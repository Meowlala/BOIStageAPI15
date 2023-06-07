local json = require("json")

local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading Save System")

function StageAPI.TryLoadModData(continued)
    if Isaac.HasModData(mod) and continued then
        local data = Isaac.LoadModData(mod)
        StageAPI.LoadSaveString(data)
    else
        StageAPI.CurrentStage = nil
        StageAPI.LevelRooms = {}
        StageAPI.RoomGrids = {}
        StageAPI.CustomGrids = {}
        StageAPI.LevelMaps = {}
        StageAPI.AscentData = {}
        StageAPI.EncounteredBosses = {}
        StageAPI.PreviousExtraRoomData = {}
        StageAPI.CurrentLevelMapID = nil
        StageAPI.CurrentLevelMapRoomID = nil
        StageAPI.DefaultLevelMapID = nil
    end
end

function StageAPI.SaveModData()
    Isaac.SaveModData(mod, StageAPI.GetSaveString())
end

function StageAPI.GetSaveString()
    local levelSaveData = {}
    for dimension, rooms in pairs(StageAPI.RoomGrids) do
        local strDimension = tostring(dimension)
        if not levelSaveData[strDimension] then
            levelSaveData[strDimension] = {}
        end

        for index, roomGrids in pairs(StageAPI.RoomGrids) do
            local strindex = tostring(index)
            if not levelSaveData[strDimension][strindex] then
                levelSaveData[strDimension][strindex] = {}
            end

            local roomDat = levelSaveData[strDimension][strindex]
            for grindex, exists in pairs(roomGrids) do
                if exists then
                    if not roomDat.Grids then
                        roomDat.Grids = {}
                    end

                    roomDat.Grids[#roomDat.Grids + 1] = grindex
                end
            end
        end
    end

    for dimension, rooms in pairs(StageAPI.CustomGrids) do
        local strDimension = tostring(dimension)
        if not levelSaveData[strDimension] then
            levelSaveData[strDimension] = {}
        end

        for lindex, customGrids in pairs(rooms) do
            local strindex = tostring(lindex)
            if not levelSaveData[strDimension][strindex] then
                levelSaveData[strDimension][strindex] = {}
            end

            local roomDat = levelSaveData[strDimension][strindex]
            roomDat.CustomGrids = customGrids
        end
    end

    for dimension, rooms in pairs(StageAPI.LevelRooms) do
        local strDimension = tostring(dimension)
        if not levelSaveData[strDimension] then
            levelSaveData[strDimension] = {}
        end

        for index, customRoom in pairs(rooms) do
            local strindex = tostring(index)
            if not levelSaveData[strDimension][strindex] then
                levelSaveData[strDimension][strindex] = {}
            end

            levelSaveData[strDimension][strindex].Room = customRoom:GetSaveData()
        end
    end

    local stage = StageAPI.CurrentStage
    if stage then
        stage = stage.Name
    end

    local encounteredBosses = {}
    for boss, encountered in pairs(StageAPI.EncounteredBosses) do
        if encountered then
            encounteredBosses[#encounteredBosses + 1] = boss
        end
    end

    local levelMaps = {}
    for dimension, levelMap in pairs(StageAPI.LevelMaps) do
        levelMaps[#levelMaps + 1] = levelMap:GetSaveData()
    end

    local stageProgress = {}
    for id, data in pairs(StageAPI.TransitionAnimationData.Progress) do
        stageProgress[tostring(id)] = data
    end

    return json.encode(StageAPI.SaveTableMarshal{
        LevelInfo = levelSaveData,
        LevelMaps = levelMaps,
        Stage = stage,
        CurrentLevelMapID = StageAPI.CurrentLevelMapID,
        DefaultLevelMapID = StageAPI.DefaultLevelMapID,
        CurrentLevelMapRoomID = StageAPI.CurrentLevelMapRoomID,
        AscentData = StageAPI.AscentData,
        PreviousExtraRoomData = StageAPI.PreviousExtraRoomData,
        EncounteredBosses = encounteredBosses,
        StageProgress = stageProgress,
    })
end

function StageAPI.LoadSaveString(str)
    StageAPI.CallCallbacks(Callbacks.PRE_STAGEAPI_LOAD_SAVE, false)
    local retRoomGrids = {}
    local retCustomGrids = {}
    local decoded = StageAPI.SaveTableUnmarshal(json.decode(str))

    StageAPI.CurrentStage = nil
    if decoded.Stage then
        StageAPI.CurrentStage = StageAPI.CustomStages[decoded.Stage]
    else
        local inOverriddenStage, override = StageAPI.InOverriddenStage()
        if inOverriddenStage then
            StageAPI.CurrentStage = override
        end
    end

    StageAPI.EncounteredBosses = {}

    if decoded.EncounteredBosses then
        for _, boss in ipairs(decoded.EncounteredBosses) do
            StageAPI.EncounteredBosses[boss] = true
        end
    end

    StageAPI.LevelRooms = {}
    for strDimension, rooms in pairs(decoded.LevelInfo) do
        local dimension = tonumber(strDimension)
        retRoomGrids[dimension] = {}
        retCustomGrids[dimension] = {}

        for strindex, roomSaveData in pairs(rooms) do
            local lindex = tonumber(strindex) or strindex
            if roomSaveData.Grids then
                retRoomGrids[dimension][lindex] = {}
                for _, grindex in ipairs(roomSaveData.Grids) do
                    retRoomGrids[dimension][lindex][grindex] = true
                end
            end

            retCustomGrids[dimension][lindex] = roomSaveData.CustomGrids

            if roomSaveData.Room then
                local customRoom = StageAPI.LevelRoom{FromSave = roomSaveData.Room}
                StageAPI.SetLevelRoom(customRoom, lindex, dimension)
            end
        end
    end

    StageAPI.LevelMaps = {}
    for _, levelMapSaveData in ipairs(decoded.LevelMaps) do
        StageAPI.LevelMap({SaveData = levelMapSaveData})
    end

    StageAPI.CurrentLevelMapID = decoded.CurrentLevelMapID
    StageAPI.DefaultLevelMapID = decoded.DefaultLevelMapID
    StageAPI.CurrentLevelMapRoomID = decoded.CurrentLevelMapRoomID
    StageAPI.AscentData = decoded.AscentData
    StageAPI.PreviousExtraRoomData = decoded.PreviousExtraRoomData

    if StageAPI.CurrentLevelMapRoomID then
        StageAPI.TransitioningToExtraRoom = true
    end

    StageAPI.RoomGrids = retRoomGrids
    StageAPI.CustomGrids = retCustomGrids

    StageAPI.TransitionAnimationData.LoadedProgress = {}
    for id, data in pairs(decoded.StageProgress) do
        StageAPI.TransitionAnimationData.LoadedProgress[tonumber(id)] = data
    end

    StageAPI.CallCallbacks(Callbacks.POST_STAGEAPI_LOAD_SAVE, false)
end

---@type table<string, {Marshal: (fun(val: any): table), Unmarshal: (fun(val: table): any)}>
local GameClassHandlers = {
    Vector = {
        Marshal = function(val)
            return {
                val.X,
                val.Y,
            }
        end,
        Unmarshal = function(val)
            return Vector(val[1], val[2])
        end,
    },
}

local function MarshalValue(val, key)
    if type(val) == "table" then
        return StageAPI.SaveTableMarshal(val, key)
    elseif type(val) == "userdata" then
        local meta = getmetatable(val)
        local classtype = meta and (meta.__type or meta.__name)
        local handler = GameClassHandlers[classtype]
        if handler then
            local out = handler.Marshal(val)
            out.__USERDATATYPE__ = classtype
            return out
        else
            return val
        end
    else
        return val
    end
end

local function UnmarshalValue(val, key)
    if type(val) == "table" then
        if val.__USERDATATYPE__ then
            local classtype = val.__USERDATATYPE__
            local handler = GameClassHandlers[classtype]
            if handler then
                val.__USERDATATYPE__ = nil
                return handler.Unmarshal(val)
            else
                StageAPI.LogErr("Couldn't unmarshal save data type: ", classtype)
                return val
            end
        else
            return StageAPI.SaveTableUnmarshal(val, key)
        end
    else
        return val
    end
end

--[[
    Table to try this out:
    test_tbl = {
        Ints = {[1] = true, [5] = true, [235] = true},
        Array = {[1] = true, [2] = false, [3] = false},
        Vector = Vector(15, 2.5),
        String = "ciao",
    }
    `l test_tbl = {Ints = {[1] = true, [5] = true, [235] = true},Array = {[1] = true, [2] = false, [3] = false},Vector = Vector(15, 2.5),String = "ciao"}`
]]

-- If should check for unneeded workarounds on save/load
-- (for example string indices) as they are not needed and 
-- worse for performance to do at runtime, and print a warning
StageAPI.MARSHALING_CHECK_OLD_WORKAROUNDS = true

---Convert some data for better json representation
-- For instance, int tables to str-int tables, 
-- and vectors into arrays.
-- This avoids having to do that at runtime.
---@param tbl table
---@return table
function StageAPI.SaveTableMarshal(tbl, name)
    -- check if table has number keys
    -- int tables with continuous values from 1 can be saved as arrays, others 
    -- get saved as arrays in json but take up a lot of space
    local isIntTable = true
    local canSaveAsArray = true
    
    local didWarningIntWorkaround = false

    for k, v in pairs(tbl) do
        if type(k) ~= "number" then
            isIntTable = false
            if not StageAPI.MARSHALING_CHECK_OLD_WORKAROUNDS then
                break
            end

            if StageAPI.MARSHALING_CHECK_OLD_WORKAROUNDS
            and not didWarningIntWorkaround and type(k) == "string" and tonumber(k) then
                didWarningIntWorkaround = true
                StageAPI.LogWarn("Save: Detected string-index table in savedata at '", name or '?', "'! Not needed anymore and likely a minor performance hit")
            end
        elseif k > #tbl then
            -- in tables, # returns the max continuous key from 1 (in array-like tables, that's normally the length)
            -- if the key is greater than that, then it's a table with int keys instead of an array
            canSaveAsArray = false
            if not StageAPI.MARSHALING_CHECK_OLD_WORKAROUNDS then
                break
            end
        end
    end

    if isIntTable and not canSaveAsArray then
        local out = {___INT_TABLE___ = true}
        for k, v in pairs(tbl) do
            out[tostring(k)] = MarshalValue(v, k)
        end
        return out
    end

    local out = {}
    for k, v in pairs(tbl) do
        out[k] = MarshalValue(v, k)
    end
    return out
end

-- Reverse `StageAPI.SaveTableMarshal`
---@param tbl table
---@return table
function StageAPI.SaveTableUnmarshal(tbl, name)
    if tbl.___INT_TABLE___ then
        tbl.___INT_TABLE___ = nil
        local out = {}
        for k, v in pairs(tbl) do
            out[tonumber(k)] = UnmarshalValue(v, k)
        end
        return out
    end

    local didWarningIntWorkaround = false

    local out = {}
    for k, v in pairs(tbl) do
        out[k] = UnmarshalValue(v, k)

        if StageAPI.MARSHALING_CHECK_OLD_WORKAROUNDS
        and not didWarningIntWorkaround and type(k) == "string" and tonumber(k) then
            didWarningIntWorkaround = true
            StageAPI.LogWarn("Load: Detected string-index table in savedata at '", name or '?', "'! Not needed anymore and likely a minor performance hit")
        end
    end
    return out
end


StageAPI.LastGameSeedLoaded = -1
StageAPI.LoadedModDataSinceLastUpdate = false
StageAPI.RecentlyStartedGame = false

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    shared.Level = shared.Game:GetLevel()
    shared.Room = shared.Game:GetRoom()
    local highestPlayerFrame
    for i = 1, shared.Game:GetNumPlayers() do
        shared.Players[i] = Isaac.GetPlayer(i - 1)
        local frame = shared.Players[i].FrameCount
        if not highestPlayerFrame or frame > highestPlayerFrame then
            highestPlayerFrame = frame
        end
    end

    if highestPlayerFrame < 3 then
        local seed = shared.Game:GetSeeds():GetStartSeed()
        if not StageAPI.LoadedModDataSinceLastUpdate or StageAPI.LastGameSeedLoaded ~= seed then
            StageAPI.RecentlyStartedGame = true
            StageAPI.LoadedModDataSinceLastUpdate = true
            StageAPI.LastGameSeedLoaded = seed
            StageAPI.TryLoadModData(shared.Game:GetFrameCount() > 2)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    StageAPI.LoadedModDataSinceLastUpdate = false
end)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, shouldSave)
    if shouldSave then
        StageAPI.SaveModData()
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    StageAPI.SaveModData()
end)
