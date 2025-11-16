Framework = Framework or {}

Framework.ShouldAllowHotReload = true
Framework.ShouldRunTests = false

Framework.Debugging = Framework.Debugging or require("shared.modules.debugging")
Framework.Debugging:Log("Autoloader initializing modules...") -- TODO: Investigate bug where this file is being called by "..." which is weird...

Framework.Hooks = Framework.Hooks or require("shared.modules.hooks")
Framework.Players = Framework.Players or require("shared.modules.playerManager")
