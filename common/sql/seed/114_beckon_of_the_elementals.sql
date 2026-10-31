-- Beckon of the Elementals (Man2g0, Gridania's level 13 story): its echo
-- instances, triggers and cast.
--
-- The quest moves the player through Gridania's PrivateAreaMasterPast
-- types 0 (Quiver's Hold before the ranging), 10 (Stillglade Fane in the
-- echo), 12 (Mih Khetto Amphitheatre) and West Shroud type 0 (the clearing
-- by Lichenweed). None was registered and nobody stood in them.
--
-- Each step's spot is its journal map marker: O-App-Pesi in Quiver's Hold
-- (Seq 003), Soileine at the Fane (015), a trigger at the Fane's door
-- (020; the trigger stands at its doors), Fye on the path east of it (025), O-App-Pesi inside (030), the
-- trigger below the amphitheatre (035), Fye in it (040), and the clearing
-- the script already warps to (045). Everyone stands on floor checked in
-- the test client; the amphitheatre crowd fills the benches facing the
-- stage. Type 10 is this seed's choice: the script named no type for the
-- Fane echo.
--
-- The amphitheatre trigger (1090279, spawned in town by seed/031) had a
-- talk condition but no push, so the quest's push could never fire: it
-- gets a 5-yalm circle. The Fane door trigger and the clearing's exit had
-- id 0 in the script; they borrow stripped trigger classes 1090280 and
-- 1090281 (classPath '', no spawn, no other reference). Like every actor
-- here that shipped without a classPath (which crashes the client), the
-- people get PopulaceStandard rows.
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

INSERT INTO "server_zones_privateareas"
    ("parentZoneId", "className", "privateAreaName", "privateAreaType", "dayMusic", "nightMusic", "battleMusic")
SELECT a.zone, '/Area/PrivateArea/PrivateAreaMasterPast', 'PrivateAreaMasterPast', a.type, 0, 0, 0
FROM (SELECT 206 AS zone, 0 AS type UNION ALL SELECT 206, 10 UNION ALL SELECT 206, 12 UNION ALL SELECT 153, 0) AS a
WHERE NOT EXISTS (SELECT 1 FROM "server_zones_privateareas" p
                  WHERE p."parentZoneId" = a.zone AND p."privateAreaName" = 'PrivateAreaMasterPast'
                    AND p."privateAreaType" = a.type);

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
    1000016, 1000018, 1000022, 1000023, 1000024, -- Ngolbb, Burchard, Ursbaen, Handeloup, Grinnaux
    1000743, 1000744, 1000745, 1000746, 1000747, -- the conjurers and archers outside the Fane
    1000748, 1000749,                            -- the conjurers inside
    1000754, 1000755, 1000756, 1000757,          -- Niall and the amphitheatre crowd
    1000824, 1000825, 1000826,
    1001485, 1001486, 1001487, 1001488, 1001489
) AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "propertyFlags" = 1,
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
WHERE "id" = 1090280 AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "propertyFlags" = 1,
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "15.0",
      "outwards": "true",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090281 AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "gamedata_actor_class" SET
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "5.0",
      "outwards": "false",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090279 AND "eventConditions" NOT LIKE '%pushWithCircle%';

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27605, 1000463, 'man2g0_0_nonolato', 206, 'PrivateAreaMasterPast', 0,    232.88, 12.46,  -1268.94, -1.38, 0, 1015, null), -- Nonolato where he stands in town
    (27606, 1000033, 'man2g0_0_o_app_pesi', 206, 'PrivateAreaMasterPast', 0,    234.41, 12.00,  -1274.59, -0.56, 0, 0, null), -- O-App-Pesi, who offers the ranging
    (27607, 1000743, 'man2g0_10_wise_looking_conjurer', 206, 'PrivateAreaMasterPast', 10,   -323.00,  7.50,  -1697.50,  2.46, 0, 0, null),
    (27608, 1000744, 'man2g0_10_disquieted_lancer', 206, 'PrivateAreaMasterPast', 10,   -324.50,  7.50,  -1702.50,  1.19, 0, 0, null),
    (27609, 1000745, 'man2g0_10_enthusiastic_archer', 206, 'PrivateAreaMasterPast', 10,   -328.50,  7.50,  -1697.00,  2.00, 0, 0, null),
    (27610, 1000746, 'man2g0_10_embittered_archer', 206, 'PrivateAreaMasterPast', 10,   -329.00,  7.50,  -1691.50,  2.39, 0, 0, null),
    (27611, 1000747, 'man2g0_10_disconcerted_conjurer', 206, 'PrivateAreaMasterPast', 10,   -332.00,  7.00,  -1700.00,  1.64, 0, 0, null),
    (27612, 1000014, 'man2g0_10_fye', 206, 'PrivateAreaMasterPast', 10,   -326.41,  7.50,  -1694.23, -1.87, 0, 0, null), -- Fye, Seq 025
    (27613, 1090280, 'man2g0_10_fane_door_trigger', 206, 'PrivateAreaMasterPast', 10,   -337.50,  8.00,  -1672.50,  0.00, 0, 0, null), -- Seq 020: the Fane's doors
    (27614, 1000033, 'man2g0_10_o_app_pesi', 206, 'PrivateAreaMasterPast', 10,   -354.00,  6.23,  -1698.16,  1.58, 0, 0, null),
    (27615, 1000234, 'man2g0_10_soileine', 206, 'PrivateAreaMasterPast', 10,   -350.00,  6.22,  -1701.44,  1.27, 0, 0, null),
    (27616, 1000748, 'man2g0_10_silky_haired_conjurer', 206, 'PrivateAreaMasterPast', 10,   -352.00,  6.22,  -1704.00,  1.13, 0, 0, null),
    (27617, 1000749, 'man2g0_10_enigmatic_conjurer', 206, 'PrivateAreaMasterPast', 10,   -356.00,  6.22,  -1702.00,  1.35, 0, 0, null),
    (27618, 1000014, 'man2g0_12_fye', 206, 'PrivateAreaMasterPast', 12,    -96.46,  9.96,  -1639.24,  0.00, 0, 0, null), -- Fye, Seq 040
    (27619, 1000009, 'man2g0_12_yda', 206, 'PrivateAreaMasterPast', 12,   -100.46, 10.90,  -1639.23,  0.00, 0, 0, null),
    (27620, 1000010, 'man2g0_12_papalymo', 206, 'PrivateAreaMasterPast', 12,    -92.46, 10.90,  -1639.24,  0.00, 0, 0, null),
    (27621, 1000015, 'man2g0_12_tkebbe', 206, 'PrivateAreaMasterPast', 12,    -83.65, 11.55,  -1631.77,  3.14, 0, 0, null),
    (27622, 1000016, 'man2g0_12_ngolbb', 206, 'PrivateAreaMasterPast', 12,   -102.56, 11.30,  -1631.46,  3.14, 0, 0, null),
    (27623, 1000017, 'man2g0_12_farrimond', 206, 'PrivateAreaMasterPast', 12,   -108.56, 11.62,  -1631.44,  3.14, 0, 0, null),
    (27624, 1000018, 'man2g0_12_burchard', 206, 'PrivateAreaMasterPast', 12,   -105.56, 11.28,  -1631.44,  3.14, 0, 0, null),
    (27625, 1000022, 'man2g0_12_ursbaen', 206, 'PrivateAreaMasterPast', 12,    -86.56, 11.29,  -1631.44,  3.14, 0, 0, null),
    (27626, 1000023, 'man2g0_12_handeloup', 206, 'PrivateAreaMasterPast', 12,    -89.56, 11.30,  -1631.43,  3.14, 0, 0, null),
    (27627, 1000024, 'man2g0_12_grinnaux', 206, 'PrivateAreaMasterPast', 12,    -84.11, 11.97,  -1627.66,  3.14, 0, 0, null),
    (27628, 1000237, 'man2g0_12_fufucha', 206, 'PrivateAreaMasterPast', 12,   -105.56, 11.96,  -1627.07,  3.14, 0, 0, null),
    (27629, 1000562, 'man2g0_12_wispily_whiskered_woodworker', 206, 'PrivateAreaMasterPast', 12,    -86.71, 11.96,  -1626.99,  3.14, 0, 0, null),
    (27630, 1000754, 'man2g0_12_niall', 206, 'PrivateAreaMasterPast', 12,   -108.65, 12.48,  -1626.77,  3.14, 0, 0, null),
    (27631, 1000755, 'man2g0_12_respectable_roegadyn', 206, 'PrivateAreaMasterPast', 12,   -102.63, 11.96,  -1626.77,  3.14, 0, 0, null),
    (27632, 1000756, 'man2g0_12_aging_elezen', 206, 'PrivateAreaMasterPast', 12,    -89.58, 11.96,  -1626.75,  3.14, 0, 0, null),
    (27633, 1000757, 'man2g0_12_urbane_elezen', 206, 'PrivateAreaMasterPast', 12,    -99.56, 11.79,  -1626.44,  3.14, 0, 0, null),
    (27634, 1000824, 'man2g0_12_sugarstrung_schoolgirl', 206, 'PrivateAreaMasterPast', 12,    -92.56, 11.77,  -1626.44,  3.14, 0, 0, null),
    (27635, 1000825, 'man2g0_12_underprivileged_urchin', 206, 'PrivateAreaMasterPast', 12,    -84.03, 13.38,  -1622.20,  3.14, 0, 0, null),
    (27636, 1000826, 'man2g0_12_squealing_sprat', 206, 'PrivateAreaMasterPast', 12,   -108.32, 13.40,  -1622.19,  3.14, 0, 0, null),
    (27637, 1000827, 'man2g0_12_deserted_daughter', 206, 'PrivateAreaMasterPast', 12,   -102.65, 13.40,  -1621.77,  3.14, 0, 0, null),
    (27638, 1000828, 'man2g0_12_troublesome_tomboy', 206, 'PrivateAreaMasterPast', 12,   -105.65, 13.40,  -1621.75,  3.14, 0, 0, null),
    (27639, 1001485, 'man2g0_12_overanimated_hyur', 206, 'PrivateAreaMasterPast', 12,    -86.61, 13.40,  -1621.68,  3.14, 0, 0, null),
    (27640, 1001486, 'man2g0_12_good_natured_goodwife', 206, 'PrivateAreaMasterPast', 12,    -89.56, 13.40,  -1621.48,  3.14, 0, 0, null),
    (27641, 1001487, 'man2g0_12_fastidious_fellow', 206, 'PrivateAreaMasterPast', 12,    -99.56, 13.31,  -1621.44,  3.14, 0, 0, null),
    (27642, 1001488, 'man2g0_12_merry_old_matron', 206, 'PrivateAreaMasterPast', 12,    -92.56, 13.33,  -1621.44,  3.14, 0, 0, null),
    (27643, 1001489, 'man2g0_12_well_groomed_woman', 206, 'PrivateAreaMasterPast', 12,    -96.46,  9.99,  -1634.24,  3.14, 0, 0, null),
    (27644, 1000009, 'man2g0_0_yda', 153, 'PrivateAreaMasterPast', 0,  -1950.56,  0.06,   -893.95,  1.36, 0, 0, null),
    (27645, 1000010, 'man2g0_0_papalymo', 153, 'PrivateAreaMasterPast', 0,  -1950.56,  0.80,   -890.50,  2.22, 0, 0, null),
    (27646, 1090281, 'man2g0_0_west_shroud_exit', 153, 'PrivateAreaMasterPast', 0,  -1947.01,  0.06,   -893.22,  0.00, 0, 0, null); -- Seq 045: leave the clearing (15 yalms) to wake
