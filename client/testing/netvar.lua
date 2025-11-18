local Framework = require("shared.framework")
require("client.autoloader")

-- Client:
local TestNetworkVar = Framework.CreateNetworkedVar("Global_")
TestNetworkVar.Replicated["TestInt"] = function(value)
	Framework.Debugging:Log("TestInt updated to:", value)
end
