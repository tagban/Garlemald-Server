-- Don't Hate the Messenger (Gcl105, Gcg105, Gcu105), the Grand Companies'
-- alliance quest (scripts/lua/quests/gc/gc105.lua). Kinnison already stands
-- before the Lotus Stand, Kan-E-Senna and Cid at Stillglade Fane, Zanthael at
-- the Admiral's Lift, Merlwyb and Storm Marshal Slafyrsyn in the Coral Tower,
-- Mumutano and Raubahn on the Royal Promenade, and the marshals in each
-- headquarters. This adds:
--
-- * Dyrfhund, the stateroom guard, beside Merlwyb in the Coral Tower (zone
--   230). He also gives the stateroom guard Augustine's lines (no class).
-- * Cid Garlond, Ebrelnaux and Saelbmoht southwest of Camp Brittlebark (Mor
--   Dhona, zone 190), on the open ground below the aetheryte.
-- * The fallen warship's strongbox, a trigger where the client's cut scene
--   (gc010610) sets Gaius van Baelsar: the valley at (-530, -3.7, 310).
-- * The Garleans guarding the wreck: an imperial secutor, hoplomachus and
--   sagittarius (seed 143's pools) at level 45, in the open world.
-- * The Archons in the clearing before the Lotus Stand, north of Kinnison
--   (zone 206): Y'shtola, Papalymo, Thancred, Urianger and Yda.
--
-- Heights checked in the test client. Dyrfhund and Yda ship stripped in
-- gamedata (classPath '') and get PopulaceStandard. Gc?105 follows Gc?104.
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "gamedata_quests" SET "prerequisite" = 111430 WHERE "id" = 111431 AND "prerequisite" = 0;
UPDATE "gamedata_quests" SET "prerequisite" = 111630 WHERE "id" = 111631 AND "prerequisite" = 0;
UPDATE "gamedata_quests" SET "prerequisite" = 111830 WHERE "id" = 111831 AND "prerequisite" = 0;

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
WHERE "id" IN (1001921, 1002000)
  AND ("classPath" = '' OR "classPath" IS NULL);

-- The strongbox.
UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "3.0",
      "outwards": "false",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090341 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27824, 1001921, 'gc105_dyrfhund',         230, '', 0,  -621.00,  43.00,   -72.00,  1.57, 0, 0, null),
    (27825, 1001572, 'gc105_cid_mor_dhona',    190, '', 0,   453.40,  19.90,   704.90, -2.36, 0, 0, null),
    (27826, 1060011, 'gc105_ebrelnaux',        190, '', 0,   448.40,  20.30,   708.90, -2.36, 0, 0, null),
    (27827, 1001732, 'gc105_saelbmoht',        190, '', 0,   456.40,  19.60,   707.90, -2.36, 0, 0, null),
    (27828, 1090341, 'gc105_strongbox',        190, '', 0,  -529.50,  -3.70,   310.10,  0.00, 0, 0, null),
    (27829, 1000001, 'gc105_yshtola',          206, '', 0,  -197.40,  22.82, -1603.10,  2.74, 0, 0, null),
    (27830, 1000010, 'gc105_papalymo',         206, '', 0,  -193.40,  22.76, -1601.10,  2.74, 0, 0, null),
    (27831, 1000185, 'gc105_thancred',         206, '', 0,  -199.70,  22.72, -1607.10,  2.74, 0, 0, null),
    (27832, 1500204, 'gc105_urianger',         206, '', 0,  -195.60,  22.93, -1599.10,  2.74, 0, 0, null),
    (27833, 1002000, 'gc105_yda',              206, '', 0,  -190.80,  22.95, -1604.00,  2.74, 0, 0, null);

-- The Garleans at the wreck, in the open world (spawnType 0).
INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (30118, 30103, 'gc105_secutor',     45, 45, 60, 1800, 0, 0, 0, 0, 0, 0, '', 0, 190),
    (30119, 30104, 'gc105_hoplomachus', 45, 45, 60, 1800, 0, 0, 0, 0, 0, 0, '', 0, 190),
    (30120, 30105, 'gc105_sagittarius', 45, 45, 60, 1500, 0, 0, 0, 0, 0, 0, '', 0, 190);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (3525, 'gc105_secutor',     30118, -539.5, -4.4, 301.9, 0.79),
    (3526, 'gc105_hoplomachus', 30119, -522.0, -2.8, 318.0, -2.36),
    (3527, 'gc105_sagittarius', 30120, -533.0, -4.0, 314.0, 2.36);
