-- Whispers in the Wood (Man1g0, Gridania's level 8 story): the three echo
-- instances.
--
-- The quest moves the player through Gridania's PrivateAreaMasterPast
-- types 7 (the Carpenters' Guild in the echo), 8 (the Acorn Orchard, Fye)
-- and 9 (the orchard after Fye), but zone 206 only had type 5, so the
-- server dropped the player into town, with nobody the quest talks to.
--
-- Type 7 has the guild where it stands in town, plus Zezekuta. The way
-- out is the playground trigger (1090204), a 15-yalm circle that fires on
-- leaving it, so it sits at the middle of the guild. Types 8 and 9 put Fye
-- and the two girls a few yalms from the quest's orchard arrival, on floor
-- checked in the test client, facing it; type 9's exit (1090205) is the
-- same leave-the-circle trigger around the arrival point.
--
-- Fye, the girls, Zezekuta and the exit trigger ship stripped in gamedata
-- (classPath ''), which crashes the client on spawn: the people get the
-- guild NPCs' PopulaceStandard row, the exit the playground trigger's.
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

INSERT INTO "server_zones_privateareas"
    ("parentZoneId", "className", "privateAreaName", "privateAreaType", "dayMusic", "nightMusic", "battleMusic")
SELECT 206, '/Area/PrivateArea/PrivateAreaMasterPast', 'PrivateAreaMasterPast', t.type, 0, 0, 0
FROM (SELECT 7 AS type UNION ALL SELECT 8 UNION ALL SELECT 9) AS t
WHERE NOT EXISTS (SELECT 1 FROM "server_zones_privateareas" p
                  WHERE p."parentZoneId" = 206 AND p."privateAreaName" = 'PrivateAreaMasterPast'
                    AND p."privateAreaType" = t.type);

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
WHERE "id" IN (
    1000014, -- Fye
    1000240, -- Zezekuta
    1000827, -- Deserted Daughter
    1000828  -- Troublesome Tomboy
) AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "propertyFlags" = 1,
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "15.0",
      "outwards": "true",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090205 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27588, 1000465, 'man1g0_7_anaidjaa', 206, 'PrivateAreaMasterPast', 7,    11.86,  8.75,  -1265.19,  1.66, 0, 1015, null),
    (27589, 1000466, 'man1g0_7_frances', 206, 'PrivateAreaMasterPast', 7,    11.85,  8.75,  -1266.45,  1.48, 0, 1041, null),
    (27590, 1000622, 'man1g0_7_decima', 206, 'PrivateAreaMasterPast', 7,    -8.60,  8.75,  -1261.71,  1.56, 0, 2036, null),
    (27591, 1000623, 'man1g0_7_chalyo_tamlyo', 206, 'PrivateAreaMasterPast', 7,    -8.96, 12.07,  -1257.55,  0.00, 0, 2037, null),
    (27592, 1000823, 'man1g0_7_ulmhylt', 206, 'PrivateAreaMasterPast', 7,    -3.90,  8.75,  -1263.30,  0.44, 0, 0, null),
    (27593, 1000822, 'man1g0_7_caplan', 206, 'PrivateAreaMasterPast', 7,    -8.78,  8.75,  -1268.19,  3.14, 0, 0, null),
    (27594, 1000240, 'man1g0_7_zezekuta', 206, 'PrivateAreaMasterPast', 7,     6.92,  9.15,  -1266.25,  1.36, 0, 0, null),
    (27595, 1090204, 'man1g0_7_playground_trigger', 206, 'PrivateAreaMasterPast', 7,     1.50,  8.75,  -1264.00,  0.00, 0, 0, null), -- leave the guild (15 yalms) for the Acorn Orchard
    (27596, 1000014, 'man1g0_8_fye', 206, 'PrivateAreaMasterPast', 8,   -32.95,  7.91,  -1247.60, -2.37, 0, 0, null), -- Fye
    (27597, 1000828, 'man1g0_8_troublesome_tomboy', 206, 'PrivateAreaMasterPast', 8,   -31.00,  7.82,  -1250.16, -1.57, 0, 0, null),
    (27598, 1000827, 'man1g0_8_deserted_daughter', 206, 'PrivateAreaMasterPast', 8,   -34.47,  8.11,  -1245.13, -2.95, 0, 0, null),
    (27599, 1000828, 'man1g0_9_troublesome_tomboy', 206, 'PrivateAreaMasterPast', 9,   -31.00,  7.82,  -1250.16, -1.57, 0, 0, null),
    (27600, 1000827, 'man1g0_9_deserted_daughter', 206, 'PrivateAreaMasterPast', 9,   -34.47,  8.11,  -1245.13, -2.95, 0, 0, null),
    (27601, 1090205, 'man1g0_9_playground_exit', 206, 'PrivateAreaMasterPast', 9,   -35.45,  7.90,  -1250.15,  0.00, 0, 0, null); -- leave the orchard (15 yalms) back to the guild
