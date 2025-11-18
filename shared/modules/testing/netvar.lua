local Framework = require("shared.framework")

function Framework.CreateNetworkedVar(prefix)
	if not prefix or type(prefix) ~= "string" then
		error("A valid string prefix is required for CreateNetworkedVar")
	end

	local backingValues = {}
	local functionHandlers = {}
	local pendingUpdates = {}
	local needsFlushing = false

	local object = {}
	local Replicated = {}

	local function flush()
		needsFlushing = false
		for key, value in pairs(pendingUpdates) do
			backingValues[key] = value
			Framework.ServerEvents.SendToAll(prefix .. key, value)
			pendingUpdates[key] = nil
		end
	end

	if Framework.IS_SERVER then
		function object:SendAllToPlayer(player)
			for key, value in pairs(backingValues) do
				if value ~= nil then
					Framework.ServerEvents.SendToPlayer(player, prefix .. key, value)
				end
			end
		end
	end

	setmetatable(Replicated, {
		__index = function(_, key)
			return backingValues[key]
		end,

		__newindex = function(_, key, value)
			if Framework.IS_SERVER then
				local pendingUpdatesCurrent = pendingUpdates[key]

				if pendingUpdatesCurrent ~= nil and pendingUpdatesCurrent == value then
					return
				end

				if pendingUpdatesCurrent == nil and backingValues[key] == value then
					return
				end

				pendingUpdates[key] = value

				if not needsFlushing then
					needsFlushing = true
					Timer.SetTimeout(flush, 0.1)
				end

				return
			end

			if type(value) ~= "function" then
				error("Client must assign a function handler")
			end

			functionHandlers[key] = value

			if not backingValues["_registered_" .. key] then
				backingValues["_registered_" .. key] = true
				Framework.ClientEvents.Register(prefix .. key, function(updated)
					functionHandlers[key](updated)
					backingValues[key] = updated
				end)
			end
		end,
	})

	object.Replicated = Replicated
	return object
end
