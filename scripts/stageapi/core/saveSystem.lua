local json = require("json")

local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading Save System")

StageAPI.SaveDataLoaded = false
StageAPI.RoomsToLoad = {}
StageAPI.LevelMapsToLoad = {}

function StageAPI.TryLoadModData(continued)
    if Isaac.HasModData(mod) and continued then
        local time1 = Isaac.GetTime()
        local data = Isaac.LoadModData(mod)
        StageAPI.LoadSaveString(data)
        local time2 = Isaac.GetTime()
        StageAPI.SaveDataLoaded = true
        StageAPI.LogMinor(("Successfully loaded save data! Took %.3fs"):format((time2 - time1) / 1000))
    else
        StageAPI.ResetModData(false)
        StageAPI.SaveDataLoaded = true
        StageAPI.LogMinor("New run (or save data file missing), reset save data")
        StageAPI.SaveModData()
    end
end

function StageAPI.ResetModData(markUnloaded)
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
    if markUnloaded then
        StageAPI.SaveDataLoaded = false
    end
end

function StageAPI.SaveModData()
    local time1 = Isaac.GetTime()
    Isaac.SaveModData(mod, StageAPI.GetSaveString())
    local time2 = Isaac.GetTime()
    StageAPI.LogMinor(("Saved data! Took %.3fs"):format((time2 - time1) / 1000))
end

function StageAPI.GetSaveString()
    local levelSaveData = {}
    for dimension, rooms in pairs(StageAPI.RoomGrids) do
        if type(dimension) == "string" and tonumber(dimension) then
            StageAPI.LogWarn("Dimension in RoomGrids is string ", dimension, ", converting to number")
            ---@type number
            dimension = tonumber(dimension)
        end
        if not levelSaveData[dimension] then
            levelSaveData[dimension] = {}
        end

        for index, roomGrids in pairs(rooms) do
            if type(index) == "string" and tonumber(index) then
                StageAPI.LogWarn("Index in RoomGrids is string ", index, ", converting to number")
                ---@type number
                index = tonumber(index)
            end
            if not levelSaveData[dimension][index] then
                levelSaveData[dimension][index] = {}
            end

            local roomDat = levelSaveData[dimension][index]
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
        if type(dimension) == "string" and tonumber(dimension) then
            StageAPI.LogWarn("Dimension in CustomGrids is string ", dimension, ", converting to number")
            ---@type number
            dimension = tonumber(dimension)
        end
        if not levelSaveData[dimension] then
            levelSaveData[dimension] = {}
        end

        for lindex, customGrids in pairs(rooms) do
            if type(lindex) == "string" and tonumber(lindex) then
                StageAPI.LogWarn("Index in CustomGrids is string ", lindex, ", converting to number")
                ---@type number
                lindex = tonumber(lindex)
            end
            if not levelSaveData[dimension][lindex] then
                levelSaveData[dimension][lindex] = {}
            end

            local roomDat = levelSaveData[dimension][lindex]
            roomDat.CustomGrids = customGrids
        end
    end

    for dimension, rooms in pairs(StageAPI.LevelRooms) do
        if type(dimension) == "string" and tonumber(dimension) then
            StageAPI.LogWarn("Dimension in LevelRooms is string ", dimension, ", converting to number")
            ---@type number
            dimension = tonumber(dimension)
        end
        if not levelSaveData[dimension] then
            levelSaveData[dimension] = {}
        end

        for index, customRoom in pairs(rooms) do
            if type(index) == "string" and tonumber(index) then
                StageAPI.LogWarn("Index in LevelRooms is string ", index, ", converting to number")
                ---@type number
                index = tonumber(index)
            end
            if not levelSaveData[dimension][index] then
                levelSaveData[dimension][index] = {}
            end

            levelSaveData[dimension][index].Room = customRoom:GetSaveData()
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
        stageProgress[id] = data
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
    for dimension, rooms in pairs(decoded.LevelInfo) do
        if type(dimension) == "string" and tonumber(dimension) then
            StageAPI.LogWarn("Dimension in LevelInfo is string ", dimension, ", converting to number")
            ---@type number
            dimension = tonumber(dimension)
        end

        retRoomGrids[dimension] = {}
        retCustomGrids[dimension] = {}

        for lindex, roomSaveData in pairs(rooms) do
            if type(lindex) == "string" and tonumber(lindex) then
                StageAPI.LogWarn("lindex in LevelInfo is string ", lindex, ", converting to number")
                ---@type number
                lindex = tonumber(lindex)
            end

            if roomSaveData.Grids then
                retRoomGrids[dimension][lindex] = {}
                for _, grindex in ipairs(roomSaveData.Grids) do
                    retRoomGrids[dimension][lindex][grindex] = true
                end
            end

            retCustomGrids[dimension][lindex] = roomSaveData.CustomGrids

            if roomSaveData.Room then
                StageAPI.RoomsToLoad[#StageAPI.RoomsToLoad+1] = {
                    RoomSaveData = roomSaveData,
                    Dimension = dimension,
                    LIndex = lindex,
                }
            end
        end
    end

    StageAPI.LevelMapsToLoad = {}
    for _, levelMapSaveData in ipairs(decoded.LevelMaps) do
        StageAPI.LevelMapsToLoad[#StageAPI.LevelMapsToLoad+1] = levelMapSaveData
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
        StageAPI.TransitionAnimationData.LoadedProgress[id] = data
    end

    StageAPI.CallCallbacks(Callbacks.POST_STAGEAPI_LOAD_SAVE, false)
end

---@type table<string, {Marshal: (fun(val: any): table), Unmarshal: (fun(val: table): any)}>
local GameClassHandlers = {
    Vector = {
        Marshal = function(val)
            return {
                -- cannot save space by using arrays
                -- as they will be saved as dicts anyways
                -- due to the type marker being added
                X = val.X,
                Y = val.Y,
            }
        end,
        Unmarshal = function(val)
            return Vector(val.X, val.Y)
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
                local success, ret = pcall(handler.Unmarshal, val)
                if success then
                    return ret
                else
                    error("Couldn't unmarshal JSON value " .. table_tostring(val) .. ": " .. tostring(ret))
                end
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

local WarnedForFields = {}

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

    -- Json parser converts 0 to string table regardless
    if tbl[0] ~= nil then
        canSaveAsArray = false
    end

    if canSaveAsArray or StageAPI.MARSHALING_CHECK_OLD_WORKAROUNDS then
        for k, v in pairs(tbl) do
            if type(k) ~= "number" then
                isIntTable = false
                if not StageAPI.MARSHALING_CHECK_OLD_WORKAROUNDS then
                    break
                end

                if StageAPI.MARSHALING_CHECK_OLD_WORKAROUNDS
                and not didWarningIntWorkaround and type(k) == "string" and tonumber(k) then
                    didWarningIntWorkaround = true
                    if name and not WarnedForFields[name] then
                        StageAPI.LogWarn("Save: Detected string-index table in savedata at '", name or '?', "'! Not needed anymore and likely a minor performance hit")
                        WarnedForFields[name] = true
                    end
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
        and not didWarningIntWorkaround and type(k) == "string" and tonumber(k)
        and name and not WarnedForFields[name] then
            WarnedForFields[name] = true
            didWarningIntWorkaround = true
            StageAPI.LogWarn("Load: Detected string-index table in savedata at '", name or '?', "'! Not needed anymore and likely a minor performance hit")
        end
    end
    return out
end

-- Loading data: on run join (callback order reasons) then
-- check if new game

StageAPI.RecentlyStartedGame = false

local LastSavedataSeed = -1

mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.EARLY, function()
    shared.Level = shared.Game:GetLevel()
    shared.Room = shared.Game:GetRoom()

    -- Also double check via seeds
    local isGameStart = shared.Game:GetFrameCount() == 0
    StageAPI.RecentlyStartedGame = isGameStart

    local seed = shared.Game:GetSeeds():GetStartSeed()
    if not StageAPI.SaveDataLoaded or (isGameStart and seed ~= LastSavedataSeed) then
        StageAPI.TryLoadModData(not isGameStart)
        LastSavedataSeed = seed
    end
end)

-- Saving data: on pause, new level, and game exit (like base game)

local WasPaused = false
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if shared.Game:IsPaused() and not WasPaused and StageAPI.SaveDataLoaded then
        StageAPI.SaveModData()
    end
    WasPaused = shared.Game:IsPaused()
end)

local function NewLevelLoad()
    for i = #StageAPI.RoomsToLoad, 1, -1 do
        local room = StageAPI.RoomsToLoad[i]
        local customRoom = StageAPI.LevelRoom{FromSave = room.RoomSaveData.Room}
        StageAPI.SetLevelRoom(customRoom, room.LIndex, room.Dimension)
        StageAPI.RoomsToLoad[i] = nil
    end

    for i = #StageAPI.LevelMapsToLoad, 1, -1 do
        StageAPI.LevelMap({SaveData = StageAPI.LevelMapsToLoad[i]})
        StageAPI.LevelMapsToLoad[i] = nil
    end

    StageAPI.SaveModData()
end

mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.IMPORTANT, NewLevelLoad)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, isContinued)
    -- Needs to trigger also when loading a level
    if isContinued then
        NewLevelLoad()
    end
end)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, menuExit)
    if StageAPI.SaveDataLoaded then
        StageAPI.SaveModData()

        --reset data so it will be loaded correctly in case the save is switched
        StageAPI.ResetModData(true)
        StageAPI.LogMinor("Run exit, unloaded data")
    end
end)
mod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, function(_, mod2)
    if mod2 == mod and StageAPI.SaveDataLoaded then
        StageAPI.LogMinor("Unloading, saving data...")
        StageAPI.SaveModData()
        StageAPI.ResetModData(true)
    end
end)

