--[[

PopulaceCompanyBuffer Script

Functions:

eventTalkWelcome(player, boolean)       - Welcome dialog.  Boolean seems to be related to rank?
eventTalkBufEffect()                    - Dialog for applying Sanction
eventTalkBufEffectAfter(player)         - Dialog after applying Sanction
eventTalkStepBreak()                    - Returns to NPC's neutral state

--]]

require ("global")
require ("gcseals")

function init(npc)
    return false, false, 0, 0;  
end

local gcRep = { 
    [1500388] = 1, -- Maelstrom Representative
    [1500389] = 2, -- Adder Representative
    [1500390] = 3, -- Flame Representative
}

function onEventStarted(player, npc, triggerName)
    local npcId = npc:GetActorClassId();
    if player:HasQuestNpc(npcId) then
        return;
    end
    local npcGC = gcRep[npcId];
    local isMember = GetSwornGC(player) == npcGC;
    local choice = callClientFunction(player, "eventTalkWelcome", player, isMember);
    
    if (not isMember or choice ~= 1) then
        -- Nothing asked for, or nothing a recruit or outsider can have.
    elseif (GetGCRank(player, npcGC) < 112) then
        callClientFunction(player, "eventTalkBufEffect");
        callClientFunction(player, "eventTalkBufEffectAfter", player);
        -- TODO: Add Sanction buff
    end
   
    callClientFunction(player, "eventTalkStepBreak"); 
    player:EndEvent();
end

