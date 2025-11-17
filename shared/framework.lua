local Config = require("shared.config")
local api = {}
local _instance = nil

function api.init(options)
	if _instance then
		return _instance
	end

	options = options or {}
	local config = options.Config or Config

	local instance = {}
	instance.ShouldAllowHotReload = config.allowHotReload
	instance.ShouldRunTests = config.runTests
	instance.CurrentEnvironment = config.environment
	instance.Environment = config.Environment

	instance.Debugging = options.Debugging or require("shared.modules.debugging")
	instance.Hooks = options.Hooks or require("shared.modules.hooks")
	instance.Players = options.Players or require("shared.modules.playerManager")

	instance.Permissions = options.Permissions or require("shared.modules.permissions")
	instance.ServerEvents = options.ServerEvents or IS_SERVER and require("shared.modules.serverEvents")

	_instance = instance
	return _instance
end

function api.get()
	return _instance
end

setmetatable(api, {
	__index = function(t, k)
		local v = rawget(t, k)
		if v ~= nil then
			return v
		end
		if _instance then
			return _instance[k]
		end
		return nil
	end,
	__newindex = function(t, k, v)
		if _instance then
			_instance[k] = v
		else
			rawset(t, k, v)
		end
	end,
})

return api
