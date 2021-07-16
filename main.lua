local mod = RegisterMod("StageAPI", 1)

--[[ FUNCTIONALITY

Basic Features:

Commands:
cstage or customstage <StageName> -- Warps to new stage.
nstage or nextstage -- Warps to next stage.
extraroom <ExtraRoomName> -- Warps to extra room
extraroomexit -- Cleanly exits extra room to previous room.
creseed -- Akin to reseed, but guaranteed to work for and only work for custom stages.

Classes:
StageAPI.Class("Name", AllowMultipleInit) -- Returns a Class object, actually is one itself.

Classes can be constructed simply by calling them with (), i.e,

local myClass = StageAPI.Class("MyClass")
local myClassInst = myClass()

Classes can have a couple of functions, Init, PostInit, and InheritInit.
When called like in the example above, Init and PostInit are called, passing in whatever args.
However, you can keep going deeper, i.e,

local myClassInstCopy = myClassInst()

Which will generate another copy that inherits from myClassInst that inherits from myClass which inherits from StageAPI.Class.
In that case, InheritInit will be called instead of Init and PostInit, unless AllowMultipleInit was passed in to the initial myClass definition.

Classes are used for a majority of StageAPI objects.

Callbacks:
StageAPI.AddCallback(modID, id, priority, function, params...) -- Stores a function and its params in a table indexed by ID and sorted by priority, where low priority is at the start.
StageAPI.GetCallbacks(id) -- Gets a list of callbacks from the table by the ID, sorted by priority.
StageAPI.UnregisterCallbacks(modID) -- Unregisters all mod callbacks, should be used when a mod loads, useful for luamod.

Individual callbacks tables are arranged like so
{
    Priority = integer,
    Function = function,
    Params = {params...},
    ModID = modID
}

StageAPI.CallCallbacks(id, breakOnFirstReturn, params...) -- Calls all callbacks with ID, passing in additional params. If breakOnFirstReturn is defined, breaks and returns the first non-nil return value.

StageAPI callbacks all use string IDs, i.e, AddCallback("POST_CHECK_VALID_ROOM", 1, function, params)

Callback List:
- POST_CHECK_VALID_ROOM(layout, roomList, seed, shape, rtype, requireRoomType)
-- Return false to invalidate a room layout, return integer to specify new weight.

- PRE_SELECT_GRIDENTITY_LIST(GridDataList, spawnIndex)
-- Takes 1 return value. If false, cancels selecting the list. If GridData, selects it to spawn.
-- With no value, picks at random.

- PRE_SELECT_ENTITY_LIST(entityList, spawnIndex, addEntities)
-- Takes 4 return values, AddEntities, EntityList, StillAddRandom, and NoBreak. If the first value is false, cancels selecting the list.
-- AddEntities and EntityList are lists of EntityData tables, described below.
-- Usually StageAPI will pick one entity from the EntityList to add to the AddEntities table at random, but that can be changed with this callback.
-- If StillAddRandom is true, StageAPI will still add a random entity from the entitylist to addentities, alongside ones you returned.

- PRE_SPAWN_ENTITY_LIST(entityList, spawnIndex, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData)
-- Takes 1 return value. If false, cancels spawning the entity list. If a table, uses it as the entity list. Any return value breaks out of future callbacks.
-- Every entity in the final entity list is spawned.
-- Note that this entity list contains EntityInfo tables rather than EntityData, which contain persistent room-specific data. Both detailed below.

- PRE_SPAWN_ENTITY(entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, shouldSpawnEntity)
-- Takes 1 return value. If false, cancels spawning the entity info. If a table, uses it as the entity info. Any return value breaks out of future callbacks.

- PRE_SPAWN_GRID(gridData, gridInformation, entities, gridSpawnRNG)
-- Takes 1 return value. If false, cancels spawning the grid. If a table, uses it as the grid data. Any return value breaks out of future callbacks.

- PRE_ROOM_LAYOUT_CHOOSE(currentRoom, roomsList)
-- Takes 1 return value. If a table, uses it as the current room layout. Otherwise, chooses from the roomslist with seeded RNG. Breaks on first return.
-- Called both on initial room load and when continuing game, before INIT.

- POST_ROOM_INIT(currentRoom, fromSaveData, saveData)
-- Called when a room initializes. Can occur at two times, when a room is initially entered or when a room is loaded from save data. Takes no return values.

- POST_ROOM_LOAD(currentRoom, isFirstLoad, isExtraRoom)
-- Called when a room is loaded. Takes no return value.

- POST_SPAWN_CUSTOM_GRID(spawnIndex, force, reSpawning, grid, persistentData, CustomGrid)
-- Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.

- POST_CUSTOM_GRID_UPDATE(grid, spawnIndex, persistData, CustomGrid, customGridTypeName)
-- Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.

- POST_CUSTOM_GRID_REMOVE(spawnIndex, persistData, CustomGrid, customGridTypeName)
-- Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.

- PRE_TRANSITION_RENDER()
-- Called before the custom room transition would render, for effects that should render before it.

- POST_SPAWN_CUSTOM_DOOR(door, data, sprite, CustomDoor, persistData, index, force, respawning, grid, CustomGrid)
-- Takes CustomDoorName as first callback parameter, and will only run if parameter not supplied or matches current door.

- POST_CUSTOM_DOOR_UPDATE(door, data, sprite, CustomDoor, persistData)
-- Takes CustomDoorName as first callback parameter, and will only run if parameter not supplied or matches current door.

- PRE_BOSS_SELECT(bosses, allowHorseman, rng)
-- If a boss is returned, uses it instead.

- POST_OVERRIDDEN_GRID_BREAK(grindex, grid, justBrokenGridSpawns)
-- Called when an overridden grid reaches its break state and is considered broken. justBrokenGridSpawns contains all deleted spawns from the grid. Breaks on first non-nil return.

- POST_GRID_UPDATE()
-- Calls when the number of grids changes or grids are reprocessed. This is when room grid graphics are changed.

- PRE_UPDATE_GRID_GFX()
-- Allows returning gridgfx to use in place of the stage's.

- PRE_CHANGE_ROOM_GFX(currentRoom)
-- Allows returning roomgfx to use in place of the stage's.

- POST_CHANGE_ROOM_GFX()

- PRE_STAGEAPI_NEW_ROOM()
-- runs before most but not all stageapi room functionality. guaranteed to run before any room loads.

- POST_STAGEAPI_NEW_ROOM_GENERATION(justGenerated, currentRoom)
-- allows returning justGenerated and currentRoom. run after normal room generation but before reloading old rooms.

- POST_STAGEAPI_NEW_ROOM()
-- all loading and processing of new room generation and old room loading is done, but the gfx hasn't changed yet

- PRE_SELECT_NEXT_STAGE(currentstage)
-- return a stage to go to instead of currentstage.NextStage or none.

- PRE_SHADING_RENDER(shadingEntity)
- POST_SHADING_RENDER(shadingEntity)

-- StageAPI Structures:
EntityData {
    Type = integer,
    Variant = integer,
    SubType = integer,
    GridX = integer,
    GridY = integer,
    Index = integer
}

GridData {
    Type = integer,
    Variant = integer,
    GridX = integer,
    GridY = integer,
    Index = integer
}

EntityInfo {
    Data = EntityData,
    PersistentIndex = integer,
    Persistent = boolean,
    PersistenceData = PersistenceData
}

PersistenceData {
    Type = etype,
    Variant = variant,
    SubType = subtype,
    AutoPersists = autoPersists,
    RemoveOnRemove = removeOnRemove,
    RemoveOnDeath = removeOnDeath,
    UpdatePosition = updatePosition,
    StoreCheck = storeCheck
}

PersistenceFunction(EntityData)
    return PersistenceData
end

Backdrop {
    NFloors = {filenames},
    LFloors = {filenames},
    Corners = {filenames},
    Walls = {filenames}
}

BossData {
    Name = string,
    NameTwo = string,
    Portrait = string,
    PortraitTwo = string,
    Weight = integer,
    Horseman = boolean,
    Rooms = RoomsList,
    Shapes = {RoomShapes}
}

Bosses {
    BossDataID,
    ...
}

DoorInfo {
    RequireCurrent = {RoomTypes},
    RequireTarget = {RoomTypes},
    RequireEither = {RoomTypes},
    NotCurrent = {RoomTypes},
    NotTarget = {RoomTypes},
    NotEither = {RoomTypes}
}

VanillaStage {
    NormalStage = true,
    Stage = LevelStage,
    StageType = StageType
}

CustomGridIndexData {
    Name = CustomGridName,
    PersistData = persistData,
    Data = CustomGrid,
    Index = gridIndex
}

GridContainer {
    Grid = GridEntity,
    Type = GridEntityType,
    Desc = GridEntityDesc,
    Index = gridIndex
}

StageOverrideStage {
    OverrideStage = LevelStage.STAGE2_1,
    OverrideStageType = StageType.STAGETYPE_WOTL,
    ReplaceWith = CustomStage
}

Shading = shadingPrefix .. "_RoomShape" .. shadingName

StageAPI Variables:

StageOverride {
    CatacombsOne = StageOverrideStage,
    CatacombsTwo = StageOverrideStage
}

DefaultDoorSpawn = DoorInfo -- where default doors should spawn
SecretDoorSpawn = DoorInfo -- where secret room doors should spawn

StageAPI Objects:

- GridGfx()
-- SetGrid(filename, GridEntityType, variant)
-- SetRocks(filename)
-- SetPits(filename, altpitsfilename, hasExtraFrames) -- Alt Pits are used where water pits would be. HasExtraFrames controls for situations where the base game would not normally tile pits specially
-- OR, with lists of { File, HasExtraFrames }
-- SetPits(filenames, altpitsfilenames) (see utero override)
-- SetBridges(filename)
-- SetDecorations(filename)
-- AddDoors(filename, DoorInfo)
-- SetPayToPlayDoor(filename)

- RoomGfx(Backdrop, GridGfx, shadingName, shadingPrefix)

- RoomsList(name, roomfiles...) -- NAME IS NOT OPTIONAL. USED FOR SAVING / LOADING ROOMS.
-- AddRooms(roomfiles...) -- automatically called on init.

- LevelRoom(layoutName, roomsList, seed, shape, roomType, isExtraRoom, saveData, requireRoomType)
-- PostGetLayout(seed) -- second part of init that is called both when loaded from save and normally, after most other things are initialized. gets spawn ents and grids
-- RemovePersistentIndex(persistentIndex)
-- RemovePersistentEntity(entity)
-- Load(isExtraRoom)
-- SaveGridInformation() -- Save functions only called for extra rooms, usually.
-- SavePersistentEntities()
-- Save()
-- GetSaveData()
-- LoadSaveData(saveData)
-- SetTypeOverride(override)

- CustomStage(name, StageOverrideStage, noSetReplaces) -- replaces defaults to catacombs one if noSetReplaces is not set.
-- NAME IS NOT OPTIONAL. USED TO IDENTIFY STAGE AND FOR SAVING CURRENT STAGE.
-- InheritInit(name, noSetAlias) -- automatically aliases the new stage to the old one, if noSetAlias is not set, meaning that IsStage calls on either will return true if either is active. STILL NEEDS A UNIQUE NAME.
-- SetName(name)
-- SetDisplayName(name)
-- SetReplace(StageOverrideStage)
-- SetNextStage(CustomStage)
-- SetRoomGfx(RoomGfx)
-- SetRooms(RoomsList)
-- SetMusic(musicID, RoomType)
-- SetBossMusic(musicID, clearedMusicID)
-- SetSpots(bossSpot, playerSpot)
-- SetBosses(Bosses)
-- GetPlayingMusic()
-- OverrideRockAltEffects()
-- SetTransitionIcon(icon)
-- IsStage(noAlias)

- CustomGrid(name, GridEntityType, baseVariant, anm2, animation, frame, variantFrames, offset, overrideGridSpawns, overrideGridSpawnAtState, forceSpawning)
-- NAME IS NOT OPTIONAL. USED FOR IDENTIFICATION AFTER SAVING.
-- Spawn(grindex, force, reSpawning, initialPersistData) -- only sets persistData if not already defined.

- CustomDoor(name, anm2, openAnim, closeAnim, openedAnim, closedAnim, noAutoHandling, alwaysOpen)
-- NAME IS NOT OPTIONAL. USED FOR IDENTIFICATION AFTER SAVING.

- Overlay(anm2, velocity, offset, size)
-- SetAlpha(alpha, noCancelFade)
-- Fade(total, time, step) -- Fades from time to total incrementing by step. Use a step of -1 and a time equal to total to fade out.
-- Render(noCenterCorrect)

Various useful tools:
Random(min, max, rng)
WeightedRNG(table, rng, weightKey, preCalculatedWeight)
GotoCustomStage(CustomStage, playTransition) -- also accepts VanillaStage
SpawnCustomTrapdoor(position, goesTo<CustomStage>, anm2, size, alreadyEntering)

AddBossData(id, BossData) -- ID is needed for save / resume.
GetBossData(id)
IsDoorSlotAllowed(slot) -- needed in custom rooms

SetExtraRoom(name, room)
GetExtraRoom(name)
InOrTransitioningToExtraRoom()
TransitioningToOrFromExtraRoom()
TransitionToExtraRoom(name, exitSlot)
TransitionFromExtraRoom(toNormalRoomIndex, exitSlot)
SpawnCustomDoor(slot, leadsToExtraRoomName, leadsToNormalRoomIndex, CustomDoorName, data(at persistData.Data), exitSlot)
SetDoorOpen(open, door)

GetCustomGridIndicesByName(name)
GetCustomGridsByName(name) -- returns list of CustomGridIndexData
GetCustomGrids() -- returns list of CustomGridIndexData
GetCustomDoors(doorDataName) -- returns list of CustomGridIndexData
IsCustomGrid(index, name) -- if name not specified just returns if there is a custom grid at index

InOverriddenStage() -- true if in new stage or in override stage
InOverrideStage() -- true if in override stage
InNewStage() -- true only if inoverriddenstage and not inoverridestage.
GetCurrentStage()
GetCurrentStageDisplayName() -- used for streaks
GetCurrentListIndex()

GetCurrentRoomID() -- returns list index or extra room name
SetCurrentRoom(LevelRoom)
GetCurrentRoom()
GetCurrentRoomType() -- returns TypeOverride, or RoomType, or room:GetType()
GetRooms()

AddEntityPersistenceData(PersistenceData)
AddPersistenceCheck(PersistenceFunction)
CheckPersistence(id, variant, subtype) -- returns PersistenceData
SetRoomFromList(roomsList, roomType, requireRoomType, isExtraRoom, load, seed, shape, fromSaveData) -- full room generation package. Initializes it, sets it, loads it, and returns it.
RemovePersistentEntity(entity) -- mapped directly to LevelRoom function of the same name

ChangeRock(GridContainer)
ChangeDecoration(GridContainer, filename)
ChangePit(GridContainer, filename, bridgefilename, altfilename)
CheckBridge(GridEntity, gridIndex, bridgefilename)
ChangeDoor(GridContainer, DoorInfo, payToPlayFilename)
DoesDoorMatch(GridEntityDoor, DoorSpawn)
ChangeGrid(GridContainer, filename)
ChangeSingleGrid(GridEntity, GridGfx, gridIndex)
ChangeGrids(GridGfx)
ChangeBackdrop(Backdrop)
ChangeShading(name, prefix)
ChangeRoomGfx(RoomGfx)

PlayTextStreak(params)
-- returns params, use as a reference to update Hold, etc
-- text values cannot be changed after init
params = {
    Text = Main text, supports newlines (\n)
    TextOffset = positional offset for main text
    BaseFontScale = scale for main text, vector
    Font = Font used for main text, defaults to upheaval
    LineSpacing = spacing between newlines, defaults to 1

    ExtraText = additional text usually used for item descriptions, unused by stageapi
    ExtraOffset = positional offset for extra text
    ExtraFontScale = scale for extra text, vector
    SmallFont = Font used for extra text, defaults to pftempestasevencondensed (item description font)

    Spritesheet = sprite for the streak bg, defaults to vanilla item streak
    SpriteOffset = positional offset for the streak bg

    Color = text color, used for all text
    RenderPos = Position the streak will be rendered at, defaults to item/new floor streak position
    Hold = set to true to hold streak indefinitely once it reaches default position, set to false when ready to continue
    HoldFrames = number of frames to hold the streak, defaults to 52
}

IsIn(table, value, iterator) -- iterator defaults to ipairs
GetPlayingAnimation(sprite, animationList)
VectorToGrid(x, y, width)
GridToVector(index, width)
GetScreenCenterPosition()
GetScreenBottomRight()
Lerp(first, second, percent)
ReverseIterate() -- in place of ipairs / pairs.
]]

Isaac.DebugString("[StageAPI] Loading Core Definitions")
do -- Core Definitions
    if not StageAPI then
        StageAPI = {}
    end

    if not include then
        include = require
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
        Shading = "StageAPIShading",
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
        BossIntro = Isaac.GetSoundIdByName("StageAPI Boss Intro"),
        TarLoop = Isaac.GetSoundIdByName("StageAPI Tar Loop")
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
            StageAPI.CurrentExtraRoom = nil
            StageAPI.CurrentExtraRoomName = nil
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
            StageAPI.TryLoadModData(StageAPI.Game:GetFrameCount() > 2)
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
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
end

-- local, so needs to be outside of do/end
local localToStageAPIMap = {
    game = "Game",
    room = "Room",
    level = "Level",
    players = "Players",
    zeroVector = "ZeroVector"
}

local sfx = SFXManager()

local oldENV = _ENV
local _ENV = {}

oldENV.setmetatable(_ENV, {
    __index = function(tbl, k)
        if localToStageAPIMap[k] then
            return StageAPI[localToStageAPIMap[k]]
        elseif oldENV[k] then
            return oldENV[k]
        end
    end
})

--local game, room, level, players, zeroVector = StageAPI.Game, StageAPI.Room, StageAPI.Level, StageAPI.Players, StageAPI.ZeroVector

StageAPI.LogMinor("Loading Core Functions")
do -- Core Functions

    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, shouldSave)
        StageAPI.Players = {}
        players = StageAPI.Players

        if shouldSave then
            StageAPI.SaveModData()
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
        StageAPI.SaveModData()
    end)

    StageAPI.RandomRNG = RNG()
    StageAPI.RandomRNG:SetSeed(Random(), 0)
    function StageAPI.Random(a, b, rng)
        rng = rng or StageAPI.RandomRNG
        if a and b then
            -- TODO remove after Rev update
            if b - a < 0 then
                StageAPI.LogErr('Bad Random Range! ' .. a .. ', ' .. b)
                return b - a
            end
            return rng:Next() % (b - a + 1) + a
        elseif a then
            -- TODO remove after Rev update
            if a < 0 then
                StageAPI.LogErr('Bad Random Max! ' .. a)
                return a
            end
            return rng:Next() % (a + 1)
        end
        return rng:Next()
    end

    function StageAPI.RandomFloat(a, b, rng)
        rng = rng or StageAPI.RandomRNG
        local rand = rng:RandomFloat()
        if a and b then
            return (rand * (b - a)) + a
        elseif a then
            return rand * a
        end

        return rand
    end

    function StageAPI.WeightedRNG(args, rng, key, preCalculatedWeight, floatWeights) -- takes tables {{obj, weight}, {"pie", 3}, {555, 0}}
        local weight_value = preCalculatedWeight or 0
        local iterated_weight = 1
        if not preCalculatedWeight then
            for _, potentialObject in ipairs(args) do
                if key then
                    weight_value = weight_value + potentialObject[key]
                else
                    weight_value = weight_value + potentialObject[2]
                end

                if weight_value % 1 ~= 0 then -- if any weight is a float, use float RNG
                    floatWeights = true
                end
            end
        end

        rng = rng or StageAPI.RandomRNG
        local random_chance
        if weight_value % 1 == 0 and not floatWeights then
            random_chance = StageAPI.Random(1, weight_value, rng)
        else
            random_chance = StageAPI.RandomFloat(1, weight_value, rng)
        end

        for i, potentialObject in ipairs(args) do
            if key then
                iterated_weight = iterated_weight + potentialObject[key]
            else
                iterated_weight = iterated_weight + potentialObject[2]
            end

            if iterated_weight > random_chance then
                local ret = potentialObject
                if key then
                    return ret, i
                else
                    return ret[1], i
                end
            end
        end
    end

    StageAPI.Class = {}
    function StageAPI.ClassInit(tbl, ...)
        local inst = {}
        setmetatable(inst, tbl)
        tbl.__index = tbl
        tbl.__call = StageAPI.ClassInit

        if inst.AllowMultipleInit or not inst.Initialized then
            inst.Initialized = true
            if inst.Init then
                inst:Init(...)
            end

            if inst.PostInit then
                inst:PostInit(...)
            end
        else
            if inst.InheritInit then
                inst:InheritInit(...)
            end
        end

        return inst
    end

    function StageAPI.Class:Init(Type, AllowMultipleInit)
        self.Type = Type
        self.AllowMultipleInit = AllowMultipleInit
        self.Initialized = false
    end

    setmetatable(StageAPI.Class, {
        __call = StageAPI.ClassInit
    })

    StageAPI.Callbacks = {}

    local function Reverse_Iterator(t,i)
      i=i-1
      local v=t[i]
      if v==nil then return v end
      return i,v
    end

    function StageAPI.ReverseIterate(t)
        return Reverse_Iterator, t, #t+1
    end

    function StageAPI.AddCallback(modID, id, priority, fn, ...)
        if not StageAPI.Callbacks[id] then
            StageAPI.Callbacks[id] = {}
        end

        local index = 1

        for i, callback in StageAPI.ReverseIterate(StageAPI.Callbacks[id]) do
            if priority > callback.Priority then
                index = i + 1
                break
            end
        end

        table.insert(StageAPI.Callbacks[id], index, {
            Priority = priority,
            Function = fn,
            ModID = modID,
            Params = {...}
        })
    end

    function StageAPI.UnregisterCallbacks(modID)
        for id, callbacks in pairs(StageAPI.Callbacks) do
            for i, callback in StageAPI.ReverseIterate(callbacks) do
                if callback.ModID == modID then
                    table.remove(callbacks, i)
                end
            end
        end
    end

    StageAPI.UnregisterCallbacks("StageAPI")

    function StageAPI.GetCallbacks(id)
        return StageAPI.Callbacks[id] or {}
    end

    function StageAPI.CallCallbacks(id, breakOnFirstReturn, ...)
        for _, callback in ipairs(StageAPI.GetCallbacks(id)) do
            local ret = callback.Function(...)
            if breakOnFirstReturn and ret ~= nil then
                return ret
            end
        end
    end

    function StageAPI.IsIn(tbl, v, fn)
        fn = fn or ipairs
        for k, v2 in fn(tbl) do
            if v2 == v then
                return k or true
            end
        end
    end

    function StageAPI.Copy(tbl)
        local t = {}
        for k, v in pairs(tbl) do
            t[k] = v
        end
        return t
    end

    function StageAPI.DeepCopy(tbl)
        local t = {}
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                t[k] = StageAPI.DeepCopy(v)
            else
                t[k] = v
            end
        end

        return t
    end

    function StageAPI.Merged(...)
        local t = {}
        for _, tbl in ipairs({...}) do
            local orderedIndices = {}
            for i, v in ipairs(tbl) do
                orderedIndices[i] = true
                t[#t + 1] = v
            end

            for k, v in pairs(tbl) do
                if not orderedIndices[k] then
                    t[k] = v
                end
            end
        end

        return t
    end

    function StageAPI.GetPlayingAnimation(sprite, animations)
        for _, anim in ipairs(animations) do
            if sprite:IsPlaying(anim) then
                return anim
            end
        end
    end

    function StageAPI.VectorToGrid(x, y, width)
        width = width or room:GetGridWidth()
        return width + 1 + (x + width * y)
    end

    function StageAPI.GridToVector(index, width)
        width = width or room:GetGridWidth()
        return (index % width) - 1, (math.floor(index / width)) - 1
    end

    function StageAPI.GetScreenBottomRight()
        return room:GetRenderSurfaceTopLeft() * 2 + Vector(442,286)
    end

    function StageAPI.GetScreenCenterPosition()
        return StageAPI.GetScreenBottomRight() / 2
    end

    StageAPI.DefaultScreenSize = Vector(480, 270)
    function StageAPI.GetScreenScale(vec)
        local bottomRight = StageAPI.GetScreenBottomRight()
        if vec then
            return Vector(bottomRight.X / StageAPI.DefaultScreenSize.X, bottomRight.Y / StageAPI.DefaultScreenSize.Y)
        else
            return bottomRight.X / StageAPI.DefaultScreenSize.X, bottomRight.Y / StageAPI.DefaultScreenSize.Y
        end
    end

    function StageAPI.Lerp(first, second, percent)
    	return first * (1 - percent) + second * percent
    end

    function StageAPI.FillBits(count)
        return (1 << count) - 1
    end

    function StageAPI.GetBits(bits, startBit, count)
        bits = bits >> startBit
        bits = bits & StageAPI.FillBits(count)
        return bits
    end

    local TextStreakScales = {
        [0] = Vector(3,0.2),     [1] = Vector(2.6,0.36),
        [2] = Vector(2.2,0.52),  [3] = Vector(1.8,0.68),
        [4] = Vector(1.4,0.84),  [5] = Vector(0.95,1.05),
        [6] = Vector(0.97,1.03), [7] = Vector(0.98,1.02),
        -- frame 8 is the hold frame
        [9] = Vector(0.99,1.03), [10] = Vector(0.98,1.05),
        [11] = Vector(0.96,1.08), [12] = Vector(0.95,1.1),
        [13] = Vector(1.36,0.92), [14] = Vector(1.77,0.74),
        [15] = Vector(2.18,0.56), [16] = Vector(2.59,0.38),
        [17] = Vector(3,0.2)
    }

    local TextStreakPositions = {
        [0] = -800, [1] = -639,
        [2] = -450, [3] = -250,
        [4] = -70,  [5] = 10,
        [6] = 6,    [7] = 3,

        [9] = -5,  [10] = -10,
        [11] = -15, [12] = -20,
        [13] = 144, [14] = 308,
        [15] = 472, [16] = 636,
        [17] =800
    }

    local StreakSprites = {}
    local Streaks = {}

    local streakFont = Font()
    streakFont:Load("font/upheaval.fnt")

    local streakSmallFont = Font()
    streakSmallFont:Load("font/pftempestasevencondensed.fnt")

    local streakDefaultHoldFrames = 52
    local streakDefaultSpritesheet = "stageapi/streak.png"
    local streakDefaultColor = KColor(1,1,1,1,0,0,0)
    local streakDefaultPos = Vector(240, 48)

    local oneVector = Vector(1, 1)
    function StageAPI.PlayTextStreak(text, extratext, extratextOffset, extratextScaleMulti, replaceSpritesheet, spriteOffset, font, smallFont, color)
        local streak
        if type(text) == "table" then
            streak = text
        else
            streak = {
                Text = text,
                ExtraText = extratext,
                Color = color,
                Font = font,
                SpriteOffset = spriteOffset,
                SmallFont = smallFont,
                ExtraFontScale = extratextScaleMulti,
                ExtraOffset = extratextOffset,
                Spritesheet = replaceSpritesheet
            }
        end

        local splitLines = {}
        streak.Text:gsub("([^\n]+)", function(c) table.insert(splitLines, { Text = c }) end)
        streak.Text = splitLines

        streak.Color          = streak.Color          or streakDefaultColor
        streak.Font           = streak.Font           or streakFont
        streak.SmallFont      = streak.SmallFont      or streakSmallFont
        streak.RenderPos      = streak.RenderPos      or streakDefaultPos
        --streak.BaseFontScale  = streak.BaseFontScale  or oneVector
        streak.ExtraFontScale = streak.ExtraFontScale or oneVector
        streak.SpriteOffset   = streak.SpriteOffset   or zeroVector
        streak.TextOffset     = streak.TextOffset     or zeroVector
        streak.ExtraOffset    = streak.ExtraOffset    or zeroVector
        streak.Spritesheet    = streak.Spritesheet    or streakDefaultSpritesheet
        streak.LineSpacing    = streak.LineSpacing    or 1
        streak.Hold           = streak.Hold           or false
        streak.HoldFrames     = streak.HoldFrames     or streakDefaultHoldFrames

        streak.Frame = 0

        for _, line in pairs(streak.Text) do
            line.Width = streak.Font:GetStringWidth(line.Text) / 2
        end

        streak.ExtraWidth = streak.SmallFont:GetStringWidth(streak.ExtraText or "") / 2

        local index = #Streaks + 1
        streak.SpriteIndex = index

        local streakSprite = StreakSprites[index]
        if not streakSprite then -- this system loads as many sprites as it has to play at once
            StreakSprites[index] = {}
            streakSprite = StreakSprites[index]
            streakSprite.Sprite = Sprite()
            streakSprite.Sprite:Load("stageapi/streak.anm2", true)
            streakSprite.Spritesheet = streakDefaultSpritesheet
        end

        if streak.Spritesheet ~= streakSprite.Spritesheet then
            streakSprite.Spritesheet = streak.Spritesheet
            streakSprite.Sprite:ReplaceSpritesheet(0, streak.Spritesheet)
            streakSprite.Sprite:LoadGraphics()
        end

        streakSprite.Sprite.Offset = streak.SpriteOffset
        streakSprite.Sprite:Play("Text", true)

        Streaks[index] = streak

        return streak
    end

    function StageAPI.UpdateTextStreak()
        for index, streakPlaying in StageAPI.ReverseIterate(Streaks) do
            local sprite = StreakSprites[streakPlaying.SpriteIndex].Sprite

            if streakPlaying.Frame == 8 then
                if streakPlaying.Hold then
                    sprite.PlaybackSpeed = 0
                elseif streakPlaying.HoldFrames > 0 then
                    sprite.PlaybackSpeed = 0
                    streakPlaying.HoldFrames = streakPlaying.HoldFrames - 1
                else
                    sprite.PlaybackSpeed = 1
                end
            end

            sprite:Update()

            streakPlaying.Frame = sprite:GetFrame()
            if streakPlaying.Frame >= 17 then
                sprite:Stop()
                table.remove(Streaks, index)
                streakPlaying.Finished = true
            end

            streakPlaying.FontScale = (TextStreakScales[streakPlaying.Frame] or oneVector)
            if streakPlaying.BaseFontScale then
                streakPlaying.FontScale = Vector(streakPlaying.FontScale.X * streakPlaying.BaseFontScale.X, streakPlaying.FontScale.X * streakPlaying.BaseFontScale.Y)
            end

            local screenX = StageAPI.GetScreenCenterPosition().X
            streakPlaying.RenderPos.X = screenX
            for _, line in ipairs(streakPlaying.Text) do
                line.PositionX = (TextStreakPositions[streakPlaying.Frame] or 0) - line.Width * streakPlaying.FontScale.X + screenX + 0.25
            end
            streakPlaying.ExtraPositionX = (TextStreakPositions[streakPlaying.Frame] or 0) - (streakPlaying.ExtraWidth / 2) * streakPlaying.FontScale.X + screenX + 0.25

            streakPlaying.Updated = true
        end
    end

    function StageAPI.RenderTextStreak()
        for index, streakPlaying in StageAPI.ReverseIterate(Streaks) do
            if streakPlaying.Updated then
                local sprite = StreakSprites[streakPlaying.SpriteIndex].Sprite
                sprite:Render(streakPlaying.RenderPos, zeroVector, zeroVector)

                local height = streakPlaying.Font:GetLineHeight() * streakPlaying.LineSpacing * streakPlaying.FontScale.Y
                for i, line in ipairs(streakPlaying.Text) do
                    streakPlaying.Font:DrawStringScaled(line.Text,
                                                        line.PositionX + streakPlaying.TextOffset.X,
                                                        streakPlaying.RenderPos.Y - 9 + (i - 1) * height  + streakPlaying.TextOffset.Y,
                                                        streakPlaying.FontScale.X, streakPlaying.FontScale.Y,
                                                        streakPlaying.Color, 0, true)
                end
                if streakPlaying.ExtraText then
                    streakPlaying.SmallFont:DrawStringScaled(streakPlaying.ExtraText, streakPlaying.ExtraPositionX + streakPlaying.ExtraOffset.X, (streakPlaying.RenderPos.Y - 9) + streakPlaying.ExtraOffset.Y, streakPlaying.FontScale.X * streakPlaying.ExtraFontScale.X, 1 * streakPlaying.ExtraFontScale.Y, streakPlaying.Color, 0, true)
                end
            end
        end
    end

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, StageAPI.UpdateTextStreak)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, StageAPI.RenderTextStreak)

    for k, v in pairs(StageAPI.E) do
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

    StageAPI.E.FloorEffectWaterCreep = {
        T = EntityType.ENTITY_EFFECT,
        V = EffectVariant.COLOSTOMIA_PUDDLE,
        S = 12545
    }

    function StageAPI.SpawnFloorEffect(pos, velocity, spawner, anm2, loadGraphics, variant, aboveWater)
        local creep = StageAPI.E.FloorEffectCreep
        if aboveWater then
            creep = StageAPI.E.FloorEffectWaterCreep
        end

        local eff = Isaac.Spawn(creep.T, creep.V, creep.S, pos or zeroVector, velocity or zeroVector, spawner)

        if aboveWater then
            eff.CollisionDamage = 0
            eff:ToEffect().Timeout = 0
        else
            eff.Variant = variant or StageAPI.E.FloorEffect.V
        end

        if anm2 then
            eff:GetSprite():Load(anm2, loadGraphics)
        end

        return eff
    end
end

StageAPI.LogMinor("Loading Overlay System")
do -- Overlays
    StageAPI.DebugTiling = false
    function StageAPI.RenderSpriteTiled(sprite, position, size, centerCorrect)
        local screenBottomRight = StageAPI.GetScreenBottomRight()
        local screenFitX = screenBottomRight.X / size.X
        local screenFitY = screenBottomRight.Y / size.Y
        local timesRendered = 0
        for x = -1, math.ceil(screenFitX) do
            for y = -1, math.ceil(screenFitY) do
                local pos = position + Vector(size.X * x, size.Y * y):Rotated(sprite.Rotation)
                if centerCorrect then
                    pos = pos + Vector(
                        size.X * x,
                        size.Y * y
                    ):Rotated(sprite.Rotation)
                end

                sprite:Render(pos, zeroVector, zeroVector)
                if StageAPI.DebugTiling then
                    timesRendered = timesRendered + 1
                    Isaac.RenderText("RenderPoint (" .. tostring(timesRendered) .. "): " .. tostring(x) .. ", " .. tostring(y), pos.X, pos.Y, 255, 0, 0, 1)
                end
            end
        end
    end

    StageAPI.OverlayDefaultSize = Vector(512, 512)
    StageAPI.Overlay = StageAPI.Class("Overlay")
    function StageAPI.Overlay:Init(file, velocity, offset, size, alpha)
        self.Sprite = Sprite()
        self.Sprite:Load(file, true)
        self.Sprite:Play("Idle", true)
        self.Position = zeroVector
        self.Velocity = velocity or zeroVector
        self.Offset = offset or zeroVector
        self.Size = size or StageAPI.OverlayDefaultSize
        if alpha then
            self:SetAlpha(alpha, true)
        end
    end

    function StageAPI.Overlay:SetAlpha(alpha, noCancelFade)
        local sprite = self.Sprite
        self.Alpha = alpha
        sprite.Color = Color(sprite.Color.R, sprite.Color.G, sprite.Color.B, alpha, sprite.Color.RO, sprite.Color.GO, sprite.Color.BO)
        if not noCancelFade then
            self.Fading = false
            self.FadingFinished = nil
            self.FadeTime = nil
            self.FadeTotal = nil
            self.FadeStep = nil
        end
    end

    function StageAPI.Overlay:Fade(total, time, step) -- use a step of -1 to fade out
        step = step or 1
        self.FadeTotal = total
        self.FadeTime = time
        self.FadeStep = step
        self.Fading = true
        self.FadingFinished = false
    end

    function StageAPI.Overlay:Update()
        if self.Velocity then
            self.Position = self.Position + self.Velocity

            self.Position = self.Position:Rotated(-self.Sprite.Rotation)

            if self.Position.X >= self.Size.X then
                self.Position = Vector(self.Position.X - self.Size.X, self.Position.Y)
            end

            if self.Position.Y >= self.Size.Y then
                self.Position = Vector(self.Position.X, self.Position.Y - self.Size.Y)
            end

            if self.Position.X < 0 then
                self.Position = Vector(self.Position.X + self.Size.X, self.Position.Y)
            end

            if self.Position.Y < 0 then
                self.Position = Vector(self.Position.X, self.Position.Y + self.Size.Y)
            end

            self.Position = self.Position:Rotated(self.Sprite.Rotation)
        end
    end

    function StageAPI.Overlay:Render(noCenterCorrect, additionalOffset, noUpdate)
        local centerCorrect = not noCenterCorrect
        if self.Fading and self.FadeTime and self.FadeTotal and self.FadeStep then
            self.FadeTime = self.FadeTime + self.FadeStep
            if self.FadeTime < 0 then
                self.FadeTime = 0
                self.Fading = false
                self.FadingFinished = true
            end

            if self.FadeTime > self.FadeTotal then
                self.FadeTime = self.FadeTotal
                self.Fading = false
                self.FadingFinished = true
            end

            self:SetAlpha(self.FadeTime / self.FadeTotal, true)
        end

        if not noUpdate then
            self:Update()
        end

        StageAPI.RenderSpriteTiled(self.Sprite, self.Position + (self.Offset or zeroVector) + (additionalOffset or zeroVector), self.Size, centerCorrect)

        if StageAPI.DebugTiling then
            Isaac.RenderText("OriginPoint: " .. tostring(self.Position.X) .. ", " .. tostring(self.Position.Y), self.Position.X, self.Position.Y, 0, 255, 0, 1)
        end
    end
end

StageAPI.LogMinor("Loading Room Handler")
do -- RoomsList
    StageAPI.RemappedEntities = {}
    function StageAPI.RemapEntity(t1, v1, s1, t2, v2, s2)
        v1 = v1 or "Default"
        s1 = s1 or "Default"
        if not StageAPI.RemappedEntities[t1] then
            StageAPI.RemappedEntities[t1] = {}
        end

        if v1 and not StageAPI.RemappedEntities[t1][v1] then
            StageAPI.RemappedEntities[t1][v1] = {}
        end

        StageAPI.RemappedEntities[t1][v1][s1] = {
            Type = t2,
            Variant = v2,
            SubType = s2
        }
    end

    StageAPI.RoomShapeToWidthHeight = {
        [RoomShape.ROOMSHAPE_1x1] = {
            Width = 15,
            Height = 9,
            Slots = {DoorSlot.UP0, DoorSlot.LEFT0, DoorSlot.RIGHT0, DoorSlot.DOWN0}
        },
        [RoomShape.ROOMSHAPE_IV] = {
            Width = 15,
            Height = 9,
            Slots = {DoorSlot.UP0, DoorSlot.DOWN0}
        },
        [RoomShape.ROOMSHAPE_IH] = {
            Width = 15,
            Height = 9,
            Slots = {DoorSlot.LEFT0, DoorSlot.RIGHT0}
        },
        [RoomShape.ROOMSHAPE_2x2] = {
            Width = 28,
            Height = 16,
            Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1}
        },
        [RoomShape.ROOMSHAPE_2x1] = {
            Width = 28,
            Height = 9,
            Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.RIGHT0, DoorSlot.DOWN0, DoorSlot.DOWN1}
        },
        [RoomShape.ROOMSHAPE_1x2] = {
            Width = 15,
            Height = 16,
            Slots = {DoorSlot.UP0, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0}
        },
        [RoomShape.ROOMSHAPE_IIV] = {
            Width = 15,
            Height = 16,
            Slots = {DoorSlot.UP0, DoorSlot.DOWN0}
        },
        [RoomShape.ROOMSHAPE_LTL] = {
            Width = 28,
            Height = 16,
            LWidthEnd = 14,
            LHeightEnd = 8,
            Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1}
        },
        [RoomShape.ROOMSHAPE_LBL] = {
            Width = 28,
            Height = 16,
            LWidthEnd = 14,
            LHeightStart = 8,
            Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1}
        },
        [RoomShape.ROOMSHAPE_LBR] = {
            Width = 28,
            Height = 16,
            LWidthStart = 14,
            LHeightStart = 8,
            Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1}
        },
        [RoomShape.ROOMSHAPE_LTR] = {
            Width = 28,
            Height = 16,
            LWidthStart = 14,
            LHeightEnd = 8,
            Slots = {DoorSlot.UP0, DoorSlot.UP1, DoorSlot.LEFT0, DoorSlot.LEFT1, DoorSlot.RIGHT0, DoorSlot.RIGHT1, DoorSlot.DOWN0, DoorSlot.DOWN1}
        },
        [RoomShape.ROOMSHAPE_IIH] = {
            Width = 28,
            Height = 9,
            Slots = {DoorSlot.LEFT0, DoorSlot.RIGHT0}
        }
    }

    function StageAPI.AddObjectToRoomLayout(layout, index, objtype, variant, subtype, gridX, gridY)
        if gridX and gridY and not index then
            index = StageAPI.VectorToGrid(gridX, gridY, layout.Width)
        end

        if StageAPI.CorrectedGridTypes[objtype] then
            local t, v = StageAPI.CorrectedGridTypes[objtype], variant
            if type(t) == "table" then
                v = t.Variant
                t = t.Type
            end

            local gridData = {
                Type = t,
                Variant = v,
                GridX = gridX,
                GridY = gridY,
                Index = index
            }

            layout.GridEntities[#layout.GridEntities + 1] = gridData

            if not layout.GridEntitiesByIndex[gridData.Index] then
                layout.GridEntitiesByIndex[gridData.Index] = {}
            end

            layout.GridEntitiesByIndex[gridData.Index][#layout.GridEntitiesByIndex[gridData.Index] + 1] = gridData
        elseif StageAPI.UnsupportedTypes[objtype] then
            StageAPI.LogErr("Error in " .. layout.Name .. "! Entities with type " .. tostring(objtype) .. " are unsupported in StageAPI layouts!")
        elseif objtype ~= 0 then
            local entData = {
                Type = objtype,
                Variant = variant,
                SubType = subtype,
                GridX = gridX,
                GridY = gridY,
                Index = index
            }

            if entData.Type == 1400 or entData.Type == 1410 then
                entData.Type = EntityType.ENTITY_FIREPLACE
                if entData.Type == 1410 then
                    entData.Variant = 1
                else
                    entData.Variant = 0
                end
            end

            if entData.Type == 999 then
                entData.Type = 1000
            end

            if StageAPI.RemappedEntities[entData.Type] then
                local remapTo
                if entData.Variant and StageAPI.RemappedEntities[entData.Type][entData.Variant] then
                    if entData.SubType and StageAPI.RemappedEntities[entData.Type][entData.Variant][entData.SubType] then
                        remapTo = StageAPI.RemappedEntities[entData.Type][entData.Variant][entData.SubType]
                    elseif StageAPI.RemappedEntities[entData.Type][entData.Variant]["Default"] then
                        remapTo = StageAPI.RemappedEntities[entData.Type][entData.Variant]["Default"]
                    end
                elseif StageAPI.RemappedEntities[entData.Type]["Default"] then
                    remapTo = StageAPI.RemappedEntities[entData.Type]["Default"]["Default"]
                end

                if remapTo then
                    entData.Type = remapTo.Type
                    if remapTo.Variant then
                        entData.Variant = remapTo.Variant
                    end

                    if remapTo.SubType then
                        entData.SubType = remapTo.SubType
                    end
                end
            end

            if not layout.EntitiesByIndex[entData.Index] then
                layout.EntitiesByIndex[entData.Index] = {}
            end

            layout.EntitiesByIndex[entData.Index][#layout.EntitiesByIndex[entData.Index] + 1] = entData
            layout.Entities[#layout.Entities + 1] = entData
        end
    end

    StageAPI.LastRoomID = 0
    function StageAPI.SimplifyRoomLayout(layout)
        local outLayout = {
            GridEntities = {},
            GridEntitiesByIndex = {},
            Entities = {},
            EntitiesByIndex = {},
            Doors = {},
            Shape = layout.SHAPE,
            Weight = layout.WEIGHT,
            Difficulty = layout.DIFFICULTY,
            Name = layout.NAME,
            Width = layout.WIDTH + 2,
            Height = layout.HEIGHT + 2,
            Type = layout.TYPE,
            Variant = layout.VARIANT,
            SubType = layout.SUBTYPE,
            StageAPIID = StageAPI.LastRoomID + 1,
            PreSimplified = true
        }

        StageAPI.LastRoomID = outLayout.StageAPIID

        local widthHeight = StageAPI.RoomShapeToWidthHeight[outLayout.Shape]
        if widthHeight then
            outLayout.LWidthStart = widthHeight.LWidthStart
            outLayout.LWidthEnd = widthHeight.LWidthEnd
            outLayout.LHeightStart = widthHeight.LHeightStart
            outLayout.LHeightEnd = widthHeight.LHeightEnd
        end

        for _, object in ipairs(layout) do
            if not object.ISDOOR then
                local index = StageAPI.VectorToGrid(object.GRIDX, object.GRIDY, outLayout.Width)
                for _, entityData in ipairs(object) do
                    StageAPI.AddObjectToRoomLayout(outLayout, index, entityData.TYPE, entityData.VARIANT, entityData.SUBTYPE, object.GRIDX, object.GRIDY)
                end
            else
                outLayout.Doors[#outLayout.Doors + 1] = {
                    Slot = object.SLOT,
                    Exists = object.EXISTS
                }
            end
        end

        return outLayout
    end

    function StageAPI.CreateEmptyRoomLayout(shape)
        shape = shape or RoomShape.ROOMSHAPE_1x1
        local widthHeight = StageAPI.RoomShapeToWidthHeight[shape]
        local width, height, lWidthStart, lWidthEnd, lHeightStart, lHeightEnd, slots
        if not widthHeight then
            width, height, slots = StageAPI.RoomShapeToWidthHeight[RoomShape.ROOMSHAPE_1x1].Width, StageAPI.RoomShapeToWidthHeight[RoomShape.ROOMSHAPE_1x1].Height, StageAPI.RoomShapeToWidthHeight[RoomShape.ROOMSHAPE_1x1].Slots
        else
            width, height, lWidthStart, lWidthEnd, lHeightStart, lHeightEnd, slots = widthHeight.Width, widthHeight.Height, widthHeight.LWidthStart, widthHeight.LWidthEnd, widthHeight.LHeightStart, widthHeight.LHeightEnd, widthHeight.Slots
        end
        local newRoom = {
            Name = "Empty",
            RoomFilename = "Special",
            Type = 1,
            Variant = 0,
            SubType = 0,
            Shape = shape,
            Difficulty = 1,
            Width = width,
            Height = height,
            LWidthStart = lWidthStart,
            LWidthEnd = lWidthEnd,
            LHeightStart = lHeightStart,
            LHeightEnd = lHeightEnd,
            Weight = 1,
            GridEntities = {},
            GridEntitiesByIndex = {},
            Entities = {},
            EntitiesByIndex = {},
            Doors = {},
            StageAPIID = StageAPI.LastRoomID + 1,
            PreSimplified = true
        }

        StageAPI.LastRoomID = newRoom.StageAPIID

        for _, slot in ipairs(slots) do
            newRoom.Doors[#newRoom.Doors + 1] = {
                Slot = slot,
                Exists = true
            }
        end

        return newRoom
    end

    StageAPI.DoorsBitwise = {
        [DoorSlot.LEFT0] = 1,
        [DoorSlot.UP0] = 1 << 1,
        [DoorSlot.RIGHT0] = 1 << 2,
        [DoorSlot.DOWN0] = 1 << 3,
        [DoorSlot.LEFT1] = 1 << 4,
        [DoorSlot.UP1] = 1 << 5,
        [DoorSlot.RIGHT1] = 1 << 6,
        [DoorSlot.DOWN1] = 1 << 7,
    }

    function StageAPI.ForAllSpawnEntries(data, func)
        local spawns = data.Spawns
        for i = 0, spawns.Size do
            local spawn = spawns:Get(i)
            local shouldBreak
            if spawn then
                local sumWeight = spawn.SumWeights
                local weight = 0
                for i = 1, spawn.EntryCount do
                    local entry = spawn:PickEntry(weight)
                    weight = weight + entry.Weight / sumWeight

                    shouldBreak = func(entry, spawn)
                    if shouldBreak then
                        break
                    end
                end
            end

            if shouldBreak then
                break
            end
        end
    end

    function StageAPI.GenerateRoomLayoutFromData(data) -- converts RoomDescriptor.Data to a StageAPI layout
        local layout = StageAPI.CreateEmptyRoomLayout(data.Shape)
        layout.Name = data.Name
        layout.RoomFilename = "Special"
        layout.Type = data.Type
        layout.Variant = data.Variant
        layout.SubType = data.Subtype
        layout.Difficulty = data.Difficulty
        layout.Weight = data.InitialWeight

        for _, door in ipairs(layout.Doors) do
            door.Exists = data.Doors & StageAPI.DoorsBitwise[door.Slot] ~= 0
        end

        StageAPI.ForAllSpawnEntries(data, function(entry, spawn)
            StageAPI.AddObjectToRoomLayout(layout, nil, entry.Type, entry.Variant, entry.Subtype, spawn.X, spawn.Y)
        end)

        return layout
    end

    StageAPI.Layouts = {}
    function StageAPI.RegisterLayout(name, layout)
        StageAPI.Layouts[name] = layout
    end

    StageAPI.RoomsLists = {}
    StageAPI.RoomsList = StageAPI.Class("RoomsList")
    function StageAPI.RoomsList:Init(name, ...)
        self.Name = name
        StageAPI.RoomsLists[name] = self
        self.All = {}
        self.ByShape = {}
        self.Shapes = {}
        self.NotSimplifiedFiles = {}
        self:AddRooms(...)
    end

    function StageAPI.RoomsList:AddRooms(...)
        local roomfiles = {...}
        for _, rooms in ipairs(roomfiles) do
            local roomfile, waitToSimplify = "N/A", false
            if type(rooms) == "table" and rooms.Rooms then
                roomfile = rooms.Name
                waitToSimplify = rooms.WaitToSimplify
                rooms = rooms.Rooms
            end

            if waitToSimplify then
                self.NotSimplifiedFiles[#self.NotSimplifiedFiles + 1] = rooms
            else
                for _, room in ipairs(rooms) do
                    local simplified
                    if not room.PreSimplified then
                        simplified = StageAPI.SimplifyRoomLayout(room)
                    else
                        simplified = room
                    end

                    simplified.RoomFilename = not waitToSimplify and room.RoomFilename or roomfile
                    self.All[#self.All + 1] = simplified
                    if not self.ByShape[simplified.Shape] then
                        self.Shapes[#self.Shapes + 1] = simplified.Shape
                        self.ByShape[simplified.Shape] = {}
                    end

                    self.ByShape[simplified.Shape][#self.ByShape[simplified.Shape] + 1] = simplified
                end
            end
        end
    end

    function StageAPI.RoomsList:CopyRooms(roomsList)
        self:AddRooms(roomsList.All)
    end

    function StageAPI.CreateSingleEntityLayout(t, v, s, name, rtype, shape)
        local layout = StageAPI.CreateEmptyRoomLayout(shape)
        layout.Type = rtype or RoomType.ROOM_DEFAULT
        layout.Name = name or "N/A"
        local centerX, centerY = math.floor((layout.Width - 2) / 2), math.floor((layout.Height - 2) / 2)
        local centerIndex = StageAPI.VectorToGrid(centerX, centerY, layout.Width)
        layout.EntitiesByIndex[centerIndex] = {
            {
                Type = t or EntityType.ENTITY_MONSTRO,
                Variant = v or 0,
                SubType = s or 0,
                GridX = centerX,
                GridY = centerY,
                Index = centerIndex
            }
        }
        return layout
    end

    function StageAPI.CreateSingleEntityRoomList(t, v, s, name, rtype, individualRoomName)
        local layouts = {}
        for name, shape in pairs(RoomShape) do
            local layout = StageAPI.CreateSingleEntityLayout(t, v, s, individualRoomName, rtype, shape)
            layouts[#layouts + 1] = layout
        end

        return StageAPI.RoomsList(name, layouts)
    end

    --[[ Entity Splitting Data

    {
        Type = ,
        Variant = ,
        SubType = ,
        ListName =
    }

    ]]

    function StageAPI.SplitRoomsOnEntities(rooms, entities, roomEntityPairs)
        local singleMode = false
        if #entities == 0 then
            singleMode = true
            entities = {entities}
        end

        roomEntityPairs = roomEntityPairs or {}

        for _, room in ipairs(rooms) do
            local hasEntities = {}
            for _, object in ipairs(room) do
                for _, entData in ipairs(object) do
                    for i, entity in ipairs(entities) do
                        local useEnt = entity.Entity or entity
                        if entData.TYPE == useEnt.Type and (not useEnt.Variant or entData.VARIANT == useEnt.Variant) and (not useEnt.SubType or entData.SUBTYPE == useEnt.SubType) then
                            if not hasEntities[i] then
                                hasEntities[i] = 0
                            end

                            hasEntities[i] = hasEntities[i] + 1
                            break
                        end
                    end
                end
            end

            for ind, count in pairs(hasEntities) do
                local entity = entities[ind]
                local listName = entity.ListName
                if entity.MultipleListName and count > 1 then
                    listName = entity.MultipleListName
                end

                if not roomEntityPairs[listName] then
                    roomEntityPairs[listName] = {}
                end

                roomEntityPairs[listName][#roomEntityPairs[listName] + 1] = room
            end
        end

        return roomEntityPairs
    end

    --[[ Type Splitting Data

    {
        Type = RoomType,
        ListName =
    }

    ]]

    function StageAPI.SplitRoomsOnTypes(rooms, types, roomTypePairs)
        roomTypePairs = roomTypePairs or {}
        for _, room in ipairs(rooms) do
            for _, rtype in ipairs(types) do
                if room.TYPE == rtype then
                    if not roomTypePairs[rtype.ListName] then
                        roomTypePairs[rtype.ListName] = {}
                    end

                    roomTypePairs[rtype.ListName][#roomTypePairs[rtype.ListName] + 1] = room
                end
            end
        end

        return roomTypePairs
    end

    --[[ Splitting List Data

    {
        ListName = ,
        SplitBy = Entity Splitting Data or Type Splitting Data
    }

    ]]

    function StageAPI.SplitRoomsIntoLists(roomsList, splitBy, splitByType, createEntityPlaceholders, listNamePrefix)
        listNamePrefix = listNamePrefix or ""
        local roomPairs

        if roomsList[1] and roomsList[1].TYPE then
            roomsList = {roomsList}
        end

        if splitByType then
            for _, rooms in ipairs(roomsList) do
                roomPairs = StageAPI.SplitRoomsOnTypes(rooms, splitBy, roomPairs)
            end
        else
            for _, rooms in ipairs(roomsList) do
                roomPairs = StageAPI.SplitRoomsOnEntities(rooms, splitBy, roomPairs)
            end
        end

        if roomPairs then
            for listName, rooms in pairs(roomPairs) do
                if StageAPI.RoomsLists[listNamePrefix .. listName] then
                    StageAPI.RoomsLists[listNamePrefix .. listName]:AddRooms(rooms)
                else
                    StageAPI.RoomsList(listNamePrefix .. listName, rooms)
                end
            end
        end

        if not splitByType and createEntityPlaceholders then
            for _, splitData in ipairs(splitBy) do
                if not StageAPI.RoomsLists[listNamePrefix .. splitData.ListName] then
                    local entity = splitData.Entity or splitData
                    StageAPI.CreateSingleEntityRoomList(entity.Type, entity.Variant, entity.SubType, listNamePrefix .. splitData.ListName, splitData.RoomType or entity.RoomType, splitData.RoomName or entity.RoomName)
                end
            end
        end
    end

    StageAPI.SinsSplitData = {
        {
            Type = EntityType.ENTITY_GLUTTONY,
            Variant = 0,
            ListName = "Gluttony",
            MultipleListName = "SuperGluttony"
        },
        {
            Type = EntityType.ENTITY_ENVY,
            Variant = 0,
            ListName = "Envy",
            MultipleListName = "SuperEnvy"
        },
        {
            Type = EntityType.ENTITY_GREED,
            Variant = 0,
            ListName = "Greed",
            MultipleListName = "SuperGreed"
        },
        {
            Type = EntityType.ENTITY_WRATH,
            Variant = 0,
            ListName = "Wrath",
            MultipleListName = "SuperWrath"
        },
        {
            Type = EntityType.ENTITY_PRIDE,
            Variant = 0,
            ListName = "Pride",
            MultipleListName = "SuperPride"
        },
        {
            Type = EntityType.ENTITY_LUST,
            Variant = 0,
            ListName = "Lust",
            MultipleListName = "SuperLust"
        },
        {
            Type = EntityType.ENTITY_SLOTH,
            Variant = 0,
            ListName = "Sloth",
            MultipleListName = "SuperSloth"
        },
        {
            Type = EntityType.ENTITY_GLUTTONY,
            Variant = 1,
            ListName = "SuperGluttony"
        },
        {
            Type = EntityType.ENTITY_ENVY,
            Variant = 1,
            ListName = "SuperEnvy"
        },
        {
            Type = EntityType.ENTITY_GREED,
            Variant = 1,
            ListName = "SuperGreed"
        },
        {
            Type = EntityType.ENTITY_WRATH,
            Variant = 1,
            ListName = "SuperWrath"
        },
        {
            Type = EntityType.ENTITY_PRIDE,
            Variant = 1,
            ListName = "SuperPride"
        },
        {
            Type = EntityType.ENTITY_LUST,
            Variant = 1,
            ListName = "SuperLust"
        },
        {
            Type = EntityType.ENTITY_SLOTH,
            Variant = 1,
            ListName = "SuperSloth"
        },
        {
            Type = EntityType.ENTITY_SLOTH,
            Variant = 2,
            ListName = "UltraPride"
        }
    }

    --[[ BossData
    {
        {
            Bosses = {
                {
                    Type = ,
                    Variant = ,
                    SubType = ,
                    Count =
                }
            },
            Name,
            Weight,
            Horseman,
            Portrait,
            Bossname,
            NameTwo,
            PortraitTwo,
            RoomListName
        }
    }

    ]]

    function StageAPI.SeparateRoomListToBossData(roomlist, bossdata)
        if roomlist.Name and StageAPI.RoomsLists[roomlist.Name] then
            StageAPI.RoomsLists[roomlist.Name] = nil
        end

        local retBossData = {}

        for _, boss in ipairs(bossdata) do
            for _, bossEntData in ipairs(boss.Bosses) do
                if not bossEntData.Count then
                    bossEntData.Count = 1
                end
            end

            local matchingLayouts = {}
            for _, layout in ipairs(roomlist.All) do
                local countsFound = {}
                for i, bossEntData in ipairs(boss.Bosses) do
                    countsFound[i] = 0
                end

                for index, entities in pairs(layout.EntitiesByIndex) do
                    for _, entityData in ipairs(entities) do
                        for i, bossEntData in ipairs(boss.Bosses) do
                            if not bossEntData.Type or entityData.Type == bossEntData.Type
                            and not bossEntData.Variant or entityData.Variant == bossEntData.Variant
                            and not bossEntData.SubType or entityData.SubType == bossEntData.SubType then
                                countsFound[i] = countsFound[i] + 1
                            end
                        end
                    end
                end

                local matches = true
                for i, bossEntData in ipairs(boss.Bosses) do
                    if bossEntData.Count ~= countsFound[i] then
                        matches = false
                    end
                end

                if matches then
                    matchingLayouts[#matchingLayouts + 1] = layout
                end
            end

            if #matchingLayouts > 0 then
                local list = StageAPI.RoomsList(boss.RoomListName or (boss.Name .. (boss.NameTwo or "")), matchingLayouts)
                retBossData[#retBossData + 1] = {
                    Name = boss.Name,
                    Weight = boss.Weight,
                    Horseman = boss.Horseman,
                    Portrait = boss.Portrait,
                    Bossname = boss.Bossname,
                    NameTwo = boss.NameTwo,
                    PortraitTwo = boss.PortraitTwo,
                    Rooms = list
                }
            end
        end

        return retBossData
    end

    function StageAPI.IsIndexInLayout(layout, x, y)
        if not y then
            x, y = StageAPI.GridToVector(x, layout.Width)
        end

        if x < 0 or x > layout.Width - 3 or y < 0 or y > layout.Height - 3 then
            return false
        elseif layout.LWidthStart or layout.LWidthEnd or layout.LHeightStart or layout.lHeightEnd then
            local inHole = true
            if layout.LWidthEnd and x > layout.LWidthEnd - 2 then
                inHole = false
            elseif layout.LWidthStart and x < layout.LWidthStart - 1 then
                inHole = false
            elseif layout.LHeightEnd and y > layout.LHeightEnd - 2 then
                inHole = false
            elseif layout.LHeightStart and y < layout.LHeightStart - 1 then
                inHole = false
            end

            return not inHole
        end

        return true
    end

    function StageAPI.DoesEntityDataMatchParameters(param, data)
        return (not param.Type or param.Type == data.Type) and (not param.Variant or param.Variant == data.Variant) and (not param.SubType or param.SubType == data.SubType)
    end

    function StageAPI.CountLayoutEntities(layout, entities, notIncluding)
        local count = 0
        for _, ent in ipairs(layout.Entities) do
            for _, entity in ipairs(entities) do
                if StageAPI.DoesEntityDataMatchParameters(entity, ent) then
                    local dontCount
                    if notIncluding then
                        for _, noInclude in ipairs(notIncluding) do
                            if StageAPI.DoesEntityDataMatchParameters(noInclude, ent) then
                                dontCount = true
                                break
                            end
                        end
                    end

                    if not dontCount then
                        count = count + 1
                        break
                    end
                end
            end
        end

        return count
    end

    function StageAPI.DoesLayoutContainEntities(layout, mustIncludeAny, mustExclude, mustIncludeAll, notIncluding)
        local includesAny = not mustIncludeAny
        local mustIncludeAllCopy = {}
        if mustIncludeAll then
            for _, include in ipairs(mustIncludeAll) do
                mustIncludeAllCopy[#mustIncludeAllCopy + 1] = include
            end
        end

        for _, ent in ipairs(layout.Entities) do
            if not includesAny then
                for _, include in ipairs(mustIncludeAny) do
                    if StageAPI.DoesEntityDataMatchParameters(include, ent) then
                        local dontCount
                        if notIncluding then
                            for _, noInclude in ipairs(notIncluding) do
                                if StageAPI.DoesEntityDataMatchParameters(noInclude, ent) then
                                    dontCount = true
                                    break
                                end
                            end
                        end

                        if not dontCount then
                            includesAny = true
                            break
                        end
                    end
                end
            end

            if mustExclude then
                for _, exclude in ipairs(mustExclude) do
                    if StageAPI.DoesEntityDataMatchParameters(exclude, ent) then
                        return false
                    end
                end
            end

            if #mustIncludeAllCopy > 0 then
                for i, include in StageAPI.ReverseIterate(mustIncludeAllCopy) do
                    if StageAPI.DoesEntityDataMatchParameters(include, ent) then
                        local dontCount
                        if notIncluding then
                            for _, noInclude in ipairs(notIncluding) do
                                if StageAPI.DoesEntityDataMatchParameters(noInclude, ent) then
                                    dontCount = true
                                    break
                                end
                            end
                        end

                        if not dontCount then
                            table.remove(mustIncludeAllCopy, i)
                            break
                        end
                    end
                end
            end
        end

        return includesAny and #mustIncludeAllCopy == 0
    end

    local excludeTypesFromClearing = {
        [EntityType.ENTITY_FAMILIAR] = true,
        [EntityType.ENTITY_PLAYER] = true,
        [EntityType.ENTITY_KNIFE] = true,
        [EntityType.ENTITY_DARK_ESAU] = true,
        [EntityType.ENTITY_MOTHERS_SHADOW] = true
    }

    function StageAPI.ClearRoomLayout(keepDecoration, doGrids, doEnts, doPersistentEnts, onlyRemoveTheseDecorations, doWalls, doDoors, skipIndexedGrids)
        if doEnts or doPersistentEnts then
            for _, ent in ipairs(Isaac.GetRoomEntities()) do
                local etype = ent.Type
                if not excludeTypesFromClearing[etype] and not (etype == StageAPI.E.Shading.T and ent.Variant == StageAPI.E.Shading.V) then
                    local persistentData = StageAPI.CheckPersistence(ent.Type, ent.Variant, ent.SubType)
                    if (doPersistentEnts or (ent:ToNPC() and (not persistentData or not persistentData.AutoPersists))) and not (ent:HasEntityFlags(EntityFlag.FLAG_CHARM) or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT)) then
                        ent:Remove()
                    end
                end
            end
        end

        if doGrids then
            if not skipIndexedGrids then
                local lindex = StageAPI.GetCurrentRoomID()
                local customGrids = StageAPI.GetTableIndexedByDimension(StageAPI.CustomGrids, true)
                customGrids[lindex] = {}

                local roomGrids = StageAPI.GetTableIndexedByDimension(StageAPI.RoomGrids, true)
                roomGrids[lindex] = {}
            end

            for i = 0, room:GetGridSize() do
                local grid = room:GetGridEntity(i)
                if grid then
                    local gtype = grid.Desc.Type
                    if (doWalls or gtype ~= GridEntityType.GRID_WALL or room:IsPositionInRoom(grid.Position, 0)) -- this allows custom wall grids to exist
                    and (doDoors or gtype ~= GridEntityType.GRID_DOOR)
                    and (not onlyRemoveTheseDecorations or gtype ~= GridEntityType.GRID_DECORATION or onlyRemoveTheseDecorations[i]) then
                        StageAPI.Room:RemoveGridEntity(i, 0, keepDecoration)
                    end
                end
            end
        end

        StageAPI.CalledRoomUpdate = true
        room:Update()
        StageAPI.CalledRoomUpdate = false
    end

    function StageAPI.DoLayoutDoorsMatch(layout, doors)
        local numNonExistingDoors = 0
        local doesLayoutMatch = true
        for _, door in ipairs(layout.Doors) do
            if door.Slot and not door.Exists then
                if ((not doors and room:GetDoor(door.Slot)) or (doors and doors[door.Slot])) then
                    doesLayoutMatch = false
                end
                numNonExistingDoors = numNonExistingDoors + 1
            end
        end

        return doesLayoutMatch, numNonExistingDoors
    end

    -- returns list of rooms, error message if no rooms valid
    function StageAPI.GetValidRoomsForLayout(args)
        local roomList = args.RoomList
        local roomDesc = args.RoomDescriptor or level:GetCurrentRoomDesc()
        local shape = args.Shape or roomDesc.Data.Shape

        local callbacks = StageAPI.GetCallbacks("POST_CHECK_VALID_ROOM")
        local validRooms = {}
        local validRoomWeights = 0

        local possibleRooms
        if shape == -1 then
            possibleRooms = roomList.All
        else
            possibleRooms = roomList.ByShape[shape]
        end

        if not possibleRooms then
            return {}, nil, "No rooms for shape!"
        end

        local requireRoomType = args.RequireRoomType
        local rtype = args.RoomType or roomDesc.Data.Type

        local ignoreDoors = args.IgnoreDoors
        local doors = args.Doors or StageAPI.GetDoorsForRoomFromData(roomDesc.Data)

        local seed = args.Seed or roomDesc.SpawnSeed
        local disallowIDs = args.DisallowIDs

        for _, layout in ipairs(possibleRooms) do
            shape = layout.Shape

            local isValid = true

            local numNonExistingDoors = 0
            if requireRoomType and layout.Type ~= rtype then
                isValid = false
            elseif not ignoreDoors then
                isValid, numNonExistingDoors = StageAPI.DoLayoutDoorsMatch(layout, doors)
            end

            if isValid and disallowIDs then
                for _, id in ipairs(disallowIDs) do
                    if layout.StageAPIID == id then
                        isValid = false
                        break
                    end
                end
            end

            local weight = layout.Weight
            if isValid then
                for _, callback in ipairs(callbacks) do
                    local ret = callback.Function(layout, roomList, seed, shape, rtype, requireRoomType)
                    if ret == false then
                        isValid = false
                        break
                    elseif type(ret) == "number" then
                        weight = ret
                    end
                end
            end

            if isValid then
                if StageAPI.CurrentlyInitializing and not StageAPI.CurrentlyInitializing.IsExtraRoom and rtype == RoomType.ROOM_DEFAULT then
                    local originalWeight = weight
                    weight = weight * 2 ^ numNonExistingDoors
                    if shape == RoomShape.ROOMSHAPE_1x1 and numNonExistingDoors > 0 then
                        weight = weight + math.min(originalWeight * 4, 4)
                    end
                end
            end

            if isValid then
                validRooms[#validRooms + 1] = {layout, weight}
                validRoomWeights = validRoomWeights + weight
            end
        end

        return validRooms, validRoomWeights, nil
    end

    StageAPI.RoomChooseRNG = RNG()
    function StageAPI.ChooseRoomLayout(roomList, seed, shape, rtype, requireRoomType, ignoreDoors, doors, disallowIDs)
        local args
        if roomList.Type ~= "RoomsList" then
            args = roomList
        else
            args = {
                RoomList = roomList,
                Seed = seed,
                Shape = shape,
                RoomType = rtype,
                RequireRoomType = requireRoomType,
                IgnoreDoors = ignoreDoors,
                Doors = doors,
                DisallowIDs = disallowIDs
            }
        end

        local validRooms, totalWeight, err = StageAPI.GetValidRoomsForLayout(args)
        if err then StageAPI.LogErr(err) end

        if #validRooms > 0 then
            StageAPI.RoomChooseRNG:SetSeed(seed, 0)
            return StageAPI.WeightedRNG(validRooms, StageAPI.RoomChooseRNG, nil, totalWeight)
        else
            StageAPI.LogErr("No rooms with correct shape and doors!")
        end
    end

    --[[ options
    {
        Type = etype,
        Variant = variant,
        SubType = subtype,
        AutoPersists = autoPersists,
        RemoveOnRemove = removeOnRemove,
        RemoveOnDeath = removeOnDeath,
        UpdatePosition = updatePosition,
        StoreCheck = storeCheck
    }
    ]]
    StageAPI.PersistentEntities = {}
    function StageAPI.AddEntityPersistenceData(persistenceData)
        StageAPI.PersistentEntities[#StageAPI.PersistentEntities + 1] = persistenceData
    end

    StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_STONEHEAD})
    StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_CONSTANT_STONE_SHOOTER})
    StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_STONE_EYE})
    StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_BRIMSTONE_HEAD})
    StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_WALL_HUGGER})
    StageAPI.AddEntityPersistenceData({Type = EntityType.ENTITY_POKY, Variant = 1})
    StageAPI.AddEntityPersistenceData({
        Type = EntityType.ENTITY_FIREPLACE,
        AutoPersists = true,
        RemoveOnRemove = true,
        UpdateType = true,
        UpdateVariant = true,
        UpdateSubType = true,
        UpdateHealth = true,
    })

    StageAPI.PersistenceChecks = {}
    function StageAPI.AddPersistenceCheck(fn)
        StageAPI.PersistenceChecks[#StageAPI.PersistenceChecks + 1] = fn
    end

    StageAPI.DynamicPersistentTypes = {
        EntityType.ENTITY_BOMBDROP,
        EntityType.ENTITY_PICKUP,
        EntityType.ENTITY_SLOT,
        EntityType.ENTITY_MOVABLE_TNT,
        EntityType.ENTITY_SHOPKEEPER,
        EntityType.ENTITY_PITFALL,
        EntityType.ENTITY_ETERNALFLY,
    }

    StageAPI.ChestVariants = {
        PickupVariant.PICKUP_CHEST,
        PickupVariant.PICKUP_LOCKEDCHEST,
        PickupVariant.PICKUP_BOMBCHEST,
        PickupVariant.PICKUP_ETERNALCHEST,
        PickupVariant.PICKUP_MIMICCHEST,
        PickupVariant.PICKUP_SPIKEDCHEST,
        PickupVariant.PICKUP_REDCHEST,
        PickupVariant.PICKUP_OLDCHEST,
        PickupVariant.PICKUP_WOODENCHEST,
        PickupVariant.PICKUP_MEGACHEST,
        PickupVariant.PICKUP_HAUNTEDCHEST,
        PickupVariant.PICKUP_MOMSCHEST,
    }

    StageAPI.AddPersistenceCheck(function(entData)
        local isDynamicPersistent = false
        for _, type in ipairs(StageAPI.DynamicPersistentTypes) do
            isDynamicPersistent = entData.Type == type
            if isDynamicPersistent then break end
        end
        if isDynamicPersistent then
            return {
                AutoPersists = true,
                UpdatePosition = true,
                RemoveOnRemove = true,
                UpdateType = true,
                UpdateVariant = true,
                UpdateSubType = true,
                StoreCheck = function(entity)
                    if entity.Type == EntityType.ENTITY_PICKUP then
                        local variant = entity.Variant
                        if variant == PickupVariant.PICKUP_COLLECTIBLE then
                            return entity.SubType == 0
                        else
                            local isChest
                            for _, var in ipairs(StageAPI.ChestVariants) do
                                if variant == var then
                                    isChest = true
                                end
                            end

                            if isChest then
                                return entity.SubType == 0
                            end

                            local sprite = entity:GetSprite()
                            if sprite:IsPlaying("Open") or sprite:IsPlaying("Opened") or sprite:IsPlaying("Collect") or sprite:IsFinished("Open") or sprite:IsFinished("Opened") or sprite:IsFinished("Collect") then
                                return true
                            end

                            if entity:IsDead() then
                                return true
                            end
                        end
                    elseif entity.Type == EntityType.ENTITY_SLOT then
                        return entity:GetSprite():IsPlaying("Death") or entity:GetSprite():IsPlaying("Broken") or entity:GetSprite():IsFinished("Death") or entity:GetSprite():IsFinished("Broken")
                    end
                end
            }
        end
    end)

    function StageAPI.CheckPersistence(id, variant, subtype)
        local persistentData

        for _, persistData in ipairs(StageAPI.PersistentEntities) do
            if (not persistData.Type or id == persistData.Type)
            and (not persistData.Variant or variant == persistData.Variant)
            and (not persistData.SubType or subtype == persistData.SubType) then
                persistentData = persistData
            end
        end

        if not persistentData then
            for _, check in ipairs(StageAPI.PersistenceChecks) do
                local persistData = check({Type = id, Variant = variant, SubType = subtype})
                if persistData then
                    persistentData = persistData
                    break
                end
            end
        end

        return persistentData
    end

    StageAPI.RoomLoadRNG = RNG()

    StageAPI.MetadataEntities = {
        [199] = {
            [0] = {
                Name = "Group",
                Tags = "Group",
                ConflictTag = "Group",
                OnlyConflictWith = "RandomizeGroup",
                BitValues = {
                    GroupID = {Offset = 0, Length = 16}
                },
            },
            [1] = {
                Name = "RandomizeGroup"
            },
            [2] = {
                Name = "Direction",
                Tag = "Direction",
                ConflictTag = "Direction",
                PreventConflictWith = "PreventDirectionConflict"
            },
            [3] = {
                Name = "PreventDirectionConflict"
            },
            [10] = {
                Name = "EnteredFromTrigger",
                Tag = "StageAPILoadEditorFeature",
                BitValues = {
                    GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
                }
            },
            [11] = {
                Name = "ShopItem",
                Tag = "StageAPIPickupEditorFeature",
                BitValues = {
                    Price = {Offset = 0, Length = 7, ValueOffset = -5}
                }
            },
            [12] = {
                Name = "OptionsPickup",
                Tag = "StageAPIPickupEditorFeature",
                BitValues = {
                    OptionsIndex = {Offset = 0, Length = 16, ValueOffset = 100}
                }
            },
            [13] = {
                Name = "CancelClearAward"
            },
            [14] = {
                Name = "SetPlayerPosition",
                Tag = "StageAPILoadEditorFeature",
                BitValues = {
                    UnclearedOnly = {Offset = 0, Length = 1}
                }
            },
            [20] = {
                Name = "Swapper",
                GroupIDIfUngrouped = "Swapper",
                BitValues = {
                    GroupID = {Offset = 0, Length = 15, ValueOffset = -1},
                    NoMetadata = {Offset = 15, Length = 1}
                }
            },
            [21] = {
                Name = "Detonator",
                Tags = {"StageAPIEditorFeature", "Triggerable"},
                BitValues = {
                    GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
                }
            },
            [22] = {
                Name = "RoomClearTrigger",
                Tag = "StageAPIEditorFeature",
                BitValues = {
                    GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
                }
            },
            [23] = {
                Name = "Spawner",
                Tags = {"StageAPIEditorFeature", "Triggerable"},
                BlockEntities = true,
                HasPersistentData = true,
                BitValues = {
                    GroupID = {Offset = 0, Length = 14, ValueOffset = -1},
                    SpawnAll = {Offset = 14, Length = 1},
                    SingleActivation = {Offset = 15, Length = 1}
                }
            },
            [24] = {
                Name = "PreventRandomization"
            },
            [25] = {
                Name = "BridgeFailsafe",
                Tag = "StageAPIEditorFeature"
            },
            [26] = {
                Name = "DetonatorTrigger",
                Tag = "StageAPIEditorFeature",
                BitValues = {
                    GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
                }
            },
            [27] = {
                Name = "DoorLocker"
            },
            [28] = {
                Name = "GridDestroyer",
                Tags = {"StageAPIEditorFeature", "Triggerable"},
                BitValues = {
                    GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
                }
            },
            [29] = {
                Name = "ButtonTrigger",
                Tag = "StageAPILoadEditorFeature",
                BitValues = {
                    GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
                }
            },
            [30] = {
                Name = "BossIdentifier"
            },
        }
    }

    mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
        if npc.Variant ~= StageAPI.E.DeleteMeNPC.Variant then
            StageAPI.LogErr("Something is wrong! A StageAPI metadata entity has spawned when it should have been removed.")
        end
    end, StageAPI.E.MetaEntity.T)

    StageAPI.MetadataEntitiesByName = {}

    StageAPI.UnblockableEntities = {}

    for id, variants in pairs(StageAPI.MetadataEntities) do
        for variant, metadata in pairs(variants) do
            metadata.Variant = variant
            metadata.Type = id
            StageAPI.MetadataEntitiesByName[metadata.Name] = metadata
        end
    end

    function StageAPI.AddMetadataEntity(data, id, variant)
        if not StageAPI.MetadataEntities[id] then
            StageAPI.MetadataEntities[id] = {}
        end

        data.Type = id
        data.Variant =  variant

        if data.Group then -- backwards compatibility features
            if not data.Tags then
                data.Tags = {}
            end

            data.Tags[#data.Tags + 1] = data.Group

            if data.Conflicts then
                data.ConflictTag = data.Group
            end
        end

        if data.StoreAsGroup then
            data.GroupID = data.Name
        end

        StageAPI.MetadataEntities[id][variant] = data
        StageAPI.MetadataEntitiesByName[data.Name] = data
    end

    function StageAPI.AddMetadataEntities(tbl)
        if type(next(tbl)) == "table" and next(tbl).Name then
            for variant, data in pairs(tbl) do
                StageAPI.AddMetadataEntity(data, 199, variant)
            end
        else
            for id, variantTable in pairs(tbl) do
                for variant, data in pairs(variantTable) do
                    StageAPI.AddMetadataEntity(data, id, variant)
                end
            end
        end
    end

    function StageAPI.IsMetadataEntity(etype, variant)
        if type(etype) == "table" then
            variant = etype.Variant
            etype = etype.Type
        end

        return StageAPI.MetadataEntities[etype] and StageAPI.MetadataEntities[etype][variant]
    end

    function StageAPI.RoomDataHasMetadataEntity(data)
        local spawns = data.Spawns
        for i = 0, spawns.Size do
            local spawn = spawns:Get(i)
            if spawn then
                local sumWeight = spawn.SumWeights
                local weight = 0
                for i = 1, spawn.EntryCount do
                    local entry = spawn:PickEntry(weight)
                    weight = weight + entry.Weight / sumWeight

                    if StageAPI.IsMetadataEntity(entry.Type, entry.Variant) then
                        return true
                    end
                end
            end
        end

        return false
    end

    function StageAPI.AddUnblockableEntities(etype, variant, subtype) -- an entity that will not be blocked by the Spawner or other BlockEntities triggers
        if type(etype) == "table" then
            for _, ent in ipairs(etype) do
                StageAPI.AddUnblockableEntities(ent[1], ent[2], ent[3])
            end
        else
            if not StageAPI.UnblockableEntities[etype] then
                if variant then
                    StageAPI.UnblockableEntities[etype] = {}
                    if subtype then
                        StageAPI.UnblockableEntities[etype][variant] = {}
                        StageAPI.UnblockableEntities[etype][variant][subtype] = true
                    else
                        StageAPI.UnblockableEntities[etype][variant] = true
                    end
                else
                    StageAPI.UnblockableEntities[etype] = true
                end
            end
        end
    end

    function StageAPI.IsEntityUnblockable(etype, variant, subtype)
        return StageAPI.UnblockableEntities[etype] == true
        or StageAPI.UnblockableEntities[etype] and (StageAPI.UnblockableEntities[etype][variant] == true
        or (StageAPI.UnblockableEntities[etype][variant] and StageAPI.UnblockableEntities[etype][variant][subtype] == true))
    end

    StageAPI.RoomMetadata = StageAPI.Class("RoomMetadata")

    function StageAPI.RoomMetadata:Init()
        self.Groups = {}
        self.BlockedEntities = {}
        self.IndexMetadata = {}
    end

    function StageAPI.RoomMetadata:GroupsWithIndex(index)
        local groups = {}
        for groupID, indices in pairs(self.Groups) do
            if indices[index] or not index then
                groups[#groups + 1] = groupID
            end
        end

        return groups
    end

    function StageAPI.RoomMetadata:IsIndexInGroup(index, group)
        return self.Groups[group] and self.Groups[group][index]
    end

    function StageAPI.RoomMetadata:IndicesInGroup(group)
        local indices = self.Groups[group]
        local out = {}
        for index, _ in pairs(indices) do
            out[#out + 1] = index
        end

        return out
    end

    function StageAPI.RoomMetadata:AddIndexToGroup(index, group)
        if type(index) == "table" then
            for _, idx in ipairs(index) do
                self:RemoveIndexFromGroup(idx, group)
            end
        elseif type(group) == "table" then
            for _, grp in ipairs(group) do
                self:RemoveIndexFromGroup(index, grp)
            end
        else
            if not self.Groups[group] then
                self.Groups[group] = {}
            end

            self.Groups[group][index] = true
        end
    end

    function StageAPI.RoomMetadata:RemoveIndexFromGroup(index, group)
        if type(index) == "table" then
            for _, idx in ipairs(index) do
                self:AddIndexToGroup(idx, group)
            end
        elseif type(group) == "table" then
            for _, grp in ipairs(group) do
                self:AddIndexToGroup(index, grp)
            end
        elseif self.Groups[group] and self.Groups[group][index] then
            self.Groups[group][index] = nil
        end
    end

    function StageAPI.RoomMetadata:GetNextGroupID()
        if not self.LastGroupID then
            self.LastGroupID = 0
        end

        self.LastGroupID = self.LastGroupID - 1
        return self.LastGroupID
    end

    function StageAPI.RoomMetadata:AddMetadataEntity(index, entity, persistentIndex) -- also accepts a name rather than an entity
        if not self.IndexMetadata[index] then
            self.IndexMetadata[index] = {}
        end

        local metadata
        if entity and type(entity) ~= "string" then
            metadata = StageAPI.IsMetadataEntity(entity)
        else
            if entity then
                name = entity
                entity = nil
            end

            metadata = StageAPI.MetadataEntitiesByName[name]
        end

        local metaEntity = {
            Name = metadata.Name,
            Metadata = metadata,
            Entity = entity or {Type = metadata.Type, Variant = metadata.Variant},
            Index = index
        }

        if metadata.BitValues then
            local sub = 0
            if entity and entity.SubType then
                sub = entity.SubType
            end

            metaEntity.BitValues = {}
            for name, bitValue in pairs(metadata.BitValues) do
                local val = StageAPI.GetBits(sub, bitValue.Offset or 0, bitValue.Length) + (bitValue.ValueOffset or 0)
                metaEntity.BitValues[name] = val
            end
        end

        if metadata.HasPersistentData then
            persistentIndex = (persistentIndex and persistentIndex + 1) or 0
            metaEntity.PersistentIndex = persistentIndex
        end

        self.IndexMetadata[index][#self.IndexMetadata[index] + 1] = metaEntity

        return metaEntity, persistentIndex
    end

    --[[

    METADATA SEARCH PARAMS

    {
        Name = string, -- Matches "Name" from metadata entity data

        Indices = { -- List of indices to search for metadata entities on
            GridIndex,
            ...
        },
        Index = GridIndex, -- Singular version of Indices

        Groups = { -- List of group ids to search for metadata entities contained within
            GroupID,
            ...
        },
        Group = GroupID, -- Singular version of Groups
        RequireAllGroups = boolean, -- If set to true, will only return metadata entities within ALL of the specified groups.

        IndicesOrGroups = boolean, -- If set to true, will return if either Groups works out or Indices works out, rather than requiring both

        Tags = { -- List of tags to search for metadata entities with "Tag = string" matching the tag, or "Tags = {"string"}" containing the tag
            string,
            ...
        },
        Tag = string, -- Singular version of Tags
        RequireAllTags = boolean, -- If set to true, will only return metadata entities with ALL of the specified tags.

        Metadata = { -- Checks each metadata entity's data for the specified keys and values, only returns if all match
            Key = Value
        },

        Entity = { -- Checks each metadata entity for the specified keys and values, only returns if all match
            Key = Value
        },

        BitValues = { -- Checks each metadata entity's BitValues for the specified keys and values, only returns if all match
            Key = Value
        },
    }

    ]]

    function StageAPI.RoomMetadata:IndexMatchesSearchParams(index, searchParams, checkIndices, checkGroups)
        if not checkIndices then
            checkIndices = searchParams.Indices or {}
            checkIndices[#checkIndices + 1] = searchParams.Index
            for _, index in ipairs(checkIndices) do
                checkIndices[index] = true
            end
        end

        local indexMatches = true
        if #checkIndices > 0 and not checkIndices[index] then
            if searchParams.IndicesOrGroups then
                indexMatches = false
            else
                return false
            end
        end

        if not checkGroups then
            checkGroups = searchParams.Groups or {}
            checkGroups[#checkGroups + 1] = searchParams.Group
        end

        local groupMatches = true
        if #checkGroups > 0 then
            local hasGroup
            for _, groupID in ipairs(checkGroups) do
                if self.Groups[groupID] and self.Groups[groupID][index] then
                    hasGroup = true
                    if not searchParams.RequireAllGroups then
                        break
                    end
                elseif searchParams.RequireAllGroups then
                    if searchParams.IndicesOrGroups then
                        groupMatches = false
                    else
                        return false
                    end
                end
            end

            if not hasGroup then
                if searchParams.IndicesOrGroups then
                    groupMatches = false
                else
                    return false
                end
            end
        end

        if searchParams.IndicesOrGroups then
            return indexMatches or groupMatches
        else
            return true
        end
    end

    function StageAPI.RoomMetadata:EntityMatchesSearchParams(metadataEntity, searchParams, checkTags)
        if searchParams.Name and metadataEntity.Name ~= searchParams.Name then
            return false
        end

        local metadata = metadataEntity.Metadata

        if not checkTags then
            checkTags = searchParams.Tags or {}
            checkTags[#checkTags + 1] = searchParams.Tag
        end

        if #checkTags > 0 then
            local hasTag
            for _, tag in ipairs(checkTags) do
                if metadata.Tag == tag or (metadata.Tags and StageAPI.IsIn(metadata.Tags, tag)) then
                    hasTag = true
                    if not searchParams.RequireAllTags then
                        break
                    end
                elseif searchParams.RequireAllTags then
                    return false
                end
            end

            if not hasTag then
                return false
            end
        end

        if searchParams.Metadata then
            for k, v in pairs(searchParams.Metadata) do
                if metadata[k] ~= v then
                    return false
                end
            end
        end

        if searchParams.Entity then
            for k, v in pairs(searchParams.Entity) do
                if metadataEntity[k] ~= v then
                    return false
                end
            end
        end

        if searchParams.BitValues then
            if not metadataEntity.BitValues then
                return false
            end

            for k, v in pairs(searchParams.BitValues) do
                if metadataEntity.BitValues[k] ~= v then
                    return false
                end
            end
        end

        return true
    end

    function StageAPI.RoomMetadata:Search(searchParams, narrowEntities)
        searchParams = searchParams or {}
        local checkIndices, checkGroups, checkTags = searchParams.Indices or {}, searchParams.Groups or {}, searchParams.Tags or {}
        checkIndices[#checkIndices + 1] = searchParams.Index
        checkGroups[#checkGroups + 1] = searchParams.Group
        checkTags[#checkTags + 1] = searchParams.Tag

        for _, index in ipairs(checkIndices) do
            checkIndices[index] = true
        end

        local matchingEntities = {}
        if narrowEntities then
            for _, metadataEntity in ipairs(narrowEntities) do
                if self:IndexMatchesSearchParams(metadataEntity.Index, searchParams, checkIndices, checkGroups) then
                    if self:EntityMatchesSearchParams(metadataEntity, searchParams, checkTags) then
                        matchingEntities[#matchingEntities + 1] = metadataEntity
                    end
                end
            end
        else
            for index, metadataEntities in pairs(self.IndexMetadata) do
                if self:IndexMatchesSearchParams(index, searchParams, checkIndices, checkGroups) then
                    for _, metadataEntity in ipairs(metadataEntities) do
                        if self:EntityMatchesSearchParams(metadataEntity, searchParams, checkTags) then
                            matchingEntities[#matchingEntities + 1] = metadataEntity
                        end
                    end
                end
            end
        end

        return matchingEntities
    end

    function StageAPI.RoomMetadata:Has(searchParams, narrowEntities)
        return #self:Search(searchParams, narrowEntities) > 0
    end

    function StageAPI.RoomMetadata:GetDirections(index)
        local directions = self:Search({Name = "Direction", Index = index})
        local outDirections = {}
        for _, direction in ipairs(directions) do
            local angle = direction.Entity.SubType * (360 / 16)
            outDirections[#outDirections + 1] = angle
        end

        return outDirections
    end

    function StageAPI.SeparateEntityMetadata(entities, grids, seed)
        StageAPI.RoomLoadRNG:SetSeed(seed or room:GetSpawnSeed(), 1)
        local outEntities = {}
        local roomMetadata = StageAPI.RoomMetadata()

        local persistentIndex

        for index, entityList in pairs(entities) do
            local outList = {}
            for _, entity in ipairs(entityList) do
                local metadata = StageAPI.IsMetadataEntity(entity.Type, entity.Variant)
                if metadata then
                    local _, newPersistentIndex = roomMetadata:AddMetadataEntity(index, entity, persistentIndex)
                    persistentIndex = newPersistentIndex
                else
                    outList[#outList + 1] = entity
                end
            end

            outEntities[index] = outList
        end

        local outGrids = {}
        for index, gridList in pairs(grids) do
            outGrids[index] = gridList
        end

        StageAPI.CallCallbacks("PRE_PARSE_METADATA", false, roomMetadata, outEntities, outGrids, StageAPI.RoomLoadRNG)

        for index, metadataEntities in pairs(roomMetadata.IndexMetadata) do
            local setsOfConflicting = {}
            for _, metaEntity in StageAPI.ReverseIterate(metadataEntities) do
                local metadata = metaEntity.Metadata
                if metadata.ConflictTag and not setsOfConflicting[metadata.ConflictTag] then
                    local shouldConflict = true
                    if metadata.PreventConflictWith or metadata.OnlyConflictWith then
                        if metadata.PreventConflictWith then
                            shouldConflict = not roomMetadata:Has({Index = index, Name = metadata.PreventConflictWith})
                        elseif metadata.OnlyConflictWith then
                            shouldConflict = roomMetadata:Has({Index = index, Name = metadata.OnlyConflictWith})
                        end
                    end

                    if shouldConflict then
                        setsOfConflicting[metadata.ConflictTag] = {}

                        for i, metaEntity2 in StageAPI.ReverseIterate(metadataEntities) do
                            local metadata2 = StageAPI.MetadataEntitiesByName[metaEntity2.Name]
                            if metadata2.ConflictTag and metadata2.ConflictTag == metadata.ConflictTag then
                                setsOfConflicting[metadata.ConflictTag][#setsOfConflicting[metadata.ConflictTag] + 1] = metaEntity
                                table.remove(metadataEntities, i)
                            end
                        end
                    end
                end
            end

            for conflictTag, metaEntities in pairs(setsOfConflicting) do
                local use = metaEntities[StageAPI.Random(1, #metaEntities, StageAPI.RoomLoadRNG)]
                metaEntities[#metadataEntities + 1] = use
            end

            for _, metaEntity in ipairs(metadataEntities) do
                local metadata = StageAPI.MetadataEntitiesByName[metaEntity.Name]

                local groupID
                if metaEntity.BitValues and metaEntity.BitValues.GroupID and metaEntity.BitValues.GroupID ~= -1 then
                    groupID = metaEntity.BitValues.GroupID
                elseif metadata.GroupID then
                    groupID = metadata.GroupID
                end

                if groupID then
                    roomMetadata:AddIndexToGroup(index, groupID)
                end
            end

            if #roomMetadata:GroupsWithIndex(index) == 0 then
                for _, metaEntity in ipairs(metadataEntities) do
                    local groupID = metaEntity.Metadata.GroupIDIfUngrouped
                    if groupID then
                        if not roomMetadata.Groups[groupID] then
                            roomMetadata.Groups[groupID] = {}
                        end

                        roomMetadata.Groups[groupID][index] = true
                    end
                end
            end
        end

        StageAPI.CallCallbacks("POST_PARSE_METADATA", nil, roomMetadata, outEntities, outGrids)

        return outEntities, outGrids, roomMetadata, persistentIndex
    end

    function StageAPI.AddEntityToSpawnList(tbl, entData, persistentIndex, index)
        local currentRoom = StageAPI.CurrentlyInitializing or StageAPI.GetCurrentRoom()
        if persistentIndex == nil and currentRoom then
            persistentIndex = currentRoom.LastPersistentIndex
            if currentRoom.LastPersistentIndex then
                currentRoom.LastPersistentIndex = currentRoom.LastPersistentIndex + 1
            end
        end

        if index and (tbl[index] and type(tbl[index]) == "table") then
            tbl = tbl[index]
        end

        entData = StageAPI.Copy(entData)

        entData.Type = entData.Type or 10
        entData.Variant = entData.Variant or 0
        entData.SubType = entData.SubType or 0
        entData.Index = entData.Index or index or 0

        if not entData.GridX or not entData.GridY then
            local width
            if currentRoom and currentRoom.Layout and currentRoom.Layout.Width then
                width = currentRoom.Layout.Width
            else
                width = room:GetGridWidth()
            end

            entData.GridX, entData.GridY = StageAPI.GridToVector(index, width)
        end

        persistentIndex = persistentIndex + 1

        local persistentData = StageAPI.CheckPersistence(entData.Type, entData.Variant, entData.SubType)

        tbl[#tbl + 1] = {
            Data = entData,
            PersistentIndex = persistentIndex,
            Persistent = not not persistentData
        }

        return persistentIndex
    end

    function StageAPI.SelectSpawnEntities(entities, seed, roomMetadata, lastPersistentIndex)
        StageAPI.RoomLoadRNG:SetSeed(seed or room:GetSpawnSeed(), 1)
        local entitiesToSpawn = {}
        local callbacks = StageAPI.GetCallbacks("PRE_SELECT_ENTITY_LIST")
        local persistentIndex = (lastPersistentIndex and lastPersistentIndex + 1) or 0
        for index, entityList in pairs(entities) do
            if #entityList > 0 then
                local addEntities = {}
                local overridden, stillAddRandom = false, nil
                for _, callback in ipairs(callbacks) do
                    local retAdd, retList, retRandom = callback.Function(entityList, index, roomMetadata)
                    if retRandom ~= nil and stillAddRandom == nil then
                        stillAddRandom = retRandom
                    end

                    if retAdd == false then
                        overridden = true
                    else
                        if retAdd and type(retAdd) == "table" then
                            addEntities = retAdd
                            overridden = true
                        end

                        if retList and type(retList) == "table" then
                            entityList = retList
                            overridden = true
                        end
                    end

                    if overridden then
                        break
                    end
                end

                if not overridden or (stillAddRandom and #entityList > 0) then
                    addEntities[#addEntities + 1] = entityList[StageAPI.Random(1, #entityList, StageAPI.RoomLoadRNG)]
                end

                if #addEntities > 0 then
                    if not entitiesToSpawn[index] then
                        entitiesToSpawn[index] = {}
                    end

                    for _, entData in ipairs(addEntities) do
                        persistentIndex = StageAPI.AddEntityToSpawnList(entitiesToSpawn[index], entData, persistentIndex)
                    end
                end
            end
        end

        return entitiesToSpawn, persistentIndex
    end

    function StageAPI.SelectSpawnGrids(gridsByIndex, seed)
        StageAPI.RoomLoadRNG:SetSeed(seed or room:GetSpawnSeed(), 1)
        local spawnGrids = {}

        local callbacks = StageAPI.GetCallbacks("PRE_SELECT_GRIDENTITY_LIST")
        for index, grids in pairs(gridsByIndex) do
            if #grids > 0 then
                local spawnGrid, noSpawnGrid
                for _, callback in ipairs(callbacks) do
                    local ret = callback.Function(grids, index)
                    if ret == false then
                        noSpawnGrid = true
                        break
                    elseif type(ret) == "table" then
                        if ret.Index then
                            spawnGrid = ret
                        else
                            grids = ret
                        end

                        break
                    end
                end

                if not noSpawnGrid then
                    if not spawnGrid then
                        spawnGrid = grids[StageAPI.Random(1, #grids, StageAPI.RoomLoadRNG)]
                    end

                    if spawnGrid then
                        spawnGrids[index] = spawnGrid
                    end
                end
            end
        end

        return spawnGrids
    end

    function StageAPI.ObtainSpawnObjects(layout, seed)
        local entitiesByIndex, gridsByIndex, roomMetadata, lastPersistentIndex = StageAPI.SeparateEntityMetadata(layout.EntitiesByIndex, layout.GridEntitiesByIndex, seed)
        local spawnEntities, lastPersistentIndex = StageAPI.SelectSpawnEntities(entitiesByIndex, seed, roomMetadata)
        local spawnGrids = StageAPI.SelectSpawnGrids(gridsByIndex, seed)

        local gridTakenIndices = {}
        local entityTakenIndices = {}

        for index, entity in pairs(spawnEntities) do
            entityTakenIndices[index] = true
        end

        for index, gridData in pairs(spawnGrids) do
            gridTakenIndices[index] = true
        end

        return spawnEntities, spawnGrids, entityTakenIndices, gridTakenIndices, lastPersistentIndex, roomMetadata
    end

    StageAPI.ActiveEntityPersistenceData = {}
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        StageAPI.ActiveEntityPersistenceData = {}
    end)

    function StageAPI.GetEntityPersistenceData(entity)
        local ent = StageAPI.ActiveEntityPersistenceData[GetPtrHash(entity)]
        if ent then
            return ent.Index, ent.Data
        end
    end

    function StageAPI.SetEntityPersistenceData(entity, persistentIndex, persistenceData)
        StageAPI.ActiveEntityPersistenceData[GetPtrHash(entity)] = {
            Index = persistentIndex,
            Data = persistenceData
        }
    end

    function StageAPI.LoadEntitiesFromEntitySets(entitysets, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, loadingWave)
        local ents_spawned = {}
        local listCallbacks = StageAPI.GetCallbacks("PRE_SPAWN_ENTITY_LIST")
        local entCallbacks = StageAPI.GetCallbacks("PRE_SPAWN_ENTITY")
        if type(entitysets) ~= "table" then
            entitysets = {entitysets}
        end

        for _, entities in ipairs(entitysets) do
            for index, entityList in pairs(entities) do
                if #entityList > 0 then
                    local shouldSpawn = true
                    for _, callback in ipairs(listCallbacks) do
                        local ret = callback.Function(entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData)
                        if ret == false then
                            shouldSpawn = false
                            break
                        elseif ret and type(ret) == "table" then
                            entityList = ret
                            break
                        end
                    end

                    if shouldSpawn and #entityList > 0 then
                        local roomType = room:GetType()
                        for _, entityInfo in ipairs(entityList) do
                            local shouldSpawnEntity = true

                            if shouldSpawnEntity and avoidSpawning and avoidSpawning[entityInfo.PersistentIndex] then
                                shouldSpawnEntity = false
                            end

                            local entityPersistData, persistData
                            if entityInfo.Persistent then
                                if entityInfo.PersistentIndex then
                                    entityPersistData = persistenceData[entityInfo.PersistentIndex]
                                    if entityPersistData then
                                        entityInfo.Data.Type = entityPersistData.Type or entityInfo.Data.Type
                                        entityInfo.Data.Variant = entityPersistData.Variant or entityInfo.Data.Variant
                                        entityInfo.Data.SubType = entityPersistData.SubType or entityInfo.Data.SubType

                                        if entityPersistData.Position then
                                            entityInfo.Position = Vector(entityPersistData.Position.X, entityPersistData.Position.Y)
                                        end
                                    end
                                end

                                persistData = StageAPI.CheckPersistence(entityInfo.Data.Type, entityInfo.Data.Variant, entityInfo.Data.SubType)
                            end

                            if shouldSpawnEntity and doPersistentOnly and not persistData then
                                shouldSpawnEntity = false
                            end

                            if shouldSpawnEntity and persistData and persistData.AutoPersists and not doAutoPersistent then
                                shouldSpawnEntity = false
                            end

                            if not entityInfo.Position then
                                entityInfo.Position = room:GetGridPosition(index)
                            end

                            for _, callback in ipairs(entCallbacks) do
                                if not callback.Params[1] or (entityInfo.Data.Type and callback.Params[1] == entityInfo.Data.Type)
                                and not callback.Params[2] or (entityInfo.Data.Variant and callback.Params[2] == entityInfo.Data.Variant)
                                and not callback.Params[3] or (entityInfo.Data.SubType and callback.Params[3] == entityInfo.Data.SubType) then
                                    local ret = callback.Function(entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, shouldSpawnEntity)
                                    if ret == false or ret == true then
                                        shouldSpawnEntity = ret
                                        break
                                    elseif ret and type(ret) == "table" then
                                        if ret.Data then
                                            entityInfo = ret
                                        else
                                            entityInfo.Data.Type = ret[1] == 999 and 1000 or ret[1]
                                            entityInfo.Data.Variant = ret[2]
                                            entityInfo.Data.SubType = ret[3]
                                        end
                                        break
                                    end
                                end
                            end

                            if shouldSpawnEntity then
                                local entityData = entityInfo.Data
                                if doGrids or (entityData.Type > 9 and entityData.Type ~= EntityType.ENTITY_FIREPLACE) then
									local ent = Isaac.Spawn(
                                        entityData.Type or 20,
                                        entityData.Variant or 0,
                                        entityData.SubType or 0,
                                        entityInfo.Position or StageAPI.ZeroVector,
                                        StageAPI.ZeroVector,
                                        nil
                                    )

                                    if entityPersistData and entityPersistData.Health then
                                        ent.HitPoints = entityPersistData.Health
                                    end

                                    local currentRoom = StageAPI.GetCurrentRoom()
                                    if currentRoom and not currentRoom.IgnoreRoomRules then
                                        if entityData.Type == EntityType.ENTITY_PICKUP and entityData.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                                            if currentRoom.RoomType == RoomType.ROOM_TREASURE then
                                                if currentRoom.Layout.Variant > 0 or string.find(string.lower(currentRoom.Layout.Name), "choice") or string.find(string.lower(currentRoom.Layout.Name), "choose") then
                                                    ent:ToPickup().OptionsPickupIndex = 1
                                                end

                                                local isShopItem
                                                for _, player in ipairs(players) do
                                                    if player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
                                                        isShopItem = true
                                                        break
                                                    end
                                                end

                                                if isShopItem then
                                                    ent:ToPickup().Price = 15
            										ent:ToPickup().AutoUpdatePrice = true
                                                end
                                            end
                                        end
                                    end

                                    ent:GetData().StageAPISpawnedPosition = entityInfo.Position or StageAPI.ZeroVector
                                    ent:GetData().StageAPIEntityListIndex = index

                                    if entityInfo.Persistent then
                                        StageAPI.SetEntityPersistenceData(ent, entityInfo.PersistentIndex, persistData)
                                    end

                                    if not loadingWave and ent:CanShutDoors() then
                                        StageAPI.Room:SetClear(false)
                                    end

                                    StageAPI.CallCallbacks("POST_SPAWN_ENTITY", false, ent, entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, shouldSpawnEntity)

                                    ents_spawned[#ents_spawned + 1] = ent
                                end
                            end
                        end
                    end
                end
            end
        end

        return ents_spawned
    end

    function StageAPI.CallGridPostInit()
        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)
            if grid then
                grid:PostInit()

                if StageAPI.RockTypes[grid.Desc.Type] then
                    grid:ToRock():UpdateAnimFrame()
                end
            end
        end
    end

    StageAPI.GridSpawnRNG = RNG()
    function StageAPI.LoadGridsFromDataList(grids, gridInformation, entities)
        local grids_spawned = {}
        StageAPI.GridSpawnRNG:SetSeed(room:GetSpawnSeed(), 0)
        local callbacks = StageAPI.GetCallbacks("PRE_SPAWN_GRID")

        local iterList = gridInformation or grids

        for index, gridData in pairs(iterList) do
            local shouldSpawn = true
            for _, callback in ipairs(callbacks) do
                local ret = callback.Function(gridData, gridInformation, entities, StageAPI.GridSpawnRNG)
                if ret == false then
                    shouldSpawn = false
                    break
                elseif type(ret) == "table" then
                    gridData = ret
                end
            end

            if shouldSpawn and StageAPI.Room:IsPositionInRoom(StageAPI.Room:GetGridPosition(index), 0) then
                room:RemoveGridEntity(index, 0, false)
                local grid = Isaac.GridSpawn(gridData.Type, gridData.Variant, StageAPI.Room:GetGridPosition(index), true)
                if grid then
                    if gridInformation and gridInformation[index] then
                        local grinformation = gridInformation[index]
                        if grinformation.State ~= nil then
                            grid.State = grinformation.State
                            if grinformation.State == 4 and gridData.Type == GridEntityType.GRID_TNT then
                                grid:ToTNT().FrameCnt = -1
                            end
                        end

                        if grinformation.VarData ~= nil then
                            grid.VarData = grinformation.VarData
                        end

                        if grid.Desc.Type == GridEntityType.GRID_ROCK and grinformation.Frame then
                            grid:ToRock():SetBigRockFrame(grinformation.Frame)
                        end
                    end

                    local sprite = grid:GetSprite()
                    if grid:ToPoop() then
                        if grid.State == 1000 then
                            sprite:Play("State5", true)
                        elseif grid.State > 666 then
                            sprite:Play("State4", true)
                        elseif grid.State > 333 then
                            sprite:Play("State3", true)
                        elseif grid.State > 0 then
                            sprite:Play("State2", true)
                        else
                            sprite:Play("State1", true)
                        end

                        sprite:SetLastFrame()
                    elseif grid:ToTNT() then
                        if grid.State == 0 then
                            sprite:Play("Idle", true)
                        elseif grid.State < 3 then
                            sprite:Play("IdleMedium", true)
                        elseif grid.State == 3 then
                            sprite:Play("ReadyToExplode", true)
                        else
                            sprite:Play("Blown", true)
                        end

                        sprite:SetLastFrame()
                    elseif grid:ToPressurePlate() then
                        if grid.State == 3 then
                            local anim = sprite:GetAnimation()
                            if anim == "OffSkull" then
                                sprite:Play("OnSkull", true)
                            elseif anim == "OffPentagram" then
                                sprite:Play("OnPentagram", true)
                            else
                                sprite:Play("On", true)
                            end
                        end
                    elseif grid:ToSpikes() then
                        if grid.State == 1 then
                            local anim = sprite:GetAnimation()
                            local firstLetters = string.sub(anim, 1, 4)
                            if anim == "Summon" or firstLetters ~= "Womb" then
                                sprite:Play("Unsummon", true)
                                sprite:SetLastFrame()
                            else
                                sprite:Play("UnsummonWomb", true)
                                sprite:SetLastFrame()
                            end
                        end
                    elseif grid.Desc.Type == GridEntityType.GRID_LOCK then
                        if grid.State == 1 then
                            sprite:Play("Broken", true)
                            grid.CollisionClass = GridCollisionClass.COLLISION_NONE
                        end
                    end

                    if gridData.Type == GridEntityType.GRID_PRESSURE_PLATE and gridData.Variant == 0 and grid.State ~= 3 then
                        StageAPI.Room:SetClear(false)
                    end

                    grids_spawned[#grids_spawned + 1] = grid
                end
            end
        end

        return grids_spawned
    end

    function StageAPI.GetGridInformation()
        local gridInformation = {}
        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)
            if grid and grid.Desc.Type ~= GridEntityType.GRID_DOOR and (grid.Desc.Type ~= GridEntityType.GRID_WALL or room:IsPositionInRoom(grid.Position, 0)) then
                gridInformation[i] = {
                    State = grid.State,
                    VarData = grid.VarData,
                    Type = grid.Desc.Type,
                    Variant = grid.Desc.Variant
                }

                if grid.Desc.Type == GridEntityType.GRID_ROCK then
                    gridInformation[i].Frame = grid:ToRock():GetBigRockFrame()
                end
            end
        end

        return gridInformation
    end

    function StageAPI.LoadRoomLayout(grids, entities, doGrids, doEntities, doPersistentOnly, doAutoPersistent, gridData, avoidSpawning, persistenceData, loadingWave)
        local grids_spawned = {}
        local ents_spawned = {}

        if grids and doGrids then
            grids_spawned = StageAPI.LoadGridsFromDataList(grids, gridData, entities)
        end

        if entities and doEntities then
            ents_spawned = StageAPI.LoadEntitiesFromEntitySets(entities, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, loadingWave)
        end

        StageAPI.CallGridPostInit()

        return ents_spawned, grids_spawned
    end

    function StageAPI.GetCurrentRoomID()
        if (StageAPI.ActiveTransitionToExtraRoom or StageAPI.LoadedExtraRoom) then
            return StageAPI.CurrentExtraRoomName
        else
            return StageAPI.GetCurrentListIndex()
        end
    end

    StageAPI.LevelRooms = {}
    function StageAPI.GetDimension(roomDesc)
        roomDesc = roomDesc or level:GetCurrentRoomDesc()
        if roomDesc.GridIndex < 0 then -- Off-grid rooms
            return -2
        end

        local hash = GetPtrHash(roomDesc)
        for dimension = 0, 2 do
            local dimensionDesc = level:GetRoomByIdx(roomDesc.SafeGridIndex, dimension)
            if GetPtrHash(dimensionDesc) == hash then
                return dimension
            end
        end
    end

    function StageAPI.GetTableIndexedByDimension(tbl, setIfNot, dimension)
        dimension = dimension or StageAPI.GetDimension()
        if setIfNot and not tbl[dimension] then
            tbl[dimension] = {}
        end

        return tbl[dimension]
    end

    function StageAPI.GetLevelRoom(roomID, dimension)
        dimension = dimension or StageAPI.GetDimension()
        return StageAPI.LevelRooms[dimension] and StageAPI.LevelRooms[dimension][roomID]
    end

    function StageAPI.GetAllLevelRooms()
        local levelRooms = {}
        for dimension, rooms in pairs(StageAPI.LevelRooms) do
            for index, levelRoom in pairs(rooms) do
                levelRooms[#levelRooms + 1] = levelRoom
            end
        end

        return levelRooms
    end

    function StageAPI.SetLevelRoom(levelRoom, roomID, dimension)
        dimension = dimension or StageAPI.GetDimension()
        if not StageAPI.LevelRooms[dimension] then
            StageAPI.LevelRooms[dimension] = {}
        end

        StageAPI.LevelRooms[dimension][roomID] = levelRoom

        if levelRoom then
            levelRoom.LevelIndex = roomID
            levelRoom.Dimension = dimension
        end
    end

    function StageAPI.SetCurrentRoom(room)
        StageAPI.ActiveEntityPersistenceData = {}
        StageAPI.SetLevelRoom(room, StageAPI.GetCurrentRoomID())
    end

    function StageAPI.GetCurrentRoom()
        return StageAPI.GetLevelRoom(StageAPI.GetCurrentRoomID())
    end

    function StageAPI.GetCurrentRoomType()
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom then
            return currentRoom.TypeOverride or currentRoom.RoomType or room:GetType()
        else
            return room:GetType()
        end
    end

    function StageAPI.GetRooms()
        return StageAPI.LevelRooms
    end

    function StageAPI.CloseDoors()
        for i = 0, 7 do
            local door = room:GetDoor(i)
            if door then
                door:Close()
            end
        end
    end

    function StageAPI.GetDoorsForRoom()
        local doors = {}
        for i = 0, 7 do
            doors[i] = not not room:GetDoor(i)
        end
        return doors
    end

    StageAPI.AllDoorsOpen = {}
    for i = 0, 7 do
        StageAPI.AllDoorsOpen[i] = true
    end

    function StageAPI.GetDoorsForRoomFromData(data)
        local doors = {}
        for i = 0, 7 do
            doors[i] = data.Doors & StageAPI.DoorsBitwise[i] ~= 0
        end

        return doors
    end

    function StageAPI.LevelRoomArgPacker(layoutName, roomsList, seed, shape, roomType, isExtraRoom, fromSaveData, requireRoomType, ignoreDoors, doors, levelIndex, ignoreRoomRules)
        return {
            LayoutName = layoutName,
            RoomsList = roomsList,
            SpawnSeed = seed,
            Shape = shape,
            RoomType = roomType,
            IsExtraRoom = isExtraRoom,
            FromSave = fromSaveData,
            RequireRoomType = requireRoomType,
            IgnoreDoors = ignoreDoors,
            Doors = doors,
            LevelIndex = levelIndex,
            IgnoreRoomRules = ignoreRoomRules
        }
    end

    local levelRoomCopyFromArgs = {"IsExtraRoom","LevelIndex","Doors","Shape","RoomType","SpawnSeed","LayoutName","RequireRoomType","IgnoreRoomRules","DecorationSeed","AwardSeed","VisitCount","IsClear","ClearCount","IsPersistentRoom","HasWaterPits","ChallengeDone","FromData","Dimension"}

    StageAPI.LevelRoom = StageAPI.Class("LevelRoom")
    StageAPI.NextUniqueRoomIdentifier = 0
    function StageAPI.LevelRoom:Init(args, ...)
        if type(args) ~= "table" then
            args = StageAPI.LevelRoomArgPacker(args, ...)
        end

        StageAPI.LogMinor("Initializing room")
        StageAPI.CurrentlyInitializing = self
        self.UniqueRoomIdentifier = StageAPI.NextUniqueRoomIdentifier
        StageAPI.NextUniqueRoomIdentifier = StageAPI.NextUniqueRoomIdentifier + 1

        if args.FromSave then
            StageAPI.LogMinor("Loading from save data")
            self:LoadSaveData(args.FromSave)
        else
            StageAPI.LogMinor("Generating room")

            local roomDesc = args.RoomDescriptor

            self.Data = {}
            self.PersistentData = {}
            self.AvoidSpawning = {}
            self.ExtraSpawn = {}
            self.PersistenceData = {}
            self.FirstLoad = true

            for _, v in ipairs(levelRoomCopyFromArgs) do
                if args[v] ~= nil then
                    self[v] = args[v]
                end
            end

            self.RoomType = self.RoomType or (roomDesc and roomDesc.Data.Type) or RoomType.ROOM_DEFAULT
            self.Shape = self.Shape or (roomDesc and roomDesc.Data.Shape) or RoomShape.ROOMSHAPE_1x1
            self.SpawnSeed = self.SpawnSeed or (roomDesc and roomDesc.SpawnSeed) or Random()
            self.DecorationSeed = self.DecorationSeed or (roomDesc and roomDesc.DecorationSeed) or Random()
            self.AwardSeed = self.AwardSeed or (roomDesc and roomDesc.AwardSeed) or Random()
            self.SurpriseMiniboss = self.SurpriseMiniboss or (roomDesc and roomDesc.SurpriseMiniboss) or false
            self.Doors = self.Doors or (roomDesc and StageAPI.GetDoorsForRoomFromData(roomDesc.Data)) or StageAPI.Copy(StageAPI.AllDoorsOpen)
            self.VisitCount = self.VisitCount or (roomDesc and roomDesc.VisitedCount) or 0
            self.ClearCount = self.ClearCount or (roomDesc and roomDesc.ClearCount) or 0

            self.Dimension = self.Dimension or StageAPI.GetDimension(roomDesc)

            -- backwards compatibility
            self.Seed = self.SpawnSeed

            local layout = args.Layout
            if args.FromData then
                local roomDesc = level:GetRooms():Get(args.FromData)
                if roomDesc then
                    layout = StageAPI.GenerateRoomLayoutFromData(roomDesc.Data)
                end
            elseif not layout then
                local replaceLayoutName = StageAPI.CallCallbacks("PRE_ROOM_LAYOUT_CHOOSE", true, self)
                if replaceLayoutName then
                    StageAPI.LogMinor("Layout replaced")
                    self.LayoutName = replaceLayoutName
                end

                if self.LayoutName then
                    layout = StageAPI.Layouts[self.LayoutName]
                end

                if not layout then
                    local roomsList = StageAPI.CallCallbacks("PRE_ROOMS_LIST_USE", true, self) or args.RoomsList
                    self.RoomsListName = roomsList.Name
                    layout = StageAPI.ChooseRoomLayout(roomsList, self.SpawnSeed, self.Shape, self.RoomType, self.RequireRoomType, self.IgnoreDoors, self.Doors)
                end
            end

            self.Layout = layout
            self:PostGetLayout(self.SpawnSeed)
        end

        StageAPI.CallCallbacks("POST_ROOM_INIT", false, self, not not fromSaveData, fromSaveData)
        StageAPI.CurrentlyInitializing = nil
    end

    function StageAPI.LevelRoom:Copy(roomDesc)
        local args = {
            RoomDescriptor = roomDesc,
            Layout = self.Layout,
            LayoutName = self.LayoutName,
            RoomsListName = self.RoomsListName
        }

        for _, v in ipairs(levelRoomCopyFromArgs) do
            args[v] = args[v] or self[v]
        end

        local newLevelRoom = StageAPI.LevelRoom(args)
        newLevelRoom.PersistentData = StageAPI.DeepCopy(self.PersistentData)
        newLevelRoom.Data = StageAPI.DeepCopy(self.Data)

        return newLevelRoom
    end

    function StageAPI.LevelRoom:PostGetLayout(seed)
        if not self.Layout then
            if self.Shape == -1 then
                self.Shape = RoomShape.ROOMSHAPE_1x1
            end

            self.Layout = StageAPI.CreateEmptyRoomLayout(self.Shape)
            StageAPI.LogErr("No layout!")
        end

        StageAPI.LogMinor("Initialized room " .. self.Layout.Name .. "." .. tostring(self.Layout.Variant) .. " from file " .. tostring(self.Layout.RoomFilename)
                            .. (roomsList and (' from list ' .. roomsList.Name) or ''))

        if self.Shape == -1 then
            self.Shape = self.Layout.Shape
        end

        self.SpawnEntities, self.SpawnGrids, self.EntityTakenIndices, self.GridTakenIndices, self.LastPersistentIndex, self.Metadata = StageAPI.ObtainSpawnObjects(self.Layout, seed)
    end

    --[[ Deprecated functions, prefer to use LevelRoom.Metadata:<Search/Has/Etc>
    function StageAPI.LevelRoom:SetEntityMetadata(index, name)
        self.Metadata:AddMetadataEntity(index, name)
    end

    function StageAPI.LevelRoom:HasEntityMetadata(index, name)
        return self.Metadata:Has({
            Index = index,
            Name = name
        })
    end

    function StageAPI.LevelRoom:GetEntityMetadata(index, name)
        local search = self.Metadata:Search({
            Index = index,
            Name = name
        })

        if index and name then
            return (#search > 0) and #search
        end

        local out = {}
        for _, metadataEntity in ipairs(search) do
            if not name then
                out[metadataEntity.Name] = (out[metadataEntity.Name] or 0) + 1
            elseif not index then
                out[metadataEntity.Index] = (out[metadataEntity.Index] or 0) + 1
            end
        end

        return out
    end

    function StageAPI.LevelRoom:GetEntityMetadataOfType(metatype, index)
        local search = self.Metadata:Search({
            Index = index,
            Tag = metatype,
        })

        if index then
            local includedMetadata = {}
            for _, metadataEntity in ipairs(search) do
                includedMetadata[#includedMetadata + 1] = metadataEntity.Name
            end

            return includedMetadata
        else
            local includedMetadataByIndex = {}
            for _, metadataEntity in ipairs(search) do
                local index = metadataEntity.Index
                includedMetadataByIndex[index] = includedMetadataByIndex[index] or {}
                includedMetadataByIndex[index][#includedMetadataByIndex[index] + 1] = metadataEntity.Name
            end

            return includedMetadataByIndex
        end
    end

    function StageAPI.LevelRoom:GetEntityMetadataGroups(index)
        return self.Metadata:GroupsWithIndex(index)
    end

    function StageAPI.LevelRoom:IndicesShareGroup(index, index2, specificGroup)
        if specificGroup then
            return self.Metadata:IsIndexInGroup(index, specificGroup) and self.Metadata:IsIndexInGroup(index2, specificGroup)
        else
            local groups = self.Metadata:GroupsWithIndex(index)
            for _, group in ipairs(groups) do
                if self.Metadata:IsIndexInGroup(index2, group) then
                    return true
                end
            end
        end

        return false
    end

    function StageAPI.LevelRoom:GetIndicesInGroup(group)
        return self.Metadata:IndicesInGroup(group)
    end

    function StageAPI.LevelRoom:GroupHasMetadata(group, name)
        return self.Metadata:Has({
            Group = group,
            Name = name
        })
    end]]

    function StageAPI.LevelRoom:IsGridIndexFree(index, ignoreEntities, ignoreGrids)
        return (ignoreEntities or not self.EntityTakenIndices[index]) and (ignoreGrids or not self.GridTakenIndices[index])
    end

    function StageAPI.LevelRoom:SaveGridInformation()
        self.GridInformation = StageAPI.GetGridInformation()
    end

    function StageAPI.LevelRoom:GetPersistenceData(index, setIfNot)
        if type(index) ~= "number" then
            if index.Metadata then
                index = index.PersistentIndex
            else
                index = StageAPI.GetEntityPersistenceData(index)
            end
        end

        if index then
            if setIfNot and not self.PersistenceData[index] then
                self.PersistenceData[index] = {}
            end

            return self.PersistenceData[index]
        end
    end

    function StageAPI.LevelRoom:SavePersistentEntities()
        local checkExistenceOf = {}
        for hash, entityPersistData in pairs(StageAPI.ActiveEntityPersistenceData) do
            if entityPersistData.Data.RemoveOnRemove then
                checkExistenceOf[hash] = entityPersistData
            end
        end

        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            checkExistenceOf[GetPtrHash(entity)] = nil

            local data = entity:GetData()
            local persistentIndex, persistData = StageAPI.GetEntityPersistenceData(entity)
            if persistentIndex then
                local changedSpawn
                local entityPersistData = self:GetPersistenceData(persistentIndex, true)
                if persistData.UpdateType then
                    if entity.Type ~= entityPersistData.Type then
                        entityPersistData.Type = entity.Type
                        changedSpawn = true
                    end
                end

                if persistData.UpdateVariant then
                    if entity.Variant ~= entityPersistData.Variant then
                        entityPersistData.Variant = entity.Variant
                        changedSpawn = true
                    end
                end

                if persistData.UpdateSubType then
                    if entity.SubType ~= entityPersistData.SubType then
                        entityPersistData.SubType = entity.SubType
                        changedSpawn = true
                    end
                end

                if persistData.UpdateHealth then
                    if entity.HitPoints ~= entityPersistData.Health then
                        entityPersistData.Health = entity.HitPoints
                    end
                end

                if persistData.UpdatePosition then
                    entityPersistData.Position = {X = entity.Position.X, Y = entity.Position.Y}
                end

                if persistData.StoreCheck and persistData.StoreCheck(entity, data) then
                    self.AvoidSpawning[persistentIndex] = true
                end

                if changedSpawn then
                    local newPersistData = StageAPI.CheckPersistence(entity.Type, entity.Variant, entity.SubType)
                    if not newPersistData then
                        StageAPI.RemovePersistentEntity(entity)
                    else
                        StageAPI.SetEntityPersistenceData(entity, persistentIndex, newPersistData)
                    end
                end
            else
                local persistData = StageAPI.CheckPersistence(entity.Type, entity.Variant, entity.SubType)
                if persistData then
                    if not persistData.StoreCheck or not persistData.StoreCheck(entity, data) then
                        local index = self.LastPersistentIndex + 1
                        self.LastPersistentIndex = index
                        local grindex = room:GetGridIndex(entity.Position)
                        if not self.ExtraSpawn[grindex] then
                            self.ExtraSpawn[grindex] = {}
                        end

                        local spawnData = {
                            Type = entity.Type,
                            Variant = entity.Variant,
                            SubType = entity.SubType,
                            Index = grindex
                        }

                        local spawnInfo = {
                            Data = spawnData,
                            Persistent = true,
                            PersistentIndex = index
                        }

                        self.ExtraSpawn[grindex][#self.ExtraSpawn[grindex] + 1] = spawnInfo

                        local entityPersistData = self:GetPersistenceData(index, true)
                        if persistData.UpdateHealth then
                            entityPersistData.Health = entity.HitPoints
                        end

                        if persistData.UpdatePosition then
                            entityPersistData.Position = {X = entity.Position.X, Y = entity.Position.Y}
                        end

                        StageAPI.SetEntityPersistenceData(entity, index, persistData)
                    end
                end
            end
        end

        for hash, entityPersistData in pairs(checkExistenceOf) do
            self.AvoidSpawning[entityPersistData.Index] = true
        end
    end

    function StageAPI.LevelRoom:RemovePersistentIndex(persistentIndex)
        self.AvoidSpawning[persistentIndex] = true
    end

    function StageAPI.LevelRoom:RemovePersistentEntity(entity)
        local index, data = StageAPI.GetEntityPersistenceData(entity)
        if index and data then
            self:RemovePersistentIndex(index)
        end
    end

    function StageAPI.LevelRoom:Load(isExtraRoom, noIncrementVisit)
        StageAPI.LogMinor("Loading room " .. self.Layout.Name .. "." .. tostring(self.Layout.Variant) .. " from file " .. tostring(self.Layout.RoomFilename))
        if isExtraRoom == nil then
            isExtraRoom = self.IsExtraRoom
        end

        room:SetClear(true)

        if not noIncrementVisit then
            self.VisitCount = self.VisitCount + 1
        end

        local wasFirstLoad = self.FirstLoad
        StageAPI.ClearRoomLayout(false, self.FirstLoad or isExtraRoom, true, self.FirstLoad or isExtraRoom, self.GridTakenIndices, nil, nil, not self.FirstLoad)
        if self.FirstLoad then
            StageAPI.LoadRoomLayout(self.SpawnGrids, {self.SpawnEntities, self.ExtraSpawn}, true, true, self.IsClear, true, self.GridInformation, self.AvoidSpawning, self.PersistenceData)
            self.WasClearAtStart = room:IsClear()
            self.IsClear = self.WasClearAtStart
            self.FirstLoad = false
            self.HasEnemies = room:GetAliveEnemiesCount() > 0
        else
            StageAPI.LoadRoomLayout(self.SpawnGrids, {self.SpawnEntities, self.ExtraSpawn}, isExtraRoom, true, self.IsClear, isExtraRoom, self.GridInformation, self.AvoidSpawning, self.PersistenceData)
            self.IsClear = room:IsClear()
        end

        StageAPI.CalledRoomUpdate = true
        room:Update()
        StageAPI.CalledRoomUpdate = false
        if not self.IsClear then
            StageAPI.CloseDoors()
        end

        self.Loaded = true

        StageAPI.CallCallbacks("POST_ROOM_LOAD", false, self, wasFirstLoad, isExtraRoom)
        StageAPI.StoreRoomGrids()
    end

    function StageAPI.LevelRoom:Save()
        self:SavePersistentEntities()
        self:SaveGridInformation()
    end

    local saveDataCopyDirectly = {
        "IsClear","WasClearAtStart","RoomsListName","LayoutName","SpawnSeed","AwardSeed","DecorationSeed",
        "FirstLoad","Shape","RoomType","TypeOverride","PersistentData","IsExtraRoom","LastPersistentIndex",
        "RequireRoomType", "IgnoreRoomRules", "VisitCount", "ClearCount", "LevelIndex","HasWaterPits","ChallengeDone",
        "SurpriseMiniboss", "FromData"
    }

    function StageAPI.LevelRoom:GetSaveData(isExtraRoom)
        if isExtraRoom == nil then
            isExtraRoom = self.IsExtraRoom
        end

        local saveData = {}

        for _, v in ipairs(saveDataCopyDirectly) do
            saveData[v] = self[v]
        end

        if isExtraRoom ~= nil then
            saveData.IsExtraRoom = isExtraRoom
        end

        if self.Doors then
            saveData.Doors = {}
            for i = 0, 7 do
                if self.Doors[i] then
                    saveData.Doors[#saveData.Doors + 1] = i
                end
            end
        end

        if self.GridInformation then
            for index, gridInfo in pairs(self.GridInformation) do
                if not saveData.GridInformation then
                    saveData.GridInformation = {}
                end

                saveData.GridInformation[tostring(index)] = gridInfo
            end
        end

        for index, avoid in pairs(self.AvoidSpawning) do
            if avoid then
                if not saveData.AvoidSpawning then
                    saveData.AvoidSpawning = {}
                end

                saveData.AvoidSpawning[#saveData.AvoidSpawning + 1] = index
            end
        end

        for pindex, persistData in pairs(self.PersistenceData) do
            if not saveData.PersistenceData then
                saveData.PersistenceData = {}
            end

            saveData.PersistenceData[tostring(pindex)] = persistData
        end

        for index, entities in pairs(self.ExtraSpawn) do
            if not saveData.ExtraSpawn then
                saveData.ExtraSpawn = {}
            end

            saveData.ExtraSpawn[tostring(index)] = entities
        end

        return saveData
    end

    function StageAPI.LevelRoom:LoadSaveData(saveData)
        self.Data = {}
        self.AvoidSpawning = {}
        self.PersistenceData = {}
        self.ExtraSpawn = {}

        for _, v in ipairs(saveDataCopyDirectly) do
            self[v] = saveData[v]
        end

        self.Seed = self.AwardSeed -- backwards compatibility
        self.PersistentData = self.PersistentData or {}

        if saveData.Doors then
            self.Doors = {}
            for _, door in ipairs(saveData.Doors) do
                self.Doors[door] = true
            end

            for i = 0, 7 do
                if not self.Doors[i] then
                    self.Doors[i] = false
                end
            end
        end

        local layout
        if self.FromData and not layout then
            local roomDesc = level:GetRooms():Get(self.FromData)
            if roomDesc then
                layout = StageAPI.GenerateRoomLayoutFromData(roomDesc.Data)
            end
        end

        if self.LayoutName and not layout then
            layout = StageAPI.Layouts[layoutName]
        end

        if self.RoomsListName and not layout then
            local roomsList = StageAPI.RoomsLists[self.RoomsListName]
            if roomsList then
                local retLayout = StageAPI.CallCallbacks("PRE_ROOM_LAYOUT_CHOOSE", true, self, roomsList)
                if retLayout then
                    layout = retLayout
                else
                    layout = StageAPI.ChooseRoomLayout(roomsList, self.SpawnSeed, self.Shape, self.RoomType, self.RequireRoomType, false, self.Doors)
                end
            end
        end

        self.Layout = layout
        self:PostGetLayout(self.SpawnSeed)

        self.LastPersistentIndex = self.LastPersistentIndex or self.LastPersistentIndex

        if saveData.GridInformation then
            for strindex, gridInfo in pairs(saveData.GridInformation) do
                if not self.GridInformation then
                    self.GridInformation = {}
                end

                self.GridInformation[tonumber(strindex)] = gridInfo
            end
        end

        if saveData.AvoidSpawning then
            for _, index in ipairs(saveData.AvoidSpawning) do
                self.AvoidSpawning[index] = true
            end
        end

        if saveData.PersistenceData then
            for pindex, persistData in pairs(saveData.PersistenceData) do
                self.PersistenceData[tonumber(strindex)] = persistData
            end
        end

        if saveData.ExtraSpawn then
            for strindex, entities in pairs(saveData.ExtraSpawn) do
                self.ExtraSpawn[tonumber(strindex)] = entities
            end
        end
    end

    function StageAPI.LevelRoom:SetTypeOverride(override)
        self.TypeOverride = override
    end

    function StageAPI.LevelRoom:GetType()
        return self.TypeOverride or self.RoomType
    end

    function StageAPI.RemovePersistentEntity(entity)
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom then
            currentRoom:RemovePersistentEntity(entity)
        end
    end

    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, ent)
        local index, data = StageAPI.GetEntityPersistenceData(ent)
        -- Entities are removed whenever you exit the room, in this time the game is paused, which we can use to stop removing persistent entities on room exit.
        if data and data.RemoveOnRemove and not game:IsPaused() then
            StageAPI.RemovePersistentEntity(ent)
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, ent)
        local index, data = StageAPI.GetEntityPersistenceData(ent)
        if data and data.RemoveOnDeath then
            StageAPI.RemovePersistentEntity(ent)
        end
    end)

    function StageAPI.IsDoorSlotAllowed(slot)
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom and currentRoom.Layout and currentRoom.Layout.Doors then
            for _, door in ipairs(currentRoom.Layout.Doors) do
                if door.Slot == slot and door.Exists then
                    return true
                end
            end
        else
            return room:IsDoorSlotAllowed(slot)
        end
    end

    function StageAPI.SetRoomFromList(roomsList, roomType, requireRoomType, isExtraRoom, load, seed, shape, fromSaveData)
        local levelIndex = StageAPI.GetCurrentRoomID()
        local newRoom = StageAPI.LevelRoom(nil, roomsList, seed, shape, roomType, isExtraRoom, fromSaveData, requireRoomType, nil, nil, levelIndex)
        StageAPI.SetCurrentRoom(newRoom)

        if load then
            newRoom:Load(isExtraRoom)
        end

        return newRoom
    end
end

StageAPI.LogMinor("Loading Custom Grid System")
do -- Custom Grid Entities
    StageAPI.CustomGridTypes = {}
    StageAPI.CustomGrid = StageAPI.Class("CustomGrid")
    function StageAPI.CustomGrid:Init(name, baseType, baseVariant, anm2, animation, frame, variantFrames, offset, overrideGridSpawns, overrideGridSpawnAtState, forceSpawning, noOverrideGridSprite)
        self.Name = name
        self.BaseType = baseType
        self.BaseVariant = baseVariant
        self.Anm2 = anm2
        self.Animation = animation
        self.Frame = frame
        self.VariantFrames = variantFrames
        self.OverrideGridSpawns = overrideGridSpawns
        self.OverrideGridSpawnState = overrideGridSpawnAtState
        self.NoOverrideGridSprite = noOverrideGridSprite
        self.ForceSpawning = forceSpawning
        self.Offset = offset

        StageAPI.CustomGridTypes[name] = self
    end

    StageAPI.DefaultBrokenGridStateByType = {
        [GridEntityType.GRID_ROCK]      = 2,
        [GridEntityType.GRID_ROCKB]     = 2,
        [GridEntityType.GRID_ROCKT]     = 2,
        [GridEntityType.GRID_ROCK_SS]   = 2,
        [GridEntityType.GRID_ROCK_BOMB] = 2,
        [GridEntityType.GRID_ROCK_ALT]  = 2,
        [GridEntityType.GRID_SPIDERWEB] = 1,
        [GridEntityType.GRID_LOCK]      = 1,
        [GridEntityType.GRID_TNT]       = 4,
        [GridEntityType.GRID_FIREPLACE] = 4,
        [GridEntityType.GRID_POOP]      = 1000,
    }

    StageAPI.CustomGrids = {}
    function StageAPI.SetCustomGrid(grindex, gridName, persistData, roomID, dimension)
        roomID = roomID or StageAPI.GetCurrentRoomID()

        local customGrids = StageAPI.GetTableIndexedByDimension(StageAPI.CustomGrids, true, dimension)

        customGrids[roomID] = customGrids[roomID] or {}
        customGrids[roomID][gridName] = customGrids[roomID][gridName] or {}
        customGrids[roomID][gridName][grindex] = persistData or {}

        return customGrids[roomID][gridName][grindex]
    end

    function StageAPI.CustomGrid:Spawn(grindex, force, reSpawning, startPersistData)
        local grid
        if self.BaseType then
            if not reSpawning then
                force = force or self.ForceSpawning
                grid = Isaac.GridSpawn(self.BaseType, self.BaseVariant or 0, room:GetGridPosition(grindex), force)
            else
                grid = room:GetGridEntity(grindex)
            end

            if self.OverrideGridSpawns and grid then
                local overrideState = self.OverrideGridSpawnState or StageAPI.DefaultBrokenGridStateByType[grid.Desc.Type] or 2
                if grid.State ~= overrideState then
                    StageAPI.SpawnOverriddenGrids[grindex] = self.OverrideGridSpawnState or overrideState
                end
            end

            if self.Anm2 and grid then
                local sprite = grid:GetSprite()
                sprite:Load(self.Anm2, true)
                if self.VariantFrames or self.Frame then
                    local animation = self.Animation or sprite:GetDefaultAnimation()
                    if self.VariantFrames then
                        sprite:SetFrame(animation, StageAPI.Random(0, self.VariantFrames))
                    else
                        sprite:SetFrame(animation, self.Frame)
                    end
                elseif self.Animation then
                    sprite:Play(self.Animation, true)
                end

                if self.Offset then
                    sprite.Offset = self.Offset
                end
            end
        end

        local gridData = StageAPI.GetCustomGrid(grindex, self.Name)
        local persistData
        if not gridData then
            persistData = StageAPI.SetCustomGrid(grindex, self.Name, startPersistData)
        else
            persistData = gridData.PersistData
        end

        for _, callback in ipairs(StageAPI.GetCallbacks("POST_SPAWN_CUSTOM_GRID")) do
            if not callback.Params[1] or callback.Params[1] == self.Name then
                callback.Function(grindex, force, reSpawning, grid, persistData, self)
            end
        end

        return grid
    end

    function StageAPI.GetCustomGrids(index, name)
        local dimension = StageAPI.GetDimension()
        local lindex = StageAPI.GetCurrentRoomID()
        if StageAPI.CustomGrids[dimension] and StageAPI.CustomGrids[dimension][lindex] then
            local customGrids = StageAPI.CustomGrids[dimension][lindex]
            local ret = {}
            if name then
                local grindices = customGrids[name]
                if grindices then
                    if index then
                        local persistData = grindices[index]
                        if persistData then
                            return {
                                Name = name,
                                PersistData = persistData,
                                Data = StageAPI.CustomGridTypes[name],
                                Index = index
                            }
                        else
                            return
                        end
                    else
                        for grindex, persistData in pairs(grindices) do
                            ret[#ret + 1] = {
                                Name = name,
                                PersistData = persistData,
                                Data = StageAPI.CustomGridTypes[name],
                                Index = grindex
                            }
                        end
                    end
                elseif index then
                    return
                end
            else
                for name, grindices in pairs(customGrids) do
                    for grindex, persistData in pairs(grindices) do
                        if not index or grindex == index then
                            ret[#ret + 1] = {
                                Name = name,
                                PersistData = persistData,
                                Data = StageAPI.CustomGridTypes[name],
                                Index = grindex
                            }
                        end
                    end
                end
            end

            return ret
        elseif index and name then
            return
        end

        return {}
    end

    function StageAPI.GetCustomGridsByName(name)
        return StageAPI.GetCustomGrids(nil, name)
    end

    function StageAPI.GetCustomGridIndicesByName(name)
        local ret = {}
        for _, grid in ipairs(StageAPI.GetCustomGrids(nil, name)) do
            ret[#ret + 1] = grid.Index
        end

        return ret
    end

    function StageAPI.GetCustomGrid(index, name)
        return StageAPI.GetCustomGrids(index, name)
    end

    function StageAPI.GetCustomGridsAtIndex(index)
        return StageAPI.GetCustomGrids(index)
    end

    function StageAPI.RemoveCustomGrid(index, name, keepVanillaGrid)
        local lindex = StageAPI.GetCurrentRoomID()
        local gridDat = StageAPI.GetCustomGrid(index, name)
        if gridDat then
            local customGrids = StageAPI.GetTableIndexedByDimension(StageAPI.CustomGrids, true)
            customGrids[lindex][name][index] = nil

            if not keepVanillaGrid then
                room:RemoveGridEntity(index, 0, false)
            end

            local callbacks = StageAPI.GetCallbacks("POST_CUSTOM_GRID_REMOVE")
            for _, callback in ipairs(callbacks) do
                if not callback.Params[1] or callback.Params[1] == name then
                    callback.Function(index, gridDat.PersistData, StageAPI.CustomGridTypes[name], name)
                end
            end
        end
    end

    function StageAPI.IsCustomGrid(index, name)
        if name then
            return not not StageAPI.GetCustomGrid(index, name)
        else
            return #StageAPI.GetCustomGridsAtIndex(index) > 0
        end
    end

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        local currentRoom = StageAPI.GetCurrentRoom()
        if room:GetFrameCount() <= 0 or (currentRoom and not currentRoom.Loaded) then
            return
        end

        local customGrids = StageAPI.GetCustomGrids()
        for _, customGrid in ipairs(customGrids) do
            local customGridType = customGrid.Data
            local grid = room:GetGridEntity(customGrid.Index)
            if not grid and customGridType.BaseType then
                StageAPI.RemoveCustomGrid(customGrid.Index, customGrid.Name, true)
            else
                local callbacks = StageAPI.GetCallbacks("POST_CUSTOM_GRID_UPDATE")
                for _, callback in ipairs(callbacks) do
                    if not callback.Params[1] or callback.Params[1] == customGrid.Name then
                        callback.Function(grid, customGrid.Index, customGrid.PersistData, customGridType, customGrid.Name)
                    end
                end
            end
        end
    end)
end

StageAPI.LogMinor("Loading Extra Room Handler")
do -- Extra Rooms
    StageAPI.InExtraRoom = false
    StageAPI.LoadedExtraRoom = false
    StageAPI.CurrentExtraRoom = nil
    StageAPI.CurrentExtraRoomName = nil
    function StageAPI.SetExtraRoom(name, room)
        StageAPI.SetLevelRoom(room, name, -2)
    end

    function StageAPI.GetExtraRoom(name)
        return StageAPI.GetLevelRoom(name, -2)
    end

    StageAPI.ActiveTransitionToExtraRoom = nil
    StageAPI.ActiveTransitionFromExtraRoom = nil
    function StageAPI.InOrTransitioningToExtraRoom()
        return StageAPI.ActiveTransitionToExtraRoom or StageAPI.InExtraRoom
    end

    function StageAPI.TransitioningToOrFromExtraRoom()
        return StageAPI.ActiveTransitionToExtraRoom or StageAPI.ActiveTransitionFromExtraRoom
    end

    function StageAPI.TransitioningToExtraRoom()
        return StageAPI.ActiveTransitionToExtraRoom
    end

    function StageAPI.TransitioningFromExtraRoom()
        return StageAPI.ActiveTransitionFromExtraRoom
    end

    StageAPI.RoomTransitionOverlay = Sprite()
    StageAPI.RoomTransitionOverlay:Load("stageapi/overlay_black.anm2", false)
    StageAPI.RoomTransitionOverlay:ReplaceSpritesheet(0, "stageapi/overlay_black.png")
    StageAPI.RoomTransitionOverlay:LoadGraphics()
    StageAPI.RoomTransitionOverlay:Play("Idle", true)
    function StageAPI.RenderBlackScreen(alpha)
        alpha = alpha or 1
        StageAPI.RoomTransitionOverlay.Scale = StageAPI.GetScreenScale(true) * 8
        StageAPI.RoomTransitionOverlay.Color = Color(1, 1, 1, alpha, 0, 0, 0)
        StageAPI.RoomTransitionOverlay:Render(StageAPI.GetScreenCenterPosition(), zeroVector, zeroVector)
    end

    function StageAPI.TransitionToExtraRoom(name, exitSlot, skipTransition, extraRoomBaseType)
        StageAPI.ExtraRoomTransition(name, Direction.NO_DIRECTION, RoomTransitionAnim.FADE, false, nil, exitSlot, nil, extraRoomBaseType)
    end

    function StageAPI.TransitionFromExtraRoom(toIndex, exitSlot)
        StageAPI.ExtraRoomTransition(toIndex, Direction.NO_DIRECTION, RoomTransitionAnim.FADE, false, nil, exitSlot)
    end

    if not RoomType.ROOM_SECRET_EXIT then
        RoomType.ROOM_SECRET_EXIT = 27
    end

    if not RoomType.ROOM_BLUE then
        RoomType.ROOM_BLUE = 28
    end

    StageAPI.RoomTypeToGotoPrefix = {
        [RoomType.ROOM_DEFAULT] = "d.",
        [RoomType.ROOM_SHOP] = "s.shop.",
        [RoomType.ROOM_ERROR] = "s.error.",
        [RoomType.ROOM_TREASURE] = "s.treasure.",
        [RoomType.ROOM_BOSS] = "s.boss.",
        [RoomType.ROOM_MINIBOSS] = "s.miniboss.",
        [RoomType.ROOM_SECRET] = "s.secret.",
        [RoomType.ROOM_SUPERSECRET] = "s.supersecret.",
        [RoomType.ROOM_ARCADE] = "s.arcade.",
        [RoomType.ROOM_CURSE] = "s.curse.",
        [RoomType.ROOM_CHALLENGE] = "s.challenge.",
        [RoomType.ROOM_LIBRARY] = "s.library.",
        [RoomType.ROOM_SACRIFICE] = "s.sacrifice.",
        [RoomType.ROOM_DEVIL] = "s.devil.",
        [RoomType.ROOM_ANGEL] = "s.angel.",
        [RoomType.ROOM_DUNGEON] = "s.itemdungeon.",
        [RoomType.ROOM_BOSSRUSH] = "s.bossrush.",
        [RoomType.ROOM_ISAACS] = "s.isaacs.",
        [RoomType.ROOM_BARREN] = "s.barren.",
        [RoomType.ROOM_CHEST] = "s.chest.",
        [RoomType.ROOM_DICE] = "s.dice.",
        [RoomType.ROOM_BLACK_MARKET] = "s.blackmarket.",
        [RoomType.ROOM_GREED_EXIT] = "s.greedexit.",
        [RoomType.ROOM_PLANETARIUM] = "s.planetarium.",
        [RoomType.ROOM_TELEPORTER] = "s.teleporter.",
        [RoomType.ROOM_TELEPORTER_EXIT] = "s.teleporterexit.",
        [RoomType.ROOM_SECRET_EXIT] = "s.secretexit.",
        [RoomType.ROOM_BLUE] = "s.blue.",
        [RoomType.ROOM_ULTRASECRET] = "s.ultrasecret.",
    }

    StageAPI.RoomShapeToGotoData = {
        [RoomShape.ROOMSHAPE_1x1] = {
            ID = "70050"
        },
        [RoomShape.ROOMSHAPE_IH] = {
            ID = "70051"
        },
        [RoomShape.ROOMSHAPE_IV] = {
            ID = "70052"
        },
        [RoomShape.ROOMSHAPE_1x2] = {
            ID = "70053",
            Locked = "70062"
        },
        [RoomShape.ROOMSHAPE_IIV] = {
            ID = "70054"
        },
        [RoomShape.ROOMSHAPE_2x1] = {
            ID = "70055",
            Locked = "70063"
        },
        [RoomShape.ROOMSHAPE_IIH] = {
            ID = "70056"
        },
        [RoomShape.ROOMSHAPE_2x2] = {
            ID = "70057",
            Locked = "70064"
        },
        [RoomShape.ROOMSHAPE_LTL] = {
            ID = "70058",
            Locked = "70065"
        },
        [RoomShape.ROOMSHAPE_LTR] = {
            ID = "70059",
            Locked = "70066"
        },
        [RoomShape.ROOMSHAPE_LBL] = {
            ID = "70060",
            Locked = "70067"
        },
        [RoomShape.ROOMSHAPE_LBR] = {
            ID = "70061",
            Locked = "70068"
        }
    }

    for shape, gotoData in pairs(StageAPI.RoomShapeToGotoData) do
        gotoData.Data = {}
        if gotoData.Locked then
            gotoData.LockedData = {}
        end
    end

    StageAPI.PreloadedGotoData = {}
    function StageAPI.PreloadGotoRooms(roomTypes, roomShapes)
        if not roomShapes then
            roomShapes = {}
            for shape = 1, RoomShape.NUM_ROOMSHAPES - 1 do
                roomShapes[#roomShapes + 1] = shape
            end
        end

        for _, roomType in ipairs(roomTypes) do
            local shapes = StageAPI.PreloadedGotoData[roomType]
            if not shapes then
                shapes = {}
                StageAPI.PreloadedGotoData[roomType] = shapes
            end

            for _, roomShape in ipairs(roomShapes) do
                if not shapes[roomShape] then
                    shapes[roomShape] = false
                end
            end
        end
    end

    local defaultSpecialRoomShapes = {
        RoomShape.ROOMSHAPE_1x1,
        RoomShape.ROOMSHAPE_IH,
        RoomShape.ROOMSHAPE_IV,
    }

    local defaultBossRoomShapes = {
        RoomShape.ROOMSHAPE_1x1,
        RoomShape.ROOMSHAPE_IH,
        RoomShape.ROOMSHAPE_IV,
        RoomShape.ROOMSHAPE_2x2,
        RoomShape.ROOMSHAPE_1x2,
        RoomShape.ROOMSHAPE_2x1,
    }

    local validDungeonShapes = {
        RoomShape.ROOMSHAPE_1x1,
        RoomShape.ROOMSHAPE_1x2,
        RoomShape.ROOMSHAPE_2x1,
        RoomShape.ROOMSHAPE_2x2,
    }

    local defaultBlueRoomShapes = {
        RoomShape.ROOMSHAPE_2x1,
        RoomShape.ROOMSHAPE_1x2,
        RoomShape.ROOMSHAPE_IIH,
        RoomShape.ROOMSHAPE_IIV,
    }

    local defaultShopRoomShapes = {
        RoomShape.ROOMSHAPE_1x1,
        RoomShape.ROOMSHAPE_IH,
        RoomShape.ROOMSHAPE_IV,
        RoomShape.ROOMSHAPE_2x1,
    }

    StageAPI.PreloadGotoRooms({RoomType.ROOM_DEFAULT})
    StageAPI.PreloadGotoRooms({RoomType.ROOM_BOSS}, defaultBossRoomShapes)
    StageAPI.PreloadGotoRooms({RoomType.ROOM_DUNGEON}, validDungeonShapes)
    StageAPI.PreloadGotoRooms({RoomType.ROOM_BLACK_MARKET}, {RoomShape.ROOMSHAPE_2x1})
    StageAPI.PreloadGotoRooms({RoomType.ROOM_BOSSRUSH}, {RoomShape.ROOMSHAPE_2x2})
    StageAPI.PreloadGotoRooms({RoomType.ROOM_BLUE}, defaultBlueRoomShapes)
    StageAPI.PreloadGotoRooms({RoomType.ROOM_SHOP}, defaultShopRoomShapes)
    StageAPI.PreloadGotoRooms({
        RoomType.ROOM_SECRET,
        RoomType.ROOM_SUPERSECRET,
        RoomType.ROOM_ULTRASECRET,
        RoomType.ROOM_GREED_EXIT,
    }, {RoomShape.ROOMSHAPE_1x1})
    StageAPI.PreloadGotoRooms({
        RoomType.ROOM_ERROR,
        RoomType.ROOM_TREASURE,
        RoomType.ROOM_MINIBOSS,
        RoomType.ROOM_ARCADE,
        RoomType.ROOM_CURSE,
        RoomType.ROOM_CHALLENGE,
        RoomType.ROOM_LIBRARY,
        RoomType.ROOM_SACRIFICE,
        RoomType.ROOM_DEVIL,
        RoomType.ROOM_ANGEL,
        RoomType.ROOM_ISAACS,
        RoomType.ROOM_BARREN,
        RoomType.ROOM_CHEST,
        RoomType.ROOM_DICE,
        RoomType.ROOM_SECRET_EXIT,
        RoomType.ROOM_PLANETARIUM,
    }, defaultSpecialRoomShapes)

    StageAPI.DataLoadNeedsRestart = false
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
        if not StageAPI.InTestMode then
            local needsToLoad
            for roomType, roomShapes in pairs(StageAPI.PreloadedGotoData) do
                for roomShape, loaded in pairs(roomShapes) do
                    if not loaded then
                        if not needsToLoad then
                            needsToLoad = {}
                        end

                        if not needsToLoad[roomType] then
                            needsToLoad[roomType] = {}
                        end

                        needsToLoad[roomType][#needsToLoad[roomType] + 1] = roomShape
                    end
                end
            end

            if needsToLoad then
                local resetRun
                local currentIndex = level:GetCurrentRoomIndex()
                if currentIndex == level:GetStartingRoomIndex() and room:IsFirstVisit() and level:GetStage() == LevelStage.STAGE1_1 then
                    resetRun = true
                end

                for roomType, roomShapes in pairs(needsToLoad) do
                    for _, shape in ipairs(roomShapes) do
                        local cmd, lockedCmd = StageAPI.GetGotoCommandForTypeShape(roomType, shape, true)
                        Isaac.ExecuteCommand(cmd)
                        local desc = level:GetRoomByIdx(GridRooms.ROOM_DEBUG_IDX)

                        local shapeData = StageAPI.RoomShapeToGotoData[shape]
                        shapeData.Data[roomType] = desc.Data

                        if lockedCmd and shapeData.LockedData then
                            Isaac.ExecuteCommand(lockedCmd)
                            local desc = level:GetRoomByIdx(GridRooms.ROOM_DEBUG_IDX)
                            shapeData.LockedData[roomType] = desc.Data
                        end

                        StageAPI.PreloadedGotoData[roomType][shape] = true
                    end
                end

                if resetRun then
                    StageAPI.DataLoadNeedsRestart = true
                end

                game:StartRoomTransition(currentIndex, Direction.NO_DIRECTION, 0)
            end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        if StageAPI.DataLoadNeedsRestart then
            Isaac.ExecuteCommand("restart")
            StageAPI.DataLoadNeedsRestart = nil
        end
    end)

    local shadowSprite = Sprite()
    shadowSprite:Load("stageapi/stage_shadow.anm2", false)
    shadowSprite:Play("1x1", true)
    local lastUsedShadowSpritesheet

    StageAPI.StoredExtraRoomThisPause = false

    function StageAPI.GetGotoCommandForTypeShape(roomType, roomShape, ignoreMissingData)
        local shapeData = StageAPI.RoomShapeToGotoData[roomShape]
        local prefix = "goto " .. StageAPI.RoomTypeToGotoPrefix[roomType]
        if shapeData.Data[roomType] or ignoreMissingData then
            return prefix .. shapeData.ID, (shapeData.Locked and (prefix .. shapeData.Locked))
        else
            return StageAPI.GetGotoCommandForTypeShape(RoomType.ROOM_DEFAULT, roomShape, true)
        end
    end

    function StageAPI.GetGotoDataForTypeShape(roomType, roomShape)
        local shapeData = StageAPI.RoomShapeToGotoData[roomShape]
        if shapeData.Data[roomType] then
            return shapeData.Data[roomType], (shapeData.LockedData and shapeData.LockedData[roomType])
        else
            return StageAPI.GetGotoDataForTypeShape(RoomType.ROOM_DEFAULT, roomShape)
        end
    end

    StageAPI.DoorOneSlots = {
        [DoorSlot.DOWN1] = true,
        [DoorSlot.UP1] = true,
        [DoorSlot.LEFT1] = true,
        [DoorSlot.RIGHT1] = true
    }

    StageAPI.DoorSlotToDirection = {
        [DoorSlot.LEFT0] = Direction.LEFT,
        [DoorSlot.LEFT1] = Direction.LEFT,
        [DoorSlot.RIGHT0] = Direction.RIGHT,
        [DoorSlot.RIGHT1] = Direction.RIGHT,
        [DoorSlot.UP0] = Direction.UP,
        [DoorSlot.UP1] = Direction.UP,
        [DoorSlot.DOWN0] = Direction.DOWN,
        [DoorSlot.DOWN1] = Direction.DOWN
    }

    StageAPI.LRoomShapes = {
        [RoomShape.ROOMSHAPE_LTL] = true,
        [RoomShape.ROOMSHAPE_LTR] = true,
        [RoomShape.ROOMSHAPE_LBL] = true,
        [RoomShape.ROOMSHAPE_LBR] = true
    }

    local function anyPlayerHas(id, trinket)
        for _, player in ipairs(players) do
            if trinket then
                if player:HasTrinket(id) then
                    return true
                end
            elseif player:HasCollectible(id) then
                return true
            end
        end

        return false
    end

    StageAPI.BaseGridRoomPriority = {
        GridRooms.ROOM_MEGA_SATAN_IDX,
        GridRooms.ROOM_BOSSRUSH_IDX,
        GridRooms.ROOM_THE_VOID_IDX,
        GridRooms.ROOM_ROTGUT_DUNGEON1_IDX,
    }

    StageAPI.BaseLGridRoomPriority = {
        GridRooms.ROOM_ANGEL_SHOP_IDX,
        GridRooms.ROOM_BLACK_MARKET_IDX,
        GridRooms.ROOM_DEBUG_IDX,
        GridRooms.ROOM_ROTGUT_DUNGEON2_IDX,
        GridRooms.ROOM_SECRET_SHOP_IDX,
        GridRooms.ROOM_ERROR_IDX
    }

    function StageAPI.GetNextFreeBaseGridRoom(priorityList, taken, nextIsBoss)
        local outIdx
        local stage = level:GetStage()
        for _, idx in ipairs(priorityList) do
            if not StageAPI.IsIn(taken, idx) then
                if idx == GridRooms.ROOM_MEGA_SATAN_IDX then
                    if stage ~= LevelStage.STAGE6 or game:IsGreedMode() then
                        outIdx = idx
                        break
                    end
                elseif idx == GridRooms.ROOM_BOSSRUSH_IDX then
                    if stage ~= LevelStage.STAGE3_2 or game:IsGreedMode() then
                        outIdx = idx
                        break
                    end
                elseif idx == GridRooms.ROOM_ROTGUT_DUNGEON1_IDX or idx == GridRooms.ROOM_ROTGUT_DUNGEON2_IDX then
                    local rooms = level:GetRooms()
                    local hasRotgutRoom
                    for i = 0, rooms.Size do
                        local desc = rooms:Get(i)
                        if desc and desc.Data.Type == RoomType.ROOM_BOSS and desc.Data.Subtype == 87 then
                            hasRotgutRoom = true
                            break
                        end
                    end

                    if not hasRotgutRoom then
                        local rotgutRoomSpawned = level:GetRoomByIdx(GridRooms.ROOM_ROTGUT_DUNGEON1_IDX).SpawnSeed ~= 0
                        if not rotgutRoomSpawned then
                            local rotgut = Isaac.Spawn(EntityType.ENTITY_ROTGUT, 0, 0, Vector.Zero, Vector.Zero, nil)
                            rotgut:Update()
                            rotgut:Remove()
                        end

                        outIdx = idx
                        break
                    end
                elseif idx == GridRooms.ROOM_SECRET_SHOP_IDX then
                    if not anyPlayerHas(CollectibleType.COLLECTIBLE_MEMBER_CARD)
                    or not (
                        stage <= LevelStage.STAGE3_2
                        or stage == LevelStage.STAGE4_3
                        or (anyPlayerHas(TrinketType.TRINKET_SILVER_DOLLAR) and stage <= LevelStage.STAGE4_2)
                    ) then
                        outIdx = idx
                        break
                    end
                elseif idx == GridRooms.ROOM_ANGEL_SHOP_IDX then
                    if not anyPlayerHas(CollectibleType.COLLECTIBLE_STAIRWAY)
                    or (
                        level:GetStartingRoomIndex() ~= level:GetCurrentRoomIndex()
                        and level:GetRoomByIdx(level:GetStartingRoomIndex()).VisitedCount > 0
                    )  then
                        outIdx = idx
                        break
                    end
                elseif idx == GridRooms.ROOM_BLACK_MARKET_IDX then
                    local dungeonRoom = level:GetRoomByIdx(GridRooms.ROOM_DUNGEON_IDX)
                    if not dungeonRoom or dungeonRoom.Data.Doors & StageAPI.DoorsBitwise[DoorSlot.RIGHT0] == 0 then
                        outIdx = idx
                        break
                    end
                elseif idx ~= GridRooms.ROOM_ERROR_IDX then
                    if not nextIsBoss then
                        if idx == GridRooms.ROOM_THE_VOID_IDX then
                            if level:GetStage() ~= LevelStage.STAGE3_4 or game:IsGreedMode() then
                                outIdx = idx
                                break
                            end
                        else
                            outIdx = idx
                            break
                        end
                    end
                else
                    outIdx = idx
                    break
                end
            end
        end

        taken[#taken + 1] = outIdx
        return outIdx
    end

    function StageAPI.GetExtraRoomBaseGridRooms(nextIsBoss)
        local taken = {}
        local default = StageAPI.GetNextFreeBaseGridRoom(StageAPI.BaseGridRoomPriority, taken, nextIsBoss)
        local alternate = StageAPI.GetNextFreeBaseGridRoom(StageAPI.BaseGridRoomPriority, taken, nextIsBoss)
        local lDefault = StageAPI.GetNextFreeBaseGridRoom(StageAPI.BaseLGridRoomPriority, taken, nextIsBoss)
        local lAlternate = StageAPI.GetNextFreeBaseGridRoom(StageAPI.BaseLGridRoomPriority, taken, nextIsBoss)

        return default, alternate, lDefault, lAlternate
    end

    -- isCustomMap is unused currently, but will be used if custom floor gen is added
    function StageAPI.ExtraRoomTransition(name, direction, transitionType, isCustomMap, leaveDoor, enterDoor, setPlayerPosition, extraRoomBaseType)
        leaveDoor = leaveDoor or -1
        enterDoor = enterDoor or -1
        transitionType = transitionType or RoomTransitionAnim.WALK
        direction = direction or Direction.NO_DIRECTION
        StageAPI.ForcePlayerNewRoomPosition = setPlayerPosition

        if StageAPI.CurrentExtraRoom then
            StageAPI.ActiveTransitionFromExtraRoom = true
            StageAPI.CurrentExtraRoom:SaveGridInformation()
            StageAPI.CurrentExtraRoom:SavePersistentEntities()
        end

        local transitionFrom = level:GetCurrentRoomIndex()
        local transitionTo
        local extraRoomName
        if type(name) ~= "string" then
            transitionTo = name
        else
            extraRoomName = name
        end

        if transitionFrom >= 0 then
            StageAPI.LastNonExtraRoom = transitionFrom
        else
            local currentRoomDesc = level:GetRoomByIdx(transitionFrom)
            local currentGotoData, currentGotoLockedData = StageAPI.GetGotoDataForTypeShape(room:GetType(), room:GetRoomShape())
            if currentGotoLockedData and StageAPI.DoorOneSlots[leaveDoor] then
                currentRoomDesc.Data = currentGotoLockedData
            else
                currentRoomDesc.Data = currentGotoData
            end
        end

        local setDataForShape, setVisitCount, setClear, setClearCount, setDecoSeed, setSpawnSeed, setAwardSeed, setWater, setChallengeDone

        if extraRoomName then
            local extraRoom = StageAPI.GetExtraRoom(extraRoomName)
            StageAPI.InExtraRoom = true
            StageAPI.CurrentExtraRoom = extraRoom
            StageAPI.CurrentExtraRoomName = extraRoomName

            StageAPI.ActiveTransitionToExtraRoom = true

            extraRoomBaseType = extraRoomBaseType or extraRoom.RoomType
            setDataForShape = setDataForShape or extraRoom.Shape
            setSpawnSeed = setSpawnSeed or extraRoom.SpawnSeed
            setDecoSeed = setDecoSeed or extraRoom.DecorationSeed
            setAwardSeed = setAwardSeed or extraRoom.AwardSeed
            setVisitCount = setVisitCount or extraRoom.VisitCount or 0
            setClearCount = setClearCount or extraRoom.ClearCount or 0
            setWater = setWater or extraRoom.HasWaterPits
            setChallengeDone = setChallengeDone or extraRoom.ChallengeDone

            if setWater == nil then
                setWater = false or extraRoom.HasWaterPits
            end

            if setChallengeDone == nil then
                setChallengeDone = false or extraRoom.ChallengeDone
            end

            if setClear == nil then
                setClear = true
                if extraRoom.IsClear ~= nil then
                    setClear = extraRoom.IsClear
                end
            end
        else
            StageAPI.InExtraRoom = false
            StageAPI.CurrentExtraRoom = nil
            StageAPI.CurrentExtraRoomName = nil
            StageAPI.ActiveTransitionToExtraRoom = false
        end

        StageAPI.LoadedExtraRoom = false

        if not transitionTo then
            local defaultGridRoom, alternateGridRoom, defaultLGridRoom, alternateLGridRoom = StageAPI.GetExtraRoomBaseGridRooms(extraRoomBaseType == RoomType.ROOM_BOSS)

            transitionTo = defaultGridRoom

            if setDataForShape and StageAPI.LRoomShapes[setDataForShape] then
                transitionTo = defaultLGridRoom
            end

            -- alternating between two off-grid rooms makes transitions between certain room types and shapes cleaner
            if transitionFrom < 0 and transitionFrom == transitionTo then
                if transitionTo == defaultGridRoom then
                    transitionTo = alternateGridRoom
                elseif transitionTo == defaultLGridRoom then
                    transitionTo = alternateLGridRoom
                end
            end
        end

        local targetRoomDesc = level:GetRoomByIdx(transitionTo)

        if setDataForShape then
            local targetGotoData, targetGotoLockedData = StageAPI.GetGotoDataForTypeShape(extraRoomBaseType, setDataForShape)
            if targetGotoLockedData and StageAPI.DoorOneSlots[enterDoor] then
                targetRoomDesc.Data = targetGotoLockedData
            else
                targetRoomDesc.Data = targetGotoData
            end
        end

        if setVisitCount then
            targetRoomDesc.VisitedCount = setVisitCount
        end

        if setClear ~= nil then
            targetRoomDesc.Clear = setClear
        end

        if setWater ~= nil then
            targetRoomDesc.HasWater = setWater
        end

        if setChallengeDone ~= nil then
            targetRoomDesc.ChallengeDone = setChallengeDone
        end

        if setClearCount then
            targetRoomDesc.ClearCount = setClearCount
        end

        if setDecoSeed then
            targetRoomDesc.DecorationSeed = setDecoSeed
        end

        if setSpawnSeed then
            targetRoomDesc.SpawnSeed = setSpawnSeed
        end

        if setAwardSeed then
            targetRoomDesc.AwardSeed = setAwardSeed
        end

        level.LeaveDoor = leaveDoor
        level.EnterDoor = enterDoor

        if transitionType == -1 then -- StageAPI special, instant transition
            StageAPI.ForcePlayerDoorSlot = (enterDoor == -1 and nil) or enterDoor
            level:ChangeRoom(transitionTo)
        else
            if enterDoor ~= -1 then
                StageAPI.ForcePlayerDoorSlot = enterDoor
            else
                StageAPI.ForcePlayerDoorSlot = nil
            end

            game:StartRoomTransition(transitionTo, direction, transitionType)
        end
    end

    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not game:IsPaused() then
            StageAPI.StoredExtraRoomThisPause = false
        elseif StageAPI.LoadedExtraRoom and not StageAPI.StoredExtraRoomThisPause then
            StageAPI.StoredExtraRoomThisPause = true
            StageAPI.CurrentExtraRoom:SaveGridInformation()
            StageAPI.CurrentExtraRoom:SavePersistentEntities()
        end

        if not StageAPI.IsHUDAnimationPlaying() then
            if not StageAPI.InNewStage() then
                local btype, stage, stype = room:GetBackdropType(), level:GetStage(), level:GetStageType()
                if (btype == 7 or btype == 8 or btype == 16) and (stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2 or stage == LevelStage.STAGE6) then
                    for _, overlay in ipairs(StageAPI.NecropolisOverlays) do
                        if not game:IsPaused() then
                            overlay:Update()
                        end

                        overlay:Render(nil, nil, true)
                    end
                end
            end

            local shadows = Isaac.FindByType(StageAPI.E.StageShadow.T, StageAPI.E.StageShadow.V, -1, false, false)
            local shadow = shadows[1]
            if shadow then
                local shadowSheet, shadowAnim = shadow:GetData().Sheet, shadow:GetData().Animation
                if shadowSheet and shadowSheet ~= lastUsedShadowSpritesheet then
                    shadowSprite:ReplaceSpritesheet(0, shadowSheet)
                    shadowSprite:LoadGraphics()
                    lastUsedShadowSpritesheet = shadowSheet
                end

                if shadowAnim and not (shadowSprite:IsPlaying(shadowAnim) or shadowSprite:IsFinished(shadowAnim)) then
                    shadowSprite:Play(shadowAnim, true)
                end

                shadowSprite:Render(Isaac.WorldToRenderPosition(shadow.Position) + room:GetRenderScrollOffset(), zeroVector, zeroVector)
            end
        end

        StageAPI.CallCallbacks("PRE_TRANSITION_RENDER")
    end)
end

StageAPI.LogMinor("Loading Custom Door Handler")
do -- Custom Doors
    StageAPI.DoorToDirection = {
        [DoorSlot.DOWN0] = Direction.DOWN,
        [DoorSlot.DOWN1] = Direction.DOWN,
        [DoorSlot.LEFT0] = Direction.LEFT,
        [DoorSlot.LEFT1] = Direction.LEFT,
        [DoorSlot.RIGHT0] = Direction.RIGHT,
        [DoorSlot.RIGHT1] = Direction.RIGHT,
        [DoorSlot.UP0] = Direction.UP,
        [DoorSlot.UP1] = Direction.UP
    }

    StageAPI.DoorOffsetsByDirection = {
        [Direction.DOWN] = Vector(0, -23),
        [Direction.UP] = Vector(0, 23),
        [Direction.LEFT] = Vector(23, 0),
        [Direction.RIGHT] = Vector(-23, 0)
    }

    function StageAPI.DirectionToDegrees(dir)
        return dir * 90 - 90
    end

    StageAPI.CustomDoorGrid = StageAPI.CustomGrid("CustomDoor")

    StageAPI.DoorTypes = {}
    StageAPI.CustomDoor = StageAPI.Class("CustomDoor")
    function StageAPI.CustomDoor:Init(name, anm2, openAnim, closeAnim, openedAnim, closedAnim, noAutoHandling, alwaysOpen)
        self.NoAutoHandling = noAutoHandling
        self.AlwaysOpen = alwaysOpen
        self.Anm2 = anm2 or "gfx/grid/door_01_normaldoor.anm2"
        self.OpenAnim = openAnim or "Open"
        self.CloseAnim = closeAnim or "Close"
        self.OpenedAnim = openedAnim or "Opened"
        self.ClosedAnim = closedAnim or "Closed"
        self.Name = name
        StageAPI.DoorTypes[name] = self
    end

    StageAPI.DefaultDoor = StageAPI.CustomDoor("DefaultDoor")

    function StageAPI.SpawnCustomDoor(slot, leadsTo, legacyLeadsToNormal, doorDataName, data, exitSlot)
        if type(legacyLeadsToNormal) == "number" then
            leadsTo = legacyLeadsToNormal
            legacyLeadsToNormal = nil
        end

        local index = room:GetGridIndex(room:GetDoorSlotPosition(slot))
        StageAPI.CustomDoorGrid:Spawn(index, nil, false, {
            Slot = slot,
            ExitSlot = exitSlot or (slot + 2) % 4,
            LeadsTo = leadsTo,
            DoorDataName = doorDataName,
            Data = data
        })
    end

    function StageAPI.GetCustomDoors(doorDataName)
        local ret = {}
        local doors = StageAPI.GetCustomGridsByName("CustomDoor")
        for _, door in ipairs(doors) do
            if not doorDataName or door.PersistData.DoorDataName == doorDataName then
                ret[#ret + 1] = door
            end
        end

        return ret
    end

    StageAPI.AddCallback("StageAPI", "POST_SPAWN_CUSTOM_GRID", 0, function(index, force, respawning, grid, persistData, customGrid)
        local doorData
        if persistData.DoorDataName and StageAPI.DoorTypes[persistData.DoorDataName] then
            doorData = StageAPI.DoorTypes[persistData.DoorDataName]
        else
            doorData = StageAPI.DefaultDoor
        end

        local door = Isaac.Spawn(StageAPI.E.Door.T, StageAPI.E.Door.V, 0, room:GetGridPosition(index), zeroVector, nil)
        local data, sprite = door:GetData(), door:GetSprite()
        sprite:Load(doorData.Anm2, true)

        door.RenderZOffset = -10000
        sprite.Rotation = persistData.Slot * 90 - 90
        door.PositionOffset = StageAPI.DoorOffsetsByDirection[StageAPI.DoorToDirection[persistData.Slot]]

        if not doorData.NoAutoHandling then
            if doorData.AlwaysOpen then
                sprite:Play(doorData.OpenedAnim, true)
            elseif doorData.AlwaysOpen == false then
                sprite:Play(doorData.ClosedAnim, true)
            else
                if room:IsClear() then
                    sprite:Play(doorData.OpenedAnim, true)
                else
                    sprite:Play(doorData.ClosedAnim, true)
                end
            end
        end

        local opened = sprite:IsPlaying(doorData.OpenedAnim) or sprite:IsFinished(doorData.OpenedAnim)

        local grid = room:GetGridEntity(index)
        if opened then
            grid.CollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
        else
            grid.CollisionClass = GridCollisionClass.COLLISION_WALL
        end

        data.DoorGridData = persistData
        data.DoorData = doorData
        data.Opened = opened

        local callbacks = StageAPI.GetCallbacks("POST_SPAWN_CUSTOM_DOOR")
        for _, callback in ipairs(callbacks) do
            if not callback.Params[1] or callback.Params[1] == persistData.DoorDataName then
                callback.Function(door, data, sprite, doorData, persistData, index, force, respawning, grid, customGrid)
            end
        end
    end, "CustomDoor")

    function StageAPI.SetDoorOpen(open, door)
        local grid = room:GetGridEntityFromPos(door.Position)
        if open then
            grid.CollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
        else
            grid.CollisionClass = GridCollisionClass.COLLISION_WALL
        end
    end

    local framesWithoutDoorData = 0
    local hadFrameWithoutDoorData = false
    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, door)
        local data, sprite = door:GetData(), door:GetSprite()
        local doorData = data.DoorData
        if StageAPI.TransitioningToOrFromExtraRoom() then
            return
        end

        if not doorData then
            framesWithoutDoorData = framesWithoutDoorData + 1
            hadFrameWithoutDoorData = true
            return
        end

        if not doorData.NoAutoHandling and doorData.AlwaysOpen == nil then
            if sprite:IsFinished(doorData.OpenAnim) then
                StageAPI.SetDoorOpen(true, door)
                sprite:Play(doorData.OpenedAnim, true)
            elseif sprite:IsFinished(doorData.CloseAnim) then
                StageAPI.SetDoorOpen(false, door)
                sprite:Play(doorData.ClosedAnim, true)
            end

            if room:IsClear() and not data.Opened then
                data.Opened = true
                sprite:Play(doorData.OpenAnim, true)
            elseif not room:IsClear() and data.Opened then
                data.Opened = false
                sprite:Play(doorData.CloseAnim, true)
            end
        end

        local transitionStarted
        for _, player in ipairs(players) do
            local size = 32 + player.Size
            if not room:IsPositionInRoom(player.Position, -16) and player.Position:DistanceSquared(door.Position) < size * size then
                local leadsTo = data.DoorGridData.LeadsTo
                if leadsTo then
                    transitionStarted = true
                    local leaveDoor = data.DoorGridData.Slot
                    if type(leadsTo) ~= "string" then
                        leaveDoor = nil
                    end

                    StageAPI.ExtraRoomTransition(leadsTo, StageAPI.DoorSlotToDirection[data.DoorGridData.Slot], RoomTransitionAnim.WALK, false, leaveDoor, data.DoorGridData.ExitSlot)
                end
            end
        end

        if transitionStarted then
            for _, player in ipairs(players) do
                player.Velocity = zeroVector
            end
        end

        local callbacks = StageAPI.GetCallbacks("POST_CUSTOM_DOOR_UPDATE")
        for _, callback in ipairs(callbacks) do
            if not callback.Params[1] or callback.Params[1] == data.DoorGridData.DoorDataName then
                callback.Function(door, data, sprite, doorData, data.DoorGridData)
            end
        end
    end, StageAPI.E.Door.V)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if hadFrameWithoutDoorData then
            hadFrameWithoutDoorData = false
        elseif framesWithoutDoorData > 0 then
            StageAPI.LogErr("Had no door data for " .. tostring(framesWithoutDoorData) .. " frames")
            framesWithoutDoorData = 0
        end
    end)
end

StageAPI.LogMinor("Loading GridGfx Handler")
do -- GridGfx
    StageAPI.GridGfx = StageAPI.Class("GridGfx")
    function StageAPI.GridGfx:Init()
        self.Grids = false
        self.Doors = false
    end

    function StageAPI.GridGfx:SetRocks(filename, noBridge)
        self.Rocks = filename

        if not self.Bridges and not noBridge then
            self.Bridges = filename
        end
    end

    function StageAPI.GridGfx:SetGrid(filename, t, v)
        if not self.Grids then
            self.Grids = {}
            self.GridsByVariant = {}
        end

        if v then
            if not self.GridsByVariant[t] then
                self.GridsByVariant[t] = {}
            end

            self.GridsByVariant[t][v] = filename
        else
            self.Grids[t] = filename
        end
    end

    function StageAPI.GridGfx:SetPits(filenames, alts, hasExtraFrames)
        if type(filenames) == 'string' then
            filenames = { {
                File = filenames,
                HasExtraFrames = hasExtraFrames
            } }
        end
        if type(alts) == 'string' then
            alts = { {
                File = alts,
                HasExtraFrames = hasExtraFrames
            } }
        end

        self.PitFiles = filenames
        self.AltPitFiles = alts
    end

    function StageAPI.GridGfx:SetBridges(filename)
        self.Bridges = filename
    end

    function StageAPI.GridGfx:SetDecorations(filename, anm2, propCount, prefix, suffix)
        self.Decorations = {
            Png = filename,
            Anm2 = anm2 or "gfx/grid/props_03_caves.anm2",
            PropCount = propCount or 42,
            Prefix = prefix or "Prop",
            Suffix = suffix or ""
        }
    end

    -- No SetPoop, do GridGfx:SetGrid(filename, GridEntityType.GRID_POOP, StageAPI.PoopVariant.Normal)

    StageAPI.DefaultDoorSpawn = {
        RequireCurrent = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS, RoomType.ROOM_SACRIFICE, RoomType.ROOM_SHOP, RoomType.ROOM_LIBRARY, RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS, RoomType.ROOM_DICE, RoomType.ROOM_CHEST},
        RequireTarget = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS, RoomType.ROOM_SACRIFICE, RoomType.ROOM_SHOP, RoomType.ROOM_LIBRARY, RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS, RoomType.ROOM_DICE, RoomType.ROOM_CHEST}
    }

    StageAPI.SecretDoorSpawn = {
        RequireTarget = {RoomType.ROOM_SECRET, RoomType.ROOM_SUPERSECRET},
        NotCurrent = {RoomType.ROOM_SECRET, RoomType.ROOM_SUPERSECRET}
    }
    --[[
    DoorInfo
    {
        RequireCurrent = {},
        RequireTarget = {},
        RequireEither = {},
        NotCurrent = {},
        NotTarget = {},
        NotEither = {}
    }
    ]]

    function StageAPI.GridGfx:AddDoors(filename, doorInfo)
        if not self.Doors then
            self.Doors = {}
        end

        if doorInfo.IsBossAmbush then
            self.HasBossAmbushDoor = true
        end

        self.Doors[#self.Doors + 1] = {
            File = filename,
            RequireCurrent = doorInfo.RequireCurrent,
            RequireTarget = doorInfo.RequireTarget,
            RequireEither = doorInfo.RequireEither,
            NotCurrent = doorInfo.NotCurrent,
            NotTarget = doorInfo.NotTarget,
            NotEither = doorInfo.NotEither,
            IsBossAmbush = doorInfo.IsBossAmbush
        }
    end

    function StageAPI.GridGfx:SetPayToPlayDoor(filename)
        self.PayToPlayDoor = filename
    end

    StageAPI.GridGfxRNG = RNG()

    function StageAPI.ChangeRock(rock, filename)
        local grid = rock.Grid
        local gsprite = grid:GetSprite()
        for i = 0, 4 do
            gsprite:ReplaceSpritesheet(i, filename)
        end

        gsprite:LoadGraphics()

        grid:ToRock():UpdateAnimFrame()
    end

    StageAPI.BridgedPits = {}
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        StageAPI.BridgedPits = {}
    end)

    function StageAPI.CheckBridge(grid, index, bridgefilename)
        if grid.State == 1 and bridgefilename and not StageAPI.BridgedPits[index] then
            local sprite = grid:GetSprite()
            sprite:ReplaceSpritesheet(1, bridgefilename)
            sprite:LoadGraphics()

            StageAPI.BridgedPits[index] = true
        end
    end

    function StageAPI.ChangePit(pit, pitFile, bridgefilename, alt)
        local grid = pit.Grid
        local gsprite = grid:GetSprite()

        if gsprite:GetFilename() ~= "stageapi/pit.anm2" then
            gsprite:Load("stageapi/pit.anm2", true)
        end

        if alt and room:HasWaterPits() then
            gsprite:ReplaceSpritesheet(0, alt.File)
        else
            gsprite:ReplaceSpritesheet(0, pitFile.File)
        end

        if bridgefilename then
            gsprite:ReplaceSpritesheet(1, bridgefilename)
        end

        gsprite:LoadGraphics()
    end

    StageAPI.DecorationSprites = {}
    function StageAPI.ChangeDecoration(decoration, decorations)
        local grid = decoration.Grid

        local gsprite = grid:GetSprite()
        gsprite:Load(decorations.Anm2, false)

        gsprite:ReplaceSpritesheet(0, decorations.Png)
        gsprite:LoadGraphics()
        local prop = StageAPI.Random(1, decorations.PropCount, StageAPI.GridGfxRNG)
        if prop < 10 then
            prop = "0" .. tostring(prop)
        end

        gsprite:Play(decorations.Prefix .. tostring(prop) .. decorations.Suffix, true)
    end

    StageAPI.DoorAnimationMap = {
        "Opened",
        "Closed",
        "Open",
        "Close",
        "Break",
        "KeyOpen",
        "KeyClose",
        "BrokenOpen",
        "KeyClosed",
        "Hidden",
        "GoldenKeyOpen",
        "KeyOpenNoKey",
        "GoldKeyOpen",
        "ArcadeSign"
    }

    function StageAPI.DoesDoorMatch(door, doorSpawn, current, target, hasBossAmbushDoor)
        current = current or door.CurrentRoomType
        target = target or door.TargetRoomType
        local valid = true
        local isChallengeRequired = false
        if doorSpawn.RequireCurrent then
            local has = false
            for _, roomType in ipairs(doorSpawn.RequireCurrent) do
                if current == roomType then
                    if roomType == RoomType.ROOM_CHALLENGE then
                        isChallengeRequired = true
                    end

                    has = true
                end
            end

            if not has then
                valid = false
            end
        end

        if doorSpawn.RequireTarget then
            local has = false
            for _, roomType in ipairs(doorSpawn.RequireTarget) do
                if target == roomType then
                    if roomType == RoomType.ROOM_CHALLENGE then
                        isChallengeRequired = true
                    end

                    has = true
                end
            end

            if not has then
                valid = false
            end
        end

        if doorSpawn.RequireEither then
            local has = false
            for _, roomType in ipairs(doorSpawn.RequireEither) do
                if current == roomType or target == roomType then
                    if roomType == RoomType.ROOM_CHALLENGE then
                        isChallengeRequired = true
                    end

                    has = true
                end
            end

            if not has then
                valid = false
            end
        end

        if doorSpawn.NotCurrent then
            local has = false
            for _, roomType in ipairs(doorSpawn.NotCurrent) do
                if current == roomType then
                    has = true
                end
            end

            if has then
                valid = false
            end
        end

        if doorSpawn.NotTarget then
            local has = false
            for _, roomType in ipairs(doorSpawn.NotTarget) do
                if target == roomType then
                    has = true
                end
            end

            if has then
                valid = false
            end
        end

        if doorSpawn.NotEither then
            local has = false
            for _, roomType in ipairs(doorSpawn.NotEither) do
                if current == roomType or target == roomType then
                    has = true
                end
            end

            if has then
                valid = false
            end
        end

        if isChallengeRequired and (current == RoomType.ROOM_CHALLENGE or target == RoomType.ROOM_CHALLENGE) and ((doorSpawn.IsBossAmbush and not level:HasBossChallenge()) or (not doorSpawn.IsBossAmbush and hasBossAmbushDoor and level:HasBossChallenge())) then
            valid = false
        end

        return valid
    end

    StageAPI.DoorSprite = Sprite()
    function StageAPI.ChangeDoor(door, doors, payToPlay, hasBossAmbushDoor)
        local grid = door.Grid:ToDoor()
        local gsprite = grid:GetSprite()
        local current = grid.CurrentRoomType
        local target = grid.TargetRoomType
        local isPayToPlay = grid:IsTargetRoomArcade() and target ~= RoomType.ROOM_ARCADE

        if isPayToPlay then
            if payToPlay then
                for i = 0, 5 do
                    gsprite:ReplaceSpritesheet(i, payToPlay)
                end

                gsprite:LoadGraphics()
            end

            return
        end

        for _, doorOption in ipairs(doors) do
            if StageAPI.DoesDoorMatch(grid, doorOption, current, target, hasBossAmbushDoor) then
                for i = 0, 5 do
                    gsprite:ReplaceSpritesheet(i, doorOption.File)
                end

                gsprite:LoadGraphics()

                break
            end
        end
    end

    function StageAPI.ChangeGrid(sent, filename)
        local grid = sent.Grid
        local sprite = grid:GetSprite()

        if type(filename) == "table" then
            filename = filename[StageAPI.Random(1, #filename, StageAPI.GridGfxRNG)]
        end

        sprite:ReplaceSpritesheet(0, filename)
        sprite:LoadGraphics()
    end

    function StageAPI.ChangeSingleGrid(grid, grids, i)
        local desc = grid.Desc
        local gtype = desc.Type
        local send = {Grid = grid, Index = i, Type = gtype, Desc = desc}
        if gtype == GridEntityType.GRID_DOOR and grids.Doors then
            StageAPI.ChangeDoor(send, grids.Doors, grids.PayToPlayDoor, grids.HasBossAmbushDoor)
        elseif StageAPI.RockTypes[gtype] and grids.Rocks then
            StageAPI.ChangeRock(send, grids.Rocks)
        elseif gtype == GridEntityType.GRID_PIT and grids.Pits then
            StageAPI.ChangePit(send, grids.Pits, grids.Bridges, grids.AltPits)
        elseif gtype == GridEntityType.GRID_DECORATION and grids.Decorations then
            StageAPI.ChangeDecoration(send, grids.Decorations)
        elseif grids.Grids or grids.GridsByVariant then
            local variant = send.Desc.Variant
            if grids.GridsByVariant and grids.GridsByVariant[send.Type] and grids.GridsByVariant[send.Type][variant] then
                StageAPI.ChangeGrid(send, grids.GridsByVariant[send.Type][variant])
            elseif grids.Grids and grids.Grids[send.Type] then
                StageAPI.ChangeGrid(send, grids.Grids[send.Type])
            end
        end
    end

    function StageAPI.ChangeDoors(doors)
        if doors then
            local payToPlay
            if doors.Type == "GridGfx" then
                doors = doors.Doors
                payToPlay = doors.PayToPlayDoor
            elseif doors.Type == "CustomStage" and doors.RoomGfx then
                local roomgfx = doors.RoomGfx[room:GetType()]
                if roomgfx and roomgfx.Grids then
                    doors = roomgfx.Grids.Doors
                    payToPlay = roomgfx.Grids.PayToPlayDoor
                end
            elseif doors.Type == "RoomGfx" and doors.Grids then
                payToPlay = doors.Grids.PayToPlayDoor
                doors = doors.Grids.Doors
            end

            if doors then
                for i = 0, 7 do
                    local door = room:GetDoor(i)
                    if door then
                        StageAPI.ChangeDoor({Grid = door}, doors, payToPlay)
                    end
                end
            end
        end
    end

    function StageAPI.ChangeGrids(grids)
        StageAPI.GridGfxRNG:SetSeed(room:GetDecorationSeed(), 0)

        if grids.PitFiles then
            grids.Pits = grids.PitFiles[StageAPI.Random(1, #grids.PitFiles, StageAPI.GridGfxRNG)]
        end
        if grids.AltPitFiles then
            grids.AltPits = grids.AltPitFiles[StageAPI.Random(1, #grids.AltPitFiles, StageAPI.GridGfxRNG)]
        end

        local pitsToUse = room:HasWaterPits() and grids.AltPits or grids.Pits
        local hasExtraPitFrames = pitsToUse and pitsToUse.HasExtraFrames

        local gridCount = 0
        local pits = {}
        for i = 0, room:GetGridSize() do
            local customGrids = StageAPI.GetCustomGridsAtIndex(i)
            local customGridBlocking = false
            for _, cgrid in ipairs(customGrids) do
                if not cgrid.Data.NoOverrideGridSprite then
                    customGridBlocking = true
                end
            end

            if not customGridBlocking then
                local grid = room:GetGridEntity(i)
                if grid then
                    if hasExtraPitFrames and grid.Desc.Type == GridEntityType.GRID_PIT then
                        pits[i] = grid
                    else
                        StageAPI.ChangeSingleGrid(grid, grids, i)
                    end
                end
            end
        end

        StageAPI.CallGridPostInit()

        if hasExtraPitFrames and next(pits) then
            local width = room:GetGridWidth()
            for index, pit in pairs(pits) do
                StageAPI.ChangePit({Grid = pit, Index = index}, grids.Pits, grids.Bridges, grids.AltPits)
                local sprite = pit:GetSprite()

                local adj = {index - 1, index + 1, index - width, index + width, index - width - 1, index + width - 1, index - width + 1, index + width + 1}
                local adjPits = {}
                for _, ind in ipairs(adj) do
                    local grid = room:GetGridEntity(ind)
                    adjPits[#adjPits + 1] = not not (grid and grid.Desc.Type == GridEntityType.GRID_PIT)
                end

                adjPits[#adjPits + 1] = true
                sprite:SetFrame("pit", StageAPI.GetPitFrame(table.unpack(adjPits)))
            end
        end
    end
end

StageAPI.LogMinor("Loading Backdrop & RoomGfx Handling")
do -- Backdrop & RoomGfx
    StageAPI.BackdropRNG = RNG()
    local backdropDefaultOffset = Vector(260,0)
    local backdropIvOffset = Vector(113,0)

    StageAPI.ShapeToWallAnm2Layers = {
        ["1x2"] = 58,
        ["2x2"] = 63,
        ["2x2X"] = 21,
        ["IIH"] = 62,
        ["LTR"] = 63,
        ["LTRX"] = 19,
        ["2x1"] = 63,
        ["2x1X"] = 7,
        ["1x1"] = 44,
        ["LTL"] = 63,
        ["LTLX"] = 19,
        ["LBR"] = 63,
        ["LBRX"] = 19,
        ["LBL"] = 63,
        ["LBLX"] = 19,
        ["IIV"] = 42,
        ["IH"] = 36,
        ["IV"] = 28
    }

    StageAPI.ShapeToName = {
       [RoomShape.ROOMSHAPE_IV] = "IV",
       [RoomShape.ROOMSHAPE_1x2] = "1x2",
       [RoomShape.ROOMSHAPE_2x2] = "2x2",
       [RoomShape.ROOMSHAPE_IH] = "IH",
       [RoomShape.ROOMSHAPE_LTR] = "LTR",
       [RoomShape.ROOMSHAPE_LTL] = "LTL",
       [RoomShape.ROOMSHAPE_2x1] = "2x1",
       [RoomShape.ROOMSHAPE_1x1] = "1x1",
       [RoomShape.ROOMSHAPE_LBL] = "LBL",
       [RoomShape.ROOMSHAPE_LBR] = "LBR",
       [RoomShape.ROOMSHAPE_IIH] = "IIH",
       [RoomShape.ROOMSHAPE_IIV] = "IIV"
    }

    function StageAPI.LoadBackdropSprite(sprite, backdrop, mode) -- modes are 1 (walls A), 2 (floors), 3 (walls B)
        sprite = sprite or Sprite()

        local needsExtra
        local roomShape = room:GetRoomShape()
        local shapeName = StageAPI.ShapeToName[roomShape]
        if StageAPI.ShapeToWallAnm2Layers[shapeName .. "X"] then
            needsExtra = true
        end

        if mode == 3 then
            shapeName = shapeName .. "X"
        end

        if backdrop.PreLoadFunc then
            local ret = backdrop.PreLoadFunc(sprite, backdrop, mode, shapeName)
            if ret then
                mode = ret
            end
        end

        if mode == 1 or mode == 3 then
            sprite:Load(backdrop.WallAnm2 or "stageapi/WallBackdrop.anm2", false)

            if backdrop.PreWallSheetFunc then
                backdrop.PreWallSheetFunc(sprite, backdrop, mode, shapeName)
            end

            local corners
            local walls
            if backdrop.WallVariants then
                walls = backdrop.WallVariants[StageAPI.Random(1, #backdrop.WallVariants, backdropRNG)]
                corners = walls.Corners or backdrop.Corners
            else
                walls = backdrop.Walls
                corners = backdrop.Corners
            end

            if walls then
                for num = 1, StageAPI.ShapeToWallAnm2Layers[shapeName] do
                    local wall_to_use = walls[StageAPI.Random(1, #walls, backdropRNG)]
                    sprite:ReplaceSpritesheet(num, wall_to_use)
                end
            end

            if corners and string.sub(shapeName, 1, 1) == "L" then
                local corner_to_use = corners[StageAPI.Random(1, #corners, backdropRNG)]
                sprite:ReplaceSpritesheet(0, corner_to_use)
            end
        elseif mode == 2 then
            sprite:Load(backdrop.FloorAnm2 or "stageapi/FloorBackdrop.anm2", false)

            if backdrop.PreFloorSheetFunc then
                backdrop.PreFloorSheetFunc(sprite, backdrop, mode, shapeName)
            end

            local floors
            if backdrop.FloorVariants then
                floors = backdrop.FloorVariants[StageAPI.Random(1, #backdrop.FloorVariants, backdropRNG)]
            else
                floors = backdrop.Floors or backdrop.Walls
            end

            if floors then
                local numFloors
                if roomShape == RoomShape.ROOMSHAPE_1x1 then
                    numFloors = 4
                elseif roomShape == RoomShape.ROOMSHAPE_1x2 or roomShape == RoomShape.ROOMSHAPE_2x1 then
                    numFloors = 8
                elseif roomShape == RoomShape.ROOMSHAPE_2x2 then
                    numFloors = 16
                end

                if numFloors then
                    for i = 0, numFloors - 1 do
                        sprite:ReplaceSpritesheet(i, floors[StageAPI.Random(1, #floors, backdropRNG)])
                    end
                end
            end

            if backdrop.NFloors and string.sub(shapeName, 1, 1) == "I" then
                for num = 18, 19 do
                    sprite:ReplaceSpritesheet(num, backdrop.NFloors[StageAPI.Random(1, #backdrop.NFloors, backdropRNG)])
                end
            end

            if backdrop.LFloors and string.sub(shapeName, 1, 1) == "L" then
                for num = 16, 17 do
                    sprite:ReplaceSpritesheet(num, backdrop.LFloors[StageAPI.Random(1, #backdrop.LFloors, backdropRNG)])
                end
            end
        end

        sprite:LoadGraphics()

        local renderPos = room:GetTopLeftPos()
        if mode ~= 2 then
            renderPos = renderPos - Vector(80, 80)
        end

        sprite:Play(shapeName, true)

        return renderPos, needsExtra, sprite
    end

    function StageAPI.ChangeBackdrop(backdrop, justWalls, storeBackdropEnts, shading)
        if type(backdrop) == "number" then
            game:ShowHallucination(0, backdrop)
            sfx:Stop(SoundEffect.SOUND_DEATH_CARD)

            return
        end

        StageAPI.BackdropRNG:SetSeed(room:GetDecorationSeed(), 1)
        local needsExtra, backdropEnts
        if storeBackdropEnts then
            backdropEnts = {}
        end

        for i = 1, 3 do
            if justWalls and i == 2 then
                i = 3
            end

            if i == 3 and not needsExtra then
                break
            end

            local backdropEntity = Isaac.Spawn(StageAPI.E.Backdrop.T, StageAPI.E.Backdrop.V, 0, zeroVector, zeroVector, nil)
            local sprite = backdropEntity:GetSprite()

            local renderPos
            renderPos, needsExtra = StageAPI.LoadBackdropSprite(sprite, backdrop, i)

            backdropEntity.SpriteOffset = (renderPos / 40) * 26
            if i == 1 or i == 3 then
                backdropEntity:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL)
            else
                backdropEntity:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
            end

            if storeBackdropEnts then
                backdropEnts[#backdropEnts + 1] = backdropEntity
            end
        end

        if shading and shading.Name then
            StageAPI.ChangeShading(shading.Name, shading.Prefix)
        else
            StageAPI.ChangeShading("_default")
        end

        return backdropEnts
    end

    StageAPI.StageShadowRNG = RNG()
    function StageAPI.ChangeStageShadow(prefix, count)
        prefix = prefix or "stageapi/floors/catacombs/overlays/"
        count = count or 5

        local shadows = Isaac.FindByType(StageAPI.E.StageShadow.T, StageAPI.E.StageShadow.V, -1, false, false)
        for _, e in ipairs(shadows) do
            e:Remove()
        end

        local roomShape = room:GetRoomShape()
        local anim

        if roomShape == RoomShape.ROOMSHAPE_1x1 or roomShape == RoomShape.ROOMSHAPE_IH or roomShape == RoomShape.ROOMSHAPE_IV then anim = "1x1"
        elseif roomShape == RoomShape.ROOMSHAPE_1x2 or roomShape == RoomShape.ROOMSHAPE_IIV then anim = "1x2"
        elseif roomShape == RoomShape.ROOMSHAPE_2x1 or roomShape == RoomShape.ROOMSHAPE_IIH then anim = "2x1"
        elseif roomShape == RoomShape.ROOMSHAPE_2x2 or roomShape == RoomShape.ROOMSHAPE_LBL or roomShape == RoomShape.ROOMSHAPE_LBR or roomShape == RoomShape.ROOMSHAPE_LTL or roomShape == RoomShape.ROOMSHAPE_LTR then anim = "2x2"
        end

        if anim then
            StageAPI.StageShadowRNG:SetSeed(room:GetDecorationSeed(), 0)
            local usingShadow = StageAPI.Random(1, count, StageAPI.StageShadowRNG)
            local sheet = prefix .. anim .. "_overlay_" .. tostring(usingShadow) .. ".png"

            local shadowEntity = Isaac.Spawn(StageAPI.E.StageShadow.T, StageAPI.E.StageShadow.V, 0, zeroVector, zeroVector, nil)
            shadowEntity:GetData().Sheet = sheet
            shadowEntity:GetData().Animation = anim
            shadowEntity.Position = StageAPI.Lerp(room:GetTopLeftPos(), room:GetBottomRightPos(), 0.5)
            shadowEntity:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
        end
    end

    local shadingDefaultOffset = Vector(-80,-80)
    local shadingIhOffset = Vector(-80,-160)
    local shadingIvOffset = Vector(-240,-80)
    function StageAPI.ChangeShading(name, prefix)
        prefix = prefix or "stageapi/shading/shading"
        local shading = Isaac.FindByType(StageAPI.E.FloorEffectWaterCreep.T, StageAPI.E.FloorEffectWaterCreep.V, StageAPI.E.FloorEffectWaterCreep.S, false, false)
        for _, e in ipairs(shading) do
            if e:GetData().StageAPIShading then
                e:Remove()
            end
        end

        local roomShape = room:GetRoomShape()

        local topLeft = room:GetTopLeftPos()
        local renderPos = topLeft + shadingDefaultOffset
        local sheet
        local lFrame

        if roomShape == RoomShape.ROOMSHAPE_1x1 then sheet = ""
        elseif roomShape == RoomShape.ROOMSHAPE_1x2 then sheet = "_1x2"
        elseif roomShape == RoomShape.ROOMSHAPE_2x1 then sheet = "_2x1"
        elseif roomShape == RoomShape.ROOMSHAPE_2x2 then sheet = "_2x2"
        elseif roomShape == RoomShape.ROOMSHAPE_IH then
            sheet = "_ih"
            renderPos = topLeft + shadingIhOffset
        elseif roomShape == RoomShape.ROOMSHAPE_IIH then
            sheet = "_iih"
            renderPos = topLeft + shadingIhOffset
        elseif roomShape == RoomShape.ROOMSHAPE_IV then
            sheet = "_iv"
            renderPos = topLeft + shadingIvOffset
        elseif roomShape == RoomShape.ROOMSHAPE_IIV then
            sheet = "_iiv"
            renderPos = topLeft + shadingIvOffset
        elseif roomShape == RoomShape.ROOMSHAPE_LTL then
            sheet = "_ltl"
            lFrame = 0
        elseif roomShape == RoomShape.ROOMSHAPE_LTR then
            sheet = "_ltr"
            lFrame = 1
        elseif roomShape == RoomShape.ROOMSHAPE_LBL then
            sheet = "_lbl"
            lFrame = 2
        elseif roomShape == RoomShape.ROOMSHAPE_LBR then
            sheet = "_lbr"
            lFrame = 3
        end

        sheet = prefix .. sheet .. name .. ".png"

        for i = 0, 1 do
            local shadingEntity
            if i == 0 then
                shadingEntity = Isaac.Spawn(StageAPI.E.Shading.T, StageAPI.E.Shading.V, 0, Vector(0, 1), zeroVector, nil)
            elseif i == 1 then
                shadingEntity = StageAPI.SpawnFloorEffect(Vector(0, 1), zeroVector, nil, nil, false, nil, true)
                shadingEntity:GetData().StageAPIShading = true
            end

            local sprite = shadingEntity:GetSprite()
            sprite:Load("stageapi/Shading.anm2", false)
            for i = 0, 4 do
                sprite:ReplaceSpritesheet(i, sheet)
            end

            sprite:LoadGraphics()

            if lFrame then
                if i == 0 then
                    sprite:SetFrame("Walls", lFrame)
                else
                    sprite:SetFrame("Floors", lFrame)
                end
            else
                sprite:Play("Default", true)
            end

            shadingEntity:GetData().Sheet = sheet
            shadingEntity.SpriteOffset = ((renderPos - shadingEntity.Position) / 40) * 26

            if i == 0 then
                shadingEntity:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL)
            end
        end
    end

    function StageAPI.ChangeRoomGfx(roomgfx)
        StageAPI.BackdropRNG:SetSeed(room:GetDecorationSeed(), 0)
        if roomgfx.Backdrops then
            if #roomgfx.Backdrops > 0 then
                local backdrop = StageAPI.Random(1, #roomgfx.Backdrops, StageAPI.BackdropRNG)
                StageAPI.ChangeBackdrop(roomgfx.Backdrops[backdrop], nil, nil, roomgfx.Shading)
            else
                StageAPI.ChangeBackdrop(roomgfx.Backdrops)
            end
        end

        if roomgfx.Grids then
            StageAPI.ChangeGrids(roomgfx.Grids)
        end
    end

    StageAPI.RoomGfx = StageAPI.Class("RoomGfx")
    function StageAPI.RoomGfx:Init(backdrops, grids, shading, shadingPrefix)
        self.Backdrops = backdrops
        self.Grids = grids
        self.Shading = {
            Name = shading,
            Prefix = shadingPrefix
        }
    end

    StageAPI.AddCallback("StageAPI", "POST_STAGEAPI_NEW_ROOM", 0, function()
        if not game:IsGreedMode()
        and StageAPI.ShouldRenderStartingRoomControls()
        and level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() then
            local p1 = players[1]
            if not p1 then return end

            local gfxData = StageAPI.TryGetPlayerGraphicsInfo(p1)
			local controls = gfxData.Controls or 'stageapi/controls.png'
            local controlsFrame = gfxData.ControlsFrame or 0
            local controlsOffset = gfxData.ControlsOffset or StageAPI.ZeroVector


            local eff = StageAPI.SpawnFloorEffect(room:GetCenterPos() + controlsOffset, StageAPI.ZeroVector, nil, 'stageapi/controls.anm2', true)
            local sprite = eff:GetSprite()
		    sprite:ReplaceSpritesheet(0, controls)
            sprite:LoadGraphics()
			sprite:Play("Controls")
			sprite:SetLayerFrame(0, controlsFrame)
			sprite:Stop()

            local color = StageAPI.GetStageFloorTextColor()
            if color then
                sprite.Color = color
            end
        end
    end)
end

StageAPI.LogMinor("Loading CustomStage Handler")
do -- Custom Stage
    StageAPI.CustomStages = {}

    StageAPI.CustomStage = StageAPI.Class("CustomStage")
    function StageAPI.CustomStage:Init(name, replaces, noSetReplaces)
        self.Name = name
        self.Alias = name

        if not noSetReplaces then
            self.Replaces = replaces or StageAPI.StageOverride.CatacombsOne
        end

        if name then
            StageAPI.CustomStages[name] = self
        end
    end

    function StageAPI.CustomStage:InheritInit(name, noSetAlias)
        if not noSetAlias then
            self.Alias = self.Name
        end

        self.Name = name
        if name then
            StageAPI.CustomStages[name] = self
        end
    end

    function StageAPI.CustomStage:SetName(name)
        self.Name = name or self.Name
        if self.Name then
            StageAPI.CustomStages[self.Name] = self
        end

    end

    function StageAPI.CustomStage:GetDisplayName()
        return self.DisplayName or self.Name
    end

    function StageAPI.CustomStage:SetDisplayName(name)
        self.DisplayName = name or self.DisplayName or self.Name
    end

    function StageAPI.CustomStage:SetReplace(replaces)
        self.Replaces = replaces
    end

    function StageAPI.CustomStage:SetNextStage(stage)
        self.NextStage = stage
    end

    function StageAPI.CustomStage:SetXLStage(stage)
        self.XLStage = stage
    end

    function StageAPI.CustomStage:SetStageNumber(num)
        self.StageNumber = num
    end

    function StageAPI.CustomStage:SetIsSecondStage(isSecondStage)
        self.IsSecondStage = isSecondStage
    end

    function StageAPI.CustomStage:SetRoomGfx(gfx, rtype)
        if not self.RoomGfx then
            self.RoomGfx = {}
        end

        if type(rtype) == "table" then
            for _, roomtype in ipairs(rtype) do
                self.RoomGfx[roomtype] = gfx
            end
        else
            self.RoomGfx[rtype] = gfx
        end
    end

    function StageAPI.CustomStage:SetRooms(rooms, rtype)
        if not self.Rooms then
            self.Rooms = {}
        end

        if type(rooms) == "table" and rooms.Type ~= "RoomsList" then
            for rtype, rooms in pairs(rooms) do
                self.Rooms[rtype] = rooms
            end
        else
            rtype = rtype or RoomType.ROOM_DEFAULT
            self.Rooms[rtype] = rooms
        end
    end

    function StageAPI.CustomStage:SetChallengeWaves(rooms, bossChallengeRooms)
        self.ChallengeWaves = {
            Normal = rooms,
            Boss = bossChallengeRooms
        }
    end

    function StageAPI.CustomStage:SetMusic(music, rtype)
        if not self.Music then
            self.Music = {}
        end

        if type(rtype) == "table" then
            for _, roomtype in ipairs(rtype) do
                self.Music[roomtype] = music
            end
        else
            self.Music[rtype] = music
        end
    end

    function StageAPI.CustomStage:SetStageMusic(music)
        self:SetMusic(music, {
            RoomType.ROOM_DEFAULT,
            RoomType.ROOM_TREASURE,
            RoomType.ROOM_CURSE,
            RoomType.ROOM_CHALLENGE,
            RoomType.ROOM_BARREN,
            RoomType.ROOM_ISAACS,
            RoomType.ROOM_SACRIFICE,
            RoomType.ROOM_DICE,
            RoomType.ROOM_CHEST,
            RoomType.ROOM_DUNGEON
        })
    end

    function StageAPI.CustomStage:SetTransitionMusic(music)
        self.TransitionMusic = music
        StageAPI.StopOverridingMusic(music)
    end

    function StageAPI.CustomStage:SetBossMusic(music, clearedMusic, intro, outro)
        self.BossMusic = {
            Fight = music,
            Cleared = clearedMusic,
            Intro = intro,
            Outro = outro
        }
    end

    function StageAPI.CustomStage:SetRenderStartingRoomControls(doRender)
        self.RenderStartingRoomControls = doRender
    end

    function StageAPI.CustomStage:SetFloorTextColor(color)
        self.FloorTextColor = color
    end

    function StageAPI.CustomStage:SetSpots(bossSpot, playerSpot)
        self.BossSpot = bossSpot
        self.PlayerSpot = playerSpot
    end

    function StageAPI.CustomStage:SetTrueCoopSpots(twoPlayersSpot, fourPlayersSpot, threePlayersSpot) -- if a three player spot is not defined, uses four instead.
        self.CoopSpot2P = twoPlayersSpot
        self.CoopSpot3P = threePlayersSpot
        self.CoopSpot4P = fourPlayersSpot
    end

    function StageAPI.CustomStage:SetBosses(bosses)
        if bosses.Pool then
            self.Bosses = bosses
        else
            self.Bosses = {
                Pool = bosses
            }
        end
    end

    function StageAPI.CustomStage:SetSinRooms(sins)
        if type(sins) == "string" then -- allows passing in a prefix to a room list name, which all sins can be grabbed from
            self.SinRooms = {}
            for _, sin in ipairs(StageAPI.SinsSplitData) do
                self.SinRooms[sin.ListName] = StageAPI.RoomsLists[sins .. sin.ListName]
            end
        else
            self.SinRooms = sins
        end
    end

    function StageAPI.CustomStage:GenerateRoom(rtype, shape, doors, isStartingRoom, fromLevelGenerator, roomDescriptor)
        StageAPI.LogMinor("Generating room for stage " .. self:GetDisplayName())

        local roomData
        if roomDescriptor then
            roomData = roomDescriptor.Data
            rtype = rtype or roomData.Type
            shape = shape or roomData.Shape
            doors = doors or StageAPI.GetDoorsForRoomFromData(roomDescriptor.Data)
        end

        if StageAPI.CurrentStage.SinRooms and (rtype == RoomType.ROOM_MINIBOSS or rtype == RoomType.ROOM_SECRET or rtype == RoomType.ROOM_SHOP) then
            local usingRoomsList
            local includedSins = {}

            if roomData then
                StageAPI.ForAllSpawnEntries(roomData, function(entry, spawn)
                    for i, sin in ipairs(StageAPI.SinsSplitData) do
                        if entry.Type == sin.Type and (sin.Variant and entry.Variant == sin.Variant) and ((sin.ListName and StageAPI.CurrentStage.SinRooms[sin.ListName]) or (sin.MultipleListName and StageAPI.CurrentStage.SinRooms[sin.MultipleListName])) then
                            if not includedSins[i] then
                                includedSins[i] = 0
                            end

                            includedSins[i] = includedSins[i] + 1
                            break
                        end
                    end
                end)
            else
                for _, entity in ipairs(Isaac.GetRoomEntities()) do
                    for i, sin in ipairs(StageAPI.SinsSplitData) do
                        if entity.Type == sin.Type and (sin.Variant and entity.Variant == sin.Variant) and ((sin.ListName and StageAPI.CurrentStage.SinRooms[sin.ListName]) or (sin.MultipleListName and StageAPI.CurrentStage.SinRooms[sin.MultipleListName])) then
                            if not includedSins[i] then
                                includedSins[i] = 0
                            end

                            includedSins[i] = includedSins[i] + 1
                            break
                        end
                    end
                end
            end

            for ind, count in pairs(includedSins) do
                local sin = StageAPI.SinsSplitData[ind]
                local listName = sin.ListName
                if count > 1 and sin.MultipleListName then
                    listName = sin.MultipleListName
                end

                usingRoomsList = StageAPI.CurrentStage.SinRooms[listName]
            end

            if usingRoomsList then
                local shape = room:GetRoomShape()
                if #usingRoomsList.ByShape[shape] > 0 then
                    local newRoom = StageAPI.LevelRoom{
                        RoomsList = usingRoomsList,
                        Shape = shape,
                        RoomType = rtype,
                        RequireRoomType = StageAPI.CurrentStage.RequireRoomTypeSin,
                        Doors = doors,
                        RoomDesciptor = roomDescriptor
                    }

                    return newRoom
                end
            end
        end

        if not isStartingRoom and StageAPI.CurrentStage.Rooms and StageAPI.CurrentStage.Rooms[rtype] then
            local newRoom = StageAPI.LevelRoom{
                RoomsList = StageAPI.CurrentStage.Rooms[rtype],
                Shape = shape,
                RoomType = rtype,
                RequireRoomType = StageAPI.CurrentStage.RequireRoomTypeMatching,
                Doors = doors,
                RoomDesciptor = roomDescriptor
            }

            return newRoom
        end

        if StageAPI.CurrentStage.Bosses and rtype == RoomType.ROOM_BOSS then
            local newRoom, boss = StageAPI.GenerateBossRoom({
                Bosses = StageAPI.CurrentStage.Bosses,
                CheckEncountered = true,
                NoPlayBossAnim = fromLevelGenerator
            }, {
                RequireRoomType = StageAPI.CurrentStage.RequireRoomTypeBoss,
                RoomDescriptor = roomDescriptor
            })

            return newRoom, boss
        end
    end

    function StageAPI.CustomStage:SetPregenerationEnabled(setTo)
        self.PregenerationEnabled = setTo
    end

    function StageAPI.CustomStage:GenerateLevel()
        if not self.PregenerationEnabled then
            return
        end

        local startingRoomIndex = level:GetStartingRoomIndex()
        local roomsList = level:GetRooms()
        for i = 0, roomsList.Size - 1 do
            local roomDesc = roomsList:Get(i)
            if roomDesc then
                local isStartingRoom = startingRoomIndex == roomDesc.SafeGridIndex
                local newRoom = self:GenerateRoom(nil, nil, nil, isStartingRoom, true, roomDesc)
                if newRoom then
                    local listIndex = roomDesc.ListIndex
                    StageAPI.SetLevelRoom(newRoom, listIndex)
                end
            end
        end
    end

    function StageAPI.CustomStage:GetPlayingMusic()
        local roomType = room:GetType()
        local id = StageAPI.Music:GetCurrentMusicID()
        if roomType == RoomType.ROOM_BOSS then
            if self.BossMusic then
                local music = self.BossMusic
                local musicID, queue, disregardNonOverride

                if (music.Outro and (id == Music.MUSIC_JINGLE_BOSS_OVER or id == Music.MUSIC_JINGLE_BOSS_OVER2 or id == music.Outro or (type(music.Outro) == "table" and StageAPI.IsIn(music.Outro, id))))
                or (music.Intro and (id == Music.MUSIC_JINGLE_BOSS or id == music.Intro or (type(music.Intro) == "table" and StageAPI.IsIn(music.Intro, id)))) then
                    if id == Music.MUSIC_JINGLE_BOSS or id == music.Intro or (type(music.Intro) == "table" and StageAPI.IsIn(music.Intro, id)) then
                        musicID, queue = music.Intro, music.Fight
                    else
                        musicID, queue = music.Outro, music.Cleared
                    end

                    disregardNonOverride = true
                else
                    local isCleared = room:GetAliveBossesCount() < 1 or room:IsClear()
                    if isCleared then
                        musicID = music.Cleared
                    else
                        musicID = music.Fight
                    end
                end

                if type(musicID) == "table" then
                    StageAPI.MusicRNG:SetSeed(room:GetDecorationSeed(), 0)
                    musicID = musicID[StageAPI.Random(1, #musicID, StageAPI.MusicRNG)]
                end

                local newMusicID = StageAPI.CallCallbacks("POST_SELECT_BOSS_MUSIC", true, self, musicID, isCleared, StageAPI.MusicRNG)
                if newMusicID then
                    musicID = newMusicID
                end

                if musicID then
                    return musicID, not room:IsClear(), queue, disregardNonOverride
                end
            end
        elseif roomType ~= RoomType.ROOM_CHALLENGE or not room:IsAmbushActive() then
            local music = self.Music
            if music then
                local musicID = music[roomType]
                local newMusicID = StageAPI.CallCallbacks("POST_SELECT_STAGE_MUSIC", true, self, musicID, roomType, StageAPI.MusicRNG)
                if newMusicID then
                    musicID = newMusicID
                end

                if musicID then
                    return musicID, not room:IsClear()
                end
            end
        end
    end

    function StageAPI.CustomStage:OverrideRockAltEffects(rooms)
        self.OverridingRockAltEffects = rooms or true
    end

    function StageAPI.CustomStage:OverrideTrapdoors()
        self.OverridingTrapdoors = true
    end

    function StageAPI.CustomStage:SetTransitionIcon(icon)
        self.TransitionIcon = icon
    end

    function StageAPI.IsSameStage(base, comp, noAlias)
        if not base then return false end

        return base.Name == comp.Name or (not noAlias and base.Alias == comp.Alias)
    end

    function StageAPI.CustomStage:IsStage(noAlias)
        return StageAPI.IsSameStage(StageAPI.CurrentStage, self, noAlias)
    end

    function StageAPI.CustomStage:IsNextStage(noAlias)
        return StageAPI.IsSameStage(StageAPI.NextStage, self, noAlias)
    end

    function StageAPI.CustomStage:SetRequireRoomTypeMatching()
        self.RequireRoomTypeMatching = true
    end

    function StageAPI.CustomStage:SetRequireRoomTypeBoss()
        self.RequireRoomTypeBoss = true
    end

    function StageAPI.CustomStage:SetRequireRoomTypeSin()
        self.RequireRoomTypeSin = true
    end

    function StageAPI.ShouldPlayStageMusic()
        return room:GetType() == RoomType.ROOM_DEFAULT or room:GetType() == RoomType.ROOM_TREASURE, not room:IsClear()
    end
end

StageAPI.LogMinor("Loading Stage Override Definitions")
do -- Definitions
    function StageAPI.BackdropHelper(backdrop, prefix, suffix)
        if #backdrop < 1 then
            backdrop = {backdrop}
        end

        for i, backdropVariant in ipairs(backdrop) do
            for k, backdropFiles in pairs(backdropVariant) do
                for i2, file in ipairs(backdropFiles) do
                    if type(file) == "table" then
                        for i3, file2 in ipairs(file) do
                            backdrop[i][k][i2][i3] = prefix .. file2 .. suffix
                        end
                    else
                        backdrop[i][k][i2] = prefix .. file .. suffix
                    end
                end
            end
        end

        return backdrop
    end

    StageAPI.StageOverride = {}

    function StageAPI.AddOverrideStage(name, overrideStage, overrideStageType, replaceWith, isGreedMode)
        StageAPI.StageOverride[name] = {
            OverrideStage = overrideStage,
            OverrideStageType = overrideStageType,
            ReplaceWith = replaceWith,
            GreedMode = isGreedMode
        }
    end

    function StageAPI.InOverriddenStage()
        for name, override in pairs(StageAPI.StageOverride) do
            if (not not override.GreedMode) == game:IsGreedMode() then
                local isStage = level:GetStage() == override.OverrideStage and
                                level:GetStageType() == override.OverrideStageType
                if isStage then
                    return true, override, name
                end
            end
        end
    end

    function StageAPI.InOverrideStage()
        for name, override in pairs(StageAPI.StageOverride) do
            if override.ReplaceWith:IsStage() then
                return true
            end
        end
    end

    StageAPI.NextStage = nil
    StageAPI.CurrentStage = nil

    function StageAPI.InNewStage()
        return StageAPI.CurrentStage and not StageAPI.InOverrideStage()
    end

    function StageAPI.GetCurrentStage()
        return StageAPI.CurrentStage
    end

    function StageAPI.GetNextStage()
        return StageAPI.NextStage
    end

    function StageAPI.GetCurrentStageDisplayName()
        if StageAPI.CurrentStage then
            return StageAPI.CurrentStage:GetDisplayName()
        end
    end

    function StageAPI.GetCurrentListIndex()
        return level:GetCurrentRoomDesc().ListIndex
    end
end

StageAPI.LogMinor("Loading Boss Handler")
do -- Bosses
    StageAPI.FloorInfo = {}
    StageAPI.FloorInfoGreed = {}

    local stageToGreed = {
        [LevelStage.STAGE1_1] = LevelStage.STAGE1_GREED,
        [LevelStage.STAGE2_1] = LevelStage.STAGE2_GREED,
        [LevelStage.STAGE3_1] = LevelStage.STAGE3_GREED,
        [LevelStage.STAGE4_1] = LevelStage.STAGE4_GREED,
    }

    local stageToSecondStage = {
        [LevelStage.STAGE1_1] = LevelStage.STAGE1_2,
        [LevelStage.STAGE2_1] = LevelStage.STAGE2_2,
        [LevelStage.STAGE3_1] = LevelStage.STAGE3_2,
        [LevelStage.STAGE4_1] = LevelStage.STAGE4_2,
    }

    StageAPI.StageTypes = {
        StageType.STAGETYPE_ORIGINAL,
        StageType.STAGETYPE_WOTL,
        StageType.STAGETYPE_AFTERBIRTH,
        StageType.STAGETYPE_REPENTANCE,
        StageType.STAGETYPE_REPENTANCE_B
    }

    local noBossStages = {
        [LevelStage.STAGE3_2] = true,
        [LevelStage.STAGE4_2] = true
    }

    -- if doGreed is false, will not add to greed at all, if true, will only add to greed. nil for both.
    -- if stagetype is true, will set floorinfo for all stagetypes
    function StageAPI.SetFloorInfo(info, stage, stagetype, doGreed)
        if stagetype == true then
            for _, stype in ipairs(StageAPI.StageTypes) do
                StageAPI.SetFloorInfo(StageAPI.Copy(info), stage, stype, doGreed)
            end

            return
        end

        if doGreed ~= true then
            StageAPI.FloorInfo[stage] = StageAPI.FloorInfo[stage] or {}
            StageAPI.FloorInfo[stage][stagetype] = info

            local stageTwo = stageToSecondStage[stage]
            if stageTwo then
                StageAPI.FloorInfo[stageTwo] = StageAPI.FloorInfo[stageTwo] or {}

                local stageTwoInfo = StageAPI.Copy(info)
                if noBossStages[stageTwo] then
                    stageTwoInfo.Bosses = nil
                end

                StageAPI.FloorInfo[stageTwo][stagetype] = stageTwoInfo
            end
        end

        if doGreed ~= false then
            local greedStage = stage
            if doGreed == nil then
                greedStage = stageToGreed[stage] or stage
            end

            local greedInfo = StageAPI.Copy(info)
            greedInfo.Bosses = nil

            StageAPI.FloorInfoGreed[greedStage] = StageAPI.FloorInfoGreed[greedStage] or {}
            StageAPI.FloorInfoGreed[greedStage][stagetype] = greedInfo
        end
    end

    function StageAPI.GetBaseFloorInfo(stage, stageType, isGreed)
        stage, stageType, isGreed = stage or level:GetStage(), stageType or level:GetStageType(), isGreed or game:IsGreedMode()
        if isGreed then
            return StageAPI.FloorInfoGreed[stage][stageType]
        else
            return StageAPI.FloorInfo[stage][stageType]
        end
    end

    StageAPI.PlayerBossInfo = {
        isaac = "01",
        magdalene = "02",
        cain = "03",
        judas = "04",
        eve = "05",
        ["???"] = "06",
        samson = "07",
        azazel = "08",
        eden = "09",
        thelost = "12",
        lilith = "13",
        keeper = "14",
        apollyon = "15",
        theforgotten = "16",
        thesoul = "16",
		bethany = "18",
		jacob = "19",
		esau = "19"
    }

    for k, v in pairs(StageAPI.PlayerBossInfo) do
        local use = k
        if k == "???" then
            use = "bluebaby"
        end

        if k == "thesoul" then
            use = "theforgotten"
        end

        local portraitbig
        if k == "lilith" or k == "keeper" then
            portraitbig = "gfx/ui/stage/playerportraitbig_" .. use .. ".png"
        else
            portraitbig = "gfx/ui/stage/playerportraitbig_" .. v .. "_" .. use .. ".png"
        end

        local name
        if k == "keeper" then
            name = "gfx/ui/boss/playername_" .. v .. "_the" .. use .. ".png"
        else
            name = "gfx/ui/boss/playername_" .. v .. "_" .. use .. ".png"
        end

        StageAPI.PlayerBossInfo[k] = {
            Portrait = "gfx/ui/boss/playerportrait_" .. v .. "_" .. use .. ".png",
            Name = name,
            PortraitBig = portraitbig
        }
    end

    StageAPI.PlayerBossInfo["???"].NoShake = true
    StageAPI.PlayerBossInfo.keeper.NoShake = true
    StageAPI.PlayerBossInfo.theforgotten.NoShake = true
    StageAPI.PlayerBossInfo.thesoul.NoShake = true
    StageAPI.PlayerBossInfo.theforgotten.ControlsFrame = 1
    StageAPI.PlayerBossInfo.thesoul.ControlsFrame = 1
	StageAPI.PlayerBossInfo.jacob.ControlsFrame = 2
    StageAPI.PlayerBossInfo.esau.ControlsFrame = 2
    StageAPI.PlayerBossInfo.thelost.NoShake = true

    function StageAPI.AddPlayerGraphicsInfo(name, portrait, namefile, portraitbig, noshake)
        local args = portrait
        if type(args) ~= "table" then
            args = {
                Portrait = portrait,
                Name = namefile,
                PortraitBig = portraitbig,
                NoShake = noshake,
				Controls = nil,
                ControlsFrame = 0,
                ControlsOffset = nil,
            }
        end

        StageAPI.PlayerBossInfo[string.gsub(string.lower(name), "%s+", "")] = args
    end

    StageAPI.AddPlayerGraphicsInfo("Black Judas", "gfx/ui/boss/playerportrait_blackjudas.png", "gfx/ui/boss/playername_04_judas.png", "gfx/ui/stage/playerportraitbig_blackjudas.png")
    StageAPI.AddPlayerGraphicsInfo("Lazarus", "gfx/ui/boss/playerportrait_09_lazarus.png", "gfx/ui/boss/playername_10_lazarus.png", "gfx/ui/stage/playerportraitbig_09_lazarus.png")
    StageAPI.AddPlayerGraphicsInfo("Lazarus II", "gfx/ui/boss/playerportrait_10_lazarus2.png", "gfx/ui/boss/playername_10_lazarus.png", "gfx/ui/stage/playerportraitbig_10_lazarus2.png")

    function StageAPI.GetStageSpot()
        if StageAPI.InNewStage() then
            return StageAPI.CurrentStage.BossSpot or "gfx/ui/boss/bossspot.png", StageAPI.CurrentStage.PlayerSpot or "gfx/ui/boss/playerspot.png"
        else
            local spot = StageAPI.GetBaseFloorInfo().Prefix
            return "gfx/ui/boss/bossspot_" .. spot .. ".png", "gfx/ui/boss/playerspot_" .. spot .. ".png"
        end
    end

    function StageAPI.ShouldRenderStartingRoomControls()
        if StageAPI.InNewStage() then
            return StageAPI.CurrentStage.RenderStartingRoomControls
        else
            return level:GetStage() == 1 and level:GetStageType() < StageType.STAGETYPE_REPENTANCE
        end
    end

    -- returns nil if no special color
    function StageAPI.GetStageFloorTextColor()
        if StageAPI.InNewStage() then
            return StageAPI.CurrentStage.FloorTextColor
        else
            return StageAPI.GetBaseFloorInfo().FloorTextColor
        end
    end

    function StageAPI.TryGetPlayerGraphicsInfo(player)
        local playerName
        if type(player) == "string" then
            playerName = player
        else
            playerName = player:GetName()
        end
        playerName = string.gsub(string.lower(playerName), "%s+", "")

        if StageAPI.PlayerBossInfo[playerName] then
            return StageAPI.PlayerBossInfo[playerName]
        else -- worth a shot, most common naming convention
            return {
                Portrait    = "gfx/ui/boss/playerportrait_" .. playerName .. ".png",
                Name        = "gfx/ui/boss/playername_" .. playerName .. ".png",
                PortraitBig = "gfx/ui/stage/playerportraitbig_" .. playerName .. ".png"
            }
        end
    end

    StageAPI.BossSprite = Sprite()
    StageAPI.BossSprite:Load("gfx/ui/boss/versusscreen.anm2", false)
    StageAPI.BossSprite:ReplaceSpritesheet(0, "gfx/ui/boss/bgblack.png")
    StageAPI.PlayingBossSprite = nil
    StageAPI.UnskippableBossAnim = nil
    StageAPI.BossOffset = nil
    function StageAPI.PlayBossAnimationManual(portrait, name, spot, playerPortrait, playerName, playerSpot, portraitTwo, unskippable)
        local paramTable = portrait
        if type(paramTable) ~= "table" then
            paramTable = {
                BossPortrait = portrait,
                BossPortraitTwo = portraitTwo,
                BossName = name,
                BossSpot = spot,
                PlayerPortrait = playerPortrait,
                PlayerName = playerName,
                PlayerSpot = playerSpot,
                Unskippable = unskippable
            }
        end

        if paramTable.Sprite then -- if you need to use a different sprite (ex for a special boss animation) this could help
            StageAPI.PlayingBossSprite = paramTable.Sprite
        else
            StageAPI.PlayingBossSprite = StageAPI.BossSprite
        end

        if not paramTable.NoLoadGraphics then
            StageAPI.PlayingBossSprite:ReplaceSpritesheet(2, paramTable.BossSpot or "gfx/ui/boss/bossspot.png")
            StageAPI.PlayingBossSprite:ReplaceSpritesheet(3, paramTable.PlayerSpot or "gfx/ui/boss/bossspot.png")
            StageAPI.PlayingBossSprite:ReplaceSpritesheet(4, paramTable.BossPortrait or "gfx/ui/boss/portrait_20.0_monstro.png")
            StageAPI.PlayingBossSprite:ReplaceSpritesheet(5, paramTable.PlayerPortrait or "gfx/ui/boss/portrait_20.0_monstro.png")
            StageAPI.PlayingBossSprite:ReplaceSpritesheet(6, paramTable.PlayerName or "gfx/ui/boss/bossname_20.0_monstro.png")
            StageAPI.PlayingBossSprite:ReplaceSpritesheet(7, paramTable.BossName or "gfx/ui/boss/bossname_20.0_monstro.png")

            if paramTable.BossPortraitTwo then
                StageAPI.PlayingBossSprite:ReplaceSpritesheet(9, paramTable.BossPortraitTwo)
                paramTable.Animation = paramTable.Animation or "DoubleTrouble"
            end

            StageAPI.PlayingBossSprite:Play(paramTable.Animation or "Scene", true)

            StageAPI.PlayingBossSprite:LoadGraphics()
        end

        if paramTable.BossOffset then
            StageAPI.BossOffset = paramTable.BossOffset
        else
            StageAPI.BossOffset = nil
        end

        StageAPI.UnskippableBossAnim = unskippable
    end

    StageAPI.IsOddRenderFrame = nil
    local menuConfirmTriggered
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        StageAPI.IsOddRenderFrame = not StageAPI.IsOddRenderFrame
        local isPlaying = StageAPI.PlayingBossSprite

        if isPlaying and ((game:IsPaused() and not menuConfirmTriggered) or StageAPI.UnskippableBossAnim) then
            if StageAPI.IsOddRenderFrame then
                StageAPI.PlayingBossSprite:Update()
            end

            local centerPos = StageAPI.GetScreenCenterPosition()
            local layerRenderOrder = {0,1,2,3,14,9,13,4,12,6,7,8,10}
            for _, layer in ipairs(layerRenderOrder) do
                local pos = centerPos
                if StageAPI.BossOffset then
                    local isDoubleTrouble = StageAPI.BossOffset.One or StageAPI.BossOffset.Two
                    if isDoubleTrouble then  -- Double trouble, table {One = Vector, Two = Vector}
                        if layer == 4 then
                            pos = pos + StageAPI.BossOffset.One or zeroVector
                        elseif layer == 9 then
                            pos = pos + StageAPI.BossOffset.Two or zeroVector
                        end
                    elseif layer == 4 then
                        pos = pos + StageAPI.BossOffset
                    end
                end

                StageAPI.PlayingBossSprite:RenderLayer(layer, pos)
            end
        elseif isPlaying then
             StageAPI.PlayingBossSprite:Stop()
             StageAPI.PlayingBossSprite = nil
        end

        if not isPlaying then
            StageAPI.UnskippableBossAnim = nil
            StageAPI.BossOffset = nil
        end

        menuConfirmTriggered = nil
        for _, player in ipairs(players) do
            if Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, player.ControllerIndex) then
                menuConfirmTriggered = true
                break
            end
        end
    end)

    StageAPI.Bosses = {}
    function StageAPI.AddBossData(id, bossData)
        StageAPI.Bosses[id] = bossData

        if not bossData.Name then
            bossData.Name = id
        end

        if not bossData.Weight then
            bossData.Weight = 1
        end

        return id
    end

    function StageAPI.GetBossData(id)
        return StageAPI.Bosses[id]
    end

    function StageAPI.PlayBossAnimation(boss, unskippable)
        local bSpot, pSpot = StageAPI.GetStageSpot()
        local gfxData = StageAPI.TryGetPlayerGraphicsInfo(StageAPI.Players[1])
        StageAPI.PlayBossAnimationManual({
            BossPortrait = boss.Portrait,
            BossPortraitTwo = boss.PortraitTwo,
            BossName = boss.BossName or boss.Bossname,
            BossSpot = boss.Spot or bSpot,
            PlayerPortrait = gfxData.Portrait,
            PlayerName = gfxData.Name,
            PlayerSpot = pSpot,
            Unskippable = unskippable,
            BossOffset = boss.Offset
        })
    end

    local horsemanRoomSubtypes = {
        9, -- Famine
        10, -- Pestilence
        11, -- War
        12, -- Death
        22, -- Headless Horseman
        38 -- Conquest
    }

    StageAPI.EncounteredBosses = {}
    function StageAPI.SetBossEncountered(name, encountered)
        if encountered == nil then
            encountered = true
        end

        StageAPI.EncounteredBosses[name] = encountered
    end

    function StageAPI.GetBossEncountered(name)
        return StageAPI.EncounteredBosses[name]
    end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
        if not continued then
            StageAPI.EncounteredBosses = {}
        end
    end)

    StageAPI.BossSelectRNG = RNG()
    function StageAPI.SelectBoss(bosses, rng, roomDesc, ignoreNoOptions)
        local bossID = StageAPI.CallCallbacks("PRE_BOSS_SELECT", true, bosses, rng, roomDesc, ignoreNoOptions)
        if type(bossID) == "table" then
            bosses = bossID
            bossID = nil
        end

        if not bossID then
            roomDesc = roomDesc or level:GetCurrentRoomDesc()
            local isHorsemanRoom = StageAPI.IsIn(horsemanRoomSubtypes, roomDesc.Data.Subtype)

            local floatWeights
            local totalUnencounteredWeight = 0
            local totalValidWeight = 0
            local totalForcedWeight = 0
            local unencounteredBosses = {}
            local validBosses = {}
            local forcedBosses = {}
            local pool = bosses.Pool or bosses
            for _, potentialBossID in ipairs(pool) do
                local poolEntry
                if type(potentialBossID) == "table" then
                    poolEntry = potentialBossID
                    potentialBossID = poolEntry.BossID
                else
                    poolEntry = {
                        BossID = potentialBossID
                    }
                end

                local potentialBoss = StageAPI.GetBossData(potentialBossID)
                local encountered = StageAPI.GetBossEncountered(potentialBoss.Name)
                if not encountered and potentialBoss.NameTwo then
                    encountered = StageAPI.GetBossEncountered(potentialBoss.NameTwo)
                end

                local weight = poolEntry.Weight or potentialBoss.Weight or 1
                local forced
                local invalid
                if potentialBoss.Rooms then
                    local validRooms, validRoomWeights = StageAPI.GetValidRoomsForLayout{
                        RoomList = potentialBoss.Rooms,
                        RoomDescriptor = roomDesc
                    }

                    if #validRooms == 0 or validRoomWeights == 0 then
                        invalid = true
                    end
                end

                if not invalid then
                    if isHorsemanRoom then
                        if poolEntry.AlwaysReplaceHorsemen or potentialBoss.AlwaysReplaceHorsemen then
                            forced = true
                        elseif not (poolEntry.Horseman or potentialBoss.Horseman) then
                            invalid = true
                        end
                    elseif poolEntry.OnlyReplaceHorsemen or potentialBoss.OnlyReplaceHorsemen then
                        invalid = true
                    end
                end

                if not invalid then
                    if forced then
                        totalForcedWeight = totalForcedWeight + weight
                        forcedBosses[#forcedBosses + 1] = {potentialBossID, weight}
                    end

                    if not encountered then
                        totalUnencounteredWeight = totalUnencounteredWeight + weight
                        unencounteredBosses[#unencounteredBosses + 1] = {potentialBossID, weight}
                    end

                    totalValidWeight = totalValidWeight + weight
                    validBosses[#validBosses + 1] = {potentialBossID, weight}
                end

                if weight % 1 ~= 0 then
                    floatWeights = true
                end
            end

            if not rng then
                rng = StageAPI.BossSelectRNG
                rng:SetSeed(roomDesc.SpawnSeed, 0)
            end

            if #forcedBosses > 0 then
                bossID = StageAPI.WeightedRNG(forcedBosses, rng, nil, totalForcedWeight, floatWeights)
            elseif #unencounteredBosses > 0 then
                bossID = StageAPI.WeightedRNG(unencounteredBosses, rng, nil, totalUnencounteredWeight, floatWeights)
            elseif #validBosses > 0 then
                bossID = StageAPI.WeightedRNG(validBosses, rng, nil, totalValidWeight, floatWeights)
            elseif not ignoreNoOptions then
                local err = "Trying to select boss, but none are valid! Options were:\n"
                for _, potentialBossID in ipairs(bosses) do
                    err = err .. potentialBossID .. "\n"
                end

                StageAPI.LogErr(err)
            end
        end

        return bossID
    end

    function StageAPI.AddBossToBaseFloorPool(poolEntry, stage, stageType, noStageTwo)
        if not poolEntry or type(poolEntry) ~= "table" or not poolEntry.BossID then
            StageAPI.LogErr("AddBossToBaseFloorPool requires a PoolEntry table with BossID set")
            return
        end

        if not StageAPI.GetBossData(poolEntry.BossID) then
            StageAPI.LogErr("Attempting to add invalid boss id " .. poolEntry.BossID .. " to pool")
            return
        end

        local floorInfo = StageAPI.GetBaseFloorInfo(stage, stageType, false)
        floorInfo.HasCustomBosses = true
        if not floorInfo.Bosses then
            floorInfo.Bosses = {Pool = {}}
        end

        floorInfo.Bosses.Pool[#floorInfo.Bosses.Pool + 1] = poolEntry

        if not noStageTwo then
            local stageTwo = stageToSecondStage[stage]
            if stageTwo and not noBossStages[stageTwo] then
                StageAPI.AddBossToBaseFloorPool(poolEntry, stageTwo, stageType, true)
            end
        end
    end
end

StageAPI.LogMinor("Loading Transition Handler")
do -- Transition
    StageAPI.StageTypeToString = {
        [StageType.STAGETYPE_ORIGINAL] = "",
        [StageType.STAGETYPE_WOTL] = "a",
        [StageType.STAGETYPE_AFTERBIRTH] = "b",
		[StageType.STAGETYPE_REPENTANCE] = "c",
		[StageType.STAGETYPE_REPENTANCE_B] = "d"
    }

    StageAPI.StageTypes = {
        StageType.STAGETYPE_ORIGINAL,
        StageType.STAGETYPE_WOTL,
        StageType.STAGETYPE_AFTERBIRTH,
		StageType.STAGETYPE_REPENTANCE,
		StageType.STAGETYPE_REPENTANCE_B
    }

    StageAPI.TransitionAnimation = Sprite()
    StageAPI.TransitionAnimation:Load("stageapi/transition/customnightmare.anm2", true)

    StageAPI.RemovedHUD = false
    StageAPI.TransitionIsPlaying = false

    StageAPI.Seeds = game:GetSeeds()

    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if StageAPI.TransitionAnimation:IsPlaying("Scene") or StageAPI.TransitionAnimation:IsPlaying("SceneNoShake") then
            if StageAPI.IsOddRenderFrame then
                StageAPI.TransitionAnimation:Update()
            end

            local stop
            for _, player in ipairs(players) do
                player.ControlsCooldown = 80

                if Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, player.ControllerIndex) or
                Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, player.ControllerIndex) then
                    stop = true
                end
            end

            if stop or StageAPI.TransitionAnimation:IsEventTriggered("LastFrame") then
                for _, player in ipairs(players) do
                    player.Position = room:GetCenterPos()
                    player:AnimateAppear()
                end

                StageAPI.TransitionAnimation:Stop()
            end

            StageAPI.TransitionIsPlaying = true
            StageAPI.RenderBlackScreen()
            StageAPI.TransitionAnimation:Render(StageAPI.GetScreenCenterPosition(), zeroVector, zeroVector)
        elseif StageAPI.TransitionIsPlaying then -- Finished transition
            StageAPI.TransitionIsPlaying = false
            if StageAPI.CurrentStage then
                local name = StageAPI.CurrentStage:GetDisplayName()
                StageAPI.PlayTextStreak(name)
            end
        end

        if StageAPI.IsHUDAnimationPlaying() then
            if not StageAPI.Seeds:HasSeedEffect(SeedEffect.SEED_NO_HUD) then
                StageAPI.Seeds:AddSeedEffect(SeedEffect.SEED_NO_HUD)
                StageAPI.RemovedHUD = true
            end
        elseif StageAPI.Seeds:HasSeedEffect(SeedEffect.SEED_NO_HUD) and StageAPI.RemovedHUD then
            StageAPI.Seeds:RemoveSeedEffect(SeedEffect.SEED_NO_HUD)
            StageAPI.RemovedHUD = false
        end
    end)

    function StageAPI.IsHUDAnimationPlaying(spriteOnly)
        return StageAPI.TransitionAnimation:IsPlaying("Scene")
        or StageAPI.TransitionAnimation:IsPlaying("SceneNoShake")
        or StageAPI.BossSprite:IsPlaying("Scene")
        or StageAPI.BossSprite:IsPlaying("DoubleTrouble")
        or (
            room:GetType() == RoomType.ROOM_BOSS
            and room:GetFrameCount() <= 0
            and not room:IsClear()
            and game:IsPaused()
            and not spriteOnly
        )
    end

    mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
        if StageAPI.IsHUDAnimationPlaying() then
            return true
        end
    end)

    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, e)
        if StageAPI.IsHUDAnimationPlaying() then
            return false
        end
    end, EntityType.ENTITY_PLAYER)

    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
        if StageAPI.IsHUDAnimationPlaying() then
            eff:Remove()
        end
    end, EffectVariant.MOM_FOOT_STOMP)

    function StageAPI.GetLevelTransitionIcon(stage, stype)
        local base = StageAPI.GetBaseFloorInfo().Prefix
        if base == "07_womb" and stype == StageType.STAGETYPE_WOTL then
            base = "utero"
        end

        return "stageapi/transition/levelicons/" .. base .. ".png"
    end

    function StageAPI.PlayTransitionAnimationManual(portraitbig, icon, transitionmusic, queue, noshake)
        portraitbig = portraitbig or "gfx/ui/stage/playerportraitbig_01_isaac.png"
        icon = icon or "stageapi/transition/levelicons/unknown.png"
        transitionmusic = transitionmusic or Music.MUSIC_JINGLE_NIGHTMARE

        if queue ~= false then
            queue = queue or StageAPI.Music:GetCurrentMusicID()
        end

        StageAPI.TransitionAnimation:ReplaceSpritesheet(1, portraitbig)
        StageAPI.TransitionAnimation:ReplaceSpritesheet(2, icon)
        StageAPI.TransitionAnimation:LoadGraphics()
        if noshake then
            StageAPI.TransitionAnimation:Play("SceneNoShake", true)
        else
            StageAPI.TransitionAnimation:Play("Scene", true)
        end

        StageAPI.Music:Play(transitionmusic, 0)
        StageAPI.Music:UpdateVolume()

        if queue ~= false then
            StageAPI.Music:Queue(queue)
        end
    end

    function StageAPI.PlayTransitionAnimation(stage)
        local gfxData = StageAPI.TryGetPlayerGraphicsInfo(players[1])
        StageAPI.PlayTransitionAnimationManual(gfxData.PortraitBig, stage.TransitionIcon, stage.TransitionMusic, stage.Music[RoomType.ROOM_DEFAULT], gfxData.NoShake)
    end

    StageAPI.StageRNG = RNG()
    function StageAPI.GotoCustomStage(stage, playTransition, noForgetSeed)
        if not noForgetSeed then
            local realstage
            if stage.NormalStage then
                realstage = stage.Stage
            else
                realstage = stage.Replaces.OverrideStage
            end

            StageAPI.Seeds:ForgetStageSeed(realstage)
        end

        if stage.NormalStage then
            local stageType = stage.StageType
            if not stageType then
                StageAPI.StageRNG:SetSeed(StageAPI.Seeds:GetStageSeed(stage.Stage), 0)
                stageType = StageAPI.StageTypes[StageAPI.Random(1, #StageAPI.StageTypes, StageAPI.StageRNG)]
            end

            if playTransition then
                local gfxData = StageAPI.TryGetPlayerGraphicsInfo(players[1])
                StageAPI.PlayTransitionAnimationManual(gfxData.PortraitBig, StageAPI.GetLevelTransitionIcon(stage.Stage, stageType), nil, nil, gfxData.NoShake)
            end

            Isaac.ExecuteCommand("stage " .. tostring(stage.Stage) .. StageAPI.StageTypeToString[stageType])
        else
            local replace = stage.Replaces
            local absolute = replace.OverrideStage
            StageAPI.NextStage = stage
            if playTransition then
                StageAPI.PlayTransitionAnimation(stage)
            end

            Isaac.ExecuteCommand("stage " .. tostring(absolute) .. StageAPI.StageTypeToString[replace.OverrideStageType])
        end
    end

    function StageAPI.SpawnCustomTrapdoor(position, goesTo, anm2, size, alreadyEntering)
        anm2 = anm2 or "gfx/grid/door_11_trapdoor.anm2"
        size = size or 24
        local trapdoor = Isaac.Spawn(StageAPI.E.FloorEffectCreep.T, StageAPI.E.FloorEffectCreep.V, StageAPI.E.FloorEffectCreep.S, position, zeroVector, nil)
        trapdoor.Variant = StageAPI.E.Trapdoor.V
        trapdoor.SubType = StageAPI.E.Trapdoor.S
        trapdoor.Size = size
        local sprite, data = trapdoor:GetSprite(), trapdoor:GetData()
        sprite:Load(anm2, true)

        if alreadyEntering then
            sprite:Play("Opened", true)
            data.BeingEntered = true
            for _, player in ipairs(players) do
                player:AnimateTrapdoor()
            end
        else
            sprite:Play("Closed", true)
        end

        data.GoesTo = goesTo
        return trapdoor
    end

    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
        local sprite, data = eff:GetSprite(), eff:GetData()
        if sprite:IsFinished("Open Animation") then
            sprite:Play("Opened", true)
        elseif (sprite:IsPlaying("Closed") or sprite:IsFinished("Closed")) and room:IsClear() then
            local playerTooClose
            for _, player in ipairs(players) do
                local size = (eff.Size + player.Size)
                if player.Position:DistanceSquared(eff.Position) < size * size then
                    playerTooClose = true
                end
            end

            if not playerTooClose then
                sprite:Play("Open Animation", true)
            end
        elseif sprite:IsPlaying("Opened") or sprite:IsFinished("Opened") then
            if not data.BeingEntered then
                local touchingTrapdoor
                for _, player in ipairs(players) do
                    local size = (eff.Size + player.Size)
                    if player.Position:DistanceSquared(eff.Position) < size * size then
                        touchingTrapdoor = true
                    end
                end

                if touchingTrapdoor then
                    data.BeingEntered = true
                    for _, player in ipairs(players) do
                        player:AnimateTrapdoor()
                    end
                end
            else
                local animationOver
                for _, player in ipairs(players) do
                    player.ControlsCooldown = 5
                    player.Velocity = (StageAPI.Lerp(player.Position, eff.Position, 0.5) - player.Position) / 2
                    if player:IsExtraAnimationFinished() then
                        animationOver = true
                    end
                end

                if animationOver then
                    StageAPI.GotoCustomStage(data.GoesTo, true)
                end
            end
        end
    end, StageAPI.E.Trapdoor.V)
end

StageAPI.LogMinor("Loading Rock Alt Breaking Override")
do -- Rock Alt Override
    StageAPI.SpawnOverriddenGrids = {}
    StageAPI.JustBrokenGridSpawns = {}
    StageAPI.RecentFarts = {}
    StageAPI.LastRockAltCheckedRoom = nil
    mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, id, variant, subtype, position, velocity, spawner, seed)
        if StageAPI.LastRockAltCheckedRoom ~= level:GetCurrentRoomIndex() then
            StageAPI.LastRockAltCheckedRoom = level:GetCurrentRoomIndex()
            StageAPI.SpawnOverriddenGrids = {}
        end

        local lindex = StageAPI.GetCurrentRoomID()
        local grindex = room:GetGridIndex(position)
        if StageAPI.SpawnOverriddenGrids[grindex] then
            local grid = room:GetGridEntity(grindex)

            local stateCheck
            if type(StageAPI.SpawnOverriddenGrids[grindex]) == "number" then
                stateCheck = StageAPI.SpawnOverriddenGrids[grindex]
            elseif grid then
                stateCheck = StageAPI.DefaultBrokenGridStateByType[grid.Type] or 2
            end

            if not grid or grid.State == stateCheck then
                if (id == EntityType.ENTITY_PICKUP and (variant == PickupVariant.PICKUP_COLLECTIBLE or variant == PickupVariant.PICKUP_TAROTCARD or variant == PickupVariant.PICKUP_HEART or variant == PickupVariant.PICKUP_COIN or variant == PickupVariant.PICKUP_TRINKET or variant == PickupVariant.PICKUP_PILL))
                or id == EntityType.ENTITY_SPIDER
                or (id == EntityType.ENTITY_EFFECT and (variant == EffectVariant.FART or variant == EffectVariant.POOF01 or variant == EffectVariant.CREEP_RED))
                or id == EntityType.ENTITY_PROJECTILE
                or id == EntityType.ENTITY_HOST
                or id == EntityType.ENTITY_MUSHROOM then
                    if id == EntityType.ENTITY_EFFECT and variant == EffectVariant.FART then
                        StageAPI.RecentFarts[grindex] = 2
                        sfx:Stop(SoundEffect.SOUND_FART)
                    end

                    if not StageAPI.JustBrokenGridSpawns[grindex] then
                        StageAPI.JustBrokenGridSpawns[grindex] = {}
                    end

                    StageAPI.JustBrokenGridSpawns[grindex][#StageAPI.JustBrokenGridSpawns[grindex] + 1] = {
                        Type = id,
                        Variant = variant,
                        SubType = subtype,
                        Position = position,
                        Velocity = velocity,
                        Spawner = spawner,
                        Seed = seed
                    }

                    if id == EntityType.ENTITY_EFFECT then
                        return {
                            StageAPI.E.DeleteMeEffect.T,
                            StageAPI.E.DeleteMeEffect.V,
                            0,
                            seed
                        }
                    elseif id == EntityType.ENTITY_PICKUP then
                        return {
                            StageAPI.E.DeleteMePickup.T,
                            StageAPI.E.DeleteMePickup.V,
                            0,
                            seed
                        }
                    elseif id == EntityType.ENTITY_PROJECTILE then
                        return {
                            StageAPI.E.DeleteMeProjectile.T,
                            StageAPI.E.DeleteMeProjectile.V,
                            0,
                            seed
                        }
                    else
                        return {
                            StageAPI.E.DeleteMeNPC.T,
                            StageAPI.E.DeleteMeNPC.V,
                            0,
                            seed
                        }
                    end
                end
            end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, e, amount, flag, source)
        if flag == 0 and source and source.Type == 0 and not e:GetData().TrueFart then
            local hasFarts = next(StageAPI.RecentFarts) ~= nil

            if hasFarts then
                e:GetData().Farted = {amount, source}
                return false
            end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, npc)
        local data = npc:GetData()
        if data.Farted then
            local stoppedFart
            for fart, timer in pairs(StageAPI.RecentFarts) do
                if room:GetGridPosition(fart):Distance(npc.Position) < 150 + npc.Size then
                    stoppedFart = true
                    break
                end
            end

            if not stoppedFart then
                data.TrueFart = true
                npc:TakeDamage(data.Farted[1], 0, EntityRef(npc), 0)
                data.TrueFart = nil
            end

            data.Farted = nil
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
        local data = npc:GetData()
        if data.Farted then
            local stoppedFart
            for fart, timer in pairs(StageAPI.RecentFarts) do
                if room:GetGridPosition(fart):Distance(npc.Position) < 150 + npc.Size then
                    stoppedFart = true
                    break
                end
            end

            if not stoppedFart then
                data.TrueFart = true
                npc:TakeDamage(data.Farted[1], 0, EntityRef(npc), 0)
                data.TrueFart = nil
            end

            data.Farted = nil
        end

        for fart, timer in pairs(StageAPI.RecentFarts) do
            if npc:HasEntityFlags(EntityFlag.FLAG_POISON) and room:GetGridPosition(fart):Distance(npc.Position) < 150 + npc.Size then
                npc:RemoveStatusEffects()
                break
            end
        end
    end)

    function StageAPI.DeleteEntity(entA, entB)
        local ent
        if entA.Remove then
            ent = entA
        else
            ent = entB
        end

        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        ent:Remove()
    end

    mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
        if npc.Variant == StageAPI.E.DeleteMeNPC.V then
            StageAPI.DeleteEntity(npc)
        end
    end, StageAPI.E.DeleteMeNPC.T)
    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, StageAPI.DeleteEntity, StageAPI.E.DeleteMeEffect.V)
    mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, StageAPI.DeleteEntity, StageAPI.E.DeleteMeProjectile.V)
    mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, StageAPI.DeleteEntity, StageAPI.E.DeleteMePickup.V)

    StageAPI.PickupChooseRNG = RNG()
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        StageAPI.PickupChooseRNG:SetSeed(room:GetSpawnSeed(), 0)
    end)

    mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
        if not pickup:Exists() then return end
        local card = game:GetItemPool():GetCard(StageAPI.PickupChooseRNG:Next(), false, true, true)
        local spawned = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, pickup.Position, zeroVector, nil)
        spawned:Update() -- get the spawned pickup up to speed with the original
        StageAPI.DeleteEntity(pickup)
    end, StageAPI.E.RandomRune.V)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        for fart, timer in pairs(StageAPI.RecentFarts) do
            StageAPI.RecentFarts[fart] = timer - 1
            if timer <= 1 then
                StageAPI.RecentFarts[fart] = nil
            end
        end

        for grindex, exists in pairs(StageAPI.SpawnOverriddenGrids) do
            local grid = room:GetGridEntity(grindex)
            local stateCheck = 2
            if type(exists) == "number" then
                stateCheck = exists
            end

            if not grid or grid.State == stateCheck then
                StageAPI.SpawnOverriddenGrids[grindex] = nil
                StageAPI.CallCallbacks("POST_OVERRIDDEN_GRID_BREAK", true, grindex, grid, StageAPI.JustBrokenGridSpawns[grindex])
            end
        end

        StageAPI.JustBrokenGridSpawns = {}
    end)

    function StageAPI.AreRockAltEffectsOverridden()
        if (StageAPI.CurrentStage and StageAPI.CurrentStage.OverridingRockAltEffects) or StageAPI.TemporaryOverrideRockAltEffects then
            local isOverridden = true
            if not StageAPI.TemporaryOverrideRockAltEffects then
                if type(StageAPI.CurrentStage.OverridingRockAltEffects) == "table" then
                    isOverridden = StageAPI.IsIn(StageAPI.CurrentStage.OverridingRockAltEffects, StageAPI.GetCurrentRoomType())
                end
            end

            return isOverridden
        end
    end

    function StageAPI.TemporarilyOverrideRockAltEffects()
        StageAPI.TemporaryOverrideRockAltEffects = true
    end

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        StageAPI.TemporaryOverrideRockAltEffects = nil
        StageAPI.RecentFarts = {}
        StageAPI.SpawnOverriddenGrids = {}
        StageAPI.JustBrokenGridSpawns = {}
    end)

    StageAPI.AddCallback("StageAPI", "POST_GRID_UPDATE", 0, function()
        if StageAPI.AreRockAltEffectsOverridden() then
            for i = room:GetGridWidth(), room:GetGridSize() do
                local grid = room:GetGridEntity(i)
                if not StageAPI.SpawnOverriddenGrids[i] and grid and (grid.Desc.Type == GridEntityType.GRID_ROCK_ALT and grid.State ~= 2) then
                    StageAPI.SpawnOverriddenGrids[i] = true
                end
            end
        end
    end)
end

StageAPI.LogMinor("Loading Core Callbacks")
do -- Callbacks
    StageAPI.NonOverrideMusic = {
        {Music.MUSIC_GAME_OVER, false, true},
        Music.MUSIC_JINGLE_GAME_OVER,
        Music.MUSIC_JINGLE_SECRETROOM_FIND,
        {Music.MUSIC_JINGLE_NIGHTMARE, true},
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

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom and currentRoom.Loaded then
            local isClear = currentRoom.IsClear
            currentRoom.IsClear = room:IsClear()
            currentRoom.JustCleared = nil
            if not isClear and currentRoom.IsClear then
                currentRoom.ClearCount = currentRoom.ClearCount + 1
                StageAPI.CallCallbacks("POST_ROOM_CLEAR", false)
                currentRoom.JustCleared = true
            end
        end
    end)

    StageAPI.RoomGrids = {}

    function StageAPI.PreventRoomGridRegrowth()
        local roomGrids = StageAPI.GetTableIndexedByDimension(StageAPI.RoomGrids, true)
        roomGrids[StageAPI.GetCurrentRoomID()] = {}
    end

    function StageAPI.StoreRoomGrids()
        local roomIndex = StageAPI.GetCurrentRoomID()
        local grids = {}
        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)
            if grid and grid.Desc.Type ~= GridEntityType.GRID_WALL and grid.Desc.Type ~= GridEntityType.GRID_DOOR then
                grids[i] = true
            end
        end

        local roomGrids = StageAPI.GetTableIndexedByDimension(StageAPI.RoomGrids, true)
        roomGrids[roomIndex] = grids
    end

    function StageAPI.RemoveExtraGrids(grids)
        for i = 0, room:GetGridSize() do
            if not grids[i] then
                local grid = room:GetGridEntity(i)
                if grid and grid.Desc.Type ~= GridEntityType.GRID_WALL and grid.Desc.Type ~= GridEntityType.GRID_DOOR then
                    room:RemoveGridEntity(i, 0, false)
                end
            end
        end

        StageAPI.CalledRoomUpdate = true
        room:Update()
        StageAPI.CalledRoomUpdate = false
    end

    mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
        if StageAPI.CalledRoomUpdate then
            return true
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
        StageAPI.RoomGrids = {}
    end)

    StageAPI.RoomNamesEnabled = false
    StageAPI.PreviousGridCount = nil

    function StageAPI.ReprocessRoomGrids()
        StageAPI.PreviousGridCount = nil
    end

    mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, StageAPI.ReprocessRoomGrids, CollectibleType.COLLECTIBLE_D12)

    function StageAPI.UseD7()
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom then
            if room:GetType() == RoomType.ROOM_BOSS then
                game:MoveToRandomRoom(false, room:GetSpawnSeed())
            else
                StageAPI.JustUsedD7 = true
            end

            for _, player in ipairs(players) do
                if player:HasCollectible(CollectibleType.COLLECTIBLE_D7) and Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
                    player:AnimateCollectible(CollectibleType.COLLECTIBLE_D7, "UseItem", "PlayerPickup")
                end
            end

            return true
        end
    end

    mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, StageAPI.UseD7, CollectibleType.COLLECTIBLE_D7)

    mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
        if StageAPI.InNewStage() then
            for _, player in ipairs(players) do
                if player:HasCollectible(CollectibleType.COLLECTIBLE_FORGET_ME_NOW) and Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_FORGET_ME_NOW)
                end
            end

            StageAPI.GotoCustomStage(StageAPI.CurrentStage, true)
            return true
        end
    end, CollectibleType.COLLECTIBLE_FORGET_ME_NOW)

    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
        if StageAPI.InNewStage() and not eff:GetData().StageAPIDoNotDelete then
            eff:Remove()
        end
    end, EffectVariant.WATER_DROPLET)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if StageAPI.JustUsedD7 then
            StageAPI.JustUsedD7 = nil
            local currentRoom = StageAPI.GetCurrentRoom()
            if currentRoom then
                currentRoom.IsClear = currentRoom.WasClearAtStart
                currentRoom:Load()
            end
        end
    end)

    function StageAPI.ShouldOverrideRoom(inStartingRoom, currentRoom)
        if inStartingRoom == nil then
            inStartingRoom = level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()
        end

        if currentRoom == nil then
            currentRoom = StageAPI.GetCurrentRoom()
        end

        if currentRoom or (StageAPI.ActiveTransitionToExtraRoom or StageAPI.LoadedExtraRoom) or (not inStartingRoom and StageAPI.InNewStage() and ((StageAPI.CurrentStage.Rooms and StageAPI.CurrentStage.Rooms[room:GetType()]) or (StageAPI.CurrentStage.Bosses and room:GetType() == RoomType.ROOM_BOSS))) then
            return true
        end
    end

    StageAPI.AddCallback("StageAPI", "POST_SELECT_BOSS_MUSIC", 0, function(stage, usingMusic, isCleared)
        if not isCleared then
            if stage.Name == "Necropolis" or stage.Alias == "Necropolis" then
                if room:IsCurrentRoomLastBoss() and (level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 or level:GetStage() == LevelStage.STAGE3_2) then
                    return Music.MUSIC_MOM_BOSS
                end
            elseif stage.Name == "Utero" or stage.Alias == "Utero" then
                if room:IsCurrentRoomLastBoss() and (level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 or level:GetStage() == LevelStage.STAGE4_2) then
                    return Music.MUSIC_MOMS_HEART_BOSS
                end
            end
        end
    end)

    StageAPI.NonOverrideTrapdoors = {
        ["gfx/grid/trapdoor_downpour.anm2"] = true,
        ["gfx/grid/trapdoor_mines.anm2"] = true,
        ["gfx/grid/trapdoor_mausoleum.anm2"] = true,
    }

    function StageAPI.CheckStageTrapdoor(grid, index)
        if not (grid.Desc.Type == GridEntityType.GRID_TRAPDOOR and grid.State == 1) or StageAPI.NonOverrideTrapdoors[grid:GetSprite():GetFilename()] then
            return
        end

        local entering = false
        for _, player in ipairs(players) do
            local dist = player.Position:DistanceSquared(grid.Position)
            local size = player.Size + 32
            if dist < size * size then
                entering = true
                break
            end
        end

        if not entering then return end

        local currStage = StageAPI.CurrentStage or {}
        local nextStage = StageAPI.CallCallbacks("PRE_SELECT_NEXT_STAGE", true, StageAPI.CurrentStage) or currStage.NextStage
        if nextStage and not currStage.OverridingTrapdoors then
            StageAPI.SpawnCustomTrapdoor(room:GetGridPosition(index), nextStage, grid:GetSprite():GetFilename(), 32, true)
            room:RemoveGridEntity(index, 0, false)
        end
    end

    StageAPI.GlobalCommandMode = false
    StageAPI.LastBackdropType = nil
    StageAPI.Music = MusicManager()
    StageAPI.MusicRNG = RNG()
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if game:GetFrameCount() <= 0 then
            return
        end

        local currentListIndex = StageAPI.GetCurrentRoomID()
        local stage = level:GetStage()
        local stype = level:GetStageType()
        local updatedGrids
        local gridCount = 0
        local pits = {}
        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)
            if grid then
                if grid.Desc.Type == GridEntityType.GRID_PIT then
                    pits[#pits + 1] = {grid, i}
                end

                StageAPI.CheckStageTrapdoor(grid, i)

                gridCount = gridCount + 1
            end
        end

        if gridCount ~= StageAPI.PreviousGridCount then
            local gridCallbacks = StageAPI.CallCallbacks("POST_GRID_UPDATE")

            updatedGrids = true
            local roomGrids = StageAPI.GetTableIndexedByDimension(StageAPI.RoomGrids, true)
            if roomGrids[currentListIndex] then
                StageAPI.StoreRoomGrids()
            end

            StageAPI.PreviousGridCount = gridCount
        end

        if sfx:IsPlaying(SoundEffect.SOUND_CASTLEPORTCULLIS) and not (StageAPI.CurrentStage and StageAPI.CurrentStage.BossMusic and StageAPI.CurrentStage.BossMusic.Intro) then
            sfx:Stop(SoundEffect.SOUND_CASTLEPORTCULLIS)
            sfx:Play(StageAPI.S.BossIntro, 1, 0, false, 1)
        end

        if StageAPI.InOverriddenStage() and StageAPI.CurrentStage then
            local roomType = room:GetType()
            local rtype = StageAPI.GetCurrentRoomType()
            local grids

            local gridsOverride = StageAPI.CallCallbacks("PRE_UPDATE_GRID_GFX", false)

            local currentRoom = StageAPI.GetCurrentRoom()
            if gridsOverride then
                grids = gridsOverride
            elseif currentRoom and currentRoom.Data.RoomGfx then
                grids = currentRoom.Data.RoomGfx.Grids
            elseif StageAPI.CurrentStage.RoomGfx and StageAPI.CurrentStage.RoomGfx[rtype] and StageAPI.CurrentStage.RoomGfx[rtype].Grids then
                grids = StageAPI.CurrentStage.RoomGfx[rtype].Grids
            end

            if grids then
                if grids.Bridges then
                    for _, grid in ipairs(pits) do
                        StageAPI.CheckBridge(grid[1], grid[2], grids.Bridges)
                    end
                end

                if not StageAPI.RoomRendered and updatedGrids then
                    StageAPI.ChangeGrids(grids)
                end
            end

            local id = StageAPI.Music:GetCurrentMusicID()
            local musicID, shouldLayer, shouldQueue, disregardNonOverride = StageAPI.CurrentStage:GetPlayingMusic()
            if musicID then
                if not shouldQueue then
                    shouldQueue = musicID
                end

                local queuedID = StageAPI.Music:GetQueuedMusicID()
                local canOverride, canOverrideQueue, neverOverrideQueue = StageAPI.CanOverrideMusic(queuedID)
                local shouldOverrideQueue = shouldQueue and (canOverride or canOverrideQueue or disregardNonOverride)
                if not neverOverrideQueue and shouldQueue then
                    shouldOverrideQueue = shouldOverrideQueue or (id == queuedID)
                end

                if queuedID ~= shouldQueue and shouldOverrideQueue then
                    StageAPI.Music:Queue(shouldQueue)
                end

                local canOverride = StageAPI.CanOverrideMusic(id)
                if id ~= musicID and (canOverride or disregardNonOverride) then
                    StageAPI.Music:Play(musicID, 0)
                end

                StageAPI.Music:UpdateVolume()

                if shouldLayer and not StageAPI.Music:IsLayerEnabled() then
                    StageAPI.Music:EnableLayer()
                elseif not shouldLayer and StageAPI.Music:IsLayerEnabled() then
                    StageAPI.Music:DisableLayer()
                end
            end

            StageAPI.RoomRendered = true
        end

        local backdropType = room:GetBackdropType()
        if StageAPI.LastBackdropType ~= backdropType then
            local currentRoom = StageAPI.GetCurrentRoom()
            local usingGfx
            local callbacks = StageAPI.GetCallbacks("PRE_CHANGE_ROOM_GFX")
            for _, callback in ipairs(callbacks) do
                local ret = callback.Function(currentRoom, usingGfx, true)
                if ret ~= nil then
                    usingGfx = ret
                end
            end

            if usingGfx then
                StageAPI.ChangeRoomGfx(usingGfx)
                if currentRoom then
                    currentRoom.Data.RoomGfx = usingGfx
                end
            else
                if backdropType ~= 16 and room:GetType() ~= RoomType.ROOM_DUNGEON then
                    if backdropType == BackdropType.UTERO then
                        StageAPI.ChangeShading("_utero")
                    else
                        StageAPI.ChangeShading("_default")
                    end
                end
            end

            StageAPI.CallCallbacks("POST_CHANGE_ROOM_GFX", false, currentRoom, usingGfx, true)

            StageAPI.LastBackdropType = backdropType
        end

        if StageAPI.RoomNamesEnabled then
            local currentRoom = StageAPI.GetCurrentRoom()
            local roomDescriptorData = level:GetCurrentRoomDesc().Data
            local scale = 0.5
            local base, custom

            if StageAPI.RoomNamesEnabled == 2 then
                base = tostring(roomDescriptorData.StageID) .. "." .. tostring(roomDescriptorData.Variant) .. "." .. tostring(roomDescriptorData.Subtype) .. " " .. roomDescriptorData.Name
            else
                base = "Base Room Stage ID: " .. tostring(roomDescriptorData.StageID) .. ", Name: " .. roomDescriptorData.Name .. ", ID: " .. tostring(roomDescriptorData.Variant) .. ", Difficulty: " .. tostring(roomDescriptorData.Difficulty) .. ", Subtype: " .. tostring(roomDescriptorData.Subtype)
            end

            if currentRoom and currentRoom.Layout.RoomFilename and currentRoom.Layout.Name and currentRoom.Layout.Variant then
                if StageAPI.RoomNamesEnabled == 2 then
                    custom = "Room File: " .. currentRoom.Layout.RoomFilename .. ", Name: " .. currentRoom.Layout.Name .. ", ID: " .. tostring(currentRoom.Layout.Variant)
                else
                    custom = "Room File: " .. currentRoom.Layout.RoomFilename .. ", Name: " .. currentRoom.Layout.Name .. ", ID: " .. tostring(currentRoom.Layout.Variant) .. ", Difficulty: " .. tostring(currentRoom.Layout.Difficulty) .. ", Subtype: " .. tostring(currentRoom.Layout.SubType)
                end
            else
                custom = "Room names enabled, custom room N/A"
            end


            Isaac.RenderScaledText(custom, 60, 35, scale, scale, 255, 255, 255, 0.75)
            Isaac.RenderScaledText(base, 60, 45, scale, scale, 255, 255, 255, 0.75)
        end

        if StageAPI.GlobalCommandMode then
            _G.slog = StageAPI.Log
            _G.game = game
            _G.level = level
            _G.room = room
            _G.desc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
            _G.apiroom = StageAPI.GetCurrentRoom()
            _G.player = players[1]
        end
    end)

    function StageAPI.SetCurrentBossRoomInPlace(bossID, room)
        local boss = StageAPI.GetBossData(bossID)
        if not boss then
            StageAPI.LogErr("Trying to set boss with invalid ID: " .. tostring(bossID))
            return
        end

        room.PersistentData.BossID = bossID
        StageAPI.CallCallbacks("POST_BOSS_ROOM_INIT", false, room, boss, bossID)
    end

    function StageAPI.GenerateBossRoom(bossID, checkEncountered, bosses, hasHorseman, requireRoomTypeBoss, noPlayBossAnim, unskippableBossAnim, isExtraRoom, shape, ignoreDoors, doors, roomType)
        local args = bossID
        local roomArgs = checkEncountered
        if type(args) ~= "table" then
            args = {
                BossID = bossID,
                CheckEncountered = checkEncountered,
                Bosses = bosses,
                NoPlayBossAnim = noPlayBossAnim,
                UnskippableBossAnim = unskippableBossAnim,
            }
        end

        if type(roomArgs) ~= "table" then
            roomArgs = {
                IsExtraRoom = isExtraRoom,
                Shape = shape,
                IgnoreDoors = ignoreDoors,
                Doors = doors,
                RoomType = roomType,
                RequireRoomType = requireRoomTypeBoss
            }
        end

        local bossID = args.BossID
        if not bossID then
            bossID = StageAPI.SelectBoss(args.Bosses)
        elseif checkEncountered then
            if StageAPI.GetBossEncountered(bossID) then
                StageAPI.LogErr("Trying to generate boss room for encountered boss: " .. tostring(bossID))
                return
            end
        end

        local boss = StageAPI.GetBossData(bossID)
        if not boss then
            StageAPI.LogErr("Trying to set boss with invalid ID: " .. tostring(bossID))
            return
        end

        StageAPI.SetBossEncountered(boss.Name)
        if boss.NameTwo then
            StageAPI.SetBossEncountered(boss.NameTwo)
        end

        local newRoom = StageAPI.LevelRoom(StageAPI.Merged({RoomsList = boss.Rooms}, roomArgs))
        newRoom.PersistentData.BossID = bossID
        StageAPI.CallCallbacks("POST_BOSS_ROOM_INIT", false, newRoom, boss, bossID)

        return newRoom, boss
    end

    function StageAPI.SetCurrentBossRoom(...)
        local newRoom, boss = StageAPI.GenerateBossRoom(...)
        if not newRoom then
            StageAPI.LogErr('Could not generate room for boss: ID: ' .. bossID .. ' List Length: ' .. tostring(bosses and #bosses or 0))
            return nil, nil
        end

        StageAPI.SetCurrentRoom(newRoom)
        newRoom:Load()

        return newRoom, boss
    end

    function StageAPI.GenerateBaseLevel()
        local baseFloorInfo = StageAPI.GetBaseFloorInfo()
        local startingRoomIndex = level:GetStartingRoomIndex()
        local backwards = game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH_INIT) or game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH)
        local roomsList = level:GetRooms()
        for i = 0, roomsList.Size - 1 do
            local roomDesc = roomsList:Get(i)
            if roomDesc then
                local dimension = StageAPI.GetDimension(roomDesc)
                local newRoom
                if baseFloorInfo and baseFloorInfo.HasCustomBosses and roomDesc.Data.Type == RoomType.ROOM_BOSS and dimension == 0 and not backwards then
                    local bossID = StageAPI.SelectBoss(baseFloorInfo.Bosses, nil, roomDesc, true)
                    if bossID then
                        local bossData = StageAPI.GetBossData(bossID)
                        if bossData and not bossData.BaseGameBoss and bossData.Rooms then
                            newRoom = StageAPI.GenerateBossRoom({
                                BossID = bossID,
                                NoPlayBossAnim = true
                            }, {
                                RoomDescriptor = roomDesc
                            })

                            StageAPI.LogMinor("Switched Base Floor Boss Room, new boss is " .. bossID)
                        end
                    end
                end

                if not newRoom then
                    local hasMetadataEntity
                    StageAPI.ForAllSpawnEntries(roomDesc.Data, function(entry, spawn)
                        if StageAPI.IsMetadataEntity(entry.Type, entry.Variant) then
                            hasMetadataEntity = true
                            return true
                        end
                    end)

                    if hasMetadataEntity then
                        newRoom = StageAPI.LevelRoom{
                            FromData = roomDesc.ListIndex,
                            RoomDescriptor = roomDesc
                        }

                        StageAPI.LogMinor("Switched Base Floor Room With Metadata")
                    end
                end

                if newRoom then
                    local listIndex = roomDesc.ListIndex
                    StageAPI.SetLevelRoom(newRoom, listIndex, dimension)
                    if roomDesc.Data.Type == RoomType.ROOM_BOSS and baseFloorInfo.HasMirrorLevel and dimension == 0 then
                        StageAPI.Log("Mirroring!")
                        local mirroredRoom = newRoom:Copy(roomDesc)
                        local mirroredDesc = level:GetRoomByIdx(roomDesc.SafeGridIndex, 1)
                        StageAPI.SetLevelRoom(mirroredRoom, mirroredDesc.ListIndex, 1)
                    end
                end
            end
        end
    end

    local uniqueBossDropRoomSubtypes = {
        19, -- Gish
        20, -- Steven
        21, -- Chad
        23, -- The Fallen
        42 -- Triachnid
    }

    -- Re-randomize fixed boss drops in StageAPI boss rooms
    StageAPI.AddCallback("StageAPI", "POST_ROOM_CLEAR", 0, function()
        if room:GetType() == RoomType.ROOM_BOSS then
            local currentRoom = StageAPI.GetCurrentRoom()
            local collectibles = Isaac.FindByType(5, 100, -1)
            local spawnedFromBoss = {}
            for _, collectible in ipairs(collectibles) do
                if not collectible.SpawnerEntity and not collectible.Parent and collectible.FrameCount <= 1 then
                    spawnedFromBoss[#spawnedFromBoss + 1] = collectible
                end
            end

            if #spawnedFromBoss > 0 then
                for _, collectible in ipairs(spawnedFromBoss) do
                    local pickup = collectible:ToPickup()
                    local alreadyChanged = StageAPI.CallCallbacks("PRE_STAGEAPI_SELECT_BOSS_ITEM", true, pickup, currentRoom)
                    if not alreadyChanged then
                        local roomData = level:GetCurrentRoomDesc().Data
                        if StageAPI.IsIn(uniqueBossDropRoomSubtypes, roomData.Subtype) then
                            pickup:Morph(collectible.Type, collectible.Variant, 0, false, true, false)
                        end
                    end
                end
            end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        StageAPI.CallCallbacks("PRE_STAGEAPI_NEW_ROOM", false)

        local isNewStage, override = StageAPI.InOverriddenStage()
        local inStartingRoom = level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()
        StageAPI.CustomGridIndices = {}

        -- Only a room the player is actively in can be "Loaded"
        for _, levelRoom in ipairs(StageAPI.GetAllLevelRooms()) do
            levelRoom.Loaded = false
        end

        if (inStartingRoom and StageAPI.GetDimension() == 0 and room:IsFirstVisit()) or (isNewStage and not StageAPI.CurrentStage) then
            if inStartingRoom then
                local maintainGrids = {}
                for dimension, rooms in pairs(StageAPI.LevelRooms) do
                    maintainGrids[dimension] = {}
                    for roomId, levelRoom in pairs(rooms) do
                        if not (levelRoom and levelRoom.IsPersistentRoom) then
                            StageAPI.SetLevelRoom(nil, roomId, dimension)
                        else
                            maintainGrids[dimension][index] = true
                        end
                    end
                end

                for dimension, roomCustomGrids in pairs(StageAPI.CustomGrids) do
                    for index, grids in pairs(roomCustomGrids) do
                        if not maintainGrids[dimension] or not maintainGrids[dimension][index] then
                            roomCustomGrids[index] = nil
                        end
                    end
                end
            end

            StageAPI.CurrentStage = nil
            if isNewStage then
                if not StageAPI.NextStage then
                    StageAPI.CurrentStage = override.ReplaceWith
                else
                    StageAPI.CurrentStage = StageAPI.NextStage
                end

                if level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 and StageAPI.CurrentStage.XLStage then
                    StageAPI.CurrentStage = StageAPI.CurrentStage.XLStage
                end

                StageAPI.CurrentStage:GenerateLevel()
            else
                StageAPI.GenerateBaseLevel()
            end

            StageAPI.NextStage = nil
            if StageAPI.CurrentStage and StageAPI.CurrentStage.GetPlayingMusic then
                local musicID = StageAPI.CurrentStage:GetPlayingMusic()
                if musicID then
                    StageAPI.Music:Queue(musicID)
                end
            end
        end

        if not StageAPI.ActiveTransitionToExtraRoom then
            StageAPI.CurrentExtraRoom = nil
            StageAPI.CurrentExtraRoomName = nil
            StageAPI.InExtraRoom = false
            StageAPI.LoadedExtraRoom = false
        end

        local currentListIndex = StageAPI.GetCurrentRoomID()
        local currentRoom, justGenerated, boss = StageAPI.GetCurrentRoom(), nil, nil

        local retCurrentRoom, retJustGenerated, retBoss = StageAPI.CallCallbacks("PRE_STAGEAPI_NEW_ROOM_GENERATION", true, currentRoom, justGenerated, currentListIndex)
        local prevRoom = currentRoom
        currentRoom, justGenerated, boss = retCurrentRoom or currentRoom, retJustGenerated or justGenerated, retBoss or boss
        if prevRoom ~= currentRoom then
            StageAPI.SetCurrentRoom(currentRoom)
        end

        if StageAPI.CurrentExtraRoom then
            for i = 0, 7 do
                if room:GetDoor(i) then
                    room:RemoveDoor(i)
                end
            end

            StageAPI.CurrentExtraRoom:Load(true)
            StageAPI.LoadedExtraRoom = true
            justGenerated = StageAPI.CurrentExtraRoom.FirstLoad
        else
            StageAPI.LoadedExtraRoom = false
        end

        if not StageAPI.InExtraRoom and StageAPI.InNewStage() then
            if not currentRoom and not inStartingRoom and StageAPI.CurrentStage.GenerateRoom then
                local newRoom, newBoss = StageAPI.CurrentStage:GenerateRoom(room:GetType())
                if newRoom then
                    StageAPI.SetCurrentRoom(newRoom)
                    newRoom:Load()
                    currentRoom = newRoom
                    justGenerated = true
                end

                if newBoss then
                    boss = newBoss
                end
            end
        end

        retCurrentRoom, retJustGenerated, retBoss = StageAPI.CallCallbacks("POST_STAGEAPI_NEW_ROOM_GENERATION", true, currentRoom, justGenerated, currentListIndex, boss)
        prevRoom = currentRoom
        currentRoom, justGenerated, boss = retCurrentRoom or currentRoom, retJustGenerated or justGenerated, retBoss or boss
        if prevRoom ~= currentRoom then
            StageAPI.SetCurrentRoom(currentRoom)
        end

        if not boss and currentRoom and currentRoom.PersistentData.BossID then
            boss = StageAPI.GetBossData(currentRoom.PersistentData.BossID)
        end

        if currentRoom and not StageAPI.InExtraRoom and not justGenerated then
            currentRoom:Load()
        end

        if boss and not room:IsClear() then
            if not boss.IsMiniboss then
                StageAPI.PlayBossAnimation(boss)
            else
                StageAPI.PlayTextStreak(players[1]:GetName() .. " VS " .. boss.Name)
            end
        end

        if not justGenerated then
            local customGrids = StageAPI.GetCustomGrids()
            if #customGrids > 0 then
                for _, customGrid in ipairs(customGrids) do
                    customGrid.Data:Spawn(customGrid.Index, nil, true)
                end
            end
        end

        if StageAPI.ForcePlayerDoorSlot or StageAPI.ForcePlayerNewRoomPosition then
            local pos = StageAPI.ForcePlayerNewRoomPosition or room:GetClampedPosition(room:GetDoorSlotPosition(StageAPI.ForcePlayerDoorSlot), 16)
            for _, player in ipairs(players) do
                player.Position = pos
            end

            if StageAPI.ForcePlayerDoorSlot then
                level.EnterDoor = StageAPI.ForcePlayerDoorSlot
            end

            StageAPI.ForcePlayerDoorSlot = nil
            StageAPI.ForcePlayerNewRoomPosition = nil
        elseif currentRoom then
            local invalidEntrance
            local validDoors = {}
            for _, door in ipairs(currentRoom.Layout.Doors) do
                if door.Slot then
                    if not door.Exists and level.EnterDoor == door.Slot then
                        invalidEntrance = true
                    elseif door.Exists then
                        validDoors[#validDoors + 1] = door.Slot
                    end
                end
            end

            if invalidEntrance and #validDoors > 0 and not currentRoom.Data.PreventDoorFix then
                local changeEntrance = validDoors[StageAPI.Random(1, #validDoors)]
                level.EnterDoor = changeEntrance
                for _, player in ipairs(players) do
                    player.Position = room:GetClampedPosition(room:GetDoorSlotPosition(changeEntrance), 16)
                end
            end
        end

        StageAPI.CallCallbacks("POST_STAGEAPI_NEW_ROOM", false, justGenerated)

        if not StageAPI.InNewStage() then
            local stage = level:GetStage()
            if stage == LevelStage.STAGE2_1 or stage == LevelStage.STAGE2_2 then
                StageAPI.ChangeStageShadow("stageapi/floors/catacombs/overlays/", 5)
            elseif stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2 then
                StageAPI.ChangeStageShadow("stageapi/floors/necropolis/overlays/", 5)
            elseif stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2 then
                StageAPI.ChangeStageShadow("stageapi/floors/utero/overlays/", 5)
            end
        end

        local usingGfx
        if currentRoom and currentRoom.Data.RoomGfx then
            usingGfx = currentRoom.Data.RoomGfx
        elseif isNewStage and StageAPI.CurrentStage.RoomGfx then
            local rtype = StageAPI.GetCurrentRoomType()
            usingGfx = StageAPI.CurrentStage.RoomGfx[rtype]
        end

        local callbacks = StageAPI.GetCallbacks("PRE_CHANGE_ROOM_GFX")
        for _, callback in ipairs(callbacks) do
            local ret = callback.Function(currentRoom, usingGfx, false)
            if ret ~= nil then
                usingGfx = ret
            end
        end

        if usingGfx then
            StageAPI.ChangeRoomGfx(usingGfx)
            if currentRoom then
                currentRoom.Data.RoomGfx = usingGfx
            end
        else
            if room:GetType() ~= RoomType.ROOM_DUNGEON and room:GetBackdropType() ~= 16 then
                if backdropType == BackdropType.UTERO then
                    StageAPI.ChangeShading("_utero")
                else
                    StageAPI.ChangeShading("_default")
                end
            end
        end

        StageAPI.CallCallbacks("POST_CHANGE_ROOM_GFX", false, currentRoom, usingGfx, false)

        StageAPI.LastBackdropType = room:GetBackdropType()

        StageAPI.ActiveTransitionFromExtraRoom = false
        StageAPI.ActiveTransitionToExtraRoom = false
        StageAPI.RoomRendered = false
    end)

    function StageAPI.GetGridPosition(index, width)
        local x, y = StageAPI.GridToVector(i, width)
        y = y + 4
        x = x + 2
        return x * 40, y * 40
    end

    mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, params)
        if (cmd == "cstage" or cmd == "customstage") and StageAPI.CustomStages[params] then
            if StageAPI.CustomStages[params] then
                StageAPI.GotoCustomStage(StageAPI.CustomStages[params])
            else
                Isaac.ConsoleOutput("No CustomStage " .. params)
            end
        elseif (cmd == "nstage" or cmd == "nextstage") and StageAPI.CurrentStage and StageAPI.CurrentStage.NextStage then
            StageAPI.GotoCustomStage(StageAPI.CurrentStage.NextStage)
        elseif cmd == "reload" then
            StageAPI.LoadSaveString(StageAPI.GetSaveString())
        elseif cmd == "printsave" then
            Isaac.DebugString(StageAPI.GetSaveString())
        elseif cmd == "extraroom" then
            if StageAPI.GetExtraRoom(params) then
                StageAPI.TransitionToExtraRoom(params)
            end
        elseif cmd == "extraroomexit" then
            StageAPI.TransitionFromExtraRoom(StageAPI.LastNonExtraRoom)
        elseif cmd == "regroom" then -- Load a registered room
            if StageAPI.Layouts[params] then
                local testRoom = StageAPI.LevelRoom{
                    LayoutName = params,
                    Shape = StageAPI.Layouts[params].Shape,
                    RoomType = StageAPI.Layouts[params].Type,
                }

                StageAPI.SetExtraRoom("StageAPITest", testRoom)
                local doors = {}
                for _, door in ipairs(StageAPI.Layouts[params].Doors) do
                    if door.Exists then
                        doors[#doors + 1] = door.Slot
                    end
                end

                StageAPI.TransitionToExtraRoom("StageAPITest", doors[StageAPI.Random(1, #doors)])
            else
                Isaac.ConsoleOutput(params .. " is not a registered room.\n")
            end
        elseif cmd == "croom" then
            local paramTable = {}
            for word in params:gmatch("%S+") do paramTable[#paramTable + 1] = word end
            local name = tonumber(paramTable[1]) or paramTable[1]
            local listName = paramTable[2]
            if name then
                local list
                if listName then
                    listName = string.gsub(listName, "_", " ")
                    if StageAPI.RoomsLists[listName] then
                        list = StageAPI.RoomsLists[listName]
                    else
                        Isaac.ConsoleOutput("Room List name invalid.")
                        return
                    end
                elseif StageAPI.CurrentStage and StageAPI.CurrentStage.Rooms and StageAPI.CurrentStage.Rooms[RoomType.ROOM_DEFAULT] then
                    list = StageAPI.CurrentStage.Rooms[RoomType.ROOM_DEFAULT]
                else
                    Isaac.ConsoleOutput("Must supply Room List name or be in a custom stage with rooms.")
                    return
                end

                if type(name) == "string" then
                    name = string.gsub(name, "_", " ")
                end

                local selectedLayout
                for _, room in ipairs(list.All) do
                    if room.Name == name or room.Variant == name then
                        selectedLayout = room
                        break
                    end
                end

                if selectedLayout then
                    StageAPI.RegisterLayout("StageAPITest", selectedLayout)
                    local testRoom = StageAPI.LevelRoom{
                        LayoutName = "StageAPITest",
                        Shape = selectedLayout.Shape,
                        RoomType = selectedLayout.Type
                    }
                    StageAPI.SetExtraRoom("StageAPITest", testRoom)
                    local doors = {}
                    for _, door in ipairs(selectedLayout.Doors) do
                        if door.Exists then
                            doors[#doors + 1] = door.Slot
                        end
                    end

                    StageAPI.TransitionToExtraRoom("StageAPITest", doors[StageAPI.Random(1, #doors)])
                else
                    Isaac.ConsoleOutput("Room with ID or name " .. tostring(name) .. " does not exist.")
                end
            else
                Isaac.ConsoleOutput("A room ID or name is required.")
            end
        elseif cmd == "creseed" then
            if StageAPI.CurrentStage then
                StageAPI.GotoCustomStage(StageAPI.CurrentStage)
            end
        elseif cmd == "roomnames" then
            if StageAPI.RoomNamesEnabled then
                StageAPI.RoomNamesEnabled = false
            else
                StageAPI.RoomNamesEnabled = 1
            end
        elseif cmd == "trimroomnames" then
            if StageAPI.RoomNamesEnabled then
                StageAPI.RoomNamesEnabled = false
            else
                StageAPI.RoomNamesEnabled = 2
            end
        elseif cmd == "modversion" then
            for name, modData in pairs(StageAPI.LoadedMods) do
                if modData.Version then
                    Isaac.ConsoleOutput(name .. " " .. modData.Prefix .. modData.Version .. "\n")
                end
            end
        elseif cmd == "roomtest" then
            local roomsList = level:GetRooms()
            for i = 0, roomsList.Size do
                local roomDesc = roomsList:Get(i)
                if roomDesc and roomDesc.Data.Type == RoomType.ROOM_DEFAULT then
                    game:ChangeRoom(roomDesc.SafeGridIndex)
                end
            end
        elseif cmd == "clearroom" then
            StageAPI.ClearRoomLayout(false, true, true, true)
        elseif cmd == "superclearroom" then
            StageAPI.ClearRoomLayout(false, true, true, true, nil, true, true)
        elseif cmd == "crashit" then
            game:ShowHallucination(0, 0)
        elseif cmd == "commandglobals" then
            if StageAPI.GlobalCommandMode then
                Isaac.ConsoleOutput("Disabled StageAPI global command mode")
                _G.slog = nil
                _G.game = nil
                _G.room = nil
                _G.desc = nil
                _G.apiroom = nil
                _G.level = nil
                _G.player = nil
                StageAPI.GlobalCommandMode = nil
            else
                Isaac.ConsoleOutput("Enabled StageAPI global command mode\nslog: Prints any number of args, parses some userdata\ngame, room, level: Correspond to respective objects\nplayer: Corresponds to player 0\ndesc: Current room descriptor, mutable\napiroom: Current StageAPI room, if applicable\nFor use with the lua command!")
                StageAPI.GlobalCommandMode = true
            end
        end
    end)

    local gridBlacklist = {
        [EntityType.ENTITY_STONEHEAD] = true,
        [EntityType.ENTITY_CONSTANT_STONE_SHOOTER] = true,
        [EntityType.ENTITY_STONE_EYE] = true,
        [EntityType.ENTITY_BRIMSTONE_HEAD] = true,
        [EntityType.ENTITY_GAPING_MAW] = true,
        [EntityType.ENTITY_BROKEN_GAPING_MAW] = true
    }

    mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, function(_, t, v, s, index, seed)
        if StageAPI.ShouldOverrideRoom() and (t >= 1000 or gridBlacklist[t] or StageAPI.IsMetadataEntity(t, v)) and not StageAPI.ActiveTransitionToExtraRoom then
            local shouldReturn
            if room:IsFirstVisit() or StageAPI.IsMetadataEntity(t, v) then
                shouldReturn = true
            else
                local currentListIndex = StageAPI.GetCurrentRoomID()
                local roomGrids = StageAPI.GetTableIndexedByDimension(StageAPI.RoomGrids, true)
                if roomGrids[currentListIndex] and not roomGrids[currentListIndex][index] then
                    shouldReturn = true
                end
            end

            if shouldReturn then
                return {
                    999,
                    StageAPI.E.DeleteMeEffect.V,
                    0
                }
            end
        end
    end)

    StageAPI.LoadedMods = {}
    StageAPI.RunWhenLoaded = {}
    function StageAPI.MarkLoaded(name, version, prntVersionOnNewGame, prntVersion, prefix)
        StageAPI.LoadedMods[name] = {Name = name, Version = version, PrintVersion = prntVersionOnNewGame, Prefix = prefix or "v"}
        if StageAPI.RunWhenLoaded[name] then
            for _, fn in ipairs(StageAPI.RunWhenLoaded[name]) do
                fn()
            end
        end

        if prntVersion then
            prefix = prefix or "v"
            StageAPI.Log(name .. " Loaded " .. prefix .. version)
        end
    end

    local versionPrintTimer = 0
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
        versionPrintTimer = 60
    end)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if versionPrintTimer > 0 then
            versionPrintTimer = versionPrintTimer - 1
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if versionPrintTimer > 0 then
            local bottomRight = StageAPI.GetScreenBottomRight()
            local renderY = bottomRight.Y - 12
            local renderX = 12
            local isFirst = true
            for name, modData in pairs(StageAPI.LoadedMods) do
                if modData.PrintVersion then
                    local text = name .. " " .. modData.Prefix .. modData.Version
                    if isFirst then
                        isFirst = false
                    else
                        text = ", " .. text
                    end

                    Isaac.RenderScaledText(text, renderX, renderY, 0.5, 0.5, 1, 1, 1, (versionPrintTimer / 60) * 0.5)
                    renderX = renderX + Isaac.GetTextWidth(text) * 0.5
                end
            end
        end
    end)

    function StageAPI.RunWhenMarkedLoaded(name, fn)
        if StageAPI.LoadedMods[name] then
            fn()
        else
            if not StageAPI.RunWhenLoaded[name] then
                StageAPI.RunWhenLoaded[name] = {}
            end

            StageAPI.RunWhenLoaded[name][#StageAPI.RunWhenLoaded[name] + 1] = fn
        end
    end
end

StageAPI.LogMinor("Loading Save System")
do
    StageAPI.json = require("json")
    function StageAPI.GetSaveString()
        local levelSaveData = {}
        for dimension, rooms in pairs(StageAPI.RoomGrids) do
            local strDimension = tostring(dimension)
            if not levelSaveData[strDimension] then
                levelSaveData[strDimension] = {}
            end

            for index, roomGrids in pairs(StageAPI.RoomGrids) do
                local strindex = tostring(index)
                if not levelSaveData[strDimension][strindex] then
                    levelSaveData[strDimension][strindex] = {}
                end

                local roomDat = levelSaveData[strDimension][strindex]
                for grindex, exists in pairs(roomGrids) do
                    if exists then
                        if not roomDat.Grids then
                            roomDat.Grids = {}
                        end

                        roomDat.Grids[#roomDat.Grids + 1] = grindex
                    end
                end
            end
        end

        for dimension, rooms in pairs(StageAPI.CustomGrids) do
            local strDimension = tostring(dimension)
            if not levelSaveData[strDimension] then
                levelSaveData[strDimension] = {}
            end

            for lindex, customGrids in pairs(StageAPI.CustomGrids) do
                local strindex = tostring(lindex)
                if not levelSaveData[strDimension][strindex] then
                    levelSaveData[strDimension][strindex] = {}
                end

                local roomDat = levelSaveData[strDimension][strindex]
                for name, indices in pairs(customGrids) do
                    for index, value in pairs(indices) do
                        if not roomDat.CustomGrids then
                            roomDat.CustomGrids = {}
                        end

                        if not roomDat.CustomGrids[name] then
                            roomDat.CustomGrids[name] = {}
                        end

                        if value == true then
                            roomDat.CustomGrids[name][#roomDat.CustomGrids[name] + 1] = index
                        else
                            roomDat.CustomGrids[name][#roomDat.CustomGrids[name] + 1] = {index, value}
                        end
                    end
                end
            end
        end

        for dimension, rooms in pairs(StageAPI.LevelRooms) do
            local strDimension = tostring(dimension)
            if not levelSaveData[strDimension] then
                levelSaveData[strDimension] = {}
            end

            for index, customRoom in pairs(rooms) do
                local strindex = tostring(index)
                if not levelSaveData[strDimension][strindex] then
                    levelSaveData[strDimension][strindex] = {}
                end

                levelSaveData[strDimension][strindex].Room = customRoom:GetSaveData()
            end
        end

        local stage = StageAPI.CurrentStage
        if stage then
            stage = stage.Name
        end

        local encounteredBosses = {}
        for boss, encountered in pairs(StageAPI.EncounteredBosses) do
            if encountered then
                encounteredBosses[#encounteredBosses + 1] = boss
            end
        end

        return StageAPI.json.encode({
            LevelInfo = levelSaveData,
            Stage = stage,
            ExtraRoomName = StageAPI.CurrentExtraRoomName,
            EncounteredBosses = encounteredBosses
        })
    end

    function StageAPI.LoadSaveString(str)
        StageAPI.CallCallbacks("PRE_STAGEAPI_LOAD_SAVE", false)
        local retLevelRooms = {}
        local retRoomGrids = {}
        local retCustomGrids = {}
        local retEncounteredBosses = {}
        local decoded = StageAPI.json.decode(str)

        StageAPI.CurrentStage = nil
        StageAPI.CurrentExtraRoom = nil
        StageAPI.CurrentExtraRoomName = decoded.ExtraRoomName
        if decoded.Stage then
            StageAPI.CurrentStage = StageAPI.CustomStages[decoded.Stage]
        else
            local inOverriddenStage, override = StageAPI.InOverriddenStage()
            if inOverriddenStage then
                StageAPI.CurrentStage = override
            end
        end

        StageAPI.EncounteredBosses = {}

        if decoded.EncounteredBosses then
            for _, boss in ipairs(decoded.EncounteredBosses) do
                StageAPI.EncounteredBosses[boss] = true
            end
        end

        StageAPI.LevelRooms = {}
        for strDimension, rooms in pairs(decoded.LevelInfo) do
            local dimension = tonumber(strDimension)
            retLevelRooms[dimension] = {}
            retRoomGrids[dimension] = {}
            retCustomGrids[dimension] = {}

            for strindex, roomSaveData in pairs(rooms) do
                local lindex = tonumber(strindex) or strindex
                if roomSaveData.Grids then
                    retRoomGrids[dimension][lindex] = {}
                    for _, grindex in ipairs(roomSaveData.Grids) do
                        retRoomGrids[dimension][lindex][grindex] = true
                    end
                end

                if roomSaveData.CustomGrids then
                    retCustomGrids[dimension][lindex] = {}
                    for name, indices in pairs(roomSaveData.CustomGrids) do
                        for _, index in ipairs(indices) do
                            if not retCustomGrids[dimension][lindex][name] then
                                retCustomGrids[dimension][lindex][name] = {}
                            end

                            if type(index) == "table" then
                                retCustomGrids[dimension][lindex][name][index[1]] = index[2]
                            else
                                retCustomGrids[dimension][lindex][name][index] = true
                            end
                        end
                    end
                end

                if roomSaveData.Room then
                    local customRoom = StageAPI.LevelRoom{FromSave = roomSaveData.Room}
                    StageAPI.SetLevelRoom(customRoom, lindex, dimension)
                end
            end
        end

        if StageAPI.CurrentExtraRoomName then
            StageAPI.CurrentExtraRoom = retLevelRooms[-2][StageAPI.CurrentExtraRoomName]
            StageAPI.InExtraRoom = true
            StageAPI.LoadingExtraRoomFromSave = true
        end

        StageAPI.RoomGrids = retRoomGrids
        StageAPI.CustomGrids = retCustomGrids
        StageAPI.CallCallbacks("POST_STAGEAPI_LOAD_SAVE", false)
    end
end

StageAPI.LogMinor("Loading Miscellaneous Functions")
do -- Misc helpful functions
    -- Takes whether or not there is a pit in each adjacent space, returns frame to set pit sprite to.
    function StageAPI.GetPitFrame(L, R, U, D, UL, DL, UR, DR, hasExtraFrames)
        -- Words were shortened to make writing code simpler.
        local F = 0 -- Sprite frame to set

        -- First bitwise frames (works for all combinations of just left up right and down)
        if L  then F = F | 1 end
        if U  then F = F | 2 end
        if R  then F = F | 4 end
        if D  then F = F | 8 end

        -- Then a bunch of other combinations
        if U and L and not UL and not R and not D then          F = 17 end
        if U and R and not UR and not L and not D then          F = 18 end
        if L and D and not DL and not U and not R then          F = 19 end
        if R and D and not DR and not L and not U then          F = 20 end
        if L and U and R and D and not UL then                  F = 21 end
        if L and U and R and D and not UR then                  F = 22 end
        if U and R and D and not L and not UR then              F = 25 end
        if L and U and D and not R and not UL then              F = 26 end
        if hasExtraFrames then
            if U and L and D and UL and not DL then                                 F = 35 end
            if U and R and D and UR and not DR then                                 F = 36 end
        end
        if L and U and R and D and not DL and not DR then       F = 24 end
        if L and U and R and D and not UR and not UL then       F = 23 end
        if L and U and R and UL and not UR and not D then       F = 27 end
        if L and U and R and UR and not UL and not D then       F = 28 end
        if L and U and R and not D and not UR and not UL then   F = 29 end
        if L and R and D and DL and not U and not DR then       F = 30 end
        if L and R and D and DR and not U and not DL then       F = 31 end
        if L and R and D and not U and not DL and not DR then   F = 32 end

        if hasExtraFrames then
            if U and R and D and not L and not UR and not DR then                   F = 33 end
            if U and L and D and not R and not UL and not DL then                   F = 34 end
            if U and R and D and L and UL and UR and DL and not DR then             F = 37 end
            if U and R and D and L and UL and UR and DR and not DL then             F = 38 end
            if U and R and D and L and not UL and not UR and not DR and not DL then F = 39 end
            if U and R and D and L and DL and DR and not UL and not UR then F = 40 end
            if U and R and D and L and DL and UR and not UL and not DR then F = 41 end
            if U and R and D and L and UL and DR and not DL and not UR then F = 42 end
            if U and R and D and L and UL and not DL and not UR and not DR then F = 43 end
            if U and R and D and L and UR and not UL and not DL and not DR then F = 44 end
            if U and R and D and L and DL and not UL and not UR and not DR then F = 45 end
            if U and R and D and L and DR and not UL and not UR and not DL then F = 46 end
            if U and R and D and L and DL and DR and not UL and not UR then F = 47 end
            if U and R and D and L and DL and UL and not UR and not DR then F = 48 end
            if U and R and D and L and DR and UR and not UL and not DL then F = 49 end
        end

        return F
    end

    local AdjacentAdjustments = {
        {X = -1, Y = 0},
        {X = 1, Y = 0},
        {X = 0, Y = -1},
        {X = 0, Y = 1},
        {X = -1, Y = -1},
        {X = -1, Y = 1},
        {X = 1, Y = -1},
        {X = 1, Y = 1}
    }

    function StageAPI.GetPitFramesFromIndices(indices, width, height, hasExtraFrames)
        local frames = {}
        for index, _ in pairs(indices) do
            local x, y = StageAPI.GridToVector(index, width)
            local adjIndices = {}
            for _, adjust in ipairs(AdjacentAdjustments) do
                local nX, nY = x + adjust.X, y + adjust.Y
                if (nX >= 0 and nX <= width) and (nY >= 0 and nY <= height) then
                    local backToGrid = StageAPI.VectorToGrid(nX, nY, width)
                    if indices[backToGrid] then
                        adjIndices[#adjIndices + 1] = true
                    else
                        adjIndices[#adjIndices + 1] = false
                    end
                else
                    adjIndices[#adjIndices + 1] = false
                end
            end
            adjIndices[#adjIndices + 1] = hasExtraFrames
            frames[tostring(index)] = StageAPI.GetPitFrame(table.unpack(adjIndices))
        end

        return frames
    end

    function StageAPI.GetIndicesWithEntity(t, v, s, entities)
        local indicesWithEntity = {}
        for index, entityList in pairs(entities) do
            for _, entityInfo in ipairs(entityList) do
                local entityData = entityInfo.Data
                if not t or entityData.Type == t
                and not v or entityData.Variant == v
                and not s or entityData.SubType == s then
                    indicesWithEntity[index] = true
                end
            end
        end

        return indicesWithEntity
    end

    function StageAPI.GetPitFramesForLayoutEntities(t, v, s, entities, width, height, hasExtraFrames)
        width = width or room:GetGridWidth()
        height = height or room:GetGridHeight()
        local indicesWithEntity = StageAPI.GetIndicesWithEntity(t, v, s, entities)

        return StageAPI.GetPitFramesFromIndices(indicesWithEntity, width, height, hasExtraFrames)
    end
end

StageAPI.LogMinor("Loading Editor Features")
do
    local d12Used = false
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
        d12Used = true
    end, CollectibleType.COLLECTIBLE_D12)

    StageAPI.AddCallback("StageAPI", "POST_PARSE_METADATA", 0, function(roomMetadata, outEntities, outGrids, rng)
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
                    roomMetadata.BlockedEntities[entityBlocker.Index] = blocked
                end

                if #outEntities[entityBlocker.Index] == 0 then
                    outEntities[entityBlocker.Index] = nil
                end
            end
        end
    end)

    StageAPI.AddCallback("StageAPI", "POST_ROOM_INIT", 0, function(currentRoom, firstLoad)
        if not currentRoom.PersistentData.BossID then
            local bossIdentifiers = currentRoom.Metadata:Search({Name = "BossIdentifier"})
            for _, bossIdentifier in ipairs(bossIdentifiers) do
                local checkEnts = {}
                if currentRoom.Metadata.BlockedEntities[bossIdentifier.Index] then
                    for _, ent in ipairs(currentRoom.Metadata.BlockedEntities[bossIdentifier.Index]) do
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

    StageAPI.AddCallback("StageAPI", "POST_ROOM_LOAD", 0, function(currentRoom, firstLoad)
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
                    StageAPI.ForcePlayerNewRoomPosition = room:GetGridPosition(loadFeature.Index)
                end
            elseif loadFeature.Name == "EnteredFromTrigger" then
                local checkPos = StageAPI.ForcePlayerNewRoomPosition
                if not checkPos and StageAPI.ForcePlayerDoorSlot then
                    checkPos = room:GetClampedPosition(room:GetDoorSlotPosition(StageAPI.ForcePlayerDoorSlot), 16)
                end

                checkPos = checkPos or players[1].Position

                local triggerPos = room:GetGridPosition(loadFeature.Index)
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
                            local spawnedEntities = currentRoom.Metadata.BlockedEntities[metaEnt.Index]
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

    StageAPI.AddCallback("StageAPI", "POST_SPAWN_ENTITY", 0, function(ent, entityInfo, entityList, index)
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom and ent:ToPickup() then
            local pickup = ent:ToPickup()
            local pickupModifiers = currentRoom.Metadata:Search({Tag = "StageAPIPickupEditorFeature", Index = index})
            for _, metaEntity in ipairs(pickupModifiers) do
                if metaEntity.Name == "ShopItem" then
                    local price = metaEntity.BitValues.Price
                    if price == 0 then
                        price = PickupPrice.PRICE_FREE
                    end

                    pickup.AutoUpdatePrice = false
                    pickup.Price = price
                elseif metaEntity.Name == "OptionsPickup" then
                    local idx = metaEntity.BitValues.OptionsIndex
                    pickup.OptionsPickupIndex = idx
                end
            end
        end
    end)

    StageAPI.AddCallback("StageAPI", "POST_SPAWN_CUSTOM_GRID", 0, function(index, force, respawning, grid, persistData)
        local button = StageAPI.SpawnFloorEffect(room:GetGridPosition(index), Vector.Zero, nil, "gfx/grid/grid_pressureplate.anm2", false, StageAPI.E.Button.V)
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
            for _, player in ipairs(players) do
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

        local width = room:GetGridWidth()
        local metadataEntities = currentRoom.Metadata:Search({Tag = "StageAPIEditorFeature"})
        for _, metadataEntity in ipairs(metadataEntities) do
            local trigger
            local index = metadataEntity.Index
            if metadataEntity.Name == "RoomClearTrigger" then
                if currentRoom.JustCleared then
                    trigger = true
                end
            elseif metadataEntity.Name == "BridgeFailsafe" then
                if room:GetGridCollision(index) ~= 0 then
                    if d12Used then
                        local grid = room:GetGridEntity(index)
                        grid:ToPit():MakeBridge(grid)
                    else
                        local adjacent = {index - 1, index + 1, index - width, index + width}
                        for _, index2 in ipairs(adjacent) do
                            local grid = room:GetGridEntity(index2)
                            if grid and room:GetGridCollision(index2) == 0 and (StageAPI.RockTypes[grid.Desc.Type] or grid.Desc.Type == GridEntityType.GRID_POOP) then
                                local pit = room:GetGridEntity(index)
                                pit:ToPit():MakeBridge(pit)
                                break
                            end
                        end
                    end
                end
            elseif metadataEntity.Name == "GridDestroyer" then
                if metadataEntity.Triggered then
                    local grid = room:GetGridEntity(index)
                    if grid and room:GetGridCollision(index) ~= 0 then
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

                if room:GetGridCollision(index) ~= 0 then
                    local checking = room:GetGridEntity(index)
                    local destroySelf = metadataEntity.Triggered
                    if not destroySelf then
                        local adjacent = {index - 1, index + 1, index - width, index + width}
                        local adjDetonators = currentRoom.Metadata:Search({Indices = adjacent, Name = "Detonator"}, metadataEntities)
                        for _, detonator in ipairs(adjDetonators) do
                            if not detonator.RecentlyTriggered and room:GetGridCollision(detonator.Index) == 0 then
                                local grid = room:GetGridEntity(detonator.Index)
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
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, room:GetGridPosition(index), zeroVector, nil)
                        metadataEntity.RecentlyTriggered = 4
                    end

                    metadataEntity.Triggered = nil
                end
            elseif metadataEntity.Name == "DetonatorTrigger" and not metadataEntity.Triggered then
                if room:GetGridCollision(index) == 0 then
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
                        local blockedEntities = currentRoom.Metadata.BlockedEntities[index]
                        if blockedEntities and #blockedEntities > 0 then
                            local spawnAll = metadataEntity.BitValues.SpawnAll == 1
                            local toSpawn = {}
                            if spawnAll then
                                toSpawn = blockedEntities
                            else
                                toSpawn[#toSpawn + 1] = blockedEntities[StageAPI.Random(1, #blockedEntities)]

                            end

                            for _, spawn in ipairs(toSpawn) do
                                local ent = Isaac.Spawn(spawn.Type or 20, spawn.Variant or 0, spawn.SubType or 0, room:GetGridPosition(index), zeroVector, nil)
                                StageAPI.CallCallbacks("POST_SPAWN_ENTITY", false, ent, {Data = spawn}, {}, index)
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
end

do -- Challenge Rooms
    --[[
    Custom Challenge Waves

    CustomStage:SetChallengeWaves(RoomsList, BossChallengeRoomsList)

    Challenge waves must be rooms with only entities, and no metadata entities, to properly merge into the existing room.

    If the challenge room has a non-zero SubType, only challenge waves with a SubType that matches or is zero will be selected.
    This allows the editor to design waves that fit each room layout, or some with SubType 0 that fit all.
    If a challenge room layout can fit any one set of waves, just use SubType 0.
    ]]

    StageAPI.Challenge = {
        WaveChanged = false,
        WaveSpawnFrame = nil,
        WaveSubtype = nil
    }
    mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
        if room:GetType() == RoomType.ROOM_CHALLENGE and not StageAPI.Challenge.WaveSpawnFrame
        and room:IsAmbushActive() and not room:IsAmbushDone() then
            if npc.CanShutDoors
            and not (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or npc:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) or npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
                local preventCounting
                for _, entity in ipairs(Isaac.FindInRadius(StageAPI.ZeroVector, 9999, EntityPartition.ENEMY)) do
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
                    npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    npc.Visible = false
                    for _, effect in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, false, false)) do
                        if effect.Position.X == npc.Position.X and effect.Position.Y == npc.Position.Y then
                            effect:Remove()
                        end
                    end

                    npc:Remove()
                end
            end
        end
    end)

    StageAPI.ChallengeWaveRNG = RNG()
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        for k, v in pairs(StageAPI.Challenge) do
            StageAPI.Challenge[k] = nil
        end
        StageAPI.ChallengeWaveRNG:SetSeed(room:GetSpawnSeed(), 0)

        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom and currentRoom.Data.ChallengeWaveIDs then
            currentRoom.Data.ChallengeWaveIDs = nil
        end
    end)

    -- prevent waves of the wrong subtype from appearing
    StageAPI.AddCallback("StageAPI", "POST_CHECK_VALID_ROOM", 0, function(layout)
        if StageAPI.Challenge.WaveSubtype then
            if not (layout.SubType == 0 or layout.SubType == StageAPI.Challenge.WaveSubtype) then
                return 0
            end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if StageAPI.Challenge.WaveSpawnFrame and game:GetFrameCount() > StageAPI.Challenge.WaveSpawnFrame then
            StageAPI.Challenge.WaveSpawnFrame = nil
        end

        if StageAPI.Challenge.WaveChanged then
            if room:GetType() ~= RoomType.ROOM_CHALLENGE then
                StageAPI.Challenge.WaveChanged = false
                StageAPI.Challenge.WaveSubtype = nil
                return
            end

            if StageAPI.CurrentStage and StageAPI.CurrentStage.ChallengeWaves then
                StageAPI.Challenge.WaveSpawnFrame = game:GetFrameCount()
                local currentRoom = StageAPI.GetCurrentRoom()

                local challengeWaveIDs
                if currentRoom then
                    if not StageAPI.Challenge.WaveSubtype and currentRoom.Layout.SubType ~= 0 then
                        StageAPI.Challenge.WaveSubtype = currentRoom.Layout.SubType
                    end

                    if not currentRoom.Data.ChallengeWaveIDs then
                        currentRoom.Data.ChallengeWaveIDs = {}
                    end

                    challengeWaveIDs = currentRoom.Data.ChallengeWaveIDs
                end

                local seed = StageAPI.ChallengeWaveRNG:Next()

                local useWaves = StageAPI.CurrentStage.ChallengeWaves.Normal
                if level:HasBossChallenge() then
                    useWaves = StageAPI.CurrentStage.ChallengeWaves.Boss
                end

                local wave = StageAPI.ChooseRoomLayout(useWaves, seed, room:GetRoomShape(), room:GetType(), false, false, nil, challengeWaveIDs)
                if currentRoom then
                    table.insert(currentRoom.Data.ChallengeWaveIDs, wave.StageAPIID)

                    if not StageAPI.Challenge.WaveSubtype
                    and currentRoom.Layout.SubType == 0 and wave.SubType ~= 0 then
                        StageAPI.Challenge.WaveSubtype = wave.SubType
                    end
                end

                local spawnEntities = StageAPI.ObtainSpawnObjects(wave, seed)
                StageAPI.SpawningChallengeEnemies = true
                StageAPI.LoadRoomLayout(nil, {spawnEntities}, false, true, false, true, nil, nil, nil, true)
                StageAPI.SpawningChallengeEnemies = false
            end

            StageAPI.CallCallbacks("CHALLENGE_WAVE_CHANGED")

            StageAPI.Challenge.WaveChanged = false
        end
    end)
end

-- Load base game reimplementation data
include("data")

StageAPI.LogMinor("Loading BR Compatibility")
do -- BR Compatibility
    StageAPI.InTestMode = false
    StageAPI.OverrideTestRoom = false -- toggle this value in console to force enable stageapi override

    local status, brTestRooms = pcall(require, 'basementrenovator.roomTest')
    if not status then
        StageAPI.Log("Could not load BR compatibility file; (basementrenovator/roomTest.lua) this will disable testing StageAPI rooms. No other features will be affected. Check log.txt for full error. To suppress this message, delete the compat file and replace it with a renamed copy of blankRoomTest.lua.")
        Isaac.DebugString('Error loading BR compatibility file: ' .. tostring(brTestRooms))
    elseif brTestRooms then
        local testList = StageAPI.RoomsList("BRTest", brTestRooms)
        for i, testLayout in ipairs(testList.All) do
            StageAPI.RegisterLayout("BRTest-" .. i, testLayout)

            if not StageAPI.OverrideTestRoom then -- force stageapi override for rooms containing metadata entities
                for _, entity in ipairs(testLayout.Entities) do
                    if StageAPI.IsMetadataEntity(entity.Type, entity.Variant) then
                        StageAPI.OverrideTestRoom = true
                        break
                    end
                end
            end
        end

        BasementRenovator = BasementRenovator or { subscribers = {} }
        BasementRenovator.subscribers['StageAPI'] = {
            PostTestInit = function(testData)
                local test = testData.Rooms and testData.Rooms[1] or testData
                local testLayout = brTestRooms[1]

                if test.Type    ~= testLayout.TYPE
                or test.Variant ~= testLayout.VARIANT
                or test.Subtype ~= testLayout.SUBTYPE
                or test.Name    ~= testLayout.NAME
                or (testData.Rooms and #testData.Rooms ~= #brTestRooms) then
                    StageAPI.LogErr("basementrenovator/roomTest.lua did not have values matching the BR test! Make sure your hooks are set up properly")
                    StageAPI.BadTestFile = true
                    return
                end

                StageAPI.InTestMode = true
                StageAPI.InTestRoom = function() return BasementRenovator.InTestRoom() end
                StageAPI.Log("Basement Renovator test mode")
            end,
            TestStage = function(test)
                if StageAPI.BadTestFile or not BasementRenovator.TestRoomData then return end
                -- TestStage fires in post_curse_eval,
                -- before StageAPI's normal stage handling code
                if test.IsModStage then
                    StageAPI.NextStage = StageAPI.CustomStages[test.StageName]
                    StageAPI.OverrideTestRoom = true -- must be turned on for custom stages
                end
            end,
            TestRoomEntitySpawn = function()
                if StageAPI.BadTestFile then return end

                if not StageAPI.OverrideTestRoom then return end

                -- makes sure placeholder/meta entities can't spawn
                return { 999, StageAPI.E.DeleteMeEffect.V, 0 }
            end
        }

        local function GetBRRoom(foo)
            if StageAPI.BadTestFile or not BasementRenovator.TestRoomData then return end

            if not StageAPI.OverrideTestRoom then return end

            if BasementRenovator.InTestStage() and room:IsFirstVisit() then
                local brRoom = BasementRenovator.InTestRoom()
                if brRoom then
                    return brRoom
                end
            end
        end

        StageAPI.AddCallback("StageAPI", "PRE_STAGEAPI_NEW_ROOM_GENERATION", 0, function()
            local brRoom = GetBRRoom()
            if brRoom then
                local testRoom = StageAPI.LevelRoom("BRTest-" .. (brRoom.Index or 1), nil, room:GetSpawnSeed(), brRoom.Shape, brRoom.Type, nil, nil, nil, nil, nil, StageAPI.GetCurrentRoomID())
                return testRoom
            end
        end)

        StageAPI.AddCallback("StageAPI", "POST_STAGEAPI_NEW_ROOM", 0, function()
            if GetBRRoom() then
                if BasementRenovator.RenderDoorSlots then
                    BasementRenovator.RenderDoorSlots()
                end
            end
        end)
    end
end

do -- Mod Compatibility
    local addedChangelogs
    local latestChangelog
    local function TryAddChangelog(ver, log)
        if not latestChangelog then
            latestChangelog = ver
        end

        if DeadSeaScrollsMenu and DeadSeaScrollsMenu.AddChangelog then
            log = string.gsub(log, "%*%*", "{FSIZE2}")
            if latestChangelog == ver then
                Isaac.DebugString(log)
            end

            DeadSeaScrollsMenu.AddChangelog("StageAPI", ver, log, false, latestChangelog == ver, false)
        elseif REVEL and REVEL.AddChangelog then
            REVEL.AddChangelog("StageAPI " .. ver, log)
        end
    end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
        if addedChangelogs then
            return
        end

        if (DeadSeaScrollsMenu and DeadSeaScrollsMenu.AddChangelog) or (REVEL and REVEL.AddChangelog and not REVEL.AddedStageAPIChangelogs) then
            addedChangelogs = true

            if not (DeadSeaScrollsMenu and DeadSeaScrollsMenu.AddChangelog) then
                REVEL.AddedStageAPIChangelogs = true
            end

            TryAddChangelog("v1.92 - 93", [[- Fixed bridges not
functioning in Catacombs,
Necropolis, and Utero

- Fixed Downpour, Mines,
and Mausoleum trapdoors
being overridden in
custom stages

- Updated StageAPI Utero
backdrop to match new version
in Repentance

- StageAPI now enables sprite
suffix replacements for
all base game floors

- StageAPI now loads before
most or all other mods

- Updated StageAPI.FloorInfo for
Repentance stages

- Fixed ShouldOverrideRoom returning
true for default room types
on custom stages without
any default rooms defined

- Fix starting room controls for
Repentance, although they don't
have keys due to the inability
to tell what the game keybinds
are set to
]])

            TryAddChangelog("v1.89 - 91", [[- Updated StageAPI to
function with Repentance.
Note that it is still
a work in progress, and
may have some bugs. Please
report any issues at
StageAPI's github page,
linked in the steam
description.

- StageAPI no longer
overrides the D7

- StageAPI now supports
Dead Sea Scrolls
changelogs

- Custom grids can now
disable the usual grid
sprite replacement that
custom stages do, via
a new argument to CustomGrid()

- Fixed an issue with
overridden RoomGfx not
using the correct GridGfx
on custom stages

- Fixed the base game's
black market crawlspace
leading to an error room

- StageAPI no longer
overrides music.xml, which
should allow for considerably
more compatibility with
music replacing mods
]])

            TryAddChangelog("v1.86 - 88", [[- Added functions
AddObjectToRoomLayout,
GenerateRoomLayoutFromData,
IsMetadataEntity,
RoomDataHasMetadataEntity
for interaction with
RoomDescriptor.Data

- Add compatibility with
Classy Vs Screen and
fix double trouble
rendering bug

- Add Starting Room
Controls rendering API
per character
]])

            TryAddChangelog("v1.85", [[- Add convenience function
GetIndicesWithEntity

- Improve womb overlay visuals
in curse of darkness
            ]])

            TryAddChangelog("v1.84", [[- Fix issue with room test file
that was causing startup crashes

- Add POST_CUSTOM_GRID_REMOVE
callback

- StageAPI is now off by default
when testing rooms outside custom
floors

- Add StageAPI.OverrideTestRoom
switch as an explicit override
for that

- Enhance PRE_SPAWN_ENTITY compat
with PRE_ROOM_ENTITY_SPAWN so
effects are automatically
converted to type 1000

- Only prevent clearing wall grids
"outside" the room. this allows
custom grids based on GRID_WALL

- Improved the accuracy of
Depths and Womb overlays

- Add RemoveCustomGrid function

- CurrentRoom.Data.RoomGfx is set
to whatever RoomGfx was applied
to the room after callbacks

- Fix a bug that crashed the game
when a coop player exited

- Fix save and continue so rooms
are loaded in the correct positions

- Remove all vanilla closet
boss rooms

- Add detonator meta entity
that when triggered destroys
its grid or creates a bridge,
and detonated trigger that
triggers when detonated in
that way

- Add default broken states
for alt grids with
overridden spawns
            ]])

            TryAddChangelog("v1.83", [[- Fix a bug with
PRE_SPAWN_ENTITY that caused
replacements to persist
between runs

- Make compatible with
multi-room Basement Renovator
tests

- Add GetValidRoomsForLayout
and GetDoorsForRoom

- Fix bug where missing door
weights were unused
            ]])

            TryAddChangelog("v1.80 - 82", [[- Extra rooms can now use
default or boss room types
from the current floor
as a base for their backdrop
and music

- Upgraded streak system to allow
larger base sprites, and holding
in place for as long as needed

- Boss rooms can be set in place
for boss testing with
basement renovator

- Movable TNT and shopkeepers are
now properly persistent

- Added a triggerable grid destroyer
metadata entity that can create
bridges and destroy rocks

- Fixed bosses marked as horsemen
not taking the place of
horsemen in their floors

- Various changes to room layout
picking including a setting to pick
from all shapes, doors now more
easily associated with empty room
layouts, and boss room initialization
without loading

- Added GetDisplayName, IsNextStage,
and IsSameStage functions

- Fixed custom doors and
shading moving incorrectly
during screenshake

**v1.81

- Pitfalls and eternal flies are now
persistent

- Separated room type requiring
for sin rooms and special rooms,
so that you do not need
secret / shop sin rooms

- Added DoLayoutDoorsMatch for
convenience

**v1.82

- Update BR scripts for Basement
Renovator xml format and add setup
script

- Improve accuracy of floor anm2 to
match with the base game

- Add hook for custom boss portrait
sprite and portrait offset

- Fixed animation for trapdoors
overridden with PRE_SELECT_NEXT_STAGE

- Add setter functions for
IsSecondStage and StageNumber
]])

            TryAddChangelog("v1.78 - 79", [[-Fixed an issue where "fart damage" was
cancelled even with none in the room,
which broke Sharp Plug.

- StageAPI's PRE_SPAWN_ENTITY is
compatible with the return value of
PRE_ROOM_ENTITY_SPAWN

- Allow multiple pit spritesheets

- Improve RNG (?)
]])

            TryAddChangelog("v1.75 - 78", [[-Fixed an issue with nightmare
jingle not being overridden

-Relocated test room lua, fixing
harmless error on game start

-"roomnames" command now
displays base rooms
as well as difficulty and stage id.
a new command "trimroomnames" has
been added which cuts out
everything other than name and id

-Overridden d7 no
longer force-plays
active use animation

-Added several new
entity metadata features
-- AddUnblockableEntities allows
setting unblockable entities,
like custom grids
-- GetEntityMetadata allows
specifying name but not index,
to get all metadata entities
with a particular name
-- GetEntityMetadataOfType allows
getting all metadata entities
within a certain group, like
directions

-GotoCustomStage now allows
not forgetting the stage
seed, in case mods want to
do special stage RNG

-Included XML to Lua script
is now much faster

- Enhanced Basement Renovator
compatibility: layout will now
load directly so roomlist callbacks
can't interfere, set up stage
support

-Fixed extra rooms not
being loaded on save
and continue
            ]])

            TryAddChangelog("v1.72 - 74", [[-Basement renovator integration

-Added stb converter to mod folder,
contained within scripts zip

-StageAPI now saved on new level,
fixing some issues with
lingering custom stages
after a crash

-Added room splitting by
type or entities functionality,
used for sins

-Custom stages can now set
sin rooms to take the place
of base minibosses

-Fixed The Soul not counting
as The Forgotten in
transitions

-An additional offset can
now be added to custom
overlays

-Custom stages can now
override StageAPI's default
trapdoor replacement system
            ]])

            TryAddChangelog("v1.69 - 71", [[-Fixed transitions out of special rooms
not properly resetting the music

-Allowed following base game
room rules such as multiple
choice treasure rooms when filling
a special room layout

-Added support for all special rooms
to be easily overriden by a
custom stage like default rooms

-Extra rooms now properly
save when moving from
one extra room to another

-Added support for custom
challenge waves (details
can be found in main.lua)

-Added support for tying
RoomGfx to a specific
room, which takes
priority over stage

-Text for "roomnames" command
is now rendered at 50% scale
and includes room subtype

-Fixed first transition from
extra room to normal room
improperly acting like
a transition from an
extra room to
an off-grid room

-Added support for custom
boss intro and outro music
for custom stages

-Added support for custom
level transition stingers
for custom stages

-Added a miniboss flag
for bosses that plays
a text streak rather than
a boss animation

-Added functions
-- IsIndexInLayout
-- GetCustomGrid
-- AddEntityToSpawnList

-Fixed teleportation cards
and items potentially
sending the player to
invalid door slots

-Fixed rooms only being accepted
as a table rather than alone
            ]])

            TryAddChangelog("v1.68", [[-Fixed some persistent entities
duplicating or respawning
when they shouldn't
in extra rooms

-Fixed escaping from an
extra room to a base
game off-grid room
(such as devil via joker)
then re-entering the extra
room resulting in an infinitely
looping bedroom
            ]])

            TryAddChangelog("v1.67", [[-Missing door weight is now
scaled correctly by original weight
            ]])

            TryAddChangelog("v1.66", [[-Fixed persistent entity data
not always unloading when
the room changes

-Room weight is now scaled
by number of unavailable
doors to make rooms
with a large amount
of unavailable doors
more likely to appear
            ]])

            TryAddChangelog("v1.65", [[-Fixed dead slot machines
respawning in extra rooms
            ]])

            TryAddChangelog("v1.64", [[-Disabled backdrop setting
on non-custom floors
            ]])

            TryAddChangelog("v1.63", [[-Fixed stage shadows not
being properly centered
in some L shaped rooms

-Fixed black overlay in
stage and room transitions
not scaling with screen.
            ]])

            TryAddChangelog("v1.62", [[-Fixed extra rooms containing
persistent entities from the
previous room, after you
re-enter the room twice
            ]])

            TryAddChangelog("v1.61", [[-Fixed extra rooms containing
persistent entities from the
previous room
            ]])

            TryAddChangelog("v1.60", [[-Fixed Mom's Heart track
not playing properly in Utero 2

-Fixed extra rooms (for example
revelations' mirror room)
not correctly unloading
when exited by means
other than a door
            ]])
        end
    end)
end

StageAPI.LogMinor("Fully Loaded, loading dependent mods.")
StageAPI.MarkLoaded("StageAPI", "1.94", true, true)

StageAPI.Loaded = true
if StageAPI.ToCall then
    for _, fn in ipairs(StageAPI.ToCall) do
        fn()
    end
end
