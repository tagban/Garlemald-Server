// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Linkshells, after Project Meteor's (`World Server/DataObjects/Group/
//! Linkshell.cs`, `LinkshellManager.cs`). A linkshell is a company group
//! (`GROUP_TYPE_LINKSHELL`) the client lists in its linkshell window with the
//! crest; the crest, master and ranks reach it as group work values when it
//! answers the group packets with a group-created (`/_init`).
//!
//! The map server sends these itself, from `server_linkshells` and
//! `characters_linkshells`: with one map server it reaches every member.

use common::luaparam::LuaParam;
use common::subpacket::SubPacket;

use crate::database::Database;
use crate::packets::send::groups as tx;
use crate::runtime::actor_registry::ActorRegistry;
use crate::world_manager::WorldManager;

// Member ranks (Meteor LinkshellManager): 0x1 guest, 0x4 member, 0x7
// leader, 0xA master; the creator is made master (Database::create_linkshell).
/// Linkshells one character can belong to (Meteor `LS_MAX_ALLOWED`).
pub const MAX_PER_CHARACTER: usize = 8;

/// The group id of linkshell `db_id`: Meteor's world-group high bit, and
/// "LS" in the next bytes so a group-created can be told apart from party,
/// content and player-work groups.
pub fn group_id(db_id: u64) -> u64 {
    0x8000_4C53_0000_0000 | (db_id & 0xFFFF_FFFF)
}

pub fn db_id_of(group_id: u64) -> Option<u64> {
    ((group_id >> 32) as u32 == 0x8000_4C53).then_some(group_id & 0xFFFF_FFFF)
}

/// Linkshell names: 3-31 characters (the client's own limit), letters,
/// digits, spaces and a few marks.
pub fn name_allowed(name: &str) -> bool {
    let n = name.chars().count();
    (3..=31).contains(&n)
        && name
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || " '-_.".contains(c))
        && !name.starts_with(' ')
        && !name.ends_with(' ')
}

pub(crate) async fn send(world: &WorldManager, session_id: u32, packets: Vec<SubPacket>) {
    if let Some(client) = world.client(session_id).await {
        for mut p in packets {
            p.set_target_id(session_id);
            client.send_bytes(p.to_bytes()).await;
        }
    }
}

pub(crate) fn now_ms() -> u64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_millis() as u64)
        .unwrap_or(0)
}

/// The group packets for one linkshell (header, members, end), as Meteor's
/// `Group.SendGroupPackets`.
fn group_packets(
    actor_id: u32,
    zone_id: u32,
    gid: u64,
    name: &str,
    members: &[(u32, u8, String)],
) -> Vec<SubPacket> {
    let location = zone_id as u64;
    let seq = now_ms();
    let list: Vec<tx::GroupMember> = members
        .iter()
        .map(|(id, _, n)| tx::GroupMember {
            actor_id: *id,
            localized_name: -1,
            unknown2: 0,
            flag1: false,
            is_online: true,
            name: n.clone(),
        })
        .collect();
    let mut out = vec![
        tx::build_group_header(
            actor_id,
            location,
            seq,
            gid,
            tx::GROUP_TYPE_LINKSHELL,
            -1,
            name,
            list.len() as u32,
        ),
        tx::build_group_members_begin(actor_id, location, seq, gid, list.len() as u32),
    ];
    let mut offset = 0usize;
    while offset < list.len() {
        let left = list.len() - offset;
        out.push(if left >= 64 {
            tx::build_group_members_x64(actor_id, location, seq, &list, &mut offset)
        } else if left >= 32 {
            tx::build_group_members_x32(actor_id, location, seq, &list, &mut offset)
        } else if left >= 16 {
            tx::build_group_members_x16(actor_id, location, seq, &list, &mut offset)
        } else {
            tx::build_group_members_x08(actor_id, location, seq, &list, &mut offset)
        });
    }
    out.push(tx::build_group_members_end(actor_id, location, seq, gid));
    out
}

/// One player's view of a linkshell: its group packets.
async fn send_linkshell(
    world: &WorldManager,
    db: &Database,
    actor_id: u32,
    session_id: u32,
    zone_id: u32,
    ls: &(u64, String, u16, u32, u8),
) {
    let members = db.linkshell_members(ls.0).await.unwrap_or_default();
    send(
        world,
        session_id,
        group_packets(actor_id, zone_id, group_id(ls.0), &ls.1, &members),
    )
    .await;
    // the crest, master and ranks too, without waiting for the client's
    // group-created (it hasn't always sent one)
    let ranks: Vec<u8> = members.iter().map(|m| m.1).collect();
    let work = tx::build_synch_group_work_values_linkshell(
        actor_id,
        group_id(ls.0),
        ls.3 as u64,
        ls.2,
        ls.4,
        &ranks,
        "/_init",
    );
    send(world, session_id, work).await;
}

/// At login: every linkshell the player belongs to, and which one is
/// active (Meteor `WorldManager.DoLogin`).
pub async fn send_login(
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    chara_id: u32,
) {
    let Some(handle) = registry.get(chara_id).await else {
        return;
    };
    let zone_id = handle.character.read().await.base.zone_id;
    let linkshells = db
        .linkshells_of_character(chara_id)
        .await
        .unwrap_or_default();
    for ls in &linkshells {
        send_linkshell(world, db, handle.actor_id, handle.session_id, zone_id, ls).await;
    }
    let active = db.active_linkshell(chara_id).await.unwrap_or_default();
    let active_gid = linkshells
        .iter()
        .find(|ls| !active.is_empty() && ls.1.eq_ignore_ascii_case(&active))
        .map(|ls| group_id(ls.0))
        .unwrap_or(0);
    if active_gid == 0 && !active.is_empty() {
        let _ = db.set_active_linkshell(chara_id, "").await;
    }
    send(
        world,
        handle.session_id,
        vec![tx::build_set_active_linkshell(handle.actor_id, active_gid)],
    )
    .await;
    if !linkshells.is_empty() {
        tracing::info!(
            player = chara_id,
            linkshells = linkshells.len(),
            "linkshells sent"
        );
    }
}

/// The client created a linkshell group (`/_init`): its crest, master and
/// ranks. Returns false when `gid` isn't a linkshell.
pub async fn answer_group_created(
    world: &WorldManager,
    db: &Database,
    actor_id: u32,
    session_id: u32,
    gid: u64,
) -> bool {
    let Some(id) = db_id_of(gid) else {
        return false;
    };
    let Ok(Some(ls)) = db.linkshell_by_id(id).await else {
        return true;
    };
    let members = db.linkshell_members(id).await.unwrap_or_default();
    let ranks: Vec<u8> = members.iter().map(|m| m.1).collect();
    let packets = tx::build_synch_group_work_values_linkshell(
        actor_id,
        gid,
        ls.3 as u64,
        ls.2,
        ls.4,
        &ranks,
        "/_init",
    );
    send(world, session_id, packets).await;
    true
}

/// Every online member of linkshell `id` gets its group packets again (a
/// new member, a new crest).
async fn resend_to_members(registry: &ActorRegistry, world: &WorldManager, db: &Database, id: u64) {
    let Ok(Some(ls)) = db.linkshell_by_id(id).await else {
        return;
    };
    for (member, _, _) in db.linkshell_members(id).await.unwrap_or_default() {
        if let Some(h) = registry.get(member).await {
            let zone_id = h.character.read().await.base.zone_id;
            send_linkshell(world, db, h.actor_id, h.session_id, zone_id, &ls).await;
            // the client keeps the group, so the new work values go too
            answer_group_created(world, db, h.actor_id, h.session_id, group_id(id)).await;
        }
    }
}

/// Create a linkshell at the Adventurers' Guild (PopulaceLinkshellManager):
/// 0 created, 1 the name is taken, 2 the name can't be used, 3 failed
/// (Meteor's codes, which the script turns into the client's messages).
pub async fn create(
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    chara_id: u32,
    name: &str,
    crest: u16,
) -> i64 {
    let name = name.trim();
    if !name_allowed(name) {
        return 2;
    }
    if db
        .linkshells_of_character(chara_id)
        .await
        .map(|l| l.len())
        .unwrap_or(0)
        >= MAX_PER_CHARACTER
    {
        return 3;
    }
    match db.create_linkshell(chara_id, name, crest).await {
        Ok(Some(id)) => {
            tracing::info!(player = chara_id, linkshell = %name, crest, id, "linkshell created");
            if let Some(h) = registry.get(chara_id).await {
                let zone_id = h.character.read().await.base.zone_id;
                if let Ok(Some(ls)) = db.linkshell_by_id(id).await {
                    send_linkshell(world, db, h.actor_id, h.session_id, zone_id, &ls).await;
                }
                // a first linkshell becomes the active one
                if db
                    .active_linkshell(chara_id)
                    .await
                    .unwrap_or_default()
                    .is_empty()
                {
                    let _ = db.set_active_linkshell(chara_id, name).await;
                    send(
                        world,
                        h.session_id,
                        vec![tx::build_set_active_linkshell(h.actor_id, group_id(id))],
                    )
                    .await;
                }
            }
            0
        }
        Ok(None) => 1,
        Err(e) => {
            tracing::warn!(player = chara_id, error = %e, "linkshell create failed");
            3
        }
    }
}

/// The master changes their linkshell's crest. Returns whether it changed.
pub async fn change_crest(
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    chara_id: u32,
    name: &str,
    crest: u16,
) -> bool {
    let Ok(Some(ls)) = db.linkshell_by_name(name.trim()).await else {
        return false;
    };
    if ls.3 != chara_id {
        tracing::info!(player = chara_id, linkshell = %ls.1, "crest change refused: not the master");
        return false;
    }
    if db.set_linkshell_crest(ls.0, crest).await.is_err() {
        return false;
    }
    tracing::info!(player = chara_id, linkshell = %ls.1, crest, "linkshell crest changed");
    resend_to_members(registry, world, db, ls.0).await;
    true
}

/// The master disbands their linkshell: every online member loses it.
pub async fn disband(
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    chara_id: u32,
    name: &str,
) -> bool {
    let Ok(Some(ls)) = db.linkshell_by_name(name.trim()).await else {
        return false;
    };
    if ls.3 != chara_id {
        tracing::info!(player = chara_id, linkshell = %ls.1, "disband refused: not the master");
        return false;
    }
    let members = db.linkshell_members(ls.0).await.unwrap_or_default();
    if db.delete_linkshell(ls.0, &ls.1).await.is_err() {
        return false;
    }
    tracing::info!(player = chara_id, linkshell = %ls.1, "linkshell disbanded");
    for (member, _, _) in members {
        if let Some(h) = registry.get(member).await {
            send(
                world,
                h.session_id,
                vec![
                    tx::build_delete_group(h.actor_id, group_id(ls.0)),
                    tx::build_set_active_linkshell(h.actor_id, 0),
                ],
            )
            .await;
        }
    }
    true
}

// --- invites, leaving, ranks ---------------------------------------------------------------------

/// The WorldMaster actor: the text sheet the linkshell messages come from.
const WORLD_MASTER: u32 = 0x5FF8_0001;
/// Meteor `Group.GroupInvitationRelationGroup` and the linkshell invite
/// command (`RelationGroupManager.CreateLinkshellRelationGroup`).
const GROUP_TYPE_INVITATION: u32 = 50001;
const INVITE_COMMAND_LINKSHELL: u32 = 10002;
const MAX_MEMBERS: usize = 128;

/// A pending linkpearl offer, by invitee.
#[derive(Clone, Copy)]
pub(crate) struct Invite {
    pub(crate) inviter: u32,
    /// The linkshell offered (0 for a party offer).
    pub(crate) linkshell: u64,
    pub(crate) relation: u64,
}

fn invites() -> &'static std::sync::Mutex<std::collections::HashMap<u32, Invite>> {
    static INVITES: std::sync::OnceLock<std::sync::Mutex<std::collections::HashMap<u32, Invite>>> =
        std::sync::OnceLock::new();
    INVITES.get_or_init(Default::default)
}

pub(crate) fn next_relation_id() -> u64 {
    static NEXT: std::sync::atomic::AtomicU32 = std::sync::atomic::AtomicU32::new(1);
    0x8000_4C52_0000_0000 | NEXT.fetch_add(1, std::sync::atomic::Ordering::Relaxed) as u64
}

/// A line from the WorldMaster text sheet (Meteor `Session.SendGameMessage`).
pub(crate) async fn tell(
    world: &WorldManager,
    registry: &ActorRegistry,
    chara_id: u32,
    text_id: u16,
    params: Vec<LuaParam>,
) {
    let Some(h) = registry.get(chara_id).await else {
        return;
    };
    let pkt = crate::packets::send::misc::build_text_sheet_no_source_auto(
        WORLD_MASTER,
        WORLD_MASTER,
        text_id,
        0x20,
        &params,
        false,
    );
    send(world, h.session_id, vec![pkt]).await;
}

pub(crate) async fn name_of(db: &Database, chara_id: u32) -> String {
    db.character_name(chara_id)
        .await
        .ok()
        .flatten()
        .unwrap_or_default()
}

/// The relation group that shows the offer to both players. `command` is
/// the invite kind the client's confirm window uses (10001 party, 10002
/// linkshell).
pub(crate) async fn send_relation(
    world: &WorldManager,
    registry: &ActorRegistry,
    db: &Database,
    inv: Invite,
    invitee: u32,
    command: u32,
) {
    let members: Vec<(u32, u8, String)> = vec![
        (inv.inviter, 0, name_of(db, inv.inviter).await),
        (invitee, 0, name_of(db, invitee).await),
    ];
    for who in [inv.inviter, invitee] {
        let Some(h) = registry.get(who).await else {
            continue;
        };
        let zone_id = h.character.read().await.base.zone_id;
        let location = zone_id as u64;
        let seq = now_ms();
        let list: Vec<tx::GroupMember> = members
            .iter()
            .map(|(id, _, n)| tx::GroupMember {
                actor_id: *id,
                localized_name: -1,
                unknown2: 0,
                flag1: false,
                is_online: true,
                name: n.clone(),
            })
            .collect();
        let mut offset = 0usize;
        let packets = vec![
            tx::build_group_header(
                h.actor_id,
                location,
                seq,
                inv.relation,
                GROUP_TYPE_INVITATION,
                -1,
                "",
                2,
            ),
            tx::build_group_members_begin(h.actor_id, location, seq, inv.relation, 2),
            tx::build_group_members_x08(h.actor_id, location, seq, &list, &mut offset),
            tx::build_group_members_end(h.actor_id, location, seq, inv.relation),
            relation_work(h.actor_id, inv, command),
        ];
        send(world, h.session_id, packets).await;
    }
}

/// The relation group's work values: who offers (Meteor's host marker in
/// the low half) and what (`variableCommand`). The client's
/// GroupInvitationRelationGroup only lights its confirm command once
/// these arrive as the answer to its group-created (`/_init`).
pub(crate) fn relation_work(actor: u32, inv: Invite, command: u32) -> SubPacket {
    let host = ((inv.inviter as u64) << 32) | 0xC1_7909;
    tx::build_synch_group_work_values_entries(
        actor,
        inv.relation,
        &[
            tx::WorkValue {
                kind: 8,
                name: "work._globalTemp.host".into(),
                value: host.to_le_bytes().to_vec(),
            },
            tx::WorkValue {
                kind: 4,
                name: "work._globalTemp.variableCommand".into(),
                value: command.to_le_bytes().to_vec(),
            },
        ],
        "/_init",
    )
}

/// The client created the invitation group of a pending linkpearl offer
/// (`/_init`). False when `gid` isn't one.
pub async fn answer_relation_created(
    world: &WorldManager,
    actor_id: u32,
    session_id: u32,
    gid: u64,
) -> bool {
    let inv = invites()
        .lock()
        .ok()
        .and_then(|m| m.values().find(|i| i.relation == gid).copied());
    let Some(inv) = inv else {
        return false;
    };
    send(
        world,
        session_id,
        vec![relation_work(actor_id, inv, INVITE_COMMAND_LINKSHELL)],
    )
    .await;
    true
}

pub(crate) async fn delete_relation(
    world: &WorldManager,
    registry: &ActorRegistry,
    inv: Invite,
    invitee: u32,
) {
    for who in [inv.inviter, invitee] {
        if let Some(h) = registry.get(who).await {
            send(
                world,
                h.session_id,
                vec![tx::build_delete_group(h.actor_id, inv.relation)],
            )
            .await;
        }
    }
}

/// Offer `invitee` (an actor id) a linkpearl to `ls_name` (Meteor
/// `WorldMaster.ProcessLinkshellInvite`).
pub async fn invite(
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    inviter: u32,
    ls_name: &str,
    invitee: u32,
) {
    let Ok(Some(ls)) = db.linkshell_by_name(ls_name.trim()).await else {
        return;
    };
    let members = db.linkshell_members(ls.0).await.unwrap_or_default();
    if !members.iter().any(|m| m.0 == inviter) {
        return;
    }
    if registry.get(invitee).await.is_none() {
        tell(world, registry, inviter, 30544, vec![]).await;
        return;
    }
    if members.iter().any(|m| m.0 == invitee) {
        tell(
            world,
            registry,
            inviter,
            25282,
            vec![
                LuaParam::String(name_of(db, invitee).await),
                LuaParam::Int32(1),
            ],
        )
        .await;
        return;
    }
    if members.len() >= MAX_MEMBERS {
        tell(
            world,
            registry,
            inviter,
            25158,
            vec![LuaParam::Actor(invitee)],
        )
        .await;
        return;
    }
    let pending = invites()
        .lock()
        .map(|m| m.contains_key(&invitee))
        .unwrap_or(false);
    if pending {
        tell(
            world,
            registry,
            inviter,
            25196,
            vec![LuaParam::Actor(invitee)],
        )
        .await;
        return;
    }
    let inv = Invite {
        inviter,
        linkshell: ls.0,
        relation: next_relation_id(),
    };
    if let Ok(mut m) = invites().lock() {
        m.insert(invitee, inv);
    }
    send_relation(world, registry, db, inv, invitee, INVITE_COMMAND_LINKSHELL).await;
    tell(
        world,
        registry,
        invitee,
        25150,
        vec![
            LuaParam::Int32(1),
            LuaParam::String(ls.1.clone()),
            LuaParam::Actor(inviter),
        ],
    )
    .await;
    tell(
        world,
        registry,
        inviter,
        25151,
        vec![LuaParam::Int32(1), LuaParam::Nil, LuaParam::Actor(invitee)],
    )
    .await;
    tracing::info!(inviter, invitee, linkshell = %ls.1, "linkpearl offered");
}

/// The inviter takes the offer back.
pub async fn cancel_invite(registry: &ActorRegistry, world: &WorldManager, inviter: u32) {
    let found = invites().lock().ok().and_then(|mut m| {
        let invitee = m
            .iter()
            .find(|(_, i)| i.inviter == inviter)
            .map(|(k, _)| *k)?;
        m.remove(&invitee).map(|i| (invitee, i))
    });
    let Some((invitee, inv)) = found else {
        return;
    };
    tell(world, registry, inviter, 25191, vec![]).await;
    tell(world, registry, invitee, 25192, vec![]).await;
    delete_relation(world, registry, inv, invitee).await;
}

/// The invitee answers (ConfirmGroupCommand): 1 accept, 2 decline.
pub async fn invite_result(
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    invitee: u32,
    result: u32,
) {
    let Some(inv) = invites().lock().ok().and_then(|mut m| m.remove(&invitee)) else {
        return;
    };
    delete_relation(world, registry, inv, invitee).await;
    let Ok(Some(ls)) = db.linkshell_by_id(inv.linkshell).await else {
        return;
    };
    if result != 1 {
        tell(world, registry, invitee, 25189, vec![]).await;
        tell(world, registry, inv.inviter, 25190, vec![]).await;
        return;
    }
    if db
        .linkshells_of_character(invitee)
        .await
        .map(|l| l.len())
        .unwrap_or(0)
        >= MAX_PER_CHARACTER
    {
        tell(
            world,
            registry,
            invitee,
            25153,
            vec![LuaParam::Actor(invitee)],
        )
        .await;
        return;
    }
    let members = db.linkshell_members(ls.0).await.unwrap_or_default();
    if members.len() >= MAX_MEMBERS {
        tell(
            world,
            registry,
            inv.inviter,
            25158,
            vec![LuaParam::Actor(invitee)],
        )
        .await;
        return;
    }
    if db.add_linkshell_member(ls.0, invitee, 0x4).await.is_err() {
        return;
    }
    tracing::info!(invitee, linkshell = %ls.1, "joined a linkshell");
    resend_to_members(registry, world, db, ls.0).await;
    let joiner = name_of(db, invitee).await;
    for (member, _, _) in db.linkshell_members(ls.0).await.unwrap_or_default() {
        if member == invitee {
            tell(
                world,
                registry,
                member,
                25157,
                vec![
                    LuaParam::Int32(0),
                    LuaParam::Actor(invitee),
                    LuaParam::String(ls.1.clone()),
                ],
            )
            .await;
        } else {
            tell(
                world,
                registry,
                member,
                25284,
                vec![
                    LuaParam::Int32(0),
                    LuaParam::String(joiner.clone()),
                    LuaParam::String(ls.1.clone()),
                ],
            )
            .await;
        }
    }
    // a first linkshell becomes the active one
    if db
        .active_linkshell(invitee)
        .await
        .unwrap_or_default()
        .is_empty()
    {
        change_active(registry, world, db, invitee, &ls.1).await;
    }
}

/// Which linkshell the player speaks in and shows ('' for none).
pub async fn change_active(
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    chara_id: u32,
    ls_name: &str,
) {
    let Some(h) = registry.get(chara_id).await else {
        return;
    };
    let ls_name = ls_name.trim();
    if ls_name.is_empty() {
        let _ = db.set_active_linkshell(chara_id, "").await;
        send(
            world,
            h.session_id,
            vec![tx::build_set_active_linkshell(h.actor_id, 0)],
        )
        .await;
        tell(world, registry, chara_id, 25132, vec![LuaParam::Int32(1)]).await;
        return;
    }
    let mine = db
        .linkshells_of_character(chara_id)
        .await
        .unwrap_or_default();
    match mine.iter().find(|l| l.1.eq_ignore_ascii_case(ls_name)) {
        Some(ls) => {
            let _ = db.set_active_linkshell(chara_id, &ls.1).await;
            send(
                world,
                h.session_id,
                vec![tx::build_set_active_linkshell(h.actor_id, group_id(ls.0))],
            )
            .await;
            tell(
                world,
                registry,
                chara_id,
                25131,
                vec![LuaParam::Int32(1), LuaParam::String(ls.1.clone())],
            )
            .await;
        }
        None => {
            tell(
                world,
                registry,
                chara_id,
                25167,
                vec![LuaParam::Int32(1), LuaParam::String(ls_name.to_string())],
            )
            .await
        }
    }
}

/// Remove `chara_id` from linkshell `ls`: their group goes, the others get
/// the new list, and it stops being their active one.
async fn remove_member(
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    ls: &(u64, String, u16, u32, u8),
    chara_id: u32,
) {
    let _ = db.remove_linkshell_member(ls.0, chara_id).await;
    resend_to_members(registry, world, db, ls.0).await;
    if db
        .active_linkshell(chara_id)
        .await
        .unwrap_or_default()
        .eq_ignore_ascii_case(&ls.1)
    {
        let _ = db.set_active_linkshell(chara_id, "").await;
        if let Some(h) = registry.get(chara_id).await {
            send(
                world,
                h.session_id,
                vec![tx::build_set_active_linkshell(h.actor_id, 0)],
            )
            .await;
        }
    }
    if let Some(h) = registry.get(chara_id).await {
        send(
            world,
            h.session_id,
            vec![tx::build_delete_group(h.actor_id, group_id(ls.0))],
        )
        .await;
    }
}

/// The player leaves a linkshell (the master can't: they disband it).
pub async fn leave(
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    chara_id: u32,
    ls_name: &str,
) {
    let Ok(Some(ls)) = db.linkshell_by_name(ls_name.trim()).await else {
        return;
    };
    let members = db.linkshell_members(ls.0).await.unwrap_or_default();
    if !members.iter().any(|m| m.0 == chara_id) || ls.3 == chara_id {
        return;
    }
    tell(
        world,
        registry,
        chara_id,
        25162,
        vec![LuaParam::Int32(1), LuaParam::String(ls.1.clone())],
    )
    .await;
    remove_member(registry, world, db, &ls, chara_id).await;
    tracing::info!(player = chara_id, linkshell = %ls.1, "left a linkshell");
}

/// The master or a leader exiles a member.
pub async fn kick(
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    requester: u32,
    ls_name: &str,
    kicked_name: &str,
) {
    let Ok(Some(ls)) = db.linkshell_by_name(ls_name.trim()).await else {
        return;
    };
    let members = db.linkshell_members(ls.0).await.unwrap_or_default();
    let my_rank = members
        .iter()
        .find(|m| m.0 == requester)
        .map(|m| m.1)
        .unwrap_or(0);
    let Some(kicked) = members
        .iter()
        .find(|m| m.2.eq_ignore_ascii_case(kicked_name.trim()))
        .cloned()
    else {
        tell(
            world,
            registry,
            requester,
            25281,
            vec![
                LuaParam::Int32(1),
                LuaParam::String(kicked_name.to_string()),
                LuaParam::String(ls.1.clone()),
            ],
        )
        .await;
        return;
    };
    if my_rank < 0x7 || kicked.0 == ls.3 || kicked.1 >= my_rank {
        return;
    }
    for (member, _, _) in &members {
        if *member == kicked.0 {
            tell(
                world,
                registry,
                *member,
                25184,
                vec![LuaParam::Int32(1), LuaParam::String(ls.1.clone())],
            )
            .await;
        } else {
            tell(
                world,
                registry,
                *member,
                25280,
                vec![
                    LuaParam::Int32(1),
                    LuaParam::String(kicked.2.clone()),
                    LuaParam::String(ls.1.clone()),
                ],
            )
            .await;
        }
    }
    remove_member(registry, world, db, &ls, kicked.0).await;
    tracing::info!(requester, kicked = %kicked.2, linkshell = %ls.1, "exiled from a linkshell");
}

/// The master changes a member's rank (0x1 guest, 0x4 member, 0x7 leader).
pub async fn change_rank(
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    requester: u32,
    ls_name: &str,
    member_name: &str,
    rank: u8,
) {
    let Ok(Some(ls)) = db.linkshell_by_name(ls_name.trim()).await else {
        return;
    };
    if ls.3 != requester || ![0x1, 0x4, 0x7].contains(&rank) {
        return;
    }
    let members = db.linkshell_members(ls.0).await.unwrap_or_default();
    let Some(member) = members
        .iter()
        .find(|m| m.2.eq_ignore_ascii_case(member_name.trim()))
        .cloned()
    else {
        return;
    };
    if member.0 == ls.3 {
        return;
    }
    if let Ok(true) = db.set_linkshell_member_rank(ls.0, member.0, rank).await {
        // the new ranks to every online member (Meteor ResendWorkValues)
        let ranks: Vec<u8> = db
            .linkshell_members(ls.0)
            .await
            .unwrap_or_default()
            .iter()
            .map(|m| m.1)
            .collect();
        for (m, _, _) in db.linkshell_members(ls.0).await.unwrap_or_default() {
            if let Some(h) = registry.get(m).await {
                let pkts = tx::build_synch_group_work_values_linkshell(
                    h.actor_id,
                    group_id(ls.0),
                    ls.3 as u64,
                    ls.2,
                    ls.4,
                    &ranks,
                    "memberRank",
                );
                send(world, h.session_id, pkts).await;
            }
        }
        tell(
            world,
            registry,
            requester,
            25277,
            vec![
                LuaParam::Int32(100000 + rank as i32),
                LuaParam::String(member.2.clone()),
            ],
        )
        .await;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn group_ids_round_trip_and_names_are_checked() {
        assert_eq!(db_id_of(group_id(42)), Some(42));
        assert_eq!(db_id_of(0x8000_0000_0000_0001), None);
        assert_eq!(db_id_of(0x3000_0000_0000_0001), None);
        assert!(name_allowed("Moogle Knights"));
        assert!(!name_allowed("ab"));
        assert!(!name_allowed(" leading"));
        assert!(!name_allowed("bad<name>"));
    }
}
