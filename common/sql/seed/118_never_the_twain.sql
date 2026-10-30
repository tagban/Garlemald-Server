-- Never the Twain Shall Meet (Man2l0, Limsa Lominsa's level 13 story):
-- the God's Grip trigger.
--
-- Seq 050 waits on trigger 1090086, which had no classPath and was never
-- spawned, so the quest stopped there. The journal puts that step on the
-- same spot as the outcrop push of Seq 037 (1090082, spawned by an earlier
-- seed), so it stands there with the same 6-yalm circle, enabled only
-- while the quest needs it.
--
-- Idempotent: UPDATE guarded, INSERT OR IGNORE on id. No schema change.

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
WHERE "id" = 1090086 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27665, 1090086, 'man2l0_gods_grip_push', 128, '', 0,   218.60, 21.00,  1176.60,  0.00, 0, 0, null); -- Seq 050
