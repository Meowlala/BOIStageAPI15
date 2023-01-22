local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading Custom Grid System")

---@type table<string, CustomGrid>
StageAPI.CustomGridTypes = {}

---@class CustomGridArgs
---@field BaseType GridEntityType
---@field BaseVariant integer
---@field Anm2 string
---@field Animation string
---@field Frame integer
---@field VariantFrames integer max number of random frame to choose from
---@field Offset Vector
---@field OverrideGridSpawns boolean
---@field AllowAltRockOverride boolean
---@field OverrideGridSpawnsState integer
---@field ForceSpawning boolean
---@field NoOverrideGridSprite boolean used for GridGfx
---@field SpawnerEntity EntityDef
---@field PoopExplosionColor Color
---@field PoopExplosionAnm2 string
---@field PoopExplosionSheet string
---@field PoopGibColor Color
---@field PoopGibAnm2 string
---@field PoopGibSheet string
---@field RemoveOnAnm2Change boolean

---@param name string
---@param baseType? GridEntityType
---@param baseVariant? integer
---@param anm2? string
---@param animation? string
---@param frame? integer
---@param variantFrames? integer max number of random frame to choose from
---@param offset? Vector
---@param overrideGridSpawns? boolean
---@param overrideGridSpawnAtState? integer
---@param forceSpawning? boolean
---@param noOverrideGridSprite? boolean used for GridGfx
---@return CustomGrid
---@overload fun(name: string, args: CustomGridArgs): CustomGrid
function StageAPI.CustomGrid(name, baseType, baseVariant, anm2, animation, frame, variantFrames, offset, overrideGridSpawns, overrideGridSpawnAtState, forceSpawning, noOverrideGridSprite)
end

---@class CustomGrid : StageAPIClass
---@field BaseType GridEntityType
---@field BaseVariant integer
---@field Anm2 string
---@field Animation string
---@field Frame integer
---@field VariantFrames integer max number of random frame to choose from
---@field Offset Vector
---@field OverrideGridSpawns boolean
---@field AllowAltRockOverride boolean
---@field OverrideGridSpawnsState integer
---@field ForceSpawning boolean
---@field NoOverrideGridSprite boolean used for GridGfx
---@field PoopExplosionColor Color
---@field PoopExplosionAnm2 string
---@field PoopExplosionSheet string
---@field PoopGibColor Color
---@field PoopGibAnm2 string
---@field PoopGibSheet string
---@field RemoveOnAnm2Change boolean
StageAPI.CustomGrid = StageAPI.Class("CustomGrid")
StageAPI.CustomGridSpawnerEntities = {}

function StageAPI.RegisterCustomGridSpawnerEntity(id, var, subtype, customGrid)
    if not StageAPI.CustomGridSpawnerEntities[id] then
        StageAPI.CustomGridSpawnerEntities[id] = {}
    end

    if not var then
        StageAPI.CustomGridSpawnerEntities[id][-1] = customGrid
        return
    elseif not StageAPI.CustomGridSpawnerEntities[id][var] then
        StageAPI.CustomGridSpawnerEntities[id][var] = {}
    end

    StageAPI.CustomGridSpawnerEntities[id][var][subtype or -1] = customGrid
end

function StageAPI.IsCustomGridSpawnerEntity(id, var, subtype)
    return (var and subtype and StageAPI.CustomGridSpawnerEntities[id] and StageAPI.CustomGridSpawnerEntities[id][var] and StageAPI.CustomGridSpawnerEntities[id][var][subtype])
    or (var and StageAPI.CustomGridSpawnerEntities[id] and StageAPI.CustomGridSpawnerEntities[id][var] and StageAPI.CustomGridSpawnerEntities[id][var][-1])
    or (StageAPI.CustomGridSpawnerEntities[id] and StageAPI.CustomGridSpawnerEntities[id][-1])
end

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

    if args.SpawnerEntity then
        StageAPI.RegisterCustomGridSpawnerEntity(args.SpawnerEntity.Type, args.SpawnerEntity.Variant, args.SpawnerEntity.SubType, self)
        args.SpawnerEntity = nil
    end

    for k, v in pairs(args) do
        self[k] = v
    end

    StageAPI.CustomGridTypes[name] = self
end

StageAPI.DefaultBrokenGridStateByType = {
    [GridEntityType.GRID_ROCK]          = 2,
    [GridEntityType.GRID_ROCKB]         = 2,
    [GridEntityType.GRID_ROCKT]         = 2,
    [GridEntityType.GRID_ROCK_SS]       = 2,
    [GridEntityType.GRID_ROCK_BOMB]     = 2,
    [GridEntityType.GRID_ROCK_ALT]      = 2,
    [GridEntityType.GRID_ROCK_SPIKED]   = 2,
    [GridEntityType.GRID_ROCK_ALT2]     = 2,
    [GridEntityType.GRID_ROCK_GOLD]     = 2,
    [GridEntityType.GRID_SPIDERWEB]     = 1,
    [GridEntityType.GRID_LOCK]          = 1,
    [GridEntityType.GRID_TNT]           = 4,
    [GridEntityType.GRID_FIREPLACE]     = 4,
    [GridEntityType.GRID_POOP]          = 1000,
}

---@class CustomGridPersistData
---@field Name string
---@field Index integer
---@field PersistData table

---@type table<integer, table<any, {Grids: CustomGridPersistData[], LastPersistentIndex: integer}>>
StageAPI.CustomGrids = {}

---@param dimension? integer default: current
---@param roomID? integer default: current
---@return {Grids: CustomGridPersistData[], LastPersistentIndex: integer}
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
            if not grid then
                -- Ideally, this would be fixed in LoadGridsFromDataList in RoomHandler, but something there doesn't seem to work properly. This works for now for custom grids.
                shared.Room:SetGridPath(grindex, 0)
                force = force or self.ForceSpawning
                grid = Isaac.GridSpawn(self.BaseType, self.BaseVariant or 0, shared.Room:GetGridPosition(grindex), force)
            end
        end

        if self.Anm2 and grid then
            local sprite = grid:GetSprite()
            sprite:Load(self.Anm2, true)
            if self.VariantFrames or self.Frame then
                local rng = RNG()
                rng:SetSeed(grid.Desc.SpawnSeed, 0)
                local animation = self.Animation or sprite:GetDefaultAnimation()
                if self.VariantFrames then
                    sprite:SetFrame(animation, StageAPI.Random(0, self.VariantFrames, rng))
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

---@type CustomGridEntity[]
StageAPI.CustomGridEntities = {}

---@param gridConfig integer | CustomGrid
---@param index integer
---@param force? boolean
---@param respawning? boolean
---@param setPersistData? table
---@return CustomGridEntity
function StageAPI.CustomGridEntity(gridConfig, index, force, respawning, setPersistData)
end

---@class CustomGridEntity : StageAPIClass
---@field PersistentIndex integer
---@field GridConfig CustomGrid
---@field GridIndex integer
---@field GridEntity GridEntity
---@field RNG RNG
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
        assert(gridConfig, "gridConfig cannot be nil while ")

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
    self.BrokenData = {}
    self.Data = {}

    ---either argument, checked if gridData nil, set if gridData not nil
    ---@diagnostic disable-next-line: need-check-nil
    local grid = gridConfig:SpawnBaseGrid(index, force, respawning)
    self.GridEntity = grid
    if self.GridEntity then
        self.RNG = grid:GetRNG()
        self.Position = self.GridEntity.Position
    else
        self.Position = shared.Room:GetGridPosition(self.GridIndex)
    end

    self.Velocity = Vector.Zero

    StageAPI.CustomGridEntities[#StageAPI.CustomGridEntities + 1] = self

    self.RoomIndex = StageAPI.GetCurrentRoomID()

    self:CallCallbacks(Callbacks.POST_SPAWN_CUSTOM_GRID, force, respawning)
end

function StageAPI.CustomGridEntity:Update()
    self.JustSpawned = false

    self.RecentlyLifted = false

    if self.Projectile and not self.Projectile:Exists() then
        self.RecentProjectilePosition = self.Projectile.Position
        self.ProjectilePositionTimer = 10
        self.Projectile = nil

        if not self.PersistentData.Destroyed then
            self.PersistentData.Destroyed = true
            StageAPI.TemporaryIgnoreSpawnOverride = true
            self:CallCallbacks(Callbacks.POST_CUSTOM_GRID_DESTROY)
            StageAPI.TemporaryIgnoreSpawnOverride = false
        end
    elseif self.ProjectilePositionTimer then
        if self.DoOverridenGridBreakLater then
            StageAPI.CallCallbacks(Callbacks.POST_OVERRIDDEN_ALT_ROCK_BREAK, true, self.Position, self.GridVariant, self.BrokenData, self, self.Projectile)
            self.DoOverridenGridBreakLater = false
        end
    
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

    self.Velocity = Vector.Zero
    if self.Projectile then
        self.Position = self.Projectile.Position
        self.Velocity = self.Projectile.Velocity
    elseif self.RecentProjectilePosition then
        self.Position = self.RecentProjectilePosition
    elseif self.GridEntity then
        self.Position = self.GridEntity.Position
        if self.GridEntity:GetVariant() ~= 1000 then
            self.GridVariant = self.GridEntity:GetVariant()
        end
    elseif self.GridIndex then
        self.Position = shared.Room:GetGridPosition(self.GridIndex)
    end

    if self.UpdateCheckForOverride then
        self.CheckedForOverride = true
        self.UpdateCheckForOverride = false
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
                            self:CallCallbacks(Callbacks.POST_CUSTOM_GRID_DESTROY)
                            StageAPI.TemporaryIgnoreSpawnOverride = false
                        end
                    end
                end
            end
        end

        if self.Lifted and not self.RecentlyLifted then
            self:RemoveFromGrid()
        end
    else
        if not self.ProjectileHelper and not self.RecentProjectileHelper and not self.Projectile and not self.RecentProjectilePosition then
            self:Unload()
            return
        end
    end

    self:CallCallbacks(Callbacks.POST_CUSTOM_GRID_UPDATE)

    if self:IsOnGrid() and self.GridConfig.BaseType then
        self.LastFilename = self.GridEntity:GetSprite():GetFilename()
    end
end

function StageAPI.CustomGridEntity:UpdateProjectile(projectile)
    self.Projectile = projectile
    if self.Projectile.Type == EntityType.ENTITY_TEAR then
        self.HeldByPlayer = false
        self.ThrownByPlayer = true
    end

    StageAPI.TemporaryIgnoreSpawnOverride = true
    self:CallCallbacks(Callbacks.POST_CUSTOM_GRID_PROJECTILE_UPDATE, projectile)
    if self.Projectile:IsDead() and not self.PersistentData.Destroyed then
        self.PersistentData.Destroyed = true
        self:CallCallbacks(Callbacks.POST_CUSTOM_GRID_DESTROY, projectile)
    end

    StageAPI.TemporaryIgnoreSpawnOverride = false
end

function StageAPI.CustomGridEntity:UpdateProjectileHelper(projectileHelper)
    self.ProjectileHelper = projectileHelper
    if self.ProjectileHelper.Parent and self.ProjectileHelper.Parent.Type == EntityType.ENTITY_PLAYER then
        self.HeldByPlayer = true
    end

    self:CallCallbacks(Callbacks.POST_CUSTOM_GRID_PROJECTILE_HELPER_UPDATE, projectileHelper, projectileHelper.Parent)
end

function StageAPI.CustomGridEntity:CheckPoopGib(effect)
    local sprite = effect:GetSprite()
    local anim, frame = sprite:GetAnimation(), sprite:GetFrame()
    local updated = false
    if effect.Variant == EffectVariant.POOP_EXPLOSION then
        if self.GridConfig.PoopExplosionColor then
            effect.Color = self.GridConfig.PoopExplosionColor
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
            effect.Color = self.GridConfig.PoopGibColor
            effect:GetData().StageAPIPoopGibColor = self.GridConfig.PoopGibColor
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
    self:CallCallbacks(Callbacks.POST_CUSTOM_GRID_POOP_GIB_SPAWN, effect)
    StageAPI.IgnorePoopGibsSpawned = false
end

function StageAPI.CustomGridEntity:CheckDirtyMind(familiar)
    StageAPI.IgnoreDirtyMindSpawned = true
    self:CallCallbacks(Callbacks.POST_CUSTOM_GRID_DIRTY_MIND_SPAWN, familiar)
    StageAPI.IgnoreDirtyMindSpawned = false
end

function StageAPI.CustomGridEntity:Unload()
    if not self.HeldByPlayer then
        self.Unloaded = true
        for i, grid in StageAPI.ReverseIterate(StageAPI.CustomGridEntities) do
            if grid.PersistentIndex == self.PersistentIndex then
                table.remove(StageAPI.CustomGridEntities, i)
            end
        end

        self:CallCallbacks(Callbacks.POST_CUSTOM_GRID_UNLOAD)
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

    self:CallCallbacks(Callbacks.POST_REMOVE_CUSTOM_GRID, keepBaseGrid)
end

function StageAPI.CustomGridEntity:Exists()
    return not self.Unloaded
end

function StageAPI.CustomGridEntity:CallCallbacks(callback, ...)
    StageAPI.CallCallbacksWithParams(callback, false, self.GridConfig.Name, self, ...)
end

---@param index? integer
---@param name? string
---@return CustomGridEntity[]
function StageAPI.GetCustomGrids(index, name)
    local matches = {}
    for _, customGrid in ipairs(StageAPI.CustomGridEntities) do
        if (not index or index == customGrid.GridIndex) and (not name or name == customGrid.GridConfig.Name) then
            matches[#matches + 1] = customGrid
        end
    end

    return matches
end

function StageAPI.GetNearestCustomGrid(position, name)
    local nearest
    local dist = 99999
    local grids = StageAPI.GetCustomGrids(nil, name)
    for _, customGrid in ipairs(grids) do
        if customGrid.Position:Distance(position) < dist then
            nearest = customGrid
            dist = customGrid.Position:Distance(position)
        end
    end

    return customGrid
end

function StageAPI.GetLiftedCustomGrids(ignoreMarked, includeRecent)
    local customGrids = StageAPI.GetCustomGrids()
    local lifted = {}
    for _, grid in ipairs(customGrids) do
        if grid:IsOnGrid() then
            local gridEnt = shared.Room:GetGridEntity(grid.GridIndex)
            if gridEnt and (ignoreMarked or (not grid.Lifted or (includeRecent and grid.RecentlyLifted))) then
                local sprite = gridEnt:GetSprite()
                if sprite:GetFilename() == "" and sprite:GetAnimation() == "" then
                    lifted[#lifted + 1] = grid
                end
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

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local data = effect:GetData()
    if not data.StageAPICheckedPoopGibColor then
        if data.StageAPIPoopGibColor then
            effect.Color = data.StageAPIPoopGibColor
        end

        data.StageAPICheckedPoopGibColor = true
    end
end, EffectVariant.POOP_PARTICLE)

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

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
    for _, customGrid in ipairs(StageAPI.GetCustomGrids()) do
        customGrid:Unload()
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, id, variant, subtype, position, velocity, spawner, seed)
    local gridConfig = StageAPI.IsCustomGridSpawnerEntity(id, variant, subtype)
    if gridConfig then
        local room = shared.Room
        local index = room:GetGridIndex(position)
        if #StageAPI.GetCustomGrids(index, gridConfig.Name) == 0 and (room:IsFirstVisit() or room:GetFrameCount() > 0 or (StageAPI.GetCurrentRoom() and StageAPI.GetCurrentRoom().FirstLoad)) then
            local grid = gridConfig:Spawn(index, true, false, {SpawnerEntity = {Type = id, Variant = variant, SubType = subtype}})
            grid.JustSpawned = true
        end

        return {
            StageAPI.E.DeleteMeEffect.T,
            StageAPI.E.DeleteMeEffect.V,
            0,
            seed
        }
    end
end)
