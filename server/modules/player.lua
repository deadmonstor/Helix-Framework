require("server.autoloader")

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
