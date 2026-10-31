--[[

PopulaceHamletBreeder Script

The Hamlet chocobo breeders (Tsimh Panipahr, 1500011, in Western La Noscea).
Functions, from the 1.23b client's script for this class:

defTalk(player) - Greeting: the line for the breeder's actor class
xmas(player) - Starlight Celebration greeting
select(player) - Menu
wantTrade(player) - Offer a trade
wantTradeRenewal(player) - Offer a renewal
goTrade(player) - Trade

Only the greeting is used: the trades belong to Hamlet Defense, which is not
implemented.

--]]

require ("global")

function init(npc)
	return false, false, 0, 0;
end

function onEventStarted(player, npc, triggerName)

	callClientFunction(player, "defTalk", player);

	player:EndEvent();
end
