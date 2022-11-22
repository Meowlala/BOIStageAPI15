local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading Extra Room Handler")

StageAPI.RoomTypeToGotoPrefix = {
    [RoomType.ROOM_DEFAULT] = "d.",
    [RoomType.ROOM_SHOP] = "s.shop.",
    [RoomType.ROOM_ERROR] = "s.error.",
    [RoomType.ROOM_TREASURE] = "s.treasure.",
    [RoomType.ROOM_BOSS] = "s.boss.",
    [RoomType.ROOM_MINIBOSS] = "s.miniboss.",
    [RoomType.ROOM_SECRET] = "s.secret.",
    [RoomType.ROOM_SUPERSECRET] = "s.supersecret.",
    [RoomType.ROOM_ARCADE] = "s.arcade.",
    [RoomType.ROOM_CURSE] = "s.curse.",
    [RoomType.ROOM_CHALLENGE] = "s.challenge.",
    [RoomType.ROOM_LIBRARY] = "s.library.",
    [RoomType.ROOM_SACRIFICE] = "s.sacrifice.",
    [RoomType.ROOM_DEVIL] = "s.devil.",
    [RoomType.ROOM_ANGEL] = "s.angel.",
    [RoomType.ROOM_DUNGEON] = "s.itemdungeon.",
    [RoomType.ROOM_BOSSRUSH] = "s.bossrush.",
    [RoomType.ROOM_ISAACS] = "s.isaacs.",
    [RoomType.ROOM_BARREN] = "s.barren.",
    [RoomType.ROOM_CHEST] = "s.chest.",
    [RoomType.ROOM_DICE] = "s.dice.",
    [RoomType.ROOM_BLACK_MARKET] = "s.blackmarket.",
    [RoomType.ROOM_GREED_EXIT] = "s.greedexit.",
    [RoomType.ROOM_PLANETARIUM] = "s.planetarium.",
    [RoomType.ROOM_TELEPORTER] = "s.teleporter.",
    [RoomType.ROOM_TELEPORTER_EXIT] = "s.teleporterexit.",
    [RoomType.ROOM_SECRET_EXIT] = "s.secretexit.",
    [RoomType.ROOM_BLUE] = "s.blue.",
    [RoomType.ROOM_ULTRASECRET] = "s.ultrasecret.",
}

StageAPI.RoomShapeToGotoData = {
    [RoomShape.ROOMSHAPE_1x1] = {
        ID = "70050"
    },
    [RoomShape.ROOMSHAPE_IH] = {
        ID = "70051"
    },
    [RoomShape.ROOMSHAPE_IV] = {
        ID = "70052"
    },
    [RoomShape.ROOMSHAPE_1x2] = {
        ID = "70053",
        Locked = "70062"
    },
    [RoomShape.ROOMSHAPE_IIV] = {
        ID = "70054"
    },
    [RoomShape.ROOMSHAPE_2x1] = {
        ID = "70055",
        Locked = "70063"
    },
    [RoomShape.ROOMSHAPE_IIH] = {
        ID = "70056"
    },
    [RoomShape.ROOMSHAPE_2x2] = {
        ID = "70057",
        Locked = "70064"
    },
    [RoomShape.ROOMSHAPE_LTL] = {
        ID = "70058",
        Locked = "70065"
    },
    [RoomShape.ROOMSHAPE_LTR] = {
        ID = "70059",
        Locked = "70066"
    },
    [RoomShape.ROOMSHAPE_LBL] = {
        ID = "70060",
        Locked = "70067"
    },
    [RoomShape.ROOMSHAPE_LBR] = {
        ID = "70061",
        Locked = "70068"
    }
}

for shape, gotoData in pairs(StageAPI.RoomShapeToGotoData) do
    gotoData.Data = {}
    if gotoData.Locked then
        gotoData.LockedData = {}
    end
end

StageAPI.PreloadedGotoData = {}
function StageAPI.PreloadGotoRooms(roomTypes, roomShapes)
    if not roomShapes then
        roomShapes = {}
        for shape = 1, RoomShape.NUM_ROOMSHAPES - 1 do
            roomShapes[#roomShapes + 1] = shape
        end
    end

    for _, roomType in ipairs(roomTypes) do
        local shapes = StageAPI.PreloadedGotoData[roomType]
        if not shapes then
            shapes = {}
            StageAPI.PreloadedGotoData[roomType] = shapes
        end

        for _, roomShape in ipairs(roomShapes) do
            if not shapes[roomShape] then
                shapes[roomShape] = false
            end
        end
    end
end

local defaultSpecialRoomShapes = {
    RoomShape.ROOMSHAPE_1x1,
    RoomShape.ROOMSHAPE_IH,
    RoomShape.ROOMSHAPE_IV,
}

local defaultBossRoomShapes = {
    RoomShape.ROOMSHAPE_1x1,
    RoomShape.ROOMSHAPE_IH,
    RoomShape.ROOMSHAPE_IV,
    RoomShape.ROOMSHAPE_2x2,
    RoomShape.ROOMSHAPE_1x2,
    RoomShape.ROOMSHAPE_2x1,
}

local validDungeonShapes = {
    RoomShape.ROOMSHAPE_1x1,
    RoomShape.ROOMSHAPE_1x2,
    RoomShape.ROOMSHAPE_2x1,
    RoomShape.ROOMSHAPE_2x2,
}

local defaultBlueRoomShapes = {
    RoomShape.ROOMSHAPE_2x1,
    RoomShape.ROOMSHAPE_1x2,
    RoomShape.ROOMSHAPE_IIH,
    RoomShape.ROOMSHAPE_IIV,
}

local defaultShopRoomShapes = {
    RoomShape.ROOMSHAPE_1x1,
    RoomShape.ROOMSHAPE_IH,
    RoomShape.ROOMSHAPE_IV,
    RoomShape.ROOMSHAPE_2x1,
}

StageAPI.PreloadGotoRooms({RoomType.ROOM_DEFAULT})
StageAPI.PreloadGotoRooms({RoomType.ROOM_BOSS}, defaultBossRoomShapes)
StageAPI.PreloadGotoRooms({RoomType.ROOM_DUNGEON}, validDungeonShapes)
StageAPI.PreloadGotoRooms({RoomType.ROOM_BLACK_MARKET}, {RoomShape.ROOMSHAPE_2x1})
StageAPI.PreloadGotoRooms({RoomType.ROOM_BOSSRUSH}, {RoomShape.ROOMSHAPE_2x2})
StageAPI.PreloadGotoRooms({RoomType.ROOM_BLUE}, defaultBlueRoomShapes)
StageAPI.PreloadGotoRooms({RoomType.ROOM_SHOP}, defaultShopRoomShapes)
StageAPI.PreloadGotoRooms({
    RoomType.ROOM_SECRET,
    RoomType.ROOM_SUPERSECRET,
    RoomType.ROOM_ULTRASECRET,
    RoomType.ROOM_GREED_EXIT,
}, {RoomShape.ROOMSHAPE_1x1})
StageAPI.PreloadGotoRooms({
    RoomType.ROOM_ERROR,
    RoomType.ROOM_TREASURE,
    RoomType.ROOM_MINIBOSS,
    RoomType.ROOM_ARCADE,
    RoomType.ROOM_CURSE,
    RoomType.ROOM_CHALLENGE,
    RoomType.ROOM_LIBRARY,
    RoomType.ROOM_SACRIFICE,
    RoomType.ROOM_DEVIL,
    RoomType.ROOM_ANGEL,
    RoomType.ROOM_ISAACS,
    RoomType.ROOM_BARREN,
    RoomType.ROOM_CHEST,
    RoomType.ROOM_DICE,
    RoomType.ROOM_SECRET_EXIT,
    RoomType.ROOM_PLANETARIUM,
}, defaultSpecialRoomShapes)

StageAPI.DataLoadNeedsRestart = false
StageAPI.GotoDataLoaded = false
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if not StageAPI.InTestMode then
        local needsToLoad
        for roomType, roomShapes in pairs(StageAPI.PreloadedGotoData) do
            for roomShape, loaded in pairs(roomShapes) do
                if not loaded then
                    if not needsToLoad then
                        needsToLoad = {}
                    end

                    if not needsToLoad[roomType] then
                        needsToLoad[roomType] = {}
                    end

                    needsToLoad[roomType][#needsToLoad[roomType] + 1] = roomShape
                end
            end
        end

        if needsToLoad then
            local resetRun
            local currentIndex = shared.Level:GetCurrentRoomIndex()
            if StageAPI.InStartingRoom() and shared.Room:IsFirstVisit() and shared.Level:GetStage() == LevelStage.STAGE1_1 and shared.Game:GetFrameCount() <= 1 then
                resetRun = true
            end

            local levelMapID, levelMapRoomID
            if StageAPI.InExtraRoom() then
                levelMapID = StageAPI.CurrentLevelMapID
                levelMapRoomID = StageAPI.CurrentLevelMapRoomID
            end

            for roomType, roomShapes in pairs(needsToLoad) do
                for _, shape in ipairs(roomShapes) do
                    local cmd, lockedCmd = StageAPI.GetGotoCommandForTypeShape(roomType, shape, true)
                    Isaac.ExecuteCommand(cmd)
                    local desc = shared.Level:GetRoomByIdx(GridRooms.ROOM_DEBUG_IDX)

                    local shapeData = StageAPI.RoomShapeToGotoData[shape]
                    shapeData.Data[roomType] = desc.Data

                    if lockedCmd and shapeData.LockedData then
                        Isaac.ExecuteCommand(lockedCmd)
                        local desc = shared.Level:GetRoomByIdx(GridRooms.ROOM_DEBUG_IDX)
                        shapeData.LockedData[roomType] = desc.Data
                    end

                    StageAPI.PreloadedGotoData[roomType][shape] = true
                end
            end

            if resetRun then
                StageAPI.DataLoadNeedsRestart = true
            end

            if levelMapID and levelMapRoomID then
                StageAPI.ExtraRoomTransition(levelMapRoomID, Direction.NO_DIRECTION, RoomTransitionAnim.WALK, levelMapID)
            else
                shared.Game:StartRoomTransition(currentIndex, Direction.NO_DIRECTION, 0)
            end
        end
    end

    StageAPI.GotoDataLoaded = true
end)

function StageAPI.FinishedLoadingData()
    return StageAPI.GotoDataLoaded and not StageAPI.DataLoadNeedsRestart
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    if StageAPI.DataLoadNeedsRestart then
        Isaac.ExecuteCommand("restart")
        StageAPI.DataLoadNeedsRestart = nil
    end
end)

local shadowSprite = Sprite()
shadowSprite:Load("stageapi/stage_shadow.anm2", false)
shadowSprite:Play("1x1", true)
local lastUsedShadowSpritesheet

StageAPI.StoredExtraRoomThisPause = false

function StageAPI.GetGotoCommandForTypeShape(roomType, roomShape, ignoreMissingData)
    local shapeData = StageAPI.RoomShapeToGotoData[roomShape]
    local prefix = "goto " .. StageAPI.RoomTypeToGotoPrefix[roomType]
    if shapeData.Data[roomType] or ignoreMissingData then
        return prefix .. shapeData.ID, (shapeData.Locked and (prefix .. shapeData.Locked))
    else
        return StageAPI.GetGotoCommandForTypeShape(RoomType.ROOM_DEFAULT, roomShape, true)
    end
end

function StageAPI.GetGotoDataForTypeShape(roomType, roomShape)
    local shapeData = StageAPI.RoomShapeToGotoData[roomShape]
    if shapeData.Data[roomType] then
        return shapeData.Data[roomType], (shapeData.LockedData and shapeData.LockedData[roomType])
    else
        return StageAPI.GetGotoDataForTypeShape(RoomType.ROOM_DEFAULT, roomShape)
    end
end

StageAPI.DoorOneSlots = {
    [DoorSlot.DOWN1] = true,
    [DoorSlot.UP1] = true,
    [DoorSlot.LEFT1] = true,
    [DoorSlot.RIGHT1] = true
}

StageAPI.DoorSlotToDirection = {
    [DoorSlot.LEFT0] = Direction.LEFT,
    [DoorSlot.LEFT1] = Direction.LEFT,
    [DoorSlot.RIGHT0] = Direction.RIGHT,
    [DoorSlot.RIGHT1] = Direction.RIGHT,
    [DoorSlot.UP0] = Direction.UP,
    [DoorSlot.UP1] = Direction.UP,
    [DoorSlot.DOWN0] = Direction.DOWN,
    [DoorSlot.DOWN1] = Direction.DOWN
}

StageAPI.LRoomShapes = {
    [RoomShape.ROOMSHAPE_LTL] = true,
    [RoomShape.ROOMSHAPE_LTR] = true,
    [RoomShape.ROOMSHAPE_LBL] = true,
    [RoomShape.ROOMSHAPE_LBR] = true
}

StageAPI.LargeRoomShapes = {
    [RoomShape.ROOMSHAPE_LTL] = true,
    [RoomShape.ROOMSHAPE_LTR] = true,
    [RoomShape.ROOMSHAPE_LBL] = true,
    [RoomShape.ROOMSHAPE_LBR] = true,
    [RoomShape.ROOMSHAPE_2x2] = true,
}

local function anyPlayerHas(id, trinket)
    for _, player in ipairs(shared.Players) do
        if trinket then
            if player:HasTrinket(id) then
                return true
            end
        elseif player:HasCollectible(id) then
            return true
        end
    end

    return false
end

StageAPI.BaseGridRoomPriority = {
    GridRooms.ROOM_MEGA_SATAN_IDX,
    GridRooms.ROOM_BOSSRUSH_IDX,
    GridRooms.ROOM_THE_VOID_IDX,
    GridRooms.ROOM_ROTGUT_DUNGEON1_IDX,
}

StageAPI.BaseLGridRoomPriority = {
    GridRooms.ROOM_ANGEL_SHOP_IDX,
    GridRooms.ROOM_BLACK_MARKET_IDX,
    GridRooms.ROOM_DEBUG_IDX,
    GridRooms.ROOM_ROTGUT_DUNGEON2_IDX,
    GridRooms.ROOM_SECRET_SHOP_IDX,
    GridRooms.ROOM_ERROR_IDX
}

function StageAPI.GetNextFreeBaseGridRoom(priorityList, taken, nextIsBoss)
    local outIdx
    local stage = shared.Level:GetStage()
    for _, idx in ipairs(priorityList) do
        if not StageAPI.IsIn(taken, idx) then
            if idx == GridRooms.ROOM_MEGA_SATAN_IDX then
                if stage ~= LevelStage.STAGE6 or shared.Game:IsGreedMode() then
                    outIdx = idx
                    break
                end
            elseif idx == GridRooms.ROOM_BOSSRUSH_IDX then
                if stage ~= LevelStage.STAGE3_2 or shared.Game:IsGreedMode() then
                    outIdx = idx
                    break
                end
            elseif idx == GridRooms.ROOM_ROTGUT_DUNGEON1_IDX or idx == GridRooms.ROOM_ROTGUT_DUNGEON2_IDX then
                local rooms = shared.Level:GetRooms()
                local hasRotgutRoom
                for i = 0, rooms.Size - 1 do
                    local desc = rooms:Get(i)
                    if desc and desc.Data.Type == RoomType.ROOM_BOSS and desc.Data.Subtype == 87 then
                        hasRotgutRoom = true
                        break
                    end
                end

                if not hasRotgutRoom then
                    local rotgutRoomSpawned = shared.Level:GetRoomByIdx(GridRooms.ROOM_ROTGUT_DUNGEON1_IDX).SpawnSeed ~= 0
                    if not rotgutRoomSpawned then
                        local rotgut = Isaac.Spawn(EntityType.ENTITY_ROTGUT, 0, 0, Vector.Zero, Vector.Zero, nil)
                        rotgut:Update()
                        rotgut:Remove()
                    end

                    outIdx = idx
                    break
                end
            elseif idx == GridRooms.ROOM_SECRET_SHOP_IDX then
                if not anyPlayerHas(CollectibleType.COLLECTIBLE_MEMBER_CARD)
                or not (
                    stage <= LevelStage.STAGE3_2
                    or stage == LevelStage.STAGE4_3
                    or (anyPlayerHas(TrinketType.TRINKET_SILVER_DOLLAR) and stage <= LevelStage.STAGE4_2)
                ) then
                    outIdx = idx
                    break
                end
            elseif idx == GridRooms.ROOM_ANGEL_SHOP_IDX then
                if not anyPlayerHas(CollectibleType.COLLECTIBLE_STAIRWAY)
                or (
                    not StageAPI.InStartingRoom()
                    and shared.Level:GetRoomByIdx(shared.Level:GetStartingRoomIndex()).VisitedCount > 0
                )  then
                    outIdx = idx
                    break
                end
            elseif idx == GridRooms.ROOM_BLACK_MARKET_IDX then
                local dungeonRoom = shared.Level:GetRoomByIdx(GridRooms.ROOM_DUNGEON_IDX)
                if not dungeonRoom or dungeonRoom.Data.Doors & StageAPI.DoorsBitwise[DoorSlot.RIGHT0] == 0 then
                    outIdx = idx
                    break
                end
            elseif idx ~= GridRooms.ROOM_ERROR_IDX then
                if not nextIsBoss then
                    if idx == GridRooms.ROOM_THE_VOID_IDX then
                        if shared.Level:GetStage() ~= LevelStage.STAGE3_4 or shared.Game:IsGreedMode() then
                            outIdx = idx
                            break
                        end
                    else
                        outIdx = idx
                        break
                    end
                end
            else
                outIdx = idx
                break
            end
        end
    end

    taken[#taken + 1] = outIdx
    return outIdx
end

function StageAPI.GetExtraRoomBaseGridRooms(nextIsBoss)
    local taken = {}
    local default = StageAPI.GetNextFreeBaseGridRoom(StageAPI.BaseGridRoomPriority, taken, nextIsBoss)
    local alternate = StageAPI.GetNextFreeBaseGridRoom(StageAPI.BaseGridRoomPriority, taken, nextIsBoss)
    local largeDefault = StageAPI.GetNextFreeBaseGridRoom(StageAPI.BaseLGridRoomPriority, taken, nextIsBoss)
    local largeAlternate = StageAPI.GetNextFreeBaseGridRoom(StageAPI.BaseLGridRoomPriority, taken, nextIsBoss)

    return default, alternate, largeDefault, largeAlternate
end

---@param levelMapRoomID any
---@param direction? Direction
---@param transitionType? RoomTransitionAnim | -1 # -1 for instant transition
---@param levelMapID? Dimension
---@param leaveDoor? DoorSlot
---@param enterDoor? DoorSlot
---@param setPlayerPosition? Vector
---@param extraRoomBaseType? RoomType
---@param noSave? boolean
function StageAPI.ExtraRoomTransition(levelMapRoomID, direction, transitionType, levelMapID, leaveDoor, enterDoor, setPlayerPosition, extraRoomBaseType, noSave)
    leaveDoor = leaveDoor or -1
    enterDoor = enterDoor or -1
    transitionType = transitionType or RoomTransitionAnim.WALK
    direction = direction or Direction.NO_DIRECTION
    StageAPI.ForcePlayerNewRoomPosition = setPlayerPosition

    if StageAPI.TransitioningToExtraRoom then
        StageAPI.LogWarn("Transitioning to extra room while already doing a transition! ", StageAPI.TryGetCallInfo())
    end

    if not noSave then
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom and currentRoom.IsExtraRoom then
            currentRoom:Save()
        end
    end

    local transitionFrom = shared.Level:GetCurrentRoomIndex()
    local transitionTo
    if not levelMapID then
        transitionTo = levelMapRoomID
    elseif type(levelMapID) == "table" then
        levelMapID = levelMapID.Dimension
    end

    if transitionFrom >= 0 then
        StageAPI.LastNonExtraRoom = transitionFrom
    else
        local currentRoomDesc = shared.Level:GetRoomByIdx(transitionFrom)
        local currentGotoData, currentGotoLockedData = StageAPI.GetGotoDataForTypeShape(shared.Room:GetType(), shared.Room:GetRoomShape())
        if currentGotoLockedData and StageAPI.DoorOneSlots[leaveDoor] then
            currentRoomDesc.Data = currentGotoLockedData
        else
            currentRoomDesc.Data = currentGotoData
        end
    end

    local targetLevelRoom
    local setDataForShape, setVisitCount, setClear, setClearCount, setDecoSeed, setSpawnSeed, setAwardSeed, setWater, setChallengeDone
    if levelMapID then
        StageAPI.TransitioningToExtraRoom = true
        StageAPI.CurrentLevelMapID = levelMapID
        StageAPI.CurrentLevelMapRoomID = levelMapRoomID

        local levelMap = StageAPI.GetCurrentLevelMap()
        local roomData = levelMap:GetRoomData(levelMapRoomID)
        targetLevelRoom = levelMap:GetRoom(levelMapRoomID)

        local curStage, currentStageType = shared.Level:GetStage(), shared.Level:GetStageType()
        local stage, stageType = roomData.Stage or curStage, roomData.StageType or currentStageType
        if stage ~= curStage or stageType ~= currentStageType then
            shared.Level:SetStage(stage, stageType)
        end
    else
        StageAPI.TransitioningToExtraRoom = false
        StageAPI.CurrentLevelMapID = StageAPI.DefaultLevelMapID
        StageAPI.CurrentLevelMapRoomID = nil
    end

    if targetLevelRoom then
        extraRoomBaseType = extraRoomBaseType or targetLevelRoom.RoomType
        setDataForShape = setDataForShape or targetLevelRoom.Shape
        setSpawnSeed = setSpawnSeed or targetLevelRoom.SpawnSeed
        setDecoSeed = setDecoSeed or targetLevelRoom.DecorationSeed
        setAwardSeed = setAwardSeed or targetLevelRoom.AwardSeed
        setVisitCount = setVisitCount or targetLevelRoom.VisitCount or 0
        setClearCount = setClearCount or targetLevelRoom.ClearCount or 0

        if setWater == nil then
            setWater = false or targetLevelRoom.HasWaterPits
        end

        if setChallengeDone == nil then
            setChallengeDone = false or targetLevelRoom.ChallengeDone
        end

        if setClear == nil then
            setClear = true
            if targetLevelRoom.IsClear ~= nil then
                setClear = targetLevelRoom.IsClear
            end
        end
    end

    if not transitionTo then
        local defaultGridRoom, alternateGridRoom, defaultLargeGridRoom, alternateLargeGridRoom = StageAPI.GetExtraRoomBaseGridRooms(extraRoomBaseType == RoomType.ROOM_BOSS)

        transitionTo = defaultGridRoom

        if setDataForShape and StageAPI.LargeRoomShapes[setDataForShape] then
            transitionTo = defaultLargeGridRoom
        end

        -- alternating between two off-grid rooms makes transitions between certain room types and shapes cleaner
        if transitionFrom < 0 and transitionFrom == transitionTo then
            if transitionTo == defaultGridRoom then
                transitionTo = alternateGridRoom
            elseif transitionTo == defaultLargeGridRoom then
                transitionTo = alternateLargeGridRoom
            end
        end
    end

    local targetRoomDesc = shared.Level:GetRoomByIdx(transitionTo)

    if setDataForShape then
        local targetGotoData, targetGotoLockedData = StageAPI.GetGotoDataForTypeShape(extraRoomBaseType, setDataForShape)
        if targetGotoLockedData and StageAPI.DoorOneSlots[enterDoor] then
            targetRoomDesc.Data = targetGotoLockedData
        else
            targetRoomDesc.Data = targetGotoData
        end
    end

    if setVisitCount then
        targetRoomDesc.VisitedCount = setVisitCount
    end

    if setClear ~= nil then
        targetRoomDesc.Clear = setClear
    end

    if setWater ~= nil then
        targetRoomDesc.HasWater = setWater
    end

    if setChallengeDone ~= nil then
        targetRoomDesc.ChallengeDone = setChallengeDone
    end

    if setClearCount then
        targetRoomDesc.ClearCount = setClearCount
    end

    if setDecoSeed then
        targetRoomDesc.DecorationSeed = setDecoSeed
    end

    if setSpawnSeed then
        targetRoomDesc.SpawnSeed = setSpawnSeed
    end

    if setAwardSeed then
        targetRoomDesc.AwardSeed = setAwardSeed
    end

    shared.Level.LeaveDoor = leaveDoor
    shared.Level.EnterDoor = enterDoor

    if transitionType == -1 then -- StageAPI special, instant transition
        StageAPI.ForcePlayerDoorSlot = (enterDoor == -1 and nil) or enterDoor
        shared.Level:ChangeRoom(transitionTo)
    else
        if enterDoor ~= -1 then
            StageAPI.ForcePlayerDoorSlot = enterDoor
        else
            StageAPI.ForcePlayerDoorSlot = nil
        end

        shared.Game:StartRoomTransition(transitionTo, direction, transitionType)
    end

    -- To check if doing transition either to or from extra room
    StageAPI.DoingExtraRoomTransition = true
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not shared.Game:IsPaused() then
        StageAPI.StoredExtraRoomThisPause = false
    elseif StageAPI.InExtraRoom() and not StageAPI.StoredExtraRoomThisPause and not StageAPI.TransitioningToExtraRoom then
        StageAPI.StoredExtraRoomThisPause = true
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom then
            currentRoom:Save()
        end
    end

    if not StageAPI.IsHUDAnimationPlaying() then
        if not StageAPI.InNewStage() then
            local btype, stage, stype = shared.Room:GetBackdropType(), shared.Level:GetStage(), shared.Level:GetStageType()
            if (btype == 7 or btype == 8 or btype == 16) and (stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2 or stage == LevelStage.STAGE6) then
                for _, overlay in ipairs(StageAPI.NecropolisOverlays) do
                    if not shared.Game:IsPaused() then
                        overlay:Update()
                    end

                    overlay:Render(nil, nil, true)
                end
            end
        end

        --[[local shadows = Isaac.FindByType(StageAPI.E.StageShadow.T, StageAPI.E.StageShadow.V, -1, false, false)
        local shadow = shadows[1]
        if shadow then
            local shadowSheet, shadowAnim = shadow:GetData().Sheet, shadow:GetData().Animation
            if shadowSheet and shadowSheet ~= lastUsedShadowSpritesheet then
                shadowSprite:ReplaceSpritesheet(0, shadowSheet)
                shadowSprite:LoadGraphics()
                lastUsedShadowSpritesheet = shadowSheet
            end

            if shadowAnim and not (shadowSprite:IsPlaying(shadowAnim) or shadowSprite:IsFinished(shadowAnim)) then
                shadowSprite:Play(shadowAnim, true)
            end
            shadowSprite.Color = shadow.Color
            shadowSprite:Render(Isaac.WorldToRenderPosition(shadow.Position) + shared.Room:GetRenderScrollOffset(), Vector.Zero, Vector.Zero)
        end]]
    end

    StageAPI.CallCallbacks(Callbacks.PRE_TRANSITION_RENDER)
end)