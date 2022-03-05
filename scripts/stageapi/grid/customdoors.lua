local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

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

function StageAPI.SpawnCustomDoor(slot, leadsTo, levelMapID, doorDataName, data, exitSlot, doorSprite, transitionAnim, exitPosition)
    if type(levelMapID) == "table" then
        levelMapID = levelMapID.Dimension
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

function StageAPI.GetCustomDoors(doorDataName)
    local ret = {}
    local doors = StageAPI.GetCustomGrids(nil, "CustomDoor")
    for _, door in ipairs(doors) do
        if not doorDataName or door.PersistentData.DoorDataName == doorDataName then
            ret[#ret + 1] = door
        end
    end

    return ret
end

StageAPI.AddCallback("StageAPI", "POST_SPAWN_CUSTOM_GRID", 0, function(customGrid, force, respawning)
    local index = customGrid.GridIndex
    local persistData = customGrid.PersistentData

    local doorData
    if persistData.DoorDataName and StageAPI.DoorTypes[persistData.DoorDataName] then
        doorData = StageAPI.DoorTypes[persistData.DoorDataName]
    else
        doorData = StageAPI.BaseDoors.Default
    end

    local door = Isaac.Spawn(StageAPI.E.Door.T, StageAPI.E.Door.V, 0, shared.Room:GetGridPosition(index), Vector.Zero, nil)
    local data, sprite = door:GetData(), door:GetSprite()
    sprite:Load(doorData.Anm2, true)

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
            data.OverlaySprite.Offset = sprite.Offset
            data.OverlaySprite:Load(doorData.OverlayAnm2, true)
        end

        data.State = persistData.State
        if not data.State then
            data.State = "Default"
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
        StageAPI.LogErr("Custom door not find grid at", index, "slot",persistData.Slot)
    end

    if opened then
        grid.CollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
    else
        grid.CollisionClass = GridCollisionClass.COLLISION_WALL
    end

    data.DoorGridData = persistData
    data.DoorData = doorData
    data.Opened = opened

    local callbacks = StageAPI.GetCallbacks("POST_SPAWN_CUSTOM_DOOR")
    for _, callback in ipairs(callbacks) do
        if not callback.Params[1] or callback.Params[1] == persistData.DoorDataName then
            callback.Function(door, data, sprite, doorData, customGrid, force, respawning)
        end
    end
end, "CustomDoor")

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, door)
    local data = door:GetData()
    if data.OverlaySprite and data.RenderOverlay then
        local rpos = Isaac.WorldToRenderPosition(door.Position) + shared.Room:GetRenderScrollOffset()
        data.OverlaySprite:Render(rpos, Vector.Zero, Vector.Zero)
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

local framesWithoutDoorData = 0
local hadFrameWithoutDoorData = false
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
            local trigger
            if stateData.Triggers.Bomb then
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

            if stateData.Triggers.EnteredThrough and shared.Level.EnterDoor == data.DoorGridData.Slot then
                trigger = stateData.Triggers.EnteredThrough
            end

            if stateData.Triggers.Unclear and not shared.Room:IsClear() then
                trigger = stateData.Triggers.Unclear
            end

            if stateData.Triggers.Clear and shared.Room:IsClear() then
                trigger = stateData.Triggers.Clear
            end

            if (stateData.Triggers.Key or stateData.Triggers.Coin or stateData.Triggers.GoldKey) and shared.Room:IsClear() then
                local touched = {}
                for _, player in ipairs(shared.Players) do
                    if player:CollidesWithGrid() and player.Position:DistanceSquared(door.Position) < 40 * 40 then
                        touched[#touched + 1] = player
                    end
                end

                for _, player in ipairs(touched) do
                    if stateData.Triggers.GoldKey then
                        if player:HasGoldenKey() then
                            trigger = stateData.Triggers.GoldKey
                            break
                        end
                    end

                    if stateData.Triggers.Key then
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

                    if stateData.Triggers.Coin then
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

    local callbacks = StageAPI.GetCallbacks("POST_CUSTOM_DOOR_UPDATE")
    for _, callback in ipairs(callbacks) do
        if not callback.Params[1] or callback.Params[1] == data.DoorGridData.DoorDataName then
            callback.Function(door, data, sprite, doorData, data.DoorGridData)
        end
    end
end, StageAPI.E.Door.V)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if hadFrameWithoutDoorData then
        hadFrameWithoutDoorData = false
    elseif framesWithoutDoorData > 0 then
        StageAPI.LogErr("Had no door data for " .. tostring(framesWithoutDoorData) .. " frames")
        framesWithoutDoorData = 0
    end
end)