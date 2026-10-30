-- Toll of the Warden (Man300, the shared level 30 story): the Ashcrown
-- Consortium, its cast, the quest's triggers and the summoning at the mesa.
--
-- The Consortium is Gridania's counterpart of the Waking Sands: zone 161
-- (Peasants Ward) was a stub with no map name. The client's region table
-- (data/03/C0/00/00.DAT) puts Gridania's private layouts, prv_f0, in region
-- 204 (with the Market Wards), and the Consortium layout prv_f0_mlt01 names
-- its map fst0Event01 (data/72/9F/00/00.DAT).
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "server_zones" SET
    "regionId" = 204,
    "zoneName" = 'fst0Event01',
    "classPath" = '/Area/Zone/ZoneMasterFstF0'
WHERE "id" = 161 AND ("zoneName" IS NULL OR "zoneName" = '');

-- The quest follows Together We Stand (offered by Minfilia at level 30).
UPDATE "gamedata_quests" SET "prerequisite" = 110014 WHERE "id" = 110015 AND "prerequisite" = 0;

-- Nananoby, the Consortium's party leader at the mesa, had no class path.
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
WHERE "id" = 1001050 AND ("classPath" = '' OR "classPath" IS NULL);

-- Two walk-in triggers, borrowing stripped classes (classPath '', no spawn,
-- no other reference) as seed 119 did: Camp Drybone, where your companion
-- reports the excavation site (1090294), and the Consortium's front door
-- out to Gridania (1090295). Both push circles stay off until the quest
-- turns them on.
UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "propertyFlags" = 1,
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "5.0",
      "outwards": "false",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090294 AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "propertyFlags" = 1,
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "2.5",
      "outwards": "false",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090295 AND ("classPath" = '' OR "classPath" IS NULL);

-- The cast. The Consortium's rooms come from the cutscenes staged there
-- (man30010/20/60 put the front door near x -39 and the Interlocutors'
-- room near x 33, on the floor at y 0 to 1.5); the cave is where man30040
-- stages Nananoby, a mesa west of Camp Drybone whose mouth opens east
-- (heights read in the test client).
INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27667, 1001047, 'man300_hedyn',          161, '', 0,  -31.00, 0.00,  -3.00, -1.57, 0, 0, null),
    (27668, 1001048, 'man300_shanga_meshanga', 161, '', 0,   33.00, 1.50,  -3.00, -1.57, 0, 0, null),
    (27669, 1001049, 'man300_troxia',         161, '', 0,   33.50, 1.50,   1.00, -1.57, 0, 0, null),
    (27670, 1090295, 'man300_consortium_exit', 161, '', 0,  -42.00, 0.00,  -2.00,  0.00, 0, 0, null),
    (27671, 1090294, 'man300_drybone_trigger', 171, '', 0, 1251.00, 264.00, -540.00, 0.00, 0, 0, null),
    (27672, 1001050, 'man300_nananoby',       171, '', 0, 1016.00, 251.10, -271.00, 1.57, 0, 0, null);

-- The summoning in the cave (SimpleContentMan30001): Amalj'aa drubbers
-- (the zone's own pool 10061) and Ixali swordfighters (a new pool on the
-- Ixal genus), around the quest's level 30, deeper in than Nananoby.
INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (20, 2106426, 'mesa_ixal', 24, 0, 1, 4200, 1, 1, 0, 0, 0, 0);

INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (21, 10061, 'mesa_amaljaa', 29, 30, 0, 500, 0, 0, 0, 1, 0, 0, '', 0, 171),
    (22, 20,    'mesa_ixal',    29, 30, 0, 450, 0, 0, 0, 1, 0, 0, '', 0, 171);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (57, 'mesa_amaljaa', 21,  996.0, 250.5, -262.0, 1.57),
    (58, 'mesa_amaljaa', 21,  992.0, 250.5, -272.0, 1.57),
    (59, 'mesa_ixal',    22,  978.0, 250.3, -298.0, 0.80),
    (60, 'mesa_ixal',    22,  970.0, 250.2, -306.0, 0.80);

-- Gridania's market entrance (1090264) carried unquoted JSON keys and a push
-- box the server can't parse, so it never spawned as a live NPC and nothing
-- could walk into it (the Consortium's way in, and the market wards'). It
-- gets the 3-yalm push circle Ul'dah's entrance (1090265) uses; Limsa's
-- (1090238) had the same defect and gets the same fix.
UPDATE "gamedata_actor_class" SET
    "eventConditions" = '{
  "noticeEventConditions": [
    {
      "unknown1": 1,
      "unknown2": 0,
      "conditionName": "noticeEvent"
    }
  ],
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "true",
      "radius": "3.0",
      "outwards": "false",
      "silent": "false",
      "conditionName": "in"
    }
  ]
}'
WHERE "id" IN (1090264, 1090238) AND "eventConditions" LIKE '%pushWithBoxEventConditions: [%';
