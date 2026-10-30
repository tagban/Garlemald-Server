-- Grand Company recruit missions (Com0x4): the cast, field triggers and
-- imperial soldiers for Engineering Victory (Com0l4) and The Mail Must Get
-- Through (Com0g4).
--
-- Places are read from the quests' dialogue and checked for ground in the
-- test client: the canyon east of Zelma's Run (Upper La Noscea) and a glade
-- northwest of Gridania (Central Shroud). Millers' Glade's and Little Ala
-- Mhigo's spots aren't known, so the Garlond Ironworks party waits at Camp
-- Glory in the Coerthas eastern lowlands, and Radulf at the south edge of
-- Camp Drybone. The
-- soldiers are the imperial troopers of seed 121 (pool 19).
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

-- Ebrelnaux, Nymiene, Aergfloh (Garlond Ironworks) and Radulf had no class
-- path.
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
WHERE "id" IN (1060011, 1001578, 1001579, 1001334) AND ("classPath" = '' OR "classPath" IS NULL);

-- The canyon and the rite site, walked into to start each fight.
UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
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
WHERE "id" IN (1090324, 1090325) AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27701, 1090324, 'com0l4_canyon',       135, '', 0,   -45.00,  49.00, -1443.00,  0.00, 0, 0, null),
    (27702, 1060011, 'com0l4_ebrelnaux',    145, '', 0,  1505.00, 206.00,   778.00, -1.57, 0, 0, null),
    (27703, 1001578, 'com0l4_nymiene',      145, '', 0,  1494.00, 206.00,   781.00,  2.36, 0, 0, null),
    (27704, 1001579, 'com0l4_aergfloh',     145, '', 0,  1489.00, 206.00,   776.00,  1.57, 0, 0, null),
    (27705, 1090325, 'com0g4_rite_site',    150, '', 0,  -336.00,   6.00,  -863.00,  0.00, 0, 0, null),
    (27706, 1001334, 'com0g4_radulf',       171, '', 0,  1255.00, 264.00,  -528.00,  3.14, 0, 0, null);

INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (26, 19, 'canyon_imperial', 23, 24, 0, 600, 0, 0, 0, 1, 0, 0, '', 0, 135),
    (27, 19, 'rite_imperial',   23, 24, 0, 600, 0, 0, 0, 1, 0, 0, '', 0, 150);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (64, 'canyon_imperial', 26,  -28.0, 49.0, -1438.0, -1.57),
    (65, 'canyon_imperial', 26,  -24.0, 49.0, -1446.0, -1.57),
    (66, 'canyon_imperial', 26,  -30.0, 49.0, -1451.0, -1.57),
    (67, 'rite_imperial',   27, -325.0,  6.0,  -855.0, -1.57),
    (68, 'rite_imperial',   27, -320.0,  6.0,  -865.0, -1.57),
    (69, 'rite_imperial',   27, -328.0,  6.0,  -872.0, -1.57);

-- The recruit arc is one chain: each mission's dialogue picks up where the
-- one before left off (Com0x5 sends you to the inauguration, Com0x6 opens on
-- it, the oath Com0x7 on the "observation" of the other companies). Seed 123
-- had Com0x5 after the oath and Com0x6 straight after the briefing. The oath
-- stays open after the briefing until every company's missions are scripted.
UPDATE "gamedata_quests" SET "prerequisite" = "id" - 1 WHERE "id" IN
    (111405, 111605, 111805) AND "prerequisite" IN (0, "id" + 2);
UPDATE "gamedata_quests" SET "prerequisite" = "id" - 1 WHERE "id" IN
    (111406, 111606, 111806) AND "prerequisite" IN (0, "id" - 3);
