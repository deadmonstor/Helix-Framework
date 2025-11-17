local Framework = require("shared.framework")
local Debugging = {}

OldPrint = OldPrint or print

local function DebuggingLogInternal(level, ...)
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

	local messages = { ... }
	local serialized = ""
	for i, msg in ipairs(messages) do
		serialized = serialized .. tostring(msg)
		if i < #messages then
			serialized = serialized .. "\t"
		end
	end
	OldPrint("[" .. level .. "]" .. prefix .. serialized)
end

function Debugging:Log(...)
	DebuggingLogInternal("Info", ...)
end

function Debugging:LogWarning(...)
	DebuggingLogInternal("Warning", ...)
end

function Debugging:LogError(...)
	DebuggingLogInternal("Error", ...)
end

function Debugging:LogPlayerList()
	DebuggingLogInternal("Info", "Current Players:")
	for player in Framework.Players:GetList() do
		OldPrint("\t- " .. tostring(player:GetDebugInfo()))
	end
end

return Debugging
