---@class LyraPlayerState
---@field PlayerId number

---@class APlayerController
---@field PlayerState LyraPlayerState

function TriggerClientEvent(playerController, eventName, ...) end

function RegisterServerEvent(eventName, cb) end
