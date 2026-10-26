// garlemald-server — Rust port of a FINAL FANTASY XIV v1.23b server emulator (lobby/world/map)
// Copyright (C) 2026  Samuel Stegall
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! SQLite access for the web server: account creation, credential lookup,
//! and session-row insertion. Shares the same on-disk file as every other
//! Garlemald binary (see `common::db::open_or_create`).

use std::path::Path;

use anyhow::{Context, Result};
use common::db::ConnCallExt;
use rusqlite::{OptionalExtension, named_params};
use tokio_rusqlite::Connection;

pub struct Database {
    conn: Connection,
}

pub struct StoredUser {
    pub id: i64,
    pub password_hash: String,
}

impl Database {
    pub async fn open(path: impl AsRef<Path>) -> Result<Self> {
        let conn = common::db::open_or_create(path).await?;
        Ok(Self { conn })
    }

    pub async fn ping(&self) -> Result<()> {
        self.conn
            .call_db(|c| {
                c.query_row("SELECT 1", [], |_| Ok(()))?;
                Ok(())
            })
            .await
            .context("ping")
    }

    /// Insert a new account row. Returns the new user's `id`, or `None` if
    /// the username is already taken (SQLite `UNIQUE` violation). All other
    /// errors propagate.
    pub async fn create_user(&self, username: &str, password_hash: &str) -> Result<Option<i64>> {
        let username = username.to_owned();
        let password_hash = password_hash.to_owned();
        let id = self
            .conn
            .call_db(move |c| {
                let res = c.execute(
                    r"INSERT INTO users(username, passwordHash)
                      VALUES(:u, :p)",
                    named_params! {
                        ":u": username,
                        ":p": password_hash,
                    },
                );
                match res {
                    Ok(_) => Ok(Some(c.last_insert_rowid())),
                    Err(rusqlite::Error::SqliteFailure(err, _))
                        if err.code == rusqlite::ErrorCode::ConstraintViolation =>
                    {
                        Ok(None)
                    }
                    Err(e) => Err(e),
                }
            })
            .await?;
        Ok(id)
    }

    pub async fn find_user_by_username(&self, username: &str) -> Result<Option<StoredUser>> {
        let username = username.to_owned();
        let row = self
            .conn
            .call_db(move |c| {
                let v = c
                    .query_row(
                        "SELECT id, passwordHash FROM users WHERE username = :u COLLATE NOCASE",
                        named_params! { ":u": username },
                        |r| {
                            Ok(StoredUser {
                                id: r.get::<_, i64>(0)?,
                                password_hash: r.get::<_, String>(1)?,
                            })
                        },
                    )
                    .optional()?;
                Ok(v)
            })
            .await?;
        Ok(row)
    }

    /// Insert a session row with `expiration = now + hours`. The 56-char
    /// token must already be unique; callers use [`session::generate`] to
    /// produce one so collisions are vanishingly rare.
    pub async fn insert_session(&self, session_id: &str, user_id: i64, hours: u32) -> Result<()> {
        let session_id = session_id.to_owned();
        let offset = format!("+{hours} hours");
        self.conn
            .call_db(move |c| {
                c.execute(
                    r"INSERT INTO sessions(id, userId, expiration)
                      VALUES(:sid, :uid, datetime('now', :offset))",
                    named_params! {
                        ":sid": session_id,
                        ":uid": user_id,
                        ":offset": offset,
                    },
                )?;
                Ok(())
            })
            .await
            .context("insert session")
    }
}

/// A world_sessions row this old (seconds) without a refresh is a player a
/// crashed world server left behind (it refreshes every 30 s).
const SEEN_WITHIN_S: i64 = 90;

impl Database {
    /// The status module: players in the world, and the `limit` most recently
    /// active characters as (name, initialTown, lastActiveAt, online), the
    /// ones online first.
    pub async fn status(&self, limit: usize) -> Result<(u32, Vec<(String, i64, i64, bool)>)> {
        self.conn
            .call_db(move |c| {
                let since = chrono::Utc::now().timestamp() - SEEN_WITHIN_S;
                let online: u32 = c.query_row(
                    "SELECT COUNT(*) FROM world_sessions WHERE last_seen_at >= :since",
                    named_params! { ":since": since },
                    |r| r.get(0),
                )?;
                let mut st = c.prepare(
                    r"SELECT c.name, COALESCE(c.initialTown, 0), c.lastActiveAt,
                             ws.character_id IS NOT NULL AND ws.last_seen_at >= :since AS online
                      FROM characters c
                      LEFT JOIN world_sessions ws ON ws.character_id = c.id
                      WHERE c.state = 2 AND c.lastActiveAt IS NOT NULL
                      ORDER BY online DESC, c.lastActiveAt DESC
                      LIMIT :limit",
                )?;
                let rows = st
                    .query_map(
                        named_params! { ":since": since, ":limit": limit as i64 },
                        |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?, r.get(3)?)),
                    )?
                    .collect::<rusqlite::Result<Vec<_>>>()?;
                Ok((online, rows))
            })
            .await
            .context("status query")
    }
}
