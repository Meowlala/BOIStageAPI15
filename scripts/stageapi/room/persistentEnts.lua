local shared = require("scripts.stageapi.shared")

--[[ options
{
    Type = etype,
    Variant = variant,
    SubType = subtype,
    AutoPersists = autoPersists,
    RemoveOnRemove = removeOnRemove,
    RemoveOnDeath = removeOnDeath,
    UpdatePosition = updatePosition,
    StoreCheck = storeCheck
}
]]
---@class EntityPersistenceData
---@field Type EntityType
---@field Variant integer
---@field SubType integer
---@field AutoPersists boolean
---@field RemoveOnRemove boolean
---@field RemoveOnDeath boolean
---@field UpdatePosition boolean
---@field UpdateHealth boolean
---@field UpdatePrice boolean
---@field StoreCheck fun(entity: Entity, data: table): boolean

---@type EntityPersistenceData[]
StageAPI.PersistentEntities = {}

---@param persistenceData EntityPersistenceData
function StageAPI.AddEntityPersistenceData(persistenceData)
    StageAPI.PersistentEntities[#StageAPI.PersistentEntities + 1] = persistenceData
end

StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_STONEHEAD})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_CONSTANT_STONE_SHOOTER})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_STONE_EYE})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_BRIMSTONE_HEAD})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_QUAKE_GRIMACE})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_WALL_HUGGER})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_POKY, Variant = 1})

for i = 0, 4 do
    StageAPI.AddEntityPersistenceData({
        Type = EntityType.ENTITY_FIREPLACE,
        Variant = i,
        AutoPersists = true,
        RemoveOnRemove = true,
        UpdateType = true,
        UpdateVariant = true,
        UpdateSubType = true,
        UpdateHealth = true,
    })
end

---@alias StageAPI.PersistenceCheck fun(entData: RoomLayout_EntityData): EntityPersistenceData?

---@type StageAPI.PersistenceCheck[]
StageAPI.PersistenceChecks = {}

---@param fn StageAPI.PersistenceCheck
function StageAPI.AddPersistenceCheck(fn)
    StageAPI.PersistenceChecks[#StageAPI.PersistenceChecks + 1] = fn
end

StageAPI.DynamicPersistentTypes = {
    EntityType.ENTITY_BOMBDROP,
    EntityType.ENTITY_PICKUP,
    EntityType.ENTITY_SLOT,
    EntityType.ENTITY_MOVABLE_TNT,
    EntityType.ENTITY_SHOPKEEPER,
    EntityType.ENTITY_PITFALL,
    EntityType.ENTITY_ETERNALFLY,
}

StageAPI.ChestVariants = {
    PickupVariant.PICKUP_CHEST,
    PickupVariant.PICKUP_LOCKEDCHEST,
    PickupVariant.PICKUP_BOMBCHEST,
    PickupVariant.PICKUP_ETERNALCHEST,
    PickupVariant.PICKUP_MIMICCHEST,
    PickupVariant.PICKUP_SPIKEDCHEST,
    PickupVariant.PICKUP_REDCHEST,
    PickupVariant.PICKUP_OLDCHEST,
    PickupVariant.PICKUP_WOODENCHEST,
    PickupVariant.PICKUP_MEGACHEST,
    PickupVariant.PICKUP_HAUNTEDCHEST,
    PickupVariant.PICKUP_MOMSCHEST,
}

StageAPI.AddPersistenceCheck(function(entData)
    local isDynamicPersistent = false
    for _, type in ipairs(StageAPI.DynamicPersistentTypes) do
        isDynamicPersistent = entData.Type == type
        if isDynamicPersistent then break end
    end
    if isDynamicPersistent then
        return {
            AutoPersists = true,
            UpdatePosition = true,
            RemoveOnRemove = true,
            UpdateType = true,
            UpdateVariant = true,
            UpdateSubType = true,
            UpdatePrice = true,
            StoreCheck = function(entity)
                if entity.Type == EntityType.ENTITY_PICKUP then
                    local variant = entity.Variant
                    if variant == PickupVariant.PICKUP_COLLECTIBLE then
                        return entity.SubType == 0
                    else
                        local isChest
                        for _, var in ipairs(StageAPI.ChestVariants) do
                            if variant == var then
                                isChest = true
                            end
                        end

                        if isChest then
                            return entity.SubType == 0
                        end

                        local sprite = entity:GetSprite()
                        if sprite:IsPlaying("Open") or sprite:IsPlaying("Opened") or sprite:IsPlaying("Collect") or sprite:IsFinished("Open") or sprite:IsFinished("Opened") or sprite:IsFinished("Collect") then
                            return true
                        end

                        if entity:IsDead() then
                            return true
                        end
                    end
                elseif entity.Type == EntityType.ENTITY_SLOT then
                    return entity:GetSprite():IsPlaying("Death") or entity:GetSprite():IsPlaying("Broken") or entity:GetSprite():IsFinished("Death") or entity:GetSprite():IsFinished("Broken")
                elseif entity.Type == EntityType.ENTITY_MOVABLE_TNT then
                    return entity.HitPoints == 0.5 or entity:GetSprite():GetAnimation() == "Blown"
                end
            end
        }
    end
end)

---@param id EntityType
---@param variant integer
---@param subtype integer
---@return EntityPersistenceData?
function StageAPI.CheckPersistence(id, variant, subtype)
    local persistentData

    for _, persistData in ipairs(StageAPI.PersistentEntities) do
        if (not persistData.Type or id == persistData.Type)
        and (not persistData.Variant or variant == persistData.Variant)
        and (not persistData.SubType or subtype == persistData.SubType) then
            persistentData = persistData
        end
    end

    if not persistentData then
        for _, check in ipairs(StageAPI.PersistenceChecks) do
            local persistData = check({Type = id, Variant = variant, SubType = subtype})
            if persistData then
                persistentData = persistData
                break
            end
        end
    end

    return persistentData
end
