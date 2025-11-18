local Framework = require("shared.framework")
require("server.autoloader")

local TestNetworkVar = Framework.CreateNetworkedVar("Global_")
TestNetworkVar.Replicated["TestInt"] = 42
TestNetworkVar.Replicated["TestInt"] = 42
TestNetworkVar.Replicated["TestInt"] = 101
TestNetworkVar.Replicated["TestInt"] = nil

Framework.Hooks:Add("OnPlayerAdded", "NetVarTestSetup", function(player)
	TestNetworkVar:SendAllToPlayer(player)
end)
