-- Like Father, Like Son (Gcu102), the Immortal Flames' stand against the
-- Garleans marching on Thanalan (scripts/lua/quests/gcu/gcu102.lua), north of
-- Camp Black Brush in Central Thanalan (zone 170):
--
-- * High Commander Jakys Ryder and his Free Brigade (Clovissoix, Dhavha and
--   Makago Nokago), on the open ground beside the Royal Sunway north of the
--   camp.
-- * The cave the brigade sends you to, north-west at the foot of the cliffs:
--   walked into to start the duty. No map or cut scene names the cave (the
--   Echo's cut scene, gc01u210, is set in Mor Dhona), so the trigger stands
--   where the cliff wall meets the brush.
-- * The Garleans who fall on you there, spawned by the duty
--   (SimpleContentGcu10201) from seed 143's imperial pools, and the four left
--   lying afterwards: the centurion who lives, and three who don't wake.
--
-- Cid and the airship landing's cast already stand at the landing (seed 134).
-- Heights checked in the test client. The whole cast ships stripped in
-- gamedata (classPath '') and gets PopulaceStandard. Gcu102 follows It Kills
-- with Fire (Gcu101).
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "gamedata_quests" SET "prerequisite" = 111816
WHERE "id" = 111827 AND "prerequisite" = 0;

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
WHERE "id" IN (1001815, 1001816, 1001817, 1001818, 1001819, 1001820, 1001821, 1001822)
  AND ("classPath" = '' OR "classPath" IS NULL);

-- The cave mouth.
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
WHERE "id" = 1090334 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27790, 1001815, 'gcu102_ryder',            170, '', 0,     0.00, 200.10,  -521.70, -2.49, 0, 0, null),
    (27791, 1001816, 'gcu102_clovissoix',       170, '', 0,     5.45, 200.00,  -527.80, -0.73, 0, 0, null),
    (27792, 1001817, 'gcu102_dhavha',           170, '', 0,    -6.10, 200.20,  -517.80,  2.14, 0, 0, null),
    (27793, 1001818, 'gcu102_makago_nokago',    170, '', 0,     3.85, 200.00,  -515.80, -2.56, 0, 0, null),
    (27794, 1090334, 'gcu102_cave_mouth',       170, '', 0,   -30.00, 197.40,  -561.10,  0.00, 0, 0, null),
    (27795, 1001819, 'gcu102_centurion',        170, '', 0,   -34.65, 200.10,  -569.70,  0.62, 0, 0, null),
    (27796, 1001820, 'gcu102_hoplomachus',      170, '', 0,   -25.80, 200.40,  -579.15,  0.62, 0, 0, null),
    (27797, 1001821, 'gcu102_signifer',         170, '', 0,   -16.35, 200.10,  -570.30,  0.62, 0, 0, null),
    (27798, 1001822, 'gcu102_laquearius',       170, '', 0,   -43.40, 195.30,  -561.65,  0.62, 0, 0, null);

-- spawnType 1 keeps them out of the open world: the duty spawns them.
INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (30109, 30103, 'gcu102_secutor',     40, 40, 0, 1400, 0, 0, 0, 1, 0, 0, '', 0, 170),
    (30110, 30104, 'gcu102_hoplomachus', 40, 40, 0, 1400, 0, 0, 0, 1, 0, 0, '', 0, 170),
    (30111, 30105, 'gcu102_sagittarius', 40, 40, 0, 1200, 0, 0, 0, 1, 0, 0, '', 0, 170);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (3515, 'gcu102_secutor',     30109,  -7.1, 199.7, -561.5, -2.49),
    (3516, 'gcu102_hoplomachus', 30110, -15.8, 196.3, -552.3, -2.49),
    (3517, 'gcu102_secutor',     30109, -15.2, 195.0, -547.2, -2.49),
    (3518, 'gcu102_sagittarius', 30111, -38.3, 198.1, -567.5,  0.62);
