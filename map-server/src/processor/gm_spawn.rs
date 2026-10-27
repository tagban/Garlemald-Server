// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! GM `!spawn`, `!despawn` and `!kill`: put any battle-NPC class next to
//! you, and defeat monsters on the spot, for testing quests, leves and
//! monster models.
//!
//! `!spawn <actor class id> [level] [count] [path=/Chara/Npc/Monster/..] [genus=<id>]`
//!
//! The spawn goes through the normal battle-NPC path, fed by pool / group /
//! spawn-location rows made for it and deleted right after. `path=` swaps
//! the class path for this spawn only — most monster classes have none in
//! gamedata, and a path the client has no script for crashes it, so this is
//! how candidate paths get tried. The genus (server_battlenpc_genus) comes
//! from the path's family folder, then from other spawns of the same monster
//! family; `genus=` sets it when neither knows. GM spawns never respawn;
//! `!despawn` removes the ones in your zone.
//!
//! `!kill` defeats your target, or the nearest monster (`!kill all`: every
//! monster within 20 yalms), through the normal death path: EXP, seals and
//! quest / leve kill hooks fire as if you'd won the fight. `!kill <name>`
//! stays the FFXI name for `!die`, and both need `die`'s GM level.

use std::sync::Mutex;
use std::sync::atomic::{AtomicU32, Ordering};

use super::PacketProcessor;
use crate::runtime::actor_registry::ActorHandle;

/// Actor numbers for GM spawns, clear of zone-load spawns (0x20000..) and
/// content spawns (0x40000 | id).
const FIRST_NUMBER: u32 = 0x38000;
const LAST_NUMBER: u32 = 0x3FFFF;
const MAX_COUNT: usize = 8;

static NEXT_NUMBER: AtomicU32 = AtomicU32::new(FIRST_NUMBER);
/// (zone, actor id) of every live GM spawn, for `!despawn`.
static SPAWNED: Mutex<Vec<(u32, u32)>> = Mutex::new(Vec::new());

fn next_number() -> u32 {
    let n = NEXT_NUMBER.fetch_add(1, Ordering::Relaxed);
    if n >= LAST_NUMBER {
        NEXT_NUMBER.store(FIRST_NUMBER, Ordering::Relaxed);
    }
    FIRST_NUMBER + (n - FIRST_NUMBER) % (LAST_NUMBER - FIRST_NUMBER)
}

const KILL_RANGE: f32 = 20.0;

impl PacketProcessor {
    /// Runs `line` (without the `!`) when it is `spawn` / `despawn`. `None`
    /// when it's some other command; otherwise the reply for the chat log.
    pub(super) async fn gm_spawn_command(
        &self,
        handle: &ActorHandle,
        line: &str,
        level: u8,
    ) -> Option<Result<String, String>> {
        let mut words = line.split_whitespace();
        let name = words.next()?.to_ascii_lowercase();
        let kill = name == "kill" && matches!(words.clone().next(), None | Some("all"));
        if name != "spawn" && name != "despawn" && !kill {
            return None;
        }
        let permission = if kill { "die" } else { name.as_str() };
        if level < crate::command_permissions::get().required(permission) {
            return Some(Err(format!("!{name} needs a higher GM level")));
        }
        let (zone_id, pos, rot) = {
            let c = handle.character.read().await;
            (handle.zone_id, c.base.position(), c.base.rotation)
        };
        if kill {
            return Some(self.gm_kill(handle, words.next() == Some("all")).await);
        }
        if name == "despawn" {
            let mine: Vec<u32> = {
                let mut all = SPAWNED.lock().unwrap();
                let (here, rest): (Vec<_>, Vec<_>) =
                    all.drain(..).partition(|(z, _)| *z == zone_id);
                *all = rest;
                here.into_iter().map(|(_, a)| a).collect()
            };
            for actor_id in &mine {
                crate::runtime::quest_apply::apply_despawn_actor(
                    zone_id,
                    *actor_id,
                    &self.registry,
                    &self.world,
                )
                .await;
            }
            return Some(Ok(format!("Removed {} spawned monsters.", mine.len())));
        }

        let usage = "usage: !spawn <actor class id> [level] [count] [path=/Chara/Npc/Monster/..] [genus=<id>]";
        let mut class_id = None;
        let mut numbers = Vec::new();
        let mut path = None;
        let mut genus = None;
        for w in words {
            if let Some(p) = w.strip_prefix("path=") {
                path = Some(p.to_string());
            } else if let Some(g) = w.strip_prefix("genus=") {
                match g.parse::<u32>() {
                    Ok(g) => genus = Some(g),
                    Err(_) => return Some(Err(usage.into())),
                }
            } else if let Ok(n) = w.parse::<u32>() {
                if class_id.is_none() {
                    class_id = Some(n);
                } else {
                    numbers.push(n);
                }
            } else {
                return Some(Err(usage.into()));
            }
        }
        let Some(class_id) = class_id else {
            return Some(Err(usage.into()));
        };
        let mob_level = numbers.first().copied().unwrap_or(1).clamp(1, 99);
        let count = (numbers.get(1).copied().unwrap_or(1) as usize).clamp(1, MAX_COUNT);

        let class = match self.db.load_actor_class(class_id).await {
            Ok(Some(c)) => c,
            Ok(None) => return Some(Err(format!("no actor class {class_id}"))),
            Err(e) => return Some(Err(format!("actor class {class_id}: {e}"))),
        };
        let class_path = path.clone().unwrap_or_else(|| class.class_path.clone());
        if !class_path.starts_with("/Chara/Npc/") {
            return Some(Err(format!(
                "class {class_id} has no class path; give one with path=/Chara/Npc/Monster/<Family>/<Script>"
            )));
        }
        let family = class_path.split('/').nth(4).unwrap_or("").to_string();
        let genus = match genus {
            Some(g) => g,
            None => match self.db.genus_for_family(family).await.ok().flatten() {
                Some(g) => g,
                None => match self
                    .db
                    .genus_for_class_family(class_id)
                    .await
                    .ok()
                    .flatten()
                {
                    Some(g) => g,
                    None => {
                        return Some(Err(format!(
                            "no genus known for class {class_id}; give one with genus=<id>"
                        )));
                    }
                },
            },
        };

        // a ring around the GM, 3 yalms out, facing them
        let positions: Vec<_> = (0..count)
            .map(|k| {
                let a = rot + std::f32::consts::TAU * k as f32 / count as f32;
                let (x, z) = (pos.x + 3.0 * a.sin(), pos.z + 3.0 * a.cos());
                (x, pos.y, z, (pos.x - x).atan2(pos.z - z))
            })
            .collect();
        let (bnpc_ids, group_id, pool_id) = match self
            .db
            .gm_spawn_insert(
                class_id,
                class_id.to_string(),
                genus,
                zone_id,
                mob_level,
                positions,
            )
            .await
        {
            Ok(r) => r,
            Err(e) => return Some(Err(format!("spawn rows: {e}"))),
        };
        let mut spawned = 0;
        for bnpc_id in &bnpc_ids {
            let actor_id = (4 << 28) | (zone_id << 19) | next_number();
            if self
                .spawn_battle_npc(*bnpc_id, zone_id, actor_id, Some(path.clone()))
                .await
            {
                SPAWNED.lock().unwrap().push((zone_id, actor_id));
                spawned += 1;
            }
        }
        if let Err(e) = self.db.gm_spawn_delete(bnpc_ids, group_id, pool_id).await {
            tracing::warn!(error = %e, "gm spawn: removing the temporary rows failed");
        }
        tracing::info!(class_id, %class_path, spawned, zone_id, "gm spawn");
        Some(Ok(format!(
            "Spawned {spawned} x {class_id} ({class_path}) at level {mob_level}."
        )))
    }

    async fn gm_kill(&self, handle: &ActorHandle, all: bool) -> Result<String, String> {
        let zone_id = handle.zone_id;
        let Some(zone_arc) = self.world.zone(zone_id).await else {
            return Err("your zone isn't loaded".into());
        };
        let (target, pos) = {
            let c = handle.character.read().await;
            (c.chara.current_target, c.base.position())
        };
        let mut monsters: Vec<(f32, u32)> = {
            let zone = zone_arc.read().await;
            zone.core
                .actors_around(handle.actor_id, KILL_RANGE)
                .into_iter()
                .filter(|a| a.is_alive && a.kind == crate::zone::area::ActorKind::BattleNpc)
                .map(|a| {
                    let (dx, dz) = (a.position.x - pos.x, a.position.z - pos.z);
                    (dx * dx + dz * dz, a.actor_id)
                })
                .collect()
        };
        monsters.sort_by(|a, b| a.0.total_cmp(&b.0));
        let victims: Vec<u32> = if all {
            monsters.iter().map(|m| m.1).collect()
        } else if monsters.iter().any(|m| m.1 == target) {
            vec![target]
        } else {
            monsters.first().map(|m| m.1).into_iter().collect()
        };
        if victims.is_empty() {
            return Err("no monster nearby".into());
        }
        for &victim in &victims {
            if let Some(v) = self.registry.get(victim).await {
                v.character.write().await.chara.hp = 0;
            }
            crate::runtime::dispatcher::die_if_defender_fell(
                victim,
                Some(handle.actor_id),
                &self.registry,
                &self.world,
                &zone_arc,
                self.lua.as_ref(),
                Some(&self.db),
            )
            .await;
        }
        Ok(format!("Defeated {} monsters.", victims.len()))
    }
}
