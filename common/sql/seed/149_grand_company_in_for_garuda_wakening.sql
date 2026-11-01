-- In for Garuda Wakening (Gcl104, Gcg104, Gcu104), the Grand Companies'
-- Garuda quest (scripts/lua/quests/gc/gc104.lua). Louisoix already stands at
-- Apkallus Falls, Merlwyb and Storm Marshal Slafyrsyn in the Coral Tower,
-- Kan-E-Senna at Stillglade Fane, Raubahn on the Royal Promenade, Zanthael at
-- the Admiral's Lift, and the marshals in each headquarters. This adds:
--
-- * Quarrymill in the South Shroud (zone 154), where Garuda's cut scene
--   (gc010410) plays: the trigger by the hamlet's campfire, and the Wood
--   Wailers Ethelinda and Hedheue beside it.
-- * The beastman aetheryte at the north-east tip of Feathergorge (Coerthas
--   Central Highlands, zone 143, map 47,19), a trigger on the grass under
--   the cliff. Walking in asks to enter the Howling Eye.
-- * Cid Garlond in each company's headquarters (Maelstrom Command 232, the
--   Hall of Flames 233, the Adders' Nest 234), on the hall floor by the west
--   benches.
-- * Garuda (battle npc 3524, class 2209501, GarudaNormal) for the Howling
--   Eye (zone 239), spawned into each copy by SimpleContentHowlingEye. The
--   arena sits where the client's own Howling Eye cut scenes (gc010420-440)
--   stand, around (1470-1520, 300, -280); spawnType 1 keeps her out of the
--   open world.
--
-- Heights checked in the test client. Gc?104 follows Gc?103.
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "gamedata_quests" SET "prerequisite" = 111429 WHERE "id" = 111430 AND "prerequisite" = 0;
UPDATE "gamedata_quests" SET "prerequisite" = 111629 WHERE "id" = 111630 AND "prerequisite" = 0;
UPDATE "gamedata_quests" SET "prerequisite" = 111829 WHERE "id" = 111830 AND "prerequisite" = 0;

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
WHERE "id" IN (1001352, 1001353)
  AND ("classPath" = '' OR "classPath" IS NULL);

-- Quarrymill and the beastman aetheryte.
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
WHERE "id" = 1090339 AND ("classPath" = '' OR "classPath" IS NULL);

-- The aetheryte asks with the raid guides' own prompt, which only their
-- class (InstanceRaidGuide, Louisoix's) carries.
UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/InstanceRaidGuide/InstanceRaidGuide',
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "4.0",
      "outwards": "false",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090340 AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "gamedata_actor_class" SET "classPath" = '/Chara/Npc/Monster/Garuda/GarudaNormal'
WHERE "id" = 2209501 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27817, 1090339, 'gc104_quarrymill',        154, '', 0,  1394.50,  -6.30,   936.60,  0.00, 0, 0, null),
    (27818, 1001352, 'gc104_ethelinda',         154, '', 0,  1393.10,  -6.30,   938.10,  2.36, 0, 0, null),
    (27819, 1001353, 'gc104_hedheue',           154, '', 0,  1391.80,  -6.30,   939.70,  2.36, 0, 0, null),
    (27820, 1090340, 'gc104_beastman_aetheryte', 143, '', 0, 1028.60, 290.80,  -139.40,  0.00, 0, 0, null),
    (27821, 1001572, 'gc104_cid_maelstrom',     232, '', 0,   152.00,   0.00,  -170.00,  1.57, 0, 0, null),
    (27822, 1001572, 'gc104_cid_flames',        233, '', 0,   152.00,   0.00,  -170.00,  1.57, 0, 0, null),
    (27823, 1001572, 'gc104_cid_adders',        234, '', 0,   152.00,   0.00,  -170.00,  1.57, 0, 0, null);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (30109, 2209501, 'Garuda', 59, 0, 1, 3600, 1.5, 1, 0, 0, 0, 0);

INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (30117, 30109, 'garuda', 45, 45, 0, 12000, 0, 0, 0, 1, 0, 0, '', 0, 239);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (3524, 'garuda', 30117, 1490.0, 302.0, -280.0, 1.57);
