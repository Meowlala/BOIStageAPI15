local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local getEntities2 = require("scripts.stageapi.reimpl.entities2")

local entities2Functions = {getEntities2}

function StageAPI.AddEntities2Function(func)
    entities2Functions[#entities2Functions + 1] = func
end

local Entities2AccessMode = {
    List = 1,
    ByName = 2,
    ByType = 3
}

function StageAPI.GetEntityConfig(id, var, sub)
    if type(id) == "string" then -- get by name
        for _, func in ipairs(entities2Functions) do
            local byName = func(Entities2AccessMode.ByName)
            if byName[id] then
                return byName[id]
            end
        end

        StageAPI.LogMinor("Could not find config for entity named \""..id.."\"")
        return nil
    elseif id then
        var, sub = var or 0, sub or 0
    
        if StageAPI.IsMetadataEntity(id, var) or StageAPI.IsCustomGridSpawnerEntity(id, var, sub) then
            return nil
        end

        local mostSpecific
        local specificVariant = false
        for _, func in ipairs(entities2Functions) do
            local byType = func(Entities2AccessMode.ByType)
            if byType[id] then
                if byType[id][var] then
                    if byType[id][var][sub] then
                        return byType[id][var][sub]
                    else
                        if byType[id][var][0] then
                            mostSpecific = byType[id][var][0]
                            specificVariant = true
                        else
                            local _, nextVal = next(byType[id][var])
                            if nextVal then
                                mostSpecific = nextVal
                                specificVariant = true
                            end
                        end
                    end
                else
                    if not specificVariant then
                        if byType[id][0] then
                            if byType[id][0][0] then
                                mostSpecific = byType[id][0][0]
                            else
                                local _, nextVal = next(byType[id])
                                if nextVal then
                                    mostSpecific = nextVal
                                end
                            end
                        else
                            local _, nextVal = next(byType[id])
                            if nextVal then
                                if nextVal[0] then
                                    mostSpecific = nextVal[0]
                                else
                                    local _, nextVal2 = next(nextVal)
                                    if nextVal2 then
                                        mostSpecific = nextVal2
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if not mostSpecific then
            StageAPI.LogMinor("Could not find config for entity of ID: "..id.."."..var.."."..sub)
        end
        return mostSpecific
    end
    
    return nil
end

function StageAPI.GetEntityConfigDefaults(id, var, sub)
    local config = StageAPI.GetEntityConfig(id, var, sub)
    if not config then
        return nil
    end

    config.Type = config.Type or 0
    config.Variant = config.Variant or 0
    config.Subtype = config.Subtype or 0
    config.Boss = config.Boss == true
    config.Champion = config.Champion == true
    config.CollisionDamage = config.CollisionDamage or 0
    config.CollisionRadius = config.CollisionRadius or 0
    config.NumGridCollisionPoints = config.NumGridCollisionPoints or 1
    config.ShadowSize = config.ShadowSize or 0
    config.HP = config.HP or 0
    config.StageHP = config.StageHP or 0
    config.Friction = config.Friction or 1
    return config
end

function StageAPI.GetChampionChance()
    local chance = 0.05 --Base chance is 5%
    if shared.Game:GetSeeds():HasSeedEffect(SeedEffect.SEED_ALL_CHAMPIONS) then
        chance = 1.1
    elseif shared.Game:GetLevel():GetStage() == LevelStage.STAGE7 then --The Void sets base chance to 75%
        chance = 0.75
    elseif StageAPI.AnyPlayerHasItem(CollectibleType.COLLECTIBLE_CHAMPION_BELT) then --Champion Belt sets base chance to 20%
        chance = 0.2
    end
    local purpleHearts = 0
    for _, player in pairs(StageAPI.GetPlayers()) do
        purpleHearts = purpleHearts + player:GetTrinketMultiplier(TrinketType.TRINKET_PURPLE_HEART)
    end
    if purpleHearts > 0 then
        chance = chance * purpleHearts * 2 --Purple Heart is a x2 mult per copy
    end 
    return chance
end

StageAPI.CantBeChampions = {}
function StageAPI.AddEnemyToChampionBlacklist(type, var, sub)
    local entry = type
    if var then
        entry = entry.." "..var
        if sub then
            entry = entry.." "..sub
        end
    end
    StageAPI.CantBeChampions[entry] = true
end

function StageAPI.CanBeChampion(id, var, sub)
    if REPENTOGON then
        local config = EntityConfig.GetEntity(id, var, sub)
        if config then
            return config:CanBeChampion()
        else
            return not (StageAPI.CantBeChampions[id] 
            or StageAPI.CantBeChampions[id.." "..var] 
            or StageAPI.CantBeChampions[id.." "..var.." "..sub])
        end
    else
        local config = StageAPI.GetEntityConfig(id, var, sub)
        if config then
            return config.Champion
        else
            return not (StageAPI.CantBeChampions[id] 
            or StageAPI.CantBeChampions[id.." "..var] 
            or StageAPI.CantBeChampions[id.." "..var.." "..sub])
        end
    end
end

function StageAPI.CalculateStageHP(stageHP, stage)
    if not stage then
        local currentStage = StageAPI.GetCurrentStage()
        if currentStage and (currentStage.StageNumber or currentStage.StageHPNumber) then
            stage = currentStage.StageHPNumber or currentStage.StageNumber
        else
            stage = shared.Level:GetStage()
        end
    end

    if stage < LevelStage.STAGE3_1 then
        return stageHP * stage
    else
        return stageHP * stage * 0.8
    end
end

function StageAPI.RecalculateEntityStageHP(entity, config)
    local stageHP 
    if REPENTOGON then
        config = config or EntityConfig.GetEntity(entity.Type, entity.Variant, entity.SubType)
    else
        config = config or StageAPI.GetEntityConfig(entity.Type, entity.Variant, entity.SubType)
    end
    if config then
        if REPENTOGON then
            stageHP = config:GetStageHP()
        else
            stageHP = config.StageHP
        end
    end
    if stageHP then
        local base = StageAPI.CalculateStageHP(stageHP, shared.Level:GetStage())
        local new = StageAPI.CalculateStageHP(stageHP)

        if base ~= new then
            entity.HitPoints = entity.HitPoints + (new - base)
            entity.MaxHitPoints = entity.MaxHitPoints + (new - base)
        end
    end
end