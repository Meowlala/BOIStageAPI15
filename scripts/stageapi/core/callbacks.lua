local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading Core Callbacks")

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    local currentRoom = StageAPI.GetCurrentRoom()
    if currentRoom and currentRoom.Loaded then
        local isClear = currentRoom.IsClear
        currentRoom.IsClear = shared.Room:IsClear()
        currentRoom.JustCleared = nil
        if not isClear and currentRoom.IsClear then
            currentRoom.ClearCount = currentRoom.ClearCount + 1
            StageAPI.CallCallbacks(Callbacks.POST_ROOM_CLEAR, false)
            currentRoom.JustCleared = true
        end
    end
end)

StageAPI.RoomGrids = {}

function StageAPI.PreventRoomGridRegrowth()
    local roomGrids = StageAPI.GetTableIndexedByDimension(StageAPI.RoomGrids, true)
    roomGrids[StageAPI.GetCurrentRoomID()] = {}
end

function StageAPI.StoreRoomGrids()
    local roomIndex = StageAPI.GetCurrentRoomID()
    local grids = {}
    for i = 0, shared.Room:GetGridSize() do
        local grid = shared.Room:GetGridEntity(i)
        if grid and grid.Desc.Type ~= GridEntityType.GRID_WALL and grid.Desc.Type ~= GridEntityType.GRID_DOOR then
            grids[i] = true
        end
    end

    local roomGrids = StageAPI.GetTableIndexedByDimension(StageAPI.RoomGrids, true)
    roomGrids[roomIndex] = grids
end

function StageAPI.RemoveExtraGrids(grids)
    for i = 0, shared.Room:GetGridSize() do
        if not grids[i] then
            local grid = shared.Room:GetGridEntity(i)
            if grid and grid.Desc.Type ~= GridEntityType.GRID_WALL and grid.Desc.Type ~= GridEntityType.GRID_DOOR then
                shared.Room:RemoveGridEntity(i, 0, false)
            end
        end
    end

    StageAPI.CalledRoomUpdate = true
    shared.Room:Update()
    StageAPI.CalledRoomUpdate = false
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
    if StageAPI.CalledRoomUpdate then
        return true
    end
end)

StageAPI.PreviousGridCount = nil

function StageAPI.ReprocessRoomGrids()
    StageAPI.PreviousGridCount = nil
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, StageAPI.ReprocessRoomGrids, CollectibleType.COLLECTIBLE_D12)

function StageAPI.UseD7()
    local currentRoom = StageAPI.GetCurrentRoom()
    if currentRoom then
        if shared.Room:GetType() == RoomType.ROOM_BOSS then
            shared.Game:MoveToRandomRoom(false, shared.Room:GetSpawnSeed())
        else
            StageAPI.JustUsedD7 = true
        end

        for _, player in ipairs(shared.Players) do
            if player:HasCollectible(CollectibleType.COLLECTIBLE_D7) and Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
                player:AnimateCollectible(CollectibleType.COLLECTIBLE_D7, "UseItem", "PlayerPickup")
            end
        end

        return true
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, StageAPI.UseD7, CollectibleType.COLLECTIBLE_D7)

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
    if StageAPI.InNewStage() then
        for _, player in ipairs(shared.Players) do
            if player:HasCollectible(CollectibleType.COLLECTIBLE_FORGET_ME_NOW) and Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
                player:RemoveCollectible(CollectibleType.COLLECTIBLE_FORGET_ME_NOW)
            end
        end

        StageAPI.GotoCustomStage(StageAPI.CurrentStage, true)
        return true
    end
end, CollectibleType.COLLECTIBLE_FORGET_ME_NOW)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
    if StageAPI.InNewStage() and not eff:GetData().StageAPIDoNotDelete then
        eff:Remove()
    end
end, EffectVariant.WATER_DROPLET)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if StageAPI.JustUsedD7 then
        StageAPI.JustUsedD7 = nil
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom then
            currentRoom.IsClear = currentRoom.WasClearAtStart
            currentRoom:Load()
        end
    end
end)

function StageAPI.ShouldOverrideRoom(inStartingRoom, currentRoom)
    if inStartingRoom == nil then
        inStartingRoom = StageAPI.InStartingRoom()
    end

    if currentRoom == nil then
        currentRoom = StageAPI.GetCurrentRoom()
    end

    if currentRoom then
        return true
    elseif StageAPI.InNewStage() then
        local shouldGenerateDefaultRoom = (StageAPI.CurrentStage.Rooms and StageAPI.CurrentStage.Rooms[shared.Room:GetType()])
        local shouldGenerateBossRoom = (StageAPI.CurrentStage.Bosses and shared.Room:GetType() == RoomType.ROOM_BOSS)
        local shouldGenerateStartingRoom = StageAPI.CurrentStage.StartingRooms

        if (not inStartingRoom and (shouldGenerateDefaultRoom or shouldGenerateBossRoom)) or (inStartingRoom and shouldGenerateStartingRoom) then
            return true
        end
    end
end

StageAPI.RecentlyChangedLevel = nil

mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, function()
    if not StageAPI.RecentlyStartedGame then
        StageAPI.RecentlyChangedLevel = true
    end
end)

StageAPI.AddCallback("StageAPI", Callbacks.POST_SELECT_BOSS_MUSIC, 0, function(stage, usingMusic, isCleared)
    if not isCleared then
        if stage.Name == "Necropolis" or stage.Alias == "Necropolis" then
            if shared.Room:IsCurrentRoomLastBoss() and (shared.Level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 or shared.Level:GetStage() == LevelStage.STAGE3_2) then
                return Music.MUSIC_MOM_BOSS
            end
        elseif stage.Name == "Utero" or stage.Alias == "Utero" then
            if shared.Room:IsCurrentRoomLastBoss() and (shared.Level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 or shared.Level:GetStage() == LevelStage.STAGE4_2) then
                return Music.MUSIC_MOMS_HEART_BOSS
            end
        end
    end
end)

StageAPI.NonOverrideTrapdoors = {
    ["gfx/grid/trapdoor_downpour.anm2"] = true,
    ["gfx/grid/trapdoor_mines.anm2"] = true,
    ["gfx/grid/trapdoor_mausoleum.anm2"] = true,
}

function StageAPI.CheckStageTrapdoor(grid, index)
    if not (grid.Desc.Type == GridEntityType.GRID_TRAPDOOR and grid.State == 1) or StageAPI.NonOverrideTrapdoors[grid:GetSprite():GetFilename()] then
        return
    end

    local entering = false
    for _, player in ipairs(shared.Players) do
        local dist = player.Position:DistanceSquared(grid.Position)
        local size = player.Size + 32
        if dist < size * size then
            entering = true
            break
        end
    end

    if not entering then return end

    local currStage = StageAPI.CurrentStage or {}
    local nextStage = StageAPI.CallCallbacks(Callbacks.PRE_SELECT_NEXT_STAGE, true, StageAPI.CurrentStage) or currStage.NextStage
    if nextStage and not currStage.OverridingTrapdoors then
        StageAPI.SpawnCustomTrapdoor(shared.Room:GetGridPosition(index), nextStage, grid:GetSprite():GetFilename(), 32, true)
        shared.Room:RemoveGridEntity(index, 0, false)
    end
end

StageAPI.LastBackdropType = nil
StageAPI.MusicRNG = RNG()

local FramesTabPressed = 0
local StageNameTabStreak = nil
local TAB_FRAMES_FOR_STREAK = 22

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if shared.Game:GetFrameCount() <= 0 then
        return
    end

    local currentListIndex = StageAPI.GetCurrentRoomID()
    local stage = shared.Level:GetStage()
    local stype = shared.Level:GetStageType()
    local updatedGrids
    local gridCount = 0
    local pits = {}
    for i = 0, shared.Room:GetGridSize() do
        local grid = shared.Room:GetGridEntity(i)
        if grid then
            if grid.Desc.Type == GridEntityType.GRID_PIT then
                pits[#pits + 1] = {grid, i}
            end

            StageAPI.CheckStageTrapdoor(grid, i)

            gridCount = gridCount + 1
        end
    end

    if gridCount ~= StageAPI.PreviousGridCount then
        StageAPI.CallCallbacks(Callbacks.POST_GRID_UPDATE)

        updatedGrids = true
        local roomGrids = StageAPI.GetTableIndexedByDimension(StageAPI.RoomGrids, true)
        if roomGrids[currentListIndex] then
            StageAPI.StoreRoomGrids()
        end

        StageAPI.PreviousGridCount = gridCount
    end

    if shared.Sfx:IsPlaying(SoundEffect.SOUND_CASTLEPORTCULLIS) and not (StageAPI.CurrentStage and StageAPI.CurrentStage.BossMusic and StageAPI.CurrentStage.BossMusic.Intro) then
        shared.Sfx:Stop(SoundEffect.SOUND_CASTLEPORTCULLIS)
        shared.Sfx:Play(StageAPI.S.BossIntro, 1, 0, false, 1)
    end

    if StageAPI.InOverriddenStage() and StageAPI.CurrentStage then
        local roomType = shared.Room:GetType()
        local rtype = StageAPI.GetCurrentRoomType()
        local grids

        local gridsOverride = StageAPI.CallCallbacks(Callbacks.PRE_UPDATE_GRID_GFX, false)

        local currentRoom = StageAPI.GetCurrentRoom()
        if gridsOverride then
            grids = gridsOverride
        elseif currentRoom and currentRoom.Data.RoomGfx then
            grids = currentRoom.Data.RoomGfx.Grids
        elseif StageAPI.CurrentStage.RoomGfx and StageAPI.CurrentStage.RoomGfx[rtype] and StageAPI.CurrentStage.RoomGfx[rtype].Grids then
            grids = StageAPI.CurrentStage.RoomGfx[rtype].Grids
        end

        if grids then
            if grids.Bridges then
                for _, grid in ipairs(pits) do
                    StageAPI.CheckBridge(grid[1], grid[2], grids.Bridges)
                end
            end

            if not StageAPI.RoomRendered and updatedGrids then
                StageAPI.ChangeGrids(grids)
            end
        end

        local id = shared.Music:GetCurrentMusicID()
        local musicID, shouldLayer, shouldQueue, disregardNonOverride = StageAPI.CurrentStage:GetPlayingMusic()
        if musicID then
            if not shouldQueue then
                shouldQueue = musicID
            end

            local queuedID = shared.Music:GetQueuedMusicID()
            local canOverride, canOverrideQueue, neverOverrideQueue = StageAPI.CanOverrideMusic(queuedID)
            local shouldOverrideQueue = shouldQueue and (canOverride or canOverrideQueue or disregardNonOverride)
            if not neverOverrideQueue and shouldQueue then
                shouldOverrideQueue = shouldOverrideQueue or (id == queuedID)
            end

            if queuedID ~= shouldQueue and shouldOverrideQueue then
                shared.Music:Queue(shouldQueue)
            end

            local canOverride = StageAPI.CanOverrideMusic(id)
            if id ~= musicID and (canOverride or disregardNonOverride) then
                shared.Music:Play(musicID, 0)
            end

            shared.Music:UpdateVolume()

            if shouldLayer and not shared.Music:IsLayerEnabled() then
                shared.Music:EnableLayer()
            elseif not shouldLayer and shared.Music:IsLayerEnabled() then
                shared.Music:DisableLayer()
            end
        end

        StageAPI.RoomRendered = true

        local anyPlayerPressingTab = false

        for _, player in ipairs(shared.Players) do
            anyPlayerPressingTab = anyPlayerPressingTab or Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex)
            if anyPlayerPressingTab then
                break
            end
        end

        if anyPlayerPressingTab then
            FramesTabPressed = FramesTabPressed + 1
            -- Isaac.RenderText("Pressed for frames: " .. FramesTabPressed, 50, 50, 1, 1, 1, 1)
            if FramesTabPressed == TAB_FRAMES_FOR_STREAK then
                local renderPos = Vector(
                    StageAPI.GetScreenCenterPosition().X,
                    StageAPI.GetScreenBottomRight().Y - 48
                )
                StageNameTabStreak = StageAPI.PlayTextStreak{
                    Text = StageAPI.CurrentStage:GetDisplayName(),
                    AboveHud = true,
                    Hold = true,
                    HoldFrames = 0,
                    RenderPos = renderPos,
                }
            end
        else
            FramesTabPressed = 0
            if StageNameTabStreak then
                StageNameTabStreak.Hold = false
                StageNameTabStreak = nil
            end
        end
    end

    local backdropType = shared.Room:GetBackdropType()
    if StageAPI.LastBackdropType ~= backdropType then
        local currentRoom = StageAPI.GetCurrentRoom()
        local usingGfx
        -- Manual handling instead of CallCallbacksAccumulator needed as usingGfx
        -- is the second arg, won't change for backwards compat
        local callbacks = StageAPI.GetCallbacks(Callbacks.PRE_CHANGE_ROOM_GFX)
        for _, callback in ipairs(callbacks) do
            local success, ret = StageAPI.TryCallback(callback, currentRoom, usingGfx, true)
            if success and ret ~= nil then
                usingGfx = ret
            end
        end

        if usingGfx then
            StageAPI.ChangeRoomGfx(usingGfx)
            if currentRoom then
                currentRoom.Data.RoomGfx = usingGfx
            end
        end

        StageAPI.CallCallbacks(Callbacks.POST_CHANGE_ROOM_GFX, false, currentRoom, usingGfx, true)

        StageAPI.LastBackdropType = backdropType
    end
end)

function StageAPI.SetCurrentBossRoomInPlace(bossID, room)
    local boss = StageAPI.GetBossData(bossID)
    if not boss then
        StageAPI.LogErr("Trying to set boss with invalid ID: " .. tostring(bossID))
        return
    end

    room.PersistentData.BossID = bossID
    StageAPI.CallCallbacks(Callbacks.POST_BOSS_ROOM_INIT, false, room, boss, bossID)
end

function StageAPI.GenerateBossRoom(bossID, checkEncountered, bosses, hasHorseman, requireRoomTypeBoss, noPlayBossAnim, unskippableBossAnim, isExtraRoom, shape, ignoreDoors, doors, roomType)
    local args = bossID
    local roomArgs = checkEncountered
    if type(args) ~= "table" then
        args = {
            BossID = bossID,
            CheckEncountered = checkEncountered,
            Bosses = bosses,
            NoPlayBossAnim = noPlayBossAnim,
            UnskippableBossAnim = unskippableBossAnim,
        }
    end

    if type(roomArgs) ~= "table" then
        roomArgs = {
            IsExtraRoom = isExtraRoom,
            Shape = shape,
            IgnoreDoors = ignoreDoors,
            Doors = doors,
            RoomType = roomType,
            RequireRoomType = requireRoomTypeBoss
        }
    end

    local bossID = args.BossID
    if not bossID then
        bossID = StageAPI.SelectBoss(args.Bosses)
    elseif checkEncountered then
        if StageAPI.GetBossEncountered(bossID) then
            StageAPI.LogErr("Trying to generate boss room for encountered boss: " .. tostring(bossID))
            return
        end
    end

    local boss = StageAPI.GetBossData(bossID)
    if not boss then
        StageAPI.LogErr("Trying to set boss with invalid ID: " .. tostring(bossID))
        return
    end

    StageAPI.SetBossEncountered(boss.Name)
    if boss.NameTwo then
        StageAPI.SetBossEncountered(boss.NameTwo)
    end

    local newRoom = StageAPI.LevelRoom(StageAPI.Merged({RoomsList = boss.Rooms}, roomArgs))
    newRoom.PersistentData.BossID = bossID
    StageAPI.CallCallbacks(Callbacks.POST_BOSS_ROOM_INIT, false, newRoom, boss, bossID)

    return newRoom, boss
end

function StageAPI.GenerateBaseRoom(roomDesc)
    local baseFloorInfo = StageAPI.GetBaseFloorInfo()
    local xlFloorInfo
    if shared.Level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 then
        xlFloorInfo = StageAPI.GetBaseFloorInfo(shared.Level:GetStage() + 1, shared.Level:GetStageType())
    end

    local lastBossRoomListIndex = shared.Level:GetLastBossRoomListIndex()
    local backwards = shared.Game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH_INIT) or shared.Game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH)
    local dimension = StageAPI.GetDimension(roomDesc)
    local newRoom
    if baseFloorInfo and baseFloorInfo.HasCustomBosses and roomDesc.Data.Type == RoomType.ROOM_BOSS and dimension == 0 and not backwards then
        local bossFloorInfo = baseFloorInfo
        if xlFloorInfo and roomDesc.ListIndex == lastBossRoomListIndex then
            bossFloorInfo = xlFloorInfo
        end

        local bossID = StageAPI.SelectBoss(bossFloorInfo.Bosses, nil, roomDesc, true)
        if bossID then
            local bossData = StageAPI.GetBossData(bossID)
            if bossData and not bossData.BaseGameBoss and bossData.Rooms then
                newRoom = StageAPI.GenerateBossRoom({
                    BossID = bossID,
                    NoPlayBossAnim = true
                }, {
                    RoomDescriptor = roomDesc
                })

                if roomDesc.Data.Subtype == 82 or roomDesc.Data.Subtype == 83 then -- Remove Great Gideon special health bar & Hornfel room properties
                    local overwritableRoomDesc = shared.Level:GetRoomByIdx(roomDesc.SafeGridIndex, dimension)
                    local replaceData = StageAPI.GetGotoDataForTypeShape(RoomType.ROOM_BOSS, roomDesc.Data.Shape)
                    overwritableRoomDesc.Data = replaceData
                end

                StageAPI.LogMinor("Switched Base Floor Boss Room, new boss is " .. bossID)
            end
        end
    end

    if not newRoom then
        local hasMetadataEntity
        StageAPI.ForAllSpawnEntries(roomDesc.Data, function(entry, spawn)
            if StageAPI.IsMetadataEntity(entry.Type, entry.Variant) then
                hasMetadataEntity = true
                return true
            end
        end)

        if hasMetadataEntity then
            newRoom = StageAPI.LevelRoom{
                FromData = roomDesc.ListIndex,
                RoomDescriptor = roomDesc
            }

            StageAPI.LogMinor("Switched Base Floor Room With Metadata")
        end
    end

    if newRoom then
        local listIndex = roomDesc.ListIndex
        StageAPI.SetLevelRoom(newRoom, listIndex, dimension)
        if roomDesc.Data.Type == RoomType.ROOM_BOSS and baseFloorInfo.HasMirrorLevel and dimension == 0 then
            StageAPI.Log("Mirroring!")
            local mirroredRoom = newRoom:Copy(roomDesc)
            local mirroredDesc = shared.Level:GetRoomByIdx(roomDesc.SafeGridIndex, 1)
            StageAPI.SetLevelRoom(mirroredRoom, mirroredDesc.ListIndex, 1)
        end
    end
end

function StageAPI.GenerateBaseLevel()
    local roomsList = shared.Level:GetRooms()
    for i = 0, roomsList.Size - 1 do
        local roomDesc = roomsList:Get(i)
        if roomDesc then
            StageAPI.GenerateBaseRoom(roomDesc)
        end
    end
end

local uniqueBossDropRoomSubtypes = {
    19, -- Gish
    20, -- Steven
    21, -- Chad
    23, -- The Fallen
    42 -- Triachnid
}

-- Re-randomize fixed boss drops in StageAPI boss rooms
StageAPI.AddCallback("StageAPI", Callbacks.POST_ROOM_CLEAR, 0, function()
    if shared.Room:GetType() == RoomType.ROOM_BOSS then
        local currentRoom = StageAPI.GetCurrentRoom()
        local collectibles = Isaac.FindByType(5, 100, -1)
        local spawnedFromBoss = {}
        for _, collectible in ipairs(collectibles) do
            if not collectible.SpawnerEntity and not collectible.Parent and collectible.FrameCount <= 1 then
                spawnedFromBoss[#spawnedFromBoss + 1] = collectible
            end
        end

        if #spawnedFromBoss > 0 then
            for _, collectible in ipairs(spawnedFromBoss) do
                local pickup = collectible:ToPickup()
                local alreadyChanged = StageAPI.CallCallbacks(Callbacks.PRE_STAGEAPI_SELECT_BOSS_ITEM, true, pickup, currentRoom)
                if not alreadyChanged then
                    local roomData = shared.Level:GetCurrentRoomDesc().Data
                    if StageAPI.IsIn(uniqueBossDropRoomSubtypes, roomData.Subtype) then
                        pickup:Morph(collectible.Type, collectible.Variant, 0, false, true, false)
                    end
                end
            end
        end
    end
end)

StageAPI.PreviousBaseLevelLayout = {}

function StageAPI.DetectBaseLayoutChanges(generateNewRooms)
    local roomsList = shared.Level:GetRooms()
    local changedRooms = {}
    for i = 0, roomsList.Size - 1 do
        local roomDesc = roomsList:Get(i)
        local previous = StageAPI.PreviousBaseLevelLayout[i]
        local changed = false
        if previous then
            if previous.Name ~= roomDesc.Data.Name or previous.Variant ~= roomDesc.Data.Variant or previous.SpawnSeed ~= roomDesc.SpawnSeed then
                changedRooms[#changedRooms + 1] = {
                    Previous = previous,
                    ListIndex = i,
                    Dimension = StageAPI.GetDimension(roomDesc)
                }
                changed = true
            end
        end

        if changed or not previous then
            if not previous and generateNewRooms then
                if StageAPI.CurrentStage then
                    if StageAPI.CurrentStage.PregenerationEnabled then
                        StageAPI.CurrentStage:GenerateRoom(roomDesc, roomDesc.SafeGridIndex == shared.Level:GetStartingRoomIndex(), true)
                    end
                else
                    StageAPI.GenerateBaseRoom(roomDesc)
                end
            end

            StageAPI.PreviousBaseLevelLayout[i] = {Name = roomDesc.Data.Name, Variant = roomDesc.Data.Variant, SpawnSeed = roomDesc.SpawnSeed}
        end
    end

    for _, changed in ipairs(changedRooms) do
        local previous = changed.Previous
        local new = StageAPI.PreviousBaseLevelLayout[changed.ListIndex]
        local dimension = changed.Dimension
        local swappedWith
        for _, changed2 in ipairs(changedRooms) do
            local previous2 = changed2.Previous
            local new2 = StageAPI.PreviousBaseLevelLayout[changed2.ListIndex]
            if changed.ListIndex ~= changed2.ListIndex and previous.AwardSeed == new2.AwardSeed and new.AwardSeed == previous2.AwardSeed then
                swappedWith = changed2
                break
            end
        end

        if swappedWith then
            local levelRoomOne = StageAPI.GetLevelRoom(swappedWith.ListIndex, dimension)
            local levelRoomTwo = StageAPI.GetLevelRoom(changed.ListIndex, dimension)
            StageAPI.SetLevelRoom(levelRoomOne, changed.ListIndex, dimension)
            StageAPI.SetLevelRoom(levelRoomTwo, swappedWith.ListIndex, dimension)
        else
            StageAPI.SetLevelRoom(nil, changed.ListIndex, dimension)
            if generateNewRooms then
                local roomDesc = shared.Level:GetRooms():Get(changed.ListIndex)
                if StageAPI.CurrentStage then
                    if StageAPI.CurrentStage.PregenerationEnabled then
                        StageAPI.CurrentStage:GenerateRoom(roomDesc, roomDesc.SafeGridIndex == shared.Level:GetStartingRoomIndex(), true)
                    end
                else
                    StageAPI.GenerateBaseRoom(roomDesc)
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    StageAPI.DetectBaseLayoutChanges(true)
end, CollectibleType.COLLECTIBLE_RED_KEY)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    StageAPI.DetectBaseLayoutChanges(true)
end, CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    StageAPI.CallCallbacks(Callbacks.PRE_STAGEAPI_NEW_ROOM, false)

    StageAPI.RecentlyChangedLevel = false
    StageAPI.RecentlyStartedGame = false

    if StageAPI.TransitioningToExtraRoom and StageAPI.IsRoomTopLeftShifted() and not StageAPI.DoubleTransitioning then
        StageAPI.DoubleTransitioning = true
        local defaultGridRoom, alternateGridRoom, defaultLargeGridRoom, alternateLargeGridRoom = StageAPI.GetExtraRoomBaseGridRooms(shared.Room:GetType() == RoomType.ROOM_BOSS)
        local targetRoom
        if shared.Level:GetCurrentRoomIndex() == defaultGridRoom then
            targetRoom = alternateGridRoom
        else
            targetRoom = defaultGridRoom
        end

        local targetRoomDesc = shared.Level:GetRoomByIdx(targetRoom)
        local targetGotoData, targetGotoLockedData = StageAPI.GetGotoDataForTypeShape(shared.Room:GetType(), shared.Room:GetRoomShape())
        if targetGotoLockedData and StageAPI.DoorOneSlots[shared.Level.EnterDoor] then
            targetRoomDesc.Data = targetGotoLockedData
        else
            targetRoomDesc.Data = targetGotoData
        end

        shared.Level:ChangeRoom(targetRoom)

        return
    end

    StageAPI.DoubleTransitioning = false

    local isNewStage, override = StageAPI.InOverriddenStage()
    local inStartingRoom = StageAPI.InStartingRoom()

    for _, customGrid in ipairs(StageAPI.GetCustomGrids()) do
        if customGrid.RoomIndex and customGrid.RoomIndex ~= StageAPI.GetCurrentRoomID() then
            customGrid:Unload()
        end
    end

    -- Only a room the player is actively in can be "Loaded"
    for _, levelRoom in ipairs(StageAPI.GetAllLevelRooms()) do
        levelRoom.Loaded = false
    end

    local setDefaultLevelMap
    if not StageAPI.TransitioningToExtraRoom then
        setDefaultLevelMap = true
        StageAPI.CurrentLevelMapID = StageAPI.DefaultLevelMapID
        StageAPI.CurrentLevelMapRoomID = nil
    end

    if (inStartingRoom and StageAPI.GetDimension() == 0 and shared.Room:IsFirstVisit()) or (isNewStage and not StageAPI.CurrentStage) then
        if inStartingRoom then
            StageAPI.RoomGrids = {}
            local maintainGrids = {}
            for dimension, rooms in pairs(StageAPI.LevelRooms) do
                maintainGrids[dimension] = {}
                for roomId, levelRoom in pairs(rooms) do
                    if not (levelRoom and levelRoom.IsPersistentRoom) then
                        StageAPI.SetLevelRoom(nil, roomId, dimension)
                    else
                        maintainGrids[dimension][roomId] = true
                    end
                end
            end

            for dimension, roomCustomGrids in pairs(StageAPI.CustomGrids) do
                for roomId, grids in pairs(roomCustomGrids) do
                    if not maintainGrids[dimension] or not maintainGrids[dimension][roomId] then
                        roomCustomGrids[roomId] = nil
                    end
                end
            end

            for mapID, levelMap in pairs(StageAPI.LevelMaps) do
                if not levelMap.Persistent then
                    local rooms = levelMap:GetRooms()
                    if #rooms == 0 then
                        levelMap:Destroy()
                    else
                        for _, roomData in ipairs(levelMap.Map) do
                            levelMap:AddRoomToMinimap(roomData)
                        end
                    end
                end
            end
        end

        if not StageAPI.DefaultLevelMapID then
            local defaultLevelMap = StageAPI.LevelMap{OverlapDimension = 0}
            StageAPI.DefaultLevelMapID = defaultLevelMap.Dimension
            if setDefaultLevelMap then
                StageAPI.CurrentLevelMapID = StageAPI.DefaultLevelMapID
            end
        end

        if not StageAPI.CurrentLevelMapID then
            StageAPI.CurrentLevelMapID = StageAPI.DefaultLevelMapID
        end

        StageAPI.PreviousBaseLevelLayout = {}
        StageAPI.CurrentStage = nil
        if isNewStage then
            if not StageAPI.NextStage then
                StageAPI.CurrentStage = override.ReplaceWith
            else
                StageAPI.CurrentStage = StageAPI.NextStage
            end

            if shared.Level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 and StageAPI.CurrentStage.XLStage then
                StageAPI.CurrentStage = StageAPI.CurrentStage.XLStage
            end

            -- shared.Game:GetHUD():ShowItemText(StageAPI.CurrentStage:GetDisplayName(), shared.Level:GetCurseName(), shared.Level:GetCurses() > 0)

            StageAPI.CurrentStage:GenerateLevel()
        else
            StageAPI.GenerateBaseLevel()
        end

        StageAPI.NextStage = nil
        if StageAPI.CurrentStage and StageAPI.CurrentStage.GetPlayingMusic then
            local musicID = StageAPI.CurrentStage:GetPlayingMusic()
            if musicID then
                shared.Music:Queue(musicID)
            end
        end
    end

    StageAPI.DetectBaseLayoutChanges(false)

    local currentListIndex = StageAPI.GetCurrentRoomID()
    local currentRoom, justGenerated, boss = StageAPI.GetCurrentRoom(), nil, nil

    local retCurrentRoom, retJustGenerated, retBoss = StageAPI.CallCallbacks(Callbacks.PRE_STAGEAPI_NEW_ROOM_GENERATION, true, currentRoom, justGenerated, currentListIndex)
    local prevRoom = currentRoom
    currentRoom, justGenerated, boss = retCurrentRoom or currentRoom, retJustGenerated or justGenerated, retBoss or boss
    if prevRoom ~= currentRoom then
        StageAPI.SetCurrentRoom(currentRoom)
    end

    if StageAPI.InExtraRoom() then
        for i = 0, 7 do
            if shared.Room:GetDoor(i) then
                shared.Room:RemoveDoor(i)
            end
        end

        justGenerated = currentRoom.FirstLoad
        currentRoom:Load(true)
    elseif StageAPI.InNewStage() then
        if not currentRoom and StageAPI.CurrentStage.GenerateRoom then
            local newRoom, newBoss = StageAPI.CurrentStage:GenerateRoom(shared.Level:GetCurrentRoomDesc(), inStartingRoom, false)
            if newRoom then
                StageAPI.SetCurrentRoom(newRoom)
                newRoom:Load()
                currentRoom = newRoom
                justGenerated = true
            end

            if newBoss then
                boss = newBoss
            end
        end
    end

    retCurrentRoom, retJustGenerated, retBoss = StageAPI.CallCallbacks("POST_STAGEAPI_NEW_ROOM_GENERATION", true, currentRoom, justGenerated, currentListIndex, boss)
    prevRoom = currentRoom
    currentRoom, justGenerated, boss = retCurrentRoom or currentRoom, retJustGenerated or justGenerated, retBoss or boss
    if prevRoom ~= currentRoom then
        StageAPI.SetCurrentRoom(currentRoom)
    end

    if not boss and currentRoom and currentRoom.PersistentData.BossID then
        boss = StageAPI.GetBossData(currentRoom.PersistentData.BossID)
    end

    if currentRoom and not StageAPI.InExtraRoom() and not justGenerated then
        currentRoom:Load()
    end

    if boss and not shared.Room:IsClear() then
        if not boss.IsMiniboss then
            StageAPI.PlayBossAnimation(boss)
        else
            local text = shared.Players[1]:GetName() .. " VS " .. boss.Name

            local ret = StageAPI.CallCallbacks(Callbacks.PRE_PLAY_MINIBOSS_STREAK, true, currentRoom, boss, text)

            if ret ~= false then
                if ret then
                    text = ret
                end
                StageAPI.PlayTextStreak(text)
            end
        end
    end

    if not justGenerated then
        local customGridData = StageAPI.GetRoomCustomGrids()
        local customGrids = StageAPI.GetCustomGrids()
        local persistentIndicesAlreadySpawned = {}
        for _, grid in ipairs(customGrids) do
            persistentIndicesAlreadySpawned[grid.PersistentIndex] = true
        end

        for persistentIndex, customGrid in pairs(customGridData.Grids) do
            if not persistentIndicesAlreadySpawned[persistentIndex] then
                StageAPI.CustomGridEntity(persistentIndex, customGrid.Index, nil, true)
            end
        end
    end

    if StageAPI.ForcePlayerDoorSlot or StageAPI.ForcePlayerNewRoomPosition then
        local pos = StageAPI.ForcePlayerNewRoomPosition or shared.Room:GetClampedPosition(shared.Room:GetDoorSlotPosition(StageAPI.ForcePlayerDoorSlot), 16)
        for _, player in ipairs(shared.Players) do
            player.Position = pos
        end

        if StageAPI.ForcePlayerDoorSlot then
            shared.Level.EnterDoor = StageAPI.ForcePlayerDoorSlot
        end

        StageAPI.ForcePlayerDoorSlot = nil
        StageAPI.ForcePlayerNewRoomPosition = nil
    elseif currentRoom then
        local invalidEntrance
        local validDoors = {}
        for _, door in ipairs(currentRoom.Layout.Doors) do
            if door.Slot then
                if not door.Exists and shared.Level.EnterDoor == door.Slot then
                    invalidEntrance = true
                elseif door.Exists then
                    validDoors[#validDoors + 1] = door.Slot
                end
            end
        end

        if invalidEntrance and #validDoors > 0 and not currentRoom.Data.PreventDoorFix then
            local changeEntrance = validDoors[StageAPI.Random(1, #validDoors)]
            shared.Level.EnterDoor = changeEntrance
            for _, player in ipairs(shared.Players) do
                player.Position = shared.Room:GetClampedPosition(shared.Room:GetDoorSlotPosition(changeEntrance), 16)
            end
        end
    end

    StageAPI.TransitioningToExtraRoom = false

    local stageType = shared.Level:GetStageType()
    if not StageAPI.InNewStage() and stageType ~= StageType.STAGETYPE_REPENTANCE and stageType ~= StageType.STAGETYPE_REPENTANCE_B then
        local stage = shared.Level:GetStage()
        if stage == LevelStage.STAGE2_1 or stage == LevelStage.STAGE2_2 then
            StageAPI.ChangeStageShadow("stageapi/floors/catacombs/overlays/", 5)
        elseif stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2 then
            StageAPI.ChangeStageShadow("stageapi/floors/necropolis/overlays/", 5)
        elseif stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2 then
            StageAPI.ChangeStageShadow("stageapi/floors/utero/overlays/", 5)
        end
    end

    local usingGfx
    if currentRoom and currentRoom.Data.RoomGfx then
        usingGfx = currentRoom.Data.RoomGfx
    elseif isNewStage and StageAPI.CurrentStage.RoomGfx then
        local rtype = StageAPI.GetCurrentRoomType()
        usingGfx = StageAPI.CurrentStage.RoomGfx[rtype]
    end

    -- Manual handling instead of CallCallbacksAccumulator needed as usingGfx
    -- is the second arg, won't change for backwards compat
    local callbacks = StageAPI.GetCallbacks(Callbacks.PRE_CHANGE_ROOM_GFX)
    for _, callback in ipairs(callbacks) do
        local success, ret = StageAPI.TryCallback(callback, currentRoom, usingGfx, false)
        if success and ret ~= nil then
            usingGfx = ret
        end
    end

    if usingGfx then
        StageAPI.ChangeRoomGfx(usingGfx)
        if currentRoom then
            currentRoom.Data.RoomGfx = usingGfx
        end
    end

    StageAPI.CallCallbacks(Callbacks.POST_CHANGE_ROOM_GFX, false, currentRoom, usingGfx, false)

    StageAPI.LastBackdropType = shared.Room:GetBackdropType()
    StageAPI.RoomRendered = false

    StageAPI.CallCallbacks(Callbacks.POST_STAGEAPI_NEW_ROOM, false, justGenerated)
end)

function StageAPI.GetGridPosition(index, width)
    local x, y = StageAPI.GridToVector(index, width)
    y = y + 4
    x = x + 2
    return x * 40, y * 40
end


StageAPI.RoomEntitySpawnGridBlacklist = {
    [EntityType.ENTITY_STONEHEAD] = true,
    [EntityType.ENTITY_CONSTANT_STONE_SHOOTER] = true,
    [EntityType.ENTITY_STONE_EYE] = true,
    [EntityType.ENTITY_BRIMSTONE_HEAD] = true,
    [EntityType.ENTITY_GAPING_MAW] = true,
    [EntityType.ENTITY_BROKEN_GAPING_MAW] = true,
    [EntityType.ENTITY_QUAKE_GRIMACE] = true,
    [EntityType.ENTITY_BOMB_GRIMACE] = true
}

mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, function(_, t, v, s, index, seed)
    if StageAPI.RecentlyChangedLevel then
        return
    end

    if StageAPI.ShouldOverrideRoom() and (t >= 1000 or StageAPI.RoomEntitySpawnGridBlacklist[t] or StageAPI.IsMetadataEntity(t, v)) and not StageAPI.ActiveTransitionToExtraRoom then
        local shouldReturn
        if shared.Room:IsFirstVisit() or StageAPI.IsMetadataEntity(t, v) then
            shouldReturn = true
        else
            local currentListIndex = StageAPI.GetCurrentRoomID()
            local roomGrids = StageAPI.GetTableIndexedByDimension(StageAPI.RoomGrids, true)
            if roomGrids[currentListIndex] and not roomGrids[currentListIndex][index] then
                shouldReturn = true
            end
        end

        if shouldReturn then
            return {
                999,
                StageAPI.E.DeleteMeEffect.V,
                0
            }
        end
    end
end)
