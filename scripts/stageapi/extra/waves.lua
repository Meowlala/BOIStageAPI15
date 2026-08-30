local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading Challenge Room / Greed Mode waves")

--[[
- Custom Challenge Waves -

CustomStage:SetChallengeWaves(RoomsList, BossChallengeRoomsList)

Challenge ROOMS must have subtype different than 1 to be normal challenge rooms, subtype 1 to be 
boss challenge rooms (vanilla difference being having an item at the center as a reward.) Challenge rooms with
subtype > 1 will be normal challenge rooms, and the subtype will be used to filter waves, see below.

Challenge WAVES must be rooms with only entities, and no metadata entities, to properly merge into the existing room.

If the challenge room has a non-zero SubType, only challenge waves with a SubType that matches or is zero will be selected.
This allows the editor to design waves that fit each room layout, or some with SubType 0 that fit all.
If a challenge room layout can fit any one set of waves, just use SubType 0. Remember that subtype 1 is used by boss challenge
rooms, so normal challenge wave layouts with subtype 1 will never be used.

- Custom Greed Waves -

CustomStage:SetGreedModeWaves(RoomsList, BossRoomsList, DevilRoomsList)

Greed waves work identically to challenge waves, including matching for subtype.
]]

StageAPI.Challenge = {
    WaveStarting = false,
    WaveChanged = false,
    WaveStartFrame = nil,
    WaveSpawnFrame = nil,
    WaveSubtype = nil,
    ChoosingWave = false,
    ChosenWave = nil,
    ChosenWaveSeed = 1,
    LastGreedWave = 0,
    WaveNumber = 1,
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

if REPENTANCE_PLUS then
    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
        local removeEntity
        if shared.Room:GetType() == RoomType.ROOM_CHALLENGE and not StageAPI.Challenge.WaveStartFrame
        and shared.Room:IsAmbushActive() and not shared.Room:IsAmbushDone() then
            StageAPI.Challenge.WaveStarting = true
            if StageAPI.Challenge.WaveStarting and StageAPI.CurrentStage and StageAPI.CurrentStage.ChallengeWaves then
                removeEntity = true
            end
        else
            removeEntity = checkShouldRemoveGreedEntity()
        end

        if removeEntity then
            effect.Visible = false
        end
    end, EffectVariant.SPAWN_PENTAGRAM)    
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    local removeEntity
    if shared.Room:GetType() == RoomType.ROOM_CHALLENGE and not StageAPI.Challenge.WaveSpawnFrame
    and shared.Room:IsAmbushActive() and not shared.Room:IsAmbushDone() then
        if not (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or npc:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) or npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET))
        and not npc.SpawnerEntity -- only room spawns
        then
            local preventCounting
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity:ToNPC() and entity:CanShutDoors()
                and not (entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or entity:HasEntityFlags(EntityFlag.FLAG_PERSISTENT))
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
    StageAPI.Challenge.WaveStarting = nil
    StageAPI.Challenge.WaveChanged = nil
    StageAPI.Challenge.WaveStartFrame = nil
    StageAPI.Challenge.WaveSpawnFrame = nil
    StageAPI.Challenge.WaveSubtype = nil
    StageAPI.Challenge.WaveNumber = 1
    StageAPI.Challenge.ChosenWave = nil
    StageAPI.Challenge.ChosenWaveSeed = 1
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
---@param layout RoomLayout
---@param roomList RoomsList
---@param seed integer
---@param shape RoomShape
---@param rtype RoomType
---@param requireRoomType boolean
StageAPI.AddCallback("StageAPI", Callbacks.POST_CHECK_VALID_ROOM, 0, function(layout, roomList, seed, shape, rtype, requireRoomType)
    -- Select correct layout (boss/normal) depending on room subtype
    if not StageAPI.Challenge.ChoosingWave 
    and rtype == RoomType.ROOM_CHALLENGE and requireRoomType
    then
        local baseSubtype = shared.Level:GetCurrentRoomDesc().Data.Subtype
        -- boss challenge room
        if baseSubtype == 1 then
            return layout.SubType == 1
        else
            return layout.SubType ~= 1
        end
    end

    -- prevent waves of the wrong subtype from appearing
    if StageAPI.Challenge.WaveSubtype and StageAPI.Challenge.ChoosingWave then
        local isBoss = StageAPI.Challenge.WaveSubtype == 1
        if isBoss then
            -- stageapi uses different room lists for boss challenge waves, so
            -- no need to check for subtype
            return true
        end
        -- Check that the (normal) challenge wave matches the room subtype or 0 (that fits all)
        if not (layout.SubType == 0 or layout.SubType == StageAPI.Challenge.WaveSubtype or StageAPI.Challenge.WaveSubtype == 0) then
            return 0
        end
    end
end)

local function GetChallengeRoomWaveDifficulty()
    if StageAPI.GetCurrentStage() and StageAPI.GetCurrentStage().IgnoreDifficultyRules == true then
        return
    else
        local isHard = shared.Game.Difficulty == Difficulty.DIFFICULTY_HARD
        if StageAPI.Challenge.WaveNumber == 1 then
            if isHard then
                return 5
            else
                return 1
            end
        elseif StageAPI.Challenge.WaveNumber == 2 then
            if isHard then
                return 10
            else
                return 5
            end
        elseif StageAPI.Challenge.WaveNumber == 3 then
            if isHard then
                return 15
            else
                return 10
            end
        end
    end
end

local function SpawnWavePentagrams(wave, seed)
    local spawnEntities = StageAPI.ObtainSpawnObjects(wave, seed or StageAPI.ChallengeWaveRNG:Next(), not shared.Game:IsGreedMode())
    for index, entList in pairs(spawnEntities) do
        for _, entInfo in pairs(entList) do
            local entData = entInfo.Data
            if entData.Type == EntityType.ENTITY_BOMB or (entData.Type >= 10 and entData.Type <= 999) then
                local pentagram = Isaac.Spawn(StageAPI.E.SpawnPentagram.T, StageAPI.E.SpawnPentagram.V, 0, shared.Room:GetGridPosition(index), Vector.Zero, nil)
                if REPENTOGON then
                    local entityConfig = EntityConfig.GetEntity(entData.Type, entData.Variant, entData.SubType)
                    if entityConfig then
                        local pentagramScale = math.min(math.max(entityConfig:GetCollisionRadius() / 16.0, 0.5), 2.0)
                        pentagram.SpriteScale = Vector(pentagramScale, pentagramScale)
                    end
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if REPENTANCE_PLUS then
        effect:GetSprite():Play("Summon", true)
        effect.DepthOffset = -200
    else
        effect:Remove()
    end
end, StageAPI.E.SpawnPentagram.V)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    if effect:GetSprite():IsFinished("Summon") then
        effect:Remove()
    end
end, StageAPI.E.SpawnPentagram.V)

local function SelectExpectedWave(isPreSelecting)
    if StageAPI.CurrentStage then
        local useWaves
        local isGreed
        if shared.Game:IsGreedMode() and StageAPI.CurrentStage.GreedWaves then
            isGreed = true
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
            StageAPI.Challenge.WaveStartFrame = shared.Game:GetFrameCount()
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
            local wave 
            StageAPI.Challenge.ChoosingWave = true
            if isGreed then
                wave = StageAPI.ChooseRoomLayout(useWaves, seed, shared.Room:GetRoomShape(), shared.Room:GetType(), false, false, nil, challengeWaveIDs)
            else
                local difficulty = GetChallengeRoomWaveDifficulty()
                wave = StageAPI.ChooseRoomLayout{
                    RoomList = useWaves,
                    Seed = seed,
                    Shape = shared.Room:GetRoomShape(),
                    RoomType = shared.Room:GetType(),
                    RequireRoomType = false,
                    Doors = nil,
                    IgnoreDoors = false,
                    DisallowIDs = challengeWaveIDs,
                    MinDifficulty = difficulty,
                    MaxDifficulty = difficulty,
                }
            end
            
            StageAPI.Challenge.ChoosingWave = false
            StageAPI.Challenge.ChosenWaveSeed = seed
            if wave then
                if isPreSelecting then
                    SpawnWavePentagrams(wave, seed)
                end
                StageAPI.Challenge.ChosenWave = wave
                if currentRoom then
                    table.insert(currentRoom.Data.ChallengeWaveIDs, wave.StageAPIID)
                end
            end

            StageAPI.Challenge.WaveNumber = StageAPI.Challenge.WaveNumber + 1
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if StageAPI.Challenge.WaveStartFrame and shared.Game:GetFrameCount() > StageAPI.Challenge.WaveStartFrame then
        StageAPI.Challenge.WaveStartFrame = nil
    end
    if StageAPI.Challenge.WaveSpawnFrame and shared.Game:GetFrameCount() > StageAPI.Challenge.WaveSpawnFrame then
        StageAPI.Challenge.WaveSpawnFrame = nil
    end

    if StageAPI.Challenge.WaveStarting then
        StageAPI.Challenge.WaveStarting = false
        if shared.Room:GetType() ~= RoomType.ROOM_CHALLENGE and not shared.Game:IsGreedMode() then
            StageAPI.Challenge.WaveStarting = false
            StageAPI.Challenge.WaveSubtype = nil
            return
        end

        SelectExpectedWave(true)
    end

    if StageAPI.Challenge.WaveChanged then
        StageAPI.Challenge.WaveChanged = false
        if shared.Room:GetType() ~= RoomType.ROOM_CHALLENGE and not shared.Game:IsGreedMode() then
            StageAPI.Challenge.WaveChanged = false
            StageAPI.Challenge.WaveSubtype = nil
            return
        end

        if not StageAPI.Challenge.ChosenWave then
            SelectExpectedWave(false)
        end

        if StageAPI.Challenge.ChosenWave then
            StageAPI.Challenge.WaveSpawnFrame = shared.Game:GetFrameCount()
            local spawnEntities = StageAPI.ObtainSpawnObjects(StageAPI.Challenge.ChosenWave, StageAPI.Challenge.ChosenWaveSeed, not shared.Game:IsGreedMode())
            StageAPI.SpawningChallengeEnemies = true
            local ents_spawned = StageAPI.LoadRoomLayout(nil, {spawnEntities}, false, true, false, true, nil, nil, nil, true)
            for _, ent in pairs(ents_spawned) do
                ent:AddEntityFlags(EntityFlag.FLAG_AMBUSH)
            end
            StageAPI.SpawningChallengeEnemies = false
            StageAPI.Challenge.ChosenWave = nil
            StageAPI.Challenge.WaveSubtype = nil
            SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND)
        end

        if shared.Game:IsGreedMode() then
            StageAPI.CallCallbacks(Callbacks.GREED_WAVE_CHANGED)
        else
            StageAPI.CallCallbacks(Callbacks.CHALLENGE_WAVE_CHANGED)
        end
    end
end)