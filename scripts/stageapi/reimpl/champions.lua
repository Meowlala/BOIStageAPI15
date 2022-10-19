local shared = require("scripts.stageapi.shared")
local game = Game()

function StageAPI.GetChampionChance() --Values taken from Isaac Wiki
    local chance = 0.05
    if game.Difficulty % 2 == 1 then --Hard Mode
        chance = 0.2
    end
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_CHAMPION_BELT) then --Champion Belt
            chance = chance + 0.2
        end
        chance = chance + (0.1 * player:GetTrinketMultiplier(TrinketType.TRINKET_PURPLE_HEART)) --Purple Heart
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
    local config = StageAPI.GetEntityConfig(id, var, sub)
    if config then
        return config.Champion
    else
        return not (StageAPI.CantBeChampions[id] 
        or StageAPI.CantBeChampions[id.." "..var] 
        or StageAPI.CantBeChampions[id.." "..var.." "..sub])
    end
end