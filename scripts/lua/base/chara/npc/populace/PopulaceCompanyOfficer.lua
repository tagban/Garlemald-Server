--[[

PopulaceCompanyOfficer Script

xtx_gcRank for GC Rank values

Functions:

eventTalkWelcome()                              - Welcome, then "too raw, come back later" (below the test quest's level)
eventTalkWelcomeQuest()                         - Welcome alone (eligible, test quest not done)
eventTalkPreJoin()                              - Induction speech for a new recruit
eventTalkExclusive()                            - Brush-off for another company's members
eventTalkJoinedOnly()                           - Salute and "never forget whose standard you fight under"
eventTalkJoined(gcRank, gcRank,  isCanAfford, isShowPromotion)  - Menu to ask about/for promotion

eventDoRankUp(gcRank, gcRank)                   - Plays the join/rank-up effect and opens the GC window
eventRankUpDone(???, ???)                       - Has your character do the GC salute?  Values seem to do nothing?
eventRankCategoryUpBefore(gcRank)               - 11/21/31  - Mentions which GC quest you need to clear to continue promotion
eventRankCategoryUpAfter()                      - Follow-up dialog after ranking up
eventTalkQuestUncomplete()                      - Quest prerequisite dialog for ranking up to Second Lieutenant (1.23b rank cap)
eventTalkFestival()                             - Foundation Day 2011 event dialog.  Server needs to reward 1000 GC seals after.
eventTalkFestival2()                            - Foundation Day 2011 event dialog.  Seems to reward more seals, unsure how many.
eventTalkFestival2012(value)                    - Foundation Day 2012 event dialog.  Rewards amount of seals dictated by value, retail used 5000.

eventTalkStepBreak()                            - Resets NPC target/facing
--]]

require ("global")

function init(npc)
	return false, false, 0, 0;	
end

gcOfficer = { 
[1500199] = 1, -- Limsa Officer
[1500200] = 2, -- Grid Officer
[1500198] = 3, -- Flame Officer
}

-- Each company's test quest. Finishing it is what earns the induction; the
-- officer gives it (the quest claims him while it's on offer or underway).
gcTestQuest = {
[1] = 111401, -- The Price of Integrity (Com0l1)
[2] = 111601, -- Breaking the Seals (Com0g1)
[3] = 111801, -- Career Opportunities (Com0u1)
}

GC_TEST_LEVEL = 22;

function onEventStarted(player, npc, triggerName)

    npcId = npc:GetActorClassId();
    local npcGC = gcOfficer[npcId];
    playerGC = player.gcCurrent;

    if playerGC == npcGC then
        talkJoined(player, playerGC);
    elseif playerGC ~= 0 then
        callClientFunction(player, "eventTalkExclusive");
    elseif player:IsQuestCompleted(gcTestQuest[npcGC]) then
        -- The test is passed: the induction speech, the join effect, and the
        -- company's roll (as a Recruit until the first promotion).
        callClientFunction(player, "eventTalkPreJoin");
        callClientFunction(player, "eventDoRankUp", 127, 127);
        player:JoinGC(npcGC);
        callClientFunction(player, "eventRankUpDone", 127, 127);
    elseif player:GetHighestLevel() < GC_TEST_LEVEL then
        -- "Too raw": come back with a reputation.
        callClientFunction(player, "eventTalkWelcome");
    else
        -- The test quest is on offer or underway: its own onTalk answers
        -- (the server runs quest hooks after this script), so stay silent
        -- here, as PopulaceStandard does.
        return;
    end
    callClientFunction(player, "eventTalkStepBreak");
    player:EndEvent();
end

-- A member of this officer's company: the promotion menu.
function talkJoined(player, playerGC)
    playerGCSeal = 1000200 + playerGC;
    -- Pull the player's current rank from the snapshot rather than
    -- the upstream Meteor hardcode. `playerGCRanks[playerGC]` resolves
    -- to the right per-GC rank field so the same script works for
    -- Maelstrom / Twin Adder / Immortal Flames officers.
    local playerGCRanks = { player.gcRankLimsa, player.gcRankGridania, player.gcRankUldah };
    playerCurrentRank = playerGCRanks[playerGC] or 0;
    playerNextRank = GetNextGCRank(playerCurrentRank);
    playerRankUpCost = GetGCPromotionCost(playerCurrentRank);
    currentRankCap = 31; -- Second Lieutenant (1.23b cap)

    if playerNextRank ~= 0 and playerCurrentRank < currentRankCap then
        if player:GetItemPackage(INVENTORY_CURRENCY):HasItem(playerGCSeal, playerRankUpCost) then
            -- Show Promotion window, allow paying
            local choice = callClientFunction(player, "eventTalkJoined", playerCurrentRank, playerNextRank, true, true);

            -- If promotion accepted
            if choice == 1 then
                callClientFunction(player, "eventDoRankUp", playerNextRank, playerNextRank);
                -- Apply the promotion server-side: spend the seal
                -- cost and bump the per-GC rank atomically. The
                -- processor re-validates every precondition
                -- (enrollment, cap, balance) so a desynced
                -- script-side check can't promote past what the
                -- player actually qualifies for.
                player:PromoteGC(playerGC);
            end

        else
            -- Show Promotion window, show dialog you can't afford promotion
            callClientFunction(player, "eventTalkJoined", playerCurrentRank, playerNextRank, false, true);
        end
    else
        callClientFunction(player, "eventTalkJoined", playerCurrentRank, playerNextRank);
    end

    callClientFunction(player, "eventTalkJoinedOnly");
end
