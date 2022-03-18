local shared = require("scripts.stageapi.shared")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading BR Compatibility")

StageAPI.InTestMode = false
StageAPI.OverrideTestRoom = false -- toggle this value in console to force enable stageapi override

local status, brTestRooms = pcall(require, 'basementrenovator.roomTest')
if not status then
    StageAPI.Log("Could not load BR compatibility file; (basementrenovator/roomTest.lua) this will disable testing StageAPI rooms. No other features will be affected. Check log.txt for full error. To suppress this message, delete the compat file and replace it with a renamed copy of blankRoomTest.lua.")
    Isaac.DebugString('Error loading BR compatibility file: ' .. tostring(brTestRooms))
elseif brTestRooms then
    local testList = StageAPI.RoomsList("BRTest", brTestRooms)
    for i, testLayout in ipairs(testList.All) do
        StageAPI.RegisterLayout("BRTest-" .. i, testLayout)
    end

    BasementRenovator = BasementRenovator or { subscribers = {} }
    BasementRenovator.subscribers['StageAPI'] = {
        PostTestInit = function(testData)
            local test = testData.Rooms and testData.Rooms[1] or testData
            local testLayout = brTestRooms[1]

            if test.Type    ~= testLayout.TYPE
            or test.Variant ~= testLayout.VARIANT
            or test.Subtype ~= testLayout.SUBTYPE
            or test.Name    ~= testLayout.NAME
            or (testData.Rooms and #testData.Rooms ~= #brTestRooms) then
                StageAPI.LogErr("basementrenovator/roomTest.lua did not have values matching the BR test! Make sure your hooks are set up properly")
                StageAPI.BadTestFile = true
                return
            end

            StageAPI.InTestMode = true
            StageAPI.InTestRoom = function() return BasementRenovator.InTestRoom() end
            StageAPI.Log("Basement Renovator test mode")
        end,
        TestStage = function(test)
            if StageAPI.BadTestFile or not BasementRenovator.TestRoomData then return end
            -- TestStage fires in post_curse_eval,
            -- before StageAPI's normal stage handling code
            if test.IsModStage then
                StageAPI.NextStage = StageAPI.CustomStages[test.StageName]
                StageAPI.OverrideTestRoom = true -- must be turned on for custom stages
            end
        end,
        TestRoomEntitySpawn = function(testData, testRoom, id, variant)
            if StageAPI.BadTestFile then return end

            if StageAPI.IsMetadataEntity(id, variant) then
                StageAPI.OverrideTestRoom = true
            end

            if not StageAPI.OverrideTestRoom then return end

            -- makes sure placeholder/meta entities can't spawn
            if (id >= 1000 and id ~= 10000) or StageAPI.RoomEntitySpawnGridBlacklist[id] or StageAPI.IsMetadataEntity(id, variant) then
                return { 999, StageAPI.E.DeleteMeEffect.V, 0 }
            end
        end
    }

    local function GetBRRoom(foo)
        if StageAPI.BadTestFile or not BasementRenovator.TestRoomData then return end

        if not StageAPI.OverrideTestRoom then return end

        if BasementRenovator.InTestStage() and shared.Room:IsFirstVisit() then
            local brRoom = BasementRenovator.InTestRoom()
            if brRoom then
                return brRoom
            end
        end
    end

    StageAPI.AddCallback("StageAPI", Callbacks.PRE_STAGEAPI_NEW_ROOM_GENERATION, 0, function()
        local brRoom = GetBRRoom()
        if brRoom then
            local testRoom = StageAPI.LevelRoom("BRTest-" .. (brRoom.Index or 1), nil, shared.Room:GetSpawnSeed(), brRoom.Shape, brRoom.Type, nil, nil, nil, nil, nil, StageAPI.GetCurrentRoomID())
            return testRoom
        end
    end)

    StageAPI.AddCallback("StageAPI", Callbacks.POST_STAGEAPI_NEW_ROOM, 0, function()
        if GetBRRoom() then
            if BasementRenovator.RenderDoorSlots then
                BasementRenovator.RenderDoorSlots()
            end
        end
    end)
end