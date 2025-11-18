local FrameworkModule = require("shared.framework")
local Framework = FrameworkModule.get() or FrameworkModule.init({
	Config = require("shared.config"),
})
require("shared.autoloader")

Framework.PolyZones = Framework.PolyZones or require("client.testing.polyzone")

if Framework._ClientAutoloaderInitialized then
	return
end

FrameworkModule.initrealm({
	IS_SERVER = false,
	IS_CLIENT = true,
})

Framework.Debugging:Log("Client autoloader finished loading modules.")
Framework._ClientAutoloaderInitialized = true

Timer.SetTimeout(function()
	Framework.Hooks:Call("OnClientAutoloaderInitialized")
end, 0.1)
