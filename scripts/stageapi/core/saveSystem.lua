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

    return json.encode({
        LevelInfo = levelSaveData,
        LevelMaps = levelMaps,
        Stage = stage,
        CurrentLevelMapID = StageAPI.CurrentLevelMapID,
        DefaultLevelMapID = StageAPI.DefaultLevelMapID,
        CurrentLevelMapRoomID = StageAPI.CurrentLevelMapRoomID,
        AscentData = StageAPI.AscentData,
        PreviousExtraRoomData = StageAPI.PreviousExtraRoomData,
        EncounteredBosses = encounteredBosses
    })
end

function StageAPI.LoadSaveString(str)
    StageAPI.CallCallbacks(Callbacks.PRE_STAGEAPI_LOAD_SAVE, false)
    local retRoomGrids = {}
    local retCustomGrids = {}
    local decoded = json.decode(str)

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
    StageAPI.CallCallbacks(Callbacks.POST_STAGEAPI_LOAD_SAVE, false)
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
