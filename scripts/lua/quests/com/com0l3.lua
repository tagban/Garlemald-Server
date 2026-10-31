require ("global")
require ("quest")

--[[

Quest Script

Name: 	Seals for the Whorl
Code: 	Com0l3
Id: 	111403
Prereq: Com0l2 complete (a recruit of the Maelstrom).

Storm Sergeant Grizzly Gnat at Maelstrom Command welcomes a new recruit and, if you
want to hear it, explains what Storm Seals buy and how official enlistment is
earned. Hearing him out completes the quest; his shop is open to you from
then on (rank-gated goods wait for the oath, Com0l7).

]]

SEQ_000					= 0;

GRIZZLY_GNAT		= 1500202;

function onStart(player, quest)
	quest:StartSequence(SEQ_000);
end

function onFinish(player, quest)
end

function onStateChange(player, quest, sequence)
	if (sequence == SEQ_ACCEPT) then
		quest:SetENpc(GRIZZLY_GNAT, QFLAG_TALK);
	end
end

function onTalk(player, quest, npc)
	if (quest:getSequence() == SEQ_ACCEPT and npc:GetActorClassId() == GRIZZLY_GNAT) then
		local heard = callClientFunction(player, "delegateEvent", player, quest, "processEventFHILAHCTStart");
		if (heard == 1) then
			player:AcceptQuest(quest, true);
			player:EndEvent();
			player:CompleteQuest(quest);
			return;
		end
	end
	player:EndEvent();
end

function getJournalInformation(player, quest)
	return 0, 0, 0, 0, 0;
end

function getJournalMapMarkerList(player, quest)
end
