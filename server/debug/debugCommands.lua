local Framework = require("shared.framework")
require("server.autoloader")

---@type table<string, fun(player: Player, ...): nil>
local commands = {
	["testcommand"] = function(Player, ...)
		Framework.ServerEvents.SendToAll("ChatMessageReceived", "Server", "Test command executed")
	end,
	["whoami"] = function(Player, ...)
		Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "You are Player ID: " .. tostring(Player:GetDebugInfo()))
	end,
}

Framework.Hooks.Add("OnServerAutoloaderInitialized", "DebugCommandsSetup", function(Player)
	Framework.Hooks.Call("OnDebugCommandsInitialized", nil, commands)
end)

Framework.Hooks.Add("OnChatMessageSent", "DebugCommands", function(player, message)
	if string.sub(message, 1, 1) ~= "~" then
		return
	end

	local args = {}
	for word in string.gmatch(message, "%S+") do
		table.insert(args, word)
	end

	Framework.Debugging:Log("Command received: " .. tostring(message))
	local commandName = string.sub(args[1], 2):lower()
	table.remove(args, 1)

	local commandFunc = commands[commandName]
	if commandFunc then
		Framework.Debugging:Log("Executing command: " .. tostring(commandName))

		if Framework.Permissions and not Framework.Permissions:Has(player, "commands." .. commandName) then
			Framework.Debugging:Log("Permission denied for command: " .. tostring(commandName))
			Framework.ServerEvents.SendToPlayer(player, "ChatMessageReceived", "Server", "You do not have permission to run this command.")
			return
		end

		commandFunc(player, args)
	else
		Framework.Debugging:Log("Unknown command: " .. tostring(commandName))
		Framework.ServerEvents.SendToPlayer(player, "ChatMessageReceived", "Server", "Unknown command: " .. commandName)
	end
end)
