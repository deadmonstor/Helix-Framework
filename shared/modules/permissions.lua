local Permissions = {}

---@type table<string, table<string, boolean>>
local rolePermissions = {}

---@type table<number, string>
local playerRoles = {}

---@param roleName string
---@param perms table<string, boolean>?
function Permissions:RegisterRole(roleName, perms)
	rolePermissions[roleName] = perms or {}
end

---@param player Player
---@param roleName string
function Permissions:SetRole(player, roleName)
	if not player then
		return
	end
	local id = player:GetId()
	playerRoles[id] = roleName
end

---@param player Player
---@return string|nil
function Permissions:GetRole(player)
	if not player then
		return nil
	end
	local id = player:GetId()
	return playerRoles[id] or "user"
end

---@param player Player
---@param permission string
---@return boolean
function Permissions:Has(player, permission)
	local role = self:GetRole(player)
	if not role then
		return false
	end
	local perms = rolePermissions[role] or {}
	if perms["*"] then
		return true
	end
	if perms[permission] == true then
		return true
	end

	for key, allowed in pairs(perms) do
		if allowed and type(key) == "string" then
			if string.sub(key, -2) == ".*" then
				local prefix = string.sub(key, 1, -3)
				if permission == prefix or string.sub(permission, 1, #prefix + 1) == (prefix .. ".") then
					return true
				end
			end
		end
	end

	return false
end

return Permissions
