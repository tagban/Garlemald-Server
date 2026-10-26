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

async fn send(world: &WorldManager, session_id: u32, packets: Vec<SubPacket>) {
    if let Some(client) = world.client(session_id).await {
        for mut p in packets {
            p.set_target_id(session_id);
            client.send_bytes(p.to_bytes()).await;
        }
    }
}

fn now_ms() -> u64 {
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
