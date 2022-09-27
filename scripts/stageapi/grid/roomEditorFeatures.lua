local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading Editor Features")

local d12Used = false
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    d12Used = true
end, CollectibleType.COLLECTIBLE_D12)

---@param roomMetadata RoomMetadata
---@param outEntities table<integer, EntityDef[]>
---@param outGrids any
---@param rng RNG
StageAPI.AddCallback("StageAPI", Callbacks.POST_PARSE_METADATA, 0, function(roomMetadata, outEntities, outGrids, rng)
    local swapperIndices = {}
    local swappers = roomMetadata:Search({Name = "Swapper"})
    for _, swapper in ipairs(swappers) do
        swapperIndices[swapper.Index] = swapper
    end

    for index, swapper in pairs(swapperIndices) do
        local alreadyInSwap = {}
        local canSwapWith = {}
        local groupedWith = roomMetadata:GroupsWithIndex(index)
        for _, groupID in ipairs(groupedWith) do
            local indices = roomMetadata:IndicesInGroup(groupID)
            for _, index2 in ipairs(indices) do
                if swapperIndices[index2] and not alreadyInSwap[index2] then
                    canSwapWith[#canSwapWith + 1] = index2
                    alreadyInSwap[index2] = true
                end
            end
        end

        if #canSwapWith > 0 then
            local swapWith = canSwapWith[StageAPI.Random(1, #canSwapWith, rng)]
            local swappingEntityList = outEntities[swapWith]
            outEntities[swapWith] = outEntities[index]
            outEntities[index] = swappingEntityList

            local swappingGrid = outGrids[swapWith]
            outGrids[swapWith] = outGrids[index]
            outGrids[index] = swappingGrid

            if swapper.BitValues.NoMetadata ~= 1 then
                local swappingEntityMeta = roomMetadata.IndexMetadata[swapWith]
                roomMetadata.IndexMetadata[swapWith] = roomMetadata.IndexMetadata[index]
                roomMetadata.IndexMetadata[index] = swappingEntityMeta

                local swappedEnts = roomMetadata:Search({Index = swapWith}, roomMetadata.IndexMetadata[index])
                for _, ent in ipairs(swappedEnts) do
                    ent.Index = index
                end

                local swappedEnts2 = roomMetadata:Search({Index = index}, roomMetadata.IndexMetadata[swapWith])
                for _, ent in ipairs(swappedEnts2) do
                    ent.Index = swapWith
                end

                local swappingGroups = roomMetadata:GroupsWithIndex(swapWith)
                local swappingGroups2 = roomMetadata:GroupsWithIndex(index)
                roomMetadata:RemoveIndexFromGroup(swapWith, swappingGroups)
                roomMetadata:AddIndexToGroup(swapWith, swappingGroups2)
                roomMetadata:RemoveIndexFromGroup(index, swappingGroups2)
                roomMetadata:AddIndexToGroup(index, swappingGroups)
            end
        end
    end

    local entityBlockers = roomMetadata:Search({Metadata = {BlockEntities = true}})
    for _, entityBlocker in ipairs(entityBlockers) do
        if outEntities[entityBlocker.Index] and (not entityBlocker.Metadata.NoBlockIfTriggered or not entityBlocker.Triggered) then
            local blocked = {}
            for i, entity in StageAPI.ReverseIterate(outEntities[entityBlocker.Index]) do
                if not StageAPI.IsEntityUnblockable(entity.Type, entity.Variant, entity.SubType) then
                    blocked[#blocked + 1] = entity
                    table.remove(outEntities[entityBlocker.Index], i)
                end
            end

            if #blocked > 0 then
                local blockedEnts = roomMetadata:GetBlockedEntities(entityBlocker.Index, true)
                for _, entity in ipairs(blocked) do
                    blockedEnts[#blockedEnts + 1] = entity
                end
            end

            if #outEntities[entityBlocker.Index] == 0 then
                outEntities[entityBlocker.Index] = nil
            end
        end
    end
end)

---@param currentRoom LevelRoom
---@param firstLoad boolean
StageAPI.AddCallback("StageAPI", Callbacks.POST_ROOM_INIT, 0, function(currentRoom, firstLoad)
    if not currentRoom.PersistentData.BossID then
        local bossIdentifiers = currentRoom.Metadata:Search({Name = "BossIdentifier"})
        for _, bossIdentifier in ipairs(bossIdentifiers) do
            local checkEnts = {}
            local blockedEntities = currentRoom.Metadata:GetBlockedEntities(bossIdentifier.Index)
            if blockedEntities then
                for _, ent in ipairs(blockedEntities) do
                    checkEnts[#checkEnts + 1] = ent
                end
            end

            if currentRoom.SpawnEntities[bossIdentifier.Index] then
                for _, ent in ipairs(currentRoom.SpawnEntities[bossIdentifier.Index]) do
                    checkEnts[#checkEnts + 1] = ent.Data
                end
            end

            local matchingBossID
            for _, ent in ipairs(checkEnts) do
                for bossID, bossData in pairs(StageAPI.Bosses) do
                    if bossData.Entity then
                        if (not bossData.Entity.Type or ent.Type == bossData.Entity.Type)
                        and (not bossData.Entity.Variant or ent.Variant == bossData.Entity.Variant)
                        and (not bossData.Entity.SubType or ent.SubType == bossData.Entity.SubType) then
                            matchingBossID = bossID
                            break
                        end
                    end
                end

                if matchingBossID then
                    break
                end
            end

            if matchingBossID then
                currentRoom.PersistentData.BossID = matchingBossID
                break
            end
        end
    end
end)

StageAPI.CustomButtonGrid = StageAPI.CustomGrid("CustomButton")

---@param currentRoom LevelRoom
---@param firstLoad boolean
StageAPI.AddCallback("StageAPI", Callbacks.POST_ROOM_LOAD, 0, function(currentRoom, firstLoad)
    local loadFeatures = currentRoom.Metadata:Search({Tag = "StageAPILoadEditorFeature"})
    for _, loadFeature in ipairs(loadFeatures) do
        if loadFeature.Name == "ButtonTrigger" then
            if firstLoad then
                StageAPI.CustomButtonGrid:Spawn(loadFeature.Index, nil, false, {
                    Triggered = false
                })
            end
        elseif loadFeature.Name == "SetPlayerPosition" then
            local unclearedOnly = loadFeature.BitValues.UnclearedOnly == 1
            if not unclearedOnly or not currentRoom.IsClear or firstLoad then
                local pos = shared.Room:GetGridPosition(loadFeature.Index)
                pos = pos + Vector(loadFeature.BitValues.OffsetX * 20, loadFeature.BitValues.OffsetY * 20)
                StageAPI.ForcePlayerNewRoomPosition = pos
            end
        elseif loadFeature.Name == "EnteredFromTrigger" then
            local checkPos = StageAPI.ForcePlayerNewRoomPosition
            if not checkPos and StageAPI.ForcePlayerDoorSlot then
                checkPos = shared.Room:GetClampedPosition(shared.Room:GetDoorSlotPosition(StageAPI.ForcePlayerDoorSlot), 16)
            end

            checkPos = checkPos or shared.Players[1].Position

            local triggerPos = shared.Room:GetGridPosition(loadFeature.Index)
            if checkPos:DistanceSquared(triggerPos) < (40 ^ 2) then
                local triggerable = currentRoom.Metadata:Search({
                    Groups = currentRoom.Metadata:GroupsWithIndex(loadFeature.Index),
                    Index = loadFeature.Index,
                    IndicesOrGroups = true,
                    Tag = "Triggerable"
                })

                for _, metaEnt in ipairs(triggerable) do
                    local shouldTrigger = true
                    if metaEnt.Name == "Spawner" then
                        local spawnedEntities = currentRoom.Metadata:GetBlockedEntities(metaEnt.Index)
                        if spawnedEntities and #spawnedEntities > 0 then
                            local hasNPC
                            for _, ent in ipairs(spawnedEntities) do
                                if ent.Type > 9 and ent.Type < 1000 then
                                    hasNPC = true
                                    break
                                end
                            end

                            if hasNPC and currentRoom.IsClear and not currentRoom.WasClearAtStart then
                                shouldTrigger = false
                            end
                        end
                    end

                    metaEnt.Triggered = shouldTrigger
                end
            end
        end
    end
end)

StageAPI.AddCallback("StageAPI", Callbacks.POST_SPAWN_ENTITY, 0, function(ent, entityInfo, entityList, index)
    local currentRoom = StageAPI.GetCurrentRoom()
    if currentRoom and ent:ToPickup() then
        local pickup = ent:ToPickup()

        -- Fix for tainted keeper items getting set to 99 price
        if pickup.ShopItemId == 0 and pickup:IsShopItem()
        and shared.Room:GetType() ~= RoomType.ROOM_SHOP then
            pickup.ShopItemId = -1
        end

        local pickupModifiers = currentRoom.Metadata:Search({Tag = "StageAPIPickupEditorFeature", Index = index})
        for _, metaEntity in ipairs(pickupModifiers) do
            if metaEntity.Name == "ShopItem" then
                local price = metaEntity.BitValues.Price
                if price == 0 then
                    price = PickupPrice.PRICE_FREE
                end

                if currentRoom.FirstLoad then
                    pickup.AutoUpdatePrice = false
                    pickup.Price = price
                end
            elseif metaEntity.Name == "OptionsPickup" then
                local idx = metaEntity.BitValues.OptionsIndex
                pickup.OptionsPickupIndex = idx
            end
        end
    end
end)

StageAPI.AddCallback("StageAPI", Callbacks.POST_SPAWN_CUSTOM_GRID, 0, function(customGrid)
    local index = customGrid.GridIndex
    local persistData = customGrid.PersistentData
    local button = StageAPI.SpawnFloorEffect(shared.Room:GetGridPosition(index), Vector.Zero, nil, "gfx/grid/grid_pressureplate.anm2", false, StageAPI.E.Button.V)
    local sprite = button:GetSprite()
    sprite:ReplaceSpritesheet(0, "gfx/grid/grid_button_output.png")
    sprite:LoadGraphics()

    if persistData.Triggered then
        sprite:Play("On", true)
    else
        sprite:Play("Off", true)
    end

    button:GetData().ButtonIndex = index
    button:GetData().ButtonGridData = persistData
end, "CustomButton")

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, button)
    local sprite, data = button:GetSprite(), button:GetData()

    if data.ButtonGridData.Triggered then
        local anim = sprite:GetAnimation()
        if anim == "Off" then
            sprite:Play("Switched", true)
        elseif sprite:IsFinished() then
            sprite:Play("On", true)
        end
    else
        local pressed
        for _, player in ipairs(shared.Players) do
            if player.Position:DistanceSquared(button.Position) < (20 + player.Size) ^ 2 then
                pressed = true
                break
            end
        end

        if pressed then
            data.ButtonGridData.Triggered = true
            sprite:Play("Switched", true)

            local currentRoom = StageAPI.GetCurrentRoom()
            if currentRoom then
                local triggerable = currentRoom.Metadata:Search({
                    Groups = currentRoom.Metadata:GroupsWithIndex(data.ButtonIndex),
                    Index = data.ButtonIndex,
                    IndicesOrGroups = true,
                    Tag = "Triggerable"
                })

                for _, metaEnt in ipairs(triggerable) do
                    metaEnt.Triggered = true
                end
            end
        end

        sprite:Play("Off", true)
    end
end, StageAPI.E.Button.V)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    local currentRoom = StageAPI.GetCurrentRoom()
    if not currentRoom then
        return
    end

    local width = shared.Room:GetGridWidth()
    local metadataEntities = currentRoom.Metadata:Search({Tag = "StageAPIEditorFeature"})
    for _, metadataEntity in ipairs(metadataEntities) do
        local trigger
        local index = metadataEntity.Index
        if metadataEntity.Name == "RoomClearTrigger" then
            if currentRoom.JustCleared then
                trigger = true
            end
        elseif metadataEntity.Name == "BridgeFailsafe" then
            if shared.Room:GetGridCollision(index) ~= 0 then
                if d12Used then
                    local grid = shared.Room:GetGridEntity(index)
                    grid:ToPit():MakeBridge(grid)
                else
                    local adjacent = {index - 1, index + 1, index - width, index + width}
                    for _, index2 in ipairs(adjacent) do
                        local grid = shared.Room:GetGridEntity(index2)
                        if grid and shared.Room:GetGridCollision(index2) == 0 and (StageAPI.RockTypes[grid.Desc.Type] or grid.Desc.Type == GridEntityType.GRID_POOP) then
                            local pit = shared.Room:GetGridEntity(index)
                            pit:ToPit():MakeBridge(pit)
                            break
                        end
                    end
                end
            end
        elseif metadataEntity.Name == "GridDestroyer" then
            if metadataEntity.Triggered then
                local grid = shared.Room:GetGridEntity(index)
                if grid and shared.Room:GetGridCollision(index) ~= 0 then
                    if StageAPI.RockTypes[grid.Desc.Type] then
                        grid:Destroy()
                    elseif grid.Desc.Type == GridEntityType.GRID_PIT then
                        grid:ToPit():MakeBridge(grid)
                    end
                end

                metadataEntity.Triggered = nil
            end
        elseif metadataEntity.Name == "Detonator" then
            if metadataEntity.RecentlyTriggered then
                metadataEntity.RecentlyTriggered = metadataEntity.RecentlyTriggered - 1
                if metadataEntity.RecentlyTriggered <= 0 then
                    metadataEntity.RecentlyTriggered = nil
                end
            end

            if shared.Room:GetGridCollision(index) ~= 0 then
                local checking = shared.Room:GetGridEntity(index)
                local destroySelf = metadataEntity.Triggered
                if not destroySelf then
                    local adjacent = {index - 1, index + 1, index - width, index + width}
                    local adjDetonators = currentRoom.Metadata:Search({Indices = adjacent, Name = "Detonator"}, metadataEntities)
                    for _, detonator in ipairs(adjDetonators) do
                        if not detonator.RecentlyTriggered and shared.Room:GetGridCollision(detonator.Index) == 0 then
                            local grid = shared.Room:GetGridEntity(detonator.Index)
                            if grid then
                                destroySelf = true
                            end
                        end
                    end
                end

                if destroySelf then
                    if StageAPI.RockTypes[checking.Desc.Type] then
                        checking:Destroy()
                    elseif checking.Desc.Type == GridEntityType.GRID_PIT then
                        checking:ToPit():MakeBridge(checking)
                    end
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, shared.Room:GetGridPosition(index), Vector.Zero, nil)
                    metadataEntity.RecentlyTriggered = 4
                end

                metadataEntity.Triggered = nil
            end
        elseif metadataEntity.Name == "DetonatorTrigger" and not metadataEntity.Triggered then
            if shared.Room:GetGridCollision(index) == 0 then
                if metadataEntity.HadGrid then
                    trigger = true
                    metadataEntity.Triggered = true
                end
            else
                metadataEntity.HadGrid = true
            end
        elseif metadataEntity.Name == "Spawner" then
            if metadataEntity.Triggered then
                local persistData = currentRoom:GetPersistenceData(metadataEntity)
                if not persistData or not persistData.NoTrigger then
                    local blockedEntities = currentRoom.Metadata:GetBlockedEntities(metadataEntity.Index)
                    if blockedEntities and #blockedEntities > 0 then
                        local spawnAll = metadataEntity.BitValues.SpawnAll == 1
                        local toSpawn = {}
                        if spawnAll then
                            toSpawn = blockedEntities
                        else
                            toSpawn[#toSpawn + 1] = blockedEntities[StageAPI.Random(1, #blockedEntities)]

                        end

                        for _, spawn in ipairs(toSpawn) do
                            local ent = Isaac.Spawn(spawn.Type or 20, spawn.Variant or 0, spawn.SubType or 0, shared.Room:GetGridPosition(index), Vector.Zero, nil)
                            StageAPI.CallCallbacks(Callbacks.POST_SPAWN_ENTITY, false, ent, {Data = spawn}, {}, index)
                        end

                        local onlyOnce = metadataEntity.BitValues.SingleActivation == 1
                        if onlyOnce then
                            if not persistData then
                                persistData = currentRoom:GetPersistenceData(metadataEntity, true)
                            end

                            persistData.NoTrigger = true
                        end
                    end
                end

                metadataEntity.Triggered = nil
            end
        end

        if trigger then
            local triggerable = currentRoom.Metadata:Search({
                Groups = currentRoom.Metadata:GroupsWithIndex(metadataEntity.Index),
                Index = metadataEntity.Index,
                IndicesOrGroups = true,
                Tag = "Triggerable"
            })

            for _, metaEnt in ipairs(triggerable) do
                metaEnt.Triggered = true
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_, rng, spawnPos)
    local currentRoom = StageAPI.GetCurrentRoom()
    if currentRoom then
        if currentRoom.Metadata:Has({Name = "CancelClearAward"}) then
            return true
        end
    end
end)
