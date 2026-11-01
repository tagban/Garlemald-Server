-- Two Vans are Better than One (Gcg102), the Order of the Twin Adder's
-- search for Arthur and the Yellow Serpents (scripts/lua/quests/gcg/gcg102.lua):
--
-- * At the Toto-Moy Battlewarrens, south-west of Camp Nine Ivies in the East
--   Shroud (zone 151): Arthur, Pfrymloef, High Commander Flutaint (Quinquerol
--   in the client), Serpent Captain Tall Oak and Serpent Commander Yarborough
--   (the client script's "Vevina"). No map or cut scene places the
--   Battlewarrens, so they stand in the raised clearing south of the camp
--   (map 47,32), the nearest open ground to the south-west.
-- * The Garleans who come back for them, spawned by the duty
--   (SimpleContentGcg10201). They share seed 143's imperial pools.
-- * Cid, Foreman Ebrelnaux and Bardo at the Gridania airship landing (zone
--   155), on the lower deck beside Lionnellais.
--
-- Heights checked in the test client. Arthur, Pfrymloef, Quinquerol, Tall
-- Oak, Yarborough and Bardo ship stripped in gamedata (classPath '') and get
-- PopulaceStandard. Gcg102 follows It Kills with Fire (Gcg101).
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "gamedata_quests" SET "prerequisite" = 111616
WHERE "id" = 111627 AND "prerequisite" = 0;

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
WHERE "id" IN (1001734, 1001812, 1001809, 1001807, 1001808, 1001580)
  AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27782, 1001809, 'gcg102_quinquerol',       151, '', 0,  1635.00,  64.00,  -611.40, -2.98, 0, 0, null),
    (27783, 1001734, 'gcg102_arthur',           151, '', 0,  1631.00,  64.45,  -618.40,  0.44, 0, 0, null),
    (27784, 1001812, 'gcg102_pfrymloef',        151, '', 0,  1629.00,  64.15,  -616.40,  0.85, 0, 0, null),
    (27785, 1001807, 'gcg102_tall_oak',         151, '', 0,  1640.00,  63.65,  -617.40, -0.84, 0, 0, null),
    (27786, 1001808, 'gcg102_yarborough',       151, '', 0,  1638.00,  63.40,  -608.40, -2.30, 0, 0, null),
    (27787, 1001572, 'gcg102_cid',              155, '', 0,    61.00,  -7.00, -1209.50,  0.00, 0, 0, null),
    (27788, 1060011, 'gcg102_ebrelnaux',        155, '', 0,    65.50,  -7.00, -1210.50, -0.79, 0, 0, null),
    (27789, 1001580, 'gcg102_bardo',            155, '', 0,    58.00,  -7.00, -1211.50,  0.79, 0, 0, null);

-- spawnType 1 keeps them out of the open world: the duty spawns them.
INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (30106, 30103, 'gcg102_secutor',     40, 40, 0, 1400, 0, 0, 0, 1, 0, 0, '', 0, 151),
    (30107, 30104, 'gcg102_hoplomachus', 40, 40, 0, 1400, 0, 0, 0, 1, 0, 0, '', 0, 151),
    (30108, 30105, 'gcg102_sagittarius', 40, 40, 0, 1200, 0, 0, 0, 1, 0, 0, '', 0, 151);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (3511, 'gcg102_secutor',     30106, 1642.0, 62.4, -606.4, 3.14),
    (3512, 'gcg102_hoplomachus', 30107, 1628.0, 64.0, -606.4, 3.14),
    (3513, 'gcg102_secutor',     30106, 1635.0, 64.0, -604.4, 3.14),
    (3514, 'gcg102_sagittarius', 30108, 1635.0, 61.7, -598.6, 3.14);
