local mod = require("scripts.stageapi.mod")
local shared = require("scripts.stageapi.shared")

StageAPI.RoomNamesEnabled = false
StageAPI.GlobalCommandMode = false

local testingStage
local testingRoomsList
local testSuite = include("resources.stageapi.luarooms.testsuite")
local mapLayoutTestRoomsList = StageAPI.RoomsList("MapLayoutTest", testSuite)

mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, params)
    if (cmd == "cstage" or cmd == "customstage") and StageAPI.CustomStages[params] then
        if StageAPI.CustomStages[params] then
            StageAPI.GotoCustomStage(StageAPI.CustomStages[params])
        else
            Isaac.ConsoleOutput("No CustomStage " .. params)
        end
    elseif (cmd == "nstage" or cmd == "nextstage") and StageAPI.CurrentStage and StageAPI.CurrentStage.NextStage then
        StageAPI.GotoCustomStage(StageAPI.CurrentStage.NextStage)
    elseif cmd == "reload" then
        StageAPI.LoadSaveString(StageAPI.GetSaveString())
    elseif cmd == "printsave" then
        Isaac.DebugString(StageAPI.GetSaveString())
    elseif cmd == "regroom" then -- Load a registered room
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
    elseif cmd == "croom" then
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
    elseif cmd == "creseed" then
        if StageAPI.CurrentStage then
            StageAPI.GotoCustomStage(StageAPI.CurrentStage)
        end
    elseif cmd == "roomnames" then
        if StageAPI.RoomNamesEnabled then
            StageAPI.RoomNamesEnabled = false
        else
            StageAPI.RoomNamesEnabled = 1
        end
    elseif cmd == "trimroomnames" then
        if StageAPI.RoomNamesEnabled then
            StageAPI.RoomNamesEnabled = false
        else
            StageAPI.RoomNamesEnabled = 2
        end
    elseif cmd == "modversion" then
        for name, modData in pairs(StageAPI.LoadedMods) do
            if modData.Version then
                Isaac.ConsoleOutput(name .. " " .. modData.Prefix .. modData.Version .. "\n")
            end
        end
    elseif cmd == "roomtest" then
        local roomsList = shared.Level:GetRooms()
        for i = 0, roomsList.Size - 1 do
            local roomDesc = roomsList:Get(i)
            if roomDesc and roomDesc.Data.Type == RoomType.ROOM_DEFAULT then
                shared.Game:ChangeRoom(roomDesc.SafeGridIndex)
            end
        end
    elseif cmd == "ascent" then
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
    elseif cmd == "mirror" then
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
    elseif cmd == "mineshaft" then
        local player = Isaac.GetPlayer()
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) then
            player:AddCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
        end
        Isaac.ExecuteCommand("stage 4c")
        -- entrance is 162
        -- knife room is 61
        shared.Game:ChangeRoom(162, 1)
    elseif cmd == "boss" then
        local player = Isaac.GetPlayer()
        player:UseCard(5, UseFlag.USE_NOANIM)
    elseif cmd == "clearroom" then
        StageAPI.ClearRoomLayout(false, true, true, true)
    elseif cmd == "superclearroom" then
        StageAPI.ClearRoomLayout(false, true, true, true, nil, true, true)
    elseif cmd == "crashit" then
        shared.Game:ShowHallucination(0, 0)
    elseif cmd == "commandglobals" then
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
            Isaac.ConsoleOutput("Enabled StageAPI global command mode\nslog: Prints any number of args, parses some userdata\ngame, room, shared.Level: Correspond to respective objects\nplayer: Corresponds to player 0\ndesc: Current room descriptor, mutable\napiroom: Current StageAPI room, if applicable\nFor use with the lua command!")
            StageAPI.GlobalCommandMode = true
        end

    elseif cmd == "teststage" then
        testingStage = params
    elseif cmd == "loadtestsuite" then
        testingRoomsList = tonumber(params)
        if not testingRoomsList then
            testingRoomsList = true
        end
    end
end)

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
