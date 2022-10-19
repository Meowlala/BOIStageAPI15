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

        return nil
    elseif id then
        var, sub = var or 0, sub or 0
        for _, func in ipairs(entities2Functions) do
            local byType = func(Entities2AccessMode.ByType)
            if byType[id] then
                if byType[id][var] then
                    if byType[id][var][sub] then
                        return byType[id][var][sub]
                    else
                        return byType[id][var][0]
                    end
                else
                    return byType[id][0][0]
                end
            end
        end
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
