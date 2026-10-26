// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! The GM tag: the GM icon shown over a character while their account is a
//! GM (level 2 or more) and the tag is on (`users.gmTag`, `!togglegm`). The
//! actors showing it are kept here so every spawn of the character sends the
//! icon.

use std::collections::HashSet;
use std::sync::{Mutex, OnceLock};

use crate::packets::send::actor::ICON_IS_GM;

/// The GM level at which the tag shows.
pub const TAG_LEVEL: u8 = 2;

fn tagged() -> &'static Mutex<HashSet<u32>> {
    static TAGGED: OnceLock<Mutex<HashSet<u32>>> = OnceLock::new();
    TAGGED.get_or_init(|| Mutex::new(HashSet::new()))
}

pub fn set(actor_id: u32, on: bool) {
    if let Ok(mut t) = tagged().lock() {
        if on {
            t.insert(actor_id);
        } else {
            t.remove(&actor_id);
        }
    }
}

/// The actor's icon bits for SetActorIcon.
pub fn icon(actor_id: u32) -> u32 {
    match tagged().lock() {
        Ok(t) if t.contains(&actor_id) => ICON_IS_GM,
        _ => 0,
    }
}
