-- Their Finest Hour (Com0g5), the Twin Adder's fifth recruit mission: the
-- crowd and Thancred at Mih Khetto's Amphitheatre after Kan-E-Senna's
-- address, and Thancred and Urianger at the Rootslake.
--
-- The client names no classes for the crowd: generic Gridanians that match
-- each line stand in (a Wood Wailer, a Serpent captain, a conjurer, a mother
-- and a child). Four ship stripped in gamedata (classPath ''); they get
-- PopulaceStandard. They take the amphitheatre's benches, where the ceremony
-- cutscene sets the player down; Thancred stands below them on the stage.
-- The Rootslake is the lake east of Camp Tranquil in the South Shroud (zone
-- 154); Thancred and Urianger stand on the gully path down to its west shore
-- (checked in the test client).
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
WHERE "id" IN (1000851, 1001896, 1000422, 1000424) AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27718, 1000185, 'com0g5_thancred_stage',     206, '', 0,   -96.50,  9.96, -1636.50,  0.00, 0, 0, null),
    (27719, 1000851, 'com0g5_stalwart_wailer',    206, '', 0,   -89.56, 11.30, -1631.43,  3.14, 0, 0, null),
    (27720, 1001896, 'com0g5_serpent_captain',    206, '', 0,   -86.71, 11.96, -1626.99,  3.14, 0, 0, null),
    (27721, 1000743, 'com0g5_wise_conjurer',      206, '', 0,  -105.65, 13.40, -1621.75,  3.14, 0, 0, null),
    (27722, 1000422, 'com0g5_flustered_mother',   206, '', 0,  -102.63, 11.96, -1626.77,  3.14, 0, 0, null),
    (27723, 1000424, 'com0g5_excited_child',      206, '', 0,   -99.56, 11.79, -1626.44,  3.14, 0, 0, null),
    (27724, 1000185, 'com0g5_thancred_rootslake', 154, '', 0,  1440.00, -8.60,  1162.00,  1.57, 0, 0, null),
    (27725, 1500204, 'com0g5_urianger_rootslake', 154, '', 0,  1438.50, -9.50,  1159.00,  1.57, 0, 0, null);
