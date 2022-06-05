-- Variables shared locally within the mod
-- (were originally sort-of-locals inside of the singular main.lua)
local sharedVars = {}

sharedVars.Game = Game()
sharedVars.Sfx = SFXManager()
sharedVars.Music = MusicManager()
sharedVars.ItemConfig = Isaac.GetItemConfig()
 -- for autocomplete, set by basic.lua
---@type Room
sharedVars.Room = room
---@type Level
sharedVars.Level = level
---@type EntityPlayer[]
sharedVars.Players = {}

--[[
    Was:
    local game / StageAPI.Game
    local sfx
    local room / StageAPI.Room
    local level / StageAPI.Level
    local players / StageAPI.Players
]]

return sharedVars