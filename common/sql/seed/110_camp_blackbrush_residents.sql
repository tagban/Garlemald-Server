-- Camp Black Brush residents: the camp's own NPCs, which no seed spawned.
--
-- DftWil already maps Blandhem, Chechedoba and Nomomo to their client
-- default-talk functions (flagged NOT IMPLEMENTED: no spawn row), and the
-- camp master Ludovraint and sub-master Mimina had no spawn either.
-- Positions and facings are the hand-placed ones from Kodama
-- (codeberg.org/redstrate/Kodama, AGPL-3.0, resources/dropins/
-- wil_w0_fld01.json); they agree with DftWil's rough estimates and with
-- the y 200.0 camp floor (seed/109).
--
-- Blandhem, Chechedoba and Nomomo ship stripped in gamedata (classPath '',
-- propertyFlags 0): an actor spawned from a classPath-less class crashes
-- the client, so they get the seed/076 populace recipe. Guarded so a
-- future upstream refresh with real rows wins.
--
-- Idempotent: UPDATE guarded, INSERTs OR IGNORE on id. No schema change.

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
    1000672, -- Blandhem
    1000673, -- Chechedoba
    1001392  -- Nomomo
) AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27400, 1000672, 'blackbrush_blandhem',   170, '', 0,  60.63, 199.70, -460.40,  1.78, 0, 0, null),
    (27401, 1000673, 'blackbrush_chechedoba', 170, '', 0,   7.16, 199.98, -484.64, -1.63, 0, 0, null),
    (27402, 1001392, 'blackbrush_nomomo',     170, '', 0,  24.01, 200.00, -474.95,  2.24, 0, 0, null),
    (27403, 1500073, 'blackbrush_ludovraint', 170, '', 0,  23.25, 200.00, -490.13,  1.36, 0, 0, null),
    (27404, 1500099, 'blackbrush_mimina',     170, '', 0,  25.19, 200.00, -470.38,  1.36, 0, 0, null);
