-- Imperial Devices (Com5l0), the Maelstrom's version: Brother Zerig of the
-- Conjurers' Guild, who takes Cid's petition and hands you the urn with the
-- earth elemental. He stands in the Stillglade Fane (Gridania, zone 206),
-- on the lower floor west of Swethyna and Lewin (seed 133). Ground checked
-- in the test client.
--
-- Zerig ships stripped in gamedata (classPath ''); he gets PopulaceStandard
-- and a talk condition.
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
WHERE "id" = 1000510 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27767, 1000510, 'com5l0_zerig',             206, '', 0,  -352.50,   6.23, -1695.00,  1.57, 0, 0, null);
