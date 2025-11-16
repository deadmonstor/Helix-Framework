---@class PlayerManager
PlayerManager = {}
PlayerManager.players = {}

---@param player table Player object with a valid `id` field.
---@return boolean success True if the player was added.
function PlayerManager:Add(player)
	if not player then
		Framework.Debugging:LogError("Invalid player object passed to PlayerManager:Add")
		return false
	end

	self.players[player:GetId()] = player
	Framework.Hooks:Run("OnPlayerAdded", player)

	Framework.Debugging:Log("Player added: " .. tostring(player:GetDebugInfo()))
	Framework.Debugging:LogPlayerList()
	return true
end

---@param playerController APlayerController The controller object used to locate the player.
---@return boolean success True if a player was found and removed.
function PlayerManager:RemoveByPlayerController(playerController)
	if not playerController then
		Framework.Debugging:LogError("Invalid playerController passed to PlayerManager:RemoveByPlayerController")
		return false
	end

	for id, player in pairs(self.players) do
		if player:GetController() == playerController then
			Framework.Hooks:Run("OnPlayerRemoved", player)
			self.players[id] = nil
			Framework.Debugging:Log("Player removed: " .. tostring(player:GetDebugInfo()))
			Framework.Debugging:LogPlayerList()
			return true
		end
	end

	Framework.Debugging:LogWarning("Player to remove not found for given controller.")
	return false
end

---@param playerId number A valid player identifier.
---@return table|nil player Player object or nil if not found.
function PlayerManager:Get(playerId)
	return self.players[playerId]
end

---@return function iterator
function PlayerManager:GetList()
	local key, value
	local players = self.players
	return function()
		key, value = next(players, key)
		return value
	end
end

return PlayerManager
