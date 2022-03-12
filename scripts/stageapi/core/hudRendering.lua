local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

local SHADER_NAME = "StageAPI-RenderAboveHUD"

-- MC_GET_SHADER_PARAMS renders above the hud, 
-- need custom shader both to be sure that it gets called 
-- and to call the callbacks only once instead of for all shaders
local function hudRendering_GetShaderParams(_, shaderName)
    if shaderName == SHADER_NAME then
        StageAPI.CallCallbacks(Callbacks.POST_HUD_RENDER, false, StageAPI.IsPauseMenuOpen(), StageAPI.GetPauseMenuDarkPct())
    end
end

StageAPI.PAUSE_DARK_BG_COLOR = 155 / 255

-- Test
--[[
StageAPI.AddCallback("StageAPI", Callbacks.POST_HUD_RENDER, 0, function(isPauseMenuOpen, pauseMenuDarkPct)
    local d = StageAPI.Lerp(1, 1 - StageAPI.PAUSE_DARK_BG_COLOR, pauseMenuDarkPct)
    local r, g, b = d, d, d

    Isaac.RenderText("Hello world", 10, 10, r, g, b, 1)
end)
]]


mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, hudRendering_GetShaderParams)
