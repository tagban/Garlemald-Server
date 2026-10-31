-- Together We Stand (Man206): the Moonspore Grove escort's cast, for
-- SimpleContentMan20601 (run by escort.lua) in an East Shroud (151) content
-- instance.
--
-- The escortee is your own Path companion: one battle npc whose look and name
-- the content script swaps at spawn (the companion classes 1070001+ by skin,
-- and your nickname), so it needs a single class here. The enemies are
-- imperial troopers. Both ride the proven FighterAllyOpeningAttacker class
-- path (a battle npc whose class script lacks the battle tuple crashes the
-- client, the man0l1 chigoe lesson); the troopers wear the trooper's look
-- (2180001) and name (3180001).
--
-- The grove's own spot isn't known, so the sentries stand on a stretch
-- walked north-east of Camp Nine Ivies (heights read in the test client).
--
-- Idempotent: INSERT OR IGNORE on ids. No schema change.

INSERT OR IGNORE INTO "gamedata_actor_class" ("id", "classPath", "displayNameId", "propertyFlags", "eventConditions") VALUES
    (2299901, '/Chara/Npc/Monster/Fighter/FighterAllyOpeningAttacker', 1500024, 0, null), -- escort companion
    (2299902, '/Chara/Npc/Monster/Fighter/FighterAllyOpeningAttacker', 3180001, 0, null); -- imperial trooper

-- Looks: copies of the first companion's (1070001; swapped at spawn anyway)
-- and the imperial trooper's (2180001).
INSERT OR IGNORE INTO "gamedata_actor_appearance"
SELECT 2299901, "base", "size", "hairStyle", "hairHighlightColor", "hairVariation", "faceType", "characteristics",
       "characteristicsColor", "faceEyebrows", "faceIrisSize", "faceEyeShape", "faceNose", "faceFeatures", "faceMouth",
       "ears", "hairColor", "skinColor", "eyeColor", "voice", "mainHand", "offHand", "spMainHand", "spOffHand",
       "throwing", "pack", "pouch", "head", "body", "legs", "hands", "feet", "waist", "neck", "leftEar", "rightEar",
       "leftIndex", "rightIndex", "leftFinger", "rightFinger"
FROM "gamedata_actor_appearance" WHERE "id" = 1070001;
INSERT OR IGNORE INTO "gamedata_actor_appearance"
SELECT 2299902, "base", "size", "hairStyle", "hairHighlightColor", "hairVariation", "faceType", "characteristics",
       "characteristicsColor", "faceEyebrows", "faceIrisSize", "faceEyeShape", "faceNose", "faceFeatures", "faceMouth",
       "ears", "hairColor", "skinColor", "eyeColor", "voice", "mainHand", "offHand", "spMainHand", "spOffHand",
       "throwing", "pack", "pouch", "head", "body", "legs", "hands", "feet", "waist", "neck", "leftEar", "rightEar",
       "leftIndex", "rightIndex", "leftFinger", "rightFinger"
FROM "gamedata_actor_appearance" WHERE "id" = 2180001;

INSERT OR IGNORE INTO "server_battlenpc_pools" ("poolId", "actorClassId", "name", "genusId", "currentJob", "combatSkill", "combatDelay", "combatDmgMult", "aggroType", "immunity", "linkType", "spellListId", "skillListId") VALUES
    (18, 2299901, 'escort_companion', 29, 2, 1, 4200, 1, 0, 0, 0, 0, 0),
    (19, 2299902, 'moonspore_trooper', 29, 2, 1, 4200, 1, 0, 0, 0, 0, 0);

-- The companion is an ally (allegiance 1) sturdy enough to survive a careless
-- fight; the troopers are around the quest's level 22.
INSERT OR IGNORE INTO "server_battlenpc_groups" ("groupId", "poolId", "scriptName", "minLevel", "maxLevel", "respawnTime", "hp", "mp", "dropListId", "allegiance", "spawnType", "animationId", "actorState", "privateAreaName", "privateAreaLevel", "zoneId") VALUES
    (19, 18, 'escort_companion', 22, 22, 0, 800, 0, 0, 1, 1, 0, 0, '', 0, 151),
    (20, 19, 'moonspore_trooper', 20, 22, 0, 300, 0, 0, 0, 1, 0, 0, '', 0, 151);

INSERT OR IGNORE INTO "server_battlenpc_spawn_locations" ("bnpcId", "customDisplayName", "groupId", "positionX", "positionY", "positionZ", "rotation") VALUES
    (52, 'escort_companion', 19, 1714.0, 31.0, -842.0, 2.6),
    (53, 'moonspore_trooper', 20, 1741.0, 29.0, -885.0, 0.0),
    (54, 'moonspore_trooper', 20, 1767.0, 20.5, -903.0, 1.5),
    (55, 'moonspore_trooper', 20, 1788.0, 20.5, -893.0, 1.5),
    (56, 'moonspore_trooper', 20, 1808.0, 26.5, -890.0, -1.5);
