local shared = require("scripts.stageapi.shared")

StageAPI.RoomsLists = {}


---@param name string
---@vararg string roomfiles
---@return RoomsList
function StageAPI.RoomsList(name, ...)
end

--- Constructor: (name, roomFiles...)
---@class RoomsList : StageAPIClass
StageAPI.RoomsList = StageAPI.Class("RoomsList")

function StageAPI.RoomsList:Init(name, ...)
    self.Name = name
    StageAPI.RoomsLists[name] = self
    ---@type RoomLayout[]
    self.All = {}
    ---@type table<RoomShape, RoomLayout[]>
    self.ByShape = {}
    ---@type RoomShape[]
    self.Shapes = {}
    self.NotSimplifiedFiles = {}
    self:AddRooms(...)
end

---@vararg string roomFiles
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
                ---@type RoomLayout
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

---@param shape RoomShape
---@return RoomLayout[]
function StageAPI.RoomsList:GetRooms(shape)
    if shape == -1 then
        return self.All
    else
        return self.ByShape[shape]
    end
end

---@param roomsList RoomsList
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

---Split passed list of rooms depending on specified logic
---@param roomsList table[]
---@param splitBy RoomType[] | RoomLayout_EntityData[] | table[]
---@param splitByType? boolean
---@param createEntityPlaceholders? boolean
---@param listNamePrefix? string
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
            StageAPI.RoomsList(listNamePrefix .. listName, rooms)
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
