// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! The enabled modules' Lua hooks (common::modules), read once at start-up.
//! `PacketProcessor` calls them after the game's own scripts: `on_login`
//! after player.lua's onLogin, `on_zone_in` after a zone's onZoneIn,
//! `on_logout` as the session ends.

use std::path::PathBuf;
use std::sync::OnceLock;

static HOOKS: OnceLock<Vec<(String, PathBuf, Vec<String>)>> = OnceLock::new();
static ENABLED: OnceLock<Vec<String>> = OnceLock::new();

/// Remember the enabled modules, and the Lua hooks they have.
pub fn init(modules: &[common::modules::Module]) {
    let _ = ENABLED.set(modules.iter().map(|m| m.name.clone()).collect());
    let hooks = modules
        .iter()
        .filter_map(|m| Some((m.name.clone(), m.lua.clone()?, m.hooks.clone())))
        .collect::<Vec<_>>();
    for (name, _, h) in &hooks {
        tracing::info!(module = %name, hooks = ?h, "module hooks loaded");
    }
    let _ = HOOKS.set(hooks);
}

/// The (module name, script) pairs that define `hook`.
pub fn with_hook(hook: &str) -> Vec<(String, PathBuf)> {
    HOOKS
        .get()
        .map(|all| {
            all.iter()
                .filter(|(_, _, h)| h.iter().any(|x| x == hook))
                .map(|(n, p, _)| (n.clone(), p.clone()))
                .collect()
        })
        .unwrap_or_default()
}

/// Whether the module `name` is enabled (false before `init`).
pub fn is_enabled(name: &str) -> bool {
    ENABLED
        .get()
        .is_some_and(|all| all.iter().any(|n| n == name))
}
