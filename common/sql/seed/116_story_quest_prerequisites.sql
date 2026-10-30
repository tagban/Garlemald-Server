-- The main scenario's prerequisites, so each nation's story hands over.
--
-- The opening quests chain in-script (Man0l0 replaces itself with Man0l1,
-- and so on), but nothing gave out the level 8 quest after the second,
-- or the level 13 one after that: every story row had prerequisite 0 and
-- the offers skipped story quests. Their scripts already name a giver at
-- SEQ_ACCEPT (Baderon, Miounne, Momodi); with a prerequisite set, the
-- quest is offered there once the one before it is complete and the
-- player has the level.
--
-- Fade to White (Man200, 110013) follows any of the three nations'
-- level 13 quests, which one column can't say, and its script names no
-- giver, so it is left alone. Together We Stand (Man206) follows it.
--
-- Idempotent: plain UPDATEs. No schema change.

UPDATE "gamedata_quests" SET "prerequisite" = 110002 WHERE "id" = 110003; -- Legends Adrift after Treasures of the Main
UPDATE "gamedata_quests" SET "prerequisite" = 110003 WHERE "id" = 110004; -- Never the Twain Shall Meet after Legends Adrift
UPDATE "gamedata_quests" SET "prerequisite" = 110006 WHERE "id" = 110007; -- Whispers in the Wood after Souls Gone Wild
UPDATE "gamedata_quests" SET "prerequisite" = 110007 WHERE "id" = 110008; -- Beckon of the Elementals after Whispers in the Wood
UPDATE "gamedata_quests" SET "prerequisite" = 110010 WHERE "id" = 110011; -- Golden Sacrifices after Court in the Sands
UPDATE "gamedata_quests" SET "prerequisite" = 110011 WHERE "id" = 110012; -- Calamity Cometh after Golden Sacrifices
UPDATE "gamedata_quests" SET "prerequisite" = 110013 WHERE "id" = 110014; -- Together We Stand after Fade to White
