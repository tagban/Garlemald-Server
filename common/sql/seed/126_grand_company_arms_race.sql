-- Arms Race (Com0u4), the Immortal Flames' recruit mission: the Hellhounds'
-- camp and the Hellhounds in Eastern Thanalan, and three arms dealers in Limsa
-- Lominsa.
--
-- The Golden Bazaar's spot isn't known (north-west Eastern Thanalan), so the
-- Hellhounds hold the road north-west out of Camp Drybone. The dealers' own
-- classes aren't known either: generic classes of the right race stand in for
-- them at the Limsa Lominsa shops, a Roegadyn pirate for Woolvale Arms, a
-- Lalafell peddler for Straight Edge Traders and a Miqo'te smithy for the
-- Gigas Forge. The Hellhounds are the imperial troopers of seed 121 (pool 19)
-- and a hellhound.
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
WHERE "id" IN (1001740, 1000420, 1000719) AND ("classPath" = '' OR "classPath" IS NULL);

-- The Hellhounds' camp, walked into to start the fight.
UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "6.0",
      "outwards": "false",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090326 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27707, 1090326, 'com0u4_hellhound_camp', 171, '', 0, 1200.00, 266.00, -625.00,  0.00, 0, 0, null),
    (27708, 1001740, 'com0u4_woolvale',       230, '', 0, -570.00,  18.20,  206.00, -1.57, 0, 0, null),
    (27709, 1000420, 'com0u4_straight_edge',  230, '', 0, -568.00,  18.20,  213.00, -1.57, 0, 0, null),
    (27710, 1000719, 'com0u4_gigas_forge',    230, '', 0, -562.00,  18.10,  208.00,  1.40, 0, 0, null);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (24, 2109801, 'hellhound', 3, 0, 1, 4200, 1, 1, 0, 0, 0, 0);

INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (28, 19, 'hellhound_sellsword', 23, 24, 0, 600, 0, 0, 0, 1, 0, 0, '', 0, 171),
    (29, 24, 'hellhound',           23, 23, 0, 600, 0, 0, 0, 1, 0, 0, '', 0, 171);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (70, 'hellhound_sellsword', 28, 1196.0, 266.0, -634.0, 0.00),
    (71, 'hellhound_sellsword', 28, 1206.0, 266.0, -632.0, 0.00),
    (72, 'hellhound_sellsword', 28, 1201.0, 266.0, -638.0, 0.00),
    (73, 'hellhound',           29, 1199.0, 266.0, -630.0, 0.00);
