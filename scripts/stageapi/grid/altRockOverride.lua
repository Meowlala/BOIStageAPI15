local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading Rock Alt Breaking Override")

local FART_RADIUS = 150

StageAPI.OverridenAltRock = StageAPI.CustomGrid("StageAPIOverridenAltRock", {
    BaseType = GridEntityType.GRID_ROCK_ALT,
    OverrideGridSpawns = true,
    NoOverrideGridSprite = true,
    RemoveOnAnm2Change = true,
})

StageAPI.AddCallback("StageAPI", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid, projectile)
    if projectile then
        customGrid.DoOverridenGridBreakLater = true
    else
        if customGrid.GridEntity then
            StageAPI.CallCallbacks(Callbacks.POST_OVERRIDDEN_GRID_BREAK, true, customGrid.GridEntity:GetGridIndex(), customGrid.GridEntity, customGrid.BrokenData)
        end
        StageAPI.CallCallbacks(Callbacks.POST_OVERRIDDEN_ALT_ROCK_BREAK, true, customGrid.Position, customGrid.GridVariant, customGrid.BrokenData, customGrid, projectile)
    end
end, "StageAPIOverridenAltRock")

StageAPI.AddCallback("StageAPI", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid, projectile)
    if customGrid.PersistentData.OverridenAltRockSpawns then
        if projectile then
            customGrid.DoOverridenGridBreakLater = true
        else
            if customGrid.GridEntity then
                StageAPI.CallCallbacks(Callbacks.POST_OVERRIDDEN_GRID_BREAK, true, customGrid.GridEntity:GetGridIndex(), customGrid.GridEntity, customGrid.BrokenData)
            end
            StageAPI.CallCallbacks(Callbacks.POST_OVERRIDDEN_ALT_ROCK_BREAK, true, customGrid.Position, customGrid.GridVariant, customGrid.BrokenData, customGrid, projectile)
        end
    end
end)

StageAPI.RecentFarts = {}
StageAPI.TemporaryIgnoreSpawnOverride = false
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, id, variant, subtype, position, velocity, spawner, seed)
    local grindex = shared.Room:GetGridIndex(position)
    local customGrid = StageAPI.GetCustomGrid(grindex)
    local shouldOverride

    if customGrid and customGrid.GridConfig.OverrideGridSpawns and customGrid.GridEntity and not customGrid.CheckedForOverride then
        local breakstate = customGrid.GridConfig.OverrideGridSpawnsState or StageAPI.DefaultBrokenGridStateByType[customGrid.GridConfig.BaseType]
        if customGrid.GridEntity.State == breakstate then
            shouldOverride = true
        end
    end

    if not shouldOverride then
        local customGrids = StageAPI.GetCustomGrids()
        for _, grid in ipairs(customGrids) do
            if grid.GridConfig.OverrideGridSpawns and not grid.CheckedForOverride then
                local projPosition = (grid.Projectile and grid.Projectile:IsDead() and grid.Projectile.Position) or grid.RecentProjectilePosition
                if projPosition and projPosition:DistanceSquared(position) < 20 ^ 2 then
                    shouldOverride = true
                    customGrid = grid
                end
            end
        end
    end

    if shouldOverride and customGrid and not StageAPI.TemporaryIgnoreSpawnOverride then
        if (id == EntityType.ENTITY_PICKUP and (variant == PickupVariant.PICKUP_COLLECTIBLE or variant == PickupVariant.PICKUP_TAROTCARD or variant == PickupVariant.PICKUP_HEART or variant == PickupVariant.PICKUP_COIN or variant == PickupVariant.PICKUP_TRINKET or variant == PickupVariant.PICKUP_PILL))
        or id == EntityType.ENTITY_SPIDER
        or (id == EntityType.ENTITY_EFFECT and (variant == EffectVariant.FART or variant == EffectVariant.POOF01 or variant == EffectVariant.CREEP_RED or variant == EffectVariant.CREEP_GREEN))
        or id == EntityType.ENTITY_PROJECTILE
        or id == EntityType.ENTITY_STRIDER
        or id == EntityType.ENTITY_SMALL_LEECH
        or id == EntityType.ENTITY_DRIP
        or id == EntityType.ENTITY_HOST
        or id == EntityType.ENTITY_MUSHROOM 
        or id == EntityType.ENTITY_SMALL_MAGGOT then
            if id == EntityType.ENTITY_EFFECT and variant == EffectVariant.FART then
                StageAPI.RecentFarts[customGrid.Position] = 2
                shared.Sfx:Stop(SoundEffect.SOUND_FART)

                for _, player in ipairs(shared.Players) do
                    if position:Distance(player.Position) < FART_RADIUS + player.Size then
                        local hadNoKnockback = player:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
                        if not hadNoKnockback then
                            player:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
                        end
                        player:GetData().__FartPreventHadNoKnockback = hadNoKnockback
                    end
                end
                local closeEnemies = Isaac.FindInRadius(position, FART_RADIUS + 60, EntityPartition.ENEMY)
                for _, npc in ipairs(closeEnemies) do
                    if position:Distance(npc.Position) < FART_RADIUS + npc.Size then
                        local hadNoKnockback = npc:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
                        if not hadNoKnockback then
                            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
                        end
                        npc:GetData().__FartPreventHadNoKnockback = hadNoKnockback
                    end
                end
            end

            local dat = {
                Type = id,
                Variant = variant,
                SubType = subtype,
                Position = position,
                Velocity = velocity,
                Spawner = spawner,
                Seed = seed
            }

            customGrid.BrokenData[#customGrid.BrokenData + 1] = dat
            customGrid.UpdateCheckForOverride = true

            if id == EntityType.ENTITY_EFFECT then
                return {
                    StageAPI.E.DeleteMeEffect.T,
                    StageAPI.E.DeleteMeEffect.V,
                    0,
                    seed
                }
            elseif id == EntityType.ENTITY_PICKUP then
                return {
                    StageAPI.E.DeleteMePickup.T,
                    StageAPI.E.DeleteMePickup.V,
                    0,
                    seed
                }
            elseif id == EntityType.ENTITY_PROJECTILE then
                return {
                    StageAPI.E.DeleteMeProjectile.T,
                    StageAPI.E.DeleteMeProjectile.V,
                    0,
                    seed
                }
            else
                return {
                    StageAPI.E.DeleteMeNPC.T,
                    StageAPI.E.DeleteMeNPC.V,
                    0,
                    seed
                }
            end
        end
    end
end)

---@param e Entity
---@param amount number
---@param flag integer
---@param source? EntityRef
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, e, amount, flag, source)
    if flag == 0 and source and source.Type == 0 and not e:GetData().TrueFart then
        local hasFarts = next(StageAPI.RecentFarts) ~= nil

        if hasFarts then
            e:GetData().Farted = {amount, source}
            return false
        end
    end
end)

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
    local data = player:GetData()

    if data.Farted then
        local stoppedFart
        for fart, timer in pairs(StageAPI.RecentFarts) do
            if fart:Distance(player.Position) < FART_RADIUS + player.Size then
                stoppedFart = true
                break
            end
        end

        if not stoppedFart then
            data.TrueFart = true
            player:TakeDamage(data.Farted[1], 0, EntityRef(player), 0)
            data.TrueFart = nil
        end

        if data.__FartPreventHadNoKnockback == false then
            player:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
        end
        data.__FartPreventHadNoKnockback = nil

        data.Farted = nil
    end
end)

---@param npc EntityNPC
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
    local data = npc:GetData()
    if data.Farted then
        local stoppedFart
        for fart, timer in pairs(StageAPI.RecentFarts) do
            if fart:Distance(npc.Position) < FART_RADIUS + npc.Size then
                stoppedFart = true
                break
            end
        end

        if not stoppedFart then
            data.TrueFart = true
            npc:TakeDamage(data.Farted[1], 0, EntityRef(npc), 0)
            data.TrueFart = nil
        end

        if data.__FartPreventHadNoKnockback == false then
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
        end
        data.__FartPreventHadNoKnockback = nil

        data.Farted = nil
    end

    for fart, timer in pairs(StageAPI.RecentFarts) do
        if npc:HasEntityFlags(EntityFlag.FLAG_POISON) and fart:Distance(npc.Position) < 150 + npc.Size then
            npc:RemoveStatusEffects()
            break
        end
    end
end)

function StageAPI.DeleteEntity(entA, entB)
    local ent
    if entA.Remove then
        ent = entA
    else
        ent = entB
    end

    ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    ent:Remove()
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    if npc.Variant == StageAPI.E.DeleteMeNPC.V then
        StageAPI.DeleteEntity(npc)
    end
end, StageAPI.E.DeleteMeNPC.T)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, StageAPI.DeleteEntity, StageAPI.E.DeleteMeEffect.V)
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, StageAPI.DeleteEntity, StageAPI.E.DeleteMeProjectile.V)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, StageAPI.DeleteEntity, StageAPI.E.DeleteMePickup.V)

StageAPI.PickupChooseRNG = RNG()
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    StageAPI.PickupChooseRNG:SetSeed(shared.Room:GetSpawnSeed(), 0)
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    if not pickup:Exists() then return end
    local card = shared.Game:GetItemPool():GetCard(StageAPI.PickupChooseRNG:Next(), false, true, true)
    local spawned = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, pickup.Position, Vector.Zero, nil)
    spawned:Update() -- get the spawned pickup up to speed with the original
    StageAPI.DeleteEntity(pickup)
end, StageAPI.E.RandomRune.V)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    for fart, timer in pairs(StageAPI.RecentFarts) do
        StageAPI.RecentFarts[fart] = timer - 1
        if timer <= 1 then
            StageAPI.RecentFarts[fart] = nil
        end
    end
end)

function StageAPI.AreRockAltEffectsOverridden()
    if (StageAPI.CurrentStage and StageAPI.CurrentStage.OverridingRockAltEffects) or StageAPI.TemporaryOverrideRockAltEffects then
        local isOverridden = true
        if not StageAPI.TemporaryOverrideRockAltEffects then
            if type(StageAPI.CurrentStage.OverridingRockAltEffects) == "table" then
                isOverridden = StageAPI.IsIn(StageAPI.CurrentStage.OverridingRockAltEffects, StageAPI.GetCurrentRoomType())
            end
        end

        return isOverridden
    end
end

function StageAPI.TemporarilyOverrideRockAltEffects()
    StageAPI.TemporaryOverrideRockAltEffects = true
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    StageAPI.TemporaryOverrideRockAltEffects = nil
    StageAPI.RecentFarts = {}
end)

StageAPI.AddCallback("StageAPI", Callbacks.POST_GRID_UPDATE, 0, function()
    if StageAPI.AreRockAltEffectsOverridden() then
        for i = shared.Room:GetGridWidth(), shared.Room:GetGridSize() do
            local grid = shared.Room:GetGridEntity(i)
            if grid and grid.Desc.Type == GridEntityType.GRID_ROCK_ALT and grid.State ~= 2 then
                local grindex = grid:GetGridIndex()
                local customGrid = StageAPI.GetCustomGrid(grindex)
                if not customGrid then
                    StageAPI.OverridenAltRock:Spawn(grindex, false, false, nil)
                else
                    if customGrid.GridConfig.AllowAltRockOverride then
                        customGrid.PersistentData.OverridenAltRockSpawns = true
                        customGrid.GridConfig.OverrideGridSpawns = true
                    end
                end
            end
        end
    end
end)