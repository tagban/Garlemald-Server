// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Who may use each chat command (`settings/commands.toml`). GM levels are
//! per account (`users.gmLevel`): 0 player, 1 helper, 2 GM, 3 senior GM,
//! 4 administrator. A command the settings don't list needs administrator,
//! so a new command is closed until an operator opens it. The server console
//! (stdin, the GM FIFO) isn't limited.

use std::collections::BTreeMap;
use std::sync::OnceLock;

use serde::Deserialize;

pub const ADMINISTRATOR: u8 = 4;

#[derive(Debug, Clone, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct CommandSettings {
    /// The level needed to aim a command at another player; below it, a
    /// command only works on whoever typed it.
    pub target_others: u8,
    /// The level each command needs, by name.
    pub levels: BTreeMap<String, u8>,
}

impl Default for CommandSettings {
    fn default() -> Self {
        Self {
            target_others: 2,
            levels: BTreeMap::new(),
        }
    }
}

impl CommandSettings {
    /// The level `command` needs.
    pub fn required(&self, command: &str) -> u8 {
        self.levels.get(command).copied().unwrap_or(ADMINISTRATOR)
    }
}

static SETTINGS: OnceLock<CommandSettings> = OnceLock::new();

/// Read `settings/commands.toml` once, at start-up.
pub fn init() -> anyhow::Result<()> {
    let s: CommandSettings = common::settings::load("commands", None)?;
    tracing::info!(
        commands = s.levels.len(),
        target_others = s.target_others,
        "command levels loaded"
    );
    let _ = SETTINGS.set(s);
    Ok(())
}

/// The settings (the built-in defaults before `init`, as in tests: every
/// command at administrator).
pub fn get() -> &'static CommandSettings {
    SETTINGS.get_or_init(CommandSettings::default)
}

/// The name of a GM level.
pub fn level_name(level: u8) -> &'static str {
    match level {
        0 => "player",
        1 => "helper",
        2 => "GM",
        3 => "senior GM",
        _ => "administrator",
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn unlisted_commands_need_administrator() {
        let s: CommandSettings =
            toml::from_str("target_others = 2\n[levels]\nhelp = 0\nzone = 2\n").unwrap();
        assert_eq!(
            (
                s.required("help"),
                s.required("zone"),
                s.required("givegil")
            ),
            (0, 2, ADMINISTRATOR)
        );
    }
}
