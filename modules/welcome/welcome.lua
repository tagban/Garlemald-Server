-- welcome: greets each player as they enter the world. A starting point for
-- your own modules: the map server calls on_login(player) after the game's
-- own onLogin, with the same player object as scripts/lua/player.lua.

require("global")

function on_login(player)
    player:SendMessage(MESSAGE_TYPE_SYSTEM, "", "Welcome to XIVLegacy!")
end
