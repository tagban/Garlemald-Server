-- The Waking Sands (Fade to White, Man200, and Together We Stand, Man206).
--
-- The quests send the player into zone 181, private area
-- PrivateAreaMasterPast: type 0 for Fade to White, 1-3 for the start, middle
-- and end of Together We Stand (the layout swaps its decor per state). The
-- zone was a stub (no map name, the region of Ul'dah's streets) and nothing
-- was spawned there, so a warp in hung on "Now Loading".
--
-- The client picks the map to load by the region id in SetMap. Its region
-- table (data/03/C0/00/00.DAT) lists the Waking Sands layout, prv_w0_mlt01,
-- under region 205 (prv_w0, Ul'dah's private maps) with the Market Wards
-- and the Hall of Flames, and the layout files name its map wil0Event01. The
-- quest coordinates (-205.25, 0, -160 in; -126.2, 1.2, -160 in Minfilia's
-- office) land on its floor.
--
-- Minfilia, the Waking Sands adventurers and the three door triggers ship
-- stripped in gamedata (classPath ''), which crashes the client on spawn:
-- they get Tataru's PopulaceStandard row, and the doors the inn exit's
-- (etc5l2_inn_push_exit, same appearance), keeping their push circles.
--
-- No source has the retail spots. Minfilia stands behind her desk facing
-- the office warp; the rest stand on floor checked by walking the test
-- client to each spot (heights are where it settled). The office door has
-- no collision, so its two triggers sit either side of it, farther than
-- their 3-yalm radius from the quests' warp points.
--
-- The way in is Ul'dah's market-ward entrance (1090265). Its class row has
-- a push box, which names a trigger box in the client's map layout by id;
-- the row named none, so it never fired, for the quest or the town menu
-- (MarketEntrance.lua's header lists ids for the box, but sending them did
-- not fire it either). It gets a 3-yalm push circle on the same spot,
-- enabled by default as the town menu is for everyone. The market wards'
-- own exits share the class and get the circle too.
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "server_zones" SET
    "regionId" = 205,
    "zoneName" = 'wil0Event01',
    "classPath" = '/Area/Zone/ZoneMasterWilW0'
WHERE "id" = 181 AND ("zoneName" IS NULL OR "zoneName" = '');

INSERT INTO "server_zones_privateareas"
    ("parentZoneId", "className", "privateAreaName", "privateAreaType", "dayMusic", "nightMusic", "battleMusic")
SELECT 181, '/Area/PrivateArea/PrivateAreaMasterPast', 'PrivateAreaMasterPast', t.type, 61, 0, 0
FROM (SELECT 0 AS type UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) AS t
WHERE NOT EXISTS (SELECT 1 FROM "server_zones_privateareas" p
                  WHERE p."parentZoneId" = 181 AND p."privateAreaName" = 'PrivateAreaMasterPast'
                    AND p."privateAreaType" = t.type);

UPDATE "gamedata_actor_class" SET "eventConditions" = '{
  "noticeEventConditions": [
    {
      "unknown1": 1,
      "unknown2": 0,
      "conditionName": "noticeEvent"
    }
  ],
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "true",
      "radius": "3.0",
      "outwards": "false",
      "silent": "false",
      "conditionName": "in"
    }
  ]
}'
WHERE "id" = 1090265 AND "eventConditions" NOT LIKE '%pushWithCircle%';

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
WHERE "id" IN (
    1000843, -- Minfilia
    1001228, 1001229, 1001230, -- Satzfloh, Percevains, Una Tayuun
    1001274, 1001275, 1001276, 1001277, 1001278, 1001279, 1001280, 1001281, 1001282,
    1001373, 1001374, 1001375, 1001376, 1001377, 1001378 -- Sahja Zhwan .. Seranelien
) AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "propertyFlags" = 1
WHERE "id" IN (1090160, 1090161, 1090162) AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    -- type 0: Fade to White
    (27522, 1000843, 'man200_minfilia', 181, 'PrivateAreaMasterPast', 0,  -119.30,  1.20,  -160.00, -1.57, 0, 0, null), -- Minfilia, behind her desk
    (27523, 1001046, 'man200_tataru', 181, 'PrivateAreaMasterPast', 0,  -139.40,  1.00,  -163.60, -0.79, 0, 0, null), -- Tataru, by the office door
    (27524, 1000841, 'man200_momodi', 181, 'PrivateAreaMasterPast', 0,  -139.40,  1.00,  -156.40, -2.36, 0, 0, null), -- Momodi (Seq 027)
    (27525, 1001228, 'man200_satzfloh', 181, 'PrivateAreaMasterPast', 0,  -145.40,  1.00,  -157.00,  3.08, 0, 0, null),
    (27526, 1001229, 'man200_percevains', 181, 'PrivateAreaMasterPast', 0,  -145.00,  1.00,  -163.00, -0.07, 0, 0, null),
    (27527, 1001230, 'man200_una_tayuun', 181, 'PrivateAreaMasterPast', 0,  -153.50,  0.10,  -161.50,  1.43, 0, 0, null),
    (27528, 1001378, 'man200_seranelien', 181, 'PrivateAreaMasterPast', 0,  -199.70,  0.00,  -156.00,  1.57, 0, 0, null),
    (27529, 1001375, 'man200_godfrey', 181, 'PrivateAreaMasterPast', 0,  -198.30,  0.00,  -156.00, -1.57, 0, 0, null),
    (27530, 1001373, 'man200_sahja_zhwan', 181, 'PrivateAreaMasterPast', 0,  -199.70,  0.00,  -164.00,  1.57, 0, 0, null),
    (27531, 1001374, 'man200_nenekani', 181, 'PrivateAreaMasterPast', 0,  -198.30,  0.00,  -164.00, -1.57, 0, 0, null),
    (27532, 1001376, 'man200_fenana', 181, 'PrivateAreaMasterPast', 0,  -195.10,  0.10,  -152.00,  1.57, 0, 0, null),
    (27533, 1001377, 'man200_nonoru', 181, 'PrivateAreaMasterPast', 0,  -193.70,  0.10,  -152.00, -1.57, 0, 0, null),
    (27534, 1001274, 'man200_rough_spoken_fellow', 181, 'PrivateAreaMasterPast', 0,  -189.20,  0.00,  -155.50,  1.57, 0, 0, null),
    (27535, 1001275, 'man200_red_shoed_rascal', 181, 'PrivateAreaMasterPast', 0,  -187.80,  0.00,  -155.50, -1.57, 0, 0, null),
    (27536, 1001276, 'man200_abstracted_gladiator', 181, 'PrivateAreaMasterPast', 0,  -159.10,  0.00,  -156.00,  1.57, 0, 0, null),
    (27537, 1001277, 'man200_chapeaued_chap', 181, 'PrivateAreaMasterPast', 0,  -157.70,  0.00,  -156.00, -1.57, 0, 0, null),
    (27538, 1001278, 'man200_barratrous_buccaneer', 181, 'PrivateAreaMasterPast', 0,  -159.10,  0.00,  -164.00,  1.57, 0, 0, null),
    (27539, 1001279, 'man200_softhearted_septuagen', 181, 'PrivateAreaMasterPast', 0,  -157.70,  0.00,  -164.00, -1.57, 0, 0, null),
    (27540, 1001280, 'man200_indigo_eyed_archer', 181, 'PrivateAreaMasterPast', 0,  -193.40, -0.27,  -167.20,  3.14, 0, 0, null),
    (27541, 1001281, 'man200_loam_scented_lady', 181, 'PrivateAreaMasterPast', 0,  -192.71, -0.27,  -168.40, -1.05, 0, 0, null),
    (27542, 1001282, 'man200_uncomfortable_brute', 181, 'PrivateAreaMasterPast', 0,  -194.09, -0.27,  -168.40,  1.05, 0, 0, null),
    (27543, 1090160, 'man200_door_exit', 181, 'PrivateAreaMasterPast', 0,  -209.50,  0.00,  -160.00,  0.00, 0, 0, null), -- entrance doors: back out to Ul'dah
    (27544, 1090161, 'man200_door_office_w', 181, 'PrivateAreaMasterPast', 0,  -135.50,  1.00,  -160.00,  0.00, 0, 0, null), -- office door, hall side
    (27545, 1090162, 'man200_door_office_e', 181, 'PrivateAreaMasterPast', 0,  -132.50,  1.20,  -160.00,  0.00, 0, 0, null), -- office door, office side
    -- type 1: Together We Stand start
    (27546, 1000843, 'man206_1_minfilia', 181, 'PrivateAreaMasterPast', 1,  -119.30,  1.20,  -160.00, -1.57, 0, 0, null),
    (27547, 1001046, 'man206_1_tataru', 181, 'PrivateAreaMasterPast', 1,  -139.40,  1.00,  -163.60, -0.79, 0, 0, null),
    (27548, 1001228, 'man206_1_satzfloh', 181, 'PrivateAreaMasterPast', 1,  -145.40,  1.00,  -157.00,  3.08, 0, 0, null),
    (27549, 1001229, 'man206_1_percevains', 181, 'PrivateAreaMasterPast', 1,  -145.00,  1.00,  -163.00, -0.07, 0, 0, null),
    (27550, 1001230, 'man206_1_una_tayuun', 181, 'PrivateAreaMasterPast', 1,  -153.50,  0.10,  -161.50,  1.43, 0, 0, null),
    (27551, 1001378, 'man206_1_seranelien', 181, 'PrivateAreaMasterPast', 1,  -199.70,  0.00,  -156.00,  1.57, 0, 0, null),
    (27552, 1001375, 'man206_1_godfrey', 181, 'PrivateAreaMasterPast', 1,  -198.30,  0.00,  -156.00, -1.57, 0, 0, null),
    (27553, 1001373, 'man206_1_sahja_zhwan', 181, 'PrivateAreaMasterPast', 1,  -199.70,  0.00,  -164.00,  1.57, 0, 0, null),
    (27554, 1001374, 'man206_1_nenekani', 181, 'PrivateAreaMasterPast', 1,  -198.30,  0.00,  -164.00, -1.57, 0, 0, null),
    (27555, 1001376, 'man206_1_fenana', 181, 'PrivateAreaMasterPast', 1,  -195.10,  0.10,  -152.00,  1.57, 0, 0, null),
    (27556, 1001377, 'man206_1_nonoru', 181, 'PrivateAreaMasterPast', 1,  -193.70,  0.10,  -152.00, -1.57, 0, 0, null),
    (27557, 1090160, 'man206_1_door_exit', 181, 'PrivateAreaMasterPast', 1,  -209.50,  0.00,  -160.00,  0.00, 0, 0, null),
    (27558, 1090161, 'man206_1_door_office_w', 181, 'PrivateAreaMasterPast', 1,  -135.50,  1.00,  -160.00,  0.00, 0, 0, null),
    (27559, 1090162, 'man206_1_door_office_e', 181, 'PrivateAreaMasterPast', 1,  -132.50,  1.20,  -160.00,  0.00, 0, 0, null),
    -- type 2: Together We Stand after accepting
    (27560, 1000843, 'man206_2_minfilia', 181, 'PrivateAreaMasterPast', 2,  -119.30,  1.20,  -160.00, -1.57, 0, 0, null),
    (27561, 1001046, 'man206_2_tataru', 181, 'PrivateAreaMasterPast', 2,  -139.40,  1.00,  -163.60, -0.79, 0, 0, null),
    (27562, 1001228, 'man206_2_satzfloh', 181, 'PrivateAreaMasterPast', 2,  -145.40,  1.00,  -157.00,  3.08, 0, 0, null),
    (27563, 1001229, 'man206_2_percevains', 181, 'PrivateAreaMasterPast', 2,  -145.00,  1.00,  -163.00, -0.07, 0, 0, null),
    (27564, 1001230, 'man206_2_una_tayuun', 181, 'PrivateAreaMasterPast', 2,  -153.50,  0.10,  -161.50,  1.43, 0, 0, null),
    (27565, 1001378, 'man206_2_seranelien', 181, 'PrivateAreaMasterPast', 2,  -199.70,  0.00,  -156.00,  1.57, 0, 0, null),
    (27566, 1001375, 'man206_2_godfrey', 181, 'PrivateAreaMasterPast', 2,  -198.30,  0.00,  -156.00, -1.57, 0, 0, null),
    (27567, 1001373, 'man206_2_sahja_zhwan', 181, 'PrivateAreaMasterPast', 2,  -199.70,  0.00,  -164.00,  1.57, 0, 0, null),
    (27568, 1001374, 'man206_2_nenekani', 181, 'PrivateAreaMasterPast', 2,  -198.30,  0.00,  -164.00, -1.57, 0, 0, null),
    (27569, 1001376, 'man206_2_fenana', 181, 'PrivateAreaMasterPast', 2,  -195.10,  0.10,  -152.00,  1.57, 0, 0, null),
    (27570, 1001377, 'man206_2_nonoru', 181, 'PrivateAreaMasterPast', 2,  -193.70,  0.10,  -152.00, -1.57, 0, 0, null),
    (27571, 1090160, 'man206_2_door_exit', 181, 'PrivateAreaMasterPast', 2,  -209.50,  0.00,  -160.00,  0.00, 0, 0, null),
    (27572, 1090161, 'man206_2_door_office_w', 181, 'PrivateAreaMasterPast', 2,  -135.50,  1.00,  -160.00,  0.00, 0, 0, null),
    (27573, 1090162, 'man206_2_door_office_e', 181, 'PrivateAreaMasterPast', 2,  -132.50,  1.20,  -160.00,  0.00, 0, 0, null),
    -- type 3: Together We Stand completion
    (27574, 1000843, 'man206_3_minfilia', 181, 'PrivateAreaMasterPast', 3,  -119.30,  1.20,  -160.00, -1.57, 0, 0, null),
    (27575, 1001046, 'man206_3_tataru', 181, 'PrivateAreaMasterPast', 3,  -139.40,  1.00,  -163.60, -0.79, 0, 0, null),
    (27576, 1001228, 'man206_3_satzfloh', 181, 'PrivateAreaMasterPast', 3,  -145.40,  1.00,  -157.00,  3.08, 0, 0, null),
    (27577, 1001229, 'man206_3_percevains', 181, 'PrivateAreaMasterPast', 3,  -145.00,  1.00,  -163.00, -0.07, 0, 0, null),
    (27578, 1001230, 'man206_3_una_tayuun', 181, 'PrivateAreaMasterPast', 3,  -153.50,  0.10,  -161.50,  1.43, 0, 0, null),
    (27579, 1001378, 'man206_3_seranelien', 181, 'PrivateAreaMasterPast', 3,  -199.70,  0.00,  -156.00,  1.57, 0, 0, null),
    (27580, 1001375, 'man206_3_godfrey', 181, 'PrivateAreaMasterPast', 3,  -198.30,  0.00,  -156.00, -1.57, 0, 0, null),
    (27581, 1001373, 'man206_3_sahja_zhwan', 181, 'PrivateAreaMasterPast', 3,  -199.70,  0.00,  -164.00,  1.57, 0, 0, null),
    (27582, 1001374, 'man206_3_nenekani', 181, 'PrivateAreaMasterPast', 3,  -198.30,  0.00,  -164.00, -1.57, 0, 0, null),
    (27583, 1001376, 'man206_3_fenana', 181, 'PrivateAreaMasterPast', 3,  -195.10,  0.10,  -152.00,  1.57, 0, 0, null),
    (27584, 1001377, 'man206_3_nonoru', 181, 'PrivateAreaMasterPast', 3,  -193.70,  0.10,  -152.00, -1.57, 0, 0, null),
    (27585, 1090160, 'man206_3_door_exit', 181, 'PrivateAreaMasterPast', 3,  -209.50,  0.00,  -160.00,  0.00, 0, 0, null),
    (27586, 1090161, 'man206_3_door_office_w', 181, 'PrivateAreaMasterPast', 3,  -135.50,  1.00,  -160.00,  0.00, 0, 0, null),
    (27587, 1090162, 'man206_3_door_office_e', 181, 'PrivateAreaMasterPast', 3,  -132.50,  1.20,  -160.00,  0.00, 0, 0, null);
