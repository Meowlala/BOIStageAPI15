local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

StageAPI.LogMinor("Loading Custom Grid System")

StageAPI.CustomGridTypes = {}
StageAPI.CustomGrid = StageAPI.Class("CustomGrid")

function StageAPI.CustomGridArgPacker(baseType, baseVariant, anm2, animation, frame, variantFrames, offset, overrideGridSpawns, overrideGridSpawnAtState, forceSpawning, noOverrideGridSprite)
    return {
        BaseType = baseType,
        BaseVariant = baseVariant,
        Anm2 = anm2,
        Animation = animation,
        Frame = frame,
        VariantFrames = variantFrames,
        OverrideGridSpawns = overrideGridSpawns,
        OverrideGridSpawnsState = overrideGridSpawnAtState,
        NoOverrideGridSprite = noOverrideGridSprite,
        ForceSpawning = forceSpawning,
        Offset = offset
    }
end

function StageAPI.CustomGrid:Init(name, args, ...)
    if type(args) ~= "table" then
        args = StageAPI.CustomGridArgPacker(args, ...)
    end

    self.Name = name

    for k, v in pairs(args) do
        self[k] = v
    end

    StageAPI.CustomGridTypes[name] = self
end

StageAPI.DefaultBrokenGridStateByType = {
    [GridEntityType.GRID_ROCK]      = 2,
    [GridEntityType.GRID_ROCKB]     = 2,
    [GridEntityType.GRID_ROCKT]     = 2,
    [GridEntityType.GRID_ROCK_SS]   = 2,
    [GridEntityType.GRID_ROCK_BOMB] = 2,
    [GridEntityType.GRID_ROCK_ALT]  = 2,
    [GridEntityType.GRID_SPIDERWEB] = 1,
    [GridEntityType.GRID_LOCK]      = 1,
    [GridEntityType.GRID_TNT]       = 4,
    [GridEntityType.GRID_FIREPLACE] = 4,
    [GridEntityType.GRID_POOP]      = 1000,
}

StageAPI.CustomGrids = {}
function StageAPI.GetRoomCustomGrids(dimension, roomID)
    local customGrids = StageAPI.GetTableIndexedByDimensionRoom(StageAPI.CustomGrids, true, dimension, roomID)
    if not customGrids.Grids then
        customGrids.Grids = {}
    end

    if not customGrids.LastPersistentIndex then
        customGrids.LastPersistentIndex = 0
    end

    return customGrids
end

function StageAPI.CustomGrid:SpawnBaseGrid(grindex, force, respawning)
    if self.BaseType then
        local grid
        if not respawning then
            force = force or self.ForceSpawning
            grid = Isaac.GridSpawn(self.BaseType, self.BaseVariant or 0, shared.Room:GetGridPosition(grindex), force)
        else
            grid = shared.Room:GetGridEntity(grindex)
        end

        if self.Anm2 and grid then
            local sprite = grid:GetSprite()
            sprite:Load(self.Anm2, true)
            if self.VariantFrames or self.Frame then
                local animation = self.Animation or sprite:GetDefaultAnimation()
                if self.VariantFrames then
                    sprite:SetFrame(animation, StageAPI.Random(0, self.VariantFrames))
                else
                    sprite:SetFrame(animation, self.Frame)
                end
            elseif self.Animation then
                sprite:Play(self.Animation, true)
            end

            if self.Offset then
                sprite.Offset = self.Offset
            end
        end

        return grid
    end
end

function StageAPI.CustomGrid:Spawn(grindex, force, respawning, persistentData)
    local grid = StageAPI.CustomGridEntity(self, grindex, force, respawning, persistentData)
    return grid
end

StageAPI.CustomGridEntities = {}
StageAPI.CustomGridEntity = StageAPI.Class("CustomGridEntity")
function StageAPI.CustomGridEntity:Init(gridConfig, index, force, respawning, setPersistData)
    local roomGrids = StageAPI.GetRoomCustomGrids()

    if type(gridConfig) == "number" then
        self.PersistentIndex = gridConfig
        gridConfig = nil
    end

    if not self.PersistentIndex then
        self.PersistentIndex = roomGrids.LastPersistentIndex + 1
        roomGrids.LastPersistentIndex = self.PersistentIndex
    end

    local gridData = roomGrids.Grids[self.PersistentIndex]
    if not gridData then
        gridData = {Name = gridConfig.Name, Index = index, PersistData = {}}
        roomGrids.Grids[self.PersistentIndex] = gridData
    else
        gridConfig = StageAPI.CustomGridTypes[gridData.Name]
    end

    self.GridConfig = gridConfig
    self.PersistentData = gridData.PersistData
    if setPersistData then
        for k, v in pairs(setPersistData) do
            self.PersistentData[k] = v
        end
    end

    self.GridIndex = index
    self.Data = {}

    local grid = gridConfig:SpawnBaseGrid(index, force, respawning)
    self.GridEntity = grid
    if self.GridEntity then
        self.RNG = grid:GetRNG()
    end

    StageAPI.CustomGridEntities[#StageAPI.CustomGridEntities + 1] = self

    self.RoomIndex = StageAPI.GetCurrentRoomID()

    self:CallCallbacks("POST_SPAWN_CUSTOM_GRID", force, respawning)
end

function StageAPI.CustomGridEntity:Update()
    self.RecentlyLifted = false

    if self.Projectile and not self.Projectile:Exists() then
        self.RecentProjectilePosition = self.Projectile.Position
        self.ProjectilePositionTimer = 10
        self.Projectile = nil
    end

    if self.ProjectilePositionTimer then
        self.ProjectilePositionTimer = self.ProjectilePositionTimer - 1
        if self.ProjectilePositionTimer <= 0 then
            self.RecentProjectilePosition = nil
            self.ProjectilePositionTimer = nil
        end
    end

    self.RecentProjectileHelper = false
    if self.ProjectileHelper and not self.ProjectileHelper:Exists() then
        self.RecentProjectileHelper = true
        self.ProjectileHelper = nil
    end

    if self:IsOnGrid() then
        if self.GridConfig.BaseType then
            self.GridEntity = shared.Room:GetGridEntity(self.GridIndex)
            if not self.GridEntity then
                self:Remove(true)
                return
            else
                self.RNG = self.GridEntity:GetRNG()
                if not self.Lifted then
                    local sprite = self.GridEntity:GetSprite()
                    local filename = sprite:GetFilename()
                    if filename == "" and sprite:GetAnimation() == "" then
                        self.RecentlyLifted = true
                        self.Lifted = true
                    elseif self.LastFilename and filename ~= self.LastFilename and self.GridConfig.RemoveOnAnm2Change then
                        self:Remove(true)
                        return
                    else
                        if self.GridConfig.BaseVariant and self.GridEntity.Desc.Variant ~= self.GridConfig.BaseVariant then
                            self:Remove(true)
                            return
                        elseif self.GridEntity.State == StageAPI.DefaultBrokenGridStateByType[self.GridConfig.BaseType] and not self.PersistentData.Destroyed then
                            self.PersistentData.Destroyed = true
                            StageAPI.TemporaryIgnoreSpawnOverride = true
                            self:CallCallbacks("POST_CUSTOM_GRID_DESTROY")
                            StageAPI.TemporaryIgnoreSpawnOverride = false
                        end
                    end
                end
            end
        end

        if self.Lifted and not self.RecentlyLifted then
            self:RemoveFromGrid()
        elseif self.GridConfig.OverrideGridSpawns then
            local grid = self.GridEntity or shared.Room:GetGridEntity(self.GridIndex)
            if grid then
                local overrideState = self.GridConfig.OverrideGridSpawnsState or StageAPI.DefaultBrokenGridStateByType[grid.Desc.Type] or 2
                if grid.State ~= overrideState then
                    StageAPI.SpawnOverriddenGrids[self.GridIndex] = overrideState
                end
            end
        end
    else
        if not self.ProjectileHelper and not self.RecentProjectileHelper and not self.Projectile and not self.RecentProjectilePosition then
            self:Unload()
            return
        end
    end

    self:CallCallbacks("POST_CUSTOM_GRID_UPDATE")

    if self:IsOnGrid() and self.GridConfig.BaseType then
        self.LastFilename = self.GridEntity:GetSprite():GetFilename()
    end

    self.JustBrokenGridSpawns = nil
end

function StageAPI.CustomGridEntity:UpdateProjectile(projectile)
    self.Projectile = projectile
    StageAPI.TemporaryIgnoreSpawnOverride = true
    self:CallCallbacks("POST_CUSTOM_GRID_PROJECTILE_UPDATE", projectile)
    if self.Projectile:IsDead() and not self.PersistentData.Destroyed then
        self.PersistentData.Destroyed = true
        self:CallCallbacks("POST_CUSTOM_GRID_DESTROY", projectile)
    end

    StageAPI.TemporaryIgnoreSpawnOverride = false
end

function StageAPI.CustomGridEntity:UpdateProjectileHelper(projectileHelper)
    self.ProjectileHelper = projectileHelper
    self:CallCallbacks("POST_CUSTOM_GRID_PROJECTILE_HELPER_UPDATE", projectileHelper, projectileHelper.Parent)
end

function StageAPI.CustomGridEntity:CheckPoopGib(effect)
    local sprite = effect:GetSprite()
    local anim, frame = sprite:GetAnimation(), sprite:GetFrame()
    local updated = false
    if effect.Variant == EffectVariant.POOP_EXPLOSION then
        if self.GridConfig.PoopExplosionColor then
            sprite.Color = self.GridConfig.PoopExplosionColor
            updated = true
        end

        if self.GridConfig.PoopExplosionAnm2 then
            sprite:Load(self.GridConfig.PoopGibAnm2, true)
            updated = true
        end

        if self.GridConfig.PoopExplosionSheet then
            sprite:ReplaceSpritesheet(0, self.GridConfig.PoopGibSheet)
            updated = true
        end
    elseif effect.Variant == EffectVariant.POOP_PARTICLE then
        if self.GridConfig.PoopGibColor then
            sprite.Color = self.GridConfig.PoopGibColor
            updated = true
        end

        if self.GridConfig.PoopGibAnm2 then
            sprite:Load(self.GridConfig.PoopGibAnm2, true)
            updated = true
        end

        if self.GridConfig.PoopGibSheet then
            sprite:ReplaceSpritesheet(0, self.GridConfig.PoopGibSheet)
            updated = true
        end
    end

    if updated then
        sprite:LoadGraphics()
        sprite:SetAnimation(anim, false)
        sprite:SetFrame(frame)
    end

    StageAPI.IgnorePoopGibsSpawned = true
    self:CallCallbacks("POST_CUSTOM_GRID_POOP_GIB_SPAWN", effect)
    StageAPI.IgnorePoopGibsSpawned = false
end

function StageAPI.CustomGridEntity:CheckDirtyMind(familiar)
    StageAPI.IgnoreDirtyMindSpawned = true
    self:CallCallbacks("POST_CUSTOM_GRID_DIRTY_MIND_SPAWN", familiar)
    StageAPI.IgnoreDirtyMindSpawned = false
end

function StageAPI.CustomGridEntity:Unload()
    for i, grid in StageAPI.ReverseIterate(StageAPI.CustomGridEntities) do
        if grid.PersistentIndex == self.PersistentIndex then
            table.remove(StageAPI.CustomGridEntities, i)
        end
    end
end

function StageAPI.CustomGridEntity:RemoveFromGrid()
    if self:IsOnGrid() then
        local roomGrids = StageAPI.GetRoomCustomGrids()
        roomGrids.Grids[self.PersistentIndex] = nil
        self.GridEntity = nil
        self.GridIndex = nil
        self.RoomIndex = nil
    end
end

function StageAPI.CustomGridEntity:IsOnGrid()
    return self.RoomIndex ~= nil and self.GridIndex ~= nil
end

function StageAPI.CustomGridEntity:Remove(keepBaseGrid)
    if not keepBaseGrid and self.GridEntity then
        shared.Room:RemoveGridEntity(self.GridIndex, 0, false)
    end

    self:RemoveFromGrid()

    self:Unload()

    self:CallCallbacks("POST_REMOVE_CUSTOM_GRID", keepBaseGrid)
end

function StageAPI.CustomGridEntity:CallCallbacks(callback, ...)
    for _, callback in ipairs(StageAPI.GetCallbacks(callback)) do
        if not callback.Params[1] or callback.Params[1] == self.GridConfig.Name then
            callback.Function(self, ...)
        end
    end
end

function StageAPI.GetCustomGrids(index, name)
    local matches = {}
    for _, customGrid in ipairs(StageAPI.CustomGridEntities) do
        if (not index or index == customGrid.GridIndex) and (not name or name == customGrid.GridConfig.Name) then
            matches[#matches + 1] = customGrid
        end
    end

    return matches
end

function StageAPI.GetLiftedCustomGrids(ignoreMarked, includeRecent)
    local customGrids = StageAPI.GetCustomGrids()
    local lifted = {}
    for _, grid in ipairs(customGrids) do
        local gridEnt = shared.Room:GetGridEntity(grid.GridIndex)
        if gridEnt and (ignoreMarked or (not grid.Lifted or (includeRecent and grid.RecentlyLifted))) then
            local sprite = gridEnt:GetSprite()
            if sprite:GetFilename() == "" and sprite:GetAnimation() == "" then
                lifted[#lifted + 1] = grid
            end
        end
    end

    return lifted
end

function StageAPI.GetClosestLiftedCustomGrid(position, ignoreMarked, includeRecent)
    local liftedGrids = StageAPI.GetLiftedCustomGrids(ignoreMarked, includeRecent)
    local closest, closestDist
    for _, grid in ipairs(liftedGrids) do
        local pos = shared.Room:GetGridPosition(grid.GridIndex)
        local dist = pos:DistanceSquared(position)
        if not closestDist or dist < closestDist then
            closest = grid
            closestDist = dist
        end
    end

    return closest
end

function StageAPI.IsCustomGrid(index, name)
    return #StageAPI.GetCustomGrids(index, name) > 0
end

function StageAPI.GetCustomGrid(index, name)
    return StageAPI.GetCustomGrids(index, name)[1]
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    local currentRoom = StageAPI.GetCurrentRoom()
    if shared.Room:GetFrameCount() <= 0 or (currentRoom and not currentRoom.Loaded) then
        return
    end

    local customGrids = StageAPI.GetCustomGrids()
    for _, customGrid in ipairs(customGrids) do
        customGrid:Update()
    end
end)

-- Poop Gib Handling
StageAPI.IgnorePoopGibsSpawned = false
local function customGridPoopGibs(_, eff)
    if not eff:GetData().StageAPIPoopGibChecked then
        eff:GetData().StageAPIPoopGibChecked = true

        local customGrids = StageAPI.GetCustomGrids()
        local customGrid
        for _, grid in ipairs(customGrids) do
            local gridConfig = grid.GridConfig
            if gridConfig.PoopExplosionColor or gridConfig.PoopExplosionAnm2 or gridConfig.PoopExplosionSheet or gridConfig.PoopGibColor or gridConfig.PoopGibAnm2 or gridConfig.PoopGibSheet or gridConfig.CustomPoopGibs then
                if not grid.Lifted and grid.GridIndex == shared.Room:GetGridIndex(eff.Position) then
                    customGrid = grid
                end

                local projPosition = (grid.Projectile and grid.Projectile:IsDead() and grid.Projectile.Position) or grid.RecentProjectilePosition
                if projPosition and projPosition:DistanceSquared(eff.Position) < 20 ^ 2 then
                    customGrid = grid
                end
            end
        end

        if customGrid and not StageAPI.IgnorePoopGibsSpawned then
            customGrid:CheckPoopGib(eff)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, customGridPoopGibs, EffectVariant.POOP_EXPLOSION)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, customGridPoopGibs, EffectVariant.POOP_PARTICLE)

-- Dirty Mind Dip handling
StageAPI.IgnoreDirtyMindSpawned = false
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
    if not familiar:GetData().StageAPIDirtyMindChecked then
        familiar:GetData().StageAPIDirtyMindChecked = true

        local customGrids = StageAPI.GetCustomGrids()
        local customGrid
        for _, grid in ipairs(customGrids) do
            if not grid.Lifted and grid.GridIndex == shared.Room:GetGridIndex(familiar.Position) then
                customGrid = grid
            end

            local projPosition = (grid.Projectile and grid.Projectile:IsDead() and grid.Projectile.Position) or grid.RecentProjectilePosition
            if projPosition and projPosition:DistanceSquared(familiar.Position) < 20 ^ 2 then
                customGrid = grid
            end
        end

        if customGrid and not StageAPI.IgnoreDirtyMindSpawned then
            customGrid:CheckDirtyMind(familiar)
        end
    end
end, FamiliarVariant.DIP)

-- Custom Grid Projectile Handling
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player)
    local projectileHelpers = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.GRID_ENTITY_PROJECTILE_HELPER, -1)
    local liftedHelper
    for _, helper in ipairs(projectileHelpers) do
        if not helper:GetData().StageAPIBraceletChecked then
            helper:GetData().StageAPIBraceletChecked = true

            if helper.FrameCount == 0 then
                liftedHelper = helper
                break
            end
        end
    end

    if liftedHelper then
        local liftedGrid = StageAPI.GetClosestLiftedCustomGrid(player.Position)
        if liftedGrid then
            liftedHelper:GetData().CustomGrid = liftedGrid
        end
    end
end, CollectibleType.COLLECTIBLE_MOMS_BRACELET)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, entity)
    if entity.Variant ~= EffectVariant.GRID_ENTITY_PROJECTILE_HELPER or shared.Room:GetFrameCount() <= 1 then return end

    local data = entity:GetData()

    if not data.StageAPIProjectileHelperRemoveChecked then
        data.StageAPIProjectileHelperRemoveChecked = true
        if not data.CustomGrid and entity.FrameCount == 0 then
            local liftedGrid = StageAPI.GetClosestLiftedCustomGrid(entity.Position)
            if liftedGrid then
                data.CustomGrid = liftedGrid
            end
        end
    end

    local gridProjectiles = Isaac.FindByType(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_GRID, -1)
    for _, projectile in ipairs(gridProjectiles) do
        if projectile.FrameCount == 0 and not projectile:GetData().StageAPIProjectileHelperRemoveChecked then
            projectile:GetData().StageAPIProjectileHelperRemoveChecked = true
            projectile:GetData().CustomGrid = data.CustomGrid
        end
    end

    local gridTears = Isaac.FindByType(EntityType.ENTITY_TEAR, TearVariant.GRIDENT, -1)
    for _, tear in ipairs(gridTears) do
        if tear.FrameCount == 0 and not tear:GetData().StageAPIProjectileHelperRemoveChecked then
            tear:GetData().StageAPIProjectileHelperRemoveChecked = true
            tear:GetData().CustomGrid = data.CustomGrid
        end
    end
end, EntityType.ENTITY_EFFECT)

local function gridProjectileRemove(_, projectile)
    if projectile.Type == EntityType.ENTITY_TEAR and projectile.Variant ~= TearVariant.GRIDENT then
        return
    elseif projectile.Type == EntityType.ENTITY_PROJECTILE and projectile.Variant ~= ProjectileVariant.PROJECTILE_GRID then
        return
    end

    local projectileHelpers = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.GRID_ENTITY_PROJECTILE_HELPER, -1)
    for _, helper in ipairs(projectileHelpers) do
        if not helper:GetData().StageAPIGridProjectileRemoveChecked then
            helper:GetData().StageAPIGridProjectileRemoveChecked = true

            if helper.FrameCount == 0 then
                helper:GetData().CustomGrid = projectile:GetData().CustomGrid
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, gridProjectileRemove, EntityType.ENTITY_TEAR)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, gridProjectileRemove, EntityType.ENTITY_PROJECTILE)

local function gridProjectileUpdate(_, projectile)
    local data = projectile:GetData()
    if data.CustomGrid then
        data.CustomGrid:UpdateProjectile(projectile)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, gridProjectileUpdate, TearVariant.GRIDENT)
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, gridProjectileUpdate, ProjectileVariant.PROJECTILE_GRID)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    local data = eff:GetData()
    if not data.StageAPIProjectileHelperUpdateChecked then
        data.StageAPIProjectileHelperUpdateChecked = true

        if not data.StageAPIBraceletChecked and not data.StageAPIGridProjectileRemoveChecked then
            local liftedGrid = StageAPI.GetClosestLiftedCustomGrid(eff.Position, nil, true)
            if liftedGrid then
                data.CustomGrid = liftedGrid
            end
        end
    end

    if data.CustomGrid then
        data.CustomGrid:UpdateProjectileHelper(eff)
    end
end, EffectVariant.GRID_ENTITY_PROJECTILE_HELPER)