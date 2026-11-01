-- It Kills with Fire (Gcl101, Gcg101, Gcu101), the Grand Companies' Ifrit
-- quest (scripts/lua/quests/gc/gc101.lua). Louisoix already stands at
-- Apkallus Falls, and four of the six beasts holding echo crystals and
-- Voidtongue Ahzabb Chah already spawn (seed 101). This adds:
--
-- * The other two beasts, by Camp Horizon in Western Thanalan (zone 172):
--   the nest commander to the north-west (map 11,25), among the aldgoats,
--   and Pyrausta to the west (map 8,30). Positions from Gamer Escape's map
--   coordinates; heights checked in the test client (Pyrausta fly).
-- * Voidtongue Ahzabb Chah at level 36 like the six beasts (seed 101 has him
--   at level 1), as an Amalj'aa.
-- * The Bowl of Embers (zone 240), which ships without a zone master: the
--   client dies entering it. It is a small two-lobed arena of its own, laid
--   out in Southern Thanalan's coordinates; the cast of Nael van Darnus's
--   cut scene there (GC010110) stands around (2480-2518, 248, 2190-2208),
--   which places the entry (dungeon.lua "embers") and Ifrit.
-- * Ifrit for that battle (battle npc 3500, class 2107301), spawned into each
--   copy by SimpleContentBowlOfEmbers. spawnType 1 keeps him out of the open
--   world.
--
-- Idempotent: UPDATEs guarded or plain value sets, INSERTs OR IGNORE on id. No
-- schema change.

UPDATE "server_zones" SET "classPath" = '/Area/Zone/ZoneMasterWilW0'
WHERE "id" = 240 AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "server_battlenpc_groups" SET "minLevel" = 36, "maxLevel" = 36, "hp" = 1077
WHERE "groupId" = 10446 AND "minLevel" = 1;
UPDATE "server_battlenpc_pools" SET "genusId" = 23
WHERE "poolId" = 10189 AND "actorClassId" = 2162061;

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (30100, 2107301, 'Ifrit',          54, 0, 1, 3600, 1.5, 1, 0, 0, 0, 0),
    (30101, 2103005, 'Nest Commander', 33, 0, 1, 4200, 1.0, 1, 0, 0, 0, 0),
    (30102, 2100114, 'Pyrausta',       45, 0, 1, 4200, 1.0, 0, 0, 0, 0, 0);

INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (30100, 30100, 'ifrit',          30, 30,  0, 8000, 0, 0, 0, 1, 0, 0, '', 0, 240),
    (30101, 30101, 'nest_commander', 36, 36, 90, 1077, 0, 0, 0, 0, 0, 0, '', 0, 172),
    (30102, 30102, 'pyrausta',       36, 36, 90, 1077, 0, 0, 0, 0, 0, 0, '', 0, 172);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (3500, 'ifrit',          30100,  2510.0, 247.4, 2204.0, 0.00),
    (3501, 'nest_commander', 30101, -1545.0, 36.5, -550.0, 0.00),
    (3502, 'nest_commander', 30101, -1530.0, 37.3, -540.0, 1.57),
    (3503, 'nest_commander', 30101, -1550.0, 36.6, -536.0, 3.14),
    (3504, 'pyrausta',       30102, -1890.0, 48.0,    6.0, 0.00),
    (3505, 'pyrausta',       30102, -1875.0, 48.0,   -5.0, 1.57),
    (3506, 'pyrausta',       30102, -1900.0, 48.0,   15.0, 3.14);
