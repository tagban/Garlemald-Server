--[[

Grand Company Seal Helper Functions

--]]
require("global");

local companySeal = {1000201, 1000202, 1000203}; -- Storm, Serpent, Flame
local rankSealCap = {
    [0] = 0,         -- None   
    [11] = 10000,    -- Private Third Class   
    [13] = 15000,    -- Private Second Class
    [15] = 20000,    -- Private First Class
    [17] = 25000,    -- Corporal
    [21] = 30000,    -- Sergeant Third Class
    [23] = 35000,    -- Sergeant Second Class
    [25] = 40000,    -- Sergeant First Class
    [27] = 45000,    -- Chief Sergeant
    [31] = 50000,    -- Second Lieutenant
    [33] = 50000,    -- First Lieutenant
    [35] = 50000,    -- Captain
    [41] = 60000,    -- Second Commander
    [43] = 60000,    -- First Commander
    [45] = 60000,    -- High Commander
    [51] = 70000,    -- Rear Marshal
    [53] = 70000,    -- Vice Marshal
    [55] = 70000,    -- Marshal
    [57] = 70000,    -- Grand Marshal
    [100] = 100000,  -- Champion
    [111] = 0,       -- Chief Admiral/Elder Seedseer/General
    [127] = 10000    -- Recruit
}
       
function GetGCSeals(player, company)
    company = tonumber(company);
    
    if company ~= nil and company > 0 and company < 4 then
        return player:GetItemPackage(INVENTORY_CURRENCY):GetItemQuantity(companySeal[tonumber(company)]);
    else
        return -1;
    end
end

function AddGCSeals(player, company, amount)
    amount = tonumber(amount);
    company = tonumber(company);   
    
    local gcRank = {player.gcRankLimsa, player.gcRankGridania, player.gcRankUldah};
    local currentAmount = GetGCSeals(player, company);
    local maxAmount = rankSealCap[gcRank[company]];  

    if currentAmount ~= -1 then
        if amount then
            if currentAmount + amount <= maxAmount then
               invCheck = player:GetItemPackage(INVENTORY_CURRENCY):AddItem(companySeal[company], amount, 1);
                if invCheck == INV_ERROR_SUCCESS then
                    return INV_ERROR_SUCCESS;
                end
            else
               return INV_ERROR_FULL;
            end
        end  
    else
        return INV_ERROR_SYSTEM_ERROR;
    end
end
--[[

Grand Company standing.

1 = Maelstrom (Limsa), 2 = Order of the Twin Adder (Gridania), 3 = Immortal
Flames (Ul'dah). A recruit has finished the company's Com0x2 (interim
enlistment, open to members of the other companies' recruit programs too);
a sworn member has taken the company's oath (Com0x7) and holds a rank from
Private Third Class (11) up. Swearing to one company ends the recruit
standing with the others.

--]]

GC_TEST_QUEST    = {111401, 111601, 111801}; -- Com0x1, the officer's test
GC_RECRUIT_QUEST = {111402, 111602, 111802}; -- Com0x2, interim enlistment
GC_OATH_QUEST    = {111407, 111607, 111807}; -- Com0x7, official enlistment

function GetGCRank(player, company)
    return ({player.gcRankLimsa, player.gcRankGridania, player.gcRankUldah})[company] or 0;
end

-- The company the player is sworn to, or 0.
function GetSwornGC(player)
    local gc = player.gcCurrent;
    local rank = GetGCRank(player, gc);
    if (gc ~= nil and gc >= 1 and gc <= 3 and rank >= 11 and rank < 127) then
        return gc;
    end
    return 0;
end

function IsGCRecruit(player, company)
    local sworn = GetSwornGC(player);
    return (sworn == 0 or sworn == company) and player:IsQuestCompleted(GC_RECRUIT_QUEST[company]);
end
