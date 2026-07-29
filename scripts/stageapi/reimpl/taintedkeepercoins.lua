local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

-- Replicated from a decompilation of the game's actual logic.

function StageAPI.GetNumTaintedKeeperCoinsToSpawn(npc)
    if not npc:IsBoss() then
        return npc:IsChampion() and 2 or 1
    end

    local effectiveStage = shared.Level:GetStage()
    if shared.Level:GetStageType() == STAGETYPE_REPENTANCE or shared.Level:GetStageType() == STAGETYPE_REPENTANCE_B then
        effectiveStage = effectiveStage + 1
    end

    local scaleFactor = effectiveStage * 10.0 + 38.0
    local scaledCoins = math.ceil(npc.MaxHitPoints / scaleFactor)

    return math.min(math.max(1, scaledCoins), 8)
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, npc)
    npc = npc:ToNPC()
    if not npc then return end

    local keeperBExists = false
    for _, player in ipairs(shared.Players) do
        if player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
            keeperBExists = true
            break
        end
    end

    if not keeperBExists then
        return
    end

    local canSpawnNormalCoins = not ((npc.SpawnGridIndex < 0) or (shared.Level:GetCurrentRoomDesc().VisitedCount ~= 1 and not npc:HasEntityFlags(EntityFlag.FLAG_AMBUSH)))

    if canSpawnNormalCoins or npc:HasEntityFlags(EntityFlag.FLAG_NO_DEATH_TRIGGER) then
        -- Don't need to do anything
        return
    end

    local data = npc:GetData()

    if not data.StageAPIEntityListIndex or data.StageAPISpawnedTaintedKeeperCoins then
        -- Only need to handle "room" entities spawned by StageAPI
        return
    end

    data.StageAPISpawnedTaintedKeeperCoins = true

    local numCoins = StageAPI.GetNumTaintedKeeperCoinsToSpawn(npc)

    if REPENTOGON and shared.Level:GetCurrentRoomDesc():GetTaintedKeeperCoinSpawns() < 10 then
        numCoins = numCoins - 1 -- The game will spawn one coin
    end
    local coinTimeout = npc:IsBoss() and 90 or 60
    local rng = npc:GetDropRNG()

    for i = 1, numCoins do
        local speed = (rng:RandomFloat() * 3.0) + 2.0
        local angle = rng:RandomFloat() * math.pi * 2.0
        local velocity = Vector(math.cos(angle) * speed, math.sin(angle) * speed)

        local coin = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, npc.Position, velocity, npc, 0, rng:Next()):ToPickup()
        if coin then
            coin.Timeout = coinTimeout
        end
    end
end)
