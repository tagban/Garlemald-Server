-- The aethernet gates no seed spawned: Limsa's seven and four of Ul'dah's.
--
-- A gate is a mini aetheryte (1200288, notices only) with a Grand Company
-- warp private beside it (PopulaceCompanyWarp): talking to the private
-- opens the town's aethernet menu. PopulaceCompanyWarp.lua already lists
-- every private and each gate's arrival point, and marks these eleven
-- privates as missing; Gridania's six gates and two of Ul'dah's were
-- spawned (seed/031), Limsa had none.
--
-- No source has the retail spots (Kodama's dropins have the same two
-- Ul'dah privates as seed/031), so each gate is placed from its arrival
-- point the way the spawned ones sit: Gridania's arrivals face their
-- mini aetheryte about 3 yalms ahead, with the private a yalm beside it
-- facing back (arrival facing + pi, within ~0.15 rad for five of six).
-- Heights are the arrival's; a gate on a slope may need a hand fix.
--
-- Storm Private Holt (1500339) and Flame Private Yar (1500338) ship
-- stripped in gamedata (classPath ''): a classPath-less actor crashes the
-- client, so they get their siblings' PopulaceCompanyWarp row. Guarded so
-- a future upstream refresh with real rows wins.
--
-- Idempotent: UPDATE guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceCompanyWarp',
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
    1500338, -- Flame Private Yar
    1500339  -- Storm Private Holt
) AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    -- Limsa Lominsa (gate 8, Zephyr Gate, is an arrival only)
    (27500, 1200288, 'aethernet_gardner_lim', 230, '', 0, -426.00,  42.00, 369.64,  0.67, 0, 0, null), -- 1 Aetheryte Plaza
    (27501, 1500321, 'storm_private_gardner', 230, '', 0, -426.79,  42.00, 370.26,  0.67, 0, 0, null),
    (27502, 1200288, 'aethernet_rich_lim',    133, '', 0, -438.89,  40.00, 237.25, -2.85, 0, 0, null), -- 2 Drowning Wench
    (27503, 1500331, 'storm_private_rich',    133, '', 0, -437.94,  40.00, 236.97, -2.85, 0, 0, null),
    (27504, 1200288, 'aethernet_potter_lim',  230, '', 0, -497.38,  43.62,  63.72, -2.89, 0, 0, null), -- 3 The Bismarck
    (27505, 1500323, 'storm_private_potter',  230, '', 0, -496.41,  43.62,  63.47, -2.89, 0, 0, null),
    (27506, 1200288, 'aethernet_hunt_lim',    230, '', 0, -761.62,  12.00, 241.35,  2.27, 0, 0, null), -- 4 Ferry Docks
    (27507, 1500330, 'storm_private_hunt',    230, '', 0, -760.98,  12.00, 242.11,  2.27, 0, 0, null),
    (27508, 1200288, 'aethernet_abel_lim',    230, '', 0, -620.62,   4.00, 368.82, -1.41, 0, 0, null), -- 5 Fisherman's Bottom
    (27509, 1500322, 'storm_private_abel',    230, '', 0, -620.79,   4.00, 367.84, -1.41, 0, 0, null),
    (27510, 1200288, 'aethernet_stone_lim',   230, '', 0, -525.36,  18.00, 170.74, -0.06, 0, 0, null), -- 6 The Octant
    (27511, 1500332, 'storm_private_stone',   230, '', 0, -526.36,  18.00, 170.68, -0.06, 0, 0, null),
    (27512, 1200288, 'aethernet_holt_lim',    133, '', 0, -233.83,  12.00, 195.69,  2.36, 0, 0, null), -- 7 Procession of Terns
    (27513, 1500339, 'storm_private_holt',    133, '', 0, -233.13,  12.00, 196.40,  2.36, 0, 0, null),
    -- Ul'dah (gates 1 and 5 are seed/031's; 7 and 8, the Gates of Nald and Thal, are arrivals only)
    (27514, 1200288, 'aethernet_tanner_uld',  175, '', 0,  -37.92, 192.00,  39.78,  2.65, 0, 0, null), -- 2 Quicksand
    (27515, 1500337, 'flame_private_tanner',  175, '', 0,  -37.04, 192.00,  40.25,  2.65, 0, 0, null),
    (27516, 1200288, 'aethernet_morning_uld', 209, '', 0, -192.14, 230.00, 206.47, -0.28, 0, 0, null), -- 3 Frondale's Phrontistery
    (27517, 1500329, 'flame_private_morning', 209, '', 0, -193.10, 230.00, 206.19, -0.28, 0, 0, null),
    (27518, 1200288, 'aethernet_covey_uld',   209, '', 0,  -63.11, 200.00, 258.59,  1.87, 0, 0, null), -- 4 Onyx Lane
    (27519, 1500336, 'flame_private_covey',   209, '', 0,  -62.82, 200.00, 259.55,  1.87, 0, 0, null),
    (27520, 1200288, 'aethernet_yar_uld',     209, '', 0, -263.80, 202.00, 203.70,  0.01, 0, 0, null), -- 6 Arrzaneth Ossuary
    (27521, 1500338, 'flame_private_yar',     209, '', 0, -264.80, 202.00, 203.71,  0.01, 0, 0, null);
