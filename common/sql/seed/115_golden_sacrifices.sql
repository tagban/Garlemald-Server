-- Golden Sacrifices (Man1u0, Ul'dah's level 8 story): its echo instances,
-- triggers and cast. The quest had no script and nothing placed for it.
--
-- Each step's spot is its journal map marker, read from the client's
-- journal map: Momodi at the Quicksand, Gagaruna in the Platinum Mirage's
-- lobby, a trigger by the stairs in the Pugilists' hall (the marker is the
-- door at their foot, which can't be walked into), Thancred outside the
-- city's north wall (where the client marks the Mirage's Paradise room),
-- Deaustie at Sunsilk Tapestries, F'lhaminn's rehearsal spot under the
-- cliffs north of Camp Black Brush, and Yayake at Arrzaneth Ossuary for
-- the funeral and Mumuepo (she stands behind the guild counter, so the
-- trigger and Niellefresne stand in the hall in front of it). Qoqoba and Mumuepo have no NPC names in the
-- client (they live only in the cutscenes), so their steps are triggers.
--
-- Echoes: Ul'dah PrivateAreaMasterPast type 5 (Paradise: Thancred,
-- Niellefresne, Greinfarr, Corguevais) and Central Thanalan type 0
-- (F'lhaminn and Ascilia at the rehearsal spot). Both types are this
-- seed's choice; neither was registered.
--
-- The triggers borrow stripped classes 1090286-1090288 (classPath '', no
-- spawn, no other reference) and get push circles, disabled until the
-- quest turns them on. The cast reuses Court in the Sands' classes, which
-- carry their appearance; that quest is done before this one starts.
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

INSERT INTO "server_zones_privateareas"
    ("parentZoneId", "className", "privateAreaName", "privateAreaType", "dayMusic", "nightMusic", "battleMusic")
SELECT a.zone, '/Area/PrivateArea/PrivateAreaMasterPast', 'PrivateAreaMasterPast', a.type, 0, 0, 0
FROM (SELECT 175 AS zone, 5 AS type UNION ALL SELECT 170, 0) AS a
WHERE NOT EXISTS (SELECT 1 FROM "server_zones_privateareas" p
                  WHERE p."parentZoneId" = a.zone AND p."privateAreaName" = 'PrivateAreaMasterPast'
                    AND p."privateAreaType" = a.type);

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "propertyFlags" = 1,
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
WHERE "id" = 1090286 AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "propertyFlags" = 1,
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "10.0",
      "outwards": "false",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090287 AND ("classPath" = '' OR "classPath" IS NULL);

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
WHERE "id" = 1090288 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27647, 1090286, 'man1u0_mirage_stairs_trigger', 175, '', 0,  -159.50, 188.70,   116.00,  0.00, 0, 0, null), -- Seq 010: below the stairs, on the way to the door at their foot
    (27648, 1000948, 'man1u0_5_thancred', 175, 'PrivateAreaMasterPast', 5,  -127.40, 200.00,  -158.40,  3.14, 0, 0, null), -- Seq 015
    (27649, 1000037, 'man1u0_5_niellefresne', 175, 'PrivateAreaMasterPast', 5,  -124.40, 200.00,  -159.40, -1.57, 0, 0, null),
    (27650, 1000039, 'man1u0_5_greinfarr', 175, 'PrivateAreaMasterPast', 5,  -130.40, 200.00,  -159.40,  1.57, 0, 0, null),
    (27651, 1001054, 'man1u0_5_corguevais', 175, 'PrivateAreaMasterPast', 5,  -124.90, 200.00,  -162.40, -0.79, 0, 0, null),
    (27652, 1090287, 'man1u0_rehearsal_trigger', 170, '', 0,   262.10, 216.34,  -867.70,  0.00, 0, 0, null), -- Seq 030: F'lhaminn's rehearsal spot
    (27653, 1000842, 'man1u0_0_flhaminn', 170, 'PrivateAreaMasterPast', 0,   257.80, 216.34,  -867.80,  1.73, 0, 0, null),
    (27654, 1000042, 'man1u0_0_ascilia', 170, 'PrivateAreaMasterPast', 0,   260.00, 216.34,  -866.50,  2.36, 0, 0, null), -- Seq 035
    (27655, 1000037, 'man1u0_ossuary_niellefresne', 209, '', 0,  -291.50, 206.10,   210.50, -2.76, 0, 0, null), -- Seq 055: lurking after the funeral
    (27656, 1090288, 'man1u0_ossuary_trigger', 209, '', 0,  -292.90, 206.10,   214.00,  0.00, 0, 0, null); -- Seq 050 and 060: the funeral, then Mumuepo; in front of the counter
