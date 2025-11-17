local Framework = require("shared.framework")
require("server.autoloader")

Framework.ServerEvents.Register("ChatMessageSent", function(player, message)
	Framework.Hooks.Call("OnChatMessageSent", nil, player, message)
end)
