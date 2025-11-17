IS_CLIENT = true

require("shared.autoloader")

Framework.PolyZones = Framework.PolyZones or require("client.testing.polyzone")
Framework.Debugging:Log("Client autoloader finished loading modules.")
