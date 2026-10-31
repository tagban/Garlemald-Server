require ("global")
require ("quest")

--[[

Quest Script

Name: 	Adder's Nest Egg
Code: 	Com0g3
Id: 	111603
Prereq: Com0g2 complete (a recruit of the Order of the Twin Adder).

Serpent Sergeant Haurtelle at the Adders' Nest welcomes a new recruit and, if you
want to hear it, explains what Serpent Seals buy and how official enlistment is
earned. Hearing him out completes the quest; his shop is open to you from
then on (rank-gated goods wait for the oath, Com0g7).

]]

SEQ_000					= 0;

HAURTELLE		= 1500203;

function onStart(player, quest)
	quest:StartSequence(SEQ_000);
end

function onFinish(player, quest)
end

function onStateChange(player, quest, sequence)
	if (sequence == SEQ_ACCEPT) then
		quest:SetENpc(HAURTELLE, QFLAG_TALK);
	end
end

function onTalk(player, quest, npc)
	if (quest:getSequence() == SEQ_ACCEPT and npc:GetActorClassId() == HAURTELLE) then
		local heard = callClientFunction(player, "delegateEvent", player, quest, "processEventStart");
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
