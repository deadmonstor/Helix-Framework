local Framework = require("shared.framework")
require("server.autoloader")

Framework.Hooks:Add("OnPlayerRoleChanged", "NetworkingPermissionsToUser", function(player, newRole)
	Framework.ServerEvents.SendToPlayer(player, "Permissions:LocalRoleChanged", newRole)
end)
