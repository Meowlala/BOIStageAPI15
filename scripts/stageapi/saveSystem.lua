local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

StageAPI.LogMinor("Loading Save System")

StageAPI.json = require("json")
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

        for lindex, customGrids in pairs(StageAPI.CustomGrids) do
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

    return StageAPI.json.encode({
        LevelInfo = levelSaveData,
        LevelMaps = levelMaps,
        Stage = stage,
        CurrentLevelMapID = StageAPI.CurrentLevelMapID,
        CurrentLevelMapRoomID = StageAPI.CurrentLevelMapRoomID,
        EncounteredBosses = encounteredBosses
    })
end

function StageAPI.LoadSaveString(str)
    StageAPI.CallCallbacks("PRE_STAGEAPI_LOAD_SAVE", false)
    local retLevelRooms = {}
    local retRoomGrids = {}
    local retCustomGrids = {}
    local retEncounteredBosses = {}
    local decoded = StageAPI.json.decode(str)

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
        retLevelRooms[dimension] = {}
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
    StageAPI.CurrentLevelMapRoomID = decoded.CurrentLevelMapRoomID

    StageAPI.RoomGrids = retRoomGrids
    StageAPI.CustomGrids = retCustomGrids
    StageAPI.CallCallbacks("POST_STAGEAPI_LOAD_SAVE", false)
end