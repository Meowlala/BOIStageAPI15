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
---@field UpdateOptionsPickupIndex boolean
---@field StoreCheck fun(entity: Entity, data: table): boolean

---@type EntityPersistenceData[]
StageAPI.PersistentEntities = {}

---@param persistenceData EntityPersistenceData
function StageAPI.AddEntityPersistenceData(persistenceData)
    StageAPI.PersistentEntities[#StageAPI.PersistentEntities + 1] = persistenceData
end

StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_STONEHEAD, RemoveOnDeath = true, RemoveOnRemove = true,})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_CONSTANT_STONE_SHOOTER, RemoveOnDeath = true, RemoveOnRemove = true,})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_STONE_EYE, RemoveOnDeath = true, RemoveOnRemove = true,})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_BRIMSTONE_HEAD, RemoveOnDeath = true, RemoveOnRemove = true,})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_QUAKE_GRIMACE, RemoveOnDeath = true, RemoveOnRemove = true,})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_BOMB_GRIMACE, RemoveOnDeath = true, RemoveOnRemove = true,})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_BALL_AND_CHAIN, RemoveOnDeath = true, RemoveOnRemove = true,})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_MINECART, Variant = 10, RemoveOnDeath = true, RemoveOnRemove = true, --Quest Minecart
    --StoreCheck = function(entity) return entity:GetData().QuestMinecartRiddenByPlayer end,
})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_POKY, Variant = 1, RemoveOnDeath = true, RemoveOnRemove = true,
    StoreCheck = function(entity) return entity:ToNPC().State == 16 end,
})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_WALL_HUGGER, RemoveOnDeath = true, RemoveOnRemove = true,
    --StoreCheck = function(entity) return entity.CollisionDamage <= 0 end,
})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_GRUDGE, RemoveOnDeath = true, RemoveOnRemove = true,
    StoreCheck = function(entity) return entity:ToNPC().State == 16 end,
})
StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_SPIKEBALL, RemoveOnDeath = true, RemoveOnRemove = true,
    StoreCheck = function(entity) return entity:ToNPC().I2 ~= 0 end,
})

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

--[[StageAPI:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
	if npc.Variant == 10 and npc.FrameCount > 0 and npc.State ~= 16 then
		npc:GetData().QuestMinecartRiddenByPlayer = true
	end
end, EntityType.ENTITY_MINECART)]]

---@alias StageAPI.PersistenceCheck fun(entData: RoomLayout_EntityData): EntityPersistenceData?

---@type StageAPI.PersistenceCheck[]
StageAPI.PersistenceChecks = {}

---@param fn StageAPI.PersistenceCheck
function StageAPI.AddPersistenceCheck(fn)
    StageAPI.PersistenceChecks[#StageAPI.PersistenceChecks + 1] = fn
end

StageAPI.AutoPersistentTypes = {
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
    local isAutoPersistent = false
    for _, type in ipairs(StageAPI.AutoPersistentTypes) do
        isAutoPersistent = entData.Type == type
        if isAutoPersistent then break end
    end
    if isAutoPersistent then
        return {
            AutoPersists = true,
            UpdatePosition = true,
            RemoveOnRemove = true,
            UpdateType = true,
            UpdateVariant = true,
            UpdateSubType = true,
            UpdatePrice = true,
            UpdateOptionsPickupIndex = true,
            StoreCheck = function(entity)
                if entity.Type == EntityType.ENTITY_PICKUP then
                    local variant = entity.Variant
                    if variant == PickupVariant.PICKUP_THROWABLEBOMB then
                        return true
                    elseif variant == PickupVariant.PICKUP_COLLECTIBLE then
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

                        local anim = entity:GetSprite():GetAnimation()
                        if anim == "Open" or anim == "Opened" or anim == "Collect" then
                            return true
                        end

                        if entity:IsDead() then
                            return true
                        end
                    end
                elseif entity.Type == EntityType.ENTITY_SLOT then
                    local anim = entity:GetSprite():GetAnimation()
                    return (anim == "Death" or anim == "Broken")
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