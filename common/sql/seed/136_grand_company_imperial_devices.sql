-- Imperial Devices (Com5l0/g0/u0), each Grand Company's first quest for
-- sworn members: the Thousand Maws of Toto-Rak and the imperial device in
-- its last chamber.
--
-- Bloisirant, the Wood Wailer posted at the Maws, stands by the Silent
-- Arbor's aetherial gate in the South Shroud (zone 154), where leaving the
-- dungeon sets you down (scripts/lua/dungeon.lua). The moogles and the
-- device are spawned into every copy of the dungeon by its content script
-- (SimpleContentDungeonTotorak), in the last chamber by the lantern huts.
-- Ground at both places checked in the test client.
--
-- Bloisirant, the three moogles and the device ("Magitek transmitter")
-- ship stripped in gamedata (classPath ''); they get PopulaceStandard and a
-- talk condition.
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
WHERE "id" IN (1001150, 1001936, 1001937, 1001938, 1002063)
  AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27766, 1001150, 'com5x0_bloisirant',        154, '', 0,   992.00, -11.97,   613.00,  3.14, 0, 0, null);
