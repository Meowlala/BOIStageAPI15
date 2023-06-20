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
if false then -- for vscode autocompletion, do not actually run as it gets metatable'd, see after
    ---@type EntityPlayer[]
    sharedVars.Players = {}
end

setmetatable(sharedVars, {
    __index = function(self, key)
        if key == "Players" then
            -- Do not actually keep players in memory to avoid crashes
            -- and running it in a callback risked players being nil
            -- for things that run before it in a run, or invalid for 
            -- things that run before it in general
            return StageAPI.GetPlayers()
        end
    end
})

return sharedVars