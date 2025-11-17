IS_SERVER = true
local FrameworkModule = require("shared.framework")

require("shared.autoloader")

local Framework = FrameworkModule.get() or FrameworkModule.init({
	Config = require("shared.config"),
})

Framework.ServerEvents = Framework.ServerEvents or require("server.modules.serverEvents")

if Framework._ServerAutoloaderInitialized then
	return
end

Framework.Debugging:Log("Server autoloader initializing modules...")
Framework._ServerAutoloaderInitialized = true

-- TODO: Move this to a config file or have it be editable in-game
Framework.Permissions:RegisterRole("admin", { ["*"] = true })

local userPermissions = {
	["commands.whoami"] = true,
}

if Framework.CurrentEnvironment == Framework.Environment.DEBUG then
	userPermissions["commands.debug.*"] = true
end

Framework.Permissions:RegisterRole("user", userPermissions)

Timer.SetTimeout(function()
	Framework.Hooks.Call("OnServerAutoloaderInitialized")
end, 0.1)
