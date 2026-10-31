require ("global")
require ("modifiers")
require ("quests/com/com0u4")

-- Arms Race's fight with the Hellhounds near the Golden Bazaar (content
-- SimpleContentCom0u401). The duty is entered in place, so the entry kick is
-- simply closed. Once the Hellhounds fall the quest sends you back to Aubrey.

function init()
	return "/Director/Quest/SimpleQuestBattle/QuestDirectorCom0u401";
end

function onEventStarted(player, actor, triggerName)
	-- By id: GetQuest resolves names only for the opening quests.
	local quest = player:GetQuest(111804);

	player:EndEvent();

	-- A duty that ends any other way purges this coroutine with the content.
	waitForSignal("battleComplete");
	wait(2);
	quest:StartSequence(SEQ_010);
	player:SetMod(modifiersGlobal.MinimumHpLock, 0);
	player:GetZone():ContentFinished();
	GetWorldManager():DoZoneChange(player, HELLHOUND_ROAD[1], nil, 0, 15,
		HELLHOUND_ROAD[2], HELLHOUND_ROAD[3], HELLHOUND_ROAD[4], HELLHOUND_ROAD[5]);
end

function main()
end
