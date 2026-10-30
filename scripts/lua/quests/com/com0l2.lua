require ("global")
require ("quest")

--[[

Quest Script

Name: 	Testing the Waters
Code: 	Com0l2
Id: 	111402
Prereq: Com0l1 complete; not sworn to another Grand Company.

Interim enlistment in the Maelstrom. Storm Lieutenant Guincum explains the
company and its seals and asks whether you'll join as a recruit; a yes
makes you one (the GC status window opens with your first 250
Storm Seals) and the quest is done in that one talk. Recruits may still
try the other companies' programs until they swear to one (Com0l7).

]]

SEQ_000					= 0;

GUINCUM					= 1500199;
COMPANY					= 1;
RECRUIT_SEALS			= 250;

function onStart(player, quest)
	quest:StartSequence(SEQ_000);
end

function onFinish(player, quest)
end

function onStateChange(player, quest, sequence)
	if (sequence == SEQ_ACCEPT) then
		quest:SetENpc(GUINCUM, QFLAG_TALK);
	end
end

function onTalk(player, quest, npc)
	if (quest:getSequence() == SEQ_ACCEPT and npc:GetActorClassId() == GUINCUM) then
		local joined = callClientFunction(player, "delegateEvent", player, quest, "processEventGUINCUMStart");
		if (joined == 1) then
			player:AcceptQuest(quest, true);
			player:JoinGC(COMPANY);
			player:AddSeals(COMPANY, RECRUIT_SEALS);
			callClientFunction(player, "delegateEvent", player, quest, "processEventGUINCUMEnd");
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
