// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! The client's command static actors (`gamedata_static_actors`, classPath
//! `/Command/...`) that have a `commands/<Name>.lua` script: EquipCommand,
//! the linkshell commands, ConfirmGroupCommand and the rest. The client runs
//! a command as an event against `0xA0F00000 | id`; this tells the event
//! dispatch which script it is. Read once at start-up.

use std::collections::HashMap;
use std::path::Path;
use std::sync::OnceLock;

static SCRIPTS: OnceLock<HashMap<u32, &'static str>> = OnceLock::new();

/// Load the command actors whose script exists under `script_root`.
pub fn init(rows: Vec<(u32, String)>, script_root: &Path) {
    let mut map = HashMap::new();
    for (id, name) in rows {
        if name.is_empty() || !name.chars().all(|c| c.is_ascii_alphanumeric()) {
            continue;
        }
        if script_root
            .join("commands")
            .join(format!("{name}.lua"))
            .exists()
        {
            map.insert(id, &*Box::leak(name.into_boxed_str()));
        }
    }
    tracing::info!(commands = map.len(), "command scripts mapped");
    let _ = SCRIPTS.set(map);
}

/// The script name of command actor `actor_id`, if it has one.
pub fn script_name(actor_id: u32) -> Option<&'static str> {
    SCRIPTS.get()?.get(&actor_id).copied()
}
