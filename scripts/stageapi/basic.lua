Isaac.DebugString("[StageAPI] Loading Core Definitions")

if not StageAPI then
    StageAPI = {}
end

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
    str = StageAPI.LogConcat('[StageAPI] ', ...)
    Isaac.ConsoleOutput(str .. '\n')
    Isaac.DebugString(str)
end

function StageAPI.LogErr(...)
    str = StageAPI.LogConcat('[StageAPI:ERROR] ', ...)
    Isaac.ConsoleOutput(str .. '\n')
    Isaac.DebugString(str)
end

StageAPI.DebugMinorLog = false
function StageAPI.LogMinor(...)
    str = StageAPI.LogConcat('[StageAPI] ', ...)
    if StageAPI.DebugMinorLog then
        Isaac.ConsoleOutput(str .. "\n")
    end

    Isaac.DebugString(str)
end

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

StageAPI.UnsupportedTypes = {
    [970] = true, -- room darkness, water flow, water disabler, lava disabler, quest door
    [969] = true, -- events
    [1009] = true, -- event rock
    [3009] = true, -- event pit
    [3002] = true, -- button rail
    [6000] = true, -- rail
    [6001] = true, -- rail over pit
}

StageAPI.E = {
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

StageAPI.S = {
    BossIntro = Isaac.GetSoundIdByName("StageAPI Boss Intro")
}

StageAPI.Game = Game()
StageAPI.Players = {}

function StageAPI.TryLoadModData(continued)
    if Isaac.HasModData(mod) and continued then
        local data = Isaac.LoadModData(mod)
        StageAPI.LoadSaveString(data)
    else
        StageAPI.CurrentStage = nil
        StageAPI.LevelRooms = {}
        StageAPI.RoomGrids = {}
        StageAPI.CustomGrids = {}
        StageAPI.LevelMaps = {}
        StageAPI.CurrentLevelMapID = nil
        StageAPI.CurrentLevelMapRoomID = nil
        StageAPI.DefaultLevelMapID = nil
    end
end

function StageAPI.SaveModData()
    Isaac.SaveModData(mod, StageAPI.GetSaveString())
end

if Isaac.GetPlayer(0) then
    StageAPI.Room = StageAPI.Game:GetRoom()
    StageAPI.Level = StageAPI.Game:GetLevel()
    local numPlayers = StageAPI.Game:GetNumPlayers()
    if numPlayers > 0 then
        for i = 1, numPlayers do
            StageAPI.Players[i] = Isaac.GetPlayer(i - 1)
        end
    end
end

StageAPI.ZeroVector = Vector(0, 0)
StageAPI.LastGameSeedLoaded = -1
StageAPI.LoadedModDataSinceLastUpdate = false
StageAPI.RecentlyStartedGame = false

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    StageAPI.Level = StageAPI.Game:GetLevel()
    StageAPI.Room = StageAPI.Game:GetRoom()
    local highestPlayerFrame
    for i = 1, StageAPI.Game:GetNumPlayers() do
        StageAPI.Players[i] = Isaac.GetPlayer(i - 1)
        local frame = StageAPI.Players[i].FrameCount
        if not highestPlayerFrame or frame > highestPlayerFrame then
            highestPlayerFrame = frame
        end
    end

    if highestPlayerFrame < 3 then
        local seed = StageAPI.Game:GetSeeds():GetStartSeed()
        if not StageAPI.LoadedModDataSinceLastUpdate or StageAPI.LastGameSeedLoaded ~= seed then
            StageAPI.RecentlyStartedGame = true
            StageAPI.LoadedModDataSinceLastUpdate = true
            StageAPI.LastGameSeedLoaded = seed
            StageAPI.TryLoadModData(StageAPI.Game:GetFrameCount() > 2)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    StageAPI.LoadedModDataSinceLastUpdate = false
    local numPlayers = StageAPI.Game:GetNumPlayers()
    if numPlayers ~= #StageAPI.Players then
        StageAPI.Players = {}
        for i = 1, numPlayers do
            StageAPI.Players[i] = Isaac.GetPlayer(i - 1)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    StageAPI.Level = StageAPI.Game:GetLevel()
    StageAPI.Room = StageAPI.Game:GetRoom()
end)