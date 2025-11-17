local Framework = require("shared.framework")
local ClientEvents = {}

---@param eventName string The name of the event to register.
---@param callback fun(...): nil The function to call when the event is received.
---@return nil
function ClientEvents.Register(eventName, callback)
	RegisterClientEvent(eventName, function(...)
		Framework.Debugging:Log("Client event received: [" .. tostring(eventName) .. "]")
		callback(...)
	end)
end

---@param eventName string The name of the event to send.
---@param ... any The arguments to send with the event.
---@return nil
function ClientEvents.Send(eventName, ...)
	Framework.Debugging:Log("Sending client event to server: [" .. tostring(eventName) .. "]")
	TriggerServerEvent(eventName, ...)
end

return ClientEvents
