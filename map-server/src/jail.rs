// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Mordion Gaol (`settings/jail.toml`): the zone and its cells for `!jail`.
//! A jailed character (`characters.jailCell`) is put back in their cell at
//! login and whenever they arrive in another zone, can't use commands, and can
//! only /say until `!pardon`.

use std::sync::OnceLock;

use serde::Deserialize;

#[derive(Debug, Clone, Copy, Deserialize)]
pub struct Cell {
    pub x: f32,
    pub y: f32,
    pub z: f32,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct JailSettings {
    pub zone: u32,
    pub cells: Vec<Cell>,
}

impl Default for JailSettings {
    fn default() -> Self {
        Self {
            zone: 177,
            cells: vec![Cell {
                x: 2.0,
                y: 2.0,
                z: 2.0,
            }],
        }
    }
}

static SETTINGS: OnceLock<JailSettings> = OnceLock::new();

pub fn init() -> anyhow::Result<()> {
    let s: JailSettings = common::settings::load("jail", None)?;
    tracing::info!(zone = s.zone, cells = s.cells.len(), "gaol cells loaded");
    let _ = SETTINGS.set(s);
    Ok(())
}

pub fn get() -> &'static JailSettings {
    SETTINGS.get_or_init(JailSettings::default)
}

/// Cell `n` (1-based); the first cell when `n` is out of range.
pub fn cell(n: u32) -> Cell {
    let s = get();
    s.cells
        .get((n as usize).saturating_sub(1))
        .or_else(|| s.cells.first())
        .copied()
        .unwrap_or(Cell {
            x: 2.0,
            y: 2.0,
            z: 2.0,
        })
}
