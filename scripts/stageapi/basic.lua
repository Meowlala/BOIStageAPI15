local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

Isaac.DebugString("[StageAPI] Loading Core Definitions")

-- Log

StageAPI.DebugMinorLog = false

function StageAPI.LogConcat(prefix, ...)
    local str = prefix
    local args = {...}
    for i, arg in ipairs(args) do
        str = str .. tostring(arg)

        if i ~= #args and type(arg) ~= "string" then
            str = str .. " "
        end
    end

    return str
end

function StageAPI.Log(...)
    local str = StageAPI.LogConcat('[StageAPI] ', ...)
    Isaac.ConsoleOutput(str .. '\n')
    Isaac.DebugString(str)
end

function StageAPI.LogErr(...)
    local str = StageAPI.LogConcat('[StageAPI:ERROR] ', ...)
    Isaac.ConsoleOutput(str .. '\n')
    Isaac.DebugString(str)
end

function StageAPI.LogWarn(...)
    local str = StageAPI.LogConcat('[StageAPI:WARNING] ', ...)
    if StageAPI.DebugMinorLog then
        Isaac.ConsoleOutput(str .. "\n")
    end
    Isaac.DebugString(str)
end

function StageAPI.LogMinor(...)
    local str = StageAPI.LogConcat('[StageAPI] ', ...)
    if StageAPI.DebugMinorLog then
        Isaac.ConsoleOutput(str .. "\n")
    end

    Isaac.DebugString(str)
end

function StageAPI.TryGetCallInfo(level)
    level = level or 2
    if debug then
        local info = debug.getinfo(1 + level)
        return tostring(info.short_src) .. "@" .. tostring(info.linedefined)
    else
        return ""
    end
end

-- definitions

---@class EntityDef
---@field Type EntityType
---@field Variant integer
---@field SubType integer

StageAPI.RockTypes = {
    [GridEntityType.GRID_ROCK] = true,
    [GridEntityType.GRID_ROCKB] = true,
    [GridEntityType.GRID_ROCKT] = true,
    [GridEntityType.GRID_ROCK_BOMB] = true,
    [GridEntityType.GRID_ROCK_ALT] = true,
    [GridEntityType.GRID_ROCK_SS] = true,
    [GridEntityType.GRID_PILLAR] = true,
    [GridEntityType.GRID_ROCK_SPIKED] = true,
    [GridEntityType.GRID_ROCK_ALT2] = true,
    [GridEntityType.GRID_ROCK_GOLD] = true,
}

StageAPI.PoopVariant = {
    Normal = 0,
    Red = 1,
    Eternal = 2,
    Golden = 3,
    Rainbow = 4,
    Black = 5,
    White = 6,
    Charming = 11
}

StageAPI.CorrectedGridTypes = {
    [1000]=GridEntityType.GRID_ROCK,
    [1001]=GridEntityType.GRID_ROCK_BOMB,
    [1002]=GridEntityType.GRID_ROCK_ALT,
    [1008]=GridEntityType.GRID_ROCK_ALT2,
    [1010]=GridEntityType.GRID_ROCK_SPIKED,
    [1011]=GridEntityType.GRID_ROCK_GOLD,
    [1300]=GridEntityType.GRID_TNT,
    [1499]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Normal}, -- giant, does not work
    [1498]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.White},
    [1497]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Black},
    [1496]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Golden},
    [1495]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Eternal},
    [1494]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Rainbow},
    [1490]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Red},
    [1500]=GridEntityType.GRID_POOP,
    [1501]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Charming},
    [1900]=GridEntityType.GRID_ROCKB,
    [1901]=GridEntityType.GRID_PILLAR,
    [1930]=GridEntityType.GRID_SPIKES,
    [1931]=GridEntityType.GRID_SPIKES_ONOFF,
    [1940]=GridEntityType.GRID_SPIDERWEB,
    [1999]=GridEntityType.GRID_WALL,
    [3000]=GridEntityType.GRID_PIT,
    [4000]=GridEntityType.GRID_LOCK,
    [4500]=GridEntityType.GRID_PRESSURE_PLATE,
    [5000]=GridEntityType.GRID_STATUE,
    [5001]={Type = GridEntityType.GRID_STATUE, Variant = 1},
    [6100]=GridEntityType.GRID_TELEPORTER,
    [9000]=GridEntityType.GRID_TRAPDOOR,
    [9100]=GridEntityType.GRID_STAIRS,
    [10000]=GridEntityType.GRID_GRAVITY
}

StageAPI.RailGridTypes = {
    [6000] = true,
    [6001] = true
}

StageAPI.MinecartRailVariants = {
    [16] = true,
    [17] = true,
    [32] = true,
    [33] = true
}

StageAPI.ConsoleSpawnedGridTypes = {
    [1009] = true, -- event rock
    [3009] = true, -- event pit
    [3002] = true, -- button rail
    [6000] = true, -- rail
    [6001] = true, -- rail over pit
}

StageAPI.UnsupportedTypes = {
    [970] = true, -- room darkness, water flow, water disabler, lava disabler, quest door
    [969] = true, -- events
}

local EntityNames = {
    MetaEntity = "StageAPIMetaEntity",
    Backdrop = "StageAPIBackdrop",
    StageShadow = "StageAPIStageShadow",
    GenericEffect = "StageAPIGenericEffect",
    FloorEffect = "StageAPIFloorEffect",
    Trapdoor = "StageAPITrapdoor",
    Door = "StageAPIDoor",
    Button = "StageAPIButton",
    DeleteMeEffect = "StageAPIDeleteMeEffect",
    DeleteMeNPC = "StageAPIDeleteMeNPC",
    DeleteMeProjectile = "StageAPIDeleteMeProjectile",
    DeleteMePickup = "StageAPIDeleteMePickup",
    RandomRune = "StageAPIRandomRune"
}

StageAPI.E = {}

for k, v in pairs(EntityNames) do
    StageAPI.E[k] = {
        T = Isaac.GetEntityTypeByName(v),
        V = Isaac.GetEntityVariantByName(v),
        S = 0
    }
end

StageAPI.E.FloorEffectCreep = {
    T = EntityType.ENTITY_EFFECT,
    V = EffectVariant.CREEP_RED,
    S = 12545
}

StageAPI.S = {
    BossIntro = Isaac.GetSoundIdByName("StageAPI Boss Intro")
}

-- music definition functions

StageAPI.NonOverrideMusic = {
    {Music.MUSIC_GAME_OVER, false, true},
    Music.MUSIC_JINGLE_GAME_OVER,
    Music.MUSIC_JINGLE_SECRETROOM_FIND,
    --{Music.MUSIC_JINGLE_NIGHTMARE, true},
    Music.MUSIC_JINGLE_GAME_START,
    Music.MUSIC_JINGLE_BOSS,
    Music.MUSIC_JINGLE_BOSS_OVER,
    Music.MUSIC_JINGLE_BOSS_OVER2,
    Music.MUSIC_JINGLE_DEVILROOM_FIND,
    Music.MUSIC_JINGLE_HOLYROOM_FIND,
    Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_0,
    Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_1,
    Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_2,
    Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_3,

    -- Rep
    Music.MUSIC_JINGLE_BOSS_RUSH_OUTRO,
    Music.MUSIC_JINGLE_BOSS_OVER3,
    Music.MUSIC_JINGLE_MOTHER_OVER,
    Music.MUSIC_JINGLE_DOGMA_OVER,
    Music.MUSIC_JINGLE_BEAST_OVER,
    Music.MUSIC_JINGLE_CHALLENGE_ENTRY,
    Music.MUSIC_JINGLE_CHALLENGE_OUTRO
}

function StageAPI.StopOverridingMusic(music, allowOverrideQueue, neverOverrideQueue)
    if allowOverrideQueue ~= nil or neverOverrideQueue ~= nil then
        StageAPI.NonOverrideMusic[#StageAPI.NonOverrideMusic + 1] = {music, allowOverrideQueue, neverOverrideQueue}
    else
        StageAPI.NonOverrideMusic[#StageAPI.NonOverrideMusic + 1] = music
    end
end

function StageAPI.CanOverrideMusic(music)
    for _, id in ipairs(StageAPI.NonOverrideMusic) do
        if type(id) == "number" then
            if music == id then
                return false
            end
        else
            if music == id[1] then
                return false, id[2], id[3]
            end
        end
    end

    return true
end

-- shared variable setting

if Isaac.GetPlayer(0) then
    shared.Room = shared.Game:GetRoom()
    shared.Level = shared.Game:GetLevel()
    local numPlayers = shared.Game:GetNumPlayers()
    if numPlayers > 0 then
        for i = 1, numPlayers do
            shared.Players[i] = Isaac.GetPlayer(i - 1)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    shared.Players = {}
    for i = 1, shared.Game:GetNumPlayers() do
        shared.Players[i] = Isaac.GetPlayer(i - 1)
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    shared.Level = shared.Game:GetLevel()
    shared.Room = shared.Game:GetRoom()
end)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, shouldSave)
    shared.Players = {}
end)
