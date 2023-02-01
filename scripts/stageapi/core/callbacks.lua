local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading Core Callbacks")

local DIMENSION_DEATH_CERTIFICATE = 2

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
StageAPI.PreviousDoors = nil

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

StageAPI.PotentialAscentData = {}
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if StageAPI.JustUsedD7 then
        StageAPI.JustUsedD7 = nil
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom then
            if currentRoom.IsExtraRoom then
                currentRoom:Save()
            end

            currentRoom.IsClear = currentRoom.WasClearAtStart
            currentRoom:Load(nil, true, true)
        end
    end

    StageAPI.PotentialAscentData = {}
    local rooms = shared.Level:GetRooms()
    for i = 0, rooms.Size - 1 do
        local roomDesc = rooms:Get(i)
        local dimension = StageAPI.GetDimension(roomDesc)
        if dimension == 0 then
            local data = roomDesc.Data
            if data.Type == RoomType.ROOM_BOSS or data.Type == RoomType.ROOM_TREASURE then
                StageAPI.PotentialAscentData[#StageAPI.PotentialAscentData + 1] = {
                    ListIndex = roomDesc.ListIndex,
                    Name = data.Name,
                    Type = data.Type,
                    Variant = data.Variant
                }
            end
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

    if shared.Game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH) then
        local ascentIndex = StageAPI.GetStageAscentIndex()
        local ascentData = StageAPI.AscentData[ascentIndex]
        local desc = shared.Level:GetCurrentRoomDesc()

        if ascentData then
            for _, roomData in ipairs(ascentData) do
                if roomData.LevelRoom and roomData.Name == desc.Data.Name and roomData.Type == desc.Data.Type and roomData.Variant == desc.Data.Variant then
                    return true, true
                end
            end
        end
    end

    if currentRoom then
        return true, false
    elseif StageAPI.InNewStage() then
        if StageAPI.CurrentStage:WillOverrideRoom(shared.Level:GetCurrentRoomDesc()) then
            return true, false
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
    ["gfx/grid/trapdoor_corpse_big.anm2"] = true
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
    local isSecretExit = shared.Room:GetType() == RoomType.ROOM_SECRET_EXIT
    local nextStage = StageAPI.CallCallbacks(Callbacks.PRE_SELECT_NEXT_STAGE, true, StageAPI.CurrentStage, isSecretExit)
    if not isSecretExit then
        nextStage = nextStage or currStage.NextStage
    end

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
    local updatedGrids, updatedDoors
    local newDoors = {}
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

    -- Door count gets changed by ie devil doors spawning
    for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local hasDoor = not not shared.Room:GetDoor(i)
        if not StageAPI.PreviousDoors or hasDoor ~= StageAPI.PreviousDoors[i] then
            updatedDoors = true
            if hasDoor then
                newDoors[#newDoors+1] = i
            end
        end
    end

    if shared.Sfx:IsPlaying(SoundEffect.SOUND_CASTLEPORTCULLIS) and not (StageAPI.CurrentStage and StageAPI.CurrentStage.BossMusic and StageAPI.CurrentStage.BossMusic.Intro) then
        shared.Sfx:Stop(SoundEffect.SOUND_CASTLEPORTCULLIS)
        shared.Sfx:Play(StageAPI.S.BossIntro, 1, 0, false, 1)
    end

    local inCustomStage = StageAPI.InOverriddenStage() and StageAPI.CurrentStage 
    local currentDimension = StageAPI.GetDimension()

    if inCustomStage then
        local roomType = shared.Room:GetType()
        local rtype = StageAPI.GetCurrentRoomType()

        -- Grid Gfx

        if currentDimension ~= DIMENSION_DEATH_CERTIFICATE then
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
                elseif updatedDoors then
                    for _, newDoorSlot in ipairs(newDoors) do
                        local door = shared.Room:GetDoor(newDoorSlot)
                        StageAPI.ChangeSingleGrid(door, grids, door:GetGridIndex())
                    end
                end
            end

            if not StageAPI.RoomRendered and updatedGrids then
                StageAPI.CallCallbacks(Callbacks.POST_UPDATE_GRID_GFX, false, grids)
            end
        end

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
        
        StageAPI.RoomRendered = true
    end

    -- Music handling

    local musicRoom = StageAPI.GetCurrentRoom()

    -- if transitioning from extra room to normal room, 
    -- grid index is still the old one while the stageapi room
    -- id is reset, leaving for default music for the transition
    -- only (if the normal room was for instance a boss room)
    -- Fix this by taking the last extra room in case
    if StageAPI.DoingExtraRoomTransition
    and not StageAPI.TransitioningToExtraRoom 
    and StageAPI.PreviousExtraRoomData.RoomID
    then
        local levelMap = StageAPI.LevelMaps[StageAPI.PreviousExtraRoomData.MapID]
        local roomId = levelMap:GetRoomData(StageAPI.PreviousExtraRoomData.RoomID).RoomID
        musicRoom = StageAPI.GetLevelRoom(roomId, StageAPI.PreviousExtraRoomData.MapID)
    end

    if (
        inCustomStage
        and currentDimension ~= DIMENSION_DEATH_CERTIFICATE
    ) or musicRoom then
        local id = shared.Music:GetCurrentMusicID()
        local musicID, shouldLayer, shouldQueue, disregardNonOverride
        if musicRoom then
            musicID, shouldLayer = musicRoom:GetPlayingMusic()
        end

        if not musicID and StageAPI.CurrentStage then
            musicID, shouldLayer, shouldQueue, disregardNonOverride = StageAPI.CurrentStage:GetPlayingMusic()
        end

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
    end

    local backdropType = shared.Room:GetBackdropType()
    if StageAPI.LastBackdropType ~= backdropType then
        local currentRoom = StageAPI.GetCurrentRoom()
        local usingGfx
        -- Manual handling instead of CallCallbacksAccumulator needed as usingGfx
        -- is the second arg, won't change for backwards compat
        local callbacks = StageAPI.GetCallbacks(Callbacks.PRE_CHANGE_ROOM_GFX)
        for _, callback in ipairs(callbacks) do
            local success, ret = StageAPI.TryCallback(callback, currentRoom, usingGfx, true, currentDimension)
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

        StageAPI.CallCallbacks(Callbacks.POST_CHANGE_ROOM_GFX, false, currentRoom, usingGfx, true, currentDimension)

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
    elseif args.CheckEncountered then
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

-- Certain boss subtypes should be replaced with monstro to avoid bugs
local replaceBossSubtypes = {
    [23] = true, -- the fallen, spawns devil items
    [81] = true, -- heretic, pentagram effect
    [82] = true, -- hornfel, doors
    [83] = true, -- great gideon, health bar
    [91] = true, -- min-min, mist
}

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
    local setMirrorBossData
    if baseFloorInfo and baseFloorInfo.HasCustomBosses
    and roomDesc.Data.Type == RoomType.ROOM_BOSS
    and roomDesc.SafeGridIndex ~= GridRooms.ROOM_DEBUG_IDX
    and dimension == 0 and not backwards then
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
                    NoPlayBossAnim = true,
                    CheckEncountered = false,
                }, {
                    RoomDescriptor = roomDesc
                })

                if replaceBossSubtypes[roomDesc.Data.Subtype] then
                    local overwritableRoomDesc = shared.Level:GetRoomByIdx(roomDesc.SafeGridIndex, dimension)
                    local replaceData = StageAPI.GetGotoDataForTypeShape(RoomType.ROOM_BOSS, roomDesc.Data.Shape)
                    overwritableRoomDesc.Data = replaceData
                    setMirrorBossData = replaceData
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
        if roomDesc.Data.Type == RoomType.ROOM_BOSS and baseFloorInfo.HasMirrorLevel and dimension == 0 and roomDesc.SafeGridIndex > -1 then
            local mirroredRoom = newRoom:Copy(roomDesc)
            local mirroredDesc = shared.Level:GetRoomByIdx(roomDesc.SafeGridIndex, 1)
            if setMirrorBossData then
                mirroredDesc.Data = setMirrorBossData
            end

            StageAPI.SetLevelRoom(mirroredRoom, mirroredDesc.ListIndex, 1)
			
            StageAPI.LogMinor("Mirroring!")
        end
    end
end

function StageAPI.GenerateBaseLevel()
    -- changing room data can cause soft locks in br testing, for some reason. don't do it!
    if BasementRenovator and BasementRenovator.InTestRoom and BasementRenovator.InTestStage and (BasementRenovator:InTestRoom() or BasementRenovator:InTestStage()) then
        return
    end

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
            if not swappedWith.HandledSwap and not changed.HandledSwap then
                swappedWith.HandledSwap = true
                changed.HandledSwap = true

                local levelRoomOne = StageAPI.GetLevelRoom(swappedWith.ListIndex, dimension)
                local levelRoomTwo = StageAPI.GetLevelRoom(changed.ListIndex, dimension)
                StageAPI.SetLevelRoom(levelRoomOne, changed.ListIndex, dimension)
                StageAPI.SetLevelRoom(levelRoomTwo, swappedWith.ListIndex, dimension)

                local customGridsOne = StageAPI.GetRoomCustomGrids(dimension, swappedWith.ListIndex)
                local customGridsTwo = StageAPI.GetRoomCustomGrids(dimension, changed.ListIndex)
                StageAPI.CustomGrids[dimension][changed.ListIndex] = customGridsOne
                StageAPI.CustomGrids[dimension][swappedWith.ListIndex] = customGridsTwo
                
                StageAPI.CallCallbacks(Callbacks.POST_ROOM_SWAP, false, swappedWith.ListIndex, changed.ListIndex, levelRoomOne, levelRoomTwo)
            end
        else
            if generateNewRooms then
                StageAPI.SetLevelRoom(nil, changed.ListIndex, dimension)
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

StageAPI.PreviousNewRoomStage = -1
StageAPI.PreviousNewRoomStageType = -1
StageAPI.EarlyNewRoomTriggered = false
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    StageAPI.CallCallbacks(Callbacks.PRE_STAGEAPI_NEW_ROOM, false)

    StageAPI.EarlyNewRoomTriggered = false
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

    if StageAPI.NextStage and not StageAPI.DoubleTransitioning then
        StageAPI.CallCallbacksWithParams(Callbacks.EARLY_NEW_CUSTOM_STAGE, false, StageAPI.NextStage, StageAPI.NextStage)
        if StageAPI.NextStage.LevelgenStage then
            StageAPI.DoubleTransitioning = true
            local replace = StageAPI.NextStage.Replaces
            shared.Level:SetStage(replace.OverrideStage, replace.OverrideStageType)
            local currentRoomIndex = shared.Level:GetCurrentRoomIndex()

            -- let on first room visit effects trigger (like The Stairway item)
            local editableCurrentDesc = shared.Level:GetRoomByIdx(currentRoomIndex)
            editableCurrentDesc.VisitedCount = 0

            shared.Level:ChangeRoom(currentRoomIndex)
            return
        end
    end

    StageAPI.DoubleTransitioning = false

    local isNewStage, override = StageAPI.InOverriddenStage()
    local inStartingRoom = StageAPI.InStartingRoom()
    local currentDimension = StageAPI.GetDimension()

    for _, customGrid in ipairs(StageAPI.GetCustomGrids()) do
        if not customGrid.JustSpawned then
            customGrid:Unload()
        else
            customGrid.JustSpawned = false
        end
    end

    -- Only a room the player is actively in can be "Loaded"
    for _, levelRoom in ipairs(StageAPI.GetAllLevelRooms()) do
        levelRoom.Loaded = false
    end

    local setDefaultLevelMap
    if not StageAPI.TransitioningToExtraRoom then
        local reversedIntoExtraRoom
        if StageAPI.PreviousExtraRoomData
        and StageAPI.PreviousExtraRoomData.RoomIndex == shared.Level:GetCurrentRoomIndex() then
            local desc = shared.Level:GetCurrentRoomDesc()
            if desc.Data.Variant == StageAPI.PreviousExtraRoomData.RoomVariant and desc.SpawnSeed == StageAPI.PreviousExtraRoomData.RoomSeed then
                StageAPI.CurrentLevelMapID = StageAPI.PreviousExtraRoomData.MapID
                StageAPI.CurrentLevelMapRoomID = StageAPI.PreviousExtraRoomData.RoomID
                reversedIntoExtraRoom = true
            end
        end

        if not reversedIntoExtraRoom then
            if StageAPI.PreviousExtraRoomData
            and StageAPI.PreviousExtraRoomData.RoomIndex then
                if StageAPI.PreviousExtraRoomData.RoomIndex ~= shared.Level:GetPreviousRoomIndex() then
                    StageAPI.PreviousExtraRoomData = {}
                else
                    local desc = shared.Level:GetRoomByIdx(StageAPI.PreviousExtraRoomData.RoomIndex)
                    if not desc or desc.Data.Variant ~= StageAPI.PreviousExtraRoomData.RoomVariant or desc.SpawnSeed ~= StageAPI.PreviousExtraRoomData.RoomSeed then
                        StageAPI.PreviousExtraRoomData = {}
                    end
                end
            end

            setDefaultLevelMap = true
            StageAPI.CurrentLevelMapID = StageAPI.DefaultLevelMapID
            StageAPI.CurrentLevelMapRoomID = nil
        end
    else
        StageAPI.PreviousExtraRoomData = {
            MapID = StageAPI.CurrentLevelMapID,
            RoomID = StageAPI.CurrentLevelMapRoomID,
            RoomIndex = shared.Level:GetCurrentRoomIndex(),
            RoomVariant = shared.Level:GetCurrentRoomDesc().Data.Variant,
            RoomSeed = shared.Level:GetCurrentRoomDesc().SpawnSeed
        }
    end

    if (
        not shared.Level:GetStateFlag(LevelStateFlag.STATE_LEVEL_START_TRIGGERED) 
        and shared.Level:GetCurrentRoomIndex() == shared.Level:GetPreviousRoomIndex()
    ) or (
        isNewStage 
        and not StageAPI.CurrentStage
    ) then
        local previousAscentIndex = StageAPI.GetStageAscentIndex(StageAPI.PreviousNewRoomStage, StageAPI.PreviousNewRoomStageType)
        if previousAscentIndex then
            local ascentData = {}
        
            for _, roomData in ipairs(StageAPI.PotentialAscentData) do
                local customGrids = StageAPI.GetRoomCustomGrids(0, roomData.ListIndex)
                local levelRoom = StageAPI.GetLevelRoom(roomData.ListIndex, 0)

                local roomSaveDat = {
                    Name = roomData.Name,
                    Type = roomData.Type,
                    Variant = roomData.Variant
                }
                if customGrids and customGrids.LastPersistentIndex ~= 0 then
                    roomSaveDat.CustomGrids = customGrids
                end
                
                if levelRoom then
                    roomSaveDat.LevelRoom = levelRoom:GetSaveData(false)
                end

                if StageAPI.RoomGrids[0] and StageAPI.RoomGrids[0][roomData.ListIndex] then
                    roomSaveDat.RoomGrids = StageAPI.RoomGrids[0][roomData.ListIndex]
                end

                ascentData[#ascentData + 1] = roomSaveDat
            end

            StageAPI.AscentData[previousAscentIndex] = ascentData
        end

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

        if shared.Game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH) then
            local ascentIndex = StageAPI.GetStageAscentIndex()
            if StageAPI.AscentData[ascentIndex] then
                local ascentData = StageAPI.AscentData[ascentIndex]

                local matchingRooms = {}
                local roomsList = shared.Level:GetRooms()
                for i = 0, roomsList.Size - 1 do
                    local roomDesc = roomsList:Get(i)
                    for _, roomData in ipairs(ascentData) do
                        if roomData.Name == roomDesc.Data.Name and roomData.Type == roomDesc.Data.Type and roomData.Variant == roomDesc.Data.Variant then
                            matchingRooms[#matchingRooms + 1] = roomDesc
                            break
                        end
                    end
                end

                for _, roomData in ipairs(ascentData) do
                    local firstMatchingRoom
                    for i, roomDesc in ipairs(matchingRooms) do
                        if roomData.Name == roomDesc.Data.Name and roomData.Type == roomDesc.Data.Type and roomData.Variant == roomDesc.Data.Variant then
                            firstMatchingRoom = roomDesc
                            table.remove(matchingRooms, i)
                            break
                        end
                    end

                    if firstMatchingRoom then
                        if roomData.LevelRoom then
                            local levelRoom = StageAPI.LevelRoom{FromSave = roomData.LevelRoom}
                            if roomData.Type == RoomType.ROOM_BOSS then
                                levelRoom.IsClear = true
                            end

                            StageAPI.SetLevelRoom(levelRoom, firstMatchingRoom.ListIndex, 0)
                        end

                        if roomData.CustomGrids then
                            StageAPI.CustomGrids[0] = StageAPI.CustomGrids[0] or {}
                            StageAPI.CustomGrids[0][firstMatchingRoom.ListIndex] = roomData.CustomGrids
                        end

                        if roomData.RoomGrids then
                            StageAPI.RoomGrids[0] = StageAPI.RoomGrids[0] or {}
                            StageAPI.RoomGrids[0][firstMatchingRoom.ListIndex] = roomData.RoomGrids
                        end
                    end
                end
            end
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

        if StageAPI.CurrentStage and StageAPI.CurrentStage.GetPlayingMusic then
            local musicID = StageAPI.CurrentStage:GetPlayingMusic()
            if musicID then
                shared.Music:Queue(musicID)
            end
        end
    end

    StageAPI.NextStage = nil
    StageAPI.DetectBaseLayoutChanges(false)

    local currentListIndex = StageAPI.GetCurrentRoomID()
    local currentRoom, justGenerated, boss = StageAPI.GetCurrentRoom(), nil, nil

    local retCurrentRoom, retJustGenerated, retBoss = StageAPI.CallCallbacks(Callbacks.PRE_STAGEAPI_NEW_ROOM_GENERATION, true, currentRoom, justGenerated, currentListIndex, currentDimension)
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

    retCurrentRoom, retJustGenerated, retBoss = StageAPI.CallCallbacks(Callbacks.POST_STAGEAPI_NEW_ROOM_GENERATION, true, currentRoom, justGenerated, currentListIndex, boss, currentDimension)
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

            local vanishingTwins = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.VANISHING_TWIN, -1, false, false)
            for _, twin in ipairs(vanishingTwins) do
                twin = twin:ToFamiliar()
                if twin.Coins > 0 then
                    if boss.VanishingTwinEntity then
                        twin.Coins = boss.VanishingTwinEntity.Type
                        twin.Keys = boss.VanishingTwinEntity.Variant
                    elseif boss.Entity then
                        twin.Coins = boss.Entity.Type
                        twin.Keys = boss.Entity.Variant
                    end
                end
            end
        else
            local text = StageAPI.SanitizeString(shared.Players[1]:GetName()) .. " VS " .. boss.Name

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
    StageAPI.DoingExtraRoomTransition = false

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
    elseif StageAPI.CurrentStage and StageAPI.CurrentStage.RoomGfx 
    and currentDimension ~= DIMENSION_DEATH_CERTIFICATE
    then
        local rtype = StageAPI.GetCurrentRoomType()

        -- Handle Devil's crown room gfx
        if rtype == RoomType.ROOM_TREASURE
        and StageAPI.IsDevilsCrownRoom(shared.Level:GetCurrentRoomDesc()) then
            rtype = RoomType.ROOM_DEVIL
        end

        usingGfx = StageAPI.CurrentStage.RoomGfx[rtype]
    end

    -- Manual handling instead of CallCallbacksAccumulator needed as usingGfx
    -- is the second arg, won't change for backwards compat
    local callbacks = StageAPI.GetCallbacks(Callbacks.PRE_CHANGE_ROOM_GFX)
    for _, callback in ipairs(callbacks) do
        local success, ret = StageAPI.TryCallback(callback, currentRoom, usingGfx, false, currentDimension)
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

    StageAPI.CallCallbacks(Callbacks.POST_CHANGE_ROOM_GFX, false, currentRoom, usingGfx, false, currentDimension)

    StageAPI.LastBackdropType = shared.Room:GetBackdropType()
    StageAPI.RoomRendered = false

    StageAPI.CallCallbacks(Callbacks.POST_STAGEAPI_NEW_ROOM, false, justGenerated)

    StageAPI.PreviousNewRoomStage = shared.Level:GetStage()
    StageAPI.PreviousNewRoomStageType = shared.Level:GetStageType()
    StageAPI.PotentialAscentData = {}
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
    if StageAPI.ConsoleSpawningGrid then -- gridspawn command triggers MC_PRE_ROOM_ENTITY_SPAWN for some reason?
        return
    end

    if not StageAPI.EarlyNewRoomTriggered then
        StageAPI.EarlyNewRoomTriggered = true
        StageAPI.CallCallbacks(Callbacks.EARLY_NEW_ROOM, false)
    end

    local shouldOverride, forceOverride = StageAPI.ShouldOverrideRoom()

    if shouldOverride and (not StageAPI.RecentlyChangedLevel or forceOverride) and (t >= 1000 or StageAPI.RoomEntitySpawnGridBlacklist[t] or StageAPI.IsMetadataEntity(t, v)) and not StageAPI.ActiveTransitionToExtraRoom then
        local shouldReturn
        if shared.Room:IsFirstVisit() or StageAPI.GetMetadataEntity(t, v) or forceOverride then
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

StageAPI.AddCallback("StageAPI", Callbacks.EARLY_NEW_ROOM, -1, function()
    --[[
        because EARLY_NEW_ROOM is unreliable, this doesn't work consistently
        but this is necessary to avoid camera bugs when loading extra rooms
        all extra rooms have an effect that will instantly delete itself
        placed in the room to ensure that this callback works when transitioning
        to them
    ]]
    if StageAPI.ForcePlayerDoorSlot or StageAPI.ForcePlayerNewRoomPosition then
        local pos = StageAPI.ForcePlayerNewRoomPosition or shared.Room:GetClampedPosition(shared.Room:GetDoorSlotPosition(StageAPI.ForcePlayerDoorSlot), 16)
        for _, player in ipairs(shared.Players) do
            player.Position = pos
        end

        if StageAPI.ForcePlayerDoorSlot then
            shared.Level.EnterDoor = StageAPI.ForcePlayerDoorSlot
        end
    end

    for _, customGrid in ipairs(StageAPI.GetCustomGrids()) do
        customGrid:Unload()
    end

    if StageAPI.InTestMode then
        StageAPI.RoomGrids = {}
        StageAPI.CustomGrids = {}
        StageAPI.LevelRooms = {}
    end

    if not StageAPI.ShouldOverrideRoom() then
        local roomDesc = shared.Level:GetCurrentRoomDesc()
        StageAPI.GenerateBaseRoom(roomDesc)
    end
end)

---Handle devil's crown items
---@param roomDesc RoomDescriptor
---@return boolean
function StageAPI.IsDevilsCrownRoom(roomDesc)
    return roomDesc.Flags & RoomDescriptor.FLAG_DEVIL_TREASURE > 0
end

function StageAPI.GetDevilPrice(id)
    local devilPrice = shared.ItemConfig:GetCollectible(id).DevilPrice

    local playerHasRedHealth, allPlayersHaveRedHealth
    for _, player in ipairs(shared.Players) do
        if player:GetMaxHearts() > 0 then
            playerHasRedHealth = true
        else
            allPlayersHaveRedHealth = true
        end
    end

    allPlayersHaveRedHealth = not allPlayersHaveRedHealth

    if allPlayersHaveRedHealth or (playerHasRedHealth and StageAPI.Random(1, 2) == 1) then
        if devilPrice == 1 then
            return PickupPrice.PRICE_ONE_HEART
        else
            return PickupPrice.PRICE_TWO_HEARTS
        end
    else
        return PickupPrice.PRICE_THREE_SOULHEARTS
    end
end

---@param currentRoom LevelRoom
---@param isFirstLoad boolean
---@param isExtraRoom boolean
StageAPI.AddCallback("StageAPI", Callbacks.POST_ROOM_LOAD, 1, function(currentRoom, isFirstLoad, isExtraRoom)
    if isFirstLoad then
        local roomDesc = shared.Level:GetCurrentRoomDesc()
        local isDevilCrown = StageAPI.IsDevilsCrownRoom(roomDesc)

        local keeperBExists = false
        for _, player in ipairs(shared.Players) do
            if player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
                keeperBExists = true
                break
            end
        end

        if isDevilCrown then
            local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
            for _, entity in ipairs(collectibles) do
                local pickup = entity:ToPickup()
                if keeperBExists then
                    pickup.Price = 15
                else
                    pickup.Price = StageAPI.GetDevilPrice(pickup.SubType)
                end
                pickup.AutoUpdatePrice = true
            end
        end
    end
end)

--#region MemberCard

local SECRET_SHOP_LADDER_VARIANT = 2
local MEMBER_CARD_DEFAULT_INDEX = 25

---@param entityInfo SpawnList.EntityInfo
---@param entityList SpawnList.EntityInfo[]
---@param index integer
---@param doGrids boolean
---@param doPersistentOnly boolean
---@param doAutoPersistent boolean
---@param avoidSpawning boolean
---@param persistenceData table
---@param shouldSpawnEntity boolean
StageAPI.AddCallback("StageAPI", Callbacks.PRE_SPAWN_ENTITY, 1, function(entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, shouldSpawnEntity)
    -- Do not spawn slot machines in secret shops

    local roomType = shared.Room:GetType()

    if roomType == RoomType.ROOM_SHOP
    and shared.Level:GetCurrentRoomDesc().GridIndex == GridRooms.ROOM_SECRET_SHOP_IDX
    and entityInfo.Data.Type == EntityType.ENTITY_SLOT
    then
        return false
    end
end)


-- Spawn member card shop trapdoor
-- Wait after room load so it doesn't go under grids spawned in room loading
-- Assumes it was cleared by ClearRoomLayout to be able to spawn it in a separate
-- position if the metaentity was set
-- Also spawn ladder which would be cleared by stageapi otherwise
---@param currentRoom LevelRoom
---@param isFirstLoad boolean
---@param isExtraRoom boolean
StageAPI.AddCallback("StageAPI", Callbacks.POST_ROOM_LOAD, 1, function(currentRoom, isFirstLoad, isExtraRoom)
    -- secret shop: base room type must be shop
    -- spawning trapdoor: stageapi room type must be shop, so custom rooms work too

    local roomDesc = shared.Level:GetCurrentRoomDesc()
    local isSecretShop = roomDesc.GridIndex == GridRooms.ROOM_SECRET_SHOP_IDX 
        and not StageAPI.InExtraRoom()
        and shared.Room:GetType() == RoomType.ROOM_SHOP

    if isSecretShop or currentRoom:GetType() == RoomType.ROOM_SHOP then
        if isFirstLoad then

            local hasMemberCard = false

            for _, player in ipairs(shared.Players) do
                if player:HasCollectible(CollectibleType.COLLECTIBLE_MEMBER_CARD) then
                    hasMemberCard = true
                    break
                end
            end

            local pos

            if isSecretShop
            or hasMemberCard then
                local index
                local positionMeta = currentRoom.Metadata:Search { Name = "Member Card Trapdoor Position" }[1]
                if positionMeta then
                    index = positionMeta.Index
                else
                    -- use normal member card position unless explicitly specified by meta entity
                    index = MEMBER_CARD_DEFAULT_INDEX --StageAPI.FindFreeIndex(MEMBER_CARD_DEFAULT_INDEX)
                end

                pos = shared.Room:GetGridPosition(index)
            end

            if isSecretShop then
                -- Spawn exit ladder

                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TALL_LADDER, 0, pos, Vector.Zero, nil)

                for _, player in ipairs(shared.Players) do
                    player.Position = pos
                end
            elseif hasMemberCard then
                -- Can't use vanilla TrySpawnSecretShop function 
                -- or FindFreeTile as it seemingly ignores spawned slot
                -- machines and such
                Isaac.GridSpawn(GridEntityType.GRID_STAIRS, SECRET_SHOP_LADDER_VARIANT, pos)
            end

            if pos then
                currentRoom.PersistentData.MemberCardIndex = shared.Room:GetGridIndex(pos)
            end
        elseif currentRoom.PersistentData.MemberCardIndex then
            -- Check if a trapdoor/ladder was spawned in default vanilla position
            -- and move it

            local checkIndex = currentRoom.PersistentData.MemberCardIndex

            if checkIndex == MEMBER_CARD_DEFAULT_INDEX then
                -- No need to do anything, vanilla handles it
                return
            end

            if isSecretShop then
                local ladders = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TALL_LADDER)
                local found = false
                for _, ladder in ipairs(ladders) do
                    local idx = shared.Room:GetGridIndex(ladder.Position)
                    if idx == checkIndex then
                        found = true
                    elseif idx == MEMBER_CARD_DEFAULT_INDEX then
                        ladder:Remove()
                    end
                end

                if not found then
                    Isaac.Spawn(
                        EntityType.ENTITY_EFFECT, EffectVariant.TALL_LADDER, 0, 
                        shared.Room:GetGridPosition(checkIndex), Vector.Zero, 
                        nil
                    )
                end

                for _, player in ipairs(shared.Players) do
                    player.Position = shared.Room:GetGridPosition(checkIndex)
                end
            else
                local gridEntity = shared.Room:GetGridEntity(MEMBER_CARD_DEFAULT_INDEX)
                if gridEntity 
                and gridEntity:GetType() == GridEntityType.GRID_STAIRS
                and gridEntity:GetVariant() == SECRET_SHOP_LADDER_VARIANT
                then
                    shared.Room:RemoveGridEntity(MEMBER_CARD_DEFAULT_INDEX, 0, false)
                end
            end
        end
    end
end)

--#endregion