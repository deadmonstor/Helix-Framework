Framework = Framework or {}

Framework.ShouldAllowHotReload = true
Framework.ShouldRunTests = false

Framework.Debugging = Framework.Debugging or require("shared.modules.debugging")
Framework.Debugging:Log("Autoloader initializing modules...") -- TODO: Investigate bug where this file is being called by "..." which is weird...

Framework.Hooks = Framework.Hooks or require("shared.modules.hooks")
Framework.Players = Framework.Players or require("shared.modules.playerManager")

-- TODO: For now this can be in here.
local function AddPlayer(Player)
	local PlayerData = require("shared.modules.player").new(Player, Player:GetLyraPlayerState()) -- TODO: Refactor to not require here and the double GetLyraPlayerState
	Framework.Players:Add(PlayerData)
end

RegisterServerEvent("HEvent:PlayerLoggedIn", function(Player)
	AddPlayer(Player)
end)

RegisterServerEvent("HEvent:PlayerUnloaded", function(source)
	Framework.Players:RemoveByPlayerController(source)
end)

-- Hot reload protection
if Framework.ShouldAllowHotReload then
	do
		local Players = UE.UGameplayStatics.GetAllActorsOfClass(HWorld, UE.UClass.Load("/Script/SandboxGame.HPlayerController"))
		for _, source in pairs(Players or {}) do
			AddPlayer(source)
		end
	end
end
