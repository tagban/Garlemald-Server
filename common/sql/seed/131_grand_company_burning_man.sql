-- Burning Man (Com0u5), the Immortal Flames' fifth recruit mission: the
-- pirates at the ferry docks of Vesper Bay, Thancred, Urianger and the
-- bystanders there, and the crowd on the Royal Promenade after General
-- Raubahn's address.
--
-- The docks are where the client stages its Vesper Bay scene (com0u510) in
-- Western Thanalan (zone 172). The address (com0u610) plays on the Royal
-- Promenade in the upper city (zone 209); its cutscene puts the crowd at
-- (-16, 36, 60) in the town scenes' own frame, which is the world less
-- (-88, 186, 142) (the Arrzaneth Ossuary and Quicksand scenes give the same
-- offset). Ground at both places checked in the test client.
--
-- The client names no classes for the bystanders: generic Ul'dahns that
-- match each line stand in. Those that ship stripped in gamedata
-- (classPath '') get PopulaceStandard. The pirates are Mistbeard buccaneers.
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
WHERE "id" IN (1001931, 1000985, 1000892, 1000582) AND ("classPath" = '' OR "classPath" IS NULL);

-- The docks, walked into to meet the pirates, and the Royal Promenade,
-- walked into to hear the address.
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
WHERE "id" IN (1090328, 1090329) AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27726, 1090328, 'com0u5_ferry_docks',            172, '', 0, -1620.00,  59.50,  248.00,  0.00, 0, 0, null),
    (27727, 1000185, 'com0u5_thancred_docks',         172, '', 0, -1614.00,  58.70,  248.50, -1.57, 0, 0, null),
    (27728, 1500204, 'com0u5_urianger_docks',         172, '', 0, -1614.10,  57.95,  244.50, -1.57, 0, 0, null),
    (27729, 1001931, 'com0u5_flame_captain',          172, '', 0, -1622.35,  58.35,  243.00,  1.57, 0, 0, null),
    (27730, 1000985, 'com0u5_bonny_lass',             172, '', 0, -1619.60,  60.15,  253.50,  1.57, 0, 0, null),
    (27731, 1000937, 'com0u5_greedy_merchant',        172, '', 0, -1618.00,  60.35,  254.50,  3.14, 0, 0, null),
    (27732, 1090329, 'com0u5_royal_promenade',        209, '', 0,  -104.00, 222.30,  199.00,  0.00, 0, 0, null),
    (27733, 1000185, 'com0u5_thancred_promenade',     209, '', 0,  -104.00, 223.30,  205.00,  3.14, 0, 0, null),
    (27734, 1000253, 'com0u5_tittering_traveler',     209, '', 0,  -108.50, 223.00,  202.00,  0.00, 0, 0, null),
    (27735, 1000892, 'com0u5_smirking_sellsword',     209, '', 0,  -102.50, 223.00,  201.50,  0.00, 0, 0, null),
    (27736, 1000582, 'com0u5_eager_gladiator',        209, '', 0,  -110.00, 222.50,  197.00,  0.50, 0, 0, null),
    (27737, 1000255, 'com0u5_enraptured_traveler',    209, '', 0,  -100.50, 222.30,  196.00, -0.50, 0, 0, null),
    (27738, 1000438, 'com0u5_well_traveled_merchant', 209, '', 0,  -106.00, 222.00,  193.00,  0.00, 0, 0, null);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (26, 2180202, 'pirate', 3, 0, 1, 4200, 1, 1, 0, 0, 0, 0);

INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (31, 26, 'pirate', 25, 26, 0, 650, 0, 0, 0, 1, 0, 0, '', 0, 172);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (77, 'pirate', 31, -1611.0, 59.0, 244.0, 0.00),
    (78, 'pirate', 31, -1627.0, 59.3, 247.0, 0.00),
    (79, 'pirate', 31, -1617.0, 60.4, 257.0, 0.00);
