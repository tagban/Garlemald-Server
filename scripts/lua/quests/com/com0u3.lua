require ("global")
require ("quest")

--[[

Quest Script

Name: 	Burning a Hole in One's Pocket
Code: 	Com0u3
Id: 	111803
Prereq: Com0u2 complete (a recruit of the Immortal Flames).

Flame Sergeant Rahz at the Hall of Flames welcomes a new recruit and, if you
want to hear it, explains what Flame Seals buy and how official enlistment is
earned. Hearing him out completes the quest; his shop is open to you from
then on (rank-gated goods wait for the oath, Com0u7).

]]

SEQ_000					= 0;

RAHZ		= 1500201;

function onStart(player, quest)
	quest:StartSequence(SEQ_000);
end

function onFinish(player, quest)
end

function onStateChange(player, quest, sequence)
	if (sequence == SEQ_ACCEPT) then
		quest:SetENpc(RAHZ, QFLAG_TALK);
	end
end

function onTalk(player, quest, npc)
	if (quest:getSequence() == SEQ_ACCEPT and npc:GetActorClassId() == RAHZ) then
		local heard = callClientFunction(player, "delegateEvent", player, quest, "processEventUSANZIStart");
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
