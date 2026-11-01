-- The oath of sole allegiance (Com0x7) now follows each company's last
-- recruit mission (Com0x6), as the dialogue runs: Cid's account in every
-- Com0x6 ends on "consider well before pledging your loyalty", and the oath
-- opens on what the recruit has observed of the companies. Seed 124 left
-- the oath open straight after the quartermaster's briefing (Com0x3) until
-- every company's missions were scripted; with Com0l6, Com0g6 and Com0u6 in
-- place they are.
--
-- Idempotent: UPDATE guarded on the briefing prerequisite.

UPDATE "gamedata_quests" SET "prerequisite" = "id" - 1 WHERE "id" IN
    (111407, 111607, 111807) AND "prerequisite" IN (0, "id" - 4);
