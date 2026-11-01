-- Imperial Devices (Com5g0), the Order of the Twin Adder's version: Seedseer
-- A-Ruhn-Senna, found resting in the Thousand Maws' last chamber with the
-- moogles. The dungeon content script (SimpleContentDungeonTotorak) spawns
-- him there beside the device and the moogles (seed 136).
--
-- A-Ruhn-Senna ships stripped in gamedata (classPath ''); he gets
-- PopulaceStandard and a talk condition.
--
-- Idempotent: the UPDATE is guarded. No schema change.

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
WHERE "id" = 1001571 AND ("classPath" = '' OR "classPath" IS NULL);
