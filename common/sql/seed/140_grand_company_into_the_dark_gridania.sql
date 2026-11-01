-- Into the Dark (Com5g1), the Order of the Twin Adder's version: Ser
-- Yuhelmeric, lord commander of House Durendaire's knights, at Owl's Nest
-- (Coerthas Eastern Lowlands, zone 145), a few steps west of Ser Vairemont
-- (seed 139). The Darkhold's guard and terminal are seed 139's and the
-- dungeon content script's. Ground checked in the test client.
--
-- Yuhelmeric ships stripped in gamedata (classPath ''); he gets
-- PopulaceStandard and a talk condition.
--
-- Idempotent: the UPDATE is guarded, the INSERT is OR IGNORE on id. No
-- schema change.

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
WHERE "id" = 1000370 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27770, 1000370, 'com5g1_yuhelmeric',        145, '', 0,  2547.50, 175.20,  1309.00,  3.14, 0, 0, null);
