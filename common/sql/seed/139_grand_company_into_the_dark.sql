-- Into the Dark (Com5u1), the Immortal Flames' second quest for sworn
-- members: Ser Vairemont of House Fortemps at Owl's Nest (Coerthas Eastern
-- Lowlands, zone 145, among the haystacks), and Dyrstweitz, the House
-- Dzemael guard at Dzemael Darkhold, by the gate where leaving the dungeon
-- sets you down (Coerthas Central Highlands, zone 143; scripts/lua/dungeon.lua).
-- The magitek terminal is spawned into every copy of the dungeon by its
-- content script (SimpleContentDungeonDzemael), in its farthest chamber,
-- where the guard says it stands. Ground at all three places checked in the test client.
--
-- Vairemont, Dyrstweitz and the terminal ship stripped in gamedata
-- (classPath ''); they get PopulaceStandard and a talk condition.
--
-- Idempotent: the UPDATE is guarded, the INSERTs are OR IGNORE on id. No
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
WHERE "id" IN (1000586, 1001154, 1002062)
  AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27768, 1000586, 'com5x1_vairemont',         145, '', 0,  2553.00, 175.30,  1306.00,  3.14, 0, 0, null),
    (27769, 1001154, 'com5x1_dyrstweitz',        143, '', 0,  -512.00, 208.00,   544.00, -1.03, 0, 0, null);
