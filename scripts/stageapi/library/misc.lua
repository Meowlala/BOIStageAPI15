local shared = require("scripts.stageapi.shared")

-- Misc

function StageAPI.GetIndicesWithEntity(t, v, s, entities)
    local indicesWithEntity = {}
    for index, entityList in pairs(entities) do
        for _, entityInfo in ipairs(entityList) do
            local entityData = entityInfo.Data
            if not t or entityData.Type == t
            and not v or entityData.Variant == v
            and not s or entityData.SubType == s then
                indicesWithEntity[index] = true
            end
        end
    end

    return indicesWithEntity
end

function StageAPI.GetPlayingAnimation(sprite, animations)
    for _, anim in ipairs(animations) do
        if sprite:IsPlaying(anim) then
            return anim
        end
    end
end

function StageAPI.VectorToGrid(x, y, width)
    width = width or shared.Room:GetGridWidth()
    return width + 1 + (x + width * y)
end

function StageAPI.GridToVector(index, width)
    width = width or shared.Room:GetGridWidth()
    return (index % width) - 1, (math.floor(index / width)) - 1
end

function StageAPI.GetScreenBottomRight()
    return shared.Room:GetRenderSurfaceTopLeft() * 2 + Vector(442,286)
end

function StageAPI.GetScreenCenterPosition()
    return StageAPI.GetScreenBottomRight() / 2
end

StageAPI.DefaultScreenSize = Vector(480, 270)
function StageAPI.GetScreenScale(vec)
    local bottomRight = StageAPI.GetScreenBottomRight()
    if vec then
        return Vector(bottomRight.X / StageAPI.DefaultScreenSize.X, bottomRight.Y / StageAPI.DefaultScreenSize.Y)
    else
        return bottomRight.X / StageAPI.DefaultScreenSize.X, bottomRight.Y / StageAPI.DefaultScreenSize.Y
    end
end

function StageAPI.Lerp(first, second, percent)
    return first * (1 - percent) + second * percent
end

function StageAPI.FillBits(count)
    return (1 << count) - 1
end

function StageAPI.GetBits(bits, startBit, count)
    bits = bits >> startBit
    bits = bits & StageAPI.FillBits(count)
    return bits
end

function StageAPI.SpawnFloorEffect(pos, velocity, spawner, anm2, loadGraphics, variant)
    local creep = StageAPI.E.FloorEffectCreep
    local eff = Isaac.Spawn(creep.T, creep.V, creep.S, pos or Vector.Zero, velocity or Vector.Zero, spawner)
    eff.Variant = variant or StageAPI.E.FloorEffect.V

    if anm2 then
        eff:GetSprite():Load(anm2, loadGraphics)
    end

    return eff
end

function StageAPI.InStartingRoom()
    return shared.Level:GetCurrentRoomDesc().SafeGridIndex == shared.Level:GetStartingRoomIndex()
end

function StageAPI.GetStageAscentIndex(stage, stageType)
    stage, stageType = stage or shared.Level:GetStage(), stageType or shared.Level:GetStageType()
    if stage >= 7 or stage < 1 then
        return
    end

    if stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B then
        return stage + 1
    else
        return stage
    end
end

---@param fromIndex integer
---@param checkEntities? boolean default: true
---@param checkGrids? boolean default: true
---@param entityPartition? EntityPartition
---@param includeDecorations? boolean
---@return integer?
function StageAPI.FindFreeIndex(fromIndex, checkEntities, checkGrids, entityPartition, includeDecorations)
    if checkEntities == nil then checkEntities = true end
    if checkGrids == nil then checkGrids = true end

    local checked = {}
    local toCheck = {fromIndex}

    local gridDiagonalHalfLength = math.ceil(40 * math.sqrt(2) / 2)

    entityPartition = entityPartition or EntityPartition.ENEMY | EntityPartition.PICKUP

    while #toCheck > 0 do
        local newToCheck = {}
        local added = {}
        for _, index in ipairs(toCheck) do
            checked[index] = true

            local isFree = true

            if checkGrids then
                local grid = shared.Room:GetGridEntity(index)
                if grid and (includeDecorations or grid:GetType() ~= GridEntityType.GRID_DECORATION) then
                    isFree = false
                end
            end

            if isFree and checkEntities then
                local pos = shared.Room:GetGridPosition(index)
                -- search entities in circle that includes grid index
                local nearEntities = Isaac.FindInRadius(pos, gridDiagonalHalfLength, entityPartition)
                for _, entity in ipairs(nearEntities) do
                    local index2 = shared.Room:GetGridIndex(entity.Position)
                    if index2 == index then
                        isFree = false
                        break
                    end
                end
            end

            if isFree then
                return index
            else
                local w = shared.Room:GetGridWidth()
                local adjacent = {
                    index - w - 1,
                    index - w,
                    index - w + 1,
                    index - 1,
                    index + 1,
                    index + w - 1,
                    index + w,
                    index + w + 1,
                }
                for _, adj in ipairs(adjacent) do
                    if not checked[adj]
                    and not added[adj]
                    and shared.Room:IsPositionInRoom(shared.Room:GetGridPosition(adj), 0)
                    then
                        newToCheck[#newToCheck+1] = adj
                        added[adj] = true
                    end
                end
            end
        end
        toCheck = newToCheck
    end
end

---@param collectibleType CollectibleType
---@return boolean
function StageAPI.AnyPlayerHasItem(collectibleType)
    for _, player in ipairs(shared.Players) do
        if player:HasCollectible(collectibleType) then
            return true
        end
    end

    return false
end

---@param trinketType TrinketType
---@return boolean
function StageAPI.AnyPlayerHasTrinket(trinketType)
    for _, player in ipairs(shared.Players) do
        if player:HasTrinket(trinketType) then
            return true
        end
    end

    return false
end

function StageAPI.SanitizeString(playerName)
    return string.gsub(playerName, "%​", "") -- Unicode 8203 "Zero Width Space"
end

function StageAPI.InterpolateSprite(sprite,frame,animTabl)
    if sprite and frame and animTabl then
        local startdata,enddata
        for i,data in ipairs(animTabl) do
            if frame<data[1] then
                startdata,enddata = animTabl[i-1],data
                break
            end
        end
        if startdata and enddata then
            if enddata[5] then
                local procent = (frame-startdata[1])/(enddata[1]-startdata[1])
                local offset = startdata[2]+(enddata[2]-startdata[2])*procent
                local scale = startdata[3]+(enddata[3]-startdata[3])*procent
                local color = Color(
	            startdata[4].R+(enddata[4].R-startdata[4].R)*procent,
                    startdata[4].G+(enddata[4].G-startdata[4].G)*procent,
                    startdata[4].B+(enddata[4].B-startdata[4].B)*procent,
                    startdata[4].A+(enddata[4].A-startdata[4].A)*procent)
                sprite.Offset = offset
                sprite.Scale = scale
                sprite.Color = color
            else
                sprite.Offset = startdata[2]
                sprite.Scale = startdata[3]
                sprite.Color = startdata[4]
            end
        end
    end
end
