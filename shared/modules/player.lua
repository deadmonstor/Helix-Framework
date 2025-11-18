---@class Player
local Player = {}

---@ignore
Player.__index = Player

local _private = setmetatable({}, { __mode = "k" })

---@param PlayerController APlayerController
---@param LyraPlayerState LyraPlayerState
---@param Character? Character
---@return Player
function Player.new(PlayerController, LyraPlayerState, Character)
	local self = setmetatable({}, Player)
	_private[self] = {
		["controller"] = PlayerController,
		["lyraPlayerState"] = LyraPlayerState,
		["character"] = Character,
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

---@return Character|nil
function Player:GetCharacter()
	return _private[self]["character"]
end

---@param Character Character
function Player:SetCharacter(Character)
	_private[self]["character"] = Character
end

---@return boolean
function Player:HasCharacter()
	return _private[self]["character"] ~= nil
end

---@return string
function Player:GetDebugInfo()
	local charInfo = self:HasCharacter() and tostring(self:GetCharacter()) or "(no character)"
	return "Player@" .. tostring(self:GetId()) .. " | Character: " .. charInfo
end

---@return string
function Player:__tostring()
	return self:GetDebugInfo()
end

return Player
