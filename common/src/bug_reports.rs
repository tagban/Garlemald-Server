// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Player bug reports (modules/bugreport), the parts the map server (which
//! files a report on `!bug`) and the web server (which takes the client's
//! files and publishes reports) share: settings/bugreport.toml and where the
//! files are kept.
//!
//! ```text
//! <folder>/pending/<account id>/<file>   sent by the client's bug-report key, waiting for !bug
//! <folder>/<report id>/<file>            a filed report's files
//! ```

use std::path::{Path, PathBuf};
use std::time::{Duration, SystemTime};

use serde::Deserialize;

/// The module (modules/bugreport); off by default.
pub const MODULE: &str = "bugreport";

/// The files a client may send, and whether each is a log (text, cut to
/// `max_log_kb` from the end) rather than the screenshot.
pub const FILES: &[(&str, bool)] = &[
    ("screenshot.png", false),
    ("game.log", true),
    ("game.prev.log", true),
    ("launcher.log", true),
    ("client.txt", true),
];

/// Whether `name` is one of [`FILES`]; Some(is a log).
pub fn file_kind(name: &str) -> Option<bool> {
    FILES.iter().find(|(n, _)| *n == name).map(|(_, log)| *log)
}

#[derive(Debug, Clone, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct Settings {
    pub folder: PathBuf,
    pub per_hour: u32,
    pub pending_minutes: u64,
    pub max_screenshot_kb: usize,
    pub max_log_kb: usize,
    pub max_message: usize,
    pub github: GitHub,
    pub discord: Discord,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct GitHub {
    pub repo: String,
    pub token: String,
    pub labels: Vec<String>,
    pub branch: String,
    pub api: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct Discord {
    pub webhook: String,
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            folder: PathBuf::from("./data/bug-reports"),
            per_hour: 5,
            pending_minutes: 15,
            max_screenshot_kb: 6144,
            max_log_kb: 1024,
            max_message: 1000,
            github: GitHub::default(),
            discord: Discord::default(),
        }
    }
}

impl Default for GitHub {
    fn default() -> Self {
        Self {
            repo: String::new(),
            token: String::new(),
            labels: vec!["bug report".into()],
            branch: "main".into(),
            api: "https://api.github.com".into(),
        }
    }
}

impl Settings {
    /// settings/bugreport.toml over the shipped defaults, with the secrets
    /// from the environment when it has them.
    pub fn load() -> anyhow::Result<Self> {
        let mut s: Self = crate::settings::load("bugreport", None)?;
        if let Ok(t) = std::env::var("XIVLEGACY_BUGREPORT_GITHUB_TOKEN")
            && !t.is_empty()
        {
            s.github.token = t;
        }
        if let Ok(w) = std::env::var("XIVLEGACY_BUGREPORT_DISCORD_WEBHOOK")
            && !w.is_empty()
        {
            s.discord.webhook = w;
        }
        Ok(s)
    }

    pub fn github_on(&self) -> bool {
        !self.github.repo.is_empty() && !self.github.token.is_empty()
    }

    pub fn discord_on(&self) -> bool {
        !self.discord.webhook.is_empty()
    }

    pub fn pending_dir(&self, user_id: i64) -> PathBuf {
        self.folder.join("pending").join(user_id.to_string())
    }

    pub fn report_dir(&self, report_id: i64) -> PathBuf {
        self.folder.join(report_id.to_string())
    }

    pub fn pending_for(&self) -> Duration {
        Duration::from_secs(self.pending_minutes * 60)
    }
}

/// The files waiting in `dir` that are younger than `max_age`, by name;
/// older ones are deleted.
pub fn fresh_files(dir: &Path, max_age: Duration) -> Vec<String> {
    let mut out = Vec::new();
    let Ok(rd) = std::fs::read_dir(dir) else {
        return out;
    };
    let now = SystemTime::now();
    for e in rd.flatten() {
        let name = e.file_name().to_string_lossy().into_owned();
        if file_kind(&name).is_none() {
            continue;
        }
        let young = e
            .metadata()
            .and_then(|m| m.modified())
            .is_ok_and(|t| now.duration_since(t).unwrap_or_default() <= max_age);
        if young {
            out.push(name);
        } else {
            let _ = std::fs::remove_file(e.path());
        }
    }
    out.sort();
    out
}

/// Move the files waiting for account `user_id` to report `report_id`'s
/// folder. Returns their names.
pub fn claim_pending(s: &Settings, user_id: i64, report_id: i64) -> std::io::Result<Vec<String>> {
    let from = s.pending_dir(user_id);
    let names = fresh_files(&from, s.pending_for());
    let to = s.report_dir(report_id);
    std::fs::create_dir_all(&to)?;
    let mut moved = Vec::new();
    for n in names {
        if std::fs::rename(from.join(&n), to.join(&n)).is_ok() {
            moved.push(n);
        }
    }
    Ok(moved)
}

/// `text` with every `secret` (a session id) blotted out.
pub fn scrub(text: &str, secrets: &[&str]) -> String {
    let mut out = text.to_string();
    for s in secrets.iter().filter(|s| s.len() >= 8) {
        out = out.replace(s, "[session]");
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn pending_files_move_to_the_report_and_stale_ones_go() {
        let root = crate::test_tmp::dir().join("bugreport");
        let s = Settings {
            folder: root.clone(),
            ..Settings::default()
        };
        let p = s.pending_dir(7);
        std::fs::create_dir_all(&p).unwrap();
        std::fs::write(p.join("screenshot.png"), b"png").unwrap();
        std::fs::write(p.join("game.log"), b"log").unwrap();
        std::fs::write(p.join("evil.sh"), b"no").unwrap();
        let moved = claim_pending(&s, 7, 3).unwrap();
        assert_eq!(moved, vec!["game.log", "screenshot.png"]);
        assert!(s.report_dir(3).join("screenshot.png").exists());
        assert!(claim_pending(&s, 7, 4).unwrap().is_empty());
        // only the files a client may send are ever picked up
        assert!(p.join("evil.sh").exists());
    }

    #[test]
    fn scrub_blots_out_session_ids() {
        let sid = "a".repeat(56);
        assert_eq!(scrub(&format!("id {sid} ok"), &[&sid]), "id [session] ok");
    }
}
