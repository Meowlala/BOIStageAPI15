local shared = require("scripts.stageapi.shared")

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
    local roomsList = shared.Level:GetRooms()
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
    return (not param.Type or param.Type == data.Type) 
    and (not param.Variant or param.Variant == data.Variant) 
    and (not param.SubType or param.SubType == data.SubType)
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