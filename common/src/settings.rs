// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Settings: shipped defaults plus the operator's overrides.
//!
//! ```text
//! settings/default/<name>.toml   shipped defaults, tracked
//! settings/<name>.toml           the operator's overrides, not tracked
//! ```
//!
//! An override file holds only what differs: its tables are merged key by key
//! over the defaults, and anything else (a value, an array such as the
//! `[[servers]]` list) replaces the default outright. `--config <file>` names a
//! different override file. The settings folder is `./settings`, or
//! `XIVLEGACY_SETTINGS` when set.

use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use serde::de::DeserializeOwned;

/// The settings folder.
pub fn root() -> PathBuf {
    std::env::var_os("XIVLEGACY_SETTINGS")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("./settings"))
}

/// `name`'s settings: `settings/default/<name>.toml`, then the override
/// (`override_path`, else `settings/<name>.toml`) over it. Missing files are
/// skipped; with neither, `T::default()`. A file that exists but doesn't parse
/// is an error: a typo silently replaced by defaults would be worse.
pub fn load<T: DeserializeOwned + Default>(name: &str, override_path: Option<&Path>) -> Result<T> {
    let root = root();
    let default = root.join("default").join(format!("{name}.toml"));
    let user = override_path
        .map(Path::to_path_buf)
        .unwrap_or_else(|| root.join(format!("{name}.toml")));
    let mut merged: Option<toml::Value> = None;
    for path in [&default, &user] {
        if !path.exists() {
            continue;
        }
        let raw =
            std::fs::read_to_string(path).with_context(|| format!("reading {}", path.display()))?;
        let value: toml::Value =
            toml::from_str(&raw).with_context(|| format!("parsing {}", path.display()))?;
        tracing::debug!(path = %path.display(), "settings file loaded");
        merged = Some(match merged {
            Some(base) => merge(base, value),
            None => value,
        });
    }
    match merged {
        Some(v) => v.try_into().with_context(|| {
            format!(
                "{name} settings ({} over {})",
                user.display(),
                default.display()
            )
        }),
        None => {
            tracing::warn!(name, folder = %root.display(), "no settings files; using built-in defaults");
            Ok(T::default())
        }
    }
}

/// `over` merged into `base`: tables key by key, anything else replaced.
pub fn merge(base: toml::Value, over: toml::Value) -> toml::Value {
    match (base, over) {
        (toml::Value::Table(mut b), toml::Value::Table(o)) => {
            for (k, v) in o {
                let merged = match b.remove(&k) {
                    Some(old) => merge(old, v),
                    None => v,
                };
                b.insert(k, merged);
            }
            toml::Value::Table(b)
        }
        (_, o) => o,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[derive(Debug, Default, serde::Deserialize)]
    #[serde(default)]
    struct S {
        server: Server,
        list: Vec<u32>,
    }
    #[derive(Debug, serde::Deserialize)]
    #[serde(default)]
    struct Server {
        bind_ip: String,
        port: u16,
    }
    impl Default for Server {
        fn default() -> Self {
            Self {
                bind_ip: "127.0.0.1".into(),
                port: 1,
            }
        }
    }

    #[test]
    fn override_changes_only_what_it_names() {
        let base: toml::Value =
            toml::from_str("list = [1, 2]\n[server]\nbind_ip = \"127.0.0.1\"\nport = 54994\n")
                .unwrap();
        let over: toml::Value =
            toml::from_str("list = [3]\n[server]\nbind_ip = \"0.0.0.0\"\n").unwrap();
        let s: S = merge(base, over).try_into().unwrap();
        assert_eq!(s.server.bind_ip, "0.0.0.0");
        assert_eq!(s.server.port, 54994);
        assert_eq!(s.list, vec![3]);
    }

    #[test]
    fn files_layer_and_missing_ones_are_skipped() {
        let dir = crate::test_tmp::dir().join(format!("xivl-settings-{}", std::process::id()));
        std::fs::create_dir_all(dir.join("default")).unwrap();
        std::fs::write(dir.join("default/t.toml"), "[server]\nport = 54994\n").unwrap();
        let over = dir.join("mine.toml");
        std::fs::write(&over, "[server]\nbind_ip = \"0.0.0.0\"\n").unwrap();
        // SAFETY: tests touching XIVLEGACY_SETTINGS run in this one test
        unsafe { std::env::set_var("XIVLEGACY_SETTINGS", &dir) };
        let s: S = load("t", Some(&over)).unwrap();
        assert_eq!(
            (s.server.bind_ip.as_str(), s.server.port),
            ("0.0.0.0", 54994)
        );
        let only_defaults: S = load("t", None).unwrap();
        assert_eq!(only_defaults.server.bind_ip, "127.0.0.1");
        let none: S = load("absent", None).unwrap();
        assert_eq!(none.server.port, 1);
        unsafe { std::env::remove_var("XIVLEGACY_SETTINGS") };
        std::fs::remove_dir_all(&dir).unwrap();
    }
}
