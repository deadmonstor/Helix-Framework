local function SendChatMessageToAllFromServer(message)
	local Players = UE.UGameplayStatics.GetAllActorsOfClass(HWorld, UE.UClass.Load("/Script/SandboxGame.HPlayerController"), Players)

	for _, source in pairs(Players or {}) do
		TriggerClientEvent(source, "ChatMessageReceived", "Server", message)
	end
end

local commands = {}

RegisterServerEvent("ChatMessageSent", function(_, message)
	if string.sub(message, 1, 1) == "~" then
		local args = {}
		for word in string.gmatch(message, "%S+") do
			table.insert(args, word)
		end

		local commandName = string.sub(args[1], 2):lower()
		table.remove(args, 1)

		local commandFunc = commands[commandName]
		if commandFunc then
			commandFunc(source, args)
		else
			TriggerClientEvent(source, "ChatMessageReceived", "Server", "Unknown command: " .. commandName)
		end
	end
end)
