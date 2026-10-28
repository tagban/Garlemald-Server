// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! `!bug <what happened>` (the bugreport module, modules/bugreport): files a
//! report with the character's place as the server knows it and the player's
//! note, and takes in the screenshot and logs the client's bug-report key
//! sent to the web server just before. The web server publishes it
//! (web-server/src/bug_reports.rs).

use std::sync::OnceLock;

use common::bug_reports::{MODULE, Settings};

use crate::database::{BugReport, Database};
use crate::runtime::actor_registry::ActorHandle;
use crate::social::ChatKind;

fn settings() -> &'static Settings {
    static S: OnceLock<Settings> = OnceLock::new();
    S.get_or_init(|| {
        Settings::load().unwrap_or_else(|e| {
            tracing::warn!(error = %e, "settings/bugreport.toml; using the defaults");
            Settings::default()
        })
    })
}

/// The command's text after `!`, when it is `bug` and the module is on:
/// Some(the player's note).
pub fn note_of(line: &str) -> Option<&str> {
    if !crate::modules::is_enabled(MODULE) {
        return None;
    }
    let mut it = line.splitn(2, char::is_whitespace);
    it.next()
        .filter(|c| c.eq_ignore_ascii_case("bug"))
        .map(|_| it.next().unwrap_or("").trim())
}

/// File the report of `character_id` (whose actor is `handle`). The answer
/// goes back to the player.
pub async fn file(
    db: &Database,
    handle: &ActorHandle,
    character_id: u32,
    note: &str,
) -> (ChatKind, String) {
    let s = settings();
    let Ok(Some(user_id)) = db.user_of_character(character_id).await else {
        return (
            ChatKind::SystemError,
            "Your bug report couldn't be filed.".into(),
        );
    };
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_or(0, |d| d.as_secs() as i64);
    let recent = db.bug_reports_since(user_id, now - 3600).await.unwrap_or(0);
    if recent >= s.per_hour {
        return (
            ChatKind::SystemError,
            format!(
                "You've sent {recent} bug reports in the last hour. Please wait a little before sending another."
            ),
        );
    }
    let pending = common::bug_reports::fresh_files(&s.pending_dir(user_id), s.pending_for());
    if note.is_empty() && pending.is_empty() {
        return (
            ChatKind::SystemError,
            "Tell us what happened: !bug <what went wrong>. Your place in the world is sent with it.".into(),
        );
    }
    let mut message: String = note.chars().take(s.max_message).collect();
    if message.is_empty() {
        message = "(no description)".into();
    }
    let mut r = {
        let c = handle.character.read().await;
        BugReport {
            user_id,
            character_id,
            character_name: c.base.display_name().to_string(),
            zone_id: c.base.zone_id,
            x: c.base.position_x,
            y: c.base.position_y,
            z: c.base.position_z,
            rotation: c.base.rotation,
            message,
            created_at: now,
            ..BugReport::default()
        }
    };
    r.zone_name = db
        .zones_matching(&r.zone_id.to_string())
        .await
        .ok()
        .and_then(|z| {
            z.into_iter()
                .find(|(id, _)| *id == r.zone_id)
                .map(|(_, p)| p)
        })
        .unwrap_or_default();
    r.world = common::server_list::ServerList::load(None)
        .ok()
        .and_then(|l| l.active().next().map(|w| w.name.clone()))
        .unwrap_or_default();
    let id = match db.insert_bug_report(&r).await {
        Ok(id) => id,
        Err(e) => {
            tracing::warn!(error = %e, "bug report not saved");
            return (
                ChatKind::SystemError,
                "Your bug report couldn't be filed.".into(),
            );
        }
    };
    let files = match common::bug_reports::claim_pending(s, user_id, id) {
        Ok(f) => f,
        Err(e) => {
            tracing::warn!(error = %e, report = id, "bug report files not moved");
            Vec::new()
        }
    };
    // the files go in only now, so the web server never publishes a report
    // before they're in place
    if let Err(e) = db.ready_bug_report(id, &files.join(",")).await {
        tracing::warn!(error = %e, report = id, "bug report not marked ready");
    }
    tracing::info!(report = id, character = %r.character_name, zone = r.zone_id, files = ?files, "bug report filed");
    let with = if files.iter().any(|f| f == "screenshot.png") {
        " with your screenshot"
    } else {
        ""
    };
    (
        ChatKind::System,
        format!("Bug report #{id} sent{with}. Thank you!"),
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn note_needs_the_module() {
        // modules aren't initialized in unit tests: the command doesn't exist
        assert_eq!(note_of("bug the door is stuck"), None);
    }
}
