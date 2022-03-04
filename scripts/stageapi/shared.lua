-- Variables shared locally within the mod
-- (were originally sort-of-locals inside of the singular main.lua)
local sharedVars = {}

sharedVars.Game = Game()
sharedVars.Sfx = SFXManager()
sharedVars.Room = nil -- for autocomplete, set by basic.lua
sharedVars.Level = nil -- for autocomplete, set by basic.lua
sharedVars.Players = {} -- for autocomplete, set by basic.lua

--[[
    Was:
    local game / StageAPI.Game
    local sfx
    local room / StageAPI.Room
    local level / StageAPI.Level
    local players / StageAPI.Players
]]

return sharedVars