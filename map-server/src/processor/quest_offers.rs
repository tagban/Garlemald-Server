// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Quest offers: quests a player can take but hasn't, shown on the NPC who
//! gives them.
//!
//! pmeteor keeps every available quest at `SEQ_ACCEPT` (65535). Its
//! `onStateChange(SEQ_ACCEPT)` names the giver (`quest:SetENpc(giver,
//! QFLAG_TALK)`), the marker goes up on that NPC, and talking to them runs
//! the quest's `onTalk` at `SEQ_ACCEPT`, which shows the offer and calls
//! `player:AcceptQuest(quest)` on a yes. Here the offers live on the
//! character (`Character::quest_offers`), rebuilt at zone-in and whenever
//! the journal changes.

use std::collections::HashMap;
use std::sync::{Mutex, OnceLock};

use super::PacketProcessor;
use crate::actor::quest::QuestEnpc;
use crate::lua::command::LuaCommand;
use crate::runtime::actor_registry::ActorHandle;

/// pmeteor `SEQ_ACCEPT`: the sequence of a quest that's offered, not taken.
pub(crate) const SEQ_ACCEPT: u32 = 65535;

/// Each quest's offer markers, from its `onStateChange(SEQ_ACCEPT)`. The
/// arm only names the giver, so it's read once per quest and kept.
fn givers() -> &'static Mutex<HashMap<u32, Vec<QuestEnpc>>> {
    static GIVERS: OnceLock<Mutex<HashMap<u32, Vec<QuestEnpc>>>> = OnceLock::new();
    GIVERS.get_or_init(Default::default)
}

/// Whether a quest is offered at its giver. The default-talk carriers
/// (`Dft*`) and the opening tutorials (`Trl*`) never are. The main scenario
/// (`Man*`) is offered only where it follows another quest: the opening
/// quests replace themselves in-script, but from the level 8 quest on, each
/// nation's story is given by its giver once the quest before it is done.
fn is_offerable(script_name: &str, has_prerequisite: bool) -> bool {
    if script_name.starts_with("dft") || script_name.starts_with("trl") {
        return false;
    }
    !script_name.starts_with("man") || has_prerequisite
}

/// Quests that follow any one of several others, which the single
/// `prerequisite` column can't say: Fade to White follows whichever
/// nation's level 13 quest the player finished.
const ANY_OF_PREREQUISITES: &[(u32, &[u32])] = &[(110013, &[110004, 110008, 110012])];

/// The quests any one of which unlocks this one (empty: none needed).
fn prerequisites(quest_id: u32, prerequisite: u32) -> Vec<u32> {
    match ANY_OF_PREREQUISITES.iter().find(|(id, _)| *id == quest_id) {
        Some((_, any)) => any.to_vec(),
        None if prerequisite != 0 => vec![prerequisite],
        None => Vec::new(),
    }
}

impl PacketProcessor {
    /// Rebuild the player's offers and put the markers up (or take stale
    /// ones down).
    pub(super) async fn refresh_quest_offers(&self, handle: &ActorHandle) {
        let Some(engine) = self.lua.as_ref() else {
            return;
        };
        let metas: Vec<crate::gamedata::QuestMeta> = match engine.catalogs().quests.read() {
            Ok(m) => m.values().cloned().collect(),
            Err(_) => return,
        };
        let eligible: Vec<u32> = {
            let c = handle.character.read().await;
            let level = c.chara.level.max(0) as u16;
            let journal = &c.quest_journal;
            metas
                .iter()
                .filter(|m| {
                    let name = m.class_name.to_lowercase();
                    let needs = prerequisites(m.id, m.prerequisite);
                    is_offerable(&name, !needs.is_empty())
                        && !journal.has(m.id)
                        && !journal.is_completed(m.id)
                        && level >= m.min_level
                        && (needs.is_empty() || needs.iter().any(|p| journal.is_completed(*p)))
                        && engine.resolver().quest(&name).exists()
                })
                .map(|m| m.id)
                .collect()
        };

        let mut offers: HashMap<u32, (u32, QuestEnpc)> = HashMap::new();
        for quest_id in eligible {
            for enpc in self.quest_givers(handle, quest_id).await {
                offers
                    .entry(enpc.actor_class_id)
                    .or_insert((quest_id, enpc));
            }
        }

        let (removed, claimed): (Vec<QuestEnpc>, Vec<u32>) = {
            let mut c = handle.character.write().await;
            let removed = c
                .quest_offers
                .iter()
                .filter(|(class, _)| !offers.contains_key(class))
                .map(|(_, (_, enpc))| *enpc)
                .collect();
            let claimed = c
                .quest_journal
                .slots
                .iter()
                .flatten()
                .flat_map(|q| q.state.current.keys().copied())
                .collect();
            c.quest_offers = offers.clone();
            (removed, claimed)
        };
        // An NPC a taken quest now uses keeps that quest's marker.
        for enpc in removed {
            if !claimed.contains(&enpc.actor_class_id) {
                self.broadcast_quest_enpc_clear(handle.actor_id, enpc).await;
            }
        }
        for (class, (_, enpc)) in &offers {
            if !claimed.contains(class) {
                self.broadcast_quest_enpc_update(handle.actor_id, *enpc)
                    .await;
            }
        }
        tracing::debug!(
            player = handle.actor_id,
            offers = offers.len(),
            "quest offers refreshed"
        );
    }

    pub(super) async fn refresh_quest_offers_for(&self, player_id: u32) {
        if let Some(handle) = self.registry.get(player_id).await {
            self.refresh_quest_offers(&handle).await;
        }
    }

    /// The givers `onStateChange(SEQ_ACCEPT)` names for a quest (cached).
    async fn quest_givers(&self, handle: &ActorHandle, quest_id: u32) -> Vec<QuestEnpc> {
        if let Some(found) = givers().lock().ok().and_then(|g| g.get(&quest_id).cloned()) {
            return found;
        }
        let Some(engine) = self.lua.as_ref() else {
            return Vec::new();
        };
        let Some(script_name) = engine.catalogs().quest_script_name(quest_id) else {
            return Vec::new();
        };
        let script_path = engine.resolver().quest(&script_name);
        let snapshot = {
            let c = handle.character.read().await;
            super::build_player_snapshot_from_character(&c)
        };
        let quest_handle = offer_handle(snapshot.actor_id, quest_id);
        let engine_clone = engine.clone();
        let result = tokio::task::spawn_blocking(move || {
            engine_clone.call_quest_hook(
                &script_path,
                "onStateChange",
                snapshot,
                quest_handle,
                vec![crate::lua::QuestHookArg::Int(SEQ_ACCEPT as i64)],
            )
        })
        .await;
        let found: Vec<QuestEnpc> = match result {
            Ok(r) => r
                .commands
                .into_iter()
                .filter_map(|cmd| match cmd {
                    LuaCommand::QuestSetEnpc {
                        actor_class_id,
                        quest_flag_type,
                        is_talk_enabled,
                        is_push_enabled,
                        is_emote_enabled,
                        is_spawned,
                        ..
                    } if quest_flag_type != 0 => Some(QuestEnpc::new(
                        actor_class_id,
                        quest_flag_type,
                        is_spawned,
                        is_talk_enabled,
                        is_emote_enabled,
                        is_push_enabled,
                    )),
                    _ => None,
                })
                .collect(),
            Err(e) => {
                tracing::warn!(quest = quest_id, error = %e, "quest offer: SEQ_ACCEPT hook panicked");
                Vec::new()
            }
        };
        if let Ok(mut g) = givers().lock() {
            g.insert(quest_id, found.clone());
        }
        found
    }

    /// The quest offered by an NPC of this class, unless a taken quest has
    /// claimed the NPC (that quest's talk wins).
    pub(super) async fn offered_quest_at(
        &self,
        handle: &ActorHandle,
        npc_class_id: u32,
    ) -> Option<u32> {
        let c = handle.character.read().await;
        let claimed = c
            .quest_journal
            .slots
            .iter()
            .flatten()
            .any(|q| q.state.current.contains_key(&npc_class_id));
        if claimed {
            return None;
        }
        c.quest_offers
            .get(&npc_class_id)
            .map(|(quest_id, _)| *quest_id)
    }
}

/// A quest handle for a quest that isn't in the journal: `SEQ_ACCEPT`, no
/// flags or counters.
pub(crate) fn offer_handle(player_id: u32, quest_id: u32) -> crate::lua::LuaQuestHandle {
    crate::lua::LuaQuestHandle {
        player_id,
        quest_id,
        has_quest: false,
        sequence: SEQ_ACCEPT,
        flags: 0,
        counters: [0; 4],
        npc_ls_from: 0,
        npc_ls_msg_step: 0,
        queue: crate::lua::command::CommandQueue::new(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn story_quests_are_offered_only_after_a_prerequisite() {
        assert!(!is_offerable("man0l1", false));
        assert!(is_offerable("man1u0", true));
        assert!(!is_offerable("dftsea", false));
        assert!(!is_offerable("dftsea", true));
        assert!(!is_offerable("trl0l1", false));
        assert!(is_offerable("etc1l1", false));
        assert!(is_offerable("wld0l1", false));
    }

    #[test]
    fn fade_to_white_follows_any_nations_level_13_quest() {
        assert_eq!(prerequisites(110013, 0), vec![110004, 110008, 110012]);
        assert_eq!(prerequisites(110011, 110010), vec![110010]);
        assert!(prerequisites(110001, 0).is_empty());
    }
}
