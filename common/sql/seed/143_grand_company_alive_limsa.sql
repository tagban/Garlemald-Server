-- Alive (Gcl102), the Maelstrom's search for Cid Garlond's grounded airship
-- (scripts/lua/quests/gcl/gcl102.lua), all in upper La Noscea (zone 135):
--
-- * At Camp Iron Lake, High Storm Commander R'ashaht Rhiki, Storm
--   Lieutenant Hidden Sunset and Storm Captain Roehmannsyn (standing in for
--   Myrganmoen, R'ashaht's veteran, who has no class in the client).
-- * The mouth of the northern pass into Oakwood, walked into to start the
--   duty, and the imperial operatives on the pass.
-- * Cid and his colleagues at the crash site. Its place comes from cut scene
--   gc01l210 (Gaius van Baelsar's arrival), whose cast stands around
--   (-796..-833, 40-48, -2387..-2408).
--
-- Heights checked in the test client. R'ashaht, Hidden Sunset, Roehmannsyn,
-- Jijina, E'bolaff and Saelbmoht ship stripped in gamedata (classPath '') and
-- get PopulaceStandard. Gcl102 follows It Kills with Fire (Gcl101).
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "gamedata_quests" SET "prerequisite" = 111416
WHERE "id" = 111427 AND "prerequisite" = 0;

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "propertyFlags" = 19,
    "eventConditions" = '{
  "talkEventConditions": [
    {
      "unknown1": 4,
      "unknown2": 0,
      "conditionName": "talkDefault"
    }
  ],
  "noticeEventConditions": [
    {
      "unknown1": 0,
      "unknown2": 1,
      "conditionName": "noticeEvent"
    }
  ]
}'
WHERE "id" IN (1001810, 1001813, 1001814, 1001731, 1001732, 1001733)
  AND ("classPath" = '' OR "classPath" IS NULL);

-- The mouth of the northern pass.
UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "8.0",
      "outwards": "false",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090333 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27772, 1001810, 'gcl102_rashaht',          135, '', 0,  -272.00,  77.65, -2254.50, -2.36, 0, 0, null),
    (27773, 1001813, 'gcl102_myrganmoen',       135, '', 0,  -268.00,  77.70, -2260.50, -1.57, 0, 0, null),
    (27774, 1001814, 'gcl102_hidden_sunset',    135, '', 0,  -284.00,  77.35, -2252.30,  2.36, 0, 0, null),
    (27775, 1090333, 'gcl102_northern_pass',    135, '', 0,  -577.00,  51.30, -2399.50,  0.00, 0, 0, null),
    (27776, 1001572, 'gcl102_cid',              135, '', 0,  -806.00,  47.40, -2403.50,  1.57, 0, 0, null),
    (27777, 1060011, 'gcl102_ebrelnaux',        135, '', 0,  -797.00,  47.65, -2402.50, -1.57, 0, 0, null),
    (27778, 1001733, 'gcl102_jijina',           135, '', 0,  -812.00,  47.70, -2408.30,  0.00, 0, 0, null),
    (27779, 1001731, 'gcl102_ebolaff',          135, '', 0,  -803.00,  48.40, -2408.50,  0.00, 0, 0, null),
    (27780, 1001732, 'gcl102_saelbmoht',        135, '', 0,  -821.00,  47.30, -2406.50,  1.57, 0, 0, null),
    (27781, 1001736, 'gcl102_sorezari',         135, '', 0,  -815.00,  46.30, -2403.30,  1.57, 0, 0, null);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (30103, 2280001, 'Imperial Secutor',     29, 0, 1, 4200, 1.0, 1, 0, 0, 0, 0),
    (30104, 2280003, 'Imperial Hoplomachus', 29, 0, 1, 4200, 1.0, 1, 0, 0, 0, 0),
    (30105, 2280006, 'Imperial Sagittarius', 29, 0, 1, 4200, 1.0, 1, 0, 0, 0, 0);

-- spawnType 1 keeps them out of the open world: the duty spawns them.
INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (30103, 30103, 'gcl102_secutor',     40, 40, 0, 1400, 0, 0, 0, 1, 0, 0, '', 0, 135),
    (30104, 30104, 'gcl102_hoplomachus', 40, 40, 0, 1400, 0, 0, 0, 1, 0, 0, '', 0, 135),
    (30105, 30105, 'gcl102_sagittarius', 40, 40, 0, 1200, 0, 0, 0, 1, 0, 0, '', 0, 135);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (3507, 'gcl102_secutor',     30103, -600.0, 48.9, -2396.5, 1.57),
    (3508, 'gcl102_hoplomachus', 30104, -591.6, 49.8, -2401.7, 1.57),
    (3509, 'gcl102_secutor',     30103, -610.0, 47.8, -2402.5, 1.57),
    (3510, 'gcl102_sagittarius', 30105, -620.0, 46.6, -2396.5, 1.57);
