require ("global")
require ("escort")
require ("quests/man/man206")

-- Together We Stand, the Moonspore Grove duty: your Path companion heads
-- north out of Camp Nine Ivies with you, past imperial sentries, to the
-- grove; with a podling entrusted to you, you bring it back to the camp.
-- The loop is escort.lua's; seed 121 holds the cast.
--
-- The grove's own spot isn't known (no journal marker resolved for the step
-- and the map doesn't label it), so the first leg ends on a stretch walked
-- north-east of the camp, on real ground.

SNPC_START = 1070001;

duty = {
	quest = 110014, -- Man206; GetQuest resolves names only for the opening quests
	escortees = {
		-- the player's own Path companion: their look and nickname
		{
			bnpcId = 52,
			look = function(player) return SNPC_START - 1 + player:GetSNpcSkin() end,
			name = function(player) return player:GetSNpcNickname() end,
		},
	},
	mobs = { 53, 54, 55, 56 },
	legs = {
		{ goal = { x = 1814.5, z = -883.8 }, radius = 8.0, signal = "groveReached", resumeSequence = SEQ_025 },
		{ goal = { x = 1712.0, z = -845.0 }, radius = 12.0, signal = "campReached" },
	},
	minutes = 30,
	failSequence = SEQ_020,
	eject = { x = NINE_IVIES_OUTSIDE[2], y = NINE_IVIES_OUTSIDE[3], z = NINE_IVIES_OUTSIDE[4], rot = NINE_IVIES_OUTSIDE[5] },
};

function onCreate(player, contentArea, director)
	escortGlobal.Create(duty, player, contentArea, director);
end

function onZoneIn(player, contentArea, director)
	player:ChangeMusic(37); -- the 1.x duty theme, as in the opening escorts
end

function onUpdate(tick, area)
	escortGlobal.Update(duty, tick, area);
end

function onAbort(player, contentArea, director)
	escortGlobal.Abort(duty, player, contentArea);
end

function onDestroy()
end
