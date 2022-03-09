local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

StageAPI.LogMinor("Loading Rock Alt Breaking Override")

StageAPI.SpawnOverriddenGrids = {}
StageAPI.JustBrokenGridSpawns = {}
StageAPI.RecentFarts = {}
StageAPI.LastRockAltCheckedRoom = nil
StageAPI.TemporaryIgnoreSpawnOverride = false
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, id, variant, subtype, position, velocity, spawner, seed)
    if StageAPI.LastRockAltCheckedRoom ~= shared.Level:GetCurrentRoomIndex() then
        StageAPI.LastRockAltCheckedRoom = shared.Level:GetCurrentRoomIndex()
        StageAPI.SpawnOverriddenGrids = {}
    end

    local shouldOverride
    local grindex = shared.Room:GetGridIndex(position)
    if StageAPI.SpawnOverriddenGrids[grindex] then
        local grid = shared.Room:GetGridEntity(grindex)

        local stateCheck
        if type(StageAPI.SpawnOverriddenGrids[grindex]) == "number" then
            stateCheck = StageAPI.SpawnOverriddenGrids[grindex]
        elseif grid then
            stateCheck = StageAPI.DefaultBrokenGridStateByType[grid.Type] or 2
        end

        shouldOverride = not grid or grid.State == stateCheck
    end

    local customGrid
    if not shouldOverride then
        local customGrids = StageAPI.GetCustomGrids()
        for _, grid in ipairs(customGrids) do
            if grid.GridConfig.OverrideGridSpawns then
                local projPosition = (grid.Projectile and grid.Projectile:IsDead() and grid.Projectile.Position) or grid.RecentProjectilePosition
                if projPosition and projPosition:DistanceSquared(position) < 20 ^ 2 then
                    shouldOverride = true
                    customGrid = grid
                end
            end
        end
    end

    if shouldOverride and not StageAPI.TemporaryIgnoreSpawnOverride then
        if (id == EntityType.ENTITY_PICKUP and (variant == PickupVariant.PICKUP_COLLECTIBLE or variant == PickupVariant.PICKUP_TAROTCARD or variant == PickupVariant.PICKUP_HEART or variant == PickupVariant.PICKUP_COIN or variant == PickupVariant.PICKUP_TRINKET or variant == PickupVariant.PICKUP_PILL))
        or id == EntityType.ENTITY_SPIDER
        or (id == EntityType.ENTITY_EFFECT and (variant == EffectVariant.FART or variant == EffectVariant.POOF01 or variant == EffectVariant.CREEP_RED))
        or id == EntityType.ENTITY_PROJECTILE
        or id == EntityType.ENTITY_STRIDER
        or id == EntityType.ENTITY_SMALL_LEECH
        or id == EntityType.ENTITY_DRIP
        or id == EntityType.ENTITY_HOST
        or id == EntityType.ENTITY_MUSHROOM then
            if id == EntityType.ENTITY_EFFECT and variant == EffectVariant.FART then
                StageAPI.RecentFarts[grindex] = 2
                shared.Sfx:Stop(SoundEffect.SOUND_FART)
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

            if not customGrid then
                if not StageAPI.JustBrokenGridSpawns[grindex] then
                    StageAPI.JustBrokenGridSpawns[grindex] = {}
                end

                StageAPI.JustBrokenGridSpawns[grindex][#StageAPI.JustBrokenGridSpawns[grindex] + 1] = dat
            else
                if not customGrid.JustBrokenGridSpawns then
                    customGrid.JustBrokenGridSpawns = {}
                end

                customGrid.JustBrokenGridSpawns[#customGrid.JustBrokenGridSpawns + 1] = dat
            end

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

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, e, amount, flag, source)
    if flag == 0 and source and source.Type == 0 and not e:GetData().TrueFart then
        local hasFarts = next(StageAPI.RecentFarts) ~= nil

        if hasFarts then
            e:GetData().Farted = {amount, source}
            return false
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, npc)
    local data = npc:GetData()
    if data.Farted then
        local stoppedFart
        for fart, timer in pairs(StageAPI.RecentFarts) do
            if shared.Room:GetGridPosition(fart):Distance(npc.Position) < 150 + npc.Size then
                stoppedFart = true
                break
            end
        end

        if not stoppedFart then
            data.TrueFart = true
            npc:TakeDamage(data.Farted[1], 0, EntityRef(npc), 0)
            data.TrueFart = nil
        end

        data.Farted = nil
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
    local data = npc:GetData()
    if data.Farted then
        local stoppedFart
        for fart, timer in pairs(StageAPI.RecentFarts) do
            if shared.Room:GetGridPosition(fart):Distance(npc.Position) < 150 + npc.Size then
                stoppedFart = true
                break
            end
        end

        if not stoppedFart then
            data.TrueFart = true
            npc:TakeDamage(data.Farted[1], 0, EntityRef(npc), 0)
            data.TrueFart = nil
        end

        data.Farted = nil
    end

    for fart, timer in pairs(StageAPI.RecentFarts) do
        if npc:HasEntityFlags(EntityFlag.FLAG_POISON) and shared.Room:GetGridPosition(fart):Distance(npc.Position) < 150 + npc.Size then
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

    for grindex, exists in pairs(StageAPI.SpawnOverriddenGrids) do
        local grid = shared.Room:GetGridEntity(grindex)
        local stateCheck = 2
        if type(exists) == "number" then
            stateCheck = exists
        end

        if not grid or grid.State == stateCheck then
            StageAPI.SpawnOverriddenGrids[grindex] = nil
            StageAPI.CallCallbacks("POST_OVERRIDDEN_GRID_BREAK", true, grindex, grid, StageAPI.JustBrokenGridSpawns[grindex])
        end
    end

    StageAPI.JustBrokenGridSpawns = {}
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
    StageAPI.SpawnOverriddenGrids = {}
    StageAPI.JustBrokenGridSpawns = {}
end)

StageAPI.AddCallback("StageAPI", "POST_GRID_UPDATE", 0, function()
    if StageAPI.AreRockAltEffectsOverridden() then
        for i = shared.Room:GetGridWidth(), shared.Room:GetGridSize() do
            local grid = shared.Room:GetGridEntity(i)
            if not StageAPI.SpawnOverriddenGrids[i] and grid and (grid.Desc.Type == GridEntityType.GRID_ROCK_ALT and grid.State ~= 2) then
                StageAPI.SpawnOverriddenGrids[i] = true
            end
        end
    end
end)