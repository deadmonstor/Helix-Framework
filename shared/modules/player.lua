---@class Player
local Player = {}

---@ignore
Player.__index = Player

local _private = setmetatable({}, { __mode = "k" })

---@param PlayerController APlayerController
---@param LyraPlayerState LyraPlayerState
---@return Player
function Player.new(PlayerController, LyraPlayerState)
	local self = setmetatable({}, Player)
	_private[self] = {
		["controller"] = PlayerController,
		["lyraPlayerState"] = LyraPlayerState,
	}
	return self
end

---@return number
function Player:GetId()
	return _private[self]["lyraPlayerState"].PlayerId
end

---@return LyraPlayerState
function Player:GetPlayerState()
	return _private[self]["lyraPlayerState"]
end

---@return APlayerController
function Player:GetController()
	return _private[self]["controller"]
end

---@return string
function Player:GetDebugInfo()
	return "Player ID: " .. tostring(self:GetId()) -- .. " | PlayerState: " .. tostring(self:GetPlayerState())
end

return Player
