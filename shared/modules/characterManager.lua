---@class CharacterManager
local CharacterManager = {}

---@ignore
CharacterManager.__index = CharacterManager

local Framework = require("shared.framework")
local Character = require("shared.modules.character")

local _private = {
	byId = {}, -- [id] = Character
	byPlayerId = {}, -- [playerId] = characterId
	idCounter = 0,
}

---@param character Character
---@return number|nil id
function CharacterManager:Add(character)
	if not character then
		Framework.Debugging:LogError("Invalid character passed to CharacterManager:Add")
		return nil
	end

	if type(character) ~= "table" or getmetatable(character) ~= Character then
		Framework.Debugging:LogError("Invalid character object passed to CharacterManager:Add")
		return nil
	end

	local id = character:GetId()
	if not id then
		_private.idCounter = _private.idCounter + 1
		id = -_private.idCounter -- TODO: negative temporary id until persisted
		character:SetId(id)
	end

	_private.byId[id] = character

	Framework.Debugging:Log("Character added: " .. tostring(id))
	Framework.Hooks:Run("OnCharacterAdded", character)
	return id
end

---@param id number
---@return boolean
function CharacterManager:RemoveById(id)
	if not id then
		return false
	end
	local char = _private.byId[id]
	if not char then
		return false
	end

	for pid, cid in pairs(_private.byPlayerId) do
		if cid == id then
			_private.byPlayerId[pid] = nil
		end
	end

	_private.byId[id] = nil
	Framework.Hooks:Run("OnCharacterRemoved", char)
	Framework.Debugging:Log("Character removed: " .. tostring(id))
	return true
end

---@param id number
---@return Character|nil
function CharacterManager:Get(id)
	return _private.byId[id]
end

---@param player Player
---@param character Character
---@return boolean
function CharacterManager:AssignToPlayer(player, character)
	if not character then
		Framework.Debugging:LogError("Invalid character object passed to CharacterManager:AssignToPlayer")
		return false
	end

	if type(character) ~= "table" or getmetatable(character) ~= Character then
		Framework.Debugging:LogError("Invalid character object passed to CharacterManager:AssignToPlayer")
		return false
	end

	local playerId = player:GetId()
	local cid = character:GetId()
	if not cid then
		cid = self:Add(character)
	else
		_private.byId[cid] = character
	end

	_private.byPlayerId[playerId] = cid
	player:SetCharacter(character)

	Framework.Hooks:Run("OnCharacterAssigned", player, character)
	return true
end

---@param player Player
---@return boolean
function CharacterManager:UnassignFromPlayer(player)
	local playerId = player:GetId()
	if not playerId then
		return false
	end

	local cid = _private.byPlayerId[playerId]
	if not cid then
		return false
	end
	_private.byPlayerId[playerId] = nil

	Framework.Hooks:Run("OnCharacterUnassigned", playerId, cid)
	return true
end

---@param player Player
---@return Character|nil
function CharacterManager:GetByPlayer(player)
	local playerId = player:GetId()
	if not playerId then
		return nil
	end
	local cid = _private.byPlayerId[playerId]
	if not cid then
		return nil
	end
	return _private.byId[cid]
end

---@param character Character
---@return table|nil
function CharacterManager:Save(character)
	if not character or not character.ToTable then
		return nil
	end
	local payload = character:ToTable()
	Framework.Hooks:Run("OnCharacterSaved", character, payload)
	return payload
end

---@param tbl table
---@return Character|nil
function CharacterManager:LoadFromTable(tbl)
	if type(tbl) ~= "table" then
		return nil
	end
	local char = Character.FromTable(tbl)
	local id = tbl.id or char:GetId()
	if not id then
		id = self:Add(char)
	end
	if not id then
		Framework.Debugging:LogError("Failed to assign id when loading character")
		return nil
	end
	_private.byId[id] = char
	return char
end

---@return fun():Character|nil
function CharacterManager:GetList()
	local key, value
	local data = _private.byId
	return function()
		key, value = next(data, key)
		return value
	end
end

return CharacterManager
