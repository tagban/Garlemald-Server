-- Together We Stand (Man206): the Camp Nine Ivies trigger, and a push
-- circle for the Gridania meeting point.
--
-- The Gridania trigger by the aetheryte plaza (1090255, Seq 010, spawned
-- by an earlier seed) had a talk condition but no push, so walking up to
-- your companion there did nothing: it gets a 5-yalm circle.
--
-- The script named its duty trigger with the placeholder class id 1, so
-- nothing could start the Moonspore Grove duty. The escort itself is a
-- duty this server can't run yet; its scenes play on this trigger at the
-- camp instead (the journal marks the camp for the step). It borrows the
-- stripped class 1090293 (classPath '', no spawn, no other reference) and
-- stands on the slope north of the aetheryte with a 5-yalm push circle,
-- enabled only while the quest needs it.
--
-- Idempotent: UPDATE guarded, INSERT OR IGNORE on id. No schema change.

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
WHERE "id" = 1090293 AND ("classPath" = '' OR "classPath" IS NULL);

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
WHERE "id" = 1090255 AND "eventConditions" NOT LIKE '%pushWithCircle%';

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27666, 1090293, 'man206_nine_ivies_trigger', 151, '', 0,  1712.00, 30.00,  -848.00,  0.00, 0, 0, null); -- Seq 015 and 025
