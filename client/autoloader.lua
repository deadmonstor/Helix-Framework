IS_CLIENT = true

local Framework = require("shared.framework")
require("shared.autoloader")

Framework.PolyZones = Framework.PolyZones or require("client.testing.polyzone")

if Framework._ClientAutoloaderInitialized then
	return
end

Framework.Debugging:Log("Client autoloader finished loading modules.")
Framework._ClientAutoloaderInitialized = true

Timer.SetTimeout(function()
	Framework.Hooks.Call("OnClientAutoloaderInitialized")
end, 0.1)
