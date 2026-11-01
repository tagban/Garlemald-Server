-- Deus ex Machina (Gcl103), the signing of the Galadion Accord
-- (scripts/lua/quests/gcl/gcl103.lua):
--
-- * In the Coral Tower (Limsa Lominsa, zone 230), Admiral Merlwyb with
--   Commodore Reyner, Storm Marshal Slafyrsyn and Hyllfyr, on the hall floor
--   before the stairs. Merlwyb is the same class as at Com0l5's clearing.
-- * Aleport (Western La Noscea, zone 129): the square the betrayal cut scene
--   (gc01l310) is set in, walked into to start the duty. The cut scene's
--   cast stands around (-1300..-1330, 0-5, -600..-640).
-- * The magitek vanguard H-I and its escort, spawned by the duty
--   (SimpleContentGcl10301). The escort shares seed 143's imperial pools.
--
-- Heights checked in the test client. Reyner, Slafyrsyn and Hyllfyr ship
-- stripped in gamedata (classPath '') and get PopulaceStandard. Gcl103
-- follows Alive (Gcl102).
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "gamedata_quests" SET "prerequisite" = 111427
WHERE "id" = 111429 AND "prerequisite" = 0;

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
WHERE "id" IN (1000140, 1060024, 1000215)
  AND ("classPath" = '' OR "classPath" IS NULL);

-- The Aleport square.
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
WHERE "id" = 1090335 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27799, 1001568, 'gcl103_merlwyb',          230, '', 0,  -617.50,  43.00,   -67.00,  1.57, 0, 0, null),
    (27800, 1000140, 'gcl103_reyner',           230, '', 0,  -616.00,  43.00,   -71.00,  0.79, 0, 0, null),
    (27801, 1060024, 'gcl103_slafyrsyn',        230, '', 0,  -616.00,  43.00,   -63.00,  2.36, 0, 0, null),
    (27802, 1000215, 'gcl103_hyllfyr',          230, '', 0,  -618.50,  43.00,   -70.50,  1.20, 0, 0, null),
    (27803, 1090335, 'gcl103_aleport',          129, '', 0, -1316.00,   2.50,  -620.00,  0.00, 0, 0, null);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (30106, 2109002, 'Magitek Vanguard H-I', 29, 0, 1, 4600, 1.2, 1, 0, 0, 0, 0);

-- spawnType 1 keeps them out of the open world: the duty spawns them.
INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (30112, 30106, 'gcl103_vanguard',    45, 45, 0, 4500, 0, 0, 0, 1, 0, 0, '', 0, 129),
    (30113, 30103, 'gcl103_secutor',     44, 44, 0, 1500, 0, 0, 0, 1, 0, 0, '', 0, 129),
    (30114, 30104, 'gcl103_hoplomachus', 44, 44, 0, 1500, 0, 0, 0, 1, 0, 0, '', 0, 129);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (3519, 'gcl103_vanguard',    30112, -1322.0, 3.8, -632.0, 0.79),
    (3520, 'gcl103_secutor',     30113, -1326.0, 3.1, -624.0, 1.57),
    (3521, 'gcl103_hoplomachus', 30114, -1318.0, 3.5, -630.0, 0.00);
