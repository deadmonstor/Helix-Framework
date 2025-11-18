---@class Character
---@field id number?
---@field firstname string
---@field lastname string
---@field money number
---@field bank number
---@field job table
---@field inventory table[]
---@field coords table
---@field health number
---@field armor number
---@field metadata table
---@class Character
local Character = {}

---@ignore
Character.__index = Character

local _private = setmetatable({}, { __mode = "k" })

---@param data table?
---@return Character
---@nodiscard
function Character.new(data)
	local self = setmetatable({}, Character)
	data = data or {}
	_private[self] = {
		id = data.id or nil,
		firstname = data.firstname or data.firstName or "",
		lastname = data.lastname or data.lastName or "",
		money = tonumber(data.money) or 0,
		bank = tonumber(data.bank) or 0,
		job = data.job or { name = "unemployed", grade = 0 },
		inventory = data.inventory or {},
		coords = data.coords or { x = 0, y = 0, z = 0, heading = 0 },
		health = data.health or 100,
		armor = data.armor or 0,
		metadata = data.metadata or {},
	}
	return self
end

---@return number|nil
function Character:GetId()
	return _private[self].id
end

function Character:SetId(id)
	_private[self].id = id
end

---@return string
function Character:GetName()
	local d = _private[self]
	if d.firstname ~= "" or d.lastname ~= "" then
		return (d.firstname or "") .. (d.lastname and (#d.lastname > 0 and (" " .. d.lastname) or "") or "")
	end
	return "(unknown)"
end

---@return string
function Character:GetFirstName()
	return _private[self].firstname
end

---@return string
function Character:GetLastName()
	return _private[self].lastname
end

---@param first string?
---@param last string?
---@return nil
function Character:SetName(first, last)
	local d = _private[self]
	d.firstname = first or d.firstname
	d.lastname = last or d.lastname
end

---@return table
function Character:GetJob()
	return _private[self].job
end

---@param jobTable table
function Character:SetJob(jobTable)
	_private[self].job = jobTable or _private[self].job
end

---@return number
function Character:GetMoney()
	return _private[self].money or 0
end

---@param amount number
---@return number
function Character:AddMoney(amount)
	amount = tonumber(amount) or 0
	_private[self].money = (_private[self].money or 0) + amount
	return _private[self].money
end

---@param amount number
---@return number
function Character:RemoveMoney(amount)
	amount = tonumber(amount) or 0
	_private[self].money = math.max(0, (_private[self].money or 0) - amount)
	return _private[self].money
end

---@return number
function Character:GetBank()
	return _private[self].bank or 0
end

---@param amount number
---@return number
function Character:AddBank(amount)
	amount = tonumber(amount) or 0
	_private[self].bank = (_private[self].bank or 0) + amount
	return _private[self].bank
end

---@param item table { name = string, qty = number, metadata = table? }
---@return boolean
function Character:AddItem(item)
	if not item or not item.name then
		return false
	end
	local inv = _private[self].inventory
	for _, v in ipairs(inv) do
		if v.name == item.name then
			v.qty = (v.qty or 0) + (item.qty or 1)
			return true
		end
	end
	table.insert(inv, { name = item.name, qty = item.qty or 1, metadata = item.metadata or {} })
	return true
end

---@param name string
---@param qty number?
---@return boolean
function Character:RemoveItem(name, qty)
	qty = qty or 1
	local inv = _private[self].inventory
	for i, v in ipairs(inv) do
		if v.name == name then
			v.qty = (v.qty or 0) - qty
			if v.qty <= 0 then
				table.remove(inv, i)
			end
			return true
		end
	end
	return false
end

---@return table[]
function Character:GetInventory()
	return _private[self].inventory
end

---@return table
function Character:GetCoords()
	return _private[self].coords
end

---@param coords table
function Character:SetCoords(coords)
	_private[self].coords = coords or _private[self].coords
end

---@return number
function Character:GetHealth()
	return _private[self].health
end

---@param val number
function Character:SetHealth(val)
	_private[self].health = val
end

---@return number
function Character:GetArmor()
	return _private[self].armor
end

---@param val number
function Character:SetArmor(val)
	_private[self].armor = val
end

---@param key string
---@return any
function Character:GetMeta(key)
	return _private[self].metadata[key]
end

---@param key string
---@param value any
function Character:SetMeta(key, value)
	_private[self].metadata[key] = value
end

---@return table
function Character:ToTable()
	local d = _private[self]
	local copy = {
		id = d.id,
		firstname = d.firstname,
		lastname = d.lastname,
		money = d.money,
		bank = d.bank,
		job = d.job,
		inventory = d.inventory,
		coords = d.coords,
		health = d.health,
		armor = d.armor,
		metadata = d.metadata,
	}
	return copy
end

---@param t table
---@return Character
function Character.FromTable(t)
	return Character.new(t)
end

---@param serializeFn fun(table):string?
---@return string|nil
function Character:ToJSON(serializeFn)
	local ser = serializeFn or function(x)
		return require("json").encode(x)
	end
	return ser(self:ToTable())
end

---@param jsonStr string
---@param deserializeFn fun(string):table?
---@return Character|nil, any
function Character.FromJSON(jsonStr, deserializeFn)
	local deser = deserializeFn or function(x)
		return require("json").decode(x)
	end
	local ok, tbl = pcall(deser, jsonStr)
	if not ok then
		return nil, tbl
	end
	if type(tbl) ~= "table" then
		return nil, "deserialized value is not a table"
	end
	return Character.FromTable(tbl)
end

---@return string
function Character:GetDebugInfo()
	return string.format("Character: [%s] %s | Job: %s | Money: %d", tostring(self:GetId() or "nil"), self:GetName(), tostring(self:GetJob() and self:GetJob().name or "(none)"), self:GetMoney())
end

---@return string
function Character:__tostring()
	return self:GetDebugInfo()
end

return Character
