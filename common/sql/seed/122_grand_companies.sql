-- The Grand Companies: their headquarters' staff, and enlistment through
-- each company's test quest (Com0l1 The Price of Integrity, Com0g1
-- Breaking the Seals, Com0u1 Career Opportunities).
--
-- Maelstrom Command (232), the Adders' Nest (234) and the Hall of Flames
-- (233) share one floor plan: the door at (160, 0, -155), a hall north of
-- it, and a service counter along the east wall (x 168, z -183..-168; the
-- Hall of Flames' sits a little further west, so its staff stand at x 169).
-- The officer, quartermaster and supply officer stand behind the counter; the
-- guide meets you inside the door and the sanction private waits by the
-- benches. The company-leve sergeants (1500222-1500227) are left out: their
-- script has only an outsider line so far.
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    -- Maelstrom Command
    (27680, 1500202, 'gc_l_quartermaster', 232, '', 0, 171.00, 0.00, -180.50, -1.57, 0, 0, null),
    (27681, 1500199, 'gc_l_officer',       232, '', 0, 171.00, 0.00, -175.50, -1.57, 0, 0, null),
    (27682, 1500210, 'gc_l_supply',        232, '', 0, 171.00, 0.00, -170.50, -1.57, 0, 0, null),
    (27683, 1001737, 'gc_l_guide',         232, '', 0, 163.00, 0.00, -166.00,  0.00, 0, 0, null),
    (27684, 1500388, 'gc_l_sanction',      232, '', 0, 157.00, 0.00, -167.00,  1.57, 0, 0, null),
    -- Hall of Flames
    (27685, 1500201, 'gc_u_quartermaster', 233, '', 0, 169.00, 0.00, -180.50, -1.57, 0, 0, null),
    (27686, 1500198, 'gc_u_officer',       233, '', 0, 169.00, 0.00, -175.50, -1.57, 0, 0, null),
    (27687, 1500212, 'gc_u_supply',        233, '', 0, 169.00, 0.00, -170.50, -1.57, 0, 0, null),
    (27688, 1001739, 'gc_u_guide',         233, '', 0, 163.00, 0.00, -166.00,  0.00, 0, 0, null),
    (27689, 1500390, 'gc_u_sanction',      233, '', 0, 157.00, 0.00, -167.00,  1.57, 0, 0, null),
    -- Adders' Nest
    (27690, 1500203, 'gc_g_quartermaster', 234, '', 0, 171.00, 0.00, -180.50, -1.57, 0, 0, null),
    (27691, 1500200, 'gc_g_officer',       234, '', 0, 171.00, 0.00, -175.50, -1.57, 0, 0, null),
    (27692, 1500211, 'gc_g_supply',        234, '', 0, 171.00, 0.00, -170.50, -1.57, 0, 0, null),
    (27693, 1001738, 'gc_g_guide',         234, '', 0, 163.00, 0.00, -166.00,  0.00, 0, 0, null),
    (27694, 1500389, 'gc_g_sanction',      234, '', 0, 157.00, 0.00, -167.00,  1.57, 0, 0, null);

-- The test quests' cast had no class path: Walcher (Wineport), Ailith
-- (Gridania) and Taylor (Ul'dah).
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
WHERE "id" IN (1001629, 1001628, 1001447) AND ("classPath" = '' OR "classPath" IS NULL);

-- Urianger's camps, walked into to meet him (one per company's quest).
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
WHERE "id" IN (1090321, 1090322, 1090323) AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    -- The Price of Integrity: Walcher by the Wineport hamlet; Urianger's
    -- camp on the sea cliffs east of it (where cutscene COM0L105 is shot).
    (27695, 1001629, 'com0l1_walcher',       130, '', 0,  623.00, 55.30, -1144.00, 0.00, 0, 0, null),
    (27696, 1090321, 'com0l1_urianger_camp', 130, '', 0, 1500.00, 55.00, -1300.00, 0.00, 0, 0, null),
    -- Breaking the Seals: Ailith outside Quarrymill; Urianger's glyphs
    -- southwest of it (cutscene COM0G105).
    (27697, 1001628, 'com0g1_ailith',        154, '', 0, 1400.00,  0.00,   940.00, 2.36, 0, 0, null),
    (27698, 1090322, 'com0g1_urianger_site', 154, '', 0, 1200.00,  0.00,  1090.00, 0.00, 0, 0, null),
    -- Career Opportunities: Taylor on the Horizon's Edge shore; Urianger
    -- just south of him (cutscene COM0U105).
    (27699, 1001447, 'com0u1_taylor',        172, '', 0, -1730.00, 58.00,   90.00, 0.25, 0, 0, null),
    (27700, 1090323, 'com0u1_urianger_docks', 172, '', 0, -1725.00, 57.00,  110.00, 0.00, 0, 0, null);

-- Urianger's familiars: a peiste (Limsa), a drake (Gridania) and an anole
-- (Ul'dah), as the quests' cutscenes show them. Their quest classes had no
-- class path.
UPDATE "gamedata_actor_class" SET "classPath" = '/Chara/Npc/Monster/Basilisk/BasiliskStandard'
WHERE "id" = 6500033 AND ("classPath" = '' OR "classPath" IS NULL);
UPDATE "gamedata_actor_class" SET "classPath" = '/Chara/Npc/Monster/Scalelizard/ScalelizardStandard'
WHERE "id" = 6500034 AND ("classPath" = '' OR "classPath" IS NULL);
UPDATE "gamedata_actor_class" SET "classPath" = '/Chara/Npc/Monster/Raptor/RaptorStandard'
WHERE "id" = 6500035 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (21, 6500033, 'peiste_familiar', 31, 0, 1, 4200, 1, 1, 0, 0, 0, 0),
    (22, 6500034, 'drake_familiar',  30, 0, 1, 4200, 1, 1, 0, 0, 0, 0),
    (23, 6500035, 'anole_familiar',  32, 0, 1, 4200, 1, 1, 0, 0, 0, 0);

INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (23, 21, 'peiste_familiar', 23, 23, 0, 900, 0, 0, 0, 1, 0, 0, '', 0, 130),
    (24, 22, 'drake_familiar',  23, 23, 0, 900, 0, 0, 0, 1, 0, 0, '', 0, 154),
    (25, 23, 'anole_familiar',  23, 23, 0, 900, 0, 0, 0, 1, 0, 0, '', 0, 172);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (61, 'peiste_familiar', 23, 1512.0, 55.0, -1299.0, -1.57),
    (62, 'drake_familiar',  24, 1206.0,  0.0,  1090.0, -1.57),
    (63, 'anole_familiar',  25, -1719.0, 57.0,  110.0, -1.57);
