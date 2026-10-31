-- An Officer and a Wise Man (Com0l5), the Maelstrom's fifth recruit mission:
-- the clearing southwest of Camp Bloodshore with Merlwyb and Urianger, the
-- brigands who tracked her there, and the gathering after the inauguration.
--
-- Merlwyb, Urianger, two corsairs and a Barracuda Knight ship stripped in
-- gamedata (classPath ''); they get PopulaceStandard. The clearing is a
-- hilltop in Eastern La Noscea (zone 130) west of the camp, ground checked in
-- the test client (y 70). The brigands are Mistbeard buccaneers.
--
-- The ceremony plays on the Bridge, a private layout (prv_s0_hal01, map
-- sea0Event01) the server has no zone for. Its cutscene ends on a warp, so the
-- gathering after it, Thancred and the crowd, stands in Maelstrom Command.
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

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
WHERE "id" IN (1001568, 1500204, 1000706, 1000707, 1000095) AND ("classPath" = '' OR "classPath" IS NULL);

-- The clearing, walked into to meet the brigands.
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
WHERE "id" = 1090327 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27711, 1090327, 'com0l5_clearing',         130, '', 0, 1040.00, 70.00, -850.00,  0.00, 0, 0, null),
    (27712, 1001568, 'com0l5_merlwyb',          130, '', 0, 1030.00, 70.00, -852.00,  1.57, 0, 0, null),
    (27713, 1500204, 'com0l5_urianger',         130, '', 0, 1030.00, 70.00, -846.00,  1.57, 0, 0, null),
    (27714, 1000185, 'com0l5_thancred',         232, '', 0,  156.00,  0.00, -184.00,  1.57, 0, 0, null),
    (27715, 1000706, 'com0l5_corsair_free',     232, '', 0,  159.00,  0.00, -189.00,  1.57, 0, 0, null),
    (27716, 1000707, 'com0l5_corsair_saltwife', 232, '', 0,  162.00,  0.00, -189.00,  1.57, 0, 0, null),
    (27717, 1000095, 'com0l5_barracuda_knight', 232, '', 0,  153.00,  0.00, -177.00,  1.57, 0, 0, null);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (25, 2180202, 'brigand', 3, 0, 1, 4200, 1, 1, 0, 0, 0, 0);

INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (30, 25, 'brigand', 25, 26, 0, 650, 0, 0, 0, 1, 0, 0, '', 0, 130);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (74, 'brigand', 30, 1047.0, 70.0, -846.0, 0.00),
    (75, 'brigand', 30, 1049.0, 70.0, -852.0, 0.00),
    (76, 'brigand', 30, 1046.0, 70.0, -856.0, 0.00);
