local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

StageAPI.LogMinor("Loading Challenge Room / Greed Mode waves")

--[[
- Custom Challenge Waves -

CustomStage:SetChallengeWaves(RoomsList, BossChallengeRoomsList)

Challenge waves must be rooms with only entities, and no metadata entities, to properly merge into the existing room.

If the challenge room has a non-zero SubType, only challenge waves with a SubType that matches or is zero will be selected.
This allows the editor to design waves that fit each room layout, or some with SubType 0 that fit all.
If a challenge room layout can fit any one set of waves, just use SubType 0.

- Custom Greed Waves -

CustomStage:SetGreedModeWaves(RoomsList, BossRoomsList, DevilRoomsList)

Greed waves work identically to challenge waves, including matching for subtype.
]]

StageAPI.Challenge = {
    WaveChanged = false,
    WaveSpawnFrame = nil,
    WaveSubtype = nil,
    LastGreedWave = 0
}

local function checkShouldRemoveGreedEntity()
    if shared.Game:IsGreedMode() then
        if shared.Level.GreedModeWave ~= StageAPI.Challenge.LastGreedWave then
            StageAPI.Challenge.LastGreedWave = shared.Level.GreedModeWave
            StageAPI.Challenge.WaveChanged = true
        end

        return StageAPI.Challenge.WaveChanged and StageAPI.CurrentStage and StageAPI.CurrentStage.GreedWaves
    end

    return false
end

local function removeAppearingChallengeEntity(entity)
    entity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    entity.Visible = false
    for _, effect in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, false, false)) do
        if effect.Position.X == entity.Position.X and effect.Position.Y == entity.Position.Y then
            effect:Remove()
        end
    end

    entity:Remove()
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    local removeEntity
    if shared.Room:GetType() == RoomType.ROOM_CHALLENGE and not StageAPI.Challenge.WaveSpawnFrame
    and shared.Room:IsAmbushActive() and not shared.Room:IsAmbushDone() then
        if not (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or npc:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) or npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
            local preventCounting
            for _, entity in ipairs(Isaac.FindInRadius(Vector.Zero, 9999, EntityPartition.ENEMY)) do
                if entity:ToNPC() and entity:CanShutDoors()
                and not (entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or entity:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) or entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET))
                and entity.FrameCount ~= npc.FrameCount then
                    preventCounting = true
                    break
                end
            end

            if not preventCounting then
                StageAPI.Challenge.WaveChanged = true
            end

            if StageAPI.Challenge.WaveChanged and StageAPI.CurrentStage and StageAPI.CurrentStage.ChallengeWaves then
                removeEntity = true
            end
        end
    else
        removeEntity = checkShouldRemoveGreedEntity()
    end

    if removeEntity then
        removeAppearingChallengeEntity(npc)
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, function(_, bomb)
    if checkShouldRemoveGreedEntity() then
        removeAppearingChallengeEntity(bomb)
    end
end)

StageAPI.ChallengeWaveRNG = RNG()
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    StageAPI.Challenge.WaveChanged = nil
    StageAPI.Challenge.WaveSpawnFrame = nil
    StageAPI.Challenge.WaveSubtype = nil
    StageAPI.Challenge.LastGreedWave = shared.Level.GreedModeWave
    StageAPI.ChallengeWaveRNG:SetSeed(shared.Room:GetSpawnSeed(), 0)

    local currentRoom = StageAPI.GetCurrentRoom()
    if currentRoom and currentRoom.Data.ChallengeWaveIDs then
        currentRoom.Data.ChallengeWaveIDs = nil
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    StageAPI.Challenge.LastGreedWave = shared.Level.GreedModeWave
end)

-- prevent waves of the wrong subtype from appearing
StageAPI.AddCallback("StageAPI", "POST_CHECK_VALID_ROOM", 0, function(layout)
    if StageAPI.Challenge.WaveSubtype then
        if not (layout.SubType == 0 or layout.SubType == StageAPI.Challenge.WaveSubtype or StageAPI.Challenge.WaveSubtype == 0) then
            return 0
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if StageAPI.Challenge.WaveSpawnFrame and shared.Game:GetFrameCount() > StageAPI.Challenge.WaveSpawnFrame then
        StageAPI.Challenge.WaveSpawnFrame = nil
    end

    if StageAPI.Challenge.WaveChanged then
        StageAPI.Challenge.WaveChanged = false
        if shared.Room:GetType() ~= RoomType.ROOM_CHALLENGE and not shared.Game:IsGreedMode() then
            StageAPI.Challenge.WaveChanged = false
            StageAPI.Challenge.WaveSubtype = nil
            return
        end

        if StageAPI.CurrentStage then
            local useWaves
            if shared.Game:IsGreedMode() and StageAPI.CurrentStage.GreedWaves then
                useWaves = StageAPI.CurrentStage.GreedWaves.Normal
                if shared.Game.Difficulty == Difficulty.DIFFICULTY_GREED then
                    if shared.Level.GreedModeWave > 8 and shared.Level.GreedModeWave < 11 then
                        useWaves = StageAPI.CurrentStage.GreedWaves.Boss
                    elseif shared.Level.GreedModeWave == 11 then
                        useWaves = StageAPI.CurrentStage.GreedWaves.Devil
                    end
                elseif shared.Game.Difficulty == Difficulty.DIFFICULTY_GREEDIER then
                    if shared.Level.GreedModeWave > 9 and shared.Level.GreedModeWave < 12 then
                        useWaves = StageAPI.CurrentStage.GreedWaves.Boss
                    elseif shared.Level.GreedModeWave == 12 then
                        useWaves = StageAPI.CurrentStage.GreedWaves.Devil
                    end
                end
            elseif shared.Room:GetType() == RoomType.ROOM_CHALLENGE and StageAPI.CurrentStage.ChallengeWaves then
                useWaves = StageAPI.CurrentStage.ChallengeWaves.Normal
                if shared.Level:HasBossChallenge() then
                    useWaves = StageAPI.CurrentStage.ChallengeWaves.Boss
                end
            end

            if useWaves then
                StageAPI.Challenge.WaveSpawnFrame = shared.Game:GetFrameCount()
                local currentRoom = StageAPI.GetCurrentRoom()

                local challengeWaveIDs
                if currentRoom then
                    StageAPI.Challenge.WaveSubtype = currentRoom.Layout.SubType

                    if not currentRoom.Data.ChallengeWaveIDs then
                        currentRoom.Data.ChallengeWaveIDs = {}
                    end

                    challengeWaveIDs = currentRoom.Data.ChallengeWaveIDs
                end

                local seed = StageAPI.ChallengeWaveRNG:Next()
                local wave = StageAPI.ChooseRoomLayout(useWaves, seed, shared.Room:GetRoomShape(), shared.Room:GetType(), false, false, nil, challengeWaveIDs)
                if currentRoom then
                    table.insert(currentRoom.Data.ChallengeWaveIDs, wave.StageAPIID)
                end

                StageAPI.Challenge.WaveSubtype = nil

                local spawnEntities = StageAPI.ObtainSpawnObjects(wave, seed)
                StageAPI.SpawningChallengeEnemies = true
                StageAPI.LoadRoomLayout(nil, {spawnEntities}, false, true, false, true, nil, nil, nil, true)
                StageAPI.SpawningChallengeEnemies = false
            end
        end

        if shared.Game:IsGreedMode() then
            StageAPI.CallCallbacks("GREED_WAVE_CHANGED")
        else
            StageAPI.CallCallbacks("CHALLENGE_WAVE_CHANGED")
        end
    end
end)