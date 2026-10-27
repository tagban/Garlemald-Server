--[[

PopulaceGuildlevePublisher Script

Functions:

eventTalkType(level (changes factionLeves), sayIntro, brokenBladePoints, shieldsPoints, hornhandPoints, showTutorialLeves, doOmen (!=0), menuId (to Jump), leveAllowances, ?, ?, ?)
eventTalkPack(startGuildlevePack, endGuildlevePack)
eventTalkCard(card1,card2,card3,card4,card5,card6,card7,card8)
eventTalkDetail(guildLeveId, factionEvaluating, rewardType1, rewardQuantity1, rewardType2, rewardQuantity2, boostPoint, previouslyCompleted, completionBonus)
eventTalkAfterOffer()
eventHistoryleveExist(guildLeveId)
eventHistoryleveCannot()
eventGLChangeDetail(?, guildLeveId, boostPoint, rewardType1, rewardQuantity1, rewardType2, rewardQuantity2, factionEvaluating, previouslyCompleted)
eventTalkChangeOne(skipQuestion)
talkOfferMaxOver()
askRetryRegionalleve(guildLeveId, leveAllowances);

--]]

require ("global")

-- Battlecraft leve sets, one per camp, by the levemete's city zone: the
-- client's pack ids (eventTalkPack shows the range as a camp list with
-- suggested levels) and each pack's camp aetheryte, in pack order.
battlePacks = {
	[133] = { first = 1, camps = {1280002, 1280003, 1280005, 1280007, 1280020, 1280004, 1280006} }, -- Limsa Lominsa
	[155] = { first = 201, camps = {1280062, 1280064, 1280066, 1280067, 1280082, 1280063, 1280073} }, -- Gridania
	[175] = { first = 101, camps = {1280032, 1280033, 1280034, 1280042, 1280052, 1280039, 1280036} }, -- Ul'dah
};

GIL = 0xF4241;

function init(npc)
	return false, false, 0, 0;	
end

-- The 8 cards of a pack: its camp's leve set, padded with 0.
function packCards(packs, pack)
	local index = pack;
	if (pack >= packs.first) then
		index = pack - packs.first + 1;
	end
	local camp = packs.camps[index];
	local cards = {0, 0, 0, 0, 0, 0, 0, 0};
	if (camp ~= nil) then
		local offers = GetGuildleveOffers(camp);
		for i = 1, math.min(#offers, 8) do
			cards[i] = offers[i];
		end
	end
	return cards;
end

function onEventStarted(player, npc)

	local packs = battlePacks[player:GetZoneID()] or battlePacks[133];

	::MENU_LOOP::
	menuChoice = callClientFunction(player, "eventTalkType", 0x30, true, 0x02CE, 0x356, 0x367, true, 0, nil, 0x29, 0,0,0);	
	--Battlecraft
	if (menuChoice == 1) then
		::PACK_LOOP::
		resultGLPack = callClientFunction(player, "eventTalkPack", packs.first, packs.first + #packs.camps - 1);
		
		if (resultGLPack == nil or resultGLPack <= 0) then
			goto MENU_LOOP;
		else
			local cards = packCards(packs, resultGLPack);
		
			::CARDS_LOOP::
			chosenGLCard = callClientFunction(player, "eventTalkCard", cards[1], cards[2], cards[3], cards[4], cards[5], cards[6], cards[7], cards[8]);
			
			if (chosenGLCard == nil or chosenGLCard == -1 or cards[chosenGLCard] == nil or cards[chosenGLCard] == 0) then
				goto PACK_LOOP;
			else
				local leveId = cards[chosenGLCard];
				local gl = GetGuildleveGamedata(leveId);
				local gil = 0;
				if (gl ~= nil) then gil = gl.rewardGil; end
				wasAccepted = callClientFunction(player, "eventTalkDetail", leveId, 0, GIL, gil, 0, 0, 0, false, 0);

				if (wasAccepted == true) then
					player:AddGuildleve(leveId);
					callClientFunction(player, "eventTalkAfterOffer");
				end

				goto CARDS_LOOP;
				
			end
		end
		
	--FieldCraft Miner
	elseif (menuChoice == 0x15) then
	--FieldCraft Botanist
	elseif (menuChoice == 0x16) then
	--FieldCraft Fisher
	elseif (menuChoice == 0x17) then
	--FieldCraft Quit
	elseif (menuChoice == 0x18) then
	--Faction Broken Blade
	elseif (menuChoice == 0x29) then
	--Faction Shields
	elseif (menuChoice == 0x2A) then
	--Faction Horn and Hand
	elseif (menuChoice == 0x2B) then
	--Leve Evaluation
	elseif (menuChoice == 5) then
		-- Hand-in / evaluation flow. Retail drives this via
		-- `eventGLChangeDetail` + `askRetryRegionalleve` over the
		-- player's *active* leves; we don't yet expose an
		-- active-regional-leve enumeration binding to Lua, so this
		-- reuses the same battlecraft card grid + `LeveForCard`
		-- resolve to let the player pick a leve to hand in. PROVISIONAL:
		-- the card selected here is the leve's *definition* card, which
		-- only matters once the player actually holds the matching
		-- (accepted + completed) leve — `HandInRegionalLeve` no-ops
		-- otherwise (checks the journal). See followups: needs a real
		-- active-leve list binding for the canonical eval UI.
		local evalCards = {0x30C3, 0x30C4, 0x30C1, 0x30C5, 0x30C6, 0x30C7, 0x30C8, 0x30C9};
		local chosenEvalCard = callClientFunction(player, "eventTalkCard", evalCards[1], evalCards[2], evalCards[3], evalCards[4], evalCards[5], evalCards[6], evalCards[7], evalCards[8]);
		if (chosenEvalCard ~= nil and chosenEvalCard ~= -1) then
			local resolver = GetRegionalLeveResolver();
			if (resolver ~= nil) then
				local leveId = resolver:LeveForCard(evalCards[chosenEvalCard]);
				if (leveId ~= nil) then
					player:HandInRegionalLeve(leveId);
				end
			end
		end
	--Tutorial
	elseif (menuChoice == 6) then
	--End of Info
	elseif (menuChoice == 7) then	
	--Quit
	elseif (menuChoice == 8) then	
	end
	
	--
	--
	--
	player:EndEvent();
end
