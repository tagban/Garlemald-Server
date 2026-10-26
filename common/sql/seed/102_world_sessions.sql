-- XIVLegacy Server: who is in the game, written only by the world server
-- (docs/DESIGN.md, Sessions). One row per account: a second sign-in replaces
-- the first. The world server clears the table when it starts, and refreshes
-- last_seen_at every 30 s for every connected player, so a row not seen for
-- 90 s is a player a crashed world server left behind.
CREATE TABLE IF NOT EXISTS world_sessions (
    account_id    INTEGER NOT NULL PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    character_id  INTEGER NOT NULL UNIQUE REFERENCES characters(id) ON DELETE CASCADE,
    world_id      INTEGER NOT NULL,
    zone_id       INTEGER NOT NULL,
    map_server    TEXT    NOT NULL,                -- the map process running the zone (host:port)
    client_ip     TEXT    NOT NULL,
    conn_seq      INTEGER NOT NULL,                -- the world server's connection, so a stale
                                                   -- disconnect can't end a newer session
    started_at    INTEGER NOT NULL,                -- unix seconds
    last_seen_at  INTEGER NOT NULL,
    state         TEXT    NOT NULL CHECK (state IN ('connecting', 'in_world', 'zoning', 'linkdead'))
);

-- When the character last entered the world or left it (unix seconds): online
-- counts and "recently active" lists without game state.
ALTER TABLE characters ADD COLUMN lastActiveAt INTEGER DEFAULT NULL;
