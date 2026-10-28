// XIVLegacy Server — FINAL FANTASY XIV v1.23b server (lobby/world/map)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//! The web server's half of player bug reports (modules/bugreport):
//!
//! - `POST /bug/attach/<file>`: the client's bug-report key sends its
//!   screenshot and logs here, signed in with the game session id
//!   (`Authorization: Bearer <session id>`). They wait for the player's
//!   `!bug`, which the map server files (map-server/src/bug_report.rs).
//! - A background task publishes each filed report: an issue in a private
//!   GitHub repository with its files committed beside it, and a message
//!   with the screenshot to a Discord channel (settings/bugreport.toml).

use std::path::Path;
use std::sync::Arc;
use std::time::Duration;

use anyhow::{Context, Result, bail};
use axum::body::Bytes;
use axum::extract::{Path as UrlPath, State};
use axum::http::{HeaderMap, StatusCode, header};
use base64::Engine;
use common::bug_reports::{Settings, file_kind};

use crate::database::{BugReport, Database};
use crate::handlers::AppState;

/// How often the publisher looks for new reports.
const POLL: Duration = Duration::from_secs(10);
/// Tries before a report is left alone (its files stay on the server).
const MAX_ATTEMPTS: i64 = 8;

/// `POST /bug/attach/<file>`.
pub async fn attach(
    State(state): State<AppState>,
    UrlPath(name): UrlPath<String>,
    headers: HeaderMap,
    body: Bytes,
) -> (StatusCode, &'static str) {
    let Some(is_log) = file_kind(&name) else {
        return (StatusCode::NOT_FOUND, "unknown file");
    };
    let Some(sid) = headers
        .get(header::AUTHORIZATION)
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.strip_prefix("Bearer "))
        .map(str::trim)
        .filter(|s| s.len() == 56 && s.bytes().all(|b| b.is_ascii_alphanumeric()))
    else {
        return (StatusCode::UNAUTHORIZED, "sign in first");
    };
    let user_id = match state.db.user_of_session(sid).await {
        Ok(Some(u)) => u,
        Ok(None) => return (StatusCode::UNAUTHORIZED, "session expired"),
        Err(e) => {
            tracing::error!(error = %e, "bug attach: session lookup");
            return (StatusCode::SERVICE_UNAVAILABLE, "try again later");
        }
    };
    let s = &state.bug_reports;
    let data = if is_log {
        let keep = s.max_log_kb * 1024;
        let text = String::from_utf8_lossy(&body);
        let mut cut = text.len().saturating_sub(keep);
        while !text.is_char_boundary(cut) {
            cut += 1;
        }
        // from the start of a line, when the log was cut
        let tail = match (cut > 0, text[cut..].find('\n')) {
            (true, Some(nl)) => &text[cut + nl + 1..],
            _ => &text[cut..],
        };
        common::bug_reports::scrub(tail, &[sid]).into_bytes()
    } else {
        if body.len() > s.max_screenshot_kb * 1024 {
            return (StatusCode::PAYLOAD_TOO_LARGE, "screenshot too large");
        }
        if !body.starts_with(b"\x89PNG\r\n\x1a\n") {
            return (StatusCode::UNSUPPORTED_MEDIA_TYPE, "PNG only");
        }
        body.to_vec()
    };
    let dir = s.pending_dir(user_id);
    let saved = tokio::task::spawn_blocking(move || -> std::io::Result<()> {
        std::fs::create_dir_all(&dir)?;
        let tmp = dir.join(format!(".{name}.part"));
        std::fs::write(&tmp, &data)?;
        std::fs::rename(&tmp, dir.join(&name))
    })
    .await;
    match saved {
        Ok(Ok(())) => {
            tracing::info!(user = user_id, "bug report file received");
            (StatusCode::OK, "ok")
        }
        e => {
            tracing::error!(error = ?e, "bug attach: saving");
            (StatusCode::INTERNAL_SERVER_ERROR, "couldn't save it")
        }
    }
}

/// Publish filed reports until the server stops.
pub async fn publisher(db: Arc<Database>, s: Arc<Settings>) {
    if !s.github_on() && !s.discord_on() {
        tracing::warn!(
            folder = %s.folder.display(),
            "bug reports: neither GitHub nor Discord is set up in settings/bugreport.toml; reports stay in the folder"
        );
        return;
    }
    tracing::info!(
        github = s.github_on(),
        discord = s.discord_on(),
        "bug report publisher running"
    );
    loop {
        let now = chrono::Utc::now().timestamp();
        match db.bug_reports_to_publish(now, MAX_ATTEMPTS).await {
            Ok(rows) => {
                for r in rows {
                    let id = r.id;
                    let s2 = s.clone();
                    let res = tokio::task::spawn_blocking(move || publish(&s2, r))
                        .await
                        .unwrap_or_else(|e| Outcome::failed(format!("{e}")));
                    if let Some(e) = &res.error {
                        tracing::warn!(report = id, error = %e, "bug report not published yet");
                    } else {
                        tracing::info!(report = id, issue = ?res.issue, "bug report published");
                    }
                    if let Err(e) = db.bug_report_published(id, &res, now).await {
                        tracing::error!(report = id, error = %e, "bug report state not saved");
                    }
                }
            }
            Err(e) => tracing::error!(error = %e, "bug reports: query"),
        }
        tokio::time::sleep(POLL).await;
    }
}

/// What a publishing attempt got done.
#[derive(Debug, Default)]
pub struct Outcome {
    pub issue: Option<String>,
    pub discord_sent: bool,
    pub error: Option<String>,
}

impl Outcome {
    fn failed(e: String) -> Self {
        Self {
            error: Some(e),
            ..Self::default()
        }
    }
}

fn agent() -> ureq::Agent {
    ureq::AgentBuilder::new()
        .timeout(Duration::from_secs(60))
        .user_agent("xivlegacy-server bug reports")
        .build()
}

/// Publish `r` to what's set up and not done yet.
fn publish(s: &Settings, r: BugReport) -> Outcome {
    let dir = s.report_dir(r.id);
    let mut out = Outcome {
        issue: r.github_issue.clone(),
        discord_sent: r.discord_sent,
        error: None,
    };
    let mut errors = Vec::new();
    if s.github_on() && out.issue.is_none() {
        match github(s, &r, &dir) {
            Ok(url) => out.issue = Some(url),
            Err(e) => errors.push(format!("GitHub: {e:#}")),
        }
    }
    // Discord after GitHub, so its message can link the issue
    if s.discord_on() && !out.discord_sent && (out.issue.is_some() || !s.github_on()) {
        match discord(s, &r, &dir, out.issue.as_deref()) {
            Ok(()) => out.discord_sent = true,
            Err(e) => errors.push(format!("Discord: {e:#}")),
        }
    }
    if !errors.is_empty() {
        out.error = Some(errors.join("; "));
    }
    out
}

fn files(r: &BugReport) -> Vec<&str> {
    r.files
        .split(',')
        .filter(|f| file_kind(f).is_some())
        .collect()
}

fn utc(unix: i64) -> String {
    chrono::DateTime::from_timestamp(unix, 0)
        .map(|t| t.format("%Y-%m-%d %H:%M UTC").to_string())
        .unwrap_or_default()
}

fn title(r: &BugReport) -> String {
    let first = r.message.lines().next().unwrap_or("");
    let mut t: String = first.chars().take(80).collect();
    if t.len() < first.len() {
        t.push('…');
    }
    let place = if r.zone_name.is_empty() {
        format!("zone {}", r.zone_id)
    } else {
        r.zone_name.clone()
    };
    format!("Bug report #{}: {t} ({place})", r.id)
}

/// The facts of a report, one (label, value) each.
fn facts(r: &BugReport) -> Vec<(&'static str, String)> {
    vec![
        (
            "Character",
            format!(
                "{} ({})",
                r.character_name,
                if r.world.is_empty() { "?" } else { &r.world }
            ),
        ),
        (
            "Zone",
            format!("{} {}", r.zone_id, r.zone_name).trim().to_string(),
        ),
        (
            "Position",
            format!("{:.2} {:.2} {:.2}, facing {:.2}", r.x, r.y, r.z, r.rotation),
        ),
        (
            "Go there",
            format!("!warp {} {:.2} {:.2} {:.2}", r.zone_id, r.x, r.y, r.z),
        ),
        ("Filed", utc(r.created_at)),
    ]
}

/// The issue's text. `files` are the committed files' addresses by name.
fn issue_body(r: &BugReport, links: &[(String, String)]) -> String {
    let mut b = String::new();
    for l in r.message.lines() {
        b += &format!("> {}\n", l.replace('<', "&lt;"));
    }
    b += "\n| | |\n|---|---|\n";
    for (k, v) in facts(r) {
        let v = if k == "Go there" {
            format!("`{v}`")
        } else {
            v.replace('|', "\\|")
        };
        b += &format!("| {k} | {v} |\n");
    }
    if let Some((_, url)) = links.iter().find(|(n, _)| n == "screenshot.png") {
        b += &format!("\n![screenshot]({url}?raw=true)\n");
    }
    let logs: Vec<_> = links
        .iter()
        .filter(|(n, _)| n != "screenshot.png")
        .collect();
    if !logs.is_empty() {
        b += "\nFiles: ";
        b += &logs
            .iter()
            .map(|(n, u)| format!("[{n}]({u})"))
            .collect::<Vec<_>>()
            .join(" · ");
        b += "\n";
    }
    b += &format!(
        "\n<sub>Filed in game with !bug · report {} · account {}</sub>\n",
        r.id, r.user_id
    );
    b
}

fn github(s: &Settings, r: &BugReport, dir: &Path) -> Result<String> {
    let g = &s.github;
    let api = g.api.trim_end_matches('/');
    let auth = format!("Bearer {}", g.token);
    let a = agent();
    let mut links = Vec::new();
    for name in files(r) {
        let data = std::fs::read(dir.join(name)).with_context(|| format!("reading {name}"))?;
        let path = format!("reports/{}/{name}", r.id);
        let res = a
            .put(&format!("{api}/repos/{}/contents/{path}", g.repo))
            .set("Authorization", &auth)
            .set("Accept", "application/vnd.github+json")
            .send_json(serde_json::json!({
                "message": format!("Bug report #{}: {name}", r.id),
                "content": base64::engine::general_purpose::STANDARD.encode(&data),
                "branch": g.branch,
            }));
        match res {
            Ok(_) => {}
            // already there from an earlier try that stopped half way
            Err(ureq::Error::Status(422, _)) => {}
            Err(ureq::Error::Status(code, resp)) => {
                bail!(
                    "uploading {name}: {code} {}",
                    resp.into_string().unwrap_or_default()
                )
            }
            Err(e) => bail!("uploading {name}: {e}"),
        }
        links.push((
            name.to_string(),
            format!("https://github.com/{}/blob/{}/{path}", g.repo, g.branch),
        ));
    }
    let res = a
        .post(&format!("{api}/repos/{}/issues", g.repo))
        .set("Authorization", &auth)
        .set("Accept", "application/vnd.github+json")
        .send_json(serde_json::json!({
            "title": title(r),
            "body": issue_body(r, &links),
            "labels": g.labels,
        }));
    let v: serde_json::Value = match res {
        Ok(resp) => resp.into_json()?,
        Err(ureq::Error::Status(code, resp)) => {
            bail!(
                "making the issue: {code} {}",
                resp.into_string().unwrap_or_default()
            )
        }
        Err(e) => bail!("making the issue: {e}"),
    };
    v["html_url"]
        .as_str()
        .map(str::to_string)
        .context("the issue's address")
}

fn discord(s: &Settings, r: &BugReport, dir: &Path, issue: Option<&str>) -> Result<()> {
    let shot = files(r)
        .contains(&"screenshot.png")
        .then(|| std::fs::read(dir.join("screenshot.png")))
        .transpose()?;
    let mut desc: String = r.message.chars().take(3500).collect();
    if let Some(u) = issue {
        desc += &format!("\n\n[GitHub issue]({u})");
    }
    let mut embed = serde_json::json!({
        "title": format!("Bug report #{}", r.id),
        "description": desc,
        "fields": facts(r).into_iter().map(|(k, v)| serde_json::json!({
            "name": k,
            "value": if k == "Go there" { format!("`{v}`") } else { v },
            "inline": k != "Go there",
        })).collect::<Vec<_>>(),
        "color": 0xC0392B,
    });
    if let Some(u) = issue {
        embed["url"] = u.into();
    }
    if shot.is_some() {
        embed["image"] = serde_json::json!({ "url": "attachment://screenshot.png" });
    }
    // nothing a player writes may ping anyone
    let payload = serde_json::json!({ "embeds": [embed], "allowed_mentions": { "parse": [] } });
    let boundary = format!("xivlegacy{:016x}", rand::random::<u64>());
    let mut body = Vec::new();
    body.extend(
        format!(
            "--{boundary}\r\nContent-Disposition: form-data; name=\"payload_json\"\r\nContent-Type: application/json\r\n\r\n{payload}\r\n"
        )
        .bytes(),
    );
    if let Some(png) = &shot {
        body.extend(
            format!(
                "--{boundary}\r\nContent-Disposition: form-data; name=\"files[0]\"; filename=\"screenshot.png\"\r\nContent-Type: image/png\r\n\r\n"
            )
            .bytes(),
        );
        body.extend(png);
        body.extend(b"\r\n");
    }
    body.extend(format!("--{boundary}--\r\n").bytes());
    let res = agent()
        .post(&s.discord.webhook)
        .set(
            "Content-Type",
            &format!("multipart/form-data; boundary={boundary}"),
        )
        .send_bytes(&body);
    match res {
        Ok(_) => Ok(()),
        Err(ureq::Error::Status(code, resp)) => {
            bail!("{code} {}", resp.into_string().unwrap_or_default())
        }
        Err(e) => bail!("{e}"),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn report() -> BugReport {
        BugReport {
            id: 4,
            user_id: 9,
            character_name: "Wyn Tagban".into(),
            world: "Fernehalwes".into(),
            zone_id: 230,
            zone_name: "Limsa Lominsa".into(),
            x: 1.0,
            y: 2.0,
            z: 3.0,
            message: "Fell through the dock <here>\nsecond line".into(),
            files: "screenshot.png,game.log".into(),
            created_at: 0,
            ..BugReport::default()
        }
    }

    #[test]
    fn the_issue_has_the_note_place_screenshot_and_logs() {
        let r = report();
        assert_eq!(
            title(&r),
            "Bug report #4: Fell through the dock <here> (Limsa Lominsa)"
        );
        let links = vec![
            ("screenshot.png".to_string(), "https://x/s.png".to_string()),
            ("game.log".to_string(), "https://x/g.log".to_string()),
        ];
        let b = issue_body(&r, &links);
        assert!(b.starts_with("> Fell through the dock &lt;here>\n> second line\n"));
        assert!(b.contains("| Zone | 230 Limsa Lominsa |"));
        assert!(b.contains("`!warp 230 1.00 2.00 3.00`"));
        assert!(b.contains("![screenshot](https://x/s.png?raw=true)"));
        assert!(b.contains("[game.log](https://x/g.log)"));
    }
}
