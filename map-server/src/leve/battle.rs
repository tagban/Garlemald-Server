// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Battle leves (the regional guildleves in `gamedata_guildleves`, ids
//! 1001+ and 10801+).
//!
//! Meteor never got these past a scripted demo (its director faked the
//! kill counter on a timer), so this is native:
//!
//! * the levemete offers a camp's leves ([`offers`]); taking one puts it
//!   in a free `work.guildleveId[slot]` ([`add`]);
//! * starting it at the camp ([`start`]) spawns a guildleve director actor
//!   (the client's leve tracker reads its `guildleveWork`) and the leve's
//!   targets at monster spawn points near the camp;
//! * kills of those targets advance the objectives ([`on_death`]); when
//!   all are met the leve completes and pays gil;
//! * [`tick`] ends leves whose time ran out or whose owner left, and
//!   takes the director down a little after the leve ended.
//!
//! The leve's targets are `mob1..4` (display-name ids) with `aimNum1..4`
//! of each to defeat. A target with no count (a Detect leve's decoys)
//! spawns a couple of extras that don't count. Gathering leves count each
//! defeated target as one item.

use std::collections::HashMap;
use std::sync::{Arc, Mutex};

use common::luaparam::LuaParam;
use common::subpacket::SubPacket;

use crate::database::Database;
use crate::gamedata::{GuildleveGamedata, GuildleveRegionalEntry};
use crate::lua::LuaEngine;
use crate::packets::send::actor::ActorPropertyPacketBuilder;
use crate::runtime::actor_registry::ActorRegistry;
use crate::world_manager::WorldManager;

const WORLD_MASTER: u32 = 0x5FF8_0001;
const LOG_SYSTEM: u8 = 0x20;
/// "You have started the leve..."
const TEXT_STARTED: u16 = 50036;
/// The leve name + difficulty banner.
const TEXT_BEGIN: u16 = 50022;
/// "Time limit: N minutes."
const TEXT_TIME_LIMIT: u16 = 50026;
/// "<leve> complete!"
const TEXT_COMPLETE: u16 = 50023;
/// "You have abandoned <leve>."
const TEXT_ABANDON: u16 = 50147;
const MUSIC_VICTORY: u16 = 81;
/// The `init` values a guildleve director script returns after its class
/// path: director kind 0x4E25, the leve id, then the aetheryte-location
/// slot and an unused marker (Meteor's scripts all pass 6, 0, 0, 0).
const DIRECTOR_KIND: i32 = 0x4E25;
/// Regional guildleve slots (`work.guildleveId[16]`).
const SLOTS: u16 = 16;
/// How many of one target are up at a time; more respawn as they fall.
const MAX_UP: usize = 8;
/// Extras of a target that doesn't count (decoys).
const EXTRAS: usize = 2;
/// Targets stand at least this far from the camp.
const MIN_CAMP_DISTANCE: f32 = 30.0;
/// The director stays this long after the leve ended, so the tracker can
/// show the result.
const LINGER_MS: u64 = 15_000;
/// A levemete's leve set changes every 36 hours, as in 1.0.
const ROTATION_SECS: u64 = 36 * 3600;
/// Leve sets show 8 cards.
const CARDS: usize = 8;
/// "My Very First Adventure" and the other class tutorials: they run their
/// own scripted director.
const TUTORIALS: [u32; 6] = [10801, 10802, 11601, 11602, 12401, 12402];

/// Necrologos (orbs) and escort/survive leves need mechanics this doesn't
/// have yet, so they aren't offered.
fn plate_supported(plate_id: u32) -> bool {
    !matches!(plate_id, 20023 | 20027)
}

/// A battle leve this runtime can run: has at least one target to defeat.
pub fn is_supported(gd: &GuildleveGamedata) -> bool {
    gd.class_type == 1
        && !TUTORIALS.contains(&gd.id)
        && plate_supported(gd.plate_id)
        && (0..4).any(|i| gd.aim_num[i] > 0 && target_of(gd, i) != 0)
}

/// The display-name id objective `i` counts: its own mob, or for a single
/// objective whose mob slot is empty, the first one.
fn target_of(gd: &GuildleveGamedata, i: usize) -> u32 {
    if gd.mobs[i] != 0 {
        gd.mobs[i]
    } else if i == 0 {
        0
    } else {
        gd.mobs[0]
    }
}

/// The director script (and client class) for a leve's plate.
fn director_class(gd: &GuildleveGamedata) -> &'static str {
    crate::director::guildleve::guildleve_script_for_plate(gd.id, gd.plate_id)
        .map(|p| p.trim_start_matches("Guildleve/"))
        .unwrap_or("PrivateGLBattleSweepNormal")
}

/// Up to 8 leves for a camp's leve set: the camp's battle leves at its
/// base level (the lowest one it has), rotated every 36 hours when it has
/// more than 8.
pub fn offers(
    catalog: &HashMap<u32, GuildleveGamedata>,
    aetheryte: u32,
    now_secs: u64,
) -> Vec<u32> {
    // Unused leve rows are copies of each other (same data, new id; the
    // client titles them "x"); real leves are unique.
    let key = |g: &GuildleveGamedata| {
        (
            g.class_type,
            g.location,
            g.level,
            g.aetheryte,
            g.plate_id,
            g.border_id,
            g.time_limit,
            g.favor_count,
            g.aim_num,
            g.mobs,
        )
    };
    let mut copies: HashMap<_, usize> = HashMap::new();
    for g in catalog.values().filter(|g| g.aetheryte == aetheryte) {
        *copies.entry(key(g)).or_default() += 1;
    }
    let mine: Vec<&GuildleveGamedata> = catalog
        .values()
        .filter(|g| g.aetheryte == aetheryte && g.level > 0 && is_supported(g))
        .filter(|g| copies.get(&key(g)) == Some(&1))
        .collect();
    let Some(base) = mine.iter().map(|g| g.level).min() else {
        return Vec::new();
    };
    let mut ids: Vec<u32> = mine
        .iter()
        .filter(|g| g.level == base)
        .map(|g| g.id)
        .collect();
    ids.sort_unstable();
    if ids.len() <= CARDS {
        return ids;
    }
    let start = ((now_secs / ROTATION_SECS) as usize * CARDS) % ids.len();
    (0..CARDS).map(|k| ids[(start + k) % ids.len()]).collect()
}

#[derive(Debug, Clone, PartialEq)]
enum Phase {
    Running {
        deadline_ms: u64,
    },
    /// Ended; the director goes away at `remove_at_ms`.
    Ended {
        remove_at_ms: u64,
    },
}

#[derive(Debug, Clone)]
struct Leve {
    owner: u32,
    guildleve_id: u32,
    difficulty: u8,
    zone_id: u32,
    director_id: u32,
    monster_level: u32,
    aim: [i8; 4],
    now: [i8; 4],
    /// Display-name id each objective counts.
    targets: [u32; 4],
    /// Monster class spawned for each objective.
    classes: [u32; 4],
    /// Live spawned actors and the objective they count for.
    spawned: HashMap<u32, Option<usize>>,
    /// Ground spots the targets use.
    spots: Vec<(f32, f32, f32)>,
    next_spot: usize,
    reward_gil: i32,
    phase: Phase,
}

static ACTIVE: Mutex<Vec<Leve>> = Mutex::new(Vec::new());
static NEXT_DIRECTOR: std::sync::atomic::AtomicU32 = std::sync::atomic::AtomicU32::new(0x6_0000);

fn with_active<R>(f: impl FnOnce(&mut Vec<Leve>) -> R) -> R {
    f(&mut ACTIVE.lock().unwrap())
}

/// The leve `player_id` is running: (leve id, difficulty).
pub fn current(player_id: u32) -> Option<(u32, u8)> {
    with_active(|a| {
        a.iter()
            .find(|l| l.owner == player_id && matches!(l.phase, Phase::Running { .. }))
            .map(|l| (l.guildleve_id, l.difficulty))
    })
}

async fn send(
    registry: &ActorRegistry,
    world: &WorldManager,
    player_id: u32,
    subs: Vec<SubPacket>,
) {
    let Some(handle) = registry.get(player_id).await else {
        return;
    };
    let Some(client) = world.client(handle.session_id).await else {
        return;
    };
    for mut sub in subs {
        sub.set_target_id(handle.session_id);
        client.send_bytes(sub.to_bytes()).await;
    }
}

async fn message(
    registry: &ActorRegistry,
    world: &WorldManager,
    player_id: u32,
    text_id: u16,
    params: &[LuaParam],
) {
    let sub = if params.is_empty() {
        crate::packets::send::build_game_message_actor1(
            WORLD_MASTER,
            player_id,
            WORLD_MASTER,
            text_id,
            LOG_SYSTEM,
        )
    } else {
        crate::packets::send::build_game_message_actor1_with_params(
            WORLD_MASTER,
            player_id,
            WORLD_MASTER,
            text_id,
            LOG_SYSTEM,
            params,
        )
    };
    send(registry, world, player_id, vec![sub]).await;
}

async fn music(registry: &ActorRegistry, world: &WorldManager, player_id: u32, id: u16) {
    let sub = crate::packets::send::misc::build_set_music(player_id, id, 0);
    send(registry, world, player_id, vec![sub]).await;
}

async fn say(registry: &ActorRegistry, world: &WorldManager, player_id: u32, text: &str) {
    crate::runtime::quest_apply::apply_send_message(
        player_id, LOG_SYSTEM, "", text, registry, world,
    )
    .await;
}

fn gamedata(lua: Option<&Arc<LuaEngine>>, gl_id: u32) -> Option<GuildleveGamedata> {
    lua?.catalogs()
        .guildleves
        .read()
        .ok()
        .and_then(|m| m.get(&gl_id).cloned())
}

/// Put `gl_id` in a free regional leve slot. False when the player already
/// holds it or every slot is taken.
pub async fn add(
    player_id: u32,
    gl_id: u32,
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
) -> bool {
    let Some(handle) = registry.get(player_id).await else {
        return false;
    };
    let slot = {
        let mut c = handle.character.write().await;
        let held = &mut c.chara.guildleves_regional;
        if held.iter().any(|e| u32::from(e.guildleve_id) == gl_id) {
            None
        } else {
            let slot =
                (0..SLOTS).find(|s| !held.iter().any(|e| e.slot == *s && e.guildleve_id != 0));
            if let Some(slot) = slot {
                held.retain(|e| e.slot != slot);
                held.push(GuildleveRegionalEntry {
                    slot,
                    guildleve_id: gl_id as u16,
                    abandoned: false,
                    completed: false,
                });
            }
            slot
        }
    };
    let Some(slot) = slot else {
        return false;
    };
    if let Err(e) = db.save_guildleve(player_id, gl_id, i32::from(slot)).await {
        tracing::warn!(player = player_id, gl_id, error = %e, "guildleve: save failed");
    }
    send_slot(registry, world, player_id, slot, gl_id as u16).await;
    tracing::info!(player = player_id, gl_id, slot, "guildleve taken");
    true
}

async fn send_slot(
    registry: &ActorRegistry,
    world: &WorldManager,
    player_id: u32,
    slot: u16,
    id: u16,
) {
    let mut b = ActorPropertyPacketBuilder::new(player_id, "work/guildleve");
    b.add_short(&format!("work.guildleveId[{slot}]"), id);
    send(registry, world, player_id, b.done()).await;
}

/// Take `gl_id` out of the player's leve slots.
async fn remove(
    player_id: u32,
    gl_id: u32,
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
) {
    let Some(handle) = registry.get(player_id).await else {
        return;
    };
    let slot = {
        let mut c = handle.character.write().await;
        let held = &mut c.chara.guildleves_regional;
        let slot = held
            .iter()
            .find(|e| u32::from(e.guildleve_id) == gl_id)
            .map(|e| e.slot);
        held.retain(|e| u32::from(e.guildleve_id) != gl_id);
        slot
    };
    if let Err(e) = db.remove_guildleve(player_id, gl_id).await {
        tracing::warn!(player = player_id, gl_id, error = %e, "guildleve: remove failed");
    }
    if let Some(slot) = slot {
        send_slot(registry, world, player_id, slot, 0).await;
    }
}

fn director_packets(
    leve: &Leve,
    target: &str,
    add: impl FnOnce(&mut ActorPropertyPacketBuilder),
) -> Vec<SubPacket> {
    let mut b = ActorPropertyPacketBuilder::new(leve.director_id, target);
    add(&mut b);
    let _ = leve;
    b.done()
}

/// Gil for completing a leve. The 1.23b data carries no reward amounts, so
/// this is an approximation scaled by level and difficulty.
pub fn reward_gil(level: u16, difficulty: u8) -> i32 {
    let base = 100 + 40 * i32::from(level.max(1));
    base * (4 + i32::from(difficulty.clamp(1, 5))) / 5
}

/// Start the leve `gl_id` the player holds, at `difficulty` (1..=5 stars).
#[allow(clippy::too_many_arguments)]
pub async fn start(
    player_id: u32,
    gl_id: u32,
    difficulty: u8,
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    lua: Option<&Arc<LuaEngine>>,
    now_ms: u64,
) {
    let Some(gd) = gamedata(lua, gl_id) else {
        tracing::warn!(player = player_id, gl_id, "guildleve: no gamedata");
        return;
    };
    if current(player_id).is_some() {
        say(
            registry,
            world,
            player_id,
            "You are already on a levequest.",
        )
        .await;
        return;
    }
    if !is_supported(&gd) {
        say(
            registry,
            world,
            player_id,
            "This levequest isn't available yet.",
        )
        .await;
        return;
    }
    let Some(handle) = registry.get(player_id).await else {
        return;
    };
    let zone_id = handle.zone_id;
    let held = {
        let c = handle.character.read().await;
        c.chara
            .guildleves_regional
            .iter()
            .any(|e| u32::from(e.guildleve_id) == gl_id)
    };
    if !held {
        tracing::warn!(
            player = player_id,
            gl_id,
            "guildleve: start without holding it"
        );
        return;
    }
    let difficulty = difficulty.clamp(1, 5);

    // Ground spots: the monster spawn point nearest the camp (but not on
    // top of it), then the spawn points around that one.
    let camp = match db.aetheryte_spot(gd.aetheryte).await {
        Ok(Some((z, x, y, zz))) if z == zone_id => (x, y, zz),
        _ => {
            let c = handle.character.read().await;
            (c.base.position_x, c.base.position_y, c.base.position_z)
        }
    };
    let points = db.battlenpc_spawn_points(zone_id).await.unwrap_or_default();
    let dist =
        |a: (f32, f32, f32), b: (f32, f32, f32)| ((a.0 - b.0).powi(2) + (a.2 - b.2).powi(2)).sqrt();
    let center = points
        .iter()
        .copied()
        .filter(|p| dist(*p, camp) >= MIN_CAMP_DISTANCE)
        .min_by(|a, b| dist(*a, camp).total_cmp(&dist(*b, camp)))
        .unwrap_or((camp.0 + MIN_CAMP_DISTANCE, camp.1, camp.2));
    let mut spots: Vec<(f32, f32, f32)> = points.clone();
    spots.sort_by(|a, b| dist(*a, center).total_cmp(&dist(*b, center)));
    spots.truncate(24);
    if spots.is_empty() {
        spots.push(center);
    }

    let mut classes = [0u32; 4];
    let mut targets = [0u32; 4];
    for i in 0..4 {
        if gd.aim_num[i] <= 0 {
            continue;
        }
        targets[i] = target_of(&gd, i);
        classes[i] = db
            .monster_class_for_name(targets[i])
            .await
            .ok()
            .flatten()
            .unwrap_or(0);
    }
    let director_id = (6 << 28)
        | (zone_id << 19)
        | (NEXT_DIRECTOR.fetch_add(1, std::sync::atomic::Ordering::Relaxed) & 0x7_FFFF);
    let time_limit_ms = u64::from(gd.time_limit.max(1)) * 60_000;
    let mut leve = Leve {
        owner: player_id,
        guildleve_id: gl_id,
        difficulty,
        zone_id,
        director_id,
        // the client's difficulty menu: each star past the first is enemy level +3
        monster_level: u32::from(gd.level.max(1)) + 3 * u32::from(difficulty - 1),
        aim: gd.aim_num.map(|a| a.max(0)),
        now: [0; 4],
        targets,
        classes,
        spawned: HashMap::new(),
        spots,
        next_spot: 0,
        reward_gil: reward_gil(gd.level, difficulty),
        phase: Phase::Running {
            deadline_ms: now_ms + time_limit_ms,
        },
    };
    for i in 0..4 {
        if leve.aim[i] > 0 && classes[i] == 0 {
            tracing::warn!(
                gl_id,
                target = targets[i],
                "guildleve: no monster class for target; objective dropped"
            );
            leve.aim[i] = 0;
        }
    }
    if leve.aim.iter().all(|a| *a == 0) {
        say(
            registry,
            world,
            player_id,
            "This levequest's targets couldn't be found.",
        )
        .await;
        return;
    }

    // Director actor first: the tracker and the start texts point at it.
    let (zone_name, zone_actor) = match world.zone(zone_id).await {
        Some(z) => {
            let z = z.read().await;
            (z.core.zone_name.clone(), z.core.actor_id)
        }
        None => return,
    };
    let class = director_class(&gd);
    let class_path = format!("/Director/Guildleve/{class}");
    let spawn = crate::world_manager::build_director_spawn_subpackets_with(
        director_id,
        zone_actor,
        &class_path,
        class,
        &zone_name,
        &[
            LuaParam::Int32(DIRECTOR_KIND),
            LuaParam::Int32(gl_id as i32),
            LuaParam::Int32(6),
            LuaParam::Int32(0),
            LuaParam::Int32(0),
            LuaParam::Int32(0),
        ],
    );
    send(registry, world, player_id, spawn).await;

    message(
        registry,
        world,
        player_id,
        TEXT_STARTED,
        &[LuaParam::Int32(gl_id as i32), LuaParam::Actor(player_id)],
    )
    .await;
    let anim =
        crate::director::guildleve::guildleve_start_animation(gd.border_id, gd.plate_id, false);
    let anim_sub = crate::packets::send::actor::build_play_animation_on_actor(player_id, anim);
    send(registry, world, player_id, vec![anim_sub]).await;
    if let Some(m) =
        crate::director::guildleve::GuildleveLocationMusic::pick(u32::from(gd.location))
    {
        music(registry, world, player_id, m).await;
    }
    message(
        registry,
        world,
        player_id,
        TEXT_BEGIN,
        &[
            LuaParam::Int32(gl_id as i32),
            LuaParam::Int32(i32::from(difficulty)),
        ],
    )
    .await;
    message(
        registry,
        world,
        player_id,
        TEXT_TIME_LIMIT,
        &[LuaParam::Int32(gd.time_limit as i32)],
    )
    .await;

    let start_secs = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs() as u32)
        .unwrap_or_default();
    let mut subs = director_packets(&leve, "guildleveWork/start", |b| {
        b.add_int("guildleveWork.startTime", start_secs);
    });
    subs.extend(director_packets(&leve, "guildleveWork/infoVariable", |b| {
        for i in 0..4 {
            if leve.aim[i] != 0 {
                b.add_byte(&format!("guildleveWork.aimNum[{i}]"), leve.aim[i] as u8);
                b.add_byte(&format!("guildleveWork.uiState[{i}]"), 1);
            }
        }
    }));
    subs.extend(director_packets(&leve, "guildleveWork/marker", |b| {
        b.add_float("guildleveWork.markerX[0]", center.0);
        b.add_float("guildleveWork.markerY[0]", center.1);
        b.add_float("guildleveWork.markerZ[0]", center.2);
    }));
    send(registry, world, player_id, subs).await;

    // Targets: up to MAX_UP of each objective, plus decoys for mobs that
    // don't count.
    let mut wave: Vec<(u32, Option<usize>)> = Vec::new();
    for i in 0..4 {
        for _ in 0..(leve.aim[i] as usize).min(MAX_UP) {
            wave.push((leve.classes[i], Some(i)));
        }
    }
    for (j, &mob) in gd.mobs.iter().enumerate() {
        if mob == 0 || leve.targets.contains(&mob) || gd.mobs[..j].contains(&mob) {
            continue;
        }
        if let Ok(Some(class_id)) = db.monster_class_for_name(mob).await {
            for _ in 0..EXTRAS {
                wave.push((class_id, None));
            }
        }
    }
    for (class_id, objective) in wave {
        if let Some(actor_id) = spawn_one(&mut leve, class_id, registry, world, db, lua).await {
            leve.spawned.insert(actor_id, objective);
        }
    }
    tracing::info!(
        player = player_id,
        gl_id,
        difficulty,
        zone_id,
        director = format!("0x{director_id:08X}"),
        targets = leve.spawned.len(),
        center = ?center,
        "battle leve started"
    );
    with_active(|a| a.push(leve));
}

/// Spawn one leve monster at the leve's next ground spot.
async fn spawn_one(
    leve: &mut Leve,
    class_id: u32,
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    lua: Option<&Arc<LuaEngine>>,
) -> Option<u32> {
    let class = db.load_actor_class(class_id).await.ok().flatten()?;
    let genus = crate::processor::gm_spawn::genus_for(db, class_id, &class.class_path).await;
    let (x, y, z) = leve.spots[leve.next_spot % leve.spots.len()];
    leve.next_spot += 1;
    // spread out a little around the spot
    let k = leve.next_spot as f32;
    let (x, z) = (x + 2.0 * (k * 2.4).sin(), z + 2.0 * (k * 2.4).cos());
    let rotation = (k * 1.7) % std::f32::consts::TAU;
    let (bnpc_ids, group_id, pool_id) = db
        .gm_spawn_insert(
            class_id,
            class_id.to_string(),
            genus,
            leve.zone_id,
            leve.monster_level,
            vec![(x, y, z, rotation)],
        )
        .await
        .ok()?;
    let mut spawned = None;
    for bnpc_id in &bnpc_ids {
        let actor_id = (4 << 28) | (leve.zone_id << 19) | crate::processor::gm_spawn::next_number();
        if crate::runtime::bnpc_spawn::spawn_battle_npc(
            *bnpc_id,
            leve.zone_id,
            actor_id,
            Some(None),
            db,
            world,
            registry,
            lua,
        )
        .await
        {
            spawned = Some(actor_id);
        }
    }
    if let Err(e) = db.gm_spawn_delete(bnpc_ids, group_id, pool_id).await {
        tracing::warn!(error = %e, "guildleve: removing the temporary spawn rows failed");
    }
    spawned
}

/// A battle NPC died: count it for the leve that spawned it.
pub async fn on_death(
    victim_id: u32,
    registry: &ActorRegistry,
    world: &WorldManager,
    db: Option<&Database>,
    lua: Option<&Arc<LuaEngine>>,
    now_ms: u64,
) {
    // update under the lock, act after it
    let hit = with_active(|a| {
        let leve = a.iter_mut().find(|l| {
            matches!(l.phase, Phase::Running { .. }) && l.spawned.contains_key(&victim_id)
        })?;
        let objective = leve.spawned.remove(&victim_id)?;
        let i = objective?;
        if leve.now[i] >= leve.aim[i] {
            return None;
        }
        leve.now[i] += 1;
        let up = leve.spawned.values().filter(|o| **o == Some(i)).count() as i8;
        let respawn = leve.now[i] + up < leve.aim[i];
        let done = (0..4).all(|k| leve.now[k] >= leve.aim[k]);
        Some((leve.clone(), i, respawn, done))
    });
    let Some((leve, i, respawn, done)) = hit else {
        return;
    };
    let subs = director_packets(&leve, "guildleveWork/infoVariable", |b| {
        b.add_byte(&format!("guildleveWork.aimNumNow[{i}]"), leve.now[i] as u8);
    });
    send(registry, world, leve.owner, subs).await;
    tracing::info!(
        player = leve.owner,
        gl_id = leve.guildleve_id,
        objective = i,
        now = leve.now[i],
        aim = leve.aim[i],
        "battle leve kill"
    );
    if done {
        if let Some(db) = db {
            complete(leve.owner, registry, world, db, now_ms).await;
        }
        return;
    }
    if respawn && let Some(db) = db {
        let mut leve = leve;
        let class_id = leve.classes[i];
        if let Some(actor_id) = spawn_one(&mut leve, class_id, registry, world, db, lua).await {
            with_active(|a| {
                if let Some(l) = a.iter_mut().find(|l| l.owner == leve.owner) {
                    l.spawned.insert(actor_id, Some(i));
                    l.next_spot = leve.next_spot;
                }
            });
        }
    }
}

/// End the running leve; returns it with its phase set to Ended.
fn finish(player_id: u32, now_ms: u64) -> Option<Leve> {
    with_active(|a| {
        let leve = a
            .iter_mut()
            .find(|l| l.owner == player_id && matches!(l.phase, Phase::Running { .. }))?;
        leve.phase = Phase::Ended {
            remove_at_ms: now_ms + LINGER_MS,
        };
        let out = leve.clone();
        leve.spawned.clear();
        Some(out)
    })
}

async fn wrap_up(leve: &Leve, registry: &ActorRegistry, world: &WorldManager, db: &Database) {
    for &actor_id in leve.spawned.keys() {
        crate::runtime::quest_apply::apply_despawn_actor(leve.zone_id, actor_id, registry, world)
            .await;
    }
    let subs = {
        let mut s = director_packets(leve, "guildleveWork/signal", |b| {
            b.add_byte("guildleveWork.signal", (-1i8) as u8);
        });
        s.extend(director_packets(leve, "guildleveWork/start", |b| {
            b.add_int("guildleveWork.startTime", 0);
        }));
        s
    };
    send(registry, world, leve.owner, subs).await;
    remove(leve.owner, leve.guildleve_id, registry, world, db).await;
}

async fn complete(
    player_id: u32,
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    now_ms: u64,
) {
    let Some(leve) = finish(player_id, now_ms) else {
        return;
    };
    music(registry, world, player_id, MUSIC_VICTORY).await;
    message(
        registry,
        world,
        player_id,
        TEXT_COMPLETE,
        &[LuaParam::Int32(leve.guildleve_id as i32)],
    )
    .await;
    wrap_up(&leve, registry, world, db).await;
    crate::runtime::quest_apply::apply_add_gil(
        player_id,
        leve.reward_gil,
        registry,
        Some(world),
        db,
    )
    .await;
    say(
        registry,
        world,
        player_id,
        &format!(
            "You receive {} gil for completing the levequest.",
            leve.reward_gil
        ),
    )
    .await;
    tracing::info!(
        player = player_id,
        gl_id = leve.guildleve_id,
        gil = leve.reward_gil,
        "battle leve complete"
    );
}

/// Give up the running leve.
pub async fn abandon(
    player_id: u32,
    registry: &ActorRegistry,
    world: &WorldManager,
    db: &Database,
    now_ms: u64,
) {
    let Some(leve) = finish(player_id, now_ms) else {
        return;
    };
    message(
        registry,
        world,
        player_id,
        TEXT_ABANDON,
        &[LuaParam::Int32(leve.guildleve_id as i32)],
    )
    .await;
    wrap_up(&leve, registry, world, db).await;
    tracing::info!(
        player = player_id,
        gl_id = leve.guildleve_id,
        "battle leve abandoned"
    );
}

/// Time limits, owners who left, and taking ended leves' directors down.
pub async fn tick(now_ms: u64, registry: &ActorRegistry, world: &WorldManager, db: &Database) {
    // once a second is plenty
    static LAST: std::sync::atomic::AtomicU64 = std::sync::atomic::AtomicU64::new(0);
    let last = LAST.load(std::sync::atomic::Ordering::Relaxed);
    if now_ms < last + 1000 {
        return;
    }
    LAST.store(now_ms, std::sync::atomic::Ordering::Relaxed);
    let snapshot: Vec<(u32, u32, u32, Phase)> = with_active(|a| {
        a.iter()
            .map(|l| (l.owner, l.zone_id, l.director_id, l.phase.clone()))
            .collect()
    });
    if snapshot.is_empty() {
        return;
    }
    for (owner, zone_id, director_id, phase) in snapshot {
        let here = match registry.get(owner).await {
            Some(h) => h.zone_id == zone_id && world.client(h.session_id).await.is_some(),
            None => false,
        };
        match phase {
            Phase::Running { deadline_ms } if !here || now_ms >= deadline_ms => {
                if let Some(leve) = finish(owner, now_ms) {
                    wrap_up(&leve, registry, world, db).await;
                    if here {
                        say(
                            registry,
                            world,
                            owner,
                            "Time is up. The levequest has failed.",
                        )
                        .await;
                    }
                    tracing::info!(
                        player = owner,
                        gl_id = leve.guildleve_id,
                        left = !here,
                        "battle leve failed"
                    );
                }
            }
            Phase::Ended { remove_at_ms } if now_ms >= remove_at_ms || !here => {
                with_active(|a| a.retain(|l| l.director_id != director_id));
                if here {
                    let sub = crate::packets::send::actor::build_remove_actor(director_id);
                    send(registry, world, owner, vec![sub]).await;
                    let bgm = match world.zone(zone_id).await {
                        Some(z) => z.read().await.core.bgm_day,
                        None => 0,
                    };
                    if bgm != 0 {
                        music(registry, world, owner, bgm).await;
                    }
                }
            }
            _ => {}
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn leve(
        id: u32,
        aetheryte: u32,
        level: u16,
        plate: u32,
        aim: [i8; 4],
        mobs: [u32; 4],
    ) -> GuildleveGamedata {
        GuildleveGamedata {
            id,
            class_type: 1,
            location: 1,
            level,
            aetheryte,
            plate_id: plate,
            time_limit: 30,
            aim_num: aim,
            mobs,
            ..Default::default()
        }
    }

    #[test]
    fn offers_the_camps_base_level_and_rotates() {
        let mut cat = HashMap::new();
        for k in 0..10 {
            let id = 10821 + k;
            cat.insert(
                id,
                leve(id, 1280002, 1, 20021, [5, 0, 0, 0], [3205701 + k, 0, 0, 0]),
            );
        }
        // unused copies of one row
        for id in [10840, 10841] {
            cat.insert(
                id,
                leve(id, 1280002, 1, 20021, [3, 0, 0, 0], [3204101, 0, 0, 0]),
            );
        }
        // other levels, other camps, tutorials and unsupported plates
        cat.insert(
            1119,
            leve(1119, 1280002, 50, 20059, [1, 0, 0, 0], [3109003, 0, 0, 0]),
        );
        cat.insert(
            10801,
            leve(10801, 1280002, 1, 20021, [3, 0, 0, 0], [3204001, 0, 0, 0]),
        );
        cat.insert(
            10846,
            leve(10846, 1280002, 1, 20023, [3, 0, 0, 0], [0, 0, 0, 0]),
        );
        cat.insert(
            10881,
            leve(10881, 1280003, 10, 20021, [3, 0, 0, 0], [3205602, 0, 0, 0]),
        );
        let first = offers(&cat, 1280002, 0);
        assert_eq!(first, (10821..10829).collect::<Vec<_>>());
        let later = offers(&cat, 1280002, ROTATION_SECS);
        assert_eq!(later.len(), 8);
        assert_ne!(later, first, "the set rotates");
        assert!(later.iter().all(|id| (10821..10831).contains(id)));
        assert_eq!(offers(&cat, 1280003, 0), vec![10881]);
        assert!(offers(&cat, 1280099, 0).is_empty());
    }

    #[test]
    fn needs_a_target_to_be_supported() {
        assert!(!is_supported(&leve(
            10863,
            1280005,
            20,
            20025,
            [3, 0, 0, 0],
            [0, 0, 0, 0]
        )));
        assert!(is_supported(&leve(
            10866,
            1280005,
            20,
            20028,
            [4, 0, 0, 0],
            [3202603, 3206004, 0, 0]
        )));
    }

    #[test]
    fn reward_grows_with_level_and_difficulty() {
        assert!(reward_gil(1, 1) < reward_gil(1, 5));
        assert!(reward_gil(1, 3) < reward_gil(20, 3));
        assert_eq!(reward_gil(1, 1), 140);
    }
}
