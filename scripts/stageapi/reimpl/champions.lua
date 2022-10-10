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

StageAPI.CantBeChampions = {
    [EntityType.ENTITY_FLY] = true,
    [EntityType.ENTITY_POOTER.." "..2] = true, --Tainted Pooter
    [EntityType.ENTITY_SHOPKEEPER] = true, 
    [EntityType.ENTITY_ATTACKFLY] = true, 
    [EntityType.ENTITY_MULLIGAN.." "..3] = true, --Tainted Mulligan
    [EntityType.ENTITY_BOOMFLY.." "..6] = true, --Tainted Boom Fly
    [EntityType.ENTITY_HOPPER.." "..3] = true, --Tainted Hopper
    [EntityType.ENTITY_SPITY.." "..1] = true, --Tainted Spitty
    [EntityType.ENTITY_FIREPLACE] = true,
    [EntityType.ENTITY_MRMAW] = true,
    [EntityType.ENTITY_STONEHEAD] = true,
    [EntityType.ENTITY_POKY] = true,
    [EntityType.ENTITY_SUCKER.." "..5] = true, --Bulb
    [EntityType.ENTITY_SUCKER.." "..6] = true, --Bloodfly
    [EntityType.ENTITY_SUCKER.." "..7] = true, --Tainted Sucker
    [EntityType.ENTITY_EMBRYO] = true, 
    [EntityType.ENTITY_MOTER] = true, 
    [EntityType.ENTITY_SPIDER] = true,
    [EntityType.ENTITY_BUTTLICKER] = true, 
    [EntityType.ENTITY_HANGER] = true, 
    [EntityType.ENTITY_MASK] = true, 
    [EntityType.ENTITY_BIGSPIDER] = true, 
    [EntityType.ENTITY_STONE_EYE] = true, 
    [EntityType.ENTITY_CONSTANT_STONE_SHOOTER] = true, 
    [EntityType.ENTITY_BRIMSTONE_HEAD] = true, 
    [EntityType.ENTITY_DEATHS_HEAD] = true, 
    [EntityType.ENTITY_MOMS_HAND] = true, 
    [EntityType.ENTITY_SWINGER] = true, 
    [EntityType.ENTITY_DIP] = true, 
    [EntityType.ENTITY_WALL_HUGGER] = true, 
    [EntityType.ENTITY_WIZOOB] = true, 
    [EntityType.ENTITY_SQUIRT] = true, 
    [EntityType.ENTITY_RING_OF_FLIES] = true, 
    [EntityType.ENTITY_DINGA] = true, 
    [EntityType.ENTITY_HOMUNCULUS] = true, 
    [EntityType.ENTITY_NERVE_ENDING] = true, 
    [EntityType.ENTITY_GAPING_MAW] = true, 
    [EntityType.ENTITY_BROKEN_GAPING_MAW] = true, 
    [EntityType.ENTITY_GRUB] = true,
    [EntityType.ENTITY_WALL_CREEP.." "..1] = true, --Soy Creep
    [EntityType.ENTITY_WALL_CREEP.." "..2] = true, --Rag Creep
    [EntityType.ENTITY_WALL_CREEP.." "..3] = true, --Tainted Soy Creep
    [EntityType.ENTITY_ROUND_WORM.." "..2] = true, --Tainted Round Worm
    [EntityType.ENTITY_ROUND_WORM.." "..3] = true, --Tainted Tube Worm
    [EntityType.ENTITY_POOP] = true,
    [EntityType.ENTITY_RAGLING.." "..1] = true, --Rag Man's Ragling
    [EntityType.ENTITY_BEGOTTEN] = true,
    [EntityType.ENTITY_DART_FLY] = true,
    [EntityType.ENTITY_SWARM] = true,
    [EntityType.ENTITY_RED_GHOST] = true,
    [EntityType.ENTITY_FLESH_DEATHS_HEAD] = true,
    [EntityType.ENTITY_MOMS_DEAD_HAND] = true,
    [EntityType.ENTITY_PITFALL] = true,
    [EntityType.ENTITY_MOVABLE_TNT] = true,
    [EntityType.ENTITY_ULTRA_COIN] = true,
    [EntityType.ENTITY_ULTRA_DOOR] = true,
    [EntityType.ENTITY_CORN_MINE] = true,
    [EntityType.ENTITY_HUSH_FLY] = true,
    [EntityType.ENTITY_STONEY] = true,
    [EntityType.ENTITY_PORTAL] = true,
    [EntityType.ENTITY_LEPER.." "..1] = true, --Leper Chunk
    [EntityType.ENTITY_LITTLE_HORN.." "..1] = true, --Dark Ball
    [EntityType.ENTITY_QUAKE_GRIMACE] = true,
    [EntityType.ENTITY_BISHOP] = true,
    [EntityType.ENTITY_WILLO] = true,
    [EntityType.ENTITY_BOMB_GRIMACE] = true,
    [EntityType.ENTITY_SMALL_LEECH] = true,
    [EntityType.ENTITY_SUB_HORF.." "..1] = true, --Tainted Sub Horf
    [EntityType.ENTITY_STRIDER] = true,
    [EntityType.ENTITY_FISSURE] = true,
    [EntityType.ENTITY_ROCK_SPIDER] = true,
    [EntityType.ENTITY_FLY_BOMB] = true,
    [EntityType.ENTITY_FACELESS.." "..1] = true, --Tainted Faceless
    [EntityType.ENTITY_MOLE.." "..1] = true, --Tainted Mole
    [EntityType.ENTITY_HENRY] = true,
    [EntityType.ENTITY_WILLO_L2] = true,
    [EntityType.ENTITY_SPIKEBALL] = true,
    [EntityType.ENTITY_SMALL_MAGGOT] = true,
    [EntityType.ENTITY_CHARGER_L2.." "..1] = true, --Elleech
    [EntityType.ENTITY_MOCKULUS] = true,
    [EntityType.ENTITY_ARMYFLY] = true,
    [EntityType.ENTITY_DRIP] = true,
    [EntityType.ENTITY_SPLURT] = true,
    [EntityType.ENTITY_GRUDGE] = true,
    [EntityType.ENTITY_SWARM_SPIDER] = true,
    [EntityType.ENTITY_DUSTY_DEATHS_HEAD] = true,
    [EntityType.ENTITY_SHADY] = true,
    [EntityType.ENTITY_POOFER] = true,
    [EntityType.ENTITY_BALL_AND_CHAIN] = true,
    [EntityType.ENTITY_GENERIC_PROP] = true,
    [EntityType.ENTITY_MINECART] = true,
}   