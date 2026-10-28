-- One player bug report (modules/bugreport). The files (screenshot, logs) are
-- in <folder>/<id>/ on the server (settings/bugreport.toml).
CREATE TABLE IF NOT EXISTS module_bugreport_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    userId INTEGER NOT NULL,
    characterId INTEGER NOT NULL,
    characterName TEXT NOT NULL,
    world TEXT NOT NULL DEFAULT '',
    zoneId INTEGER NOT NULL,
    zoneName TEXT NOT NULL DEFAULT '',
    posX REAL NOT NULL DEFAULT 0,
    posY REAL NOT NULL DEFAULT 0,
    posZ REAL NOT NULL DEFAULT 0,
    rotation REAL NOT NULL DEFAULT 0,
    message TEXT NOT NULL DEFAULT '',
    -- the attached file names, comma separated
    files TEXT NOT NULL DEFAULT '',
    createdAt INTEGER NOT NULL,
    -- publishing (web server): the GitHub issue's address once made, whether
    -- Discord has it, and when to try again after a failure
    githubIssue TEXT,
    discordSent INTEGER NOT NULL DEFAULT 0,
    attempts INTEGER NOT NULL DEFAULT 0,
    nextTryAt INTEGER NOT NULL DEFAULT 0,
    lastError TEXT,
    publishedAt INTEGER
);
CREATE INDEX IF NOT EXISTS module_bugreport_reports_user ON module_bugreport_reports(userId, createdAt);
CREATE INDEX IF NOT EXISTS module_bugreport_reports_pending ON module_bugreport_reports(publishedAt);
