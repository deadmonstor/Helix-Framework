IS_CLIENT = true

require("shared.autoloader")

local FrameworkModule = require("shared.framework")
local Framework = FrameworkModule.get() or FrameworkModule.init({
	Config = require("shared.config"),
})

Framework.PolyZones = Framework.PolyZones or require("client.testing.polyzone")
Framework.ClientEvents = Framework.ClientEvents or require("client.modules.clientEvents")

if Framework._ClientAutoloaderInitialized then
	return
end

Framework.Debugging:Log("Client autoloader finished loading modules.")
Framework._ClientAutoloaderInitialized = true

Timer.SetTimeout(function()
	Framework.Hooks:Call("OnClientAutoloaderInitialized")
end, 0.1)
