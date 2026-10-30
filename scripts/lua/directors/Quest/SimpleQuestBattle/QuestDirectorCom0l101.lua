require ("global")
require ("modifiers")
require ("quests/com/com0l1")

-- The Price of Integrity's familiar on the cliffs east of Wineport (content
-- SimpleContentCom0l101). The duty is entered in place, so there is no
-- loading veil to lift: the entry kick is simply closed. Once the familiar
-- falls, Y'shtola finds you (processEvent_030) and the quest sends you back
-- to Walcher.

function init()
	return "/Director/Quest/SimpleQuestBattle/QuestDirectorCom0l101";
end

function onEventStarted(player, actor, triggerName)
	-- By id: GetQuest resolves names only for the opening quests.
	local quest = player:GetQuest(111401);

	player:EndEvent();

	-- A duty that ends any other way purges this coroutine with the content.
	waitForSignal("battleComplete");
	wait(2);
	kickEventContinue(player, actor, "noticeEvent", "noticeEvent");
	-- processEvent_030 fades in after a warp: the warp out below is it.
	callClientFunction(player, "delegateEvent", player, quest, "processEvent_030");
	quest:StartSequence(SEQ_030);
	player:EndEvent();
	player:SetMod(modifiersGlobal.MinimumHpLock, 0);
	player:GetZone():ContentFinished();
	GetWorldManager():DoZoneChange(player, CAMP_OUTSIDE[1], nil, 0, 15,
		CAMP_OUTSIDE[2], CAMP_OUTSIDE[3], CAMP_OUTSIDE[4], CAMP_OUTSIDE[5]);
end

function main()
end
