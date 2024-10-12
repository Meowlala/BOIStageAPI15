local mod = require("scripts.stageapi.mod")
local shared = require("scripts.stageapi.shared")

StageAPI.RoomNamesEnabled = false
StageAPI.GlobalCommandMode = false

local testingStage
local testingRoomsList
local testSuite = include("resources.stageapi.luarooms.testsuite")
local mapLayoutTestRoomsList = StageAPI.RoomsList("MapLayoutTest", testSuite)

local function keys(tbl)
    local out = {}
    for k, _ in pairs(tbl) do out[#out+1] = k end
    return out
end

local function map(tbl, fun)
    local out = {}
    for k, v in pairs(tbl) do out[k] = fun(v) end
    return out
end

---@type {[string]: {Execute: fun(params: string): (string?), Autocomplete: (fun(params: string): table?)?|AutocompleteType, Aliases: string[]?, Help: string?, Desc: string, Usage: string?, File: string?}}
local Commands = {
    customstage = {
        Execute = function (params)
            if StageAPI.CustomStages[params] then
                StageAPI.GotoCustomStage(StageAPI.CustomStages[params])
            else
                Isaac.ConsoleOutput("No CustomStage " .. params)
            end
        end,
        Autocomplete = function (params)
            return keys(StageAPI.CustomStages)
        end,
        Desc = "Teleport to custom stage",
        Help = "Goes to a custom stage registered with StageAPI",
        Usage = "stageName",
        Aliases = {"cstage"},
    },
    nextstage = {
        Execute = function (params)
            if  StageAPI.CurrentStage and StageAPI.CurrentStage.NextStage then
                StageAPI.GotoCustomStage(StageAPI.CurrentStage.NextStage)
            end
        end,
        Desc = "Go to next custom stage",
        Help = "Goes to the stage after this custom stage (if any)",
        Aliases = {"nstage"},
    },
    reload = {
        Execute = function (params)
            StageAPI.LoadSaveString(StageAPI.GetSaveString())
        end,
        Desc = "Reload StageAPI save data",
    },
    printsave = {
        Execute = function (params)
            Isaac.DebugString(StageAPI.GetSaveString())
        end,
        Desc = "Print StageAPI save data",
    },
    regroom = {
        Execute = function (params)
            if StageAPI.Layouts[params] then
                local testRoom = StageAPI.LevelRoom{
                    LayoutName = params,
                    Shape = StageAPI.Layouts[params].Shape,
                    RoomType = StageAPI.Layouts[params].Type,
                }
    
                local levelMap = StageAPI.GetDefaultLevelMap()
                local addedRoomData = levelMap:AddRoom(testRoom, {RoomID = "StageAPITest"}, true)
    
                local doors = {}
                for _, door in ipairs(StageAPI.Layouts[params].Doors) do
                    if door.Exists then
                        doors[#doors + 1] = door.Slot
                    end
                end
    
                StageAPI.ExtraRoomTransition(addedRoomData.MapID, nil, nil, StageAPI.DefaultLevelMapID, doors[StageAPI.Random(1, #doors)])
            else
                Isaac.ConsoleOutput(params .. " is not a registered room.\n")
            end
        end,
        Autocomplete = function (params)
            return keys(StageAPI.Layouts)
        end,
        Desc = "Teleport to special custom room layout",
        Usage = "layoutName",
        Help = "Teleport to a room with the specified stageapi registered room layout",
    },
    croom = {
        Execute = function (params)
            local paramTable = {}
            for word in params:gmatch("%S+") do paramTable[#paramTable + 1] = word end
            local name = tonumber(paramTable[1]) or paramTable[1]
            local listName = paramTable[2]
            if name then
                local list
                if listName then
                    listName = string.gsub(listName, "_", " ")
                    if StageAPI.RoomsLists[listName] then
                        list = StageAPI.RoomsLists[listName]
                    else
                        Isaac.ConsoleOutput("Room List name invalid.")
                        return
                    end
                elseif StageAPI.CurrentStage and StageAPI.CurrentStage.Rooms and StageAPI.CurrentStage.Rooms[RoomType.ROOM_DEFAULT] then
                    list = StageAPI.CurrentStage.Rooms[RoomType.ROOM_DEFAULT]
                else
                    Isaac.ConsoleOutput("Must supply Room List name or be in a custom stage with rooms.")
                    return
                end
    
                if type(name) == "string" then
                    name = string.gsub(name, "_", " ")
                end
    
                local selectedLayout
                for _, room in ipairs(list.All) do
                    if room.Name == name or room.Variant == name then
                        selectedLayout = room
                        break
                    end
                end
    
                if selectedLayout then
                    StageAPI.RegisterLayout("StageAPITest", selectedLayout)
                    local testRoom = StageAPI.LevelRoom{
                        LayoutName = "StageAPITest",
                        Shape = selectedLayout.Shape,
                        RoomType = selectedLayout.Type
                    }
    
                    local levelMap = StageAPI.GetDefaultLevelMap()
                    local addedRoomData = levelMap:AddRoom(testRoom, {RoomID = "StageAPITest"}, true)
    
                    local doors = {}
                    for _, door in ipairs(selectedLayout.Doors) do
                        if door.Exists then
                            doors[#doors + 1] = door.Slot
                        end
                    end
    
                    StageAPI.ExtraRoomTransition(addedRoomData.MapID, nil, nil, StageAPI.DefaultLevelMapID, doors[StageAPI.Random(1, #doors)])
                else
                    Isaac.ConsoleOutput("Room with ID or name " .. tostring(name) .. " does not exist.")
                end
            else
                Isaac.ConsoleOutput("A room ID or name is required.")
            end
        end,
        Autocomplete = function (params)
            local paramTable = {}
            for word in params:gmatch("%S+") do paramTable[#paramTable + 1] = word end

            if #paramTable == 0 then
                -- Would need to list both room lists and rooms for current stage, rather 
                return nil
            else
                return map(keys(StageAPI.RoomsLists), function(s) return string.gsub(s, " ", "_") end)
            end
        end,
        Desc = "Teleport to custom room in stage or list",
        Usage = "roomName|roomId [roomListName]",
        Help = "Teleport to a StageAPI room in the specified list, or in the current stage if no list is specified. Note that underscores in names are replaced with spaces.",
    },
    crooml = {
        Execute = function (params)
            local paramTable = {}
            for word in params:gmatch("%S+") do paramTable[#paramTable + 1] = word end
            local listName = paramTable[1]
            local name = tonumber(paramTable[2]) or paramTable[2]
            if listName and name then
                local list
                listName = string.gsub(listName, "_", " ")
                if StageAPI.RoomsLists[listName] then
                    list = StageAPI.RoomsLists[listName]
                else
                    Isaac.ConsoleOutput("Room List name invalid.")
                    return
                end
    
                if type(name) == "string" then
                    name = string.gsub(name, "_", " ")
                end
    
                local selectedLayout
                for _, room in ipairs(list.All) do
                    if room.Name == name or room.Variant == name then
                        selectedLayout = room
                        break
                    end
                end
    
                if selectedLayout then
                    StageAPI.RegisterLayout("StageAPITest", selectedLayout)
                    local testRoom = StageAPI.LevelRoom{
                        LayoutName = "StageAPITest",
                        Shape = selectedLayout.Shape,
                        RoomType = selectedLayout.Type
                    }
    
                    local levelMap = StageAPI.GetDefaultLevelMap()
                    local addedRoomData = levelMap:AddRoom(testRoom, {RoomID = "StageAPITest"}, true)
    
                    local doors = {}
                    for _, door in ipairs(selectedLayout.Doors) do
                        if door.Exists then
                            doors[#doors + 1] = door.Slot
                        end
                    end
    
                    StageAPI.ExtraRoomTransition(addedRoomData.MapID, nil, nil, StageAPI.DefaultLevelMapID, doors[StageAPI.Random(1, #doors)])
                else
                    Isaac.ConsoleOutput("Room with ID or name " .. tostring(name) .. " does not exist.")
                end
            else
                Isaac.ConsoleOutput("A room list name and room ID or name is required.")
            end
        end,
        Autocomplete = function (params)
            local paramTable = {}
            for word in params:gmatch("%S+") do paramTable[#paramTable + 1] = word end

            if #paramTable == 0 or (#paramTable == 1 and string.find(params, " ") == nil) then
                return map(keys(StageAPI.RoomsLists), function(s) return string.gsub(s, " ", "_") end)
            elseif #paramTable >= 1 then
                local listName = paramTable[1]
                listName = string.gsub(listName, "_", " ")
                if StageAPI.RoomsLists[listName] then
                    local out = {}
                    local list = StageAPI.RoomsLists[listName]
                    for _, room in ipairs(list.All) do
                        out[#out+1] = paramTable[1] .. " " .. string.gsub(room.Name, " ", "_")
                        out[#out+1] = paramTable[1] .. " " .. room.Variant
                    end
                    return out
                end
            end
        end,
        Desc = "Teleport to custom room in list",
        Usage = "roomListName roomName|roomId",
        Help = "Similar to croom, but with inverted param order for better autocomplete.",
    },
    creseed = {
        Execute = function (params)
            if StageAPI.CurrentStage then
                StageAPI.GotoCustomStage(StageAPI.CurrentStage)
            end    
        end,
        Desc = "Reseed custom stage",
        Help = "As reseed, but for StageAPI stages (as normal reseed might act wonky).",
    },
    roomnames = {
        Execute = function (params)
            if StageAPI.RoomNamesEnabled then
                StageAPI.RoomNamesEnabled = false
            else
                StageAPI.RoomNamesEnabled = 1
            end
        end,
        Desc = "Toggle custom room name rendering",
        Help = "Toggles name rendering for StageAPI rooms",
    },
    trimroomnames = {
        Execute = function (params)
            if StageAPI.RoomNamesEnabled then
                StageAPI.RoomNamesEnabled = false
            else
                StageAPI.RoomNamesEnabled = 2
            end
        end,
        Desc = "Shorter custom room name rendering",
        Help = "Toggles name rendering for StageAPI rooms, as roomnames but shorter.",
    },
    modversion = {
        Execute = function (params)
            for name, modData in pairs(StageAPI.LoadedMods) do
                if modData.Version then
                    Isaac.ConsoleOutput(name .. " " .. modData.Prefix .. modData.Version .. "\n")
                end
            end
        end,
        Desc = "Print StageAPI version",
    },
    roomtest = {
        Execute = function (params)
            local roomsList = shared.Level:GetRooms()
            for i = 0, roomsList.Size - 1 do
                local roomDesc = roomsList:Get(i)
                if roomDesc and roomDesc.Data.Type == RoomType.ROOM_DEFAULT then
                    shared.Game:ChangeRoom(roomDesc.SafeGridIndex)
                end
            end
        end,
        Desc = "Teleport to all rooms",
        Help = "Teleport to all rooms in order, to test for new room errors",
    },
    ascent = {
        Execute = function (params)
            local stageNum = shared.Level:GetStage()
            local stageType = shared.Level:GetStageType()
            local letter = ""
            if stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B then
                letter = "c"
            end
    
            Isaac.ExecuteCommand("stage 7") -- backwards path doesn't properly initialize special rooms if you don't leave the stage you're in first
            shared.Game:SetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH, true)
            Isaac.ExecuteCommand("stage " .. stageNum .. letter)
            shared.Sfx:Stop(SoundEffect.SOUND_MOM_AND_DAD_1)
            shared.Sfx:Stop(SoundEffect.SOUND_MOM_AND_DAD_2)
            shared.Sfx:Stop(SoundEffect.SOUND_MOM_AND_DAD_3)
            shared.Sfx:Stop(SoundEffect.SOUND_MOM_AND_DAD_4)
            print("Entered ascent.")
        end,
        Desc = "Start Repentance Ascent",
        Help = "Enter the Repentance Ascent sequence",
    },
    mirror = {
        Execute = function (params)
            local stageNum = shared.Level:GetStage()
            local stageType = shared.Level:GetStageType()
            if (stageNum == LevelStage.STAGE1_2) and (stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B) then
                if shared.Game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH) == true then
                    print("Cannot be used in ascent.")
                else
                    local roomIndex = shared.Level:GetCurrentRoomIndex()
                    if shared.Game:GetRoom():IsMirrorWorld() then
                        shared.Game:ChangeRoom(roomIndex, 0)
                        print("Exited mirror.")
                    else
                        shared.Game:ChangeRoom(roomIndex, 1)
                        print("Entered mirror.")
                    end
                end
            else
                print("Must be used in stage 2 of Downpour or Dross.")
            end
        end,
        Desc = "Toggle mirror dimension",
        Help = "Toggle mirror world in Repentance stages",
    },
    mineshaft = {
        Execute = function (params)
            local player = Isaac.GetPlayer()
            if not player:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) then
                player:AddCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
            end
            Isaac.ExecuteCommand("stage 4c")
            -- entrance is 162
            -- knife room is 61
            shared.Game:ChangeRoom(162, 1)
        end,
        Desc = "Teleport to Mines mineshaft",
    },
    boss = {
        Execute = function (params)
            local player = Isaac.GetPlayer()
            player:UseCard(5, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        end,
        Desc = "Teleport to boss room",
    },
    clearroom = {
        Execute = function (params)
            StageAPI.ClearRoomLayout(false, true, true, true)
        end,
        Desc = "Clear room layout",
        Help = "Remove all grids and entities",
    },
    superclearroom = {
        Execute = function (params)
            StageAPI.ClearRoomLayout(false, true, true, true, nil, true, true)
        end,
        Desc = "Clear room layout more",
        Help = "Remove all grids and entities, including doors and walls",
    },
    crashit = {
        Execute = function (params)
            shared.Game:ShowHallucination(0, 0)
        end,
        Desc = "Crash the game",
    },
    commandglobals = {
        Execute = function (params)
            if StageAPI.GlobalCommandMode then
                Isaac.ConsoleOutput("Disabled StageAPI global command mode")
                _G.slog = nil
                _G.game = nil
                _G.room = nil
                _G.desc = nil
                _G.apiroom = nil
                _G.level = nil
                _G.player = nil
                StageAPI.GlobalCommandMode = nil
            else
                Isaac.ConsoleOutput("Enabled StageAPI global command mode\nslog: Prints any number of args, parses some userdata\ngame, room, level: Correspond to respective objects\nplayer: Corresponds to player 0\ndesc: Current room descriptor, mutable\napiroom: Current StageAPI room, if applicable\nFor use with the lua command!")
                StageAPI.GlobalCommandMode = true
            end
        end,
        Desc = "StageAPI global command mode",
    },
    teststage = {
        Execute = function (params)
            testingStage = params
        end,
        Autocomplete = REPENTOGON and AutocompleteType.STAGE or nil,
        Usage = "stageId",
        Desc = "Test StageAPI custom level",
        Help = "Same args as stage command, go to specified stage and initialize a stageAPI custom map",
    },
    loadtestsuite = {
        Execute = function (params)
            testingRoomsList = tonumber(params)
            if not testingRoomsList then
                testingRoomsList = true
            end
        end,
        Usage = "mapName",
        Desc = "Test custom map with list",
        Help = "Init custom map with arbitrary name, using the room list specified in stageAPI commands.lua",
    }
}

local function GetAliasTable()
    local aliasTable = {}

    for baseCommand, commandData in pairs(Commands) do
        aliasTable[baseCommand] = commandData
        if commandData.Aliases then
            for _, alias in ipairs(commandData.Aliases) do
                aliasTable[alias] = commandData
            end
        end
    end

    return aliasTable
end

local AliasTable = GetAliasTable()

local function RegisterCommands()
    for baseCommand, commandData in pairs(Commands) do
        assert(commandData.Desc, "Command " .. tostring(baseCommand) .. " doesn't have a Desc!")
        assert(commandData.Execute, "Command " .. tostring(baseCommand) .. " doesn't have a Execute func!")

        local aliases = commandData.Aliases or {}
        local autocompleteType = AutocompleteType.NONE
        if type(commandData.Autocomplete) == "function" then
            autocompleteType = AutocompleteType.CUSTOM
        elseif commandData.Autocomplete then
            autocompleteType = commandData.Autocomplete
        end
        local help = commandData.Desc .. "\n" .. "Usage: " .. baseCommand

        if commandData.Usage then 
            help = help .. " " .. commandData.Usage 
        end
        if commandData.Help then 
            help = help .. "\n" .. commandData.Help 
        end
        if commandData.Aliases then
            help = help .. "\nAliases: "
            for i, alias in ipairs(commandData.Aliases) do
                if i > 1 then
                    help = help .. ", "
                end
                help = help .. alias
            end
        end

        Console.RegisterCommand(baseCommand, commandData.Desc, help, true, autocompleteType)

        for _, alias in ipairs(aliases) do
            Console.RegisterCommand(alias, commandData.Desc, help, true, autocompleteType)
        end
    end
end

local function RegisterAutocomplete()
    for alias, commandData in pairs(AliasTable) do
        if type(commandData.Autocomplete) == "function" then
            mod:AddCallback(ModCallbacks.MC_CONSOLE_AUTOCOMPLETE, function (_, cmd, params)
                return commandData.Autocomplete(params)
            end, alias)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, params)
    params = tostring(params)

    local aliasTable = GetAliasTable()
    local commandData = aliasTable[cmd]

    if commandData then
        return commandData.Execute(params)
    end
end)

if REPENTOGON then
    RegisterCommands()
    RegisterAutocomplete()
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if StageAPI.RoomNamesEnabled then
        local currentRoom = StageAPI.GetCurrentRoom()
        local roomDescriptorData = shared.Level:GetCurrentRoomDesc().Data
        local scale = 0.5
        local base, custom

        if StageAPI.RoomNamesEnabled == 2 then
            base = tostring(roomDescriptorData.StageID) .. "." .. tostring(roomDescriptorData.Variant) .. "." .. tostring(roomDescriptorData.Subtype) .. " " .. roomDescriptorData.Name
        else
            base = "Base Room Stage ID: " .. tostring(roomDescriptorData.StageID) .. ", Name: " .. roomDescriptorData.Name .. ", ID: " .. tostring(roomDescriptorData.Variant) .. ", Difficulty: " .. tostring(roomDescriptorData.Difficulty) .. ", Subtype: " .. tostring(roomDescriptorData.Subtype)
        end

        if currentRoom and currentRoom.Layout.RoomFilename and currentRoom.Layout.Name and currentRoom.Layout.Variant then
            if StageAPI.RoomNamesEnabled == 2 then
                custom = "Room File: " .. currentRoom.Layout.RoomFilename .. ", Name: " .. currentRoom.Layout.Name .. ", ID: " .. tostring(currentRoom.Layout.Variant)
            else
                custom = "Room File: " .. currentRoom.Layout.RoomFilename .. ", Name: " .. currentRoom.Layout.Name .. ", ID: " .. tostring(currentRoom.Layout.Variant) .. ", Difficulty: " .. tostring(currentRoom.Layout.Difficulty) .. ", Subtype: " .. tostring(currentRoom.Layout.SubType)
            end
        else
            custom = "Room names enabled, custom room N/A"
        end


        Isaac.RenderScaledText(custom, 60, 35, scale, scale, 255, 255, 255, 0.75)
        Isaac.RenderScaledText(base, 60, 45, scale, scale, 255, 255, 255, 0.75)
    end

    if StageAPI.GlobalCommandMode then
        _G.slog = StageAPI.Log
        _G.game = shared.Game
        _G.level = shared.Level
        _G.room = shared.Room
        _G.desc = shared.Level:GetRoomByIdx(shared.Level:GetCurrentRoomIndex())
        _G.apiroom = StageAPI.GetCurrentRoom()
        _G.player = shared.Players[1]
    end

    -- Custom floor gen commands
    if testingStage then
        local baseStage = shared.Level:GetStage()
        local baseStageType = shared.Level:GetStageType()
        Isaac.ExecuteCommand("stage " .. testingStage)
        testingStage = nil
        local levelMap = StageAPI.CopyCurrentLevelMap()
        Isaac.ExecuteCommand("stage " .. tostring(baseStage) .. StageAPI.StageTypeToString[baseStageType])
        StageAPI.InitCustomLevel(levelMap, true)
    elseif testingRoomsList then
        local levelMap
        if testingRoomsList == true then
            levelMap = StageAPI.CreateMapFromRoomsList(mapLayoutTestRoomsList)
        else
            levelMap = StageAPI.CreateMapFromRoomsList(mapLayoutTestRoomsList, testingRoomsList)
        end

        testingRoomsList = nil
        StageAPI.InitCustomLevel(levelMap, true)
    end
end)
