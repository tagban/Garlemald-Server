-- Shadow of the Raven (Gcg103), the Wood Wailers' ranging and the burning of
-- the West Shroud (scripts/lua/quests/gcg/gcg103.lua):
--
-- * Elder Seedseer Kan-E-Senna at Stillglade Fane (Gridania, zone 206),
--   among the conjurers on the upper floor, and O-App-Pesi on the lower
--   floor beside Brother Zerig. The other O-App-Pesi spawns at the Fane stand
--   in man2g0's past (PrivateAreaMasterPast), out of sight of the open city.
-- * Grand Serpent Marshal Brookstone in the Adders' Nest (zone 234), on the
--   hall floor.
-- * The ranging ground south of Camp Crimson Bark (West Shroud, zone 153),
--   walked into to start the duty. Its place comes from the bombardment cut
--   scene (gc01g310), whose cast stands around (-1300..-1322, 0, -217..-236).
-- * The magitek war machine (vanguard F-I), spawned by the duty
--   (SimpleContentGcg10301).
--
-- Heights checked in the test client. Kan-E-Senna and Brookstone ship
-- stripped in gamedata (classPath '') and get PopulaceStandard. Gcg103
-- follows Two Vans are Better than One (Gcg102).
--
-- Idempotent: UPDATEs guarded, INSERTs OR IGNORE on id. No schema change.

UPDATE "gamedata_quests" SET "prerequisite" = 111627
WHERE "id" = 111629 AND "prerequisite" = 0;

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
WHERE "id" IN (1001569, 1060025)
  AND ("classPath" = '' OR "classPath" IS NULL);

-- The ranging ground.
UPDATE "gamedata_actor_class" SET
    "classPath" = '/Chara/Npc/Populace/PopulaceStandard',
    "eventConditions" = '{
  "pushWithCircleEventConditions": [
    {
      "isEnabled": "false",
      "radius": "8.0",
      "outwards": "false",
      "silent": "false",
      "conditionName": "pushDefault"
    }
  ]
}'
WHERE "id" = 1090336 AND ("classPath" = '' OR "classPath" IS NULL);

INSERT OR IGNORE INTO "server_spawn_locations"
    ("id", "actorClassId", "uniqueId", "zoneId", "privateAreaName", "privateAreaLevel",
     "positionX", "positionY", "positionZ", "rotation", "actorState", "animationId", "customDisplayName")
VALUES
    (27804, 1001569, 'gcg103_kan_e_senna',      206, '', 0,  -340.50,   6.82, -1701.00,  1.57, 0, 0, null),
    (27805, 1060025, 'gcg103_brookstone',       234, '', 0,   157.00,   0.00,  -178.00,  1.57, 0, 0, null),
    (27806, 1090336, 'gcg103_ranging',          153, '', 0, -1310.00,   0.00,  -228.00,  0.00, 0, 0, null),
    (27807, 1000033, 'gcg103_o_app_pesi',       206, '', 0,  -356.50,   6.23, -1697.00,  1.57, 0, 0, null);

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (30107, 2209002, 'Magitek Vanguard F-I', 29, 0, 1, 4600, 1.2, 1, 0, 0, 0, 0);

-- spawnType 1 keeps it out of the open world: the duty spawns it.
INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (30115, 30107, 'gcg103_war_machine', 45, 45, 0, 6000, 0, 0, 0, 1, 0, 0, '', 0, 153);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (3522, 'gcg103_war_machine', 30115, -1318.0, 0.0, -236.0, 0.79);
