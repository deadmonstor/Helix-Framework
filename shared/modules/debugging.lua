local Debugging = {}

local function DebuggingLogInternal(level, message)
	local info = debug.getinfo(3, "Sl")
	local file = info.short_src or "unknown"
	file = string.match(file, "([^\\/]+)$") or file
	file = string.match(file, '^[^" ]+') or file
	if file == "..." then
		file = "unknown" -- Bug: Helix is running files from the wildcard path "..."
	end
	local line = info.currentline or 0
	local realm = IS_SERVER and "Server" or "Client"
	local prefix = "[" .. realm .. "][" .. file .. ":" .. line .. "] "

	if type(message) == "table" then
		local serialized = "{ "
		for k, v in pairs(message) do
			serialized = serialized .. tostring(k) .. " = " .. tostring(v) .. ", "
		end
		serialized = serialized .. " }"
		print("[" .. level .. "]" .. prefix .. serialized)
	else
		print("[" .. level .. "]" .. prefix .. tostring(message))
	end
end

function Debugging:Log(message)
	DebuggingLogInternal("Info", message)
end

function Debugging:LogWarning(message)
	DebuggingLogInternal("Warning", message)
end

function Debugging:LogError(message)
	DebuggingLogInternal("Error", message)
end

function Debugging:LogPlayerList()
	DebuggingLogInternal("Info", "Current Players:")
	for player in Framework.Players:GetList() do
		print("\t- " .. tostring(player:GetDebugInfo()))
	end
end

return Debugging
