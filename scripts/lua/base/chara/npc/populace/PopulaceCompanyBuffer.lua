--[[

PopulaceCompanyBuffer Script

Functions:

eventTalkWelcome(player, boolean)       - Welcome dialog.  Boolean seems to be related to rank?
eventTalkBufEffect()                    - Dialog for applying Sanction
eventTalkBufEffectAfter(player)         - Dialog after applying Sanction
eventTalkStepBreak()                    - Returns to NPC's neutral state

--]]

require ("global")

function init(npc)
    return false, false, 0, 0;  
end

local gcRep = { 
    [1500388] = 1, -- Maelstrom Representative
    [1500389] = 2, -- Adder Representative
    [1500390] = 3, -- Flame Representative
}

function onEventStarted(player, npc, triggerName)
    local playerGC = player.gcCurrent;
    local playerGCRanks = {player.gcRankLimsa, player.gcRankGridania, player.gcRankUldah};
    
    local npcGC = gcRep[npc:GetActorClassId()];
    local isMember = playerGC == npcGC;
    local choice = callClientFunction(player, "eventTalkWelcome", player, isMember);
    
    if (not isMember or choice ~= 1) then
        -- Nothing asked for (or nothing a non-member can have). Recruits
        -- (rank 127) aren't sanctioned either.
    elseif (playerGCRanks[playerGC] > 10 and playerGCRanks[playerGC] < 112) then
        callClientFunction(player, "eventTalkBufEffect");
        callClientFunction(player, "eventTalkBufEffectAfter", player);
        -- TODO: Add Sanction buff
    end
   
    callClientFunction(player, "eventTalkStepBreak"); 
    player:EndEvent();
end

