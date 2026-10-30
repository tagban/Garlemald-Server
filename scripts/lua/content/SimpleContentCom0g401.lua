require ("global")
require ("modifiers")
require ("ally")

-- The Mail Must Get Through, the defense of the conjurers' rite northwest
-- of Gridania: an imperial raiding party. Beating them ends the duty; the
-- content roster running out of live hostiles fires "battleComplete" to the
-- director (QuestDirectorCom0g401). Seed 124 holds the soldiers.

MOBS = { 67, 68, 69 };

function onCreate(player, contentArea, director)
	director:AddMember(player);
	director:AddMember(director);
	for _, id in ipairs(MOBS) do
		local mob = GetWorldManager().SpawnBattleNpcById(id, contentArea);
		mob:ChangeState(2);
		director:AddMember(mob);
		allyGlobal.EngageTarget(mob, player);
	end
	-- The player can't die in content yet (no death/return flow there).
	player:SetMod(modifiersGlobal.MinimumHpLock, 1);
end

function onZoneIn(player, contentArea, director)
	player:ChangeMusic(37); -- the 1.x duty theme
end

function onUpdate(tick, area)
end

function onAbort(player, contentArea, director)
end

function onDestroy()
end
