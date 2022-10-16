local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

---@type table<any, LevelMap>
StageAPI.LevelMaps = {}
StageAPI.DefaultLevelMapID = nil
StageAPI.CurrentLevelMapID = nil
StageAPI.CurrentLevelMapRoomID = nil

StageAPI.LevelMapStartingDimension = -2

---@class LevelMapArgs
---@field Dimension integer
---@field StartingRoom integer # room ID
---@field Persistent boolean
---@field OverlapDimension integer

---@param args? LevelMapArgs
---@return LevelMap
function StageAPI.LevelMap(args)
end

--- Constructor: (args: {Dimension = int, StartingRoom = int, Persistent = bool, OverlapDimension = int})
---@class LevelMap : StageAPIClass
---@field Dimension integer # map ID
---@field StartingRoom integer # room ID
---@field Persistent boolean
---@field OverlapDimension integer
---@field Map table<integer, LevelMap.RoomData>
---@field Map2D table<table<integer, LevelMap.RoomData>>
StageAPI.LevelMap = StageAPI.Class("LevelMap")

---@class LevelMap.RoomData
---@field GridIndex integer
---@field X integer
---@field Y integer
---@field MapID integer 
---@field RoomID any
---@field MapSegments LevelMap.RoomSegment[]
---@field LowX integer
---@field LowY integer
---@field HighX integer
---@field HighY integer
---@field Doors table<DoorSlot,  {ExitRoom: integer, ExitSlot: DoorSlot}> # ExitRoom is a MapID
---@field AutoDoors boolean
---@field Stage LevelStage
---@field StageType StageType
---@field Shape RoomShape
---@field RoomType RoomType

local levelMapDirectCopyFromArgs = {"Dimension", "StartingRoom", "Persistent", "OverlapDimension"}
function StageAPI.LevelMap:Init(args)
    args = args or {}

    self.Map = {}
    self.Map2D = {}

    for _, arg in ipairs(levelMapDirectCopyFromArgs) do
        if args[arg] then
            self[arg] = args[arg]
        end
    end

    if args.SaveData then
        self:LoadSaveData(args.SaveData)
    elseif not self.Dimension then
        local dimension = StageAPI.LevelMapStartingDimension
        while not self.Dimension do
            if not StageAPI.LevelMaps[dimension] then
                self.Dimension = dimension
                break
            end

            dimension = dimension - 1
        end
    end

    StageAPI.LevelMaps[self.Dimension] = self
end

---@param roomData LevelMap.RoomData
function StageAPI.LevelMap:UpdateDoorsAroundRoom(roomData)
    if not roomData.LowX or not roomData.HighX or not roomData.LowY or not roomData.HighY or not roomData.X or not roomData.Y then
        return
    end

    local updatedRooms = {}
    for x = roomData.LowX - 2, roomData.HighX + 2 do
        if self.Map2D[x] then
            for y = roomData.LowY - 2, roomData.HighY + 2 do
                local roomData = self:GetRoomData(x, y)
                if not updatedRooms[roomData.RoomID] then
                    updatedRooms[roomData.RoomID] = true
                    self:SetRoomDoors(roomData)
                end
            end
        end
    end
end

---@param levelRoom? LevelRoom # If nil, will get from from RoomID in roomData
---@param roomData? LevelMap.RoomData # If nil, will be created
---@param noUpdateDoors? boolean
---@return LevelMap.RoomData
function StageAPI.LevelMap:AddRoom(levelRoom, roomData, noUpdateDoors)
    roomData = roomData or {}
    if roomData.GridIndex then
        roomData.X, roomData.Y = StageAPI.GridToVector(roomData.GridIndex, 13)
    end

    local mapID = #self.Map + 1
    roomData.RoomID = roomData.RoomID or mapID
    roomData.MapID = mapID

    if levelRoom then
        StageAPI.SetLevelRoom(levelRoom, roomData.RoomID, self.Dimension)
    else
        levelRoom = StageAPI.GetLevelRoom(roomData.RoomID, self.Dimension)
    end

    roomData.Shape = levelRoom.Shape

    if roomData.X and roomData.Y then
        roomData.MapSegments = StageAPI.GetRoomMapSegments(roomData.X, roomData.Y, roomData.Shape)

        for _, seg in ipairs(roomData.MapSegments) do
            if not self.Map2D[seg.X] then
                self.Map2D[seg.X] = {}
            end

            if self.Map2D[seg.X][seg.Y] then
                StageAPI.LogErr("Overriding a room! Something went wrong at " .. tostring(seg.X) .. "x" .. tostring(seg.Y) ..  "!")
            end

            self.Map2D[seg.X][seg.Y] = mapID

            if not roomData.LowX or seg.X < roomData.LowX then roomData.LowX = seg.X end
            if not roomData.HighX or seg.X > roomData.HighX then roomData.HighX = seg.X end
            if not roomData.LowY or seg.Y < roomData.LowY then roomData.LowY = seg.Y end
            if not roomData.HighY or seg.Y > roomData.HighY then roomData.HighY = seg.Y end
            if not self.LowX or seg.X < self.LowX then self.LowX = seg.X end
            if not self.HighX or seg.X > self.HighX then self.HighX = seg.X end
            if not self.LowY or seg.Y < self.LowY then self.LowY = seg.Y end
            if not self.HighY or seg.Y > self.HighY then self.HighY = seg.Y end
        end

        if not noUpdateDoors then
            self:UpdateDoorsAroundRoom(roomData)
        end
    end

    self:AddRoomToMinimap(roomData)
    self.Map[mapID] = roomData

    return roomData
end

---@param removeRoomData LevelMap.RoomData
---@param noUpdateDoors? boolean
---@param noRemoveLevelRoom? boolean
function StageAPI.LevelMap:RemoveRoom(removeRoomData, noUpdateDoors, noRemoveLevelRoom)
    local mapID = removeRoomData.MapID
    local roomData
    if mapID then
        roomData = self.Map[mapID]
    else
        roomData = self:GetRoomDataFromRoomID(removeRoomData.RoomID)
        mapID = roomData.MapID
    end

    if not roomData then
        return
    end

    if not noRemoveLevelRoom then
        StageAPI.SetLevelRoom(nil, roomData.RoomID, self.Dimension)
    end

    self.Map[mapID] = nil
    if roomData.LowX and roomData.LowY and roomData.HighX and roomData.HighY then
        for x = roomData.LowX, roomData.HighX do
            for y = roomData.LowY, roomData.HighY do
                if self.Map2D[x] and self.Map2D[x][y] == mapID then
                    self.Map2D[x][y] = nil
                end
            end
        end

        if not noUpdateDoors then
            self:UpdateDoorsAroundRoom(roomData)
        end
    end
end

---@param roomData LevelMap.RoomData
function StageAPI.LevelMap:AddRoomToMinimap(roomData)
    if MinimapAPI and roomData.X and roomData.Y then
        local levelRoom = self:GetRoom(roomData)
        if levelRoom then
            local dim = self.OverlapDimension or self.Dimension
            local t = {
                Shape = levelRoom.Shape,
                PermanentIcons = {MinimapAPI:GetRoomTypeIconID(levelRoom.RoomType)},
                LockedIcons = {MinimapAPI:GetUnknownRoomTypeIconID(levelRoom.RoomType)},
                ItemIcons = {},
                VisitedIcons = {},
                Position = Vector(roomData.X, roomData.Y),
                AdjacentDisplayFlags = MinimapAPI.RoomTypeDisplayFlagsAdjacent[levelRoom.RoomType] or 5,
                -- StageAPI custom room types can be strings, which MinimapAPI doesn't support
                Type = type(levelRoom.RoomType) == "number" and levelRoom.RoomType or RoomType.ROOM_DEFAULT,
                Dimension = dim,
                ID = roomData.MapID
            }
            if t.Type == RoomType.ROOM_SECRET or t.Type == RoomType.ROOM_SUPERSECRET then
                t.Hidden = 1
            elseif t.Type == RoomType.ROOM_ULTRASECRET then
                t.Hidden = 2
            end

            MinimapAPI:AddRoom(t)
        end
    end
end

---@param x integer
---@param y integer
---@return LevelMap.RoomData
---@overload fun(self: LevelMap, mapID: integer): LevelMap.RoomData
function StageAPI.LevelMap:GetRoomData(x, y)
    if y then
        if self.Map2D[x] and self.Map2D[x][y] then
            return self.Map[self.Map2D[x][y]]
        end
    else
        return self.Map[x]
        ---@diagnostic disable-next-line
    end
end

---@param roomID any
---@return LevelMap.RoomData?
function StageAPI.LevelMap:GetRoomDataFromRoomID(roomID)
    for _, roomData in ipairs(self.Map) do
        if roomData.RoomID == roomID then
            return roomData
        end
    end
end

---@param x integer
---@param y integer
---@return LevelRoom?
---@overload fun(self: LevelMap, roomData: LevelMap.RoomData): LevelRoom?
---@overload fun(self: LevelMap, mapID: integer): LevelRoom?
function StageAPI.LevelMap:GetRoom(x, y)
    if type(x) == "table" then
        return StageAPI.GetLevelRoom(x.RoomID, self.Dimension)
    else
        local roomData = self:GetRoomData(x, y)
        if roomData then
            return StageAPI.GetLevelRoom(roomData.RoomID, self.Dimension)
        end
    end
end

---@return LevelRoom[]
function StageAPI.LevelMap:GetRooms()
    local rooms = {}
    for _, roomData in ipairs(self.Map) do
        rooms[#rooms + 1] = StageAPI.GetLevelRoom(roomData.RoomID, self.Dimension)
    end

    return rooms
end

---@return LevelMap.RoomData?
function StageAPI.LevelMap:GetCurrentRoomData()
    if self:IsCurrent() and StageAPI.CurrentLevelMapRoomID then
        return self.Map[StageAPI.CurrentLevelMapRoomID]
    end
end

---@param roomData LevelMap.RoomData
function StageAPI.LevelMap:SetRoomDoors(roomData)
    if not roomData.X or not roomData.Y then
        return
    end

    if not roomData.Doors then
        roomData.Doors = {}
    end

    for x = roomData.LowX - 2, roomData.HighX + 2 do -- no need to consider rooms more than two segments away, since 2x2 is the largest shape.
        if self.Map2D[x] then
            for y = roomData.LowY - 2, roomData.HighY + 2 do
                local adjacentRoomData = self:GetRoomData(x, y)
                if adjacentRoomData and adjacentRoomData.MapID ~= roomData.MapID then
                    local adjacent, doors = StageAPI.CheckRoomAdjacency(roomData, adjacentRoomData, true)
                    if adjacent then
                        for enterSlot, exitSlot in pairs(doors) do
                            roomData.Doors[enterSlot] = {
                                ExitRoom = adjacentRoomData.MapID,
                                ExitSlot = exitSlot
                            }
                        end
                    end
                end
            end
        end
    end

    local levelRoom = self:GetRoom(roomData)
    levelRoom.Doors = {}
    for slot, _ in pairs(roomData.Doors) do
        levelRoom.Doors[slot] = true
    end
end

function StageAPI.LevelMap:SetAllRoomDoors()
    for _, roomData in ipairs(self.Map) do
        self:SetRoomDoors(roomData)
    end
end

function StageAPI.LevelMap:GetSaveData()
    local saveMap = {}
    for _, roomData in ipairs(self.Map) do
        saveMap[#saveMap + 1] = {
            RoomID = roomData.RoomID,
            X = roomData.X,
            Y = roomData.Y,
            Stage = roomData.Stage,
            StageType = roomData.StageType,
            Shape = roomData.Shape,
            AutoDoors = roomData.AutoDoors
        }
    end

    return {Map = saveMap, Dimension = self.Dimension, StartingRoom = self.StartingRoom}
end

function StageAPI.LevelMap:LoadSaveData(saveData)
    for _, arg in ipairs(levelMapDirectCopyFromArgs) do
        if saveData[arg] then
            self[arg] = saveData[arg]
        end
    end

    for _, roomData in ipairs(saveData.Map) do
        self:AddRoom(nil, roomData, true)
    end

    self:SetAllRoomDoors()
end

function StageAPI.LevelMap:Destroy()
    StageAPI.LevelMaps[self.Dimension] = nil
    if StageAPI.CurrentLevelMapID == self.Dimension then
        StageAPI.CurrentLevelMapID = nil
    end

    if StageAPI.DefaultLevelMapID == self.Dimension then
        StageAPI.DefaultLevelMapID = nil
    end
end

function StageAPI.LevelMap:IsCurrent()
    return StageAPI.CurrentLevelMapID == self.Dimension
end

---@return LevelMap # Is actually nil-able, but since in most usecases it won't be nil and the vscode extension would complain without redundant checks, is set as non-nil.
function StageAPI.GetCurrentLevelMap()
    if StageAPI.CurrentLevelMapID then
        return StageAPI.LevelMaps[StageAPI.CurrentLevelMapID]
        ---@diagnostic disable-next-line
    end
end

---@return LevelMap # Is actually nil-able, but since in most usecases it won't be nil and the vscode extension would complain without redundant checks, is set as non-nil.
function StageAPI.GetDefaultLevelMap()
    if StageAPI.DefaultLevelMapID then
        return StageAPI.LevelMaps[StageAPI.DefaultLevelMapID]
        ---@diagnostic disable-next-line
    end
end

function StageAPI.InExtraRoom()
    return not not (StageAPI.CurrentLevelMapID and StageAPI.CurrentLevelMapRoomID)
end

function StageAPI.InOrTransitioningToExtraRoom()
    return StageAPI.InExtraRoom() or StageAPI.TransitioningToExtraRoom
end

---@param roomsList RoomsList
---@param useMapID? any
---@param roomArgs? LevelRoomArgs
---@return LevelMap?
function StageAPI.CreateMapFromRoomsList(roomsList, useMapID, roomArgs)
    local startingRoom
    local mapLayouts = {}
    local nonMapLayouts = {}
    for _, layout in ipairs(roomsList.All) do
        local stageIndices = {}
        local roomIndices = {}
        local roomEntities = {}
        for _, ent in ipairs(layout.Entities) do
            local metadata = StageAPI.IsMetadataEntity(ent.Type, ent.Variant)
            if metadata then
                if metadata.Name == "Room" then
                    local roomID = StageAPI.GetBits(ent.SubType, 2, 14)

                    roomEntities[#roomEntities + 1] = {Entity = ent, GridX = ent.GridX, GridY = ent.GridY, RoomID = roomID, FromMap = layout.Variant}
                    if not startingRoom and StageAPI.GetBits(ent.SubType, 0, 1) == 1 then
                        startingRoom = layout.Variant
                    end

                    roomIndices[ent.Index] = true
                elseif metadata.Name == "Stage" then
                    stageIndices[ent.Index] = {Entity = ent, Metadata = metadata}
                end
            end
        end

        if #roomEntities > 0 then
            local globalStage
            local roomToStage = {}
            for index, stageDat in pairs(stageIndices) do
                local stage = StageAPI.GetBits(stageDat.Entity.SubType, 0, 4) + 1
                local stageType = StageAPI.GetBits(stageDat.Entity.SubType, 4, 3)
                if stageType >= StageType.STAGETYPE_GREEDMODE then
                    stageType = stageType + 1
                end

                if roomIndices[index] then
                    roomToStage[index] = {Stage = stage, StageType = stageType}
                else
                    globalStage = {Stage = stage, StageType = stageType}
                end
            end

            mapLayouts[layout.Variant] = {Layout = layout, GlobalStage = globalStage, RoomToStage = roomToStage, RoomEntities = roomEntities}
        else
            nonMapLayouts[layout.Variant] = layout
        end
    end

    for variant, mapLayout in pairs(mapLayouts) do
        mapLayout.MapMergePoints = {}
        for i, roomEnt in StageAPI.ReverseIterate(mapLayout.RoomEntities) do
            if mapLayouts[roomEnt.RoomID] then
                mapLayout.MapMergePoints[roomEnt.RoomID] = {X = roomEnt.Entity.GridX, Y = roomEnt.Entity.GridY, MapID = variant}
                table.remove(mapLayout.RoomEntities, i)
            end
        end
    end

    if useMapID or startingRoom then
        local mapLayout = mapLayouts[useMapID or startingRoom]
        local roomsByID = {}

        while next(mapLayout.MapMergePoints) do
            local mergeID, mergePos = next(mapLayout.MapMergePoints)
            local mergeDat = mapLayouts[mergeID]
            if mergeDat then
                local mergingPos = mergeDat.MapMergePoints[mergePos.MapID]
                if mergingPos then
                    local relativeX, relativeY = mergePos.X - mergingPos.X, mergePos.Y - mergingPos.Y
                    for _, roomEnt in ipairs(mergeDat.RoomEntities) do
                        roomEnt = StageAPI.DeepCopy(roomEnt)
                        roomEnt.GridX = roomEnt.GridX + relativeX
                        roomEnt.GridY = roomEnt.GridY + relativeY
                        mapLayout.RoomEntities[#mapLayout.RoomEntities + 1] = roomEnt
                    end

                    for mergeID2, mergePos2 in pairs(mergeDat.MapMergePoints) do
                        if mergeID2 ~= mergePos.MapID then
                            mapLayout.MapMergePoints[mergeID2] = {X = mergePos2.X + relativeX, Y = mergePos2.Y + relativeY, MapID = mergeID}
                        end
                    end
                end
            end

            mapLayout.MapMergePoints[mergeID] = nil
        end

        for _, roomEnt in ipairs(mapLayout.RoomEntities) do
            local isStartingRoom = StageAPI.GetBits(roomEnt.Entity.SubType, 0, 1) == 1
            local isPersistentRoom = StageAPI.GetBits(roomEnt.Entity.SubType, 1, 1) == 1
            local roomID = roomEnt.RoomID

            local roomPosition = {
                StartingRoom = isStartingRoom,
                Persistent = isPersistentRoom,
                RoomID = roomID,
                GridX = roomEnt.GridX,
                GridY = roomEnt.GridY
            }

            local entMap = mapLayouts[roomEnt.FromMap]
            if entMap.RoomToStage[roomEnt.Entity.Index] then
                roomPosition.Stage = entMap.RoomToStage[roomEnt.Entity.Index]
            elseif entMap.GlobalStage then
                roomPosition.Stage = entMap.GlobalStage
            end

            if not roomsByID[roomID] then
                roomsByID[roomID] = {}
            end

            roomsByID[roomID][#roomsByID[roomID] + 1] = roomPosition
        end

        StageAPI.StageRNG:SetSeed(StageAPI.Seeds:GetStageSeed(shared.Level:GetStage()), 32)

        local levelMap = StageAPI.LevelMap()
        for roomID, roomPositions in pairs(roomsByID) do
            local roomLayout = nonMapLayouts[roomID]
            local shape = roomLayout.Shape
            while #roomPositions > 0 do
                local gridIndices = {}
                local onMap = {}
                for i, position in ipairs(roomPositions) do
                    if not onMap[position.GridX] then
                        onMap[position.GridX] = {}
                    end

                    onMap[position.GridX][position.GridY] = i

                    for x = position.GridX - 1, position.GridX do
                        for y = position.GridY - 1, position.GridY do
                            gridIndices[#gridIndices + 1] = {X = x, Y = y}
                        end
                    end
                end

                local setRoom
                for _, gridIndex in ipairs(gridIndices) do
                    local mapSegs = StageAPI.GetRoomMapSegments(gridIndex.X, gridIndex.Y, shape)
                    local invalid
                    for _, seg in ipairs(mapSegs) do
                        if not onMap[seg.X] or not onMap[seg.X][seg.Y] then
                            invalid = true
                        end
                    end

                    if not invalid then
                        setRoom = {X = gridIndex.X, Y = gridIndex.Y, Segments = mapSegs}
                        break
                    end
                end

                if setRoom then
                    local stage = mapLayout.GlobalStage
                    local isStartingRoom, isPersistent
                    for i, position in StageAPI.ReverseIterate(roomPositions) do
                        local shouldRemove
                        for _, seg in ipairs(setRoom.Segments) do
                            if seg.X == position.GridX and seg.Y == position.GridY then
                                shouldRemove = true
                                break
                            end
                        end

                        if shouldRemove then
                            if position.Stage then
                                stage = position.Stage
                            end

                            isStartingRoom = isStartingRoom or position.StartingRoom
                            isPersistent = isPersistent or position.Persistent
                            table.remove(roomPositions, i)
                        end
                    end

                    local listIndex
                    local searchRooms = roomsList:GetRooms(shape)
                    for listID, layout in ipairs(searchRooms) do
                        if layout.Variant == roomLayout.Variant then
                            listIndex = listID
                            break
                        end
                    end

                    local newRoom = StageAPI.LevelRoom(StageAPI.Merged({
                        RoomsListName = roomsList.Name,
                        RoomsListID = listIndex,
                        SpawnSeed = StageAPI.StageRNG:Next(),
                        AwardSeed = StageAPI.StageRNG:Next(),
                        DecorationSeed = StageAPI.StageRNG:Next(),
                        Shape = shape,
                        RoomType = roomLayout.Type,
                        IsPersistentRoom = true,
                        IsExtraRoom = true
                    }, roomArgs or {}))

                    local roomData = {X = setRoom.X, Y = setRoom.Y, AutoDoors = true}
                    if stage then
                        roomData.Stage = stage.Stage
                        roomData.StageType = stage.StageType
                    end

                    local addedRoomData = levelMap:AddRoom(newRoom, roomData, true)
                    if isStartingRoom then
                        levelMap.StartingRoom = addedRoomData.MapID
                    end
                end
            end
        end

        levelMap:SetAllRoomDoors()
        return levelMap
    end
end

StageAPI.RoomShapeToSegments = {
    [RoomShape.ROOMSHAPE_1x1] = {
        {0, 0, Doors = {UP = DoorSlot.UP0, DOWN = DoorSlot.DOWN0, LEFT = DoorSlot.LEFT0, RIGHT = DoorSlot.RIGHT0}}
    },
    [RoomShape.ROOMSHAPE_IH] = {
        {0, 0, Doors = {LEFT = DoorSlot.LEFT0, RIGHT = DoorSlot.RIGHT0}}
    },
    [RoomShape.ROOMSHAPE_IV] = {
        {0, 0, Doors = {UP = DoorSlot.UP0, DOWN = DoorSlot.DOWN0}}
    },
    [RoomShape.ROOMSHAPE_2x1] = {
        {0, 0, Doors = {UP = DoorSlot.UP0, DOWN = DoorSlot.DOWN0, LEFT = DoorSlot.LEFT0}},
        {1, 0, Doors = {UP = DoorSlot.UP1, DOWN = DoorSlot.DOWN1, RIGHT = DoorSlot.RIGHT0}}
    },
    [RoomShape.ROOMSHAPE_1x2] = {
        {0, 0, Doors = {UP = DoorSlot.UP0, LEFT = DoorSlot.LEFT0, RIGHT = DoorSlot.RIGHT0}},
        {0, 1, Doors = {DOWN = DoorSlot.DOWN0, LEFT = DoorSlot.LEFT1, RIGHT = DoorSlot.RIGHT1}}
    },
    [RoomShape.ROOMSHAPE_IIH] = {
        {0, 0, Doors = {LEFT = DoorSlot.LEFT0}},
        {1, 0, Doors = {RIGHT = DoorSlot.RIGHT0}}
    },
    [RoomShape.ROOMSHAPE_IIV] = {
        {0, 0, Doors = {UP = DoorSlot.UP0}},
        {0, 1, Doors = {DOWN = DoorSlot.DOWN0}}
    },
    [RoomShape.ROOMSHAPE_2x2] = {
        {0, 0, Doors = {UP = DoorSlot.UP0, LEFT = DoorSlot.LEFT0}},
        {1, 0, Doors = {UP = DoorSlot.UP1, RIGHT = DoorSlot.RIGHT0}},
        {0, 1, Doors = {DOWN = DoorSlot.DOWN0, LEFT = DoorSlot.LEFT1}},
        {1, 1, Doors = {DOWN = DoorSlot.DOWN1, RIGHT = DoorSlot.RIGHT1}}
    },
    [RoomShape.ROOMSHAPE_LBL] = {
        {0, 0, Doors = {UP = DoorSlot.UP0, DOWN = DoorSlot.DOWN0, LEFT = DoorSlot.LEFT0}},
        {1, 0, Doors = {UP = DoorSlot.UP1, RIGHT = DoorSlot.RIGHT0}},
        {1, 1, Doors = {DOWN = DoorSlot.DOWN1, LEFT = DoorSlot.LEFT1, RIGHT = DoorSlot.RIGHT1}}
    },
    [RoomShape.ROOMSHAPE_LBR] = {
        {0, 0, Doors = {UP = DoorSlot.UP0, LEFT = DoorSlot.LEFT0}},
        {1, 0, Doors = {UP = DoorSlot.UP1, DOWN = DoorSlot.DOWN1, RIGHT = DoorSlot.RIGHT0}},
        {0, 1, Doors = {DOWN = DoorSlot.DOWN0, LEFT = DoorSlot.LEFT1, RIGHT = DoorSlot.RIGHT1}}
    },
    [RoomShape.ROOMSHAPE_LTL] = {
        {1, 0, Doors = {UP = DoorSlot.UP1, LEFT = DoorSlot.LEFT0, RIGHT = DoorSlot.RIGHT0}},
        {0, 1, Doors = {UP = DoorSlot.UP0, DOWN = DoorSlot.DOWN0, LEFT = DoorSlot.LEFT1}},
        {1, 1, Doors = {DOWN = DoorSlot.DOWN1, RIGHT = DoorSlot.RIGHT1}}
    },
    [RoomShape.ROOMSHAPE_LTR] = {
        {0, 0, Doors = {UP = DoorSlot.UP0, LEFT = DoorSlot.LEFT0, RIGHT = DoorSlot.RIGHT0}},
        {0, 1, Doors = {DOWN = DoorSlot.DOWN0, LEFT = DoorSlot.LEFT1}},
        {1, 1, Doors = {UP = DoorSlot.UP1, DOWN = DoorSlot.DOWN1, RIGHT = DoorSlot.RIGHT1}}
    }
}

---@class LevelMap.RoomSegment
---@field X integer
---@field Y integer
---@field Segment integer
---@field Doors table<"LEFT"|"UP"|"RIGHT"|"DOWN", DoorSlot>

---@param roomX integer
---@param roomY integer
---@param shape RoomShape
---@return LevelMap.RoomSegment[]
function StageAPI.GetRoomMapSegments(roomX, roomY, shape)
    local onMap = {}
    local segments = StageAPI.RoomShapeToSegments[shape]
    for i, seg in ipairs(segments) do
        local x, y = roomX + seg[1], roomY + seg[2]
        onMap[#onMap + 1] = {X = x, Y = y, Doors = seg.Doors, Segment = i}
    end

    return onMap
end

---@param roomObject RoomDescriptor | LevelMap.RoomData | integer
---@param noCaching? boolean
---@param noInterference? boolean
---@return LevelMap.RoomSegment[]
function StageAPI.GetMapSegmentsFromRoomObject(roomObject, noCaching, noInterference)
    local typ = type(roomObject)
    if typ == "table" then
        if roomObject.MapSegments then
            return roomObject.MapSegments
        elseif roomObject.X and roomObject.Y and roomObject.Shape then
            local segs = StageAPI.GetRoomMapSegments(roomObject.X, roomObject.Y, roomObject.Shape)
            if not noInterference then
                roomObject.MapSegments = segs
            end

            return segs
        end
    elseif typ == "userdata" then
        local x, y = StageAPI.GridToVector(roomObject.GridIndex, 13)
        local shape = roomObject.Data.Shape
        return StageAPI.GetRoomMapSegments(x, y, shape)
    elseif typ == "number" then
        return StageAPI.GetMapSegmentsFromRoomObject(shared.Level:GetRoomByIdx(roomObject), noCaching)
    end
end

---@return LevelMap
function StageAPI.CopyCurrentLevelMap()
    local levelMap = StageAPI.LevelMap()
    local roomsList = shared.Level:GetRooms()
    for i = 0, roomsList.Size do
        local roomDesc = roomsList:Get(i)
        if roomDesc then
            local id = "CL" .. tostring(i)
            local layout = StageAPI.GenerateRoomLayoutFromData(roomDesc.Data)
            StageAPI.RegisterLayout(id, layout)
            local newRoom = StageAPI.LevelRoom{
                LayoutName = id,
                SpawnSeed = roomDesc.SpawnSeed,
                AwardSeed = roomDesc.AwardSeed,
                DecorationSeed = roomDesc.DecorationSeed,
                Shape = roomDesc.Data.Shape,
                RoomType = roomDesc.Data.Type,
                IsClear = roomDesc.Clear,
                HasWaterPits = roomDesc.HasWater,
                SurpriseMiniboss = roomDesc.SurpriseMiniboss,
                IsPersistentRoom = true,
                IsExtraRoom = true,
                LevelIndex = id
            }

            local addedRoomData = levelMap:AddRoom(newRoom, {GridIndex = roomDesc.GridIndex, AutoDoors = true}, true)
            if shared.Level:GetStartingRoomIndex() == roomDesc.SafeGridIndex then
                levelMap.StartingRoom = addedRoomData.MapID
            end
        end
    end

    levelMap:SetAllRoomDoors()
    return levelMap
end

local directionStringSwap = {
    LEFT = "RIGHT",
    RIGHT = "LEFT",
    UP = "DOWN",
    DOWN = "UP"
}

---@param segs1 LevelMap.RoomSegment[]
---@param segs2 LevelMap.RoomSegment[]
---@param getDoors? boolean
---@param getSegs? boolean
---@return boolean
---@return table<DoorSlot, DoorSlot>|{[1]: LevelMap.RoomSegment, [2]: LevelMap.RoomSegment, [3]: "LEFT"|"UP"|"RIGHT"|"DOWN"}[]?
---@return {[1]: LevelMap.RoomSegment, [2]: LevelMap.RoomSegment, [3]: "LEFT"|"UP"|"RIGHT"|"DOWN"}[]?
function StageAPI.CheckAdjacentRoomSegments(segs1, segs2, getDoors, getSegs)
    local adjacentSegments = {}
    for _, seg in ipairs(segs1) do
        for _, seg2 in ipairs(segs2) do
            if seg.X == seg2.X or seg.Y == seg2.Y then -- only aligned segments could possibly be adjacent
                local adjacencyType
                if seg.X == seg2.X + 1 then
                    adjacencyType = "LEFT"
                elseif seg.X == seg2.X - 1 then
                    adjacencyType = "RIGHT"
                elseif seg.Y == seg2.Y + 1 then
                    adjacencyType = "UP"
                elseif seg.Y == seg2.Y - 1 then
                    adjacencyType = "DOWN"
                end

                if adjacencyType then
                    adjacentSegments[#adjacentSegments + 1] = {seg, seg2, adjacencyType}

                    if not (getDoors or getSegs) then
                        return true
                    end
                end
            end
        end
    end

    if #adjacentSegments > 0 then
        local doors
        if getDoors then
            doors = {}
            for _, pair in ipairs(adjacentSegments) do
                local seg, seg2, adjType = pair[1], pair[2], pair[3]
                if seg.Doors[adjType] and seg2.Doors[directionStringSwap[adjType]] then
                    doors[seg.Doors[adjType]] = seg2.Doors[directionStringSwap[adjType]]
                end
            end

            if getSegs then
                return true, doors, adjacentSegments
            else
                return true, doors
            end
        else -- getDoors or getSegs will always be true in adjacent rooms since otherwise the function is cut short
            return true, adjacentSegments
        end
    end

    return false
end

---@param room1 RoomDescriptor | LevelMap.RoomData | integer
---@param room2 RoomDescriptor | LevelMap.RoomData | integer
---@param getDoors? boolean
---@param getSegs? boolean
---@param preventCaching? boolean
---@return boolean
---@return table<DoorSlot, DoorSlot>|{[1]: LevelMap.RoomSegment, [2]: LevelMap.RoomSegment, [3]: "LEFT"|"UP"|"RIGHT"|"DOWN"}[]?
---@return {[1]: LevelMap.RoomSegment, [2]: LevelMap.RoomSegment, [3]: "LEFT"|"UP"|"RIGHT"|"DOWN"}[]?
function StageAPI.CheckRoomAdjacency(room1, room2, getDoors, getSegs, preventCaching) -- Checks if two rooms are adjacent on the map; if getDoors is true, returns the doors in room1 paired to the doors they connect to in room2
    local segs1, segs2 = StageAPI.GetMapSegmentsFromRoomObject(room1, preventCaching), StageAPI.GetMapSegmentsFromRoomObject(room2, preventCaching)
    return StageAPI.CheckAdjacentRoomSegments(segs1, segs2, getDoors, getSegs)
end

---@param levelRoom LevelRoom
---@param roomData LevelMap.RoomData
---@param levelMap? LevelMap
function StageAPI.LoadCustomMapRoomDoors(levelRoom, roomData, levelMap)
    levelMap = levelMap or StageAPI.GetCurrentLevelMap()
    if roomData.Doors then
        for slot, doorData in pairs(roomData.Doors) do
            ---@type LevelRoom
            local targetLevelRoom = levelMap:GetRoom(doorData.ExitRoom)
            local cancelSpawn = StageAPI.CallCallbacks(Callbacks.PRE_LEVELMAP_SPAWN_DOOR, true, slot, doorData, levelRoom, targetLevelRoom, roomData, levelMap)

            if not cancelSpawn then
                local current, target = levelRoom.RoomType, targetLevelRoom.RoomType
                local isBossAmbush = nil
                local isPayToPlay = nil
                -- TODO: check flatfile in custom doors, could check item but vanilla 
                -- behavior is setting VarData to 1 which persists even without item
                local isFlatfiled = nil
                local isSurpriseMiniboss = levelRoom.SurpriseMiniboss
                local useSprite, useDoor = StageAPI.CompareDoorSpawns(
                    StageAPI.BaseDoorSpawnList, current, target, 
                    isBossAmbush, isPayToPlay, isSurpriseMiniboss, isFlatfiled
                )
                StageAPI.SpawnCustomDoor(slot, doorData.ExitRoom, levelMap, useDoor, nil, doorData.ExitSlot, useSprite)
            end
        end
    end
end

StageAPI.AddCallback("StageAPI", Callbacks.POST_ROOM_LOAD, -1, function(newRoom, firstLoad)
    local levelMap = StageAPI.GetCurrentLevelMap()
    local roomData = levelMap:GetCurrentRoomData()
    if roomData and roomData.AutoDoors and firstLoad then
        StageAPI.LoadCustomMapRoomDoors(newRoom, roomData, levelMap)
    end
end)

StageAPI.AddCallback("StageAPI", Callbacks.POST_CHANGE_ROOM_GFX, -1, function(currentRoom)
    if StageAPI.InExtraRoom() and currentRoom and currentRoom.IsExtraRoom and not StageAPI.CurrentStage then
        local baseFloorInfo = StageAPI.GetBaseFloorInfo()
        if baseFloorInfo and shared.Room:GetBackdropType() == baseFloorInfo.Backdrop and baseFloorInfo.RoomGfx then
            StageAPI.ChangeDoors(baseFloorInfo.RoomGfx)
        end
    end
end)

function StageAPI.InitCustomLevel(levelMap, levelStartRoom)
    if levelStartRoom then
        if levelStartRoom == true then
            levelStartRoom = levelMap.StartingRoom
        end

        StageAPI.ExtraRoomTransition(levelStartRoom, Direction.NO_DIRECTION, -1, levelMap, nil, nil, Vector(320, 380))
    end
end