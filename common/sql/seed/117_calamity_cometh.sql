-- Calamity Cometh (Man2u0, Ul'dah's level 13 story): its triggers and
-- cast. The quest had no script and nothing placed for it.
--
-- Spots come from the client's journal map markers: Rururaji at the
-- chocobo stables, a trigger inside Frondale's Phrontistery, Camp Black
-- Brush, the plaza before Arrzaneth Ossuary, and the desert outside
-- Ul'dah's north wall where the coach catches Corguevais (the minemite
-- battle there is skipped; walking onto it plays the aftermath).
-- F'lhaminn's sickroom is
-- the Phrontistery's ward echo (PrivateAreaMasterPast 5), which Court in
-- the Sands already registered; her visitors stand there.
--
-- The Phrontistery trigger fires twice: walking in (Damielliot greets
-- you) and walking out after the sickroom (he collapses). The Black Brush
-- trigger is where Qoqoba waits (she has no NPC name in the client, so
-- her step is a trigger). The triggers borrow stripped classes
-- 1090289-1090292 (classPath '', no spawn, no other reference) and get
-- push circles, disabled until the quest turns them on.
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

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
WHERE "id" = 1090289 AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "propertyFlags" = 1,
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
WHERE "id" = 1090290 AND ("classPath" = '' OR "classPath" IS NULL);

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
WHERE "id" = 1090291 AND ("classPath" = '' OR "classPath" IS NULL);

UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "propertyFlags" = 1,
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
WHERE "id" = 1090292 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27657, 1090289, 'man2u0_phrontistery_trigger', 209, '', 0,  -209.50, 229.50,   289.00,  0.00, 0, 0, null), -- Seq 010 and 020: in, then out
    (27658, 1000842, 'man2u0_5_flhaminn', 209, 'PrivateAreaMasterPast', 5,  -222.00, 229.50,   309.50,  2.60, 0, 0, null), -- Seq 015: the sickroom
    (27659, 1000037, 'man2u0_5_niellefresne', 209, 'PrivateAreaMasterPast', 5,  -219.50, 229.50,   311.50, -2.60, 0, 0, null),
    (27660, 1000039, 'man2u0_5_greinfarr', 209, 'PrivateAreaMasterPast', 5,  -224.50, 229.50,   311.00,  2.20, 0, 0, null),
    (27661, 1090290, 'man2u0_blackbrush_trigger', 170, '', 0,    38.00, 200.00,  -470.00,  0.00, 0, 0, null), -- Seq 030: Qoqoba at Camp Black Brush
    (27662, 1090291, 'man2u0_ossuary_plaza_trigger', 209, '', 0,  -259.00, 202.00,   208.70,  0.00, 0, 0, null), -- Seq 035: before Arrzaneth Ossuary
    (27663, 1000948, 'man2u0_ossuary_thancred', 209, '', 0,  -255.00, 202.00,   203.00,  2.40, 0, 0, null), -- Seq 040
    (27664, 1090292, 'man2u0_battlefield_trigger', 175, '', 0,  -138.00, 205.00,  -163.00,  0.00, 0, 0, null); -- Seq 005: where the coach caught Corguevais
