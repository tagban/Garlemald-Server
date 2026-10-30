--[[

PopulaceCompanyGuide Script

Functions:

eventTalkWelcome()                              - Dialog for new recruits
eventTalkProvisional()                          - Message for when rank isn't high enough?
eventTalkExclusive()                            - Message for wrong GC.
eventTalkComMember(nil, npc, isFoundationDay)   - Information menus for various GC related activities
eventTalkStepBreak()                            - Returns to NPC's neutral state

--]]

require ("global")
require ("gcseals")

function init(npc)
    return false, false, 0, 0;  
end

local gcRep = { 
    [1001737] = 1, -- Maelstrom Representative
    [1001738] = 2, -- Adder Representative
    [1001739] = 3, -- Flame Representative
}

function onEventStarted(player, npc, triggerName)
    local npcId = npc:GetActorClassId();
    if player:HasQuestNpc(npcId) then
        return;
    end
    local npcGC = gcRep[npcId];
    local sworn = GetSwornGC(player);

    if (sworn == npcGC) then
        callClientFunction(player, "eventTalkComMember", nil, npc, true);
    elseif (sworn ~= 0) then
        callClientFunction(player, "eventTalkExclusive");
    elseif (IsGCRecruit(player, npcGC)) then
        callClientFunction(player, "eventTalkProvisional");
    else
        callClientFunction(player, "eventTalkWelcome");
    end

    callClientFunction(player, "eventTalkStepBreak"); 
    player:EndEvent();
end
