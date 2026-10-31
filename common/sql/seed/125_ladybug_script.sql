-- Ladybugs crashed the client. Every class scripted
-- /Chara/Npc/Monster/Bug/LadyBugStandard (ladybug, oilbug, maidenbug,
-- painted ladybug, carrier ladybug and the rest) kills the 1.23b client
-- with a null read inside its Lua spawn path as soon as one comes into
-- view, so any zone with ladybugs nearby could not be entered: Camp
-- Bloodshore (Eastern La Noscea), Quarrymill, Horizon's Edge and more.
-- They take the plain bug script instead: same model family (base 10501),
-- the ladybug body and colors still come from the appearance, but they
-- walk instead of hovering.
--
-- Idempotent: only rows still on the ladybug script are touched.

UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Bug/BugStandard'
    WHERE classPath = '/Chara/Npc/Monster/Bug/LadyBugStandard';
