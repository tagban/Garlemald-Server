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

function init(npc)
    return false, false, 0, 0;  
end

local gcRep = { 
    [1001737] = 1, -- Maelstrom Representative
    [1001738] = 2, -- Adder Representative
    [1001739] = 3, -- Flame Representative
}

function onEventStarted(player, npc, triggerName)
    local playerGC = player.gcCurrent;
    local playerGCRanks = {player.gcRankLimsa, player.gcRankGridania, player.gcRankUldah};
    local npcGC = gcRep[npc:GetActorClassId()];    
    
    -- gcCurrent 0 is no company; a member's rank is 127 (Recruit) until
    -- the first promotion.
    if (playerGC == 0) then
        callClientFunction(player, "eventTalkWelcome");
    elseif (playerGC ~= npcGC) then
        callClientFunction(player, "eventTalkExclusive");
    elseif (playerGCRanks[playerGC] == 127) then
        callClientFunction(player, "eventTalkProvisional");
    else
        callClientFunction(player, "eventTalkComMember", nil, npc, true);
    end

    callClientFunction(player, "eventTalkStepBreak"); 
    player:EndEvent();
end

