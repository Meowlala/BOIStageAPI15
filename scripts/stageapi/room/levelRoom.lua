local shared = require("scripts.stageapi.shared")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

---@class LevelRoomArgs
---@field LayoutName string
---@field RoomsList RoomsList
---@field SpawnSeed integer
---@field Shape RoomShape
---@field RoomType RoomType
---@field IsExtraRoom boolean
---@field FromSave boolean
---@field RequireRoomType boolean
---@field IgnoreDoors boolean
---@field Doors table<integer, boolean>
---@field LevelIndex integer
---@field IgnoreRoomRules boolean
---@field ReplaceVSStreak string

---Default room args, but not necessarily only possible ones
---@param layoutName string
---@param roomsList? RoomsList
---@param seed? integer
---@param shape? RoomShape
---@param roomType? RoomType
---@param isExtraRoom? boolean
---@param fromSaveData? boolean
---@param requireRoomType? boolean
---@param ignoreDoors? boolean
---@param doors? table<DoorSlot, boolean>
---@param levelIndex? integer
---@param ignoreRoomRules? boolean
---@param replaceVSStreak? string
---@return LevelRoomArgs
function StageAPI.LevelRoomArgPacker(layoutName, roomsList, seed, shape, roomType, isExtraRoom, fromSaveData, requireRoomType, ignoreDoors, doors, levelIndex, ignoreRoomRules, replaceVSStreak)
    return {
        LayoutName = layoutName,
        RoomsList = roomsList,
        SpawnSeed = seed,
        Shape = shape,
        RoomType = roomType,
        IsExtraRoom = isExtraRoom,
        FromSave = fromSaveData,
        RequireRoomType = requireRoomType,
        IgnoreDoors = ignoreDoors,
        Doors = doors,
        LevelIndex = levelIndex,
        IgnoreRoomRules = ignoreRoomRules,
        ReplaceVSStreak = replaceVSStreak,
    }
end

local levelRoomCopyFromArgs = {
    "IsExtraRoom",
    "LevelIndex",
    "IgnoreDoors",
    "Doors",
    "IgnoreShape",
    "Shape",
    "RoomType",
    "SpawnSeed",
    "LayoutName",
    "RequireRoomType",
    "IgnoreRoomRules",
    "DecorationSeed",
    "AwardSeed",
    "VisitCount",
    "IsClear",
    "ClearCount",
    "IsPersistentRoom",
    "HasWaterPits",
    "ChallengeDone",
    "FromData",
    "Dimension",
    "RoomsListName",
    "RoomsListID",
    "ReplaceVSStreak",
}

---@param layoutName string
---@param roomsList? RoomsList
---@param seed? integer
---@param shape? RoomShape
---@param roomType? RoomType
---@param isExtraRoom? boolean
---@param fromSaveData? boolean
---@param requireRoomType? boolean
---@param ignoreDoors? boolean
---@param doors? table<DoorSlot, boolean>
---@param levelIndex? integer
---@param ignoreRoomRules? boolean
---@return LevelRoom
---@overload fun(args: LevelRoomArgs): LevelRoom
function StageAPI.LevelRoom(layoutName, roomsList, seed, shape, roomType, isExtraRoom, fromSaveData, requireRoomType, ignoreDoors, doors, levelIndex, ignoreRoomRules)
end
--Duplicated field to make this easy on the Lua linter

--- Constructor: (layoutName, roomsList, seed, shape, roomType, isExtraRoom, fromSaveData, requireRoomType, ignoreDoors, doors, levelIndex, ignoreRoomRules)
--- Or constructor: (args) where args is a table of fields to initialize the room with
---@class LevelRoom
---@field LayoutName string
---@field RoomsList RoomsList
---@field SpawnSeed integer
---@field Shape RoomShape
---@field RoomType RoomType
---@field IsExtraRoom boolean
---@field FromSave boolean
---@field RequireRoomType boolean
---@field IgnoreDoors boolean
---@field Doors table<DoorSlot, boolean>
---@field LevelIndex integer
---@field IgnoreRoomRules boolean
---@field FromData boolean
---@field RoomDescriptor RoomDescriptor #can be passed to initialize the room with the descriptor's data
---@field RoomsListID integer
---@field IgnoreShape boolean
---@field ReplaceVSStreak string
StageAPI.LevelRoom = StageAPI.Class("LevelRoom")
StageAPI.NextUniqueRoomIdentifier = 0
function StageAPI.LevelRoom:Init(args, ...)
    if type(args) ~= "table" then
        args = StageAPI.LevelRoomArgPacker(args, ...)
    end

    StageAPI.LogMinor("Initializing room")
    StageAPI.CurrentlyInitializing = self
    self.UniqueRoomIdentifier = StageAPI.NextUniqueRoomIdentifier
    StageAPI.NextUniqueRoomIdentifier = StageAPI.NextUniqueRoomIdentifier + 1

    if args.FromSave then
        StageAPI.LogMinor("Loading from save data")
        self:LoadSaveData(args.FromSave)
    else
        StageAPI.LogMinor("Generating room")

        local roomDesc = args.RoomDescriptor

        self.Data = {}
        self.PersistentData = {}
        self.AvoidSpawning = {}
        self.ExtraSpawn = {}
        self.PersistenceData = {}
        self.FirstLoad = true

        for _, v in ipairs(levelRoomCopyFromArgs) do
            if args[v] ~= nil then
                self[v] = args[v]
            end
        end

        self.RoomType = self.RoomType or (roomDesc and roomDesc.Data.Type) or RoomType.ROOM_DEFAULT
        self.Shape = self.Shape or (roomDesc and roomDesc.Data.Shape) or RoomShape.ROOMSHAPE_1x1
        self.SpawnSeed = self.SpawnSeed or (roomDesc and roomDesc.SpawnSeed) or Random()
        self.DecorationSeed = self.DecorationSeed or (roomDesc and roomDesc.DecorationSeed) or Random()
        self.AwardSeed = self.AwardSeed or (roomDesc and roomDesc.AwardSeed) or Random()
        self.SurpriseMiniboss = self.SurpriseMiniboss or (roomDesc and roomDesc.SurpriseMiniboss) or false
        self.Doors = self.Doors or (roomDesc and StageAPI.GetDoorsForRoomFromData(roomDesc.Data)) or StageAPI.Copy(StageAPI.AllDoorsOpen)
        self.VisitCount = self.VisitCount or (roomDesc and roomDesc.VisitedCount) or 0
        self.ClearCount = self.ClearCount or (roomDesc and roomDesc.ClearCount) or 0

        self.Dimension = self.Dimension or StageAPI.GetDimension(roomDesc)

        if args.RoomsList then
            self.RoomsListName = self.RoomsListName or args.RoomsList.Name
        end

        -- backwards compatibility
        self.Seed = self.SpawnSeed

        self:GetLayout()
        self:PostGetLayout(self.SpawnSeed)
    end

    StageAPI.CallCallbacks(Callbacks.POST_ROOM_INIT, false, self, not not args.FromSave, args.FromSave)
    StageAPI.CurrentlyInitializing = nil
end

function StageAPI.LevelRoom:Copy(roomDesc)
    local args = {
        RoomDescriptor = roomDesc,
        Layout = self.Layout,
        LayoutName = self.LayoutName,
        RoomsListName = self.RoomsListName
    }

    for _, v in ipairs(levelRoomCopyFromArgs) do
        args[v] = args[v] or self[v]
    end

    local newLevelRoom = StageAPI.LevelRoom(args)
    newLevelRoom.PersistentData = StageAPI.DeepCopy(self.PersistentData)
    newLevelRoom.Data = StageAPI.DeepCopy(self.Data)

    return newLevelRoom
end

function StageAPI.LevelRoom:GetLayout()
    if self.FromData and not self.Layout then
        local roomDesc = shared.Level:GetRooms():Get(self.FromData)
        if not roomDesc then
            if self.FromData == 509 then
                roomDesc = shared.Level:GetRoomByIdx(GridRooms.ROOM_DEBUG_IDX)
            end
        end

        if roomDesc then
            self.Layout = StageAPI.GenerateRoomLayoutFromData(roomDesc.Data)
        end
    end

    if self.LayoutName and not self.Layout then
        self.Layout = StageAPI.Layouts[self.LayoutName]
    end

    if self.RoomsListName and self.RoomsListID and not self.Layout then
        local roomsList = StageAPI.RoomsLists[self.RoomsListName]
        if roomsList then
            local layouts = roomsList:GetRooms(self.Shape)
            if layouts and layouts[self.RoomsListID] then
                self.Layout = layouts[self.RoomsListID]
            end
        end
    end

    if self.RoomsListName and not self.Layout then
        local roomsList = StageAPI.CallCallbacks(Callbacks.PRE_ROOMS_LIST_USE, true, self) or StageAPI.RoomsLists[self.RoomsListName]
        if roomsList then
            self.RoomsListName = roomsList.Name

            local retLayout = StageAPI.CallCallbacks(Callbacks.PRE_ROOM_LAYOUT_CHOOSE, true, self, roomsList)
            if retLayout then
                self.Layout = retLayout
            else
                self.Layout = StageAPI.ChooseRoomLayout{
                    RoomList = roomsList,
                    Seed = self.SpawnSeed,
                    IgnoreShape = self.IgnoreShape,
                    Shape = self.Shape,
                    RoomType = self.RoomType,
                    RequireRoomType = self.RequireRoomType,
                    IgnoreDoors = self.IgnoreDoors,
                    Doors = self.Doors
                }

                if self.IgnoreShape then
                    self.Shape = self.Layout.Shape
                end

                if self.IgnoreDoors then
                    self.Doors = {}
                    for _, door in ipairs(self.Layout.Doors) do
                        self.Doors[door.Slot] = door.Exists
                    end
                end
            end
        end
    end
end

function StageAPI.LevelRoom:PostGetLayout(seed)
    if not self.Layout then
        if self.Shape == -1 then
            self.Shape = RoomShape.ROOMSHAPE_1x1
        end

        self.Layout = StageAPI.CreateEmptyRoomLayout(self.Shape)
        StageAPI.LogErr("No layout!")
    end

    StageAPI.LogMinor("Initialized room " .. tostring(self.Layout.Name) .. "." .. tostring(self.Layout.Variant) .. " from file " .. tostring(self.Layout.RoomFilename)
                        .. (self.RoomsListName and (' from list ' .. self.RoomsListName) or ''))

    if self.Shape == -1 then
        self.Shape = self.Layout.Shape
    end

    self.SpawnEntities, self.SpawnGrids, self.EntityTakenIndices, self.GridTakenIndices, self.LastPersistentIndex, self.Metadata = StageAPI.ObtainSpawnObjects(self.Layout, seed)
    self.Metadata.LevelRoom = self
end

function StageAPI.LevelRoom:IsGridIndexFree(index, ignoreEntities, ignoreGrids)
    return (ignoreEntities or not self.EntityTakenIndices[index]) and (ignoreGrids or not self.GridTakenIndices[index])
end

function StageAPI.LevelRoom:SaveGridInformation()
    self.GridInformation = StageAPI.GetGridInformation()
end

function StageAPI.LevelRoom:GetPersistenceData(index, setIfNot)
    if type(index) ~= "number" then
        if index.Metadata then
            index = index.PersistentIndex
        else
            index = StageAPI.GetEntityPersistenceData(index)
        end
    end

    if index then
        if setIfNot and not self.PersistenceData[index] then
            self.PersistenceData[index] = {}
        end

        return self.PersistenceData[index]
    end
end

function StageAPI.LevelRoom:GetNextPersistentIndex()
    self.LastPersistentIndex = self.LastPersistentIndex + 1
    return self.LastPersistentIndex
end

function StageAPI.LevelRoom:SavePersistentEntities()
    local checkExistenceOf = {}
    for hash, entityPersistData in pairs(StageAPI.ActiveEntityPersistenceData) do
        if entityPersistData.Data.RemoveOnRemove then
            checkExistenceOf[hash] = entityPersistData
        end
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        checkExistenceOf[GetPtrHash(entity)] = nil

        local data = entity:GetData()
        local persistentIndex, persistData = StageAPI.GetEntityPersistenceData(entity)
        if persistentIndex then
            local changedSpawn
            local entityPersistData = self:GetPersistenceData(persistentIndex, true)
            if persistData.UpdateType then
                if entity.Type ~= entityPersistData.Type then
                    entityPersistData.Type = entity.Type
                    changedSpawn = true
                end
            end

            if persistData.UpdateVariant then
                if entity.Variant ~= entityPersistData.Variant then
                    entityPersistData.Variant = entity.Variant
                    changedSpawn = true
                end
            end

            if persistData.UpdateSubType then
                if entity.SubType ~= entityPersistData.SubType then
                    entityPersistData.SubType = entity.SubType
                    changedSpawn = true
                end
            end

            if persistData.UpdateHealth then
                if entity.HitPoints ~= entityPersistData.Health then
                    entityPersistData.Health = entity.HitPoints
                end
            end

            if persistData.UpdatePosition then
                entityPersistData.Position = {X = entity.Position.X, Y = entity.Position.Y}
            end

            if persistData.UpdatePrice and entity.Type == EntityType.ENTITY_PICKUP then
                entityPersistData.Price = {Price = entity:ToPickup().Price, AutoUpdate = entity:ToPickup().AutoUpdatePrice}
            end

            if persistData.StoreCheck and persistData.StoreCheck(entity, data) then
                self.AvoidSpawning[persistentIndex] = true
            end

            if changedSpawn then
                local newPersistData = StageAPI.CheckPersistence(entity.Type, entity.Variant, entity.SubType)
                if not newPersistData then
                    StageAPI.RemovePersistentEntity(entity)
                else
                    StageAPI.SetEntityPersistenceData(entity, persistentIndex, newPersistData)
                end
            end
        else
            local persistData = StageAPI.CheckPersistence(entity.Type, entity.Variant, entity.SubType)
            if persistData then
                if not persistData.StoreCheck or not persistData.StoreCheck(entity, data) then
                    local index = self:GetNextPersistentIndex()
                    local grindex = shared.Room:GetGridIndex(entity.Position)
                    if not self.ExtraSpawn[grindex] then
                        self.ExtraSpawn[grindex] = {}
                    end

                    local spawnData = {
                        Type = entity.Type,
                        Variant = entity.Variant,
                        SubType = entity.SubType,
                        Index = grindex
                    }

                    local spawnInfo = {
                        Data = spawnData,
                        Persistent = true,
                        PersistentIndex = index
                    }

                    self.ExtraSpawn[grindex][#self.ExtraSpawn[grindex] + 1] = spawnInfo

                    local entityPersistData = self:GetPersistenceData(index, true)
                    if persistData.UpdateHealth then
                        entityPersistData.Health = entity.HitPoints
                    end

                    if persistData.UpdatePosition then
                        entityPersistData.Position = {X = entity.Position.X, Y = entity.Position.Y}
                    end

                    if persistData.UpdatePrice and entity.Type == EntityType.ENTITY_PICKUP then
                        entityPersistData.Price = {Price = entity:ToPickup().Price, AutoUpdate = entity:ToPickup().AutoUpdatePrice}
                    end

                    StageAPI.SetEntityPersistenceData(entity, index, persistData)
                end
            end
        end
    end

    for hash, entityPersistData in pairs(checkExistenceOf) do
        self.AvoidSpawning[entityPersistData.Index] = true
    end
end

function StageAPI.LevelRoom:RemovePersistentIndex(persistentIndex)
    self.AvoidSpawning[persistentIndex] = true
end

function StageAPI.LevelRoom:RemovePersistentEntity(entity)
    local index, data = StageAPI.GetEntityPersistenceData(entity)
    if index and data then
        self:RemovePersistentIndex(index)
    end
end

function StageAPI.LevelRoom:Load(isExtraRoom, noIncrementVisit, clearNPCsOnly)
    StageAPI.LogMinor("Loading room " .. self.Layout.Name .. "." .. tostring(self.Layout.Variant) .. " from file " .. tostring(self.Layout.RoomFilename))
    if isExtraRoom == nil then
        isExtraRoom = self.IsExtraRoom
    end

    shared.Room:SetClear(true)

    if not noIncrementVisit then
        self.VisitCount = self.VisitCount + 1
    end

    local wasFirstLoad = self.FirstLoad
    StageAPI.ClearRoomLayout(false, self.FirstLoad or isExtraRoom, true, self.FirstLoad or isExtraRoom, self.GridTakenIndices, nil, nil, not self.FirstLoad, clearNPCsOnly)
    if self.FirstLoad then
        StageAPI.LoadRoomLayout(self.SpawnGrids, {self.SpawnEntities, self.ExtraSpawn}, true, true, self.IsClear, true, self.GridInformation, self.AvoidSpawning, self.PersistenceData)
        self.WasClearAtStart = shared.Room:IsClear()
        self.IsClear = self.WasClearAtStart
        self.FirstLoad = false
        self.HasEnemies = shared.Room:GetAliveEnemiesCount() > 0
    else
        StageAPI.LoadRoomLayout(self.SpawnGrids, {self.SpawnEntities, self.ExtraSpawn}, isExtraRoom, true, self.IsClear, isExtraRoom, self.GridInformation, self.AvoidSpawning, self.PersistenceData)
        self.IsClear = shared.Room:IsClear()
    end

    StageAPI.CalledRoomUpdate = true
    shared.Room:Update()
    StageAPI.CalledRoomUpdate = false
    if not self.IsClear then
        StageAPI.CloseDoors()
    end

    self.Loaded = true

    StageAPI.CallCallbacks(Callbacks.POST_ROOM_LOAD, false, self, wasFirstLoad, isExtraRoom)
    StageAPI.StoreRoomGrids()
end

function StageAPI.LevelRoom:Save()
    self:SavePersistentEntities()
    self:SaveGridInformation()
end

local saveDataCopyDirectly = {
    "IsClear","WasClearAtStart","RoomsListName","RoomsListID","LayoutName","SpawnSeed","AwardSeed","DecorationSeed",
    "FirstLoad","Shape","RoomType","TypeOverride","PersistentData","IsExtraRoom","LastPersistentIndex",
    "RequireRoomType", "IgnoreRoomRules", "VisitCount", "ClearCount", "LevelIndex","HasWaterPits","ChallengeDone",
    "SurpriseMiniboss", "FromData", "Dimension"
}

function StageAPI.LevelRoom:GetSaveData(isExtraRoom)
    if isExtraRoom == nil then
        isExtraRoom = self.IsExtraRoom
    end

    local saveData = {}

    for _, v in ipairs(saveDataCopyDirectly) do
        saveData[v] = self[v]
    end

    if isExtraRoom ~= nil then
        saveData.IsExtraRoom = isExtraRoom
    end

    if self.Doors then
        saveData.Doors = {}
        for i = 0, 7 do
            if self.Doors[i] then
                saveData.Doors[#saveData.Doors + 1] = i
            end
        end
    end

    if self.GridInformation then
        for index, gridInfo in pairs(self.GridInformation) do
            if not saveData.GridInformation then
                saveData.GridInformation = {}
            end

            saveData.GridInformation[tostring(index)] = gridInfo
        end
    end

    for index, avoid in pairs(self.AvoidSpawning) do
        if avoid then
            if not saveData.AvoidSpawning then
                saveData.AvoidSpawning = {}
            end

            saveData.AvoidSpawning[#saveData.AvoidSpawning + 1] = index
        end
    end

    for pindex, persistData in pairs(self.PersistenceData) do
        if not saveData.PersistenceData then
            saveData.PersistenceData = {}
        end

        saveData.PersistenceData[tostring(pindex)] = persistData
    end

    for index, entities in pairs(self.ExtraSpawn) do
        if not saveData.ExtraSpawn then
            saveData.ExtraSpawn = {}
        end

        saveData.ExtraSpawn[tostring(index)] = entities
    end

    return saveData
end

function StageAPI.LevelRoom:LoadSaveData(saveData)
    self.Data = {}
    self.AvoidSpawning = {}
    self.PersistenceData = {}
    self.ExtraSpawn = {}

    for _, v in ipairs(saveDataCopyDirectly) do
        self[v] = saveData[v]
    end

    self.Seed = self.AwardSeed -- backwards compatibility
    self.PersistentData = self.PersistentData or {}

    if saveData.Doors then
        self.Doors = {}
        for _, door in ipairs(saveData.Doors) do
            self.Doors[door] = true
        end

        for i = 0, 7 do
            if not self.Doors[i] then
                self.Doors[i] = false
            end
        end
    end

    self:GetLayout()
    self:PostGetLayout(self.SpawnSeed)

    self.LastPersistentIndex = self.LastPersistentIndex or self.LastPersistentIndex

    if saveData.GridInformation then
        for strindex, gridInfo in pairs(saveData.GridInformation) do
            if not self.GridInformation then
                self.GridInformation = {}
            end

            self.GridInformation[tonumber(strindex)] = gridInfo
        end
    end

    if saveData.AvoidSpawning then
        for _, index in ipairs(saveData.AvoidSpawning) do
            self.AvoidSpawning[index] = true
        end
    end

    if saveData.PersistenceData then
        for strindex, persistData in pairs(saveData.PersistenceData) do
            self.PersistenceData[tonumber(strindex)] = persistData
        end
    end

    if saveData.ExtraSpawn then
        for strindex, entities in pairs(saveData.ExtraSpawn) do
            self.ExtraSpawn[tonumber(strindex)] = entities
        end
    end
end

function StageAPI.LevelRoom:SetTypeOverride(override)
    self.TypeOverride = override
end

function StageAPI.LevelRoom:GetType()
    return self.TypeOverride or self.RoomType
end
