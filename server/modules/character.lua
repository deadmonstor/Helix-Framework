local Framework = require("shared.framework")
require("server.autoloader")

local Character = require("shared.modules.character")

Framework.Hooks:Add("OnDebugCommandsInitialized", "CharacterManagerSetup", function(commands)
	if Framework.CurrentEnvironment == Framework.Environment.DEBUG then
		commands["debug.setcharacter"] = function(Player, CharacterId)
			local CharacterManager = Framework.Characters
			local PlayerManager = Framework.Players

			local characterId = tonumber(CharacterId)
			if not characterId then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Invalid character ID.")
				return
			end

			local character = CharacterManager:Get(characterId)
			if not character then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Character not found with ID: " .. tostring(characterId))
				return
			end

			local playerData = PlayerManager:Get(Player:GetId())
			if not playerData then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Player data not found.")
				return
			end

			CharacterManager:AssignToPlayer(playerData, character)
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Character set to ID: " .. tostring(characterId))
		end

		commands["debug.createcharacter"] = function(Player)
			local CharacterManager = Framework.Characters
			local PlayerManager = Framework.Players

			local character = Character.new({})
			local characterId = CharacterManager:Add(character)

			local playerData = PlayerManager:Get(Player:GetId())
			if not playerData then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Player data not found.")
				return
			end

			CharacterManager:AssignToPlayer(playerData, character)
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "New character created with ID: " .. tostring(characterId))
		end

		commands["debug.clearcharacter"] = function(Player)
			local CharacterManager = Framework.Characters
			local PlayerManager = Framework.Players

			local playerData = PlayerManager:Get(Player:GetId())
			if not playerData then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Player data not found.")
				return
			end

			CharacterManager:UnassignFromPlayer(playerData)
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Character unassigned from player.")
		end

		commands["debug.setmoney"] = function(Player, Amount)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local amt = tonumber(Amount) or 0
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			char:AddMoney(amt - char:GetMoney())
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Money set to: " .. tostring(char:GetMoney()))
		end

		commands["debug.addmoney"] = function(Player, Amount)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local amt = tonumber(Amount) or 0
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			char:AddMoney(amt)
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Money added. New total: " .. tostring(char:GetMoney()))
		end

		commands["debug.removemoney"] = function(Player, Amount)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local amt = tonumber(Amount) or 0
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			char:RemoveMoney(amt)
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Money removed. New total: " .. tostring(char:GetMoney()))
		end

		commands["debug.addbank"] = function(Player, Amount)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local amt = tonumber(Amount) or 0
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			char:AddBank(amt)
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Bank updated. New balance: " .. tostring(char:GetBank()))
		end

		commands["debug.giveitem"] = function(Player, ItemName, Qty)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local qty = tonumber(Qty) or 1
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			char:AddItem({ name = tostring(ItemName or "unknown"), qty = qty })
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Gave item: " .. tostring(ItemName) .. " x" .. tostring(qty))
		end

		commands["debug.removeitem"] = function(Player, ItemName, Qty)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local qty = tonumber(Qty) or 1
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			local ok = char:RemoveItem(tostring(ItemName or ""), qty)
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Remove item result: " .. tostring(ok))
		end

		commands["debug.teleport"] = function(Player, X, Y, Z, Heading)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local x = tonumber(X) or 0
			local y = tonumber(Y) or 0
			local z = tonumber(Z) or 0
			local h = tonumber(Heading) or 0
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			char:SetCoords({ x = x, y = y, z = z, heading = h })
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Teleported character to: " .. x .. "," .. y .. "," .. z)
		end

		commands["debug.setjob"] = function(Player, JobName, Grade)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local grade = tonumber(Grade) or 0
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			char:SetJob({ name = tostring(JobName or "unemployed"), grade = grade })
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Job set to: " .. tostring(JobName) .. " (grade " .. tostring(grade) .. ")")
		end

		commands["debug.sethealth"] = function(Player, Val)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local val = tonumber(Val) or 100
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			char:SetHealth(val)
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Health set to: " .. tostring(val))
		end

		commands["debug.setarmor"] = function(Player, Val)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local val = tonumber(Val) or 0
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			char:SetArmor(val)
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Armor set to: " .. tostring(val))
		end

		commands["debug.savecharacter"] = function(Player)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			local payload = CharacterManager:Save(char)
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Character saved: " .. tostring(payload and payload.id or "(no id)"))
		end

		commands["debug.showcharacter"] = function(Player)
			local PlayerManager = Framework.Players
			local CharacterManager = Framework.Characters
			local playerData = PlayerManager:Get(Player:GetId())
			local char = CharacterManager:GetByPlayer(playerData)
			if not char then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "No character assigned.")
				return
			end
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", char:GetDebugInfo())
		end

		commands["debug.listcharacters"] = function(Player)
			local CharacterManager = Framework.Characters
			local out = {}
			for c in CharacterManager:GetList() do
				table.insert(out, c:GetId() .. " -> " .. tostring(c))
			end
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Characters:\n" .. table.concat(out, "\n"))
		end

		commands["debug.createcharacterwithdata"] = function(Player, First, Last)
			local CharacterManager = Framework.Characters
			local PlayerManager = Framework.Players
			local data = { firstname = tostring(First or "Test"), lastname = tostring(Last or "Player"), job = { name = "tester", grade = 1 } }
			local char = Character.new(data)
			local id = CharacterManager:Add(char)
			local playerData = PlayerManager:Get(Player:GetId())
			if playerData then
				CharacterManager:AssignToPlayer(playerData, char)
			end
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Created character: " .. tostring(char:GetDebugInfo()))
		end

		commands["debug.unassigncharacter"] = function(Player)
			local CharacterManager = Framework.Characters
			local PlayerManager = Framework.Players
			local playerData = PlayerManager:Get(Player:GetId())
			if not playerData then
				Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Player data not found.")
				return
			end
			CharacterManager:UnassignFromPlayer(playerData)
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "Character unassigned.")
		end
	end
end)
