// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Auto-translate entries in chat commands. The client sends an entry picked
//! from its auto-translate menu (Tab) as `02 2E <length> <category> <key...>
//! 03` inside the message. The words themselves are in the client's own
//! dictionary, not on the server, so commands only understand the entries
//! listed here: the client's [Places] category holds just Central Shroud and
//! Limsa Lominsa (captured from the 1.23b client). Other entries are dropped.

/// (category and key bytes, the name a command sees)
const KNOWN: &[(&[u8], &str)] = &[
    (&[0x15, 0xF2, 0x04, 0x1B], "Limsa Lominsa"),
    (&[0x15, 0xF2, 0x07, 0xD7], "Central Shroud"),
];

/// A chat command's text with auto-translate entries replaced by the names
/// above (with spaces around them) and any other non-text bytes dropped.
pub fn command_text(raw: &[u8]) -> String {
    let mut out = String::new();
    let mut i = 0;
    while i < raw.len() {
        if raw[i] == 0x02 && raw.get(i + 1) == Some(&0x2E) && i + 2 < raw.len() {
            let len = raw[i + 2] as usize;
            let end = i + 3 + len; // one past the 0x03
            if len >= 1 && end <= raw.len() && raw[end - 1] == 0x03 {
                let entry = &raw[i + 3..end - 1];
                if let Some((_, name)) = KNOWN.iter().find(|(k, _)| *k == entry) {
                    if !out.is_empty() && !out.ends_with(' ') {
                        out.push(' ');
                    }
                    out.push_str(name);
                    out.push(' ');
                }
                i = end;
                continue;
            }
        }
        let b = raw[i];
        if (0x20..0x7F).contains(&b) && !(b == b' ' && out.ends_with(' ')) {
            out.push(b as char);
        }
        i += 1;
    }
    out.trim_end().to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn places_from_the_client_become_names() {
        // captured from the 1.23b client: "!zone " + [Central Shroud]
        let raw = b"!zone \x02\x2e\x05\x15\xf2\x07\xd7\x03";
        assert_eq!(command_text(raw), "!zone Central Shroud");
        let raw = b"!zone\x02\x2e\x05\x15\xf2\x04\x1b\x03 Some Name";
        assert_eq!(command_text(raw), "!zone Limsa Lominsa Some Name");
        // an entry this server doesn't know is dropped
        assert_eq!(command_text(b"!camp \x02\x2e\x04\x09\x02\x03\x03"), "!camp");
        assert_eq!(command_text(b"!zone 155"), "!zone 155");
    }
}
