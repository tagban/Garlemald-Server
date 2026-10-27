// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Scratch space for tests: use [`dir`] in place of `std::env::temp_dir()`.
//!
//! Every test process gets its own folder, `<temp>/xivlegacy-tests/<pid>`,
//! and the whole folder goes when the process exits, so the databases and
//! script folders tests make don't pile up in the system temp folder (they
//! once filled a disk). A run that crashed before it could clean up leaves
//! its folder behind; those are swept the next time tests run, once they're
//! a day old.

use std::path::PathBuf;
use std::sync::OnceLock;
use std::time::{Duration, SystemTime};

static DIR: OnceLock<PathBuf> = OnceLock::new();

/// A crashed run's folder older than this is swept by the next run.
const STALE_AFTER: Duration = Duration::from_secs(24 * 60 * 60);

unsafe extern "C" {
    fn atexit(cb: extern "C" fn()) -> std::ffi::c_int;
}

extern "C" fn remove_dir() {
    if let Some(dir) = DIR.get() {
        let _ = std::fs::remove_dir_all(dir);
    }
}

/// This test process's scratch folder (made on first use, removed at exit).
pub fn dir() -> PathBuf {
    DIR.get_or_init(|| {
        let root = std::env::temp_dir().join("xivlegacy-tests");
        sweep_stale(&root);
        let dir = root.join(std::process::id().to_string());
        let _ = std::fs::create_dir_all(&dir);
        // SAFETY: registers a plain function with the C runtime; it only
        // reads the OnceLock that is already set by the time it can run.
        unsafe {
            atexit(remove_dir);
        }
        dir
    })
    .clone()
}

fn sweep_stale(root: &std::path::Path) {
    let Ok(entries) = std::fs::read_dir(root) else {
        return;
    };
    let now = SystemTime::now();
    for e in entries.flatten() {
        let old = e
            .metadata()
            .and_then(|m| m.modified())
            .ok()
            .and_then(|t| now.duration_since(t).ok())
            .is_some_and(|age| age > STALE_AFTER);
        if old {
            let _ = std::fs::remove_dir_all(e.path());
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn one_folder_per_process_under_the_temp_folder() {
        let a = dir();
        assert_eq!(a, dir());
        assert!(a.is_dir());
        assert!(a.starts_with(std::env::temp_dir().join("xivlegacy-tests")));
        assert!(a.ends_with(std::process::id().to_string()));
    }

    #[test]
    fn stale_folders_are_swept_and_fresh_ones_kept() {
        let root = dir().join("sweep-test");
        let fresh = root.join("fresh");
        let old = root.join("old");
        std::fs::create_dir_all(&fresh).unwrap();
        std::fs::create_dir_all(&old).unwrap();
        let two_days_ago = SystemTime::now() - 2 * STALE_AFTER;
        std::fs::File::open(&old)
            .unwrap()
            .set_modified(two_days_ago)
            .unwrap();
        sweep_stale(&root);
        assert!(fresh.is_dir(), "a folder in use isn't touched");
        assert!(!old.exists(), "a crashed run's folder is swept");
        let _ = std::fs::remove_dir_all(&root);
    }
}
