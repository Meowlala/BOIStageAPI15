local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

-- Room handler
-- Actually uses the elements defined in the other lua files
-- in this folder and does the game logic

local EFFECT_SUBTYPE_MOONLIGHT = 1 -- Luna light beam in secret rooms

local excludeTypesFromClearing = {
    [EntityType.ENTITY_FAMILIAR] = true,
    [EntityType.ENTITY_PLAYER] = true,
    [EntityType.ENTITY_KNIFE] = true,
    [EntityType.ENTITY_BLOOD_PUPPY] = true,
    [EntityType.ENTITY_DARK_ESAU] = true,
    [EntityType.ENTITY_MOTHERS_SHADOW] = true,
    [EntityType.ENTITY_EFFECT] = {
        [EffectVariant.HEAVEN_LIGHT_DOOR] = {
            [EFFECT_SUBTYPE_MOONLIGHT] = true,
        },
        [EffectVariant.BLOOD_SPLAT] = true,
        [EffectVariant.WISP] = true,
    },
}

-- These rooms consist purely of wall entities placed where the walls of the room should be
-- Used to fix the occasional broken walls when entering extra rooms
StageAPI.WallDataLayouts = StageAPI.RoomsList("StageAPIWallData", include("resources.stageapi.luarooms.walldata"))
StageAPI.WallData = {}
for name, shape in pairs(RoomShape) do
    local layouts = StageAPI.WallDataLayouts.ByShape[shape]
    if layouts and layouts[1] then
        local layout = layouts[1]
        local lowIndex
        StageAPI.WallData[shape] = {Indices = {}}
        for index, grids in pairs(layout.GridEntitiesByIndex) do
            if not lowIndex or index < lowIndex then
                lowIndex = index
            end

            if grids[1].Type == GridEntityType.GRID_WALL then
                StageAPI.WallData[shape].Indices[index] = true
            end
        end

        StageAPI.WallData[shape].TopLeft = lowIndex
    end
end

function StageAPI.FixWalls()
    local shape = shared.Room:GetRoomShape()
    local data = StageAPI.WallData[shape]
    if data then
        for index, _ in pairs(data.Indices) do
            local grid = shared.Room:GetGridEntity(index)
            if not grid or (grid.Desc.Type ~= GridEntityType.GRID_WALL and grid.Desc.Type ~= GridEntityType.GRID_DOOR) then
                shared.Room:SpawnGridEntity(index, GridEntityType.GRID_WALL, 0, 1, 0)
            end
        end

        for i = 0, shared.Room:GetGridSize() do
            local grid = shared.Room:GetGridEntity(i)
            if not data.Indices[i] and grid and grid.Desc.Type == GridEntityType.GRID_WALL and not shared.Room:IsPositionInRoom(grid.Position, 0) then
                shared.Room:RemoveGridEntity(i, 0, false)
                shared.Room:SetGridPath(i, 0)
            end
        end
    end
end

local function ShouldExcludeEntityFromClearing(entity)
    return excludeTypesFromClearing[entity.Type] == true
        or (
            type(excludeTypesFromClearing[entity.Type]) == "table"
            and excludeTypesFromClearing[entity.Type][entity.Variant] == true
        )
        or (
            type(excludeTypesFromClearing[entity.Type]) == "table"
            and type(excludeTypesFromClearing[entity.Type][entity.Variant]) == "table"
            and excludeTypesFromClearing[entity.Type][entity.Variant][entity.SubType]
        )
end

---@param keepDecoration? boolean
---@param doGrids? boolean
---@param doEnts? boolean
---@param doPersistentEnts? boolean
---@param onlyRemoveTheseDecorations? table<integer, boolean>
---@param doWalls? boolean
---@param doDoors? boolean
---@param skipIndexedGrids? boolean
---@param doNPCsOnly? boolean
function StageAPI.ClearRoomLayout(keepDecoration, doGrids, doEnts, doPersistentEnts, onlyRemoveTheseDecorations, doWalls, doDoors, skipIndexedGrids, doNPCsOnly)
    if StageAPI.InOrTransitioningToExtraRoom() and shared.Room:GetType() ~= RoomType.ROOM_DUNGEON then
        StageAPI.FixWalls()
    end

    if doEnts or doPersistentEnts then
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if not ShouldExcludeEntityFromClearing(ent) and (not doNPCsOnly or ent:ToNPC()) then
                local persistentData = StageAPI.CheckPersistence(ent.Type, ent.Variant, ent.SubType)
                if (doPersistentEnts or (ent:ToNPC() and (not persistentData or not persistentData.AutoPersists))) and not (ent:HasEntityFlags(EntityFlag.FLAG_CHARM) or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT)) then
                    ent:Remove()
                end
            end
        end
    end

    if doGrids and not doNPCsOnly then
        if not skipIndexedGrids then
            local lindex = StageAPI.GetCurrentRoomID()
            local customGrids = StageAPI.GetTableIndexedByDimension(StageAPI.CustomGrids, true)
            customGrids[lindex] = {}

            local roomGrids = StageAPI.GetTableIndexedByDimension(StageAPI.RoomGrids, true)
            roomGrids[lindex] = {}

            StageAPI.CustomGridEntities = {}
        end

        for i = 0, shared.Room:GetGridSize() do
            local grid = shared.Room:GetGridEntity(i)
            if grid then
                local gtype = grid.Desc.Type
                if (doWalls or gtype ~= GridEntityType.GRID_WALL or shared.Room:IsPositionInRoom(grid.Position, 0)) -- this allows custom wall grids to exist
                and (doDoors or gtype ~= GridEntityType.GRID_DOOR)
                and (not onlyRemoveTheseDecorations or gtype ~= GridEntityType.GRID_DECORATION or onlyRemoveTheseDecorations[i]) then
                    shared.Room:RemoveGridEntity(i, 0, keepDecoration)
                    shared.Room:SetGridPath(i, 0)
                end
            else
                shared.Room:SetGridPath(i, 0)
            end
        end
    end

    StageAPI.CalledRoomUpdate = true
    shared.Room:Update()
    StageAPI.CalledRoomUpdate = false
end

---@param layout RoomLayout
---@param doors table<DoorSlot, boolean>
---@return boolean doesLayoutMatch
---@return integer numNonExistingDoors
function StageAPI.DoLayoutDoorsMatch(layout, doors)
    local numNonExistingDoors = 0
    local doesLayoutMatch = true
    for _, door in ipairs(layout.Doors) do
        if door.Slot and not door.Exists then
            if ((not doors and shared.Room:GetDoor(door.Slot)) or (doors and doors[door.Slot])) then
                doesLayoutMatch = false
            end
            numNonExistingDoors = numNonExistingDoors + 1
        end
    end

    return doesLayoutMatch, numNonExistingDoors
end

---@class GetValidRoomsForLayout.Args
---@field RoomList RoomsList
---@field RoomDescriptor RoomDescriptor
---@field IgnoreShape boolean
---@field Shape RoomShape
---@field RoomType RoomType
---@field RequireRoomType boolean
---@field IgnoreDoors boolean
---@field Doors boolean[]
---@field Seed integer
---@field DisallowIDs any[]
---@field RequireSubtype integer?
---@field ForceRequiredSubtype boolean
---@field MinDifficulty integer
---@field MaxDifficulty integer

-- returns list of rooms, error message if no rooms valid
---@param args GetValidRoomsForLayout.Args
---@return {[1]: {Layout: RoomLayout, ListID: integer}, [2]: number} validRooms # second value is weight
---@return number? validRoomWeights
---@return string? errorMessage
function StageAPI.GetValidRoomsForLayout(args)
    local roomList = args.RoomList
    local roomDesc = args.RoomDescriptor or shared.Level:GetCurrentRoomDesc()
    local shape = -1
    if not args.IgnoreShape then
        shape = args.Shape or roomDesc.Data.Shape
    end

    local callbacks = StageAPI.GetCallbacks(Callbacks.POST_CHECK_VALID_ROOM)
    local validRooms = {}
    local validRoomWeights = 0

    local possibleRooms = roomList:GetRooms(shape)
    if not possibleRooms then
        return {}, nil, "No rooms for shape!"
    end

    local requireRoomType = args.RequireRoomType
    local rtype = args.RoomType or roomDesc.Data.Type

    local ignoreDoors = args.IgnoreDoors
    local doors = args.Doors or StageAPI.GetDoorsForRoomFromData(roomDesc.Data)

    local seed = args.Seed or roomDesc.SpawnSeed
    local disallowIDs = args.DisallowIDs

    local requireSubtype = args.RequireSubtype

    local mindiff = args.MinDifficulty
    local maxdiff = args.MaxDifficulty

    for listID, layout in ipairs(possibleRooms) do
        shape = layout.Shape

        local isValid = true

        local numNonExistingDoors = 0
        if requireRoomType and layout.Type ~= rtype then
            isValid = false
        elseif not ignoreDoors then
            isValid, numNonExistingDoors = StageAPI.DoLayoutDoorsMatch(layout, doors)
        end

        if isValid and requireSubtype then
            isValid = layout.SubType == requireSubtype
        elseif isValid and mindiff and maxdiff then
            isValid = (layout.Difficulty >= mindiff or layout.Difficulty <= maxdiff)
        end

        if isValid and disallowIDs then
            for _, id in ipairs(disallowIDs) do
                if layout.StageAPIID == id then
                    isValid = false
                    break
                end
            end
        end

        local weight = layout.Weight
        if isValid then
            for _, callback in ipairs(callbacks) do
                local success, ret = StageAPI.TryCallback(callback,
                        layout, roomList, seed, shape, rtype, requireRoomType)
                if success then
                    if ret == false then
                        isValid = false
                        break
                    elseif type(ret) == "number" then
                        weight = ret
                    end
                end
            end
        end

        if isValid then
            if StageAPI.CurrentlyInitializing and not StageAPI.CurrentlyInitializing.IsExtraRoom and rtype == RoomType.ROOM_DEFAULT then
                local originalWeight = weight
                weight = weight * 2 ^ numNonExistingDoors
                if shape == RoomShape.ROOMSHAPE_1x1 and numNonExistingDoors > 0 then
                    weight = weight + math.min(originalWeight * 4, 4)
                end
            end
        end

        if isValid then
            validRooms[#validRooms + 1] = {{Layout = layout, ListID = listID}, weight}
            validRoomWeights = validRoomWeights + weight
        end
    end

    return validRooms, validRoomWeights, nil
end

StageAPI.RoomChooseRNG = RNG()

---@param roomList RoomsList
---@param seed? integer
---@param shape? RoomShape
---@param rtype? RoomType
---@param requireRoomType? RoomType
---@param ignoreDoors? boolean
---@param doors? boolean[]
---@param disallowIDs? any[]
---@return RoomLayout?
---@return integer? listId
---@overload fun(args: GetValidRoomsForLayout.Args)
function StageAPI.ChooseRoomLayout(roomList, seed, shape, rtype, requireRoomType, ignoreDoors, doors, disallowIDs)
    ---@type GetValidRoomsForLayout.Args
    local args
    if roomList.Type ~= "RoomsList" then
        args = roomList
    else
        args = {
            RoomList = roomList,
            Seed = seed,
            Shape = shape,
            RoomType = rtype,
            RequireRoomType = requireRoomType,
            IgnoreDoors = ignoreDoors,
            Doors = doors,
            DisallowIDs = disallowIDs,
        }
    end

    local validRooms, totalWeight, err = StageAPI.GetValidRoomsForLayout(args)
    if err then StageAPI.LogErr(err) end

    if args.RequireSubtype and not args.ForceRequiredSubtype and #validRooms == 0 then
        StageAPI.LogWarn("No room with subtype ", args.RequireSubtype, " found, trying with any...")

        local requireSubtype = args.RequireSubtype
        args.RequireSubtype = nil

        validRooms, totalWeight, err = StageAPI.GetValidRoomsForLayout(args)
        if err then StageAPI.LogErr(err) end

        -- In case it's a static external object, do not alter it
        args.RequireSubtype = requireSubtype
    end

    if args.MinDifficulty and args.MaxDifficulty and #validRooms == 0 then
        StageAPI.LogWarn("No room in difficulty range ", args.MinDifficulty, "-", args.MaxDifficulty, " found, trying with any...")

        local minDiff = args.MinDifficulty
        local maxDiff = args.MaxDifficulty
        args.MinDifficulty = nil
        args.MaxDifficulty = nil

        validRooms, totalWeight, err = StageAPI.GetValidRoomsForLayout(args)
        if err then StageAPI.LogErr(err) end

        -- In case it's a static external object, do not alter it
        args.MinDifficulty = minDiff
        args.MaxDifficulty = maxDiff
    end

    if #validRooms > 0 then
        StageAPI.RoomChooseRNG:SetSeed(args.Seed, 0)
        local chosen = StageAPI.WeightedRNG(validRooms, StageAPI.RoomChooseRNG, nil, totalWeight)
        return chosen.Layout, chosen.ListID
    else
        StageAPI.LogErr("No rooms with correct shape and doors!")
    end
end

StageAPI.RoomLoadRNG = RNG()

---@class SpawnList.EntityInfo
---@field Data RoomLayout_EntityData
---@field PersistentIndex integer
---@field Persistent boolean

---@param tbl SpawnList.EntityInfo[]
---@param entData RoomLayout_EntityData
---@param persistentIndex integer
---@param index? integer
---@param noChampions? boolean
---@return integer lastPersistentIndex
function StageAPI.AddEntityToSpawnList(tbl, entData, persistentIndex, index, noChampions)
    local currentRoom = StageAPI.CurrentlyInitializing or StageAPI.GetCurrentRoom()
    if persistentIndex == nil and currentRoom then
        persistentIndex = currentRoom.LastPersistentIndex
        if currentRoom.LastPersistentIndex then
            currentRoom.LastPersistentIndex = currentRoom.LastPersistentIndex + 1
        end
    end

    if index and (tbl[index] and type(tbl[index]) == "table") then
        tbl = tbl[index]
    end

    entData = StageAPI.Copy(entData)

    entData.Type = entData.Type or 10
    entData.Variant = entData.Variant or 0
    entData.SubType = entData.SubType or 0
    entData.Index = entData.Index or index or 0
    
    if not noChampions and entData.Type > 9 and entData.Type < 1000 then
        if StageAPI.CanBeChampion(entData.Type, entData.Variant, entData.SubType) then
            if StageAPI.RoomLoadRNG:RandomFloat() <= StageAPI.GetChampionChance() then
                entData.ChampionSeed = StageAPI.RoomLoadRNG:GetSeed()
            end
        end
    end

    if not entData.GridX or not entData.GridY then
        local width
        if currentRoom and currentRoom.Layout and currentRoom.Layout.Width then
            width = currentRoom.Layout.Width
        else
            width = shared.Room:GetGridWidth()
        end

        entData.GridX, entData.GridY = StageAPI.GridToVector(index, width)
    end

    persistentIndex = persistentIndex + 1

    local persistentData = StageAPI.CheckPersistence(entData.Type, entData.Variant, entData.SubType)

    tbl[#tbl + 1] = {
        Data = entData,
        PersistentIndex = persistentIndex,
        Persistent = not not persistentData
    }

    return persistentIndex
end

---@param entities table<integer, RoomLayout_EntityData[]>
---@param seed? integer
---@param roomMetadata RoomMetadata
---@param lastPersistentIndex integer
---@param noChampions? boolean
---@return table<integer, SpawnList.EntityInfo[]> entitiesToSpawn
---@return integer lastPersistentIndex
function StageAPI.SelectSpawnEntities(entities, seed, roomMetadata, lastPersistentIndex, noChampions)
    StageAPI.RoomLoadRNG:SetSeed(seed or shared.Room:GetSpawnSeed(), 1)
    local entitiesToSpawn = {}
    local callbacks = StageAPI.GetCallbacks(Callbacks.PRE_SELECT_ENTITY_LIST)
    local persistentIndex = (lastPersistentIndex and lastPersistentIndex + 1) or 0
    for index, entityList in pairs(entities) do
        if #entityList > 0 then
            local addEntities = {}
            local overridden, stillAddRandom = false, nil
            for _, callback in ipairs(callbacks) do
                local success, retAdd, retList, retRandom = StageAPI.TryCallbackMultiReturn(callback, entityList, index, roomMetadata)
                if success then
                    if retRandom ~= nil and stillAddRandom == nil then
                        stillAddRandom = retRandom
                    end

                    if retAdd == false then
                        overridden = true
                    else
                        if retAdd and type(retAdd) == "table" then
                            addEntities = retAdd
                            overridden = true
                        end

                        if retList and type(retList) == "table" then
                            entityList = retList
                            overridden = true
                        end
                    end

                    if overridden then
                        break
                    end
                end
            end

            if not overridden or (stillAddRandom and #entityList > 0) then
                addEntities[#addEntities + 1] = entityList[StageAPI.Random(1, #entityList, StageAPI.RoomLoadRNG)]
            end

            if #addEntities > 0 then
                if not entitiesToSpawn[index] then
                    entitiesToSpawn[index] = {}
                end

                for _, entData in ipairs(addEntities) do
                    persistentIndex = StageAPI.AddEntityToSpawnList(entitiesToSpawn[index], entData, persistentIndex, nil, noChampions)
                end
            end
        end
    end

    return entitiesToSpawn, persistentIndex
end

---@param gridsByIndex table<integer, RoomLayout_GridData[]>
---@param seed? integer
---@return table<integer, RoomLayout_GridData>
function StageAPI.SelectSpawnGrids(gridsByIndex, seed)
    StageAPI.RoomLoadRNG:SetSeed(seed or shared.Room:GetSpawnSeed(), 1)
    local spawnGrids = {}

    local callbacks = StageAPI.GetCallbacks(Callbacks.PRE_SELECT_GRIDENTITY_LIST)
    for index, grids in pairs(gridsByIndex) do
        if #grids > 0 then
            local spawnGrid, noSpawnGrid
            for _, callback in ipairs(callbacks) do
                local success, ret = StageAPI.TryCallback(callback, grids, index)
                if success then
                    if ret == false then
                        noSpawnGrid = true
                        break
                    elseif type(ret) == "table" then
                        if ret.Index then
                            spawnGrid = ret
                        else
                            grids = ret
                        end

                        break
                    end
                end
            end

            if not noSpawnGrid then
                if not spawnGrid then
                    spawnGrid = grids[StageAPI.Random(1, #grids, StageAPI.RoomLoadRNG)]
                end

                if spawnGrid then
                    spawnGrids[index] = spawnGrid
                end
            end
        end
    end

    return spawnGrids
end

---@param layout RoomLayout
---@param seed? integer
---@param noChampions? boolean
---@return table<integer, SpawnList.EntityInfo[]> spawnEntities
---@return table<integer, RoomLayout_GridData> spawnGrids
---@return table<integer, boolean> entityTakenIndices
---@return table<integer, boolean> gridTakenIndices
---@return integer lastPersistentIndex
---@return RoomMetadata roomMetadata
function StageAPI.ObtainSpawnObjects(layout, seed, noChampions)
    local entitiesByIndex, gridsByIndex, roomMetadata, lastPersistentIndex = StageAPI.SeparateEntityMetadata(layout.EntitiesByIndex, layout.GridEntitiesByIndex, seed)
    local spawnEntities, lastPersistentIndex = StageAPI.SelectSpawnEntities(entitiesByIndex, seed, roomMetadata, lastPersistentIndex, noChampions)
    local spawnGrids = StageAPI.SelectSpawnGrids(gridsByIndex, seed)

    local gridTakenIndices = {}
    local entityTakenIndices = {}

    for index, entity in pairs(spawnEntities) do
        entityTakenIndices[index] = true
    end

    for index, gridData in pairs(spawnGrids) do
        gridTakenIndices[index] = true
    end

    return spawnEntities, spawnGrids, entityTakenIndices, gridTakenIndices, lastPersistentIndex, roomMetadata
end

StageAPI.ActiveEntityPersistenceData = {}
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    StageAPI.ActiveEntityPersistenceData = {}
end)

---@param entity Entity
---@return integer? persistentIndex
---@return EntityPersistenceData?
function StageAPI.GetEntityPersistenceData(entity)
    local ent = StageAPI.ActiveEntityPersistenceData[GetPtrHash(entity)]
    if ent then
        return ent.Index, ent.Data
    end
end

---@param entity Entity
---@param persistentIndex integer
---@param persistenceData EntityPersistenceData
function StageAPI.SetEntityPersistenceData(entity, persistentIndex, persistenceData)
    StageAPI.ActiveEntityPersistenceData[GetPtrHash(entity)] = {
        Index = persistentIndex,
        Data = persistenceData
    }
end

---@param entitysets table<integer, SpawnList.EntityInfo[]>
---@param doGrids? boolean
---@param doPersistentOnly? boolean
---@param doAutoPersistent? boolean
---@param avoidSpawning? boolean
---@param persistenceData? table[] Apparently never set? To investigate
---@param loadingWave? boolean
---@return Entity[] entsSpawned
function StageAPI.LoadEntitiesFromEntitySets(entitysets, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, loadingWave)
    local ents_spawned = {}
    local listCallbacks = StageAPI.GetCallbacks(Callbacks.PRE_SPAWN_ENTITY_LIST)
    local entCallbacks = StageAPI.GetCallbacks(Callbacks.PRE_SPAWN_ENTITY)
    if type(entitysets) ~= "table" then
        entitysets = {entitysets}
    end

    for _, entities in ipairs(entitysets) do
        for index, entityList in pairs(entities) do
            if #entityList > 0 then
                local shouldSpawn = true
                for _, callback in ipairs(listCallbacks) do
                    local success, ret = StageAPI.TryCallback(callback,
                        entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData)
                    if success then
                        if ret == false then
                            shouldSpawn = false
                            break
                        elseif ret and type(ret) == "table" then
                            entityList = ret
                            break
                        end
                    end
                end

                if shouldSpawn and #entityList > 0 then
                    for _, entityInfo in ipairs(entityList) do
                        local shouldSpawnEntity = true

                        if shouldSpawnEntity and avoidSpawning and avoidSpawning[entityInfo.PersistentIndex] then
                            shouldSpawnEntity = false
                        end

                        local entityPersistData, persistData
                        if entityInfo.Persistent and persistenceData then
                            if entityInfo.PersistentIndex then
                                entityPersistData = persistenceData[entityInfo.PersistentIndex]
                                if entityPersistData then
                                    entityInfo.Data.Type = entityPersistData.Type or entityInfo.Data.Type
                                    entityInfo.Data.Variant = entityPersistData.Variant or entityInfo.Data.Variant
                                    entityInfo.Data.SubType = entityPersistData.SubType or entityInfo.Data.SubType

                                    if entityPersistData.Position then
                                        entityInfo.Position = Vector(entityPersistData.Position.X, entityPersistData.Position.Y)
                                    end
                                end
                            end

                            persistData = StageAPI.CheckPersistence(entityInfo.Data.Type, entityInfo.Data.Variant, entityInfo.Data.SubType)
                        end

                        if shouldSpawnEntity and doPersistentOnly and not persistData then
                            shouldSpawnEntity = false
                        end

                        if shouldSpawnEntity and persistData and persistData.AutoPersists and not doAutoPersistent then
                            shouldSpawnEntity = false
                        end

                        if not entityInfo.Position then
                            entityInfo.Position = shared.Room:GetGridPosition(index)
                        end

                        for _, callback in ipairs(entCallbacks) do
                            if not callback.Params[1] or (entityInfo.Data.Type and callback.Params[1] == entityInfo.Data.Type)
                            and not callback.Params[2] or (entityInfo.Data.Variant and callback.Params[2] == entityInfo.Data.Variant)
                            and not callback.Params[3] or (entityInfo.Data.SubType and callback.Params[3] == entityInfo.Data.SubType) then
                                local success, ret = StageAPI.TryCallback(callback,
                                    entityInfo, entityList, index, doGrids, doPersistentOnly,
                                    doAutoPersistent, avoidSpawning, persistenceData, shouldSpawnEntity)
                                if success then
                                    if ret == false or ret == true then
                                        shouldSpawnEntity = ret
                                        break
                                    elseif ret and type(ret) == "table" then
                                        if ret.Data then
                                            entityInfo = ret
                                        else
                                            entityInfo.Data.Type = ret[1] == 999 and 1000 or ret[1]
                                            entityInfo.Data.Variant = ret[2]
                                            entityInfo.Data.SubType = ret[3]
                                        end
                                        break
                                    end
                                end
                            end
                        end

                        local currentRoom = StageAPI.GetCurrentRoom()
                        local followRoomRules = currentRoom and not currentRoom.IgnoreRoomRules and currentRoom.FirstLoad
                        if followRoomRules and shared.Room:IsMirrorWorld() then -- only slot machines and npcs can spawn in the mirror world
                            if entityInfo.Data.Type < 10 and entityInfo.Data.Type ~= EntityType.ENTITY_SLOT then
                                shouldSpawnEntity = false
                            end
                        end

                        if shouldSpawnEntity then
                            local entityData = entityInfo.Data
                            if doGrids or (entityData.Type > 9 and entityData.Type ~= EntityType.ENTITY_FIREPLACE) then
                                local ent = Isaac.Spawn(
                                    entityData.Type or 20,
                                    entityData.Variant or 0,
                                    entityData.SubType or 0,
                                    entityInfo.Position or Vector.Zero,
                                    Vector.Zero,
                                    nil
                                )

                                if not ent:IsBoss() and ent:ToNPC() then
                                    if entityData.ChampionSeed then
                                        ent:ToNPC():MakeChampion(entityData.ChampionSeed, -1, true)
                                        ent.HitPoints = ent.MaxHitPoints
                                    end
                                end

                                if entityData.Type == EntityType.ENTITY_PICKUP and entityData.Variant == PickupVariant.PICKUP_COLLECTIBLE and entityData.SubType ~= 0 then -- why can corrupted data change fixed items spawns??
                                    if ent.SubType ~= entityData.SubType then
                                        ent:ToPickup():Morph(ent.Type, ent.Variant, entityData.SubType, true, true, true)
                                    end
                                end

                                if entityPersistData and entityPersistData.Health then
                                    ent.HitPoints = entityPersistData.Health
                                end

                                if entityPersistData and entityPersistData.Price and ent.Type == EntityType.ENTITY_PICKUP then
                                    local pickup = ent:ToPickup()
                                    pickup.Price = entityPersistData.Price.Price
                                    pickup.AutoUpdatePrice = entityPersistData.Price.AutoUpdate
                                end

                                if followRoomRules then
                                    if entityData.Type == EntityType.ENTITY_PICKUP and entityData.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                                        if currentRoom.RoomType == RoomType.ROOM_TREASURE then
                                            local hasBrokenGlasses = StageAPI.AnyPlayerHasTrinket(TrinketType.TRINKET_BROKEN_GLASSES)
                                    
                                            --[[
                                            Base game treasure rooms have:
                                            - Subtype 0: normal treasure rooms (includes rare double item treasure rooms)
                                            - Subtype 1: double treasure rooms (used by more options / broken glasses)
                                            - Subtype 2: treasure rooms with restock machine (used by pay to play)
                                            - Subtype 3: double treasure rooms with restock machine (used by both)
                                            ]]

                                            if currentRoom.Layout.Variant == 1
                                            or currentRoom.Layout.Variant == 3
                                            or string.find(string.lower(currentRoom.Layout.Name), "choice") 
                                            or string.find(string.lower(currentRoom.Layout.Name), "choose") 
                                            then
                                                ent:ToPickup().OptionsPickupIndex = 1
                                            end

                                            local isShopItem
                                            for _, player in ipairs(shared.Players) do
                                                if player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
                                                    isShopItem = true
                                                    break
                                                end
                                            end

                                            if isShopItem then
                                                ent:ToPickup().Price = 15
                                                ent:ToPickup().AutoUpdatePrice = true
                                            end

                                            -- Per vanilla behavior, always affects extra item
                                            -- even with other items that add a choice item
                                            if hasBrokenGlasses then
                                                local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
                                                if collectibles[2] then
                                                    local sprite = collectibles[2]:GetSprite()
                                                    sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
                                                    sprite:LoadGraphics()
                                                end
                                            end
                                        end
                                    end
                                end

                                ent:GetData().StageAPISpawnedPosition = entityInfo.Position or Vector.Zero
                                ent:GetData().StageAPIEntityListIndex = index

                                if entityInfo.Persistent then
                                    StageAPI.SetEntityPersistenceData(ent, entityInfo.PersistentIndex, persistData)
                                end

                                if not loadingWave and ent:CanShutDoors() then
                                    shared.Room:SetClear(false)
                                end

                                StageAPI.CallCallbacks(Callbacks.POST_SPAWN_ENTITY, false, ent, entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, shouldSpawnEntity)

                                ents_spawned[#ents_spawned + 1] = ent
                            end
                        end
                    end
                end
            end
        end
    end

    return ents_spawned
end

function StageAPI.CallGridPostInit()
    for i = 0, shared.Room:GetGridSize() do
        local grid = shared.Room:GetGridEntity(i)
        if grid then
            grid:PostInit()

            if StageAPI.RockTypes[grid.Desc.Type] then
                grid:ToRock():UpdateAnimFrame()
            end
        end
    end
end

StageAPI.GridSpawnRNG = RNG()
StageAPI.ConsoleSpawningGrid = false

---@class GridInformation : RoomLayout_GridData
---@field State integer
---@field VarData integer
---@field Frame integer

---@param grids table<integer, RoomLayout_GridData>
---@param gridInformation? table<integer, GridInformation> if set will be used instead of grids, and set its additional data
---@param entities table<integer, SpawnList.EntityInfo[]>
---@return GridEntity[] gridsSpawned
function StageAPI.LoadGridsFromDataList(grids, gridInformation, entities)
    local grids_spawned = {}
    StageAPI.GridSpawnRNG:SetSeed(shared.Room:GetSpawnSeed(), 0)
    local callbacks = StageAPI.GetCallbacks(Callbacks.PRE_SPAWN_GRID)

    local iterList = gridInformation or grids

    for index, gridData in pairs(iterList) do
        local shouldSpawn = true
        for _, callback in ipairs(callbacks) do
            local success, ret = StageAPI.TryCallback(callback,
                gridData, gridInformation, entities, StageAPI.GridSpawnRNG)
            if success then
                if ret == false then
                    shouldSpawn = false
                    break
                elseif type(ret) == "table" then
                    gridData = ret
                end
            end
        end

        if shouldSpawn and shared.Room:IsPositionInRoom(shared.Room:GetGridPosition(index), 0) then
            local existingGrid = shared.Room:GetGridEntity(index)
            if existingGrid then
                shared.Room:RemoveGridEntity(index, 0, false)
            end

            shared.Room:SetGridPath(index, 0)

            local grid
            if StageAPI.ConsoleSpawnedGridTypes[gridData.Type] then
                local command = "gridspawn " .. gridData.Type .. "." .. gridData.Variant .. " " .. index
                StageAPI.ConsoleSpawningGrid = true
                Isaac.ExecuteCommand(command)
                StageAPI.ConsoleSpawningGrid = false

                if StageAPI.RailGridTypes[gridData.Type] and StageAPI.MinecartRailVariants[gridData.Variant] then
                    -- TODO: Rail Cart Handling (may require redoing minecart rendering?)
                end
            else
                grid = Isaac.GridSpawn(gridData.Type, gridData.Variant, shared.Room:GetGridPosition(index), true)
            end

            if grid then
                if gridInformation and gridInformation[index] then
                    local grinformation = gridInformation[index]
                    if grinformation.State ~= nil then
                        grid.State = grinformation.State
                        if grinformation.State == 4 and gridData.Type == GridEntityType.GRID_TNT then
                            grid:ToTNT().FrameCnt = -1
                        end
                    end

                    if grinformation.VarData ~= nil then
                        grid.VarData = grinformation.VarData
                    end

                    if grid.Desc.Type == GridEntityType.GRID_ROCK and grinformation.Frame then
                        grid:ToRock():SetBigRockFrame(grinformation.Frame)
                    end
                end

                local sprite = grid:GetSprite()
                if grid:ToPoop() then
                    if grid.State == 1000 then
                        sprite:Play("State5", true)
                    elseif grid.State > 750 then
                        sprite:Play("State4", true)
                    elseif grid.State > 250 then
                        sprite:Play("State3", true)
                    elseif grid.State > 0 then
                        sprite:Play("State2", true)
                    else
                        sprite:Play("State1", true)
                    end

                    sprite:SetLastFrame()
                elseif grid:ToTNT() then
                    if grid.State == 0 then
                        sprite:Play("Idle", true)
                    elseif grid.State < 3 then
                        sprite:Play("IdleMedium", true)
                    elseif grid.State == 3 then
                        sprite:Play("ReadyToExplode", true)
                    else
                        sprite:Play("Blown", true)
                    end

                    sprite:SetLastFrame()
                elseif grid:ToPressurePlate() then
                    if grid.State == 3 then
                        local anim = sprite:GetAnimation()
                        if anim == "OffSkull" then
                            sprite:Play("OnSkull", true)
                        elseif anim == "OffPentagram" then
                            sprite:Play("OnPentagram", true)
                        else
                            sprite:Play("On", true)
                        end
                    end
                elseif grid:ToSpikes() then
                    if grid.State == 1 then
                        local anim = sprite:GetAnimation()
                        local firstLetters = string.sub(anim, 1, 4)
                        if anim == "Summon" or firstLetters ~= "Womb" then
                            sprite:Play("Unsummon", true)
                            sprite:SetLastFrame()
                        else
                            sprite:Play("UnsummonWomb", true)
                            sprite:SetLastFrame()
                        end
                    end
                elseif grid.Desc.Type == GridEntityType.GRID_LOCK then
                    if grid.State == 1 then
                        sprite:Play("Broken", true)
                        grid.CollisionClass = GridCollisionClass.COLLISION_NONE
                    end
                end

                if gridData.Type == GridEntityType.GRID_PRESSURE_PLATE and gridData.Variant == 0 and grid.State ~= 3 then
                    shared.Room:SetClear(false)
                end

                grids_spawned[#grids_spawned + 1] = grid
            end
        end
    end

    return grids_spawned
end

---@return table<integer, GridInformation>
function StageAPI.GetGridInformation()
    local gridInformation = {}
    for i = 0, shared.Room:GetGridSize() do
        local grid = shared.Room:GetGridEntity(i)
        if grid and grid.Desc.Type ~= GridEntityType.GRID_DOOR and (grid.Desc.Type ~= GridEntityType.GRID_WALL or shared.Room:IsPositionInRoom(grid.Position, 0)) then
            gridInformation[i] = {
                State = grid.State,
                VarData = grid.VarData,
                Type = grid.Desc.Type,
                Variant = grid.Desc.Variant
            }

            if grid.Desc.Type == GridEntityType.GRID_ROCK then
                gridInformation[i].Frame = grid:ToRock():GetBigRockFrame()
            end
        end
    end

    return gridInformation
end

---@param grids table<integer, RoomLayout_GridData>
---@param entities table<integer, SpawnList.EntityInfo[]>
---@param doGrids? boolean
---@param doEntities? boolean
---@param doPersistentOnly? boolean
---@param doAutoPersistent? boolean
---@param gridData? boolean
---@param avoidSpawning? boolean
---@param persistenceData? boolean
---@param loadingWave? boolean
---@return Entity[] entsSpawned
---@return GridEntity[] gridsSpawned
function StageAPI.LoadRoomLayout(grids, entities, doGrids, doEntities, doPersistentOnly, doAutoPersistent, gridData, avoidSpawning, persistenceData, loadingWave)
    local grids_spawned = {}
    local ents_spawned = {}

    if grids and doGrids then
        grids_spawned = StageAPI.LoadGridsFromDataList(grids, gridData, entities)
    end

    if entities and doEntities then
        ents_spawned = StageAPI.LoadEntitiesFromEntitySets(entities, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, loadingWave)
    end

    StageAPI.CallGridPostInit()

    return ents_spawned, grids_spawned
end

---@return any
function StageAPI.GetCurrentRoomID()
    local levelMap = StageAPI.GetCurrentLevelMap()
    if levelMap and StageAPI.CurrentLevelMapRoomID then
        return levelMap:GetRoomData(StageAPI.CurrentLevelMapRoomID).RoomID
    else
        return StageAPI.GetCurrentListIndex()
    end
end

---@type table<integer, table<any, LevelRoom>>
StageAPI.LevelRooms = {}

---@alias Dimension integer

---@param roomDesc? RoomDescriptor
---@return Dimension
function StageAPI.GetDimension(roomDesc)
    if not roomDesc then
        local levelMap = StageAPI.GetCurrentLevelMap()
        if levelMap and StageAPI.CurrentLevelMapRoomID then
            return levelMap.Dimension
        end
    end

    roomDesc = roomDesc or shared.Level:GetCurrentRoomDesc()
    if roomDesc.GridIndex < 0 then -- Off-grid rooms
        return -2
    end

    local hash = GetPtrHash(roomDesc)
    for dimension = 0, 2 do
        local dimensionDesc = shared.Level:GetRoomByIdx(roomDesc.SafeGridIndex, dimension)
        if GetPtrHash(dimensionDesc) == hash then
            return dimension
        end
        ---@diagnostic disable-next-line
    end
end

---@generic T
---@param tbl table<integer, T>
---@param setIfNot? boolean
---@param dimension? Dimension
---@return T
function StageAPI.GetTableIndexedByDimension(tbl, setIfNot, dimension)
    dimension = dimension or StageAPI.GetDimension()
    if setIfNot and not tbl[dimension] then
        tbl[dimension] = {}
    end
    return tbl[dimension]
end

---@generic T
---@param tbl table<integer, table<any, T>>
---@param setIfNot? boolean
---@param dimension? Dimension
---@param roomID? any
---@return T
function StageAPI.GetTableIndexedByDimensionRoom(tbl, setIfNot, dimension, roomID)
    local byDimension = StageAPI.GetTableIndexedByDimension(tbl, setIfNot, dimension)
    roomID = roomID or StageAPI.GetCurrentRoomID()
    if byDimension then
        if setIfNot and not byDimension[roomID] then
            byDimension[roomID] = {}
        end

        return byDimension[roomID]
        ---@diagnostic disable-next-line
    end
end

---@param roomID any
---@param dimension? Dimension
---@return LevelRoom
function StageAPI.GetLevelRoom(roomID, dimension)
    dimension = dimension or StageAPI.GetDimension()
    return StageAPI.LevelRooms[dimension] and StageAPI.LevelRooms[dimension][roomID]
end

---@return LevelRoom[]
function StageAPI.GetAllLevelRooms()
    local levelRooms = {}
    for dimension, rooms in pairs(StageAPI.LevelRooms) do
        for index, levelRoom in pairs(rooms) do
            levelRooms[#levelRooms + 1] = levelRoom
        end
    end

    return levelRooms
end

---@param levelRoom LevelRoom
---@param roomID any
---@param dimension? Dimension
function StageAPI.SetLevelRoom(levelRoom, roomID, dimension)
    dimension = dimension or StageAPI.GetDimension()
    if not StageAPI.LevelRooms[dimension] then
        StageAPI.LevelRooms[dimension] = {}
    end

    StageAPI.LevelRooms[dimension][roomID] = levelRoom

    if levelRoom then
        levelRoom.LevelIndex = roomID
        levelRoom.Dimension = dimension
    end
end

---@param room LevelRoom
function StageAPI.SetCurrentRoom(room)
    StageAPI.ActiveEntityPersistenceData = {}
    StageAPI.SetLevelRoom(room, StageAPI.GetCurrentRoomID())
end

function StageAPI.GetCurrentRoom()
    return StageAPI.GetLevelRoom(StageAPI.GetCurrentRoomID())
end

function StageAPI.GetCurrentRoomType()
    local currentRoom = StageAPI.GetCurrentRoom()
    if currentRoom then
        return currentRoom.TypeOverride or currentRoom.RoomType or shared.Room:GetType()
    else
        return shared.Room:GetType()
    end
end

function StageAPI.GetRooms()
    return StageAPI.LevelRooms
end

function StageAPI.CloseDoors()
    for i = 0, 7 do
        local door = shared.Room:GetDoor(i)
        if door then
            door:Close()
        end
    end
end

---@return table<DoorSlot, boolean>
function StageAPI.GetDoorsForRoom()
    local doors = {}
    for i = 0, 7 do
        doors[i] = not not shared.Room:GetDoor(i)
    end
    return doors
end

StageAPI.AllDoorsOpen = {}
for i = 0, 7 do
    StageAPI.AllDoorsOpen[i] = true
end

---@param data RoomConfig_Room
---@return table<DoorSlot, boolean>
function StageAPI.GetDoorsForRoomFromData(data)
    local doors = {}
    for i = 0, 7 do
        doors[i] = data.Doors & StageAPI.DoorsBitwise[i] ~= 0
    end

    return doors
end

---@param slot DoorSlot
---@return boolean
function StageAPI.IsDoorSlotAllowed(slot)
    local currentRoom = StageAPI.GetCurrentRoom()
    if currentRoom and currentRoom.Layout and currentRoom.Layout.Doors then
        for _, door in ipairs(currentRoom.Layout.Doors) do
            if door.Slot == slot and door.Exists then
                return true
            end
        end        
        return false
    else
        return shared.Room:IsDoorSlotAllowed(slot)
    end
end

---@param roomsList RoomsList
---@param roomType? RoomType
---@param requireRoomType? boolean
---@param isExtraRoom? boolean
---@param load? boolean
---@param seed? integer
---@param shape? RoomShape
---@param fromSaveData? boolean
---@return LevelRoom
function StageAPI.SetRoomFromList(roomsList, roomType, requireRoomType, isExtraRoom, load, seed, shape, fromSaveData)
    local levelIndex = StageAPI.GetCurrentRoomID()
    local newRoom = StageAPI.LevelRoom(nil, roomsList, seed, shape, roomType, isExtraRoom, fromSaveData, requireRoomType, nil, nil, levelIndex)
    StageAPI.SetCurrentRoom(newRoom)

    if load then
        newRoom:Load(isExtraRoom)
    end

    return newRoom
end

---@param entity Entity
function StageAPI.RemovePersistentEntity(entity)
    local currentRoom = StageAPI.GetCurrentRoom()
    if currentRoom then
        currentRoom:RemovePersistentEntity(entity)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, ent)
    local index, data = StageAPI.GetEntityPersistenceData(ent)
    -- Entities are removed whenever you exit the room, in this time the game is paused, which we can use to stop removing persistent entities on room exit.
    if data and data.RemoveOnRemove and not shared.Game:IsPaused() then
        StageAPI.RemovePersistentEntity(ent)
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, ent)
    local index, data = StageAPI.GetEntityPersistenceData(ent)
    if data and data.RemoveOnDeath then
        StageAPI.RemovePersistentEntity(ent)
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, ent)
    if StageAPI.InNewStage() then
        StageAPI.RecalculateEntityStageHP(ent)
    end
end)