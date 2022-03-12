local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

local SHADER_NAME = "StageAPI-RenderAboveHUD"

-- MC_GET_SHADER_PARAMS renders above the hud, 
-- need custom shader both to be sure that it gets called 
-- and to call the callbacks only once instead of for all shaders
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName)
    if shaderName == SHADER_NAME then
        StageAPI.CallCallbacks(Callbacks.POST_HUD_RENDER)
    end
end)

--[[
-- Test
StageAPI.AddCallback("StageAPI", Callbacks.POST_HUD_RENDER, 0, function()
    Isaac.RenderText("Hello world", 10, 10, 1, 1, 1, 255)
end)
]]
