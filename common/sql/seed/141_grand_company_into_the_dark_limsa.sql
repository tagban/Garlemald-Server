-- Into the Dark (Com5l1), the Maelstrom's version: Quiliane, the Faces of
-- Mercy's contact at Owl's Nest (Coerthas Eastern Lowlands, zone 145), a
-- few steps east of Ser Vairemont (seed 139). Hasthwab already stands on
-- the Astalicia (seed 031). The Darkhold's guard and terminal are seed
-- 139's and the dungeon content script's. Ground checked in the test client.
--
-- Quiliane ships stripped in gamedata (classPath ''); she gets
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
WHERE "id" = 1001635 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27771, 1001635, 'com5l1_quiliane',          145, '', 0,  2559.50, 176.00,  1309.50,  3.14, 0, 0, null);
