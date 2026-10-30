require ("global")
require ("quests/man/man206")

-- Together We Stand's Moonspore Grove escort (content SimpleContentMan20601,
-- run by escort.lua). The client's QuestDirectorMan20601 is an empty
-- subclass of QuestDirectorBaseClass, like all its quest directors; the
-- scenes come from the quest itself.
--
-- Beat order follows the opening escorts' directors (QuestDirectorMan0g101),
-- except for the opening: the duty is entered in place (no warp), so no
-- loading veil is up for questBaseRewardSeting to lift, and the entry kick
-- is simply closed. Each leg's arrival signal then plays its scenes.

function init()
	return "/Director/Quest/QuestDirectorMan20601";
end

function onEventStarted(player, actor, triggerName)
	-- By id: GetQuest resolves names only for the opening quests.
	local quest = player:GetQuest(110014);

	-- Close the entry kick; the escort's own loop takes it from here.
	player:EndEvent();

	-- The grove: the podlings, and one entrusted to you.
	-- A failed duty's ContentFinished purges this coroutine, so a signal
	-- only ever arrives from a real arrival.
	waitForSignal("groveReached");
	wait(2);
	kickEventContinue(player, actor, "noticeEvent", "noticeEvent");
	callClientFunction(player, "delegateEvent", player, quest, "processEvent016");
	callClientFunction(player, "delegateEvent", player, quest, "pE20", player:GetSNpcNickname(), player:GetSNpcSkin(), player:GetSNpcPersonality(), player:GetSNpcCoordinate(), player:GetInitialTown());
	quest:StartSequence(SEQ_025);
	player:EndEvent();

	-- Back at the camp with the podling.
	waitForSignal("campReached");
	wait(2);
	kickEventContinue(player, actor, "noticeEvent", "noticeEvent");
	-- pE30 fades in after a warp: the warp out below is it.
	callClientFunction(player, "delegateEvent", player, quest, "pE30", player:GetSNpcNickname(), player:GetSNpcSkin(), player:GetSNpcPersonality(), player:GetSNpcCoordinate(), player:GetInitialTown());
	quest:StartSequence(SEQ_030);
	-- "You are no longer bound by duty." is the client's own, as the content
	-- group comes down.
	player:EndEvent();
	player:GetZone():ContentFinished();
	GetWorldManager():DoZoneChange(player, NINE_IVIES_OUTSIDE[1], nil, 0, 15,
		NINE_IVIES_OUTSIDE[2], NINE_IVIES_OUTSIDE[3], NINE_IVIES_OUTSIDE[4], NINE_IVIES_OUTSIDE[5]);
end

function main()
end
