require ("dungeon")

-- A copy of the dungeon in zone 246 (dungeon.lua): its monsters, nothing
-- scripted on top yet.

function onCreate(player, contentArea, director)
	spawnDungeon(player, contentArea, director, 246);
end

function onZoneIn(player, contentArea, director)
end

function onUpdate(tick, area)
end

function onAbort(player, contentArea, director)
end

function onDestroy()
end
