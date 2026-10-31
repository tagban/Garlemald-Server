require ("dungeon")

-- !dungeon <name> / !dungeon leave (processor/dungeon.rs calls these).

function enterTotorak(player) enterDungeon(player, "totorak") end
function enterDzemael(player) enterDungeon(player, "dzemael") end
function enterAurum(player) enterDungeon(player, "aurum") end
function enterCutters(player) enterDungeon(player, "cutters") end
function leave(player) leaveDungeon(player) end
