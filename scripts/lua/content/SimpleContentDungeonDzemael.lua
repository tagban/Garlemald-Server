require ("dungeon")

-- A copy of the dungeon in zone 231 (dungeon.lua): its monsters, nothing
-- scripted on top yet.

function onCreate(player, contentArea, director)
	spawnDungeon(player, contentArea, director, 231);
end

function onZoneIn(player, contentArea, director)
end

function onUpdate(tick, area)
end

function onAbort(player, contentArea, director)
end

function onDestroy()
end
