local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading Custom Door Handler")

StageAPI.DoorToDirection = {
    [DoorSlot.DOWN0] = Direction.DOWN,
    [DoorSlot.DOWN1] = Direction.DOWN,
    [DoorSlot.LEFT0] = Direction.LEFT,
    [DoorSlot.LEFT1] = Direction.LEFT,
    [DoorSlot.RIGHT0] = Direction.RIGHT,
    [DoorSlot.RIGHT1] = Direction.RIGHT,
    [DoorSlot.UP0] = Direction.UP,
    [DoorSlot.UP1] = Direction.UP
}

StageAPI.DoorOffsetsByDirection = {
    [Direction.DOWN] = Vector(0, -23),
    [Direction.UP] = Vector(0, 23),
    [Direction.LEFT] = Vector(23, 0),
    [Direction.RIGHT] = Vector(-23, 0)
}

StageAPI.SecretDoorOffsetsByDirection = {
    [Direction.DOWN] = Vector(0, 0),
    [Direction.UP] = Vector(0, 0),
    [Direction.LEFT] = Vector(0, 0),
    [Direction.RIGHT] = Vector(0, 0)
}

function StageAPI.DirectionToDegrees(dir)
    return dir * 90 - 90
end

StageAPI.CustomDoorGrid = StageAPI.CustomGrid("CustomDoor")

StageAPI.DoorTypes = {}

---@param name any
---@param anm2? string
---@param openAnim? string
---@param closeAnim? string
---@param openedAnim? string
---@param closedAnim? string
---@param noAutoHandling? boolean
---@param alwaysOpen? boolean
---@param exitFunction? fun(door: EntityEffect, data: table, sprite: Sprite, doorData: CustomDoor, doorGridData: table) #doorGridData is the persistData
---@param directionOffsets? table<Direction, Vector>
---@param transitionAnim? integer Transition anim ID
---@return CustomDoor
function StageAPI.CustomDoor(name, anm2, openAnim, closeAnim, openedAnim, closedAnim, noAutoHandling, alwaysOpen, exitFunction, directionOffsets, transitionAnim)
end

---@class CustomDoor : StageAPIClass
StageAPI.CustomDoor = StageAPI.Class("CustomDoor")
function StageAPI.CustomDoor:Init(name, anm2, openAnim, closeAnim, openedAnim, closedAnim, noAutoHandling, alwaysOpen, exitFunction, directionOffsets, transitionAnim)
    self.NoAutoHandling = noAutoHandling
    self.AlwaysOpen = alwaysOpen
    self.Anm2 = anm2 or "gfx/grid/door_01_normaldoor.anm2"
    self.OpenAnim = openAnim or "Open"
    self.CloseAnim = closeAnim or "Close"
    self.OpenedAnim = openedAnim or "Opened"
    self.ClosedAnim = closedAnim or "Closed"
    self.ExitFunction = exitFunction
    self.DirectionOffsets = directionOffsets
    self.TransitionAnim = transitionAnim
    self.Name = name
    StageAPI.DoorTypes[name] = self
end

---@param name string
---@param anm2? string
---@param states table<string, CustomStateDoor_StateData | string>
---@param exitFunction? fun(door: EntityEffect, data: table, sprite: Sprite, doorData: CustomDoor, doorGridData: table) #doorGridData is the persistData
---@param overlayAnm2? string optional, uses a separate sprite rather than an overlay anim for overlay animations
---@param directionOffsets? table<Direction, Vector>
---@return CustomStateDoor
function StageAPI.CustomStateDoor(name, anm2, states, exitFunction, overlayAnm2, directionOffsets)
end

---@class CustomStateDoor_StateData
---@field Anim string
---@field OverlayAnim string
---@field Frame integer
---@field OverlayFrame integer
---@field PlayAtStart boolean
---@field Passable boolean
---@field ChangeAfterTriggerAnim boolean
---@field NoMemory boolean
---@field RememberAs string state name to be saved in persistData instead of state name
---@field StartAnim string
---@field StartFunction fun(door: EntityEffect, data: table, sprite: Sprite, doorData: CustomDoor, doorGridData: table) #doorGridData is the persistData
---@field StartOverlayAnim string
---@field StartSound SoundEffect | {[1]: SoundEffect, [2]: number, [3]: integer, [4]: boolean, [5]: number}
---@field Triggers CustomStateDoor_Triggers

---@class CustomStateDoor_Triggers
---@field Bomb string | CustomStateDoor_Trigger
---@field EnteredThrough string | CustomStateDoor_Trigger
---@field Unclear string | CustomStateDoor_Trigger
---@field Clear string | CustomStateDoor_Trigger
---@field Key string | CustomStateDoor_Trigger
---@field Coin string | CustomStateDoor_Trigger
---@field GoldKey string | CustomStateDoor_Trigger
---@field OverlayEvent CustomStateDoor_TriggerOverlayEvent
---@field FinishOverlayTrigger string | CustomStateDoor_Trigger
---@field FinishAnimTrigger string | CustomStateDoor_Trigger
---@field Function fun(door: EntityEffect, data: table, sprite: Sprite, doorData: CustomDoor, doorGridData: table): string | CustomStateDoor_Trigger #doorGridData is the persistData

---@class CustomStateDoor_Trigger
---@field State string
---@field Anim string
---@field OverlayAnim string
---@field Jingle Music
---@field Particle CustomStateDoor_TriggerParticle
---@field Particles CustomStateDoor_TriggerParticle[]

---@class CustomStateDoor_TriggerOverlayEvent : CustomStateDoor_Trigger
---@field OverlayEvent string

---@class CustomStateDoor_TriggerParticle
---@field Count integer
---@field Velocity number
---@field LifeSpan integer | {[1]: integer, [2]: integer}
---@field Type integer
---@field Variant integer
---@field SubType integer
---@field Timeout integer
---@field Rotation number


---@class CustomStateDoor : StageAPIClass
StageAPI.CustomStateDoor = StageAPI.Class("CustomStateDoor")

function StageAPI.CustomStateDoor:Init(name, anm2, states, exitFunction, overlayAnm2, directionOffsets)
    self.Anm2 = anm2 or "gfx/grid/door_01_normaldoor.anm2"
    self.OverlayAnm2 = overlayAnm2 -- optional, uses a separate sprite rather than an overlay anim for overlay animations
    self.States = states
    self.ExitFunction = exitFunction
    self.IsCustomStateDoor = true
    self.DirectionOffsets = directionOffsets
    StageAPI.DoorTypes[name] = self
end

function StageAPI.CustomStateDoor:SetDoorAnim(sprite, anim, frame, overlayAnim, overlayFrame, overlaySprite)
    if anim then
        if frame then
            sprite:SetFrame(anim, frame)
        elseif not sprite:IsPlaying(anim) and not sprite:IsFinished(anim) then
            sprite:Play(anim, true)
        end
    end

    if overlayAnim then
        if overlayFrame then
            if overlaySprite then
                overlaySprite:SetFrame(overlayAnim, overlayFrame)
            else
                sprite:SetOverlayFrame(overlayAnim, overlayFrame)
            end
        elseif not overlaySprite and not sprite:IsOverlayPlaying(overlayAnim) and not sprite:IsOverlayFinished(overlayAnim) then
            sprite:PlayOverlay(overlayAnim, true)
        elseif overlaySprite and not overlaySprite:IsPlaying(overlayAnim) and not overlaySprite:IsFinished(overlayAnim) then
            overlaySprite:Play(overlayAnim, true)
        end
    end
end

function StageAPI.CustomStateDoor:UpdateDoorSprite(sprite, stateData, triggerAnim, triggerOverlayAnim, overlaySprite)
    if type(stateData) == "string" then
        stateData = self.States[stateData]
    end

    local anim, overlayAnim
    if not triggerAnim or not sprite:IsPlaying(triggerAnim) then
        anim = stateData.Anim
    end

    if not triggerOverlayAnim or not ((overlaySprite and overlaySprite:IsPlaying(triggerOverlayAnim)) or sprite:IsOverlayPlaying(triggerOverlayAnim)) then
        overlayAnim = stateData.OverlayAnim
    end

    self:SetDoorAnim(sprite, anim, stateData.Frame, overlayAnim, stateData.OverlayFrame, overlaySprite)

    local renderOverlay = overlaySprite and ((triggerOverlayAnim and overlaySprite:IsPlaying(triggerOverlayAnim)) or overlayAnim)
    return renderOverlay, not not anim, not not overlayAnim
end

---@param slot DoorSlot
---@param leadsTo? any
---@param levelMapID? any
---@param doorDataName string
---@param data? table
---@param exitSlot? DoorSlot
---@param doorSprite? DoorSprite | string | string[]
---@param transitionAnim? RoomTransitionAnim
---@param exitPosition? Vector
---@param force? boolean do not check if a door already exists at the slot
function StageAPI.SpawnCustomDoor(slot, leadsTo, levelMapID, doorDataName, data, exitSlot, doorSprite, transitionAnim, exitPosition, force)
    if type(levelMapID) == "table" then
        levelMapID = levelMapID.Dimension
    end

    local existant = StageAPI.GetCustomDoorDataAtSlot(slot)
    if existant and not force then
        error("SpawnCustomDoor | door already exists at slot " .. tostring(slot) .. ", is " .. tostring(existant.PersistData.DoorDataName), 2)
    end

    local persistData = {
        Slot = slot,
        ExitPosition = exitPosition,
        ExitSlot = exitSlot or (slot + 2) % 4,
        LeadsTo = leadsTo,
        LevelMapID = levelMapID,
        DoorDataName = doorDataName,
        Data = data,
        DoorSprite = doorSprite,
        TransitionAnim = transitionAnim
    }
    if exitPosition then
        persistData.ExitSlot = nil
    end

    local index = shared.Room:GetGridIndex(shared.Room:GetDoorSlotPosition(slot))
    StageAPI.CustomDoorGrid:Spawn(index, nil, false, persistData)
end

---Remember that custom grids placed in previous visits of
-- the room will only spawn after ROOM_LOAD, so this is not
-- to be used there
---@param doorDataName? string
---@return CustomGridEntity[]
function StageAPI.GetCustomDoors(doorDataName)
    local ret = {}
    local doors = StageAPI.GetCustomGrids(nil, StageAPI.CustomDoorGrid.Name)
    for _, door in ipairs(doors) do
        if not doorDataName or door.PersistentData.DoorDataName == doorDataName then
            ret[#ret + 1] = door
        end
    end

    return ret
end

---Remember that custom grids placed in previous visits of
-- the room will only spawn after ROOM_LOAD, so this is not
-- to be used there
---@param slot integer
---@param doorDataName? string Optionally filter door types
---@return CustomGridEntity?
function StageAPI.GetCustomDoorAtSlot(slot, doorDataName)
    local doors = StageAPI.GetCustomGrids(nil, StageAPI.CustomDoorGrid.Name)

    for _, door in ipairs(doors) do
        if door.PersistentData.Slot == slot
        (not doorDataName or door.PersistentData.DoorDataName == doorDataName) 
        then
            return door
        end
    end
end

---Can be used during room load too
---@param doorDataName? string Optionally filter door types
---@return CustomGridPersistData[]
function StageAPI.GetCustomDoorData(doorDataName)
    local customGrids = StageAPI.GetRoomCustomGrids()
    local ret = {}

    for _, gridData in pairs(customGrids.Grids) do
        if gridData.Name == StageAPI.CustomDoorGrid.Name
        and (not doorDataName or gridData.PersistData.DoorDataName == doorDataName)
        then
            ret[#ret+1] = gridData
        end
    end

    return ret
end

---Can be used during room load too
---@param slot integer
---@param doorDataName? string Optionally filter door types
---@return CustomGridPersistData?
function StageAPI.GetCustomDoorDataAtSlot(slot, doorDataName)
    local customGrids = StageAPI.GetRoomCustomGrids()

    for _, gridData in pairs(customGrids.Grids) do
        if gridData.Name == StageAPI.CustomDoorGrid.Name
        and gridData.PersistData.Slot == slot
        and (not doorDataName or gridData.PersistData.DoorDataName == doorDataName)
        then
            return gridData
        end
    end
end

StageAPI.AddCallback("StageAPI", Callbacks.POST_SPAWN_CUSTOM_GRID, 0, function(customGrid, force, respawning)
    local index = customGrid.GridIndex
    local persistData = customGrid.PersistentData

    ---@type CustomDoor | CustomStateDoor
    local doorData
    if persistData.DoorDataName and StageAPI.DoorTypes[persistData.DoorDataName] then
        doorData = StageAPI.DoorTypes[persistData.DoorDataName]
    else
        doorData = StageAPI.BaseDoors.Default
    end

    local door = Isaac.Spawn(StageAPI.E.Door.T, StageAPI.E.Door.V, 0, shared.Room:GetGridPosition(index), Vector.Zero, nil)
    local data, sprite = door:GetData(), door:GetSprite()
    sprite:Load(doorData.Anm2, true)

    customGrid.Data.DoorEntity = door
    data.RoomIndex = StageAPI.GetCurrentRoomID()

    if persistData.DoorSprite then
        data.DoorSprite = persistData.DoorSprite
    end

    door.RenderZOffset = -10000
    sprite.Rotation = persistData.Slot * 90 - 90

    if doorData.DirectionOffsets then
        door.PositionOffset = doorData.DirectionOffsets[StageAPI.DoorToDirection[persistData.Slot]]
    else
        door.PositionOffset = StageAPI.DoorOffsetsByDirection[StageAPI.DoorToDirection[persistData.Slot]]
    end

    local opened
    if doorData.IsCustomStateDoor then
        if doorData.OverlayAnm2 then
            data.OverlaySprite = Sprite()
            data.OverlaySprite.Rotation = sprite.Rotation
            data.OverlaySprite.Offset = door.PositionOffset * (26 / 40)
            data.OverlaySprite:Load(doorData.OverlayAnm2, true)
        end

        data.State = persistData.State
        if not data.State then
            data.State = "Default"

            if doorData.States.DefaultPayToPlay and StageAPI.AnyPlayerWithPayToPlay() then
                data.State = "DefaultPayToPlay"
            end

            if shared.Room:IsClear() then
                if doorData.States.DefaultCleared then
                    data.State = "DefaultCleared"
                end
            else
                if doorData.States.DefaultUncleared then
                    data.State = "DefaultUncleared"
                end
            end

            if type(doorData.States[data.State]) == "string" then
                data.State = doorData.States[data.State]
            end
        end

        local stateData = doorData.States[data.State]

        if not stateData.PlayAtStart then
            data.PreviousState = data.State
            doorData:UpdateDoorSprite(sprite, stateData, nil, nil, data.OverlaySprite)
        end

        if stateData.Passable then
            opened = true
        else
            opened = false
        end
    elseif not doorData.NoAutoHandling then
        if doorData.AlwaysOpen then
            sprite:Play(doorData.OpenedAnim, true)
        elseif doorData.AlwaysOpen == false then
            sprite:Play(doorData.ClosedAnim, true)
        else
            if shared.Room:IsClear() then
                sprite:Play(doorData.OpenedAnim, true)
            else
                sprite:Play(doorData.ClosedAnim, true)
            end
        end
    end

    opened = opened or (opened == nil and (sprite:IsPlaying(doorData.OpenedAnim) or sprite:IsFinished(doorData.OpenedAnim)))

    local grid = shared.Room:GetGridEntity(index)
    if not grid then
        StageAPI.LogErr("Custom door not find grid at ", index, " slot ",persistData.Slot)
    end

    if opened then
        grid.CollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
    else
        grid.CollisionClass = GridCollisionClass.COLLISION_WALL
    end

    data.DoorGridData = persistData
    data.DoorData = doorData
    data.Opened = opened

    StageAPI.CallCallbacksWithParams(
        Callbacks.POST_SPAWN_CUSTOM_DOOR, false, persistData.DoorDataName,
        door, data, sprite, doorData, customGrid, force, respawning
    )
end, "CustomDoor")

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, door, offset)
    local data = door:GetData()
    if data.OverlaySprite and data.RenderOverlay then
        if shared.Room:GetRenderMode() == RenderMode.RENDER_NORMAL then
            local rpos = Isaac.WorldToRenderPosition(door.Position) + offset
            data.OverlaySprite:Render(rpos, Vector.Zero, Vector.Zero)
        end
    end
end, StageAPI.E.Door.V)

function StageAPI.SetDoorOpen(open, door)
    local grid = shared.Room:GetGridEntityFromPos(door.Position)
    if open then
        grid.CollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
    else
        grid.CollisionClass = GridCollisionClass.COLLISION_WALL
    end
end

function StageAPI.IsRoomTopLeftShifted()
    local tlPos = shared.Room:GetTopLeftPos()
    local shape = shared.Room:GetRoomShape()
    local data = StageAPI.WallData[shape]
    if data then
        local trueTL = shared.Room:GetGridPosition(data.TopLeft) + Vector(20, 20)
        if trueTL.X ~= tlPos.X or trueTL.Y ~= tlPos.Y then
            return true
        end
    end

    return false
end

function StageAPI.AnyPlayerWithPayToPlay()
    for _, player in ipairs(shared.Players) do
        if player:HasCollectible(CollectibleType.COLLECTIBLE_PAY_TO_PLAY) then
            return true
        end
    end

    return false
end

local framesWithoutDoorData = 0
local hadFrameWithoutDoorData = false
local recentDadsKey

---@param door EntityEffect
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, door)
    local data, sprite = door:GetData(), door:GetSprite()
    local doorData = data.DoorData
    if not doorData then
        framesWithoutDoorData = framesWithoutDoorData + 1
        hadFrameWithoutDoorData = true
        return
    end

    if doorData.IsCustomStateDoor then
        local stateData = doorData.States[data.State]
        if data.State ~= data.PreviousState then
            if stateData.StartAnim and not data.SkipStartAnim then
                sprite:Play(stateData.StartAnim, true)
                data.TriggerAnim = stateData.StartAnim
            end

            if stateData.StartOverlayAnim and not data.SkipStartOverlayAnim then
                sprite:Play(stateData.StartOverlayAnim, true)
                data.TriggerOverlayAnim = stateData.StartOverlayAnim
            end

            data.SkipStartAnim = nil
            data.SkipStartOverlayAnim = nil

            if not stateData.ChangeAfterTriggerAnim then
                if stateData.Passable then
                    StageAPI.SetDoorOpen(true, door)
                else
                    StageAPI.SetDoorOpen(false, door)
                end
            end

            if stateData.StartFunction then
                stateData.StartFunction(door, data, sprite, doorData, data.DoorGridData)
            end

            if stateData.StartSound then
                if type(stateData.StartSound) == "table" then
                    shared.Sfx:Play(stateData.StartSound[1], stateData.StartSound[2] or 1, stateData.StartSound[3] or 0, stateData.StartSound[4] or false, stateData.StartSound[5] or 1)
                else
                    shared.Sfx:Play(stateData.StartSound, 1, 0, false, 1)
                end
            end

            data.PreviousState = data.State
        end

        if stateData.ChangeAfterTriggerAnim and data.TriggerAnim then
            if sprite:IsFinished(data.TriggerAnim) then
                if stateData.Passable then
                    StageAPI.SetDoorOpen(true, door)
                else
                    StageAPI.SetDoorOpen(false, door)
                end
            end
        end

        local renderOverlay, animTriggerFinish, overlayTriggerFinish = doorData:UpdateDoorSprite(sprite, stateData, data.TriggerAnim, data.TriggerOverlayAnim, data.OverlaySprite)
        data.RenderOverlay = renderOverlay

        if not stateData.NoMemory then
            if stateData.RememberAs then
                data.DoorGridData.State = stateData.RememberAs
            else
                data.DoorGridData.State = data.State
            end
        end

        if stateData.Triggers then
            local currentRoom = StageAPI.GetCurrentRoom()
            local doorLocked = currentRoom and currentRoom.Metadata:Has({Name = "DoorLocker", Index = shared.Room:GetGridIndex(door.Position)})

            ---@type CustomStateDoor_Trigger
            local trigger
            if stateData.Triggers.DadsKey and recentDadsKey and not doorLocked then
                trigger = stateData.Triggers.DadsKey
            end

            if stateData.Triggers.Bomb and not doorLocked then
                if not data.CountedExplosions then
                    data.CountedExplosions = {}
                end

                for _, explosion in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, -1, false, false)) do
                    local hash = GetPtrHash(explosion)
                    local frame = explosion.FrameCount
                    if (not data.CountedExplosions[hash] or frame < data.CountedExplosions[hash]) and explosion.Position:DistanceSquared(door.Position) < 144 * 144 then
                        trigger = stateData.Triggers.Bomb
                    end

                    data.CountedExplosions[hash] = frame
                end
            end

            if stateData.Triggers.EnteredThrough and shared.Level.EnterDoor == data.DoorGridData.Slot and data.RoomIndex == StageAPI.GetCurrentRoomID() and not doorLocked then
                trigger = stateData.Triggers.EnteredThrough
            end


            if stateData.Triggers.Unclear and (not shared.Room:IsClear() or doorLocked) and not data.ForcedOpen then
                trigger = stateData.Triggers.Unclear
            end

            if stateData.Triggers.Clear and shared.Room:IsClear() and not doorLocked then
                trigger = stateData.Triggers.Clear
            end

            if (stateData.Triggers.Key or stateData.Triggers.Coin or stateData.Triggers.GoldKey) and shared.Room:IsClear() and not doorLocked then
                local touched = {}
                for _, player in ipairs(shared.Players) do
                    if player:CollidesWithGrid() and player.Position:DistanceSquared(door.Position) < 40 * 40 then
                        touched[#touched + 1] = player
                    end
                end

                local payToPlay = StageAPI.AnyPlayerWithPayToPlay()

                for _, player in ipairs(touched) do
                    if stateData.Triggers.GoldKey then
                        if player:HasGoldenKey() then
                            trigger = stateData.Triggers.GoldKey
                            break
                        end
                    end

                    if stateData.Triggers.Key and (not payToPlay or not stateData.Triggers.Key.NoPayToPlay) then
                        local keyCount = player:GetNumKeys()
                        local hasGold = player:HasGoldenKey() and not stateData.Triggers.Key.NoGold
                        if keyCount > 0 or hasGold then
                            trigger = stateData.Triggers.Key
                            if not hasGold then
                                player:AddKeys(-1)
                            end

                            break
                        end
                    end

                    if stateData.Triggers.Coin and (payToPlay or not stateData.Triggers.Coin.PayToPlay) then
                        local coinCount = player:GetNumCoins()
                        if coinCount > 0 then
                            trigger = stateData.Triggers.Coin
                            player:AddCoins(-1)
                            break
                        end
                    end
                end
            end

            if stateData.Triggers.OverlayEvent then
                if data.OverlaySprite:IsEventTriggered(stateData.Triggers.OverlayEvent.Event) then
                    trigger = stateData.Triggers.OverlayEvent
                end
            end

            if stateData.Triggers.FinishOverlayTrigger and overlayTriggerFinish then
                trigger = stateData.Triggers.FinishOverlayTrigger
            end

            if stateData.Triggers.FinishAnimTrigger and animTriggerFinish then
                trigger = stateData.Triggers.FinishAnimTrigger
            end

            if stateData.Triggers.Function then
                local active = stateData.Triggers.Function(door, data, sprite, doorData, data.DoorGridData)
                if active then
                    trigger = active
                end
            end

            if trigger then
                if type(trigger) == "table" then
                    if not trigger.Check or trigger.Check(door, data, sprite, doorData, data.DoorGridData) then
                        if trigger.State then
                            data.State = trigger.State
                        end

                        if trigger.Anim or trigger.OverlayAnim then
                            doorData:SetDoorAnim(sprite, trigger.Anim, nil, trigger.OverlayAnim, nil, data.OverlaySprite)
                        end

                        if trigger.Anim then
                            data.TriggerAnim = trigger.Anim
                            data.SkipStartAnim = true
                        end

                        if trigger.OverlayAnim then
                            data.TriggerOverlayAnim = trigger.OverlayAnim
                            data.SkipStartOverlayAnim = true
                        end

                        if trigger.ForcedOpen then
                            data.ForcedOpen = true
                        end

                        if trigger.Jingle then
                            local currentMusic = shared.Music:GetCurrentMusicID()
                            shared.Music:Play(trigger.Jingle, 1)
                            shared.Music:UpdateVolume()
                            shared.Music:Queue(currentMusic)
                        end

                        if trigger.Particle then
                            trigger.Particles = {trigger.Particle}
                        end

                        if trigger.Particles then
                            for _, particle in ipairs(trigger.Particles) do
                                local count, vel = particle.Count or 5, particle.Velocity or 5
                                if type(count) == "table" then
                                    count = StageAPI.Random(count[1], count[2])
                                end

                                if type(vel) == "table" then
                                    vel = StageAPI.Random(vel[1], vel[2])
                                end

                                for i = 1,count do
                                    local direction = Vector.FromAngle(sprite.Rotation + StageAPI.Random(-90, 90))
                                    if not shared.Room:IsPositionInRoom(door.Position + direction * 40, 0) then
                                        direction = -direction
                                    end

                                    local part = Isaac.Spawn(particle.Type or 1000, particle.Variant or EffectVariant.ROCK_PARTICLE, particle.SubType or 0, door.Position, direction * vel, nil)

                                    if particle.LifeSpan then
                                        local lifespan = particle.LifeSpan
                                        if type(lifespan) == "table" then
                                            lifespan = StageAPI.Random(lifespan[1], lifespan[2])
                                        end

                                        part:ToEffect().LifeSpan = lifespan
                                    end

                                    if particle.Timeout then
                                        local timeout = particle.Timeout
                                        if type(timeout) == "table" then
                                            timeout = StageAPI.Random(timeout[1], timeout[2])
                                        end

                                        part:ToEffect().Timeout = timeout
                                    end

                                    if particle.Rotation then
                                        local rotation = particle.Rotation
                                        if type(rotation) == "table" then
                                            rotation = StageAPI.Random(rotation[1], rotation[2])
                                        end

                                        part:ToEffect().Rotation = rotation
                                    end
                                end
                            end
                        end
                    end
                else
                    data.State = trigger
                end
            end
        end

        if data.OverlaySprite then
            data.OverlaySprite:Update()
        end
    elseif not doorData.NoAutoHandling and doorData.AlwaysOpen == nil then
        if sprite:IsFinished(doorData.OpenAnim) then
            StageAPI.SetDoorOpen(true, door)
            sprite:Play(doorData.OpenedAnim, true)
        elseif sprite:IsFinished(doorData.CloseAnim) then
            StageAPI.SetDoorOpen(false, door)
            sprite:Play(doorData.ClosedAnim, true)
        end

        if shared.Room:IsClear() and not data.Opened then
            data.Opened = true
            sprite:Play(doorData.OpenAnim, true)
        elseif not shared.Room:IsClear() and data.Opened then
            data.Opened = false
            sprite:Play(doorData.CloseAnim, true)
        end
    end

    local transitionStarted
    for _, player in ipairs(shared.Players) do
        local size = 32 + player.Size
        if not shared.Room:IsPositionInRoom(player.Position, -16) and player.Position:DistanceSquared(door.Position) < size * size then
            if doorData.ExitFunction then
                doorData.ExitFunction(door, data, sprite, doorData, data.DoorGridData)
            end

            local leadsTo = data.DoorGridData.LeadsTo
            local transitionAnim = data.DoorGridData.TransitionAnim or doorData.TransitionAnim or RoomTransitionAnim.WALK
            if leadsTo then
                transitionStarted = true
                StageAPI.ExtraRoomTransition(leadsTo, StageAPI.DoorSlotToDirection[data.DoorGridData.Slot], transitionAnim, data.DoorGridData.LevelMapID, data.DoorGridData.Slot, data.DoorGridData.ExitSlot, data.DoorGridData.ExitPosition)
            end
        end
    end

    if transitionStarted then
        for _, player in ipairs(shared.Players) do
            player.Velocity = Vector.Zero
        end
    end

    StageAPI.CallCallbacksWithParams(
        Callbacks.POST_CUSTOM_DOOR_UPDATE, false, data.DoorGridData.DoorDataName,
        door, data, sprite, doorData, data.DoorGridData
    )
end, StageAPI.E.Door.V)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    recentDadsKey = true
end, CollectibleType.COLLECTIBLE_DADS_KEY)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    recentDadsKey = false
    if hadFrameWithoutDoorData then
        hadFrameWithoutDoorData = false
    elseif framesWithoutDoorData > 0 then
        StageAPI.LogErr("Had no door data for " .. tostring(framesWithoutDoorData) .. " frames")
        framesWithoutDoorData = 0
    end
end)
