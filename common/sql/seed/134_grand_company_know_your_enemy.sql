-- Know Your Enemy (Com0u6), the Immortal Flames' sixth recruit mission:
-- Cid and the Garlond Ironworks' engineers at the airship landing, the
-- ferry docks of Vesper Bay, and Charledore the Steadfast.
--
-- The landing is the Wellhead Lift's top floor in the upper city (zone 209);
-- the cast stands on the open floor before the counters, where
-- H'cidjaa, Goodife and Guillestet already stand. The docks are where the
-- client stages com0u510 (Charledore's last words), the docks Burning Man
-- (seed 131) and Ceruleum Shock (seed 132) use. Ground at both places
-- checked in the test client.
--
-- Rycharde, Autgar and Ahldbyrt (the engineers) ship stripped in gamedata
-- (classPath ''); they get PopulaceStandard. Charledore's battle class ships
-- stripped too; it gets the pirates' class (PirateStandard), the human
-- enemies' class.
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
WHERE "id" IN (1001718, 1001714, 1001715)
  AND ("classPath" = '' OR "classPath" IS NULL);

-- The docks, walked onto to find Charledore.
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
WHERE "id" = 1090332 AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Monster/Pirate/PirateStandard'
WHERE "id" = 2289025 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27761, 1090332, 'com0u6_ferry_docks',        172, '', 0, -1620.00,  59.50,   248.00,  0.00, 0, 0, null),
    (27762, 1001572, 'com0u6_cid',                209, '', 0,  -109.50, 271.00,   168.00,  3.14, 0, 0, null),
    (27763, 1001718, 'com0u6_rycharde',           209, '', 0,  -107.50, 271.00,   164.00, -2.62, 0, 0, null),
    (27764, 1001714, 'com0u6_autgar',             209, '', 0,  -111.50, 271.00,   162.50,  1.21, 0, 0, null),
    (27765, 1001715, 'com0u6_ahldbyrt',           209, '', 0,  -112.50, 271.00,   166.50,  1.11, 0, 0, null);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (30, 2289025, 'charledore', 3, 0, 1, 4200, 1, 1, 0, 0, 0, 0);

INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (35, 30, 'charledore', 27, 27, 0, 1500, 0, 0, 0, 1, 0, 0, '', 0, 172);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (86, 'charledore', 35, -1617.4, 59.05, 247.0, 0.00);
