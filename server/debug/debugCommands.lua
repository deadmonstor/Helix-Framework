if not Framework or not Framework.ServerEvents then
	return
end

local commands = {
	["testcommand"] = function(_, __)
		Framework.ServerEvents.SendToAll("ChatMessageReceived", "Server", "Test command executed")
	end,
}

Framework.ServerEvents.Register("ChatMessageSent", function(source, message)
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
		commandFunc(source, args)
	else
		Framework.Debugging:Log("Unknown command: " .. tostring(commandName))
		Framework.ServerEvents.SendToPlayer(source, "ChatMessageReceived", "Server", "Unknown command: " .. commandName)
	end
end)
