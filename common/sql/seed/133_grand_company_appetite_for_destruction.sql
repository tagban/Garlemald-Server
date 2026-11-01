-- Appetite for Destruction (Com0g6), the Twin Adder's sixth recruit mission:
-- Bowlord Lewin, Cid and those gathered at Stillglade Fane, the clearing west
-- of Camp Nine Ivies, and the spiders that hold it.
--
-- Stillglade Fane is the conjurers' hall in Gridania (zone 206); the cast
-- stands on its floor around the circle, where O-App-Pesi already stands.
-- The clearing is where the client stages com0g510 (Cid's flare and Arthur),
-- in the East Shroud (zone 151). Ground at both places checked in the test
-- client.
--
-- Lewin, Concessa, Kinborow, Norbertillon and Suzari Sorezari ship stripped
-- in gamedata (classPath ''); they get PopulaceStandard. Swethyna and
-- O-App-Pesi have classes in use already. The beasts are spiders, as in the
-- cutscene (a large female and two young): a diremite and two molting
-- mitelings.
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
WHERE "id" IN (1000020, 1000511, 1000509, 1001735, 1001736)
  AND ("classPath" = '' OR "classPath" IS NULL);

-- The clearing, walked into to secure it.
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
WHERE "id" = 1090331 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27753, 1090331, 'com0g6_clearing',           151, '', 0,  1475.00,  21.60,  -804.00,  0.00, 0, 0, null),
    (27754, 1000020, 'com0g6_lewin',              206, '', 0,  -344.00,   6.82, -1699.50,  0.00, 0, 0, null),
    (27755, 1001572, 'com0g6_cid',                206, '', 0,  -341.00,   6.82, -1696.00, -2.40, 0, 0, null),
    (27756, 1000680, 'com0g6_swethyna',           206, '', 0,  -348.70,   6.23, -1694.50,  2.50, 0, 0, null),
    (27757, 1000511, 'com0g6_concessa',           206, '', 0,  -348.50,   6.82, -1704.40,  0.80, 0, 0, null),
    (27758, 1000509, 'com0g6_kinborow',           206, '', 0,  -342.50,   6.82, -1705.00, -0.50, 0, 0, null),
    (27759, 1001735, 'com0g6_norbertillon',       206, '', 0,  -340.90,   6.82, -1694.60,  3.00, 0, 0, null),
    (27760, 1001736, 'com0g6_suzari_sorezari',    206, '', 0,  -345.50,   6.82, -1703.00,  0.30, 0, 0, null);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (28, 2101103, 'diremite', 22, 0, 1, 4200, 1, 1, 0, 0, 0, 0),
    (29, 2101112, 'molting_miteling', 22, 0, 1, 4200, 1, 1, 0, 0, 0, 0);

INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (33, 28, 'diremite', 26, 26, 0, 900, 0, 0, 0, 1, 0, 0, '', 0, 151),
    (34, 29, 'molting_miteling', 25, 25, 0, 500, 0, 0, 0, 1, 0, 0, '', 0, 151);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (83, 'diremite', 33, 1471.4, 22.2, -803.4, 0.00),
    (84, 'molting_miteling', 34, 1479.4, 21.8, -810.4, 0.00),
    (85, 'molting_miteling', 34, 1471.4, 22.2, -799.4, 0.00);
