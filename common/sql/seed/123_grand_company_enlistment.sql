-- Grand Company enlistment order: the officer's test (Com0x1), interim
-- enlistment as a recruit (Com0x2), the quartermaster's briefing (Com0x3),
-- the recruit missions (Com0x4, Com0x6) and the oath of sole allegiance
-- (Com0x7, Private Third Class). The Corporal-to-Sergeant gate (Com0x5)
-- follows the oath. The quest-offer code also gates company quests by
-- standing (processor/quest_offers.rs, company_gate): nothing for members
-- sworn to another company, Com0x5 only from Corporal, no second oath.
--
-- Idempotent: UPDATEs guarded on the unset prerequisite.

UPDATE "gamedata_quests" SET "prerequisite" = "id" - 1 WHERE "id" IN
    (111402, 111403, 111602, 111603, 111802, 111803) AND "prerequisite" = 0;

UPDATE "gamedata_quests" SET "prerequisite" = "id" - 1 WHERE "id" IN
    (111404, 111604, 111804) AND "prerequisite" = 0;

UPDATE "gamedata_quests" SET "prerequisite" = "id" - 3 WHERE "id" IN
    (111406, 111606, 111806) AND "prerequisite" = 0;

UPDATE "gamedata_quests" SET "prerequisite" = "id" - 4 WHERE "id" IN
    (111407, 111607, 111807) AND "prerequisite" = 0;

UPDATE "gamedata_quests" SET "prerequisite" = "id" + 2 WHERE "id" IN
    (111405, 111605, 111805) AND "prerequisite" = 0;
