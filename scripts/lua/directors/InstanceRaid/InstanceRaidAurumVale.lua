require ("global")

-- The client's own director for this dungeon (dungeon.lua). Nothing runs on
-- it yet beyond closing any event it's kicked with.

function init()
	return "/Director/InstanceRaid/InstanceRaidAurumVale";
end

function onEventStarted(player, actor, triggerName)
	player:EndEvent();
end

function main()
end
