require ("global")
require ("modifiers")
require ("ally")

-- Toll of the Warden, the summoning in the mesa cave: Amalj'aa and Ixal on
-- the verge of calling their primals. Beating them all ends it; the content
-- roster running out of live hostiles fires "battleComplete" to the
-- director (QuestDirectorMan30001), which plays the Ascian. Seed 120 holds
-- the tribes.

MOBS = { 57, 58, 59, 60 };
ENGAGE_RADIUS = 25.0;	-- a tribesman this close to the player joins the fight

function onCreate(player, contentArea, director)
	director:AddMember(player);
	director:AddMember(director);
	for _, id in ipairs(MOBS) do
		local mob = GetWorldManager().SpawnBattleNpcById(id, contentArea);
		mob:ChangeState(2);
		director:AddMember(mob);
	end
	-- The player can't die in content yet (no death/return flow there).
	player:SetMod(modifiersGlobal.MinimumHpLock, 1);
end

function onZoneIn(player, contentArea, director)
	player:ChangeMusic(37); -- the 1.x duty theme
end

function onUpdate(tick, area)
	if not area then return end
	local owner = nil;
	for player in area:GetPlayers() do
		if player then owner = owner or player end
	end
	if not owner or (owner.positionX == 0 and owner.positionZ == 0) then return end
	for _, mob in ipairs(area:GetMonsters()) do
		if (mob and not mob:IsEngaged()) then
			local dx = mob.positionX - owner.positionX;
			local dz = mob.positionZ - owner.positionZ;
			if (math.sqrt(dx * dx + dz * dz) <= ENGAGE_RADIUS) then
				allyGlobal.EngageTarget(mob, owner);
			end
		end
	end
end

function onAbort(player, contentArea, director)
end

function onDestroy()
end
