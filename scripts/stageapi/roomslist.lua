StageAPI.LogMinor("Loading Room Handler")

StageAPI.RemappedEntities = {}
function StageAPI.RemapEntity(t1, v1, s1, t2, v2, s2)
    v1 = v1 or "Default"
    s1 = s1 or "Default"
    if not StageAPI.RemappedEntities[t1] then
        StageAPI.RemappedEntities[t1] = {}
    end

    if v1 and not StageAPI.RemappedEntities[t1][v1] then
        StageAPI.RemappedEntities[t1][v1] = {}
    end

    StageAPI.RemappedEntities[t1][v1][s1] = {
        Type = t2,
        Variant = v2,
        SubType = s2
    }
end

StageAPI.RoomShapeToWidthHeight = {
    [RoomShape.ROOMSHAPE_1x1] = {
        Width = 15,
        Height = 9,
        Slots = {DoorSlot.UP0, DoorSlot.LEFT0, DoorSlot.RIGHT0, DoorSlot.DOWN0}
    },
    [RoomShape.ROOMSHAPE_IV] = {
        Width = 15,
        Height = 9,
        Slots = {DoorSlot.UP0, DoorSlot.DOWN0}
    },
    [RoomShape.ROOMSHAPE_IH] = {
        Width = 15,
        Height = 9,
        Slots = {DoorSlot.LEFT0, DoorSlot.RIGHT0}
    },
    [RoomShape.ROOMSHAPE_2x2] = {
        Width = 28,
        Height = 16,
        Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1}
    },
    [RoomShape.ROOMSHAPE_2x1] = {
        Width = 28,
        Height = 9,
        Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.RIGHT0, DoorSlot.DOWN0, DoorSlot.DOWN1}
    },
    [RoomShape.ROOMSHAPE_1x2] = {
        Width = 15,
        Height = 16,
        Slots = {DoorSlot.UP0, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0}
    },
    [RoomShape.ROOMSHAPE_IIV] = {
        Width = 15,
        Height = 16,
        Slots = {DoorSlot.UP0, DoorSlot.DOWN0}
    },
    [RoomShape.ROOMSHAPE_LTL] = {
        Width = 28,
        Height = 16,
        LWidthEnd = 14,
        LHeightEnd = 8,
        Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1}
    },
    [RoomShape.ROOMSHAPE_LBL] = {
        Width = 28,
        Height = 16,
        LWidthEnd = 14,
        LHeightStart = 8,
        Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1}
    },
    [RoomShape.ROOMSHAPE_LBR] = {
        Width = 28,
        Height = 16,
        LWidthStart = 14,
        LHeightStart = 8,
        Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1}
    },
    [RoomShape.ROOMSHAPE_LTR] = {
        Width = 28,
        Height = 16,
        LWidthStart = 14,
        LHeightEnd = 8,
        Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1}
    },
    [RoomShape.ROOMSHAPE_IIH] = {
        Width = 28,
        Height = 9,
        Slots = {DoorSlot.LEFT0, DoorSlot.RIGHT0}
    }
}

function StageAPI.AddObjectToRoomLayout(layout, index, objtype, variant, subtype, gridX, gridY)
    if gridX and gridY and not index then
        index = StageAPI.VectorToGrid(gridX, gridY, layout.Width)
    end

    if StageAPI.CorrectedGridTypes[objtype] then
        local t, v = StageAPI.CorrectedGridTypes[objtype], variant
        if type(t) == "table" then
            v = t.Variant
            t = t.Type
        end

        local gridData = {
            Type = t,
            Variant = v,
            GridX = gridX,
            GridY = gridY,
            Index = index
        }

        layout.GridEntities[#layout.GridEntities + 1] = gridData

        if not layout.GridEntitiesByIndex[gridData.Index] then
            layout.GridEntitiesByIndex[gridData.Index] = {}
        end

        layout.GridEntitiesByIndex[gridData.Index][#layout.GridEntitiesByIndex[gridData.Index] + 1] = gridData
    elseif StageAPI.UnsupportedTypes[objtype] then
        StageAPI.LogErr("Error in " .. layout.Name .. "! Entities with type " .. tostring(objtype) .. " are unsupported in StageAPI layouts!")
    elseif objtype ~= 0 then
        local entData = {
            Type = objtype,
            Variant = variant,
            SubType = subtype,
            GridX = gridX,
            GridY = gridY,
            Index = index
        }

        if entData.Type == 1400 or entData.Type == 1410 then
            entData.Type = EntityType.ENTITY_FIREPLACE
            if entData.Type == 1410 then
                entData.Variant = 1
            else
                entData.Variant = 0
            end
        end

        if entData.Type == 999 then
            entData.Type = 1000
        end

        if StageAPI.RemappedEntities[entData.Type] then
            local remapTo
            if entData.Variant and StageAPI.RemappedEntities[entData.Type][entData.Variant] then
                if entData.SubType and StageAPI.RemappedEntities[entData.Type][entData.Variant][entData.SubType] then
                    remapTo = StageAPI.RemappedEntities[entData.Type][entData.Variant][entData.SubType]
                elseif StageAPI.RemappedEntities[entData.Type][entData.Variant]["Default"] then
                    remapTo = StageAPI.RemappedEntities[entData.Type][entData.Variant]["Default"]
                end
            elseif StageAPI.RemappedEntities[entData.Type]["Default"] then
                remapTo = StageAPI.RemappedEntities[entData.Type]["Default"]["Default"]
            end

            if remapTo then
                entData.Type = remapTo.Type
                if remapTo.Variant then
                    entData.Variant = remapTo.Variant
                end

                if remapTo.SubType then
                    entData.SubType = remapTo.SubType
                end
            end
        end

        if not layout.EntitiesByIndex[entData.Index] then
            layout.EntitiesByIndex[entData.Index] = {}
        end

        layout.EntitiesByIndex[entData.Index][#layout.EntitiesByIndex[entData.Index] + 1] = entData
        layout.Entities[#layout.Entities + 1] = entData
    end
end

StageAPI.LastRoomID = 0
function StageAPI.SimplifyRoomLayout(layout)
    local outLayout = {
        GridEntities = {},
        GridEntitiesByIndex = {},
        Entities = {},
        EntitiesByIndex = {},
        Doors = {},
        Shape = layout.SHAPE,
        Weight = layout.WEIGHT,
        Difficulty = layout.DIFFICULTY,
        Name = layout.NAME,
        Width = layout.WIDTH + 2,
        Height = layout.HEIGHT + 2,
        Type = layout.TYPE,
        Variant = layout.VARIANT,
        SubType = layout.SUBTYPE,
        StageAPIID = StageAPI.LastRoomID + 1,
        PreSimplified = true
    }

    StageAPI.LastRoomID = outLayout.StageAPIID

    local widthHeight = StageAPI.RoomShapeToWidthHeight[outLayout.Shape]
    if widthHeight then
        outLayout.LWidthStart = widthHeight.LWidthStart
        outLayout.LWidthEnd = widthHeight.LWidthEnd
        outLayout.LHeightStart = widthHeight.LHeightStart
        outLayout.LHeightEnd = widthHeight.LHeightEnd
    end

    for _, object in ipairs(layout) do
        if not object.ISDOOR then
            local index = StageAPI.VectorToGrid(object.GRIDX, object.GRIDY, outLayout.Width)
            for _, entityData in ipairs(object) do
                StageAPI.AddObjectToRoomLayout(outLayout, index, entityData.TYPE, entityData.VARIANT, entityData.SUBTYPE, object.GRIDX, object.GRIDY)
            end
        else
            outLayout.Doors[#outLayout.Doors + 1] = {
                Slot = object.SLOT,
                Exists = object.EXISTS
            }
        end
    end

    return outLayout
end

function StageAPI.CreateEmptyRoomLayout(shape)
    shape = shape or RoomShape.ROOMSHAPE_1x1
    local widthHeight = StageAPI.RoomShapeToWidthHeight[shape]
    local width, height, lWidthStart, lWidthEnd, lHeightStart, lHeightEnd, slots
    if not widthHeight then
        width, height, slots = StageAPI.RoomShapeToWidthHeight[RoomShape.ROOMSHAPE_1x1].Width, StageAPI.RoomShapeToWidthHeight[RoomShape.ROOMSHAPE_1x1].Height, StageAPI.RoomShapeToWidthHeight[RoomShape.ROOMSHAPE_1x1].Slots
    else
        width, height, lWidthStart, lWidthEnd, lHeightStart, lHeightEnd, slots = widthHeight.Width, widthHeight.Height, widthHeight.LWidthStart, widthHeight.LWidthEnd, widthHeight.LHeightStart, widthHeight.LHeightEnd, widthHeight.Slots
    end
    local newRoom = {
        Name = "Empty",
        RoomFilename = "Special",
        Type = 1,
        Variant = 0,
        SubType = 0,
        Shape = shape,
        Difficulty = 1,
        Width = width,
        Height = height,
        LWidthStart = lWidthStart,
        LWidthEnd = lWidthEnd,
        LHeightStart = lHeightStart,
        LHeightEnd = lHeightEnd,
        Weight = 1,
        GridEntities = {},
        GridEntitiesByIndex = {},
        Entities = {},
        EntitiesByIndex = {},
        Doors = {},
        StageAPIID = StageAPI.LastRoomID + 1,
        PreSimplified = true
    }

    StageAPI.LastRoomID = newRoom.StageAPIID

    for _, slot in ipairs(slots) do
        newRoom.Doors[#newRoom.Doors + 1] = {
            Slot = slot,
            Exists = true
        }
    end

    return newRoom
end

StageAPI.DoorsBitwise = {
    [DoorSlot.LEFT0] = 1,
    [DoorSlot.UP0] = 1 << 1,
    [DoorSlot.RIGHT0] = 1 << 2,
    [DoorSlot.DOWN0] = 1 << 3,
    [DoorSlot.LEFT1] = 1 << 4,
    [DoorSlot.UP1] = 1 << 5,
    [DoorSlot.RIGHT1] = 1 << 6,
    [DoorSlot.DOWN1] = 1 << 7,
}

function StageAPI.ForAllSpawnEntries(data, func)
    local spawns = data.Spawns
    for i = 0, spawns.Size - 1 do
        local spawn = spawns:Get(i)
        local shouldBreak
        if spawn then
            local sumWeight = spawn.SumWeights
            local weight = 0
            for i = 1, spawn.EntryCount do
                local entry = spawn:PickEntry(weight)
                weight = weight + entry.Weight / sumWeight

                shouldBreak = func(entry, spawn)
                if shouldBreak then
                    break
                end
            end
        end

        if shouldBreak then
            break
        end
    end
end

function StageAPI.GenerateRoomLayoutFromData(data) -- converts RoomDescriptor.Data to a StageAPI layout
    local layout = StageAPI.CreateEmptyRoomLayout(data.Shape)
    layout.Name = data.Name
    layout.RoomFilename = "Special"
    layout.Type = data.Type
    layout.Variant = data.Variant
    layout.SubType = data.Subtype
    layout.Difficulty = data.Difficulty
    layout.Weight = data.InitialWeight

    for _, door in ipairs(layout.Doors) do
        door.Exists = data.Doors & StageAPI.DoorsBitwise[door.Slot] ~= 0
    end

    StageAPI.ForAllSpawnEntries(data, function(entry, spawn)
        StageAPI.AddObjectToRoomLayout(layout, nil, entry.Type, entry.Variant, entry.Subtype, spawn.X, spawn.Y)
    end)

    return layout
end

-- convenience function for testing if an entity exists anywhere in a stage's room layouts
function StageAPI.EntityInLevel(id, variant, subtype, defaultRoomsOnly)
    local roomsList = level:GetRooms()
    for i = 0, roomsList.Size - 1 do
        local roomDesc = roomsList:Get(i)
        if roomDesc and (not defaultRoomsOnly or roomDesc.Data.Type == RoomType.ROOM_DEFAULT) then
            local foundMatch
            StageAPI.ForAllSpawnEntries(roomDesc.Data, function(entry)
                if entry.Type == id and (not variant or entry.Variant == variant) and (not subtype or entry.Subtype == subtype) then
                    foundMatch = true
                    return true
                end
            end)

            if foundMatch then
                return true, i, roomDesc.SafeGridIndex
            end
        end
    end

    return false
end

StageAPI.Layouts = {}
function StageAPI.RegisterLayout(name, layout)
    StageAPI.Layouts[name] = layout
end

StageAPI.RoomsLists = {}
StageAPI.RoomsList = StageAPI.Class("RoomsList")
function StageAPI.RoomsList:Init(name, ...)
    self.Name = name
    StageAPI.RoomsLists[name] = self
    self.All = {}
    self.ByShape = {}
    self.Shapes = {}
    self.NotSimplifiedFiles = {}
    self:AddRooms(...)
end

function StageAPI.RoomsList:AddRooms(...)
    local roomfiles = {...}
    for _, rooms in ipairs(roomfiles) do
        local roomfile, waitToSimplify = "N/A", false
        if type(rooms) == "table" and rooms.Rooms then
            roomfile = rooms.Name
            waitToSimplify = rooms.WaitToSimplify
            rooms = rooms.Rooms
        end

        if waitToSimplify then
            self.NotSimplifiedFiles[#self.NotSimplifiedFiles + 1] = rooms
        else
            for _, room in ipairs(rooms) do
                local simplified
                if not room.PreSimplified then
                    simplified = StageAPI.SimplifyRoomLayout(room)
                else
                    simplified = room
                end

                simplified.RoomFilename = not waitToSimplify and room.RoomFilename or roomfile
                self.All[#self.All + 1] = simplified
                if not self.ByShape[simplified.Shape] then
                    self.Shapes[#self.Shapes + 1] = simplified.Shape
                    self.ByShape[simplified.Shape] = {}
                end

                self.ByShape[simplified.Shape][#self.ByShape[simplified.Shape] + 1] = simplified
            end
        end
    end
end

function StageAPI.RoomsList:GetRooms(shape)
    if shape == -1 then
        return self.All
    else
        return self.ByShape[shape]
    end
end

function StageAPI.RoomsList:CopyRooms(roomsList)
    self:AddRooms(roomsList.All)
end

function StageAPI.CreateSingleEntityLayout(t, v, s, name, rtype, shape)
    local layout = StageAPI.CreateEmptyRoomLayout(shape)
    layout.Type = rtype or RoomType.ROOM_DEFAULT
    layout.Name = name or "N/A"
    local centerX, centerY = math.floor((layout.Width - 2) / 2), math.floor((layout.Height - 2) / 2)
    local centerIndex = StageAPI.VectorToGrid(centerX, centerY, layout.Width)
    layout.EntitiesByIndex[centerIndex] = {
        {
            Type = t or EntityType.ENTITY_MONSTRO,
            Variant = v or 0,
            SubType = s or 0,
            GridX = centerX,
            GridY = centerY,
            Index = centerIndex
        }
    }
    return layout
end

function StageAPI.CreateSingleEntityRoomList(t, v, s, name, rtype, individualRoomName)
    local layouts = {}
    for name, shape in pairs(RoomShape) do
        local layout = StageAPI.CreateSingleEntityLayout(t, v, s, individualRoomName, rtype, shape)
        layouts[#layouts + 1] = layout
    end

    return StageAPI.RoomsList(name, layouts)
end

--[[ Entity Splitting Data

{
    Type = ,
    Variant = ,
    SubType = ,
    ListName =
}

]]

function StageAPI.SplitRoomsOnEntities(rooms, entities, roomEntityPairs)
    local singleMode = false
    if #entities == 0 then
        singleMode = true
        entities = {entities}
    end

    roomEntityPairs = roomEntityPairs or {}

    for _, room in ipairs(rooms) do
        local hasEntities = {}
        for _, object in ipairs(room) do
            for _, entData in ipairs(object) do
                for i, entity in ipairs(entities) do
                    local useEnt = entity.Entity or entity
                    if entData.TYPE == useEnt.Type and (not useEnt.Variant or entData.VARIANT == useEnt.Variant) and (not useEnt.SubType or entData.SUBTYPE == useEnt.SubType) then
                        if not hasEntities[i] then
                            hasEntities[i] = 0
                        end

                        hasEntities[i] = hasEntities[i] + 1
                        break
                    end
                end
            end
        end

        for ind, count in pairs(hasEntities) do
            local entity = entities[ind]
            local listName = entity.ListName
            if entity.MultipleListName and count > 1 then
                listName = entity.MultipleListName
            end

            if not roomEntityPairs[listName] then
                roomEntityPairs[listName] = {}
            end

            roomEntityPairs[listName][#roomEntityPairs[listName] + 1] = room
        end
    end

    return roomEntityPairs
end

--[[ Type Splitting Data

{
    Type = RoomType,
    ListName =
}

]]

function StageAPI.SplitRoomsOnTypes(rooms, types, roomTypePairs)
    roomTypePairs = roomTypePairs or {}
    for _, room in ipairs(rooms) do
        for _, rtype in ipairs(types) do
            if room.TYPE == rtype then
                if not roomTypePairs[rtype.ListName] then
                    roomTypePairs[rtype.ListName] = {}
                end

                roomTypePairs[rtype.ListName][#roomTypePairs[rtype.ListName] + 1] = room
            end
        end
    end

    return roomTypePairs
end

--[[ Splitting List Data

{
    ListName = ,
    SplitBy = Entity Splitting Data or Type Splitting Data
}

]]

function StageAPI.SplitRoomsIntoLists(roomsList, splitBy, splitByType, createEntityPlaceholders, listNamePrefix)
    listNamePrefix = listNamePrefix or ""
    local roomPairs

    if roomsList[1] and roomsList[1].TYPE then
        roomsList = {roomsList}
    end

    if splitByType then
        for _, rooms in ipairs(roomsList) do
            roomPairs = StageAPI.SplitRoomsOnTypes(rooms, splitBy, roomPairs)
        end
    else
        for _, rooms in ipairs(roomsList) do
            roomPairs = StageAPI.SplitRoomsOnEntities(rooms, splitBy, roomPairs)
        end
    end

    if roomPairs then
        for listName, rooms in pairs(roomPairs) do
            if StageAPI.RoomsLists[listNamePrefix .. listName] then
                StageAPI.RoomsLists[listNamePrefix .. listName]:AddRooms(rooms)
            else
                StageAPI.RoomsList(listNamePrefix .. listName, rooms)
            end
        end
    end

    if not splitByType and createEntityPlaceholders then
        for _, splitData in ipairs(splitBy) do
            if not StageAPI.RoomsLists[listNamePrefix .. splitData.ListName] then
                local entity = splitData.Entity or splitData
                StageAPI.CreateSingleEntityRoomList(entity.Type, entity.Variant, entity.SubType, listNamePrefix .. splitData.ListName, splitData.RoomType or entity.RoomType, splitData.RoomName or entity.RoomName)
            end
        end
    end
end

StageAPI.SinsSplitData = {
    {
        Type = EntityType.ENTITY_GLUTTONY,
        Variant = 0,
        ListName = "Gluttony",
        MultipleListName = "SuperGluttony"
    },
    {
        Type = EntityType.ENTITY_ENVY,
        Variant = 0,
        ListName = "Envy",
        MultipleListName = "SuperEnvy"
    },
    {
        Type = EntityType.ENTITY_GREED,
        Variant = 0,
        ListName = "Greed",
        MultipleListName = "SuperGreed"
    },
    {
        Type = EntityType.ENTITY_WRATH,
        Variant = 0,
        ListName = "Wrath",
        MultipleListName = "SuperWrath"
    },
    {
        Type = EntityType.ENTITY_PRIDE,
        Variant = 0,
        ListName = "Pride",
        MultipleListName = "SuperPride"
    },
    {
        Type = EntityType.ENTITY_LUST,
        Variant = 0,
        ListName = "Lust",
        MultipleListName = "SuperLust"
    },
    {
        Type = EntityType.ENTITY_SLOTH,
        Variant = 0,
        ListName = "Sloth",
        MultipleListName = "SuperSloth"
    },
    {
        Type = EntityType.ENTITY_GLUTTONY,
        Variant = 1,
        ListName = "SuperGluttony"
    },
    {
        Type = EntityType.ENTITY_ENVY,
        Variant = 1,
        ListName = "SuperEnvy"
    },
    {
        Type = EntityType.ENTITY_GREED,
        Variant = 1,
        ListName = "SuperGreed"
    },
    {
        Type = EntityType.ENTITY_WRATH,
        Variant = 1,
        ListName = "SuperWrath"
    },
    {
        Type = EntityType.ENTITY_PRIDE,
        Variant = 1,
        ListName = "SuperPride"
    },
    {
        Type = EntityType.ENTITY_LUST,
        Variant = 1,
        ListName = "SuperLust"
    },
    {
        Type = EntityType.ENTITY_SLOTH,
        Variant = 1,
        ListName = "SuperSloth"
    },
    {
        Type = EntityType.ENTITY_SLOTH,
        Variant = 2,
        ListName = "UltraPride"
    }
}

--[[ BossData
{
    {
        Bosses = {
            {
                Type = ,
                Variant = ,
                SubType = ,
                Count =
            }
        },
        Name,
        Weight,
        Horseman,
        Portrait,
        Bossname,
        NameTwo,
        PortraitTwo,
        RoomListName
    }
}

]]

function StageAPI.SeparateRoomListToBossData(roomlist, bossdata)
    if roomlist.Name and StageAPI.RoomsLists[roomlist.Name] then
        StageAPI.RoomsLists[roomlist.Name] = nil
    end

    local retBossData = {}

    for _, boss in ipairs(bossdata) do
        for _, bossEntData in ipairs(boss.Bosses) do
            if not bossEntData.Count then
                bossEntData.Count = 1
            end
        end

        local matchingLayouts = {}
        for _, layout in ipairs(roomlist.All) do
            local countsFound = {}
            for i, bossEntData in ipairs(boss.Bosses) do
                countsFound[i] = 0
            end

            for index, entities in pairs(layout.EntitiesByIndex) do
                for _, entityData in ipairs(entities) do
                    for i, bossEntData in ipairs(boss.Bosses) do
                        if not bossEntData.Type or entityData.Type == bossEntData.Type
                        and not bossEntData.Variant or entityData.Variant == bossEntData.Variant
                        and not bossEntData.SubType or entityData.SubType == bossEntData.SubType then
                            countsFound[i] = countsFound[i] + 1
                        end
                    end
                end
            end

            local matches = true
            for i, bossEntData in ipairs(boss.Bosses) do
                if bossEntData.Count ~= countsFound[i] then
                    matches = false
                end
            end

            if matches then
                matchingLayouts[#matchingLayouts + 1] = layout
            end
        end

        if #matchingLayouts > 0 then
            local list = StageAPI.RoomsList(boss.RoomListName or (boss.Name .. (boss.NameTwo or "")), matchingLayouts)
            retBossData[#retBossData + 1] = {
                Name = boss.Name,
                Weight = boss.Weight,
                Horseman = boss.Horseman,
                Portrait = boss.Portrait,
                Bossname = boss.Bossname,
                NameTwo = boss.NameTwo,
                PortraitTwo = boss.PortraitTwo,
                Rooms = list
            }
        end
    end

    return retBossData
end

function StageAPI.IsIndexInLayout(layout, x, y)
    if not y then
        x, y = StageAPI.GridToVector(x, layout.Width)
    end

    if x < 0 or x > layout.Width - 3 or y < 0 or y > layout.Height - 3 then
        return false
    elseif layout.LWidthStart or layout.LWidthEnd or layout.LHeightStart or layout.lHeightEnd then
        local inHole = true
        if layout.LWidthEnd and x > layout.LWidthEnd - 2 then
            inHole = false
        elseif layout.LWidthStart and x < layout.LWidthStart - 1 then
            inHole = false
        elseif layout.LHeightEnd and y > layout.LHeightEnd - 2 then
            inHole = false
        elseif layout.LHeightStart and y < layout.LHeightStart - 1 then
            inHole = false
        end

        return not inHole
    end

    return true
end

function StageAPI.DoesEntityDataMatchParameters(param, data)
    return (not param.Type or param.Type == data.Type) and (not param.Variant or param.Variant == data.Variant) and (not param.SubType or param.SubType == data.SubType)
end

function StageAPI.CountLayoutEntities(layout, entities, notIncluding)
    local count = 0
    for _, ent in ipairs(layout.Entities) do
        for _, entity in ipairs(entities) do
            if StageAPI.DoesEntityDataMatchParameters(entity, ent) then
                local dontCount
                if notIncluding then
                    for _, noInclude in ipairs(notIncluding) do
                        if StageAPI.DoesEntityDataMatchParameters(noInclude, ent) then
                            dontCount = true
                            break
                        end
                    end
                end

                if not dontCount then
                    count = count + 1
                    break
                end
            end
        end
    end

    return count
end

function StageAPI.DoesLayoutContainEntities(layout, mustIncludeAny, mustExclude, mustIncludeAll, notIncluding)
    local includesAny = not mustIncludeAny
    local mustIncludeAllCopy = {}
    if mustIncludeAll then
        for _, include in ipairs(mustIncludeAll) do
            mustIncludeAllCopy[#mustIncludeAllCopy + 1] = include
        end
    end

    for _, ent in ipairs(layout.Entities) do
        if not includesAny then
            for _, include in ipairs(mustIncludeAny) do
                if StageAPI.DoesEntityDataMatchParameters(include, ent) then
                    local dontCount
                    if notIncluding then
                        for _, noInclude in ipairs(notIncluding) do
                            if StageAPI.DoesEntityDataMatchParameters(noInclude, ent) then
                                dontCount = true
                                break
                            end
                        end
                    end

                    if not dontCount then
                        includesAny = true
                        break
                    end
                end
            end
        end

        if mustExclude then
            for _, exclude in ipairs(mustExclude) do
                if StageAPI.DoesEntityDataMatchParameters(exclude, ent) then
                    return false
                end
            end
        end

        if #mustIncludeAllCopy > 0 then
            for i, include in StageAPI.ReverseIterate(mustIncludeAllCopy) do
                if StageAPI.DoesEntityDataMatchParameters(include, ent) then
                    local dontCount
                    if notIncluding then
                        for _, noInclude in ipairs(notIncluding) do
                            if StageAPI.DoesEntityDataMatchParameters(noInclude, ent) then
                                dontCount = true
                                break
                            end
                        end
                    end

                    if not dontCount then
                        table.remove(mustIncludeAllCopy, i)
                        break
                    end
                end
            end
        end
    end

    return includesAny and #mustIncludeAllCopy == 0
end

local excludeTypesFromClearing = {
    [EntityType.ENTITY_FAMILIAR] = true,
    [EntityType.ENTITY_PLAYER] = true,
    [EntityType.ENTITY_KNIFE] = true,
    [EntityType.ENTITY_DARK_ESAU] = true,
    [EntityType.ENTITY_MOTHERS_SHADOW] = true
}

-- These rooms consist purely of wall entities placed where the walls of the room should be
-- Used to fix the occasional broken walls when entering extra rooms
StageAPI.WallDataLayouts = StageAPI.RoomsList("StageAPIWallData", fixInclude("resources.stageapi.luarooms.walldata"))
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
    local shape = room:GetRoomShape()
    local data = StageAPI.WallData[shape]
    if data then
        for index, _ in pairs(data.Indices) do
            local grid = room:GetGridEntity(index)
            if not grid or (grid.Desc.Type ~= GridEntityType.GRID_WALL and grid.Desc.Type ~= GridEntityType.GRID_DOOR) then
                room:SpawnGridEntity(index, GridEntityType.GRID_WALL, 0, 1, 0)
            end
        end

        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)
            if not data.Indices[i] and grid and grid.Desc.Type == GridEntityType.GRID_WALL then
                room:RemoveGridEntity(i, 0, false)
            end
        end
    end
end

function StageAPI.ClearRoomLayout(keepDecoration, doGrids, doEnts, doPersistentEnts, onlyRemoveTheseDecorations, doWalls, doDoors, skipIndexedGrids)
    if StageAPI.InOrTransitioningToExtraRoom() and room:GetType() ~= RoomType.ROOM_DUNGEON then
        StageAPI.FixWalls()
    end

    if doEnts or doPersistentEnts then
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            local etype = ent.Type
            if not excludeTypesFromClearing[etype] then
                local persistentData = StageAPI.CheckPersistence(ent.Type, ent.Variant, ent.SubType)
                if (doPersistentEnts or (ent:ToNPC() and (not persistentData or not persistentData.AutoPersists))) and not (ent:HasEntityFlags(EntityFlag.FLAG_CHARM) or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT)) then
                    ent:Remove()
                end
            end
        end
    end

    if doGrids then
        if not skipIndexedGrids then
            local lindex = StageAPI.GetCurrentRoomID()
            local customGrids = StageAPI.GetTableIndexedByDimension(StageAPI.CustomGrids, true)
            customGrids[lindex] = {}

            local roomGrids = StageAPI.GetTableIndexedByDimension(StageAPI.RoomGrids, true)
            roomGrids[lindex] = {}
        end

        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)
            if grid then
                local gtype = grid.Desc.Type
                if (doWalls or gtype ~= GridEntityType.GRID_WALL or room:IsPositionInRoom(grid.Position, 0)) -- this allows custom wall grids to exist
                and (doDoors or gtype ~= GridEntityType.GRID_DOOR)
                and (not onlyRemoveTheseDecorations or gtype ~= GridEntityType.GRID_DECORATION or onlyRemoveTheseDecorations[i]) then
                    StageAPI.Room:RemoveGridEntity(i, 0, keepDecoration)
                end
            end
        end
    end

    StageAPI.CalledRoomUpdate = true
    room:Update()
    StageAPI.CalledRoomUpdate = false
end

function StageAPI.DoLayoutDoorsMatch(layout, doors)
    local numNonExistingDoors = 0
    local doesLayoutMatch = true
    for _, door in ipairs(layout.Doors) do
        if door.Slot and not door.Exists then
            if ((not doors and room:GetDoor(door.Slot)) or (doors and doors[door.Slot])) then
                doesLayoutMatch = false
            end
            numNonExistingDoors = numNonExistingDoors + 1
        end
    end

    return doesLayoutMatch, numNonExistingDoors
end

-- returns list of rooms, error message if no rooms valid
function StageAPI.GetValidRoomsForLayout(args)
    local roomList = args.RoomList
    local roomDesc = args.RoomDescriptor or level:GetCurrentRoomDesc()
    local shape = -1
    if not args.IgnoreShape then
        shape = args.Shape or roomDesc.Data.Shape
    end

    local callbacks = StageAPI.GetCallbacks("POST_CHECK_VALID_ROOM")
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

    for listID, layout in ipairs(possibleRooms) do
        shape = layout.Shape

        local isValid = true

        local numNonExistingDoors = 0
        if requireRoomType and layout.Type ~= rtype then
            isValid = false
        elseif not ignoreDoors then
            isValid, numNonExistingDoors = StageAPI.DoLayoutDoorsMatch(layout, doors)
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
                local ret = callback.Function(layout, roomList, seed, shape, rtype, requireRoomType)
                if ret == false then
                    isValid = false
                    break
                elseif type(ret) == "number" then
                    weight = ret
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
function StageAPI.ChooseRoomLayout(roomList, seed, shape, rtype, requireRoomType, ignoreDoors, doors, disallowIDs)
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
            DisallowIDs = disallowIDs
        }
    end

    local validRooms, totalWeight, err = StageAPI.GetValidRoomsForLayout(args)
    if err then StageAPI.LogErr(err) end

    if #validRooms > 0 then
        StageAPI.RoomChooseRNG:SetSeed(args.Seed, 0)
        local chosen = StageAPI.WeightedRNG(validRooms, StageAPI.RoomChooseRNG, nil, totalWeight)
        return chosen.Layout, chosen.ListID
    else
        StageAPI.LogErr("No rooms with correct shape and doors!")
    end
end

--[[ options
{
    Type = etype,
    Variant = variant,
    SubType = subtype,
    AutoPersists = autoPersists,
    RemoveOnRemove = removeOnRemove,
    RemoveOnDeath = removeOnDeath,
    UpdatePosition = updatePosition,
    StoreCheck = storeCheck
}
]]
StageAPI.PersistentEntities = {}
function StageAPI.AddEntityPersistenceData(persistenceData)
    StageAPI.PersistentEntities[#StageAPI.PersistentEntities + 1] = persistenceData
end

StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_STONEHEAD})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_CONSTANT_STONE_SHOOTER})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_STONE_EYE})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_BRIMSTONE_HEAD})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_WALL_HUGGER})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_POKY, Variant = 1})
StageAPI.AddEntityPersistenceData({
    Type = EntityType.ENTITY_FIREPLACE,
    AutoPersists = true,
    RemoveOnRemove = true,
    UpdateType = true,
    UpdateVariant = true,
    UpdateSubType = true,
    UpdateHealth = true,
})

StageAPI.PersistenceChecks = {}
function StageAPI.AddPersistenceCheck(fn)
    StageAPI.PersistenceChecks[#StageAPI.PersistenceChecks + 1] = fn
end

StageAPI.DynamicPersistentTypes = {
    EntityType.ENTITY_BOMBDROP,
    EntityType.ENTITY_PICKUP,
    EntityType.ENTITY_SLOT,
    EntityType.ENTITY_MOVABLE_TNT,
    EntityType.ENTITY_SHOPKEEPER,
    EntityType.ENTITY_PITFALL,
    EntityType.ENTITY_ETERNALFLY,
}

StageAPI.ChestVariants = {
    PickupVariant.PICKUP_CHEST,
    PickupVariant.PICKUP_LOCKEDCHEST,
    PickupVariant.PICKUP_BOMBCHEST,
    PickupVariant.PICKUP_ETERNALCHEST,
    PickupVariant.PICKUP_MIMICCHEST,
    PickupVariant.PICKUP_SPIKEDCHEST,
    PickupVariant.PICKUP_REDCHEST,
    PickupVariant.PICKUP_OLDCHEST,
    PickupVariant.PICKUP_WOODENCHEST,
    PickupVariant.PICKUP_MEGACHEST,
    PickupVariant.PICKUP_HAUNTEDCHEST,
    PickupVariant.PICKUP_MOMSCHEST,
}

StageAPI.AddPersistenceCheck(function(entData)
    local isDynamicPersistent = false
    for _, type in ipairs(StageAPI.DynamicPersistentTypes) do
        isDynamicPersistent = entData.Type == type
        if isDynamicPersistent then break end
    end
    if isDynamicPersistent then
        return {
            AutoPersists = true,
            UpdatePosition = true,
            RemoveOnRemove = true,
            UpdateType = true,
            UpdateVariant = true,
            UpdateSubType = true,
            StoreCheck = function(entity)
                if entity.Type == EntityType.ENTITY_PICKUP then
                    local variant = entity.Variant
                    if variant == PickupVariant.PICKUP_COLLECTIBLE then
                        return entity.SubType == 0
                    else
                        local isChest
                        for _, var in ipairs(StageAPI.ChestVariants) do
                            if variant == var then
                                isChest = true
                            end
                        end

                        if isChest then
                            return entity.SubType == 0
                        end

                        local sprite = entity:GetSprite()
                        if sprite:IsPlaying("Open") or sprite:IsPlaying("Opened") or sprite:IsPlaying("Collect") or sprite:IsFinished("Open") or sprite:IsFinished("Opened") or sprite:IsFinished("Collect") then
                            return true
                        end

                        if entity:IsDead() then
                            return true
                        end
                    end
                elseif entity.Type == EntityType.ENTITY_SLOT then
                    return entity:GetSprite():IsPlaying("Death") or entity:GetSprite():IsPlaying("Broken") or entity:GetSprite():IsFinished("Death") or entity:GetSprite():IsFinished("Broken")
                end
            end
        }
    end
end)

function StageAPI.CheckPersistence(id, variant, subtype)
    local persistentData

    for _, persistData in ipairs(StageAPI.PersistentEntities) do
        if (not persistData.Type or id == persistData.Type)
        and (not persistData.Variant or variant == persistData.Variant)
        and (not persistData.SubType or subtype == persistData.SubType) then
            persistentData = persistData
        end
    end

    if not persistentData then
        for _, check in ipairs(StageAPI.PersistenceChecks) do
            local persistData = check({Type = id, Variant = variant, SubType = subtype})
            if persistData then
                persistentData = persistData
                break
            end
        end
    end

    return persistentData
end

StageAPI.RoomLoadRNG = RNG()

StageAPI.MetadataEntities = {
    [199] = {
        [0] = {
            Name = "Group",
            Tags = "Group",
            ConflictTag = "Group",
            OnlyConflictWith = "RandomizeGroup",
            BitValues = {
                GroupID = {Offset = 0, Length = 16}
            },
        },
        [1] = {
            Name = "RandomizeGroup"
        },
        [2] = {
            Name = "Direction",
            Tag = "Direction",
            ConflictTag = "Direction",
            PreventConflictWith = "PreventDirectionConflict",
            BitValues = {
                Direction = {Offset = 0, Length = 4}
            }
        },
        [3] = {
            Name = "PreventDirectionConflict"
        },
        [10] = {
            Name = "EnteredFromTrigger",
            Tag = "StageAPILoadEditorFeature",
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [11] = {
            Name = "ShopItem",
            Tag = "StageAPIPickupEditorFeature",
            BitValues = {
                Price = {Offset = 0, Length = 7, ValueOffset = -5}
            }
        },
        [12] = {
            Name = "OptionsPickup",
            Tag = "StageAPIPickupEditorFeature",
            BitValues = {
                OptionsIndex = {Offset = 0, Length = 16, ValueOffset = 100}
            }
        },
        [13] = {
            Name = "CancelClearAward"
        },
        [14] = {
            Name = "SetPlayerPosition",
            Tag = "StageAPILoadEditorFeature",
            BitValues = {
                UnclearedOnly = {Offset = 0, Length = 1}
            }
        },
        [20] = {
            Name = "Swapper",
            GroupIDIfUngrouped = "Swapper",
            BitValues = {
                GroupID = {Offset = 0, Length = 15, ValueOffset = -1},
                NoMetadata = {Offset = 15, Length = 1}
            }
        },
        [21] = {
            Name = "Detonator",
            Tags = {"StageAPIEditorFeature", "Triggerable"},
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [22] = {
            Name = "RoomClearTrigger",
            Tag = "StageAPIEditorFeature",
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [23] = {
            Name = "Spawner",
            Tags = {"StageAPIEditorFeature", "Triggerable"},
            BlockEntities = true,
            HasPersistentData = true,
            BitValues = {
                GroupID = {Offset = 0, Length = 14, ValueOffset = -1},
                SpawnAll = {Offset = 14, Length = 1},
                SingleActivation = {Offset = 15, Length = 1}
            }
        },
        [24] = {
            Name = "PreventRandomization"
        },
        [25] = {
            Name = "BridgeFailsafe",
            Tag = "StageAPIEditorFeature"
        },
        [26] = {
            Name = "DetonatorTrigger",
            Tag = "StageAPIEditorFeature",
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [27] = {
            Name = "DoorLocker"
        },
        [28] = {
            Name = "GridDestroyer",
            Tags = {"StageAPIEditorFeature", "Triggerable"},
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [29] = {
            Name = "ButtonTrigger",
            Tag = "StageAPILoadEditorFeature",
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [30] = {
            Name = "BossIdentifier"
        },
        [40] = {
            Name = "Room"
        },
        [41] = {
            Name = "Stage"
        },
    }
}

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant ~= StageAPI.E.DeleteMeNPC.Variant then
        StageAPI.LogErr("Something is wrong! A StageAPI metadata entity has spawned when it should have been removed.")
    end
end, StageAPI.E.MetaEntity.T)

StageAPI.MetadataEntitiesByName = {}

StageAPI.UnblockableEntities = {}

for id, variants in pairs(StageAPI.MetadataEntities) do
    for variant, metadata in pairs(variants) do
        metadata.Variant = variant
        metadata.Type = id
        StageAPI.MetadataEntitiesByName[metadata.Name] = metadata
    end
end

function StageAPI.AddMetadataEntity(data, id, variant)
    if data.Group then -- backwards compatibility features
        if not data.Tags then
            data.Tags = {}
        end

        data.Tags[#data.Tags + 1] = data.Group

        if data.Conflicts then
            data.ConflictTag = data.Group
        end
    end

    if data.StoreAsGroup then
        data.GroupID = data.Name
    end

    if id and variant then
        if not StageAPI.MetadataEntities[id] then
            StageAPI.MetadataEntities[id] = {}
        end

        data.Type = id
        data.Variant =  variant

        StageAPI.MetadataEntities[id][variant] = data
    end

    StageAPI.MetadataEntitiesByName[data.Name] = data
end

function StageAPI.AddMetadataEntities(tbl)
    if type(next(tbl)) == "table" and next(tbl).Name then
        for variant, data in pairs(tbl) do
            if type(variant) == "string" then
                StageAPI.AddMetadataEntity(data)
            else
                StageAPI.AddMetadataEntity(data, 199, variant)
            end
        end
    elseif #tbl > 0 and next(tbl).Name then
        for _, data in ipairs(tbl) do
            StageAPI.AddMetadataEntity(data)
        end
    else
        for id, variantTable in pairs(tbl) do
            if type(id) == "string" then
                StageAPI.AddMetadataEntity(variantTable)
            else
                for variant, data in pairs(variantTable) do
                    StageAPI.AddMetadataEntity(data, id, variant)
                end
            end
        end
    end
end

function StageAPI.IsMetadataEntity(etype, variant)
    if type(etype) == "table" then
        variant = etype.Variant
        etype = etype.Type
    end

    return StageAPI.MetadataEntities[etype] and StageAPI.MetadataEntities[etype][variant]
end

function StageAPI.GetMetadataByName(metadataName)
    return StageAPI.MetadataEntitiesByName[metadataName]
end

function StageAPI.RoomDataHasMetadataEntity(data)
    local spawns = data.Spawns
    for i = 0, spawns.Size - 1 do
        local spawn = spawns:Get(i)
        if spawn then
            local sumWeight = spawn.SumWeights
            local weight = 0
            for i = 1, spawn.EntryCount do
                local entry = spawn:PickEntry(weight)
                weight = weight + entry.Weight / sumWeight

                if StageAPI.IsMetadataEntity(entry.Type, entry.Variant) then
                    return true
                end
            end
        end
    end

    return false
end

function StageAPI.AddUnblockableEntities(etype, variant, subtype) -- an entity that will not be blocked by the Spawner or other BlockEntities triggers
    if type(etype) == "table" then
        for _, ent in ipairs(etype) do
            StageAPI.AddUnblockableEntities(ent[1], ent[2], ent[3])
        end
    else
        if not StageAPI.UnblockableEntities[etype] then
            if variant then
                StageAPI.UnblockableEntities[etype] = {}
                if subtype then
                    StageAPI.UnblockableEntities[etype][variant] = {}
                    StageAPI.UnblockableEntities[etype][variant][subtype] = true
                else
                    StageAPI.UnblockableEntities[etype][variant] = true
                end
            else
                StageAPI.UnblockableEntities[etype] = true
            end
        end
    end
end

function StageAPI.IsEntityUnblockable(etype, variant, subtype)
    return StageAPI.UnblockableEntities[etype] == true
    or StageAPI.UnblockableEntities[etype] and (StageAPI.UnblockableEntities[etype][variant] == true
    or (StageAPI.UnblockableEntities[etype][variant] and StageAPI.UnblockableEntities[etype][variant][subtype] == true))
end

StageAPI.RoomMetadata = StageAPI.Class("RoomMetadata")

function StageAPI.RoomMetadata:Init()
    self.Groups = {}
    self.BlockedEntities = {}
    self.IndexMetadata = {}
end

function StageAPI.RoomMetadata:GroupsWithIndex(index)
    local groups = {}
    for groupID, indices in pairs(self.Groups) do
        if indices[index] or not index then
            groups[#groups + 1] = groupID
        end
    end

    return groups
end

function StageAPI.RoomMetadata:IsIndexInGroup(index, group)
    return self.Groups[group] and self.Groups[group][index]
end

function StageAPI.RoomMetadata:IndicesInGroup(group)
    local indices = self.Groups[group]
    local out = {}
    for index, _ in pairs(indices) do
        out[#out + 1] = index
    end

    return out
end

function StageAPI.RoomMetadata:AddIndexToGroup(index, group)
    if type(index) == "table" then
        for _, idx in ipairs(index) do
            self:RemoveIndexFromGroup(idx, group)
        end
    elseif type(group) == "table" then
        for _, grp in ipairs(group) do
            self:RemoveIndexFromGroup(index, grp)
        end
    else
        if not self.Groups[group] then
            self.Groups[group] = {}
        end

        self.Groups[group][index] = true
    end
end

function StageAPI.RoomMetadata:RemoveIndexFromGroup(index, group)
    if type(index) == "table" then
        for _, idx in ipairs(index) do
            self:AddIndexToGroup(idx, group)
        end
    elseif type(group) == "table" then
        for _, grp in ipairs(group) do
            self:AddIndexToGroup(index, grp)
        end
    elseif self.Groups[group] and self.Groups[group][index] then
        self.Groups[group][index] = nil
    end
end

function StageAPI.RoomMetadata:GetNextGroupID()
    if not self.LastGroupID then
        self.LastGroupID = 0
    end

    self.LastGroupID = self.LastGroupID - 1
    return self.LastGroupID
end

function StageAPI.RoomMetadata:AddMetadataEntity(index, entity, persistentIndex) -- also accepts a name rather than an entity
    if not self.IndexMetadata[index] then
        self.IndexMetadata[index] = {}
    end

    local metadata
    local name
    if entity and type(entity) ~= "string" then
        metadata = StageAPI.IsMetadataEntity(entity)
        name = metadata.Name
    else
        if entity then
            name = entity
            entity = nil
        end

        metadata = StageAPI.GetMetadataByName(name)
    end

    local metaEntity = {
        Name = name,
        Metadata = metadata,
        Entity = entity,
        Index = index
    }

    if metadata.BitValues then
        local sub = 0
        if entity and entity.SubType then
            sub = entity.SubType
        end

        metaEntity.BitValues = {}
        for name, bitValue in pairs(metadata.BitValues) do
            local val = StageAPI.GetBits(sub, bitValue.Offset or 0, bitValue.Length) + (bitValue.ValueOffset or 0)
            metaEntity.BitValues[name] = val
        end
    end

    if metadata.HasPersistentData then
        if not persistentIndex and self.LevelRoom then
            persistentIndex = self.LevelRoom:GetNextPersistentIndex()
        else
            persistentIndex = (persistentIndex and persistentIndex + 1) or 0
        end

        metaEntity.PersistentIndex = persistentIndex
    end

    self.IndexMetadata[index][#self.IndexMetadata[index] + 1] = metaEntity

    return metaEntity, persistentIndex
end

function StageAPI.RoomMetadata:GetBlockedEntities(index, setIfNot)
    if setIfNot and not self.BlockedEntities[index] then
        self.BlockedEntities[index] = {}
    end

    return self.BlockedEntities[index]
end

function StageAPI.RoomMetadata:SetBlockedEntities(index, tbl)
    self.BlockedEntities[index] = tbl
end

--[[

METADATA SEARCH PARAMS

{
    Names = { -- Matches "Name" from metadata entity data
        string,
        ...
    },
    Name = string, -- Singular version of Names

    Indices = { -- List of indices to search for metadata entities on
        GridIndex,
        ...
    },
    Index = GridIndex, -- Singular version of Indices

    Groups = { -- List of group ids to search for metadata entities contained within
        GroupID,
        ...
    },
    Group = GroupID, -- Singular version of Groups
    RequireAllGroups = boolean, -- If set to true, will only return metadata entities within ALL of the specified groups.

    IndicesOrGroups = boolean, -- If set to true, will return if either Groups works out or Indices works out, rather than requiring both

    Tags = { -- List of tags to search for metadata entities with "Tag = string" matching the tag, or "Tags = {"string"}" containing the tag
        string,
        ...
    },
    Tag = string, -- Singular version of Tags
    RequireAllTags = boolean, -- If set to true, will only return metadata entities with ALL of the specified tags.

    Metadata = { -- Checks each metadata entity's data for the specified keys and values, only returns if all match
        Key = Value
    },

    Entity = { -- Checks each metadata entity for the specified keys and values, only returns if all match
        Key = Value
    },

    BitValues = { -- Checks each metadata entity's BitValues for the specified keys and values, only returns if all match
        Key = Value
    },

    IndexTable = boolean, -- If set to true, will return meta entities as a table formatted {[index] = {metaEntity, metaEntity}}
    IndexBooleanTable = boolean, -- If set to true, will return meta entities as a table formatted {[index] = true} for indices that have a matching metadata entity
}

]]

function StageAPI.RoomMetadata:IndexMatchesSearchParams(index, searchParams, checkIndices, checkGroups)
    if not checkIndices then
        checkIndices = searchParams.Indices or {}
        checkIndices[#checkIndices + 1] = searchParams.Index
        for _, index in ipairs(checkIndices) do
            checkIndices[index] = true
        end
    end

    local indexMatches = true
    if #checkIndices > 0 and not checkIndices[index] then
        if searchParams.IndicesOrGroups then
            indexMatches = false
        else
            return false
        end
    end

    if not checkGroups then
        checkGroups = searchParams.Groups or {}
        checkGroups[#checkGroups + 1] = searchParams.Group
    end

    local groupMatches = true
    if #checkGroups > 0 then
        local hasGroup
        for _, groupID in ipairs(checkGroups) do
            if self.Groups[groupID] and self.Groups[groupID][index] then
                hasGroup = true
                if not searchParams.RequireAllGroups then
                    break
                end
            elseif searchParams.RequireAllGroups then
                if searchParams.IndicesOrGroups then
                    groupMatches = false
                else
                    return false
                end
            end
        end

        if not hasGroup then
            if searchParams.IndicesOrGroups then
                groupMatches = false
            else
                return false
            end
        end
    end

    if searchParams.IndicesOrGroups then
        return indexMatches or groupMatches
    else
        return true
    end
end

function StageAPI.RoomMetadata:EntityMatchesSearchParams(metadataEntity, searchParams, checkNames, checkTags)
    if not checkNames then
        checkNames = searchParams.Names or {}
        checkNames[#checkNames + 1] = searchParams.Name
    end

    if #checkNames > 0 and not StageAPI.IsIn(checkNames, metadataEntity.Name) then
        return false
    end

    local metadata = metadataEntity.Metadata

    if not checkTags then
        checkTags = searchParams.Tags or {}
        checkTags[#checkTags + 1] = searchParams.Tag
    end

    if #checkTags > 0 then
        local hasTag
        for _, tag in ipairs(checkTags) do
            if metadata.Tag == tag or (metadata.Tags and StageAPI.IsIn(metadata.Tags, tag)) then
                hasTag = true
                if not searchParams.RequireAllTags then
                    break
                end
            elseif searchParams.RequireAllTags then
                return false
            end
        end

        if not hasTag then
            return false
        end
    end

    if searchParams.Metadata then
        for k, v in pairs(searchParams.Metadata) do
            if metadata[k] ~= v then
                return false
            end
        end
    end

    if searchParams.Entity then
        for k, v in pairs(searchParams.Entity) do
            if metadataEntity[k] ~= v then
                return false
            end
        end
    end

    if searchParams.BitValues then
        if not metadataEntity.BitValues then
            return false
        end

        for k, v in pairs(searchParams.BitValues) do
            if metadataEntity.BitValues[k] ~= v then
                return false
            end
        end
    end

    return true
end

function StageAPI.RoomMetadata:Search(searchParams, narrowEntities)
    searchParams = searchParams or {}
    local checkIndices, checkGroups, checkNames, checkTags = searchParams.Indices or {}, searchParams.Groups or {}, searchParams.Names or {}, searchParams.Tags or {}
    checkIndices[#checkIndices + 1] = searchParams.Index
    checkGroups[#checkGroups + 1] = searchParams.Group
    checkNames[#checkNames + 1] = searchParams.Name
    checkTags[#checkTags + 1] = searchParams.Tag

    for _, index in ipairs(checkIndices) do
        checkIndices[index] = true
    end

    local matchingEntities = {}
    if narrowEntities then
        for _, metadataEntity in ipairs(narrowEntities) do
            if not searchParams.IndexBooleanTable or not matchingEntities[metadataEntity.Index] then
                if self:IndexMatchesSearchParams(metadataEntity.Index, searchParams, checkIndices, checkGroups) then
                    if self:EntityMatchesSearchParams(metadataEntity, searchParams, checkNames, checkTags) then
                        if searchParams.IndexBooleanTable then
                            matchingEntities[metadataEntity.Index] = true
                        elseif searchParams.IndexTable then
                            matchingEntities[metadataEntity.Index] = matchingEntities[metadataEntity.Index] or {}
                            matchingEntities[metadataEntity.Index][#matchingEntities[metadataEntity.Index] + 1] = metadataEntity
                        else
                            matchingEntities[#matchingEntities + 1] = metadataEntity
                        end
                    end
                end
            end
        end
    else
        for index, metadataEntities in pairs(self.IndexMetadata) do
            if self:IndexMatchesSearchParams(index, searchParams, checkIndices, checkGroups) then
                for _, metadataEntity in ipairs(metadataEntities) do
                    if self:EntityMatchesSearchParams(metadataEntity, searchParams, checkNames, checkTags) then
                        if searchParams.IndexBooleanTable then
                            matchingEntities[index] = true
                            break
                        elseif searchParams.IndexTable then
                            matchingEntities[index] = matchingEntities[index] or {}
                            matchingEntities[index][#matchingEntities[index] + 1] = metadataEntity
                        else
                            matchingEntities[#matchingEntities + 1] = metadataEntity
                        end
                    end
                end
            end
        end
    end

    return matchingEntities
end

function StageAPI.RoomMetadata:Has(searchParams, narrowEntities)
    return #self:Search(searchParams, narrowEntities) > 0
end

function StageAPI.RoomMetadata:GetDirections(index)
    local directions = self:Search({Name = "Direction", Index = index})
    local outDirections = {}
    for _, direction in ipairs(directions) do
        local angle = direction.BitValues.Direction * (360 / 16)
        outDirections[#outDirections + 1] = angle
    end

    return outDirections
end

function StageAPI.SeparateEntityMetadata(entities, grids, seed)
    StageAPI.RoomLoadRNG:SetSeed(seed or room:GetSpawnSeed(), 1)
    local outEntities = {}
    local roomMetadata = StageAPI.RoomMetadata()

    local persistentIndex

    for index, entityList in pairs(entities) do
        local outList = {}
        for _, entity in ipairs(entityList) do
            local metadata = StageAPI.IsMetadataEntity(entity.Type, entity.Variant)
            if metadata then
                local _, newPersistentIndex = roomMetadata:AddMetadataEntity(index, entity, persistentIndex)
                persistentIndex = newPersistentIndex
            else
                outList[#outList + 1] = entity
            end
        end

        outEntities[index] = outList
    end

    local outGrids = {}
    for index, gridList in pairs(grids) do
        outGrids[index] = gridList
    end

    StageAPI.CallCallbacks("PRE_PARSE_METADATA", false, roomMetadata, outEntities, outGrids, StageAPI.RoomLoadRNG)

    for index, metadataEntities in pairs(roomMetadata.IndexMetadata) do
        local setsOfConflicting = {}
        for _, metaEntity in StageAPI.ReverseIterate(metadataEntities) do
            local metadata = metaEntity.Metadata
            if metadata.ConflictTag and not setsOfConflicting[metadata.ConflictTag] then
                local shouldConflict = true
                if metadata.PreventConflictWith or metadata.OnlyConflictWith then
                    if metadata.PreventConflictWith then
                        shouldConflict = not roomMetadata:Has({Index = index, Name = metadata.PreventConflictWith})
                    elseif metadata.OnlyConflictWith then
                        shouldConflict = roomMetadata:Has({Index = index, Name = metadata.OnlyConflictWith})
                    end
                end

                if shouldConflict then
                    setsOfConflicting[metadata.ConflictTag] = {}

                    for i, metaEntity2 in StageAPI.ReverseIterate(metadataEntities) do
                        local metadata2 = metaEntity2.Metadata
                        if metadata2.ConflictTag and metadata2.ConflictTag == metadata.ConflictTag then
                            setsOfConflicting[metadata.ConflictTag][#setsOfConflicting[metadata.ConflictTag] + 1] = metaEntity
                            table.remove(metadataEntities, i)
                        end
                    end
                end
            end
        end

        for conflictTag, metaEntities in pairs(setsOfConflicting) do
            local use = metaEntities[StageAPI.Random(1, #metaEntities, StageAPI.RoomLoadRNG)]
            metadataEntities[#metadataEntities + 1] = use
        end

        for _, metaEntity in ipairs(metadataEntities) do
            local metadata = metaEntity.Metadata

            local groupID
            if metaEntity.BitValues and metaEntity.BitValues.GroupID and metaEntity.BitValues.GroupID ~= -1 then
                groupID = metaEntity.BitValues.GroupID
            elseif metadata.GroupID then
                groupID = metadata.GroupID
            end

            if groupID then
                roomMetadata:AddIndexToGroup(index, groupID)
            end
        end

        if #roomMetadata:GroupsWithIndex(index) == 0 then
            for _, metaEntity in ipairs(metadataEntities) do
                local groupID = metaEntity.Metadata.GroupIDIfUngrouped
                if groupID then
                    if not roomMetadata.Groups[groupID] then
                        roomMetadata.Groups[groupID] = {}
                    end

                    roomMetadata.Groups[groupID][index] = true
                end
            end
        end
    end

    StageAPI.CallCallbacks("POST_PARSE_METADATA", nil, roomMetadata, outEntities, outGrids)

    return outEntities, outGrids, roomMetadata, persistentIndex
end

function StageAPI.AddEntityToSpawnList(tbl, entData, persistentIndex, index)
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

    if not entData.GridX or not entData.GridY then
        local width
        if currentRoom and currentRoom.Layout and currentRoom.Layout.Width then
            width = currentRoom.Layout.Width
        else
            width = room:GetGridWidth()
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

function StageAPI.SelectSpawnEntities(entities, seed, roomMetadata, lastPersistentIndex)
    StageAPI.RoomLoadRNG:SetSeed(seed or room:GetSpawnSeed(), 1)
    local entitiesToSpawn = {}
    local callbacks = StageAPI.GetCallbacks("PRE_SELECT_ENTITY_LIST")
    local persistentIndex = (lastPersistentIndex and lastPersistentIndex + 1) or 0
    for index, entityList in pairs(entities) do
        if #entityList > 0 then
            local addEntities = {}
            local overridden, stillAddRandom = false, nil
            for _, callback in ipairs(callbacks) do
                local retAdd, retList, retRandom = callback.Function(entityList, index, roomMetadata)
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

            if not overridden or (stillAddRandom and #entityList > 0) then
                addEntities[#addEntities + 1] = entityList[StageAPI.Random(1, #entityList, StageAPI.RoomLoadRNG)]
            end

            if #addEntities > 0 then
                if not entitiesToSpawn[index] then
                    entitiesToSpawn[index] = {}
                end

                for _, entData in ipairs(addEntities) do
                    persistentIndex = StageAPI.AddEntityToSpawnList(entitiesToSpawn[index], entData, persistentIndex)
                end
            end
        end
    end

    return entitiesToSpawn, persistentIndex
end

function StageAPI.SelectSpawnGrids(gridsByIndex, seed)
    StageAPI.RoomLoadRNG:SetSeed(seed or room:GetSpawnSeed(), 1)
    local spawnGrids = {}

    local callbacks = StageAPI.GetCallbacks("PRE_SELECT_GRIDENTITY_LIST")
    for index, grids in pairs(gridsByIndex) do
        if #grids > 0 then
            local spawnGrid, noSpawnGrid
            for _, callback in ipairs(callbacks) do
                local ret = callback.Function(grids, index)
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

function StageAPI.ObtainSpawnObjects(layout, seed)
    local entitiesByIndex, gridsByIndex, roomMetadata, lastPersistentIndex = StageAPI.SeparateEntityMetadata(layout.EntitiesByIndex, layout.GridEntitiesByIndex, seed)
    local spawnEntities, lastPersistentIndex = StageAPI.SelectSpawnEntities(entitiesByIndex, seed, roomMetadata)
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

function StageAPI.GetEntityPersistenceData(entity)
    local ent = StageAPI.ActiveEntityPersistenceData[GetPtrHash(entity)]
    if ent then
        return ent.Index, ent.Data
    end
end

function StageAPI.SetEntityPersistenceData(entity, persistentIndex, persistenceData)
    StageAPI.ActiveEntityPersistenceData[GetPtrHash(entity)] = {
        Index = persistentIndex,
        Data = persistenceData
    }
end

function StageAPI.LoadEntitiesFromEntitySets(entitysets, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, loadingWave)
    local ents_spawned = {}
    local listCallbacks = StageAPI.GetCallbacks("PRE_SPAWN_ENTITY_LIST")
    local entCallbacks = StageAPI.GetCallbacks("PRE_SPAWN_ENTITY")
    if type(entitysets) ~= "table" then
        entitysets = {entitysets}
    end

    for _, entities in ipairs(entitysets) do
        for index, entityList in pairs(entities) do
            if #entityList > 0 then
                local shouldSpawn = true
                for _, callback in ipairs(listCallbacks) do
                    local ret = callback.Function(entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData)
                    if ret == false then
                        shouldSpawn = false
                        break
                    elseif ret and type(ret) == "table" then
                        entityList = ret
                        break
                    end
                end

                if shouldSpawn and #entityList > 0 then
                    local roomType = room:GetType()
                    for _, entityInfo in ipairs(entityList) do
                        local shouldSpawnEntity = true

                        if shouldSpawnEntity and avoidSpawning and avoidSpawning[entityInfo.PersistentIndex] then
                            shouldSpawnEntity = false
                        end

                        local entityPersistData, persistData
                        if entityInfo.Persistent then
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
                            entityInfo.Position = room:GetGridPosition(index)
                        end

                        for _, callback in ipairs(entCallbacks) do
                            if not callback.Params[1] or (entityInfo.Data.Type and callback.Params[1] == entityInfo.Data.Type)
                            and not callback.Params[2] or (entityInfo.Data.Variant and callback.Params[2] == entityInfo.Data.Variant)
                            and not callback.Params[3] or (entityInfo.Data.SubType and callback.Params[3] == entityInfo.Data.SubType) then
                                local ret = callback.Function(entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, shouldSpawnEntity)
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

                        if shouldSpawnEntity then
                            local entityData = entityInfo.Data
                            if doGrids or (entityData.Type > 9 and entityData.Type ~= EntityType.ENTITY_FIREPLACE) then
                                local ent = Isaac.Spawn(
                                    entityData.Type or 20,
                                    entityData.Variant or 0,
                                    entityData.SubType or 0,
                                    entityInfo.Position or StageAPI.ZeroVector,
                                    StageAPI.ZeroVector,
                                    nil
                                )

                                if entityPersistData and entityPersistData.Health then
                                    ent.HitPoints = entityPersistData.Health
                                end

                                local currentRoom = StageAPI.GetCurrentRoom()
                                if currentRoom and not currentRoom.IgnoreRoomRules then
                                    if entityData.Type == EntityType.ENTITY_PICKUP and entityData.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                                        if currentRoom.RoomType == RoomType.ROOM_TREASURE then
                                            if currentRoom.Layout.Variant > 0 or string.find(string.lower(currentRoom.Layout.Name), "choice") or string.find(string.lower(currentRoom.Layout.Name), "choose") then
                                                ent:ToPickup().OptionsPickupIndex = 1
                                            end

                                            local isShopItem
                                            for _, player in ipairs(players) do
                                                if player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
                                                    isShopItem = true
                                                    break
                                                end
                                            end

                                            if isShopItem then
                                                ent:ToPickup().Price = 15
                                                ent:ToPickup().AutoUpdatePrice = true
                                            end
                                        end
                                    end
                                end

                                ent:GetData().StageAPISpawnedPosition = entityInfo.Position or StageAPI.ZeroVector
                                ent:GetData().StageAPIEntityListIndex = index

                                if entityInfo.Persistent then
                                    StageAPI.SetEntityPersistenceData(ent, entityInfo.PersistentIndex, persistData)
                                end

                                if not loadingWave and ent:CanShutDoors() then
                                    StageAPI.Room:SetClear(false)
                                end

                                StageAPI.CallCallbacks("POST_SPAWN_ENTITY", false, ent, entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, shouldSpawnEntity)

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
    for i = 0, room:GetGridSize() do
        local grid = room:GetGridEntity(i)
        if grid then
            grid:PostInit()

            if StageAPI.RockTypes[grid.Desc.Type] then
                grid:ToRock():UpdateAnimFrame()
            end
        end
    end
end

StageAPI.GridSpawnRNG = RNG()
function StageAPI.LoadGridsFromDataList(grids, gridInformation, entities)
    local grids_spawned = {}
    StageAPI.GridSpawnRNG:SetSeed(room:GetSpawnSeed(), 0)
    local callbacks = StageAPI.GetCallbacks("PRE_SPAWN_GRID")

    local iterList = gridInformation or grids

    for index, gridData in pairs(iterList) do
        local shouldSpawn = true
        for _, callback in ipairs(callbacks) do
            local ret = callback.Function(gridData, gridInformation, entities, StageAPI.GridSpawnRNG)
            if ret == false then
                shouldSpawn = false
                break
            elseif type(ret) == "table" then
                gridData = ret
            end
        end

        if shouldSpawn and room:IsPositionInRoom(StageAPI.Room:GetGridPosition(index), 0) then
            room:RemoveGridEntity(index, 0, false)
            local grid = Isaac.GridSpawn(gridData.Type, gridData.Variant, StageAPI.Room:GetGridPosition(index), true)
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
                    StageAPI.Room:SetClear(false)
                end

                grids_spawned[#grids_spawned + 1] = grid
            end
        end
    end

    return grids_spawned
end

function StageAPI.GetGridInformation()
    local gridInformation = {}
    for i = 0, room:GetGridSize() do
        local grid = room:GetGridEntity(i)
        if grid and grid.Desc.Type ~= GridEntityType.GRID_DOOR and (grid.Desc.Type ~= GridEntityType.GRID_WALL or room:IsPositionInRoom(grid.Position, 0)) then
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

function StageAPI.GetCurrentRoomID()
    local levelMap = StageAPI.GetCurrentLevelMap()
    if levelMap and StageAPI.CurrentLevelMapRoomID then
        return levelMap:GetRoomData(StageAPI.CurrentLevelMapRoomID).RoomID
    else
        return StageAPI.GetCurrentListIndex()
    end
end

StageAPI.LevelRooms = {}
function StageAPI.GetDimension(roomDesc)
    if not roomDesc then
        local levelMap = StageAPI.GetCurrentLevelMap()
        if levelMap and StageAPI.CurrentLevelMapRoomID then
            return levelMap.Dimension
        end
    end

    roomDesc = roomDesc or level:GetCurrentRoomDesc()
    if roomDesc.GridIndex < 0 then -- Off-grid rooms
        return -2
    end

    local hash = GetPtrHash(roomDesc)
    for dimension = 0, 2 do
        local dimensionDesc = level:GetRoomByIdx(roomDesc.SafeGridIndex, dimension)
        if GetPtrHash(dimensionDesc) == hash then
            return dimension
        end
    end
end

function StageAPI.GetTableIndexedByDimension(tbl, setIfNot, dimension)
    dimension = dimension or StageAPI.GetDimension()
    if setIfNot and not tbl[dimension] then
        tbl[dimension] = {}
    end
    return tbl[dimension]
end

function StageAPI.GetTableIndexedByDimensionRoom(tbl, setIfNot, dimension, roomID)
    local byDimension = StageAPI.GetTableIndexedByDimension(tbl, setIfNot, dimension)
    roomID = roomID or StageAPI.GetCurrentRoomID()
    if byDimension then
        if setIfNot and not byDimension[roomID] then
            byDimension[roomID] = {}
        end

        return byDimension[roomID]
    end
end

function StageAPI.GetLevelRoom(roomID, dimension)
    dimension = dimension or StageAPI.GetDimension()
    return StageAPI.LevelRooms[dimension] and StageAPI.LevelRooms[dimension][roomID]
end

function StageAPI.GetAllLevelRooms()
    local levelRooms = {}
    for dimension, rooms in pairs(StageAPI.LevelRooms) do
        for index, levelRoom in pairs(rooms) do
            levelRooms[#levelRooms + 1] = levelRoom
        end
    end

    return levelRooms
end

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
        return currentRoom.TypeOverride or currentRoom.RoomType or room:GetType()
    else
        return room:GetType()
    end
end

function StageAPI.GetRooms()
    return StageAPI.LevelRooms
end

function StageAPI.CloseDoors()
    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door then
            door:Close()
        end
    end
end

function StageAPI.GetDoorsForRoom()
    local doors = {}
    for i = 0, 7 do
        doors[i] = not not room:GetDoor(i)
    end
    return doors
end

StageAPI.AllDoorsOpen = {}
for i = 0, 7 do
    StageAPI.AllDoorsOpen[i] = true
end

function StageAPI.GetDoorsForRoomFromData(data)
    local doors = {}
    for i = 0, 7 do
        doors[i] = data.Doors & StageAPI.DoorsBitwise[i] ~= 0
    end

    return doors
end

function StageAPI.LevelRoomArgPacker(layoutName, roomsList, seed, shape, roomType, isExtraRoom, fromSaveData, requireRoomType, ignoreDoors, doors, levelIndex, ignoreRoomRules)
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
        IgnoreRoomRules = ignoreRoomRules
    }
end

local levelRoomCopyFromArgs = {"IsExtraRoom","LevelIndex", "IgnoreDoors","Doors", "IgnoreShape","Shape","RoomType","SpawnSeed","LayoutName","RequireRoomType","IgnoreRoomRules","DecorationSeed","AwardSeed","VisitCount","IsClear","ClearCount","IsPersistentRoom","HasWaterPits","ChallengeDone","FromData","Dimension","RoomsListName","RoomsListID"}

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

    StageAPI.CallCallbacks("POST_ROOM_INIT", false, self, not not fromSaveData, fromSaveData)
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
        local roomDesc = level:GetRooms():Get(self.FromData)
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
        local roomsList = StageAPI.CallCallbacks("PRE_ROOMS_LIST_USE", true, self) or StageAPI.RoomsLists[self.RoomsListName]
        if roomsList then
            self.RoomsListName = roomsList.Name

            local retLayout = StageAPI.CallCallbacks("PRE_ROOM_LAYOUT_CHOOSE", true, self, roomsList)
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

    StageAPI.LogMinor("Initialized room " .. self.Layout.Name .. "." .. tostring(self.Layout.Variant) .. " from file " .. tostring(self.Layout.RoomFilename)
                        .. (roomsList and (' from list ' .. roomsList.Name) or ''))

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
                    local grindex = room:GetGridIndex(entity.Position)
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

function StageAPI.LevelRoom:Load(isExtraRoom, noIncrementVisit)
    StageAPI.LogMinor("Loading room " .. self.Layout.Name .. "." .. tostring(self.Layout.Variant) .. " from file " .. tostring(self.Layout.RoomFilename))
    if isExtraRoom == nil then
        isExtraRoom = self.IsExtraRoom
    end

    room:SetClear(true)

    if not noIncrementVisit then
        self.VisitCount = self.VisitCount + 1
    end

    local wasFirstLoad = self.FirstLoad
    StageAPI.ClearRoomLayout(false, self.FirstLoad or isExtraRoom, true, self.FirstLoad or isExtraRoom, self.GridTakenIndices, nil, nil, not self.FirstLoad)
    if self.FirstLoad then
        StageAPI.LoadRoomLayout(self.SpawnGrids, {self.SpawnEntities, self.ExtraSpawn}, true, true, self.IsClear, true, self.GridInformation, self.AvoidSpawning, self.PersistenceData)
        self.WasClearAtStart = room:IsClear()
        self.IsClear = self.WasClearAtStart
        self.FirstLoad = false
        self.HasEnemies = room:GetAliveEnemiesCount() > 0
    else
        StageAPI.LoadRoomLayout(self.SpawnGrids, {self.SpawnEntities, self.ExtraSpawn}, isExtraRoom, true, self.IsClear, isExtraRoom, self.GridInformation, self.AvoidSpawning, self.PersistenceData)
        self.IsClear = room:IsClear()
    end

    StageAPI.CalledRoomUpdate = true
    room:Update()
    StageAPI.CalledRoomUpdate = false
    if not self.IsClear then
        StageAPI.CloseDoors()
    end

    self.Loaded = true

    StageAPI.CallCallbacks("POST_ROOM_LOAD", false, self, wasFirstLoad, isExtraRoom)
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
        for pindex, persistData in pairs(saveData.PersistenceData) do
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

function StageAPI.RemovePersistentEntity(entity)
    local currentRoom = StageAPI.GetCurrentRoom()
    if currentRoom then
        currentRoom:RemovePersistentEntity(entity)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, ent)
    local index, data = StageAPI.GetEntityPersistenceData(ent)
    -- Entities are removed whenever you exit the room, in this time the game is paused, which we can use to stop removing persistent entities on room exit.
    if data and data.RemoveOnRemove and not game:IsPaused() then
        StageAPI.RemovePersistentEntity(ent)
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, ent)
    local index, data = StageAPI.GetEntityPersistenceData(ent)
    if data and data.RemoveOnDeath then
        StageAPI.RemovePersistentEntity(ent)
    end
end)

function StageAPI.IsDoorSlotAllowed(slot)
    local currentRoom = StageAPI.GetCurrentRoom()
    if currentRoom and currentRoom.Layout and currentRoom.Layout.Doors then
        for _, door in ipairs(currentRoom.Layout.Doors) do
            if door.Slot == slot and door.Exists then
                return true
            end
        end
    else
        return room:IsDoorSlotAllowed(slot)
    end
end

function StageAPI.SetRoomFromList(roomsList, roomType, requireRoomType, isExtraRoom, load, seed, shape, fromSaveData)
    local levelIndex = StageAPI.GetCurrentRoomID()
    local newRoom = StageAPI.LevelRoom(nil, roomsList, seed, shape, roomType, isExtraRoom, fromSaveData, requireRoomType, nil, nil, levelIndex)
    StageAPI.SetCurrentRoom(newRoom)

    if load then
        newRoom:Load(isExtraRoom)
    end

    return newRoom
end