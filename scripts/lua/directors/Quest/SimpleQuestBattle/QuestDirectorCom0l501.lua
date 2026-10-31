require ("global")
require ("modifiers")
require ("quests/com/com0l5")

-- An Officer and a Wise Man's fight with the brigands tracking the Admiral
-- (content SimpleContentCom0l501). The duty is entered in place, so the entry
-- kick is simply closed. Once the brigands fall you step out on the clearing
-- road, in sight of Merlwyb.

function init()
	return "/Director/Quest/SimpleQuestBattle/QuestDirectorCom0l501";
end

function onEventStarted(player, actor, triggerName)
	-- By id: GetQuest resolves names only for the opening quests.
	local quest = player:GetQuest(111405);

	player:EndEvent();

	-- A duty that ends any other way purges this coroutine with the content.
	waitForSignal("battleComplete");
	wait(2);
	quest:StartSequence(SEQ_005);
	player:SetMod(modifiersGlobal.MinimumHpLock, 0);
	player:GetZone():ContentFinished();
	GetWorldManager():DoZoneChange(player, CLEARING_ROAD[1], nil, 0, 15,
		CLEARING_ROAD[2], CLEARING_ROAD[3], CLEARING_ROAD[4], CLEARING_ROAD[5]);
end

function main()
end
