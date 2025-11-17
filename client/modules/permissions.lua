local Framework = require("shared.framework")
require("client.autoloader")

Framework.ClientEvents.Register("Permissions:LocalRoleChanged", function(newRole)
	Framework.Permissions:SetRole(Framework.Players:GetLocalPlayer(), newRole)
end)
