-- Careless Whispers (Gcu103), Teledji's juggernaut and the raid on the ferry
-- docks (scripts/lua/quests/gcu/gcu103.lua):
--
-- * Flame General Raubahn on the Royal Promenade (Ul'dah, zone 209), beside
--   the stair where Thancred waits in Com0u5.
-- * Grand Flame Marshal Roaille in the Hall of Flames (zone 233), on the hall
--   floor (the client names her talk "Eline").
-- * The battlefield west of Camp Horizon (Western Thanalan, zone 172),
--   walked into to start the duty. Its place comes from the cut scene
--   (gc01u320), whose cast lies around (-1900..-1930, 24, -300..-330).
-- * The wounded Flames left on the battlefield once the juggernaut falls
--   (the client's "FUMETSU" talks), always standing there: the fallen
--   sergeant's word sends you on.
-- * The open ground at the ferry docks (-2205, 14, -425), walked into for
--   Raubahn's closing cut scene (gc01u310).
-- * The imperial juggernaut, spawned by the duty (SimpleContentGcu10301).
--
-- Heights checked in the test client. The cast ships stripped in gamedata
-- (classPath '') and gets PopulaceStandard. Gcu103 follows Like Father, Like
-- Son (Gcu102).
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "gamedata_quests" SET "prerequisite" = 111827
WHERE "id" = 111829 AND "prerequisite" = 0;

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
WHERE "id" IN (1060008, 1060026, 1002027, 1002028, 1002029, 1002030, 1002031)
  AND ("classPath" = '' OR "classPath" IS NULL);

-- The battlefield and the ferry docks.
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
WHERE "id" IN (1090337, 1090338) AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27808, 1060008, 'gcu103_raubahn',          209, '', 0,  -102.00, 224.70,   205.20,  3.14, 0, 0, null),
    (27809, 1060026, 'gcu103_roaille',          233, '', 0,   157.00,   0.00,  -178.00,  1.57, 0, 0, null),
    (27810, 1090337, 'gcu103_battlefield',      172, '', 0, -1920.00,  24.00,  -320.00,  0.00, 0, 0, null),
    (27811, 1090338, 'gcu103_ferry_docks',      172, '', 0, -2205.00,  14.00,  -425.00,  0.00, 0, 0, null),
    (27812, 1002027, 'gcu103_lieutenant',       172, '', 0, -1906.00,  24.00,  -318.00, -1.57, 0, 0, null),
    (27813, 1002028, 'gcu103_sergeant',         172, '', 0, -1908.00,  24.00,  -308.00,  3.14, 0, 0, null),
    (27814, 1002029, 'gcu103_injured',          172, '', 0, -1916.00,  24.00,  -308.00,  3.14, 0, 0, null),
    (27815, 1002030, 'gcu103_sergeant2',        172, '', 0, -1904.00,  24.00,  -312.00, -1.57, 0, 0, null),
    (27816, 1002031, 'gcu103_fallen',           172, '', 0, -1918.00,  24.00,  -314.00,  1.57, 0, 0, null);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (30108, 2202401, 'Imperial Juggernaut', 29, 0, 1, 4600, 1.2, 1, 0, 0, 0, 0);

-- spawnType 1 keeps it out of the open world: the duty spawns it.
INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (30116, 30108, 'gcu103_juggernaut', 45, 45, 0, 6000, 0, 0, 0, 1, 0, 0, '', 0, 172);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (3523, 'gcu103_juggernaut', 30116, -1926.0, 24.0, -326.0, 0.79);
