local FrameworkModule = require("shared.framework")
local Config = require("shared.config")

local Framework = FrameworkModule.init({ Config = Config })

if Framework._SharedAutoloaderInitialized then
	return
end

Framework.Debugging:Log("Autoloader initializing modules...") -- TODO: Investigate bug where this file is being called by "..." which is weird...
Framework._SharedAutoloaderInitialized = true

local function AddPlayer(Player)
	local PlayerData = require("shared.modules.player").new(Player, Player:GetLyraPlayerState()) -- TODO: Refactor to not require here
	Framework.Players:Add(PlayerData)
end

RegisterServerEvent("HEvent:PlayerLoggedIn", function(Player)
	AddPlayer(Player)
end)

RegisterServerEvent("HEvent:PlayerUnloaded", function(source)
	Framework.Players:RemoveByPlayerController(source)
end)

if Framework.ShouldAllowHotReload then
	local Players = UE.UGameplayStatics.GetAllActorsOfClass(HWorld, UE.UClass.Load("/Script/SandboxGame.HPlayerController"))
	for _, source in pairs(Players or {}) do
		AddPlayer(source)
	end
end

Framework.Hooks:Add("OnDebugCommandsInitialized", "PlayerManagerSetup", function(commands)
	if Framework.CurrentEnvironment == Framework.Environment.DEBUG then
		commands["debug.givemeadmin"] = function(Player, ...)
			Framework.Permissions:SetRole(Player, "admin")
			Framework.ServerEvents.SendToPlayer(Player, "ChatMessageReceived", "Server", "You have been granted admin role.")
		end
	end
end)

Timer.SetTimeout(function()
	Framework.Hooks:Call("OnSharedAutoloaderInitialized")
end, 0.1)
