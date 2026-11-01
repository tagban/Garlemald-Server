-- Ceruleum Shock (Com0l6), the Maelstrom's sixth recruit mission: the Hollow
-- Barons and the travelers at Vesper Bay, the Immortal Flames who answer the
-- Barons' riot, and Cid with those waiting on the Limsa Lominsa Landing.
--
-- The bay is the ferry docks Burning Man (Com0u5, seed 131) uses, in Western
-- Thanalan (zone 172). The Landing atop the Mizzenmast has no zone on this
-- server, so its company stands beside Zanthael's lift in Limsa Lominsa (zone
-- 133), where the lift ride sets the player down. Ground at both places
-- checked in the test client; past
-- x -1623 the ground drops away to the sea.
--
-- The client names no classes for the Barons and the bystanders: a pirate
-- stands in for Lvfrid, and generic Lominsans and travelers that match each
-- line stand in for the rest. The Landing's own staff (Ajin Zukajin,
-- Raplulu, G'zentsa, Aldyet) take the Landing's lines. Those that ship
-- stripped in gamedata (classPath '') get PopulaceStandard. The Flames are
-- Flame scouts, which ship stripped too; they get the class the pirates use
-- (PirateStandard), the human enemies' class.
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
WHERE "id" IN (1001572, 1000765, 1000114, 1000763, 1000124, 1000772, 1000116,
               1001700, 1001701, 1001702, 1001703)
  AND ("classPath" = '' OR "classPath" IS NULL);

-- Burning Man's docks cast (seed 131) stood in the air: the captain and the
-- bonny lass past the cliff edge over the sea, the rest a step above the
-- slope. Set them on the ground above the docks.
UPDATE "server_spawn_locations" SET "positionX" = -1622.35, "positionY" = 58.35, "positionZ" = 243.00
WHERE "id" = 27729 AND "uniqueId" = 'com0u5_flame_captain';
UPDATE "server_spawn_locations" SET "positionX" = -1619.60, "positionY" = 60.15, "positionZ" = 253.50
WHERE "id" = 27730 AND "uniqueId" = 'com0u5_bonny_lass';
UPDATE "server_spawn_locations" SET "positionX" = -1614.00, "positionY" = 58.70, "positionZ" = 248.50
WHERE "id" = 27727 AND "uniqueId" = 'com0u5_thancred_docks';
UPDATE "server_spawn_locations" SET "positionX" = -1614.10, "positionY" = 57.95, "positionZ" = 244.50
WHERE "id" = 27728 AND "uniqueId" = 'com0u5_urianger_docks';
UPDATE "server_spawn_locations" SET "positionX" = -1618.00, "positionY" = 60.35, "positionZ" = 254.50
WHERE "id" = 27731 AND "uniqueId" = 'com0u5_greedy_merchant';

-- The docks at Vesper Bay, walked into to join the riot.
UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "8.0",
      "outwards": "false",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090330 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27739, 1090330, 'com0l6_vesper_bay',                172, '', 0, -1620.00,  59.50,  248.00,  0.00, 0, 0, null),
    (27740, 1000765, 'com0l6_lvfrid',                    172, '', 0, -1617.40,  59.05,  247.00,  1.57, 0, 0, null),
    (27741, 1000114, 'com0l6_hook_nosed_pirate',         172, '', 0, -1618.60,  58.80,  244.00,  1.57, 0, 0, null),
    (27742, 1000763, 'com0l6_uninhibited_buccaneer',     172, '', 0, -1618.60,  59.90,  250.50,  1.57, 0, 0, null),
    (27743, 1000124, 'com0l6_discombobulated_traveler',  172, '', 0, -1616.30,  60.50,  252.60,  3.14, 0, 0, null),
    (27744, 1000772, 'com0l6_plump_faced_traveler',      172, '', 0, -1613.00,  59.70,  251.00, -1.57, 0, 0, null),
    (27745, 1001572, 'com0l6_cid',                       133, '', 0,  -437.00,  21.00,  182.00, -2.40, 0, 0, null),
    (27746, 1001700, 'com0l6_ajin_zukajin',              133, '', 0,  -434.00,  21.00,  179.00, -1.57, 0, 0, null),
    (27747, 1000079, 'com0l6_misinformed_pirate',        133, '', 0,  -444.00,  21.00,  181.00,  1.57, 0, 0, null),
    (27748, 1000116, 'com0l6_inscrutable_pirate',        133, '', 0,  -445.00,  21.00,  178.00,  1.57, 0, 0, null),
    (27749, 1000086, 'com0l6_coquettish_pirate',         133, '', 0,  -440.00,  21.00,  185.00,  3.14, 0, 0, null),
    (27750, 1001701, 'com0l6_raplulu',                   133, '', 0,  -435.00,  21.00,  175.00, -1.57, 0, 0, null),
    (27751, 1001702, 'com0l6_gzentsa',                   133, '', 0,  -437.00,  21.00,  172.00,  0.00, 0, 0, null),
    (27752, 1001703, 'com0l6_aldyet',                    133, '', 0,  -439.00,  21.00,  172.00,  0.00, 0, 0, null);

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Monster/Pirate/PirateStandard'
WHERE "id" = 2290052 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (27, 2290052, 'flame_scout', 3, 0, 1, 4200, 1, 1, 0, 0, 0, 0);

INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (32, 27, 'flame_scout', 25, 26, 0, 650, 0, 0, 0, 1, 0, 0, '', 0, 172);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (80, 'flame_scout', 32, -1613.4, 57.8, 244.8, 0.00),
    (81, 'flame_scout', 32, -1617.0, 60.4, 257.0, 0.00),
    (82, 'flame_scout', 32, -1613.6, 60.3, 254.3, 0.00);
