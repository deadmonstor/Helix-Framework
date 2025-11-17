local Framework = require("shared.framework")
local ServerEvents = {}

---@param eventName string The name of the event to send.
---@vararg ... Additional arguments to send with the event.
---@return nil
function ServerEvents.SendToAll(eventName, ...)
	Framework.Debugging:Log("Sending event to all players: [" .. tostring(eventName) .. "]")
	for player in Framework.Players:GetList() do
		TriggerClientEvent(player:GetController(), eventName, ...)
	end
end

---@param player Player The player to send the event to.
---@param eventName string The name of the event to send.
---@vararg ... Additional arguments to send with the event.
---@return nil
function ServerEvents.SendToPlayer(player, eventName, ...)
	Framework.Debugging:Log("Sending server event to player [" .. tostring(eventName) .. "] for player [" .. tostring(player and player:GetDebugInfo() or "nil") .. "]")
	local controller = player.GetController and player:GetController() or player
	TriggerClientEvent(controller, eventName, ...)
end

---@param eventName string The name of the event to register.
---@param callback fun(player: Player, ...): nil The function to call when the event is received.
---@return nil
function ServerEvents.Register(eventName, callback)
	RegisterServerEvent(eventName, function(source, ...)
		Framework.Debugging:Log("Server event received: [" .. tostring(eventName) .. "] from source: [" .. tostring(source) .. "]")
		local player = Framework.Players:GetByPlayerController(source)
		if not player then
			Framework.Debugging:LogWarning("No player found for source: [" .. tostring(source) .. "] on event: [" .. tostring(eventName) .. "]")
			return
		end
		callback(player, ...)
	end)
end

return ServerEvents
