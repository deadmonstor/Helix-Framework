-- send to all
local ServerEvents = {}

function ServerEvents.SendToAll(eventName, ...)
	for player in Framework.Players:GetList() do
		TriggerClientEvent(player:GetController(), eventName, ...)
	end
end

return ServerEvents
