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

- PRE_SPAWN_ENTITY_LIST(entityList, spawnIndex, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistentPositions)
-- Takes 1 return value. If false, cancels spawning the entity list. If a table, uses it as the entity list. Any return value breaks out of future callbacks.
-- Every entity in the final entity list is spawned.
-- Note that this entity list contains EntityInfo tables rather than EntityData, which contain persistent room-specific data. Both detailed below.

- PRE_SPAWN_ENTITY(entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistentPositions, shouldSpawnEntity)
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

- PRE_TRANSITION_RENDER()
-- Called before the custom room transition would render, for effects that should render before it.

- POST_SPAWN_CUSTOM_DOOR(door, data, sprite, CustomDoor, persistData, index, force, respawning, grid, CustomGrid)
-- Takes CustomDoorName as first callback parameter, and will only run if parameter not supplied or matches current door.

- POST_CUSTOM_DOOR_UPDATE(door, data, sprite, CustomDoor, persistData)
-- Takes CustomDoorName as first callback parameter, and will only run if parameter not supplied or matches current door.

- PRE_SELECT_BOSS(bosses, allowHorseman, rng)
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

PlayTextStreak(text, extratext, extratextOffset, extratextScaleMulti) -- extra text usually used for item descriptions, not used in stageapi by default.

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

    function StageAPI.Log(str)
        str = '[StageAPI] ' .. str
        Isaac.ConsoleOutput(str .. '\n')
        Isaac.DebugString(str)
    end

    StageAPI.PoopVariant = {
        Normal = 0,
        Red = 1,
        Eternal = 2,
        Golden = 3,
        Rainbow = 4,
        Black = 5,
        White = 6
    }

    StageAPI.CorrectedGridTypes = {
        [1000]=GridEntityType.GRID_ROCK,
        [1001]=GridEntityType.GRID_ROCK_BOMB,
        [1002]=GridEntityType.GRID_ROCK_ALT,
        [1300]=GridEntityType.GRID_TNT,
        [1498]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.White},
        [1497]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Black},
        [1496]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Golden},
        [1495]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Eternal},
        [1494]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Rainbow},
        [1490]={Type = GridEntityType.GRID_POOP, Variant = StageAPI.PoopVariant.Red},
        [1500]=GridEntityType.GRID_POOP,
        [1900]=GridEntityType.GRID_ROCKB,
        [1930]=GridEntityType.GRID_SPIKES,
        [1931]=GridEntityType.GRID_SPIKES_ONOFF,
        [1940]=GridEntityType.GRID_SPIDERWEB,
        [3000]=GridEntityType.GRID_PIT,
        [4000]=GridEntityType.GRID_LOCK,
        [4500]=GridEntityType.GRID_PRESSURE_PLATE,
        [5000]=GridEntityType.GRID_STATUE,
        [5001]={Type = GridEntityType.GRID_STATUE, Variant = 1},
        [9000]=GridEntityType.GRID_TRAPDOOR,
        [9100]=GridEntityType.GRID_STAIRS,
        [10000]=GridEntityType.GRID_GRAVITY
    }

    StageAPI.E = {
        Backdrop = "StageAPIBackdrop",
        Bridge = "StageAPIBridge",
        Shading = "StageAPIShading",
        StageShadow = "StageAPIStageShadow",
        GenericEffect = "StageAPIGenericEffect",
        FloorEffect = "StageAPIFloorEffect",
        Trapdoor = "StageAPITrapdoor",
        Door = "StageAPIDoor",
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

Isaac.DebugString("[StageAPI] Loading Core Functions")
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
            return rng:Next() % (b - a + 1) + a
        elseif a then
            return rng:Next() % a
        end
        return rng:Next()
    end

    function StageAPI.WeightedRNG(args, rng, key, preCalculatedWeight) -- takes tables {{obj, weight}, {"pie", 3}, {555, 0}}
        local weight_value = preCalculatedWeight or 0
        local iterated_weight = 1
        if not preCalculatedWeight then
            for _, potentialObject in ipairs(args) do
                if key then
                    weight_value = weight_value + potentialObject[key]
                else
                    weight_value = weight_value + potentialObject[2]
                end
            end
        end

        rng = rng or StageAPI.RandomRNG
        local random_chance = StageAPI.Random(1, weight_value, rng)
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

    local TextStreakScales = {
        [0] = Vector(3,0.2),	[1] = Vector(2.6,0.36),
        [2] = Vector(2.2,0.52),	[3] = Vector(1.8,0.68),
        [4] = Vector(1.4,0.84),	[5] = Vector(0.95,1.05),
        [6] = Vector(0.97,1.03),	[7] = Vector(0.98,1.02),
        [61] = Vector(0.99,1.03),	[62] = Vector(0.98,1.05),
        [63] = Vector(0.96,1.08),	[64] = Vector(0.95,1.1),
        [65] = Vector(1.36,0.92),	[66] = Vector(1.77,0.74),
        [67] = Vector(2.18,0.56),	[68] = Vector(2.59,0.38),
        [69] = Vector(3,0.2)
    }

    local TextStreakPositions = {
        [0] = -800,	[1] = -639,
        [2] = -450,	[3] = -250,
        [4] = -70,	[5] = 10,
        [6] = 6,	[7] = 3,
        [61] = -5,	[62] = -10,
        [63] = -15,	[64] = -20,
        [65] = 144,	[66] = 308,
        [67] = 472,	[68] = 636,
        [69] =800
    }

    local StreakSprites = {}
    local Streaks = {}

    local streakFont = Font()
    streakFont:Load("font/upheaval.fnt")

    local streakSmallFont = Font()
    streakSmallFont:Load("font/pftempestasevencondensed.fnt")

    local streakDefaultColor = KColor(1,1,1,1,0,0,0)
    local streakDefaultPos = Vector(240, 48)
    local oneVector = Vector(1, 1)
    function StageAPI.PlayTextStreak(text, extratext, extratextOffset, extratextScaleMulti, replaceSpritesheet, spriteOffset, font, smallFont, color)
        local streak = {}
        if type(text) == "table" then
            streak = text
        else
            streak.Text = text
            streak.ExtraText = extratext
        end

        streak.Frame = 0
        streak.Color = streak.Color or color or streakDefaultColor
        streak.Font = streak.Font or font or streakFont
        streak.SmallFont = streak.SmallFont or smallFont or streakSmallFont
        streak.Width = streak.Font:GetStringWidth(streak.Text) / 2
        streak.ExtraWidth = streak.SmallFont:GetStringWidth(streak.ExtraText or "") / 2
        streak.RenderPos = streak.RenderPos or streakDefaultPos
        streak.FontScale = streak.FontScale or oneVector
        streak.ExtraFontScale = streak.ExtraFontScale or extratextScaleMulti
        streak.ExtraOffset = streak.ExtraOffset or extratextOffset
        streak.SpriteOffset = streak.SpriteOffset or spriteOffset or zeroVector
        streak.Spritesheet = streak.Spritesheet or replaceSpritesheet or "stageapi/streak.png"

        local index = #Streaks + 1
        streak.SpriteIndex = index

        if not StreakSprites[index] then -- this system loads as many sprites as it has to play at once
            StreakSprites[index] = Sprite()
            StreakSprites[index]:Load("stageapi/streak.anm2", true)
        end

        if streak.Spritesheet then
            StreakSprites[index]:ReplaceSpritesheet(0, streak.Spritesheet)
            StreakSprites[index]:LoadGraphics()
        end

        StreakSprites[index].Offset = streak.SpriteOffset
        StreakSprites[index]:Play("Text", true)

        Streaks[index] = streak
    end

    function StageAPI.UpdateTextStreak()
        for index, streakPlaying in StageAPI.ReverseIterate(Streaks) do
            local sprite = StreakSprites[streakPlaying.SpriteIndex]

            sprite:Update()

            streakPlaying.Frame = sprite:GetFrame()
            if streakPlaying.Frame >= 69 then
                sprite:Stop()
                table.remove(Streaks, index)
            end

            streakPlaying.FontScale = (TextStreakScales[streakPlaying.Frame] or oneVector)
            local screenX = StageAPI.GetScreenCenterPosition().X
            streakPlaying.RenderPos.X = screenX
            streakPlaying.PositionX = (TextStreakPositions[streakPlaying.Frame] or 0) - streakPlaying.Width * streakPlaying.FontScale.X + screenX + 0.25
            streakPlaying.ExtraPositionX = (TextStreakPositions[streakPlaying.Frame] or 0) - (streakPlaying.ExtraWidth / 2) * streakPlaying.FontScale.X + screenX + 0.25
        end
    end

    function StageAPI.RenderTextStreak()
        for index, streakPlaying in StageAPI.ReverseIterate(Streaks) do
            if streakPlaying.PositionX then
                local sprite = StreakSprites[streakPlaying.SpriteIndex]
                sprite:Render(streakPlaying.RenderPos, zeroVector, zeroVector)
                streakPlaying.Font:DrawStringScaled(streakPlaying.Text, streakPlaying.PositionX, streakPlaying.RenderPos.Y - 9, streakPlaying.FontScale.X, 1, streakPlaying.Color, 0, true)
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

    function StageAPI.SpawnFloorEffect(pos, velocity, spawner, anm2, loadGraphics, variant)
        local eff = Isaac.Spawn(StageAPI.E.FloorEffectCreep.T, StageAPI.E.FloorEffectCreep.V, StageAPI.E.FloorEffectCreep.S, pos or zeroVector, velocity or zeroVector, spawner)
        eff.Variant = variant or StageAPI.E.FloorEffect.V
        if anm2 then
            eff:GetSprite():Load(anm2, loadGraphics)
        end

        return eff
    end
end

Isaac.DebugString("[StageAPI] Loading Overlay System")
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
    function StageAPI.Overlay:Init(file, velocity, offset, size)
        self.Sprite = Sprite()
        self.Sprite:Load(file, true)
        self.Sprite:Play("Idle", true)
        self.Position = zeroVector
        self.Velocity = velocity or zeroVector
        self.Offset = offset or zeroVector
        self.Size = size or StageAPI.OverlayDefaultSize
    end

    function StageAPI.Overlay:SetAlpha(alpha, noCancelFade)
        local sprite = self.Sprite
        self.Alpha = alpha
        sprite.Color = Color(sprite.Color.R, sprite.Color.G, sprite.Color.B, alpha, math.floor(sprite.Color.RO*255), math.floor(sprite.Color.GO*255), math.floor(sprite.Color.BO*255))
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

    function StageAPI.Overlay:Render(noCenterCorrect, additionalOffset)
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

        StageAPI.RenderSpriteTiled(self.Sprite, self.Position + (self.Offset or zeroVector) + (additionalOffset or zeroVector), self.Size, centerCorrect)

        if StageAPI.DebugTiling then
            Isaac.RenderText("OriginPoint: " .. tostring(self.Position.X) .. ", " .. tostring(self.Position.Y), self.Position.X, self.Position.Y, 0, 255, 0, 1)
        end
    end
end

Isaac.DebugString("[StageAPI] Loading Room Handler")
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
            Height = 9
        },
        [RoomShape.ROOMSHAPE_IV] = {
            Width = 15,
            Height = 9
        },
        [RoomShape.ROOMSHAPE_IH] = {
            Width = 15,
            Height = 9
        },
        [RoomShape.ROOMSHAPE_2x2] = {
            Width = 28,
            Height = 16
        },
        [RoomShape.ROOMSHAPE_2x1] = {
            Width = 28,
            Height = 9
        },
        [RoomShape.ROOMSHAPE_1x2] = {
            Width = 15,
            Height = 16
        },
        [RoomShape.ROOMSHAPE_IIV] = {
            Width = 15,
            Height = 16
        },
        [RoomShape.ROOMSHAPE_LTL] = {
            Width = 28,
            Height = 16,
            LWidthEnd = 14,
            LHeightEnd = 8
        },
        [RoomShape.ROOMSHAPE_LBL] = {
            Width = 28,
            Height = 16,
            LWidthEnd = 14,
            LHeightStart = 8
        },
        [RoomShape.ROOMSHAPE_LBR] = {
            Width = 28,
            Height = 16,
            LWidthStart = 14,
            LHeightStart = 8
        },
        [RoomShape.ROOMSHAPE_LTR] = {
            Width = 28,
            Height = 16,
            LWidthStart = 14,
            LHeightEnd = 8
        },
        [RoomShape.ROOMSHAPE_IIH] = {
            Width = 28,
            Height = 9
        }
    }

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
                    if StageAPI.CorrectedGridTypes[entityData.TYPE] then
                        local t, v = StageAPI.CorrectedGridTypes[entityData.TYPE], entityData.VARIANT
                        if type(t) == "table" then
                            v = t.Variant
                            t = t.Type
                        end

                        local gridData = {
                            Type = t,
                            Variant = v,
                            GridX = object.GRIDX,
                            GridY = object.GRIDY,
                            Index = index
                        }
                        outLayout.GridEntities[#outLayout.GridEntities + 1] = gridData

                        if not outLayout.GridEntitiesByIndex[gridData.Index] then
                            outLayout.GridEntitiesByIndex[gridData.Index] = {}
                        end

                        outLayout.GridEntitiesByIndex[gridData.Index][#outLayout.GridEntitiesByIndex[gridData.Index] + 1] = gridData
                    elseif entityData.TYPE ~= 0 then
                        local entData = {
                            Type = entityData.TYPE,
                            Variant = entityData.VARIANT,
                            SubType = entityData.SUBTYPE,
                            GridX = object.GRIDX,
                            GridY = object.GRIDY,
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

                        if not outLayout.EntitiesByIndex[entData.Index] then
                            outLayout.EntitiesByIndex[entData.Index] = {}
                        end

                        outLayout.EntitiesByIndex[entData.Index][#outLayout.EntitiesByIndex[entData.Index] + 1] = entData
                        outLayout.Entities[#outLayout.Entities + 1] = entData
                    end
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
        local width, height, lWidthStart, lWidthEnd, lHeightStart, lHeightEnd
        if not widthHeight then
            width, height = StageAPI.RoomShapeToWidthHeight[RoomShape.ROOMSHAPE_1x1].Width, StageAPI.RoomShapeToWidthHeight[RoomShape.ROOMSHAPE_1x1].Height
        else
            width, height, lWidthStart, lWidthEnd, lHeightStart, lHeightEnd = widthHeight.Width, widthHeight.Height, widthHeight.LWidthStart, widthHeight.LWidthEnd, widthHeight.LHeightStart, widthHeight.LHeightEnd
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

        for i = 0, 7 do
            newRoom.Doors[#newRoom.Doors + 1] = {
                Slot = i,
                Exists = true
            }
        end

        return newRoom
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

    function StageAPI.ClearRoomLayout(keepDecoration, doGrids, doEnts, doPersistentEnts, onlyRemoveTheseDecorations, doWalls, doDoors)
        if doEnts or doPersistentEnts then
            for _, ent in ipairs(Isaac.GetRoomEntities()) do
                local etype = ent.Type
                if etype ~= EntityType.ENTITY_FAMILIAR and etype ~= EntityType.ENTITY_PLAYER and etype ~= EntityType.ENTITY_KNIFE and not (etype == StageAPI.E.Shading.T and ent.Variant == StageAPI.E.Shading.V) then
                    local persistentData = StageAPI.CheckPersistence(ent.Type, ent.Variant, ent.SubType)
                    if (doPersistentEnts or (ent:ToNPC() and (not persistentData or not persistentData.AutoPersists))) and not (ent:HasEntityFlags(EntityFlag.FLAG_CHARM) or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        ent:Remove()
                    end
                end
            end
        end

        if doGrids then
            local lindex = StageAPI.GetCurrentRoomID()
            StageAPI.CustomGrids[lindex] = {}
            StageAPI.RoomGrids[lindex] = {}
            for i = 0, room:GetGridSize() do
                local grid = room:GetGridEntity(i)
                if grid then
                    local gtype = grid.Desc.Type
                    if (doWalls or gtype ~= GridEntityType.GRID_WALL) and (doDoors or gtype ~= GridEntityType.GRID_DOOR) and (not onlyRemoveTheseDecorations or gtype ~= GridEntityType.GRID_DECORATION or onlyRemoveTheseDecorations[i]) then
                        StageAPI.Room:RemoveGridEntity(i, 0, keepDecoration)
                    end
                end
            end
        end

        StageAPI.CalledRoomUpdate = true
        room:Update()
        StageAPI.CalledRoomUpdate = false
    end

    StageAPI.RoomChooseRNG = RNG()
    function StageAPI.ChooseRoomLayout(roomList, seed, shape, rtype, requireRoomType, ignoreDoors, doors, disallowIDs)
        local callbacks = StageAPI.GetCallbacks("POST_CHECK_VALID_ROOM")
        local validRooms = {}

        shape = shape or room:GetRoomShape()
        seed = seed or room:GetSpawnSeed()
        if requireRoomType then
            rtype = rtype or room:GetType()
        end

        local possibleRooms = roomList[shape]
        local totalWeight = 0
        if possibleRooms then
            for _, layout in ipairs(possibleRooms) do
                local isValid = true

                local numNonExistingDoors = 0
                if requireRoomType and layout.Type ~= rtype then
                    isValid = false
                elseif not ignoreDoors then
                    for _, door in ipairs(layout.Doors) do
                        if door.Slot then
                            if not door.Exists and ((not doors and room:GetDoor(door.Slot)) or (doors and doors[door.Slot])) then
                                isValid = false
                            elseif not door.Exists then
                                numNonExistingDoors = numNonExistingDoors + 1
                            end
                        end
                    end
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

                local originalWeight = weight
                weight = weight * 2 ^ numNonExistingDoors
                if shape == RoomShape.ROOMSHAPE_1x1 and numNonExistingDoors > 0 then
                    weight = weight + math.min(originalWeight * 4, 4)
                end

                if isValid then
                    validRooms[#validRooms + 1] = {layout, weight}
                    totalWeight = totalWeight + weight
                end
            end
        else
            StageAPI.Log("No rooms for shape!")
        end

        if #validRooms > 0 then
            StageAPI.RoomChooseRNG:SetSeed(seed, 0)
            return StageAPI.WeightedRNG(validRooms, StageAPI.RoomChooseRNG, nil, totalWeight)
        else
            StageAPI.Log("No rooms with correct shape and doors!")
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

    StageAPI.PersistenceChecks = {}
    function StageAPI.AddPersistenceCheck(fn)
        StageAPI.PersistenceChecks[#StageAPI.PersistenceChecks + 1] = fn
    end

    StageAPI.AddPersistenceCheck(function(entData)
        if entData.Type == EntityType.ENTITY_BOMBDROP or entData.Type == EntityType.ENTITY_PICKUP or entData.Type == EntityType.ENTITY_SLOT or entData.Type == EntityType.ENTITY_FIREPLACE then
            return {
                AutoPersists = true,
                UpdatePosition = true,
                RemoveOnRemove = true,
                StoreCheck = function(entity)
                    if entity.Type == EntityType.ENTITY_PICKUP then
                        local variant = entity.Variant
                        if variant == PickupVariant.PICKUP_COLLECTIBLE then
                            return entity.SubType == 0
                        else
                            local sprite = entity:GetSprite()
                            if sprite:IsPlaying("Open") or sprite:IsPlaying("Opened") or sprite:IsPlaying("Collect") or sprite:IsFinished("Open") or sprite:IsFinished("Opened") or sprite:IsFinished("Collect") then
                                return true
                            end

                            if entity:IsDead() then
                                return true
                            end
                        end
                    elseif entity.Type == EntityType.ENTITY_FIREPLACE then
                        return entity.HitPoints <= 2
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
        [900] = {
            [0] = {
                Name = "Group 0",
                Group = "Groups",
                Conflicts = true,
                StoreAsGroup = true,
                OnlyConflictWith = "RandomizeGroup"
            },
            [1] = {
                Name = "Group 1",
                Group = "Groups",
                Conflicts = true,
                StoreAsGroup = true,
                OnlyConflictWith = "RandomizeGroup"
            },
            [2] = {
                Name = "Group 2",
                Group = "Groups",
                Conflicts = true,
                StoreAsGroup = true,
                OnlyConflictWith = "RandomizeGroup"
            },
            [3] = {
                Name = "Group 3",
                Group = "Groups",
                Conflicts = true,
                StoreAsGroup = true,
                OnlyConflictWith = "RandomizeGroup"
            },
            [4] = {
                Name = "Group 4",
                Group = "Groups",
                Conflicts = true,
                StoreAsGroup = true,
                OnlyConflictWith = "RandomizeGroup"
            },
            [5] = {
                Name = "Group 5",
                Group = "Groups",
                Conflicts = true,
                StoreAsGroup = true,
                OnlyConflictWith = "RandomizeGroup"
            },
            [6] = {
                Name = "Group 6",
                Group = "Groups",
                Conflicts = true,
                StoreAsGroup = true,
                OnlyConflictWith = "RandomizeGroup"
            },
            [7] = {
                Name = "Group 7",
                Group = "Groups",
                Conflicts = true,
                StoreAsGroup = true,
                OnlyConflictWith = "RandomizeGroup"
            },
            [8] = {
                Name = "Group 8",
                Group = "Groups",
                Conflicts = true,
                StoreAsGroup = true,
                OnlyConflictWith = "RandomizeGroup"
            },
            [9] = {
                Name = "Group 9",
                Group = "Groups",
                Conflicts = true,
                StoreAsGroup = true,
                OnlyConflictWith = "RandomizeGroup"
            },
            [10] = {
                Name = "RandomizeGroup"
            },
            [11] = {
                Name = "Left",
                Group = "Direction",
                Conflicts = true,
                PreventConflictWith = "PreventDirectionConflict"
            },
            [12] = {
                Name = "Right",
                Group = "Direction",
                Conflicts = true,
                PreventConflictWith = "PreventDirectionConflict"
            },
            [13] = {
                Name = "Up",
                Group = "Direction",
                Conflicts = true,
                PreventConflictWith = "PreventDirectionConflict"
            },
            [14] = {
                Name = "Down",
                Group = "Direction",
                Conflicts = true,
                PreventConflictWith = "PreventDirectionConflict"
            },
            [15] = {
                Name = "UpLeft",
                Group = "Direction",
                Conflicts = true,
                PreventConflictWith = "PreventDirectionConflict"
            },
            [16] = {
                Name = "UpRight",
                Group = "Direction",
                Conflicts = true,
                PreventConflictWith = "PreventDirectionConflict"
            },
            [17] = {
                Name = "DownLeft",
                Group = "Direction",
                Conflicts = true,
                PreventConflictWith = "PreventDirectionConflict"
            },
            [18] = {
                Name = "DownRight",
                Group = "Direction",
                Conflicts = true,
                PreventConflictWith = "PreventDirectionConflict"
            },
            [19] = {
                Name = "PreventDirectionConflict"
            },
            [20] = {
                Name = "Swapper"
            },
            --[[
            [21] = {
                Name = "Detonator"
            },]]
            [22] = {
                Name = "RoomClearTrigger",
                Trigger = true
            },
            [23] = {
                Name = "Spawner",
                BlockEntities = true
            },
            [24] = {
                Name = "PreventRandomization"
            },
            [25] = {
                Name = "BridgeFailsafe"
            },
            --[[
            [26] = {
                Name = "DetonatorTrigger",
                Trigger = true
            }]]
            [27] = {
                Name = "DoorLocker"
            }
        }
    }

    StageAPI.MetadataEntitiesByName = {}

    StageAPI.UnblockableEntities = {}

    for id, variants in pairs(StageAPI.MetadataEntities) do
        for variant, metadata in pairs(variants) do
            metadata.Variant = variant
            metadata.Type = id
            StageAPI.MetadataEntitiesByName[metadata.Name] = metadata
        end
    end

    function StageAPI.AddMetadataEntities(tbl)
        if type(next(tbl)) == "table" and next(tbl).Name then
            for variant, data in pairs(tbl) do
                data.Type = 900
                data.Variant = variant
                StageAPI.MetadataEntities[900][variant] = data
                StageAPI.MetadataEntitiesByName[data.Name] = data
            end
        else
            for id, variantTable in pairs(tbl) do
                if StageAPI.MetadataEntities[id] then
                    for variant, data in pairs(variantTable) do
                        data.Variant = variant
                        data.Type = id
                        StageAPI.MetadataEntities[id][variant] = data
                        StageAPI.MetadataEntitiesByName[data.Name] = data
                    end
                else
                    StageAPI.MetadataEntities[id] = {}
                    for variant, data in pairs(variantTable) do
                        data.Variant = variant
                        data.Type = id
                        StageAPI.MetadataEntities[id][variant] = data
                        StageAPI.MetadataEntitiesByName[data.Name] = data
                    end
                end
            end
        end
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

    function StageAPI.SeparateEntityMetadata(entities, grids, seed)
        StageAPI.RoomLoadRNG:SetSeed(seed or room:GetSpawnSeed(), 1)
        local outEntities, entityMeta = {}, {}
        for index, entityList in pairs(entities) do
            local outList = {}
            for _, entity in ipairs(entityList) do
                if StageAPI.MetadataEntities[entity.Type] and entity.Variant and StageAPI.MetadataEntities[entity.Type][entity.Variant] and (not entity.SubType or entity.SubType == 0) then
                    local metadata = StageAPI.MetadataEntities[entity.Type][entity.Variant]
                    if not entityMeta[index] then
                        entityMeta[index] = {}
                    end

                    if not entityMeta[index][metadata.Name] then
                        entityMeta[index][metadata.Name] = 0
                    end

                    entityMeta[index][metadata.Name] = entityMeta[index][metadata.Name] + 1
                else
                    outList[#outList + 1] = entity
                end
            end

            outEntities[index] = outList
        end

        local swapIndexToGroups = {}
        local swapGroupToIndices = {}
        local blockedEntities = {}

        for index, metadataSet in pairs(entityMeta) do
            local setsOfConflicting = {}
            for name, count in pairs(metadataSet) do
                local metadata = StageAPI.MetadataEntitiesByName[name]
                if metadata.BlockEntities and outEntities[index] then
                    blockedEntities[index] = {}
                    for i, entity in StageAPI.ReverseIterate(outEntities[index]) do
                        if not (StageAPI.UnblockableEntities[entity.Type] and (StageAPI.UnblockableEntities[entity.Type] == true
                        or (StageAPI.UnblockableEntities[entity.Type][entity.Variant] and (StageAPI.UnblockableEntities[entity.Type][entity.Variant] == true
                        or StageAPI.UnblockableEntities[entity.Type][entity.Variant][entity.SubType] == true)))) then
                            blockedEntities[index][#blockedEntities[index] + 1] = entity
                            table.remove(outEntities[index], i)
                        end
                    end

                    if #blockedEntities[index] == 0 then
                        blockedEntities[index] = nil
                    end

                    if #outEntities[index] == 0 then
                        outEntities[index] = nil
                    end
                end

                if metadata.Group then
                    if metadata.Conflicts and not setsOfConflicting[metadata.Group] then
                        local shouldConflict = true
                        if metadata.PreventConflictWith or metadata.OnlyConflictWith then
                            if metadata.PreventConflictWith then
                                local noConflictWith = metadata.PreventConflictWith
                                if type(noConflictWith) ~= "table" then
                                    noConflictWith = {noConflictWith}
                                end

                                for _, preventName in ipairs(noConflictWith) do
                                    if metadataSet[preventName] then
                                        shouldConflict = false
                                    end
                                end
                            elseif metadata.OnlyConflictWith then
                                shouldConflict = false
                                local needsToConflict = metadata.OnlyConflictWith
                                if type(needsToConflict) ~= "table" then
                                    needsToConflict = {needsToConflict}
                                end

                                for _, needsName in ipairs(needsToConflict) do
                                    if metadataSet[needsName] then
                                        shouldConflict = true
                                    end
                                end
                            end
                        end

                        if shouldConflict then
                            setsOfConflicting[metadata.Group] = {}

                            for name2, count2 in pairs(metadataSet) do
                                local metadata2 = StageAPI.MetadataEntitiesByName[name2]
                                if metadata2.Conflicts and metadata2.Group == metadata.Group then
                                    setsOfConflicting[metadata.Group][#setsOfConflicting[metadata.Group] + 1] = name2
                                end
                            end
                        end
                    end
                end
            end

            for group, conflicts in pairs(setsOfConflicting) do
                local use = conflicts[StageAPI.Random(1, #conflicts, StageAPI.RoomLoadRNG)]
                for _, conflictName in ipairs(conflicts) do
                    if conflictName ~= use then
                        metadataSet[conflictName] = nil
                    end
                end
            end

            for name, count in pairs(metadataSet) do
                local metadata = StageAPI.MetadataEntitiesByName[name]
                if metadata and metadata.Group then
                    if metadata.StoreAsGroup then
                        if not metadataSet[metadata.Group] then
                            metadataSet[metadata.Group] = {}
                        end

                        if not metadataSet[metadata.Group][name] then
                            metadataSet[metadata.Group][name] = 0
                        end

                        metadataSet[metadata.Group][name] = metadataSet[metadata.Group][name] + 1
                    elseif type(metadataSet[metadata.Group]) ~= "table" then
                        if not metadataSet[metadata.Group] then
                            metadataSet[metadata.Group] = 0
                        end

                        metadataSet[metadata.Group] = metadataSet[metadata.Group] + 1
                    end
                end
            end

            if metadataSet["Swapper"] then
                if metadataSet["Groups"] then
                    local groupList = {}
                    for group, count in pairs(metadataSet["Groups"]) do
                        groupList[#groupList + 1] = group
                        if not swapGroupToIndices[group] then
                            swapGroupToIndices[group] = {}
                        end
                        swapGroupToIndices[group][#swapGroupToIndices[group] + 1] = index
                    end

                    swapIndexToGroups[index] = groupList
                else
                    if not swapGroupToIndices["None"] then
                        swapGroupToIndices["None"] = {}
                    end

                    swapGroupToIndices["None"][#swapGroupToIndices["None"] + 1] = index
                    swapIndexToGroups[index] = {"None"}
                end
            end
        end

        local outGrids = {}
        for index, gridList in pairs(grids) do
            outGrids[index] = gridList
        end

        for index, groups in pairs(swapIndexToGroups) do
            local canSwapWith = {}
            for _, group in ipairs(groups) do
                local indices = swapGroupToIndices[group]
                for _, index2 in ipairs(indices) do
                    canSwapWith[#canSwapWith + 1] = index2
                end
            end

            if #canSwapWith > 0 then
                local swapWith = canSwapWith[StageAPI.Random(1, #canSwapWith)]
                local swappingEntityList = outEntities[swapWith]
                outEntities[swapWith] = outEntities[index]
                outEntities[index] = swappingEntityList
                local swappingEntityMeta = entityMeta[swapWith]
                entityMeta[swapWith] = entityMeta[index]
                entityMeta[index] = swappingEntityMeta
                local swappingGrid = outGrids[swapWith]
                outGrids[swapWith] = outGrids[index]
                outGrids[index] = swappingGrid
            end
        end

        entityMeta.BlockedEntities = blockedEntities
        entityMeta.Triggers = {}
        entityMeta.RecentTriggers = {}

        return outEntities, outGrids, entityMeta
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
            Persistent = not not persistentData,
            PersistenceData = persistentData
        }

        return persistentIndex
    end

    function StageAPI.SelectSpawnEntities(entities, seed, entityMeta)
        StageAPI.RoomLoadRNG:SetSeed(seed or room:GetSpawnSeed(), 1)
        local entitiesToSpawn = {}
        local callbacks = StageAPI.GetCallbacks("PRE_SELECT_ENTITY_LIST")
        local persistentIndex = 0
        for index, entityList in pairs(entities) do
            if #entityList > 0 then
                local addEntities = {}
                local overridden, stillAddRandom = false, nil
                for _, callback in ipairs(callbacks) do
                    local retAdd, retList, retRandom = callback.Function(entityList, index, entityMeta)
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

                        --[[
                        persistentIndex = persistentIndex + 1
                        local persistentData = StageAPI.CheckPersistence(entData.Type, entData.Variant, entData.SubType)
                        entitiesToSpawn[index][#entitiesToSpawn[index] + 1] = {
                            Data = entData,
                            PersistentIndex = persistentIndex,
                            Persistent = not not persistentData,
                            PersistenceData = persistentData
                        }]]
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
        local entitiesByIndex, gridsByIndex, entityMeta = StageAPI.SeparateEntityMetadata(layout.EntitiesByIndex, layout.GridEntitiesByIndex, seed)
        local spawnEntities, lastPersistentIndex = StageAPI.SelectSpawnEntities(entitiesByIndex, seed, entityMeta)
        local spawnGrids = StageAPI.SelectSpawnGrids(gridsByIndex, seed)

        local gridTakenIndices = {}
        local entityTakenIndices = {}

        for index, entity in pairs(spawnEntities) do
            entityTakenIndices[index] = true
        end

        for index, gridData in pairs(spawnGrids) do
            gridTakenIndices[index] = true
        end

        return spawnEntities, spawnGrids, entityTakenIndices, gridTakenIndices, lastPersistentIndex, entityMeta
    end

    StageAPI.ActiveEntityPersistenceData = {}
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        StageAPI.ActiveEntityPersistenceData = {}
    end)

    function StageAPI.GetEntityPersistenceData(entity)
        return StageAPI.ActiveEntityPersistenceData[GetPtrHash(entity)]
    end

    function StageAPI.SetEntityPersistenceData(entity, persistentIndex, persistentData)
        StageAPI.ActiveEntityPersistenceData[GetPtrHash(entity)] = {
            PersistentIndex = persistentIndex,
            PersistenceData = persistentData
        }
    end

    function StageAPI.LoadEntitiesFromEntitySets(entitysets, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistentPositions, loadingWave)
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
                        local ret = callback.Function(entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistentPositions)
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

                            if shouldSpawnEntity and doPersistentOnly and not entityInfo.PersistenceData then
                                shouldSpawnEntity = false
                            end

                            if shouldSpawnEntity and entityInfo.Persistent and entityInfo.PersistenceData.AutoPersists and not doAutoPersistent then
                                shouldSpawnEntity = false
                            end

                            if entityInfo.PersistentIndex and persistentPositions and persistentPositions[entityInfo.PersistentIndex] then
                                entityInfo.Position = Vector(persistentPositions[entityInfo.PersistentIndex].X, persistentPositions[entityInfo.PersistentIndex].Y)
                            end

                            if not entityInfo.Position then
                                entityInfo.Position = room:GetGridPosition(index)
                            end

                            for _, callback in ipairs(entCallbacks) do
                                if not callback.Params[1] or (entityInfo.Data.Type and callback.Params[1] == entityInfo.Data.Type)
                                and not callback.Params[2] or (entityInfo.Data.Variant and callback.Params[2] == entityInfo.Data.Variant)
                                and not callback.Params[3] or (entityInfo.Data.SubType and callback.Params[3] == entityInfo.Data.SubType) then
                                    local ret = callback.Function(entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistentPositions, shouldSpawnEntity)
                                    if ret == false or ret == true then
                                        shouldSpawnEntity = ret
                                        break
                                    elseif ret and type(ret) == "table" then
                                        if ret.Data then
                                            entityInfo = ret
                                        else
                                            entityInfo.Data.Type = ret[1]
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

                                    local currentRoom = StageAPI.GetCurrentRoom()
                                    if currentRoom and not currentRoom.IgnoreRoomRules then
                                        if entityData.Type == EntityType.ENTITY_PICKUP and entityData.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                                            if currentRoom.RoomType == RoomType.ROOM_TREASURE and (currentRoom.Layout.Variant > 0 or string.find(string.lower(currentRoom.Layout.Name), "choice") or string.find(string.lower(currentRoom.Layout.Name), "choose")) then
                                                ent:ToPickup().TheresOptionsPickup = true
                                            end
                                        end
                                    end

                                    ent:GetData().StageAPISpawnedPosition = entityInfo.Position or StageAPI.ZeroVector
                                    ent:GetData().StageAPIEntityListIndex = index

                                    if entityInfo.Persistent then
                                        StageAPI.SetEntityPersistenceData(ent, entityInfo.PersistentIndex, entityInfo.PersistenceData)
                                    end

                                    if not loadingWave and ent:CanShutDoors() then
                                        StageAPI.Room:SetClear(false)
                                    end

                                    StageAPI.CallCallbacks("POST_SPAWN_ENTITY", false, ent, entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistentPositions, shouldSpawnEntity)

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

                if grid:ToRock() then
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
        for index, gridData in pairs(grids) do
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
                    end

                    grids_spawned[#grids_spawned + 1] = grid
                end

                if gridData.Type == GridEntityType.GRID_PRESSURE_PLATE and gridData.Variant == 0 then
                    StageAPI.Room:SetClear(false)
                end
            end
        end

        return grids_spawned
    end

    function StageAPI.GetGridInformation()
        local gridInformation = {}
        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)
            if grid then
                gridInformation[i] = {
                    State = grid.State,
                    VarData = grid.VarData
                }
            end
        end

        return gridInformation
    end

    function StageAPI.LoadRoomLayout(grids, entities, doGrids, doEntities, doPersistentOnly, doAutoPersistent, gridData, avoidSpawning, persistentPositions, loadingWave)
        local grids_spawned = {}
        local ents_spawned = {}

        if grids and doGrids then
            grids_spawned = StageAPI.LoadGridsFromDataList(grids, gridData, entities)
        end

        if entities and doEntities then
            ents_spawned = StageAPI.LoadEntitiesFromEntitySets(entities, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistentPositions, loadingWave)
        end

        StageAPI.CallGridPostInit()

        return ents_spawned, grids_spawned
    end

    function StageAPI.GetCurrentRoomID()
        if StageAPI.InExtraRoom then
            return StageAPI.CurrentExtraRoomName
        else
            return StageAPI.GetCurrentListIndex()
        end
    end

    StageAPI.LevelRooms = {}
    function StageAPI.SetCurrentRoom(room)
        StageAPI.ActiveEntityPersistenceData = {}
        StageAPI.LevelRooms[StageAPI.GetCurrentRoomID()] = room
    end

    function StageAPI.GetCurrentRoom()
        return StageAPI.LevelRooms[StageAPI.GetCurrentRoomID()]
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

    StageAPI.LevelRoom = StageAPI.Class("LevelRoom")
    StageAPI.NextUniqueRoomIdentifier = 0
    function StageAPI.LevelRoom:Init(layoutName, roomsList, seed, shape, roomType, isExtraRoom, fromSaveData, requireRoomType, ignoreDoors, doors, levelIndex, ignoreRoomRules)
        Isaac.DebugString("[StageAPI] Initializing room")
        StageAPI.CurrentlyInitializing = self
        self.UniqueRoomIdentifier = StageAPI.NextUniqueRoomIdentifier
        StageAPI.NextUniqueRoomIdentifier = StageAPI.NextUniqueRoomIdentifier + 1
        if fromSaveData then
            Isaac.DebugString("[StageAPI] Loading from save data")
            self.LevelIndex = levelIndex
            self:LoadSaveData(fromSaveData)
        else
            Isaac.DebugString("[StageAPI] Generating room")
            roomType = roomType or room:GetType()
            shape = shape or room:GetRoomShape()
            seed = seed or room:GetSpawnSeed()

            if not doors then
                doors = {}
                for i = 0, 7 do
                    if room:GetDoor(i) then
                        doors[i] = true
                    end
                end
            end

            self.Data = {}
            self.PersistentData = {}

            self.LevelIndex = levelIndex
            self.Doors = doors
            self.Shape = shape
            self.RoomType = roomType
            self.Seed = seed
            self.LayoutName = layoutName
            self.AvoidSpawning = {}
            self.ExtraSpawn = {}
            self.PersistentPositions = {}
            self.FirstLoad = true
            self.RequireRoomType = requireRoomType
            self.IgnoreRoomRules = ignoreRoomRules

            local replaceLayoutName = StageAPI.CallCallbacks("PRE_ROOM_LAYOUT_CHOOSE", true, self)
            if replaceLayoutName then
                Isaac.DebugString("[StageAPI] Layout replaced")
                self.LayoutName = replaceLayoutName
            end

            local layout
            if self.LayoutName then
                layout = StageAPI.Layouts[self.LayoutName]
            end

            if not layout then
                roomsList = StageAPI.CallCallbacks("PRE_ROOMS_LIST_USE", true, self) or roomsList
                self.RoomsListName = roomsList.Name
                layout = StageAPI.ChooseRoomLayout(roomsList.ByShape, seed, shape, roomType, requireRoomType, ignoreDoors, self.Doors)
            end

            self.Layout = layout
            Isaac.DebugString("[StageAPI] Initialized room " .. self.Layout.Name .. "." .. tostring(self.Layout.Variant) .. " from file " .. tostring(self.Layout.RoomFilename)
                                .. (roomsList and (' from list ' .. roomsList.Name) or ''))
            self:PostGetLayout(seed)
        end

        StageAPI.CallCallbacks("POST_ROOM_INIT", false, self, not not fromSaveData, fromSaveData)
        StageAPI.CurrentlyInitializing = nil
    end

    function StageAPI.LevelRoom:PostGetLayout(seed)
        if not self.Layout then
            self.Layout = StageAPI.CreateEmptyRoomLayout(self.Shape)
            StageAPI.Log("No layout!")
        end

        self.SpawnEntities, self.SpawnGrids, self.EntityTakenIndices, self.GridTakenIndices, self.LastPersistentIndex, self.EntityMetadata = StageAPI.ObtainSpawnObjects(self.Layout, seed)

        --[[
        self.SpawnEntities, self.LastPersistentIndex = StageAPI.SelectSpawnEntities(self.Layout.EntitiesByIndex, seed)
        self.SpawnGrids = StageAPI.SelectSpawnGrids(self.Layout.GridEntitiesByIndex, seed)

        self.GridTakenIndices = {}
        self.EntityTakenIndices = {}

        for index, entity in pairs(self.SpawnEntities) do
            self.EntityTakenIndices[index] = true
        end

        for _, grid in ipairs(self.SpawnGrids) do
            self.GridTakenIndices[grid.Index] = true
        end]]
    end

    function StageAPI.LevelRoom:SetEntityMetadata(index, name, value)
        if not self.EntityMetadata[index] then
            self.EntityMetadata[index] = {}
        end

        if not value and not self.EntityMetadata[index][name] then
            self.EntityMetadata[index][name] = 0
        end

        if not value then
            self.EntityMetadata[index][name] = self.EntityMetadata[index][name] + 1
        else
            self.EntityMetadata[index][name] = value
        end
    end

    function StageAPI.LevelRoom:HasEntityMetadata(index, name)
        return self.EntityMetadata[index] and (not name or self.EntityMetadata[index][name])
    end

    function StageAPI.LevelRoom:GetEntityMetadata(index, name)
        if not name then
            return self.EntityMetadata[index]
        elseif not index then
            local indicesWithMetadata = {}
            for index, metadataSet in pairs(self.EntityMetadata) do
                if metadataSet[name] then
                    indicesWithMetadata[index] = metadataSet[name]
                end
            end

            return indicesWithMetadata
        elseif self.EntityMetadata[index] and self.EntityMetadata[index][name] then
            return self.EntityMetadata[index][name]
        end
    end

    function StageAPI.LevelRoom:GetEntityMetadataOfType(metatype, index)
        if index then
            if self.EntityMetadata[index] then
                local includedMetadata = {}
                for name, val in pairs(self.EntityMetadata[index]) do
                    if type(val) == "table" and name == metatype then
                        for _, v in ipairs(val) do
                            includedMetadata[#includedMetadata + 1] = v
                        end
                    elseif type(val) ~= "table" then
                        if StageAPI.MetadataEntitiesByName[name] and StageAPI.MetadataEntitiesByName[name].Group == metatype then
                            includedMetadata[#includedMetadata + 1] = name
                        end
                    end
                end

                return includedMetadata
            end
        else
            local includedMetadataByIndex = {}
            for index, metadataSet in pairs(self.EntityMetadata) do
                local includedMetadata = self:GetEntityMetadataOfType(metatype, index)
                if #includedMetadata > 0 then
                    includedMetadataByIndex[index] = includedMetadata
                end
            end

            return includedMetadataByIndex
        end
    end

    function StageAPI.LevelRoom:GetEntityMetadataGroups(index)
        local groups = {}

        if index then
            local groupTbl = self:GetEntityMetadata(index, "Groups")
            if groupTbl then
                for group, count in pairs(groupTbl) do
                    groups[#groups + 1] = group
                end
            end
        else
            for index, metadataSet in pairs(self.EntityMetadata) do
                if metadataSet["Groups"] then
                    for group, count in pairs(metadataSet["Groups"]) do
                        if not StageAPI.IsIn(groups, group) then
                            groups[#groups + 1] = group
                        end
                    end
                end
            end
        end

        return groups
    end

    function StageAPI.LevelRoom:IndicesShareGroup(index, index2, specificGroup)
        if specificGroup then
            return self:HasEntityMetadata(index, specificGroup) and self:HasEntityMetadata(index2, specificGroup)
        else
            local groups = self:GetEntityMetadataGroups(index)
            for _, group in ipairs(groups) do
                if self:HasEntityMetadata(index2, group) then
                    return true
                end
            end
        end

        return false
    end

    function StageAPI.LevelRoom:GetIndicesInGroup(group)
        local indices = {}
        for index, metadataSet in pairs(self.EntityMetadata) do
            if metadataSet[group] then
                indices[#indices + 1] = index
            end
        end

        return indices
    end

    function StageAPI.LevelRoom:GroupHasMetadata(group, name)
        for index, metadataSet in pairs(self.EntityMetadata) do
            if metadataSet[group] and metadataSet[name] then
                return true
            end
        end

        return false
    end

    function StageAPI.LevelRoom:IndexSharesGroupWithMetadata(index, name)
        local groups = self:GetEntityMetadataGroups(index)
        for _, group in ipairs(groups) do
            if self:GroupHasMetadata(group, name) then
                return true
            end
        end

        return false
    end

    function StageAPI.LevelRoom:IndexIsAssociatedWithMetadata(index, name)
        return self:HasEntityMetadata(index, name) or self:IndexSharesGroupWithMetadata(index, name)
    end

    function StageAPI.LevelRoom:SetMetadataTrigger(name, index, groups, value)
        if not groups then
            groups = {index}
        elseif index then
            groups[#groups + 1] = index
        end

        for _, group in ipairs(groups) do
            if not self.EntityMetadata.Triggers[group] then
                self.EntityMetadata.Triggers[group] = {}
                self.EntityMetadata.RecentTriggers[group] = {}
            end

            if value then
                self.EntityMetadata.Triggers[group][name] = value
                self.EntityMetadata.RecentTriggers[group][name] = 0
            else
                self.EntityMetadata.Triggers[group][name] = nil
                self.EntityMetadata.RecentTriggers[group][name] = nil
            end
        end
    end

    function StageAPI.LevelRoom:WasMetadataTriggered(name, frames, index, groups, exactFrame)
        frames = frames or 0
        if not groups then
            groups = {index}
        elseif index then
            groups[#groups + 1] = index
        end

        for group, names in pairs(self.EntityMetadata.RecentTriggers) do
            if not groups or StageAPI.IsIn(groups, group) then
                for name2, timeSince in pairs(names) do
                    if (not name or name2 == name) and (timeSince == exactFrame or timeSince <= frames) then
                        return true
                    end
                end
            end
        end
    end

    function StageAPI.LevelRoom:TriggerIndexMetadata(index, name, value)
        if value == nil then
            value = true
        end

        local groups = self:GetEntityMetadataGroups(index)
        self:SetMetadataTrigger(name, index, groups, value)
    end

    function StageAPI.LevelRoom:WasIndexTriggered(index, frames, exactFrame)
        return self:WasMetadataTriggered(nil, frames, index, self:GetEntityMetadataGroups(index), exactFrame)
    end

    function StageAPI.LevelRoom:IsGridIndexFree(index, ignoreEntities, ignoreGrids)
        return (ignoreEntities or not self.EntityTakenIndices[index]) and (ignoreGrids or not self.GridTakenIndices[index])
    end

    function StageAPI.LevelRoom:SaveGridInformation()
        self.GridInformation = StageAPI.GetGridInformation()
    end

    function StageAPI.LevelRoom:SavePersistentEntities()
        for index, spawns in pairs(self.ExtraSpawn) do
            for _, spawn in ipairs(spawns) do
                if spawn.PersistenceData.RemoveOnRemove then
                    local hasMatch = false
                    local matching = Isaac.FindByType(spawn.Data.Type, spawn.Data.Variant, spawn.Data.SubType, false, false)
                    for _, match in ipairs(matching) do
                        if not spawn.PersistenceData.StoreCheck or not spawn.PersistenceData.StoreCheck(match, match:GetData()) then
                            hasMatch = true
                        end
                    end

                    if not hasMatch then
                        self.AvoidSpawning[spawn.PersistentIndex] = true
                    end
                end
            end
        end

        for index, spawns in pairs(self.SpawnEntities) do
            for _, spawn in ipairs(spawns) do
                if spawn.PersistenceData and spawn.PersistenceData.RemoveOnRemove then
                    local hasMatch = false
                    local matching = Isaac.FindByType(spawn.Data.Type, spawn.Data.Variant, spawn.Data.SubType, false, false)
                    for _, match in ipairs(matching) do
                        if not spawn.PersistenceData.StoreCheck or not spawn.PersistenceData.StoreCheck(match, match:GetData()) then
                            hasMatch = true
                        end
                    end

                    if not hasMatch then
                        self.AvoidSpawning[spawn.PersistentIndex] = true
                    end
                end
            end
        end

        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local data = entity:GetData()
            local entityPersistData = StageAPI.GetEntityPersistenceData(entity)
            if entityPersistData then
                if entityPersistData.PersistenceData.UpdatePosition then
                    self.PersistentPositions[entityPersistData.PersistentIndex] = {X = entity.Position.X, Y = entity.Position.Y}
                end

                if entityPersistData.PersistenceData.StoreCheck and entityPersistData.PersistenceData.StoreCheck(entity, data) then
                    self.AvoidSpawning[entityPersistData.PersistentIndex] = true
                end
            else
                local persistentData = StageAPI.CheckPersistence(entity.Type, entity.Variant, entity.SubType)
                if persistentData then
                    if not persistentData.StoreCheck or not persistentData.StoreCheck(entity, data) then
                        local index = self.LastPersistentIndex + 1
                        self.LastPersistentIndex = index
                        local grindex = room:GetGridIndex(entity.Position)
                        if not self.ExtraSpawn[grindex] then
                            self.ExtraSpawn[grindex] = {}
                        end

                        self.ExtraSpawn[grindex][#self.ExtraSpawn[grindex] + 1] = {
                            Data = {
                                Type = entity.Type,
                                Variant = entity.Variant,
                                SubType = entity.SubType,
                                Index = grindex
                            },
                            Persistent = true,
                            PersistentIndex = index,
                            PersistenceData = persistentData
                        }

                        if persistentData.UpdatePosition then
                            self.PersistentPositions[index] = {X = entity.Position.X, Y = entity.Position.Y}
                        end

                        StageAPI.SetEntityPersistenceData(entity, index, persistentData)
                    end
                end
            end
        end
    end

    function StageAPI.LevelRoom:RemovePersistentIndex(persistentIndex)
        self.AvoidSpawning[persistentIndex] = true
    end

    function StageAPI.LevelRoom:RemovePersistentEntity(entity)
        local data = StageAPI.GetEntityPersistenceData(entity)
        if data and data.PersistenceData then
            self:RemovePersistentIndex(data.PersistentIndex)
        end
    end

    function StageAPI.LevelRoom:Load(isExtraRoom)
        Isaac.DebugString("[StageAPI] Loading room " .. self.Layout.Name .. "." .. tostring(self.Layout.Variant) .. " from file " .. tostring(self.Layout.RoomFilename))
        if isExtraRoom == nil then
            isExtraRoom = self.IsExtraRoom
        end

        room:SetClear(true)
        StageAPI.ClearRoomLayout(false, self.FirstLoad or isExtraRoom, true, self.FirstLoad or isExtraRoom, self.GridTakenIndices)
        if self.FirstLoad then
            StageAPI.LoadRoomLayout(self.SpawnGrids, {self.SpawnEntities, self.ExtraSpawn}, true, true, false, true, self.GridInformation, self.AvoidSpawning, self.PersistentPositions)
            self.WasClearAtStart = room:IsClear()
            self.IsClear = self.WasClearAtStart
            self.FirstLoad = false
            self.HasEnemies = room:GetAliveEnemiesCount() > 0
        else
            StageAPI.LoadRoomLayout(self.SpawnGrids, {self.SpawnEntities, self.ExtraSpawn}, isExtraRoom, true, self.IsClear, isExtraRoom, self.GridInformation, self.AvoidSpawning, self.PersistentPositions)
            self.IsClear = room:IsClear()
        end

        StageAPI.CalledRoomUpdate = true
        room:Update()
        StageAPI.CalledRoomUpdate = false
        if not self.IsClear then
            StageAPI.CloseDoors()
        end

        StageAPI.CallCallbacks("POST_ROOM_LOAD", false, self, self.FirstLoad, isExtraRoom)
        StageAPI.StoreRoomGrids()
    end

    function StageAPI.LevelRoom:Save()
        self:SavePersistentEntities()
        self:SaveGridInformation()
    end

    function StageAPI.LevelRoom:GetSaveData(isExtraRoom)
        if isExtraRoom == nil then
            isExtraRoom = self.IsExtraRoom
        end

        local saveData = {}
        saveData.IsClear = self.IsClear
        saveData.WasClearAtStart = self.WasClearAtStart
        saveData.RoomsListName = self.RoomsListName
        saveData.LayoutName = self.LayoutName
        saveData.Seed = self.Seed
        saveData.FirstLoad = self.FirstLoad
        saveData.Shape = self.Shape
        saveData.RoomType = self.RoomType
        saveData.TypeOverride = self.TypeOverride
        saveData.PersistentData = self.PersistentData
        saveData.IsExtraRoom = isExtraRoom
        saveData.LastPersistentIndex = self.LastPersistentIndex
        saveData.RequireRoomType = self.RequireRoomType
        saveData.IgnoreRoomRules = self.IgnoreRoomRules

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

        for pindex, position in pairs(self.PersistentPositions) do
            if not saveData.PersistentPositions then
                saveData.PersistentPositions = {}
            end

            saveData.PersistentPositions[tostring(pindex)] = position
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
        self.PersistentData = saveData.PersistentData or {}
        self.AvoidSpawning = {}
        self.PersistentPositions = {}
        self.ExtraSpawn = {}

        self.RoomsListName = saveData.RoomsListName
        self.LayoutName = saveData.LayoutName
        self.Seed = saveData.Seed
        self.Shape = saveData.Shape
        self.RoomType = saveData.RoomType
        self.RequireRoomType = saveData.RequireRoomType
        self.TypeOverride = saveData.TypeOverride
        self.IgnoreRoomRules = saveData.IgnoreRoomRules

        if saveData.Doors then
            self.Doors = {}
            for _, door in ipairs(saveData.Doors) do
                self.Doors[door] = true
            end
        end

        local layout
        if self.LayoutName then
            layout = StageAPI.Layouts[layoutName]
        end

        if self.RoomsListName and not layout then
            local roomsList = StageAPI.RoomsLists[self.RoomsListName]
            if roomsList then
                local retLayout = StageAPI.CallCallbacks("PRE_ROOM_LAYOUT_CHOOSE", true, self, roomsList)
                if retLayout then
                    layout = retLayout
                else
                    layout = StageAPI.ChooseRoomLayout(roomsList.ByShape, self.Seed, self.Shape, self.RoomType, self.RequireRoomType, false, self.Doors)
                end
            end
        end

        self.Layout = layout
        self:PostGetLayout(self.Seed)

        self.LastPersistentIndex = saveData.LastPersistentIndex or self.LastPersistentIndex
        self.IsClear = saveData.IsClear
        self.WasClearAtStart = saveData.WasClearAtStart
        self.FirstLoad = saveData.FirstLoad
        self.IsExtraRoom = saveData.IsExtraRoom

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

        if saveData.PersistentPositions then
            for strindex, position in pairs(saveData.PersistentPositions) do
                self.PersistentPositions[tonumber(strindex)] = position
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
        local data = StageAPI.GetEntityPersistenceData(ent)
        -- Entities are removed whenever you exit the room, in this time the game is paused, which we can use to stop removing persistent entities on room exit.
        if data and data.PersistenceData and data.PersistenceData.RemoveOnRemove and not game:IsPaused() then
            StageAPI.RemovePersistentEntity(ent)
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, ent)
        local data = StageAPI.GetEntityPersistenceData(ent)
        if data and data.PersistenceData and data.PersistenceData.RemoveOnDeath then
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

Isaac.DebugString("[StageAPI] Loading Custom Grid System")
do -- Custom Grid Entities
    StageAPI.CustomGridTypes = {}
    StageAPI.CustomGrid = StageAPI.Class("CustomGrid")
    function StageAPI.CustomGrid:Init(name, baseType, baseVariant, anm2, animation, frame, variantFrames, offset, overrideGridSpawns, overrideGridSpawnAtState, forceSpawning)
        self.Name = name
        self.BaseType = baseType
        self.BaseVariant = baseVariant
        self.Anm2 = anm2
        self.Animation = animation
        self.Frame = frame
        self.VariantFrames = variantFrames
        self.OverrideGridSpawns = overrideGridSpawns
        self.OverrideGridSpawnState = overrideGridSpawnAtState
        self.ForceSpawning = forceSpawning
        self.Offset = offset

        if anm2 then
            self.Sprite = Sprite()
            self.Sprite:Load(anm2, true)
        end

        StageAPI.CustomGridTypes[name] = self
    end

    StageAPI.CustomGrids = {}
    StageAPI.CustomGridIndices = {}
    function StageAPI.CustomGrid:Spawn(grindex, force, reSpawning, startPersistData)
        local grid
        if self.BaseType then
            if not reSpawning then
                force = force or self.ForceSpawning
                grid = Isaac.GridSpawn(self.BaseType, self.BaseVariant or 0, room:GetGridPosition(grindex), force)
            else
                grid = room:GetGridEntity(grindex)
            end

            if self.OverrideGridSpawns and grid and grid.State ~= self.OverrideGridSpawnState or 2 then
                StageAPI.SpawnOverriddenGrids[grindex] = self.OverrideGridSpawnState or true
            end

            if self.Sprite and grid then
                if self.VariantFrames or self.Frame then
                    local animation = self.Animation or self.Sprite:GetDefaultAnimation()
                    if self.VariantFrames then
                        self.Sprite:SetFrame(animation, StageAPI.Random(0, self.VariantFrames))
                    else
                        self.Sprite:SetFrame(animation, self.Frame)
                    end
                elseif self.Animation then
                    self.Sprite:Play(self.Animation, true)
                end

                grid.Sprite = self.Sprite
                if self.Offset then
                    grid.Sprite.Offset = self.Offset
                end
            end
        end

        local lindex = StageAPI.GetCurrentRoomID()
        if not StageAPI.CustomGrids[lindex] then
            StageAPI.CustomGrids[lindex] = {}
        end

        if not StageAPI.CustomGrids[lindex][self.Name] then
            StageAPI.CustomGrids[lindex][self.Name] = {}
        end

        if not StageAPI.CustomGrids[lindex][self.Name][grindex] then
            StageAPI.CustomGrids[lindex][self.Name][grindex] = startPersistData or {}
        end

        StageAPI.CustomGridIndices[grindex] = true

        for _, callback in ipairs(StageAPI.GetCallbacks("POST_SPAWN_CUSTOM_GRID")) do
            if not callback.Params[1] or callback.Params[1] == self.Name then
                callback.Function(grindex, force, reSpawning, grid, StageAPI.CustomGrids[lindex][self.Name][grindex], self)
            end
        end

        return grid
    end

    function StageAPI.GetCustomGridIndicesByName(name)
        local lindex = StageAPI.GetCurrentRoomID()
        if StageAPI.CustomGrids[lindex] and StageAPI.CustomGrids[lindex][name] then
            local ret = {}
            for grindex, exists in pairs(StageAPI.CustomGrids[lindex][name]) do
                ret[#ret + 1] = grindex
            end

            return ret
        end

        return {}
    end

    function StageAPI.GetCustomGridsByName(name)
        local lindex = StageAPI.GetCurrentRoomID()
        if StageAPI.CustomGrids[lindex] and StageAPI.CustomGrids[lindex][name] then
            local ret = {}
            for grindex, persistData in pairs(StageAPI.CustomGrids[lindex][name]) do
                ret[#ret + 1] = {
                    Name = name,
                    PersistData = persistData,
                    Data = StageAPI.CustomGridTypes[name],
                    Index = grindex
                }
            end

            return ret
        end

        return {}
    end

    function StageAPI.GetCustomGrids()
        local lindex = StageAPI.GetCurrentRoomID()
        if StageAPI.CustomGrids[lindex] then
            local ret = {}
            for name, grindices in pairs(StageAPI.CustomGrids[lindex]) do
                for grindex, persistData in pairs(grindices) do
                    ret[#ret + 1] = {
                        Name = name,
                        PersistData = persistData,
                        Data = StageAPI.CustomGridTypes[name],
                        Index = grindex
                    }
                end
            end

            return ret
        end

        return {}
    end

    function StageAPI.GetCustomGrid(index, name)
        local lindex = StageAPI.GetCurrentRoomID()
        if StageAPI.CustomGrids[lindex] and StageAPI.CustomGrids[lindex][name] and StageAPI.CustomGrids[lindex][name][index] then
            return {
                Name = name,
                PersistData = StageAPI.CustomGrids[lindex][name][index],
                Data = StageAPI.CustomGridTypes[name],
                Index = index
            }
        end
    end

    function StageAPI.IsCustomGrid(index, name)
        if not name then
            return StageAPI.CustomGridIndices[index]
        else
            local lindex = StageAPI.GetCurrentRoomID()
            return StageAPI.CustomGrids[lindex] and StageAPI.CustomGrids[lindex][name] and not not StageAPI.CustomGrids[lindex][name][index]
        end
    end

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        local lindex = StageAPI.GetCurrentRoomID()
        if StageAPI.CustomGrids[lindex] then
            for name, grindices in pairs(StageAPI.CustomGrids[lindex]) do
                local customGridType = StageAPI.CustomGridTypes[name]
                for grindex, persistData in pairs(grindices) do
                    local grid = room:GetGridEntity(grindex)
                    if not grid and customGridType.BaseType then
                        grindices[grindex] = nil
                    else
                        local callbacks = StageAPI.GetCallbacks("POST_CUSTOM_GRID_UPDATE")
                        for _, callback in ipairs(callbacks) do
                            if not callback.Params[1] or callback.Params[1] == name then
                                callback.Function(grid, grindex, persistData, StageAPI.CustomGridTypes[name], name)
                            end
                        end
                    end
                end
            end
        end
    end)
end

do -- Extra Rooms
    StageAPI.InExtraRoom = false
    StageAPI.LoadedExtraRoom = false
    StageAPI.CurrentExtraRoom = nil
    StageAPI.CurrentExtraRoomName = nil
    function StageAPI.SetExtraRoom(name, room)
        StageAPI.LevelRooms[name] = room
    end

    function StageAPI.GetExtraRoom(name)
        return StageAPI.LevelRooms[name]
    end

    function StageAPI.InOrTransitioningToExtraRoom()
        return StageAPI.TransitionTimer or StageAPI.InExtraRoom
    end

    function StageAPI.TransitioningToOrFromExtraRoom()
        return not not StageAPI.TransitionTimer
    end

    function StageAPI.TransitioningToExtraRoom()
        return StageAPI.TransitioningToOrFromExtraRoom() and StageAPI.TransitionToExtra
    end

    function StageAPI.TransitioningFromExtraRoom()
        return StageAPI.TransitioningToOrFromExtraRoom() and not StageAPI.TransitionToExtra
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

    StageAPI.TransitionFadeTime = 30

    StageAPI.TransitionTimer = nil
    StageAPI.TransitioningTo = nil
    StageAPI.TransitioningFromTo = nil
    StageAPI.TransitionExitSlot = nil
    StageAPI.TransitionToExtra = nil
    function StageAPI.TransitionToExtraRoom(name, exitSlot)
        StageAPI.TransitionTimer = 0
        StageAPI.TransitioningTo = name
        StageAPI.TransitionExitSlot = exitSlot
        StageAPI.TransitionToExtra = true
    end

    function StageAPI.TransitionFromExtraRoom(toIndex, exitSlot)
        StageAPI.TransitionTimer = 0
        StageAPI.TransitioningFromTo = toIndex
        StageAPI.TransitionExitSlot = exitSlot
        StageAPI.TransitionToExtra = false
    end

    StageAPI.RoomShapeToGotoID = {
        [RoomShape.ROOMSHAPE_1x1] = "4550",
        [RoomShape.ROOMSHAPE_IH] = "4551",
        [RoomShape.ROOMSHAPE_IV] = "4552",
        [RoomShape.ROOMSHAPE_1x2] = "4553",
        [RoomShape.ROOMSHAPE_IIV] = "4554",
        [RoomShape.ROOMSHAPE_2x1] = "4555",
        [RoomShape.ROOMSHAPE_IIH] = "4556",
        [RoomShape.ROOMSHAPE_2x2] = "4557",
        [RoomShape.ROOMSHAPE_LTL] = "4558",
        [RoomShape.ROOMSHAPE_LTR] = "4559",
        [RoomShape.ROOMSHAPE_LBL] = "4560",
        [RoomShape.ROOMSHAPE_LBR] = "4561"
    }

    local shadowSprite = Sprite()
    shadowSprite:Load("stageapi/stage_shadow.anm2", false)
    shadowSprite:Play("1x1", true)
    local lastUsedShadowSpritesheet

    StageAPI.StoredExtraRoomThisPause = false

    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not game:IsPaused() then
            StageAPI.StoredExtraRoomThisPause = false
            if StageAPI.TransitioningTo or StageAPI.TransitioningFromTo then
                StageAPI.TransitionTimer = StageAPI.TransitionTimer + 1
                if StageAPI.TransitionTimer == StageAPI.TransitionFadeTime then
                    if StageAPI.CurrentExtraRoom then
                        StageAPI.CurrentExtraRoom:SaveGridInformation()
                        StageAPI.CurrentExtraRoom:SavePersistentEntities()
                    end

                    if StageAPI.TransitioningTo then
                        if not StageAPI.InExtraRoom then
                            StageAPI.LastNonExtraRoom = level:GetCurrentRoomIndex()
                        end

                        local extraRoom = StageAPI.GetExtraRoom(StageAPI.TransitioningTo)
                        local id = StageAPI.RoomShapeToGotoID[extraRoom.Shape]
                        StageAPI.InExtraRoom = true
                        StageAPI.CurrentExtraRoom = extraRoom
                        StageAPI.CurrentExtraRoomName = StageAPI.TransitioningTo
                        StageAPI.TransitioningTo = nil
                        Isaac.ExecuteCommand("goto s.barren." .. id)
                    elseif StageAPI.TransitioningFromTo then
                        StageAPI.InExtraRoom = nil
                        StageAPI.CurrentExtraRoom = nil
                        StageAPI.CurrentExtraRoomName = nil
                        game:StartRoomTransition(StageAPI.TransitioningFromTo, Direction.NO_DIRECTION, 0)
                        StageAPI.TransitioningFromTo = nil
                    end

                    StageAPI.LoadedExtraRoom = false
                end
            elseif StageAPI.TransitionTimer then
                StageAPI.TransitionTimer = StageAPI.TransitionTimer - 1
                if StageAPI.TransitionTimer <= 0 then
                    StageAPI.TransitionTimer = nil
                    StageAPI.TransitionToExtra = nil
                end
            end
        elseif StageAPI.LoadedExtraRoom and not StageAPI.StoredExtraRoomThisPause then
            StageAPI.StoredExtraRoomThisPause = true
            StageAPI.CurrentExtraRoom:SaveGridInformation()
            StageAPI.CurrentExtraRoom:SavePersistentEntities()
        end

        if not StageAPI.IsHUDAnimationPlaying() then
            if not StageAPI.InNewStage() then
                local btype, stage, stype = room:GetBackdropType(), level:GetStage(), level:GetStageType()
                if (btype == 10 or btype == 11) and (stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2) then
                    for _, overlay in ipairs(StageAPI.UteroOverlays) do
                        overlay:Render()
                    end
                elseif (btype == 7 or btype == 8 or btype == 16) and (stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2 or stage == LevelStage.STAGE6) then
                    for _, overlay in ipairs(StageAPI.NecropolisOverlays) do
                        overlay:Render()
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

                shadowSprite:Render(Isaac.WorldToScreen(shadow.Position), zeroVector, zeroVector)
            end
        end

        StageAPI.CallCallbacks("PRE_TRANSITION_RENDER")
        if StageAPI.TransitionTimer then
            for _, player in ipairs(players) do
                player.ControlsCooldown = 2
            end

            StageAPI.RenderBlackScreen(StageAPI.TransitionTimer / StageAPI.TransitionFadeTime)
        end
    end)

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
        [Direction.DOWN] = Vector(0, -15),
        [Direction.UP] = Vector(0, 15),
        [Direction.LEFT] = Vector(15, 0),
        [Direction.RIGHT] = Vector(-15, 0)
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

    function StageAPI.SpawnCustomDoor(slot, leadsToExtra, leadsToNormal, doorDataName, data, exitSlot)
        local index = room:GetGridIndex(room:GetDoorSlotPosition(slot))
        StageAPI.CustomDoorGrid:Spawn(index, nil, false, {
            Slot = slot,
            ExitSlot = exitSlot or (slot + 2) % 4,
            LeadsToExtra = leadsToExtra,
            LeadsToNormal = leadsToNormal,
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
        door.Visible = false
        local data, sprite = door:GetData(), door:GetSprite()
        sprite:Load(doorData.Anm2, true)

        door.RenderZOffset = -10000
        sprite.Rotation = persistData.Slot * 90 - 90
        sprite.Offset = StageAPI.DoorOffsetsByDirection[StageAPI.DoorToDirection[persistData.Slot]]

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

    StageAPI.AddCallback("StageAPI", "PRE_SHADING_RENDER", 0, function(shading)
        for _, door in ipairs(Isaac.FindByType(StageAPI.E.Door.T, StageAPI.E.Door.V, -1, false, false)) do
            door:GetSprite():Render(Isaac.WorldToScreen(door.Position), zeroVector, zeroVector)
        end
    end)

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
                if data.DoorGridData.LeadsToExtra then
                    transitionStarted = true
                    StageAPI.TransitionToExtraRoom(data.DoorGridData.LeadsToExtra, data.DoorGridData.ExitSlot)
                elseif data.DoorGridData.LeadsToNormal then
                    transitionStarted = true
                    StageAPI.TransitionFromExtraRoom(data.DoorGridData.LeadsToNormal, data.DoorGridData.ExitSlot)
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
            StageAPI.Log("Had no door data for " .. tostring(framesWithoutDoorData) .. " frames")
            framesWithoutDoorData = 0
        end
    end)
end

Isaac.DebugString("[StageAPI] Loading GridGfx Handler")
do -- GridGfx
    StageAPI.GridGfx = StageAPI.Class("GridGfx")
    function StageAPI.GridGfx:Init()
        self.Grids = false
        self.Doors = false
    end

    function StageAPI.GridGfx:SetRocks(filename)
        self.Rocks = filename
    end

    function StageAPI.GridGfx:SetGrid(filename, t, v)
        if not self.Grids then
            self.Grids = {}
            self.GridsByVariant = {}
        end

        if v then
            self.GridsByVariant[t] = {
                [v] = filename
            }
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

    StageAPI.RockAnimationMap = {
        "normal",
        "black",
        "tinted",
        "alt",
        "bombrock",
        "big",
        "superspecial",
        "ss_broken"
    }

    StageAPI.GridGfxRNG = RNG()

    StageAPI.RockSprite = Sprite()
    StageAPI.RockSprite:Load("gfx/grid/grid_rock.anm2", true)
    function StageAPI.ChangeRock(rock, filename)
        local grid = rock.Grid:ToRock()

        for i = 0, 4 do
            StageAPI.RockSprite:ReplaceSpritesheet(i, filename)
        end

        StageAPI.RockSprite:LoadGraphics()

        grid.Sprite = StageAPI.RockSprite
        grid.Sprite:Play(grid.Anim, true)
        grid:UpdateAnimFrame()
    end

    StageAPI.BridgeEntities = {}
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        StageAPI.BridgeEntities = {}
    end)

    StageAPI.BridgeOffset = Vector(3, 3)

    function StageAPI.CheckBridge(grid, index, bridgefilename)
        if grid.State == 1 and bridgefilename and not StageAPI.BridgeEntities[index] then
            local bridge = Isaac.Spawn(StageAPI.E.Bridge.T, StageAPI.E.Bridge.V, 0, room:GetGridPosition(index), zeroVector, nil)
            local sprite = bridge:GetSprite()
            sprite:Load("stageapi/bridge.anm2", false)
            sprite:ReplaceSpritesheet(0, bridgefilename)
            sprite:LoadGraphics()
            sprite:Play("Idle", true)

            bridge:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
            bridge.SpriteOffset = StageAPI.BridgeOffset
            bridge.RenderZOffset = -10000
            StageAPI.BridgeEntities[index] = bridge
        end
    end

    StageAPI.PitSprite = Sprite()
    StageAPI.PitSprite:Load("stageapi/pit.anm2", true)
    function StageAPI.ChangePit(pit, pitFile, bridgefilename, alt)
        local grid = pit.Grid

        if alt and room:HasWaterPits() then
            StageAPI.PitSprite:ReplaceSpritesheet(0, alt.File)
        else
            StageAPI.PitSprite:ReplaceSpritesheet(0, pitFile.File)
        end

        StageAPI.PitSprite:LoadGraphics()

        grid.Sprite = StageAPI.PitSprite

        StageAPI.CheckBridge(grid, pit.Index, bridgefilename)
    end

    StageAPI.DecorationSprites = {}
    function StageAPI.ChangeDecoration(decoration, decorations)
        local grid = decoration.Grid

        local decSprite = StageAPI.DecorationSprites[decorations.Anm2]
        if not decSprite then
            decSprite = Sprite()
            decSprite:Load(decorations.Anm2, false)
            StageAPI.DecorationSprites[decorations.Anm2] = decSprite
        end

        decSprite:ReplaceSpritesheet(0, decorations.Png)
        decSprite:LoadGraphics()
        local prop = StageAPI.Random(1, decorations.PropCount, StageAPI.GridGfxRNG)
        if prop < 10 then
            prop = "0" .. tostring(prop)
        end

        decSprite:Play(decorations.Prefix .. tostring(prop) .. decorations.Suffix, true)
        grid.Sprite = decSprite
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
        local current = grid.CurrentRoomType
        local target = grid.TargetRoomType
        local isPayToPlay = grid:IsTargetRoomArcade() and target ~= RoomType.ROOM_ARCADE

        if isPayToPlay then
            if payToPlay then
                local sprite = grid.Sprite
                for i = 0, 5 do
                    sprite:ReplaceSpritesheet(i, payToPlay)
                end

                sprite:LoadGraphics()

                grid.Sprite = sprite
            end

            return
        end

        for _, doorOption in ipairs(doors) do
            if StageAPI.DoesDoorMatch(grid, doorOption, current, target, hasBossAmbushDoor) then
                local sprite = grid.Sprite
                for i = 0, 5 do
                    sprite:ReplaceSpritesheet(i, doorOption.File)
                end

                sprite:LoadGraphics()

                grid.Sprite = sprite

                break
            end
        end
    end

    function StageAPI.ChangeGrid(sent, filename)
        local grid = sent.Grid
        local sprite = grid.Sprite

        if type(filename) == "table" then
            filename = filename[StageAPI.Random(1, #filename, StageAPI.GridGfxRNG)]
        end

        sprite:ReplaceSpritesheet(0, filename)
        sprite:LoadGraphics()
        grid.Sprite = sprite
    end

    function StageAPI.ChangeSingleGrid(grid, grids, i)
        local desc = grid.Desc
        local gtype = desc.Type
        local send = {Grid = grid, Index = i, Type = gtype, Desc = desc}
        if gtype == GridEntityType.GRID_DOOR and grids.Doors then
            StageAPI.ChangeDoor(send, grids.Doors, grids.PayToPlayDoor, grids.HasBossAmbushDoor)
        elseif grid:ToRock() and grids.Rocks then
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
        local hasExtraPitFrames = pitsToUse and pitsToUse.HasExtraPitFrames

        local gridCount = 0
        local pits = {}
        for i = 0, room:GetGridSize() do
            if not StageAPI.CustomGridIndices[i] then
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
                local sprite = pit.Sprite

                local adj = {index - 1, index + 1, index - width, index + width, index - width - 1, index + width - 1, index - width + 1, index + width + 1}
                local adjPits = {}
                for _, ind in ipairs(adj) do
                    local grid = room:GetGridEntity(ind)
                    if grid and grid.Desc.Type == GridEntityType.GRID_PIT then
                        adjPits[#adjPits + 1] = true
                    else
                        adjPits[#adjPits + 1] = false
                    end
                end

                adjPits[#adjPits + 1] = true
                sprite:SetFrame("pit", StageAPI.GetPitFrame(table.unpack(adjPits)))
                pit.Sprite = sprite
            end
        end
    end
end

Isaac.DebugString("[StageAPI] Loading Backdrop & RoomGfx Handling")
do -- Backdrop & RoomGfx
    StageAPI.BackdropRNG = RNG()
    local backdropDefaultOffset = Vector(260,0)
    local backdropIvOffset = Vector(113,0)
    local lRooms = {
        RoomShape.ROOMSHAPE_LTL,
        RoomShape.ROOMSHAPE_LTR,
        RoomShape.ROOMSHAPE_LBL,
        RoomShape.ROOMSHAPE_LBR
    }

    for _, roomsh in ipairs(lRooms) do
        lRooms[roomsh] = true
    end

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

    function StageAPI.ChangeBackdrop(backdrop)
        StageAPI.BackdropRNG:SetSeed(room:GetDecorationSeed(), 1)
        local needsExtra
        for i = 1, 3 do
            if i == 3 and not needsExtra then
                break
            end

            local roomShape = room:GetRoomShape()
            local shapeName = StageAPI.ShapeToName[roomShape]
            if StageAPI.ShapeToWallAnm2Layers[shapeName .. "X"] then
                needsExtra = true
            end

            if i == 3 then
                shapeName = shapeName .. "X"
            end

            local backdropEntity = Isaac.Spawn(StageAPI.E.Backdrop.T, StageAPI.E.Backdrop.V, 0, zeroVector, zeroVector, nil)
            local sprite = backdropEntity:GetSprite()

            if i == 1 or i == 3 then
                sprite:Load("stageapi/WallBackdrop.anm2", false)

                if backdrop.Walls then
                    for num = 1, StageAPI.ShapeToWallAnm2Layers[shapeName] do
                        local wall_to_use = backdrop.Walls[StageAPI.Random(1, #backdrop.Walls, backdropRNG)]
                        sprite:ReplaceSpritesheet(num, wall_to_use)
                    end
                end
                if backdrop.Corners and string.sub(shapeName, 1, 1) == "L" then
                    local corner_to_use = backdrop.Corners[StageAPI.Random(1, #backdrop.Corners, backdropRNG)]
                    sprite:ReplaceSpritesheet(0, corner_to_use)
                end
            else
                sprite:Load("stageapi/FloorBackdrop.anm2", false)

                local floors
                if backdrop.FloorVariants then
                    floors = backdrop.FloorVariants[StageAPI.Random(1, #backdrop.FloorVariants, backdropRNG)]
                else
                    floors = backdrop.Floors or backdrop.Walls
                end

                if floors then
                    local numWalls
                    if roomShape == RoomShape.ROOMSHAPE_1x1 then
                        numWalls = 4
                    elseif roomShape == RoomShape.ROOMSHAPE_1x2 or roomShape == RoomShape.ROOMSHAPE_2x1 then
                        numWalls = 8
                    elseif roomShape == RoomShape.ROOMSHAPE_2x2 then
                        numWalls = 16
                    end

                    if numWalls then
                        for i = 0, numWalls - 1 do
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
            if i ~= 2 then
                renderPos = renderPos - Vector(80, 80)
            end

            sprite:Play(shapeName, true)

            backdropEntity.Position = renderPos
            if i == 1 or i == 3 then
                backdropEntity:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL)
            else
                backdropEntity:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
            end
        end
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
        local shading = Isaac.FindByType(StageAPI.E.Shading.T, StageAPI.E.Shading.V, -1, false, false)
        for _, e in ipairs(shading) do
            e:Remove()
        end

        local shadingEntity = Isaac.Spawn(StageAPI.E.Shading.T, StageAPI.E.Shading.V, 0, zeroVector, zeroVector, nil)
        local roomShape = room:GetRoomShape()

        local topLeft = room:GetTopLeftPos()
        local renderPos = topLeft + shadingDefaultOffset
        local sheet

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
        elseif roomShape == RoomShape.ROOMSHAPE_LBL then sheet = "_lbl"
        elseif roomShape == RoomShape.ROOMSHAPE_LBR then sheet = "_lbr"
        elseif roomShape == RoomShape.ROOMSHAPE_LTL then sheet = "_ltl"
        elseif roomShape == RoomShape.ROOMSHAPE_LTR then sheet = "_ltr"
        end

        sheet = prefix .. sheet .. name .. ".png"

        --[[
        local sprite = shadingEntity:GetSprite()
        sprite:Load("stageapi/Shading.anm2", false)
        sprite:ReplaceSpritesheet(0, sheet)
        sprite:LoadGraphics()
        sprite:Play("Default", true)]]

        shadingEntity:GetData().Sheet = sheet
        shadingEntity.Position = renderPos
        shadingEntity:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
    end

    local shadingSprite = Sprite()
    shadingSprite:Load("stageapi/Shading.anm2", false)
    shadingSprite:Play("Default", true)
    local lastUsedShadingSpritesheet
    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, eff)
        StageAPI.CallCallbacks("PRE_SHADING_RENDER", false, eff)

        local sheet = eff:GetData().Sheet
        if sheet and sheet ~= lastUsedShadingSpritesheet then
            shadingSprite:ReplaceSpritesheet(0, sheet)
            shadingSprite:LoadGraphics()
            lastUsedShadingSpritesheet = sheet
        end

        shadingSprite:Render(Isaac.WorldToScreen(eff.Position), zeroVector, zeroVector)
        StageAPI.CallCallbacks("POST_SHADING_RENDER", false, eff)
    end, StageAPI.E.Shading.V)

    function StageAPI.ChangeRoomGfx(roomgfx)
        StageAPI.BackdropRNG:SetSeed(room:GetDecorationSeed(), 0)
        if roomgfx.Backdrops then
            if #roomgfx.Backdrops > 0 then
                local backdrop = StageAPI.Random(1, #roomgfx.Backdrops, StageAPI.BackdropRNG)
                StageAPI.ChangeBackdrop(roomgfx.Backdrops[backdrop])
            else
                StageAPI.ChangeBackdrop(roomgfx.Backdrops)
            end
        end

        if roomgfx.Grids then
            StageAPI.ChangeGrids(roomgfx.Grids)
        end

        if roomgfx.Shading and roomgfx.Shading.Name then
            StageAPI.ChangeShading(roomgfx.Shading.Name, roomgfx.Shading.Prefix)
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
end

Isaac.DebugString("[StageAPI] Loading CustomStage Handler")
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
        self:SetMusic(music, {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE})
    end

    function StageAPI.CustomStage:SetTransitionMusic(music)
        self.TransitionMusic = music
    end

    function StageAPI.CustomStage:SetBossMusic(music, clearedMusic, intro, outro)
        self.BossMusic = {
            Fight = music,
            Cleared = clearedMusic,
            Intro = intro,
            Outro = outro
        }
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
        for _, bossID in ipairs(bosses) do
            local boss = StageAPI.GetBossData(bossID)
            if not boss.Shapes then
                boss.Shapes = {}
                for shape, rooms in pairs(boss.Rooms.ByShape) do
                    boss.Shapes[#boss.Shapes + 1] = shape
                end
            end

            if not boss.Weight then
                boss.Weight = 1
            end

            if boss.Horseman then
                bosses.HasHorseman = true
            end
        end

        self.Bosses = bosses
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
        else
            local music = self.Music
            if music then
                local musicID = music[roomType]
                local newMusicID = StageAPI.CallCallbacks("POST_SELECT_STAGE_MUSIC", true, self, musicID, roomType, StageAPI.MusicRNG)
                if newMusicID then
                    musicID = newMusicID
                end

                if musicID and id ~= self.TransitionMusic then
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

    function StageAPI.CustomStage:IsStage(noAlias)
        if StageAPI.CurrentStage then
            local matches = StageAPI.CurrentStage.Name == self.Name
            if not matches and not noAlias then
                matches = StageAPI.CurrentStage.Alias == self.Alias
            end

            return matches
        end

        return false
    end

    function StageAPI.CustomStage:SetRequireRoomTypeMatching()
        self.RequireRoomTypeMatching = true
    end

    function StageAPI.CustomStage:SetRequireRoomTypeBoss()
        self.RequireRoomTypeBoss = true
    end

    function StageAPI.ShouldPlayStageMusic()
        return room:GetType() == RoomType.ROOM_DEFAULT or room:GetType() == RoomType.ROOM_TREASURE, not room:IsClear()
    end
end

Isaac.DebugString("[StageAPI] Loading Stage Override Definitions")
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

    StageAPI.CatacombsGridGfx = StageAPI.GridGfx()
    StageAPI.CatacombsGridGfx:SetRocks("gfx/grid/rocks_catacombs.png")
    StageAPI.CatacombsGridGfx:SetPits("gfx/grid/grid_pit_catacombs.png", "gfx/grid/grid_pit_water_catacombs.png")
    StageAPI.CatacombsGridGfx:SetBridges("stageapi/floors/catacombs/grid_bridge_catacombs.png")
    StageAPI.CatacombsGridGfx:SetDecorations("gfx/grid/props_03_caves.png")

    StageAPI.CatacombsFloors = {
        {"Catacombs1_1", "Catacombs1_2"},
        {"Catacombs2_1", "Catacombs2_2"},
        {"CatacombsExtraFloor_1", "CatacombsExtraFloor_2"}
    }

    StageAPI.CatacombsBackdrop = {
        {
            Walls = {"Catacombs1_1", "Catacombs1_2"},
            FloorVariants = StageAPI.CatacombsFloors,
            NFloors = {"Catacombs_nfloor"},
            LFloors = {"Catacombs_lfloor"},
            Corners = {"Catacombs1_corner"}
        },
        {
            Walls = {"Catacombs2_1", "Catacombs2_2"},
            FloorVariants = StageAPI.CatacombsFloors,
            NFloors = {"Catacombs_nfloor"},
            LFloors = {"Catacombs_lfloor"},
            Corners = {"Catacombs2_corner"}
        }
    }

    StageAPI.CatacombsBackdrop = StageAPI.BackdropHelper(StageAPI.CatacombsBackdrop, "stageapi/floors/catacombs/", ".png")
    StageAPI.CatacombsRoomGfx = StageAPI.RoomGfx(--[[StageAPI.CatacombsBackdrop]] nil, StageAPI.CatacombsGridGfx, "_default")
    StageAPI.CatacombsMusicID = Isaac.GetMusicIdByName("Catacombs")
    StageAPI.Catacombs = StageAPI.CustomStage("Catacombs", nil, true)
    StageAPI.Catacombs:SetStageMusic(StageAPI.CatacombsMusicID)
    StageAPI.Catacombs:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)
    StageAPI.Catacombs:SetRoomGfx(StageAPI.CatacombsRoomGfx, {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})
    StageAPI.Catacombs.DisplayName = "Catacombs I"

    StageAPI.CatacombsTwo = StageAPI.Catacombs("Catacombs 2")
    StageAPI.CatacombsTwo.DisplayName = "Catacombs II"

    StageAPI.CatacombsXL = StageAPI.Catacombs("Catacombs XL")
    StageAPI.CatacombsXL.DisplayName = "Catacombs XL"
    StageAPI.Catacombs:SetXLStage(StageAPI.CatacombsXL)

    StageAPI.NecropolisGridGfx = StageAPI.GridGfx()
    StageAPI.NecropolisGridGfx:SetRocks("gfx/grid/rocks_depths.png")
    StageAPI.NecropolisGridGfx:SetPits("gfx/grid/grid_pit_necropolis.png")
    StageAPI.NecropolisGridGfx:SetBridges("stageapi/floors/necropolis/grid_bridge_necropolis.png")
    StageAPI.NecropolisGridGfx:SetDecorations("gfx/grid/props_05_depths.png", "gfx/grid/props_05_depths.anm2", 43)

    StageAPI.NecropolisBackdrop = {
        {
            Walls = {"necropolis1_1"},
            NFloors = {"necropolis_nfloor1", "necropolis_nfloor2"},
            LFloors = {"necropolis_lfloor"},
            Corners = {"necropolis1_corner"}
        }
    }

    StageAPI.NecropolisOverlays = {
        StageAPI.Overlay("stageapi/floors/necropolis/overlay.anm2", Vector(0.66, 0.66)),
        StageAPI.Overlay("stageapi/floors/necropolis/overlay.anm2", Vector(-0.66, 0.66))
    }

    StageAPI.NecropolisBackdrop = StageAPI.BackdropHelper(StageAPI.NecropolisBackdrop, "stageapi/floors/necropolis/", ".png")
    StageAPI.NecropolisRoomGfx = StageAPI.RoomGfx(--[[StageAPI.NecropolisBackdrop]] nil, StageAPI.NecropolisGridGfx, "_default")
    StageAPI.NecropolisMusicID = Isaac.GetMusicIdByName("Necropolis")
    StageAPI.Necropolis = StageAPI.CustomStage("Necropolis", nil, true)
    StageAPI.Necropolis:SetStageMusic(StageAPI.NecropolisMusicID)
    StageAPI.Necropolis:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)
    StageAPI.Necropolis:SetRoomGfx(StageAPI.NecropolisRoomGfx, {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})
    StageAPI.Necropolis.DisplayName = "Necropolis I"

    StageAPI.NecropolisTwo = StageAPI.Necropolis("Necropolis 2")
    StageAPI.NecropolisTwo.DisplayName = "Necropolis II"

    StageAPI.NecropolisXL = StageAPI.Necropolis("Necropolis XL")
    StageAPI.NecropolisXL.DisplayName = "Necropolis XL"
    StageAPI.Necropolis:SetXLStage(StageAPI.NecropolisXL)

    StageAPI.UteroGridGfx = StageAPI.GridGfx()
    StageAPI.UteroGridGfx:SetRocks("gfx/grid/rocks_womb.png")
    StageAPI.UteroGridGfx:SetPits("gfx/grid/grid_pit_womb.png", {
        { File = "gfx/grid/grid_pit_blood_womb.png" },
        { File = "gfx/grid/grid_pit_acid_womb.png" },
    })
    StageAPI.UteroGridGfx:SetBridges("stageapi/floors/utero/grid_bridge_womb.png")
    StageAPI.UteroGridGfx:SetDecorations("gfx/grid/props_07_the womb.png", "gfx/grid/props_07_the womb.anm2", 43)

    StageAPI.UteroBackdrop = {
        {
            Walls = {"utero1_1", "utero1_2", "utero1_3", "utero1_4"},
            NFloors = {"utero_nfloor"},
            LFloors = {"utero_lfloor"},
            Corners = {"utero1_corner"}
        }
    }

    StageAPI.UteroOverlays = {
        StageAPI.Overlay("stageapi/floors/utero/overlay.anm2", Vector(0.66, 0.66)),
        StageAPI.Overlay("stageapi/floors/utero/overlay.anm2", Vector(-0.66, 0.66))
    }

    StageAPI.UteroBackdrop = StageAPI.BackdropHelper(StageAPI.UteroBackdrop, "stageapi/floors/utero/", ".png")
    StageAPI.UteroRoomGfx = StageAPI.RoomGfx(--[[StageAPI.UteroBackdrop]] nil, StageAPI.UteroGridGfx, "_default")
    StageAPI.UteroMusicID = Isaac.GetMusicIdByName("Womb/Utero")
    StageAPI.Utero = StageAPI.CustomStage("Utero", nil, true)
    StageAPI.Utero:SetStageMusic(StageAPI.UteroMusicID)
    StageAPI.Utero:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)
    StageAPI.Utero:SetRoomGfx(StageAPI.UteroRoomGfx, {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})
    StageAPI.Utero.DisplayName = "Utero I"

    StageAPI.UteroTwo = StageAPI.Utero("Utero 2")
    StageAPI.UteroTwo.DisplayName = "Utero II"

    StageAPI.UteroXL = StageAPI.Utero("Utero XL")
    StageAPI.UteroXL.DisplayName = "Utero XL"
    StageAPI.Utero:SetXLStage(StageAPI.UteroXL)

    StageAPI.StageOverride = {
        CatacombsOne = {
            OverrideStage = LevelStage.STAGE2_1,
            OverrideStageType = StageType.STAGETYPE_WOTL,
            ReplaceWith = StageAPI.Catacombs
        },
        CatacombsTwo = {
            OverrideStage = LevelStage.STAGE2_2,
            OverrideStageType = StageType.STAGETYPE_WOTL,
            ReplaceWith = StageAPI.CatacombsTwo
        },
        NecropolisOne = {
            OverrideStage = LevelStage.STAGE3_1,
            OverrideStageType = StageType.STAGETYPE_WOTL,
            ReplaceWith = StageAPI.Necropolis
        },
        NecropolisTwo = {
            OverrideStage = LevelStage.STAGE3_2,
            OverrideStageType = StageType.STAGETYPE_WOTL,
            ReplaceWith = StageAPI.NecropolisTwo
        },
        UteroOne = {
            OverrideStage = LevelStage.STAGE4_1,
            OverrideStageType = StageType.STAGETYPE_WOTL,
            ReplaceWith = StageAPI.Utero
        },
        UteroTwo = {
            OverrideStage = LevelStage.STAGE4_2,
            OverrideStageType = StageType.STAGETYPE_WOTL,
            ReplaceWith = StageAPI.UteroTwo
        }
    }

    StageAPI.Catacombs:SetReplace(StageAPI.StageOverride.CatacombsOne)
    StageAPI.CatacombsTwo:SetReplace(StageAPI.StageOverride.CatacombsTwo)

    StageAPI.Necropolis:SetReplace(StageAPI.StageOverride.NecropolisOne)
    StageAPI.NecropolisTwo:SetReplace(StageAPI.StageOverride.NecropolisTwo)

    StageAPI.Utero:SetReplace(StageAPI.StageOverride.UteroOne)
    StageAPI.UteroTwo:SetReplace(StageAPI.StageOverride.UteroTwo)

    function StageAPI.InOverriddenStage()
        for name, override in pairs(StageAPI.StageOverride) do
            local isStage = level:GetStage() == override.OverrideStage and
                            level:GetStageType() == override.OverrideStageType
            if isStage then
                return true, override, name
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

    function StageAPI.GetCurrentStageDisplayName()
        if StageAPI.CurrentStage then
            return StageAPI.CurrentStage.DisplayName or StageAPI.CurrentStage.Name
        end
    end

    function StageAPI.GetCurrentListIndex()
        return level:GetCurrentRoomDesc().ListIndex
    end
end

Isaac.DebugString("[StageAPI] Loading Boss Handler")
do -- Bosses
    StageAPI.FloorInfo = {
        [LevelStage.STAGE1_1] = {
            [StageType.STAGETYPE_ORIGINAL] = "01_basement",
            [StageType.STAGETYPE_WOTL] = "02_cellar",
            [StageType.STAGETYPE_AFTERBIRTH] = "13_burning_basement",
            [StageType.STAGETYPE_GREEDMODE] = "01_basement"
        },
        [LevelStage.STAGE2_1] = {
            [StageType.STAGETYPE_ORIGINAL] = "03_caves",
            [StageType.STAGETYPE_WOTL] = "04_catacombs",
            [StageType.STAGETYPE_AFTERBIRTH] = "14_drowned_caves",
            [StageType.STAGETYPE_GREEDMODE] = "03_caves"
        },
        [LevelStage.STAGE3_1] = {
            [StageType.STAGETYPE_ORIGINAL] = "05_depths",
            [StageType.STAGETYPE_WOTL] = "06_necropolis",
            [StageType.STAGETYPE_AFTERBIRTH] = "15_dank_depths",
            [StageType.STAGETYPE_GREEDMODE] = "05_depths"
        },
        [LevelStage.STAGE4_1] = {
            [StageType.STAGETYPE_ORIGINAL] = "07_womb",
            [StageType.STAGETYPE_WOTL] = "07_womb",
            [StageType.STAGETYPE_AFTERBIRTH] = "16_scarred_womb",
            [StageType.STAGETYPE_GREEDMODE] = "07_womb"
        },
        [LevelStage.STAGE4_3] = {
            [StageType.STAGETYPE_ORIGINAL] = "17_blue_womb",
            [StageType.STAGETYPE_WOTL] = "17_blue_womb",
            [StageType.STAGETYPE_AFTERBIRTH] = "17_blue_womb",
            [StageType.STAGETYPE_GREEDMODE] = "17_blue_womb"
        },
        [LevelStage.STAGE5] = {
            [StageType.STAGETYPE_ORIGINAL] = "09_sheol",
            [StageType.STAGETYPE_WOTL] = "10_cathedral",
            [StageType.STAGETYPE_AFTERBIRTH] = "09_sheol",
            [StageType.STAGETYPE_GREEDMODE] = "09_sheol"
        },
        [LevelStage.STAGE6] = {
            [StageType.STAGETYPE_ORIGINAL] = "11_darkroom",
            [StageType.STAGETYPE_WOTL] = "12_chest",
            [StageType.STAGETYPE_AFTERBIRTH] = "11_darkroom",
            [StageType.STAGETYPE_GREEDMODE] = "18_shop"
        },
        [LevelStage.STAGE7] = {
            [StageType.STAGETYPE_ORIGINAL] = "19_void",
            [StageType.STAGETYPE_WOTL] = "19_void",
            [StageType.STAGETYPE_AFTERBIRTH] = "19_void",
            [StageType.STAGETYPE_GREEDMODE] = "18_shop"
        }
    }

    StageAPI.FloorInfo[LevelStage.STAGE1_2] = StageAPI.FloorInfo[LevelStage.STAGE1_1]
    StageAPI.FloorInfo[LevelStage.STAGE2_2] = StageAPI.FloorInfo[LevelStage.STAGE2_1]
    StageAPI.FloorInfo[LevelStage.STAGE3_2] = StageAPI.FloorInfo[LevelStage.STAGE3_1]
    StageAPI.FloorInfo[LevelStage.STAGE4_2] = StageAPI.FloorInfo[LevelStage.STAGE4_1]

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
        thesoul = "16"
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
    StageAPI.PlayerBossInfo.thelost.NoShake = true

    function StageAPI.AddPlayerGraphicsInfo(name, portrait, namefile, portraitbig, noshake)
        StageAPI.PlayerBossInfo[string.gsub(string.lower(name), "%s+", "")] = {
            Portrait = portrait,
            Name = namefile,
            PortraitBig = portraitbig,
            NoShake = noshake
        }
    end

    StageAPI.AddPlayerGraphicsInfo("Black Judas", "gfx/ui/boss/playerportrait_blackjudas.png", "gfx/ui/boss/playername_04_judas.png", "gfx/ui/stage/playerportraitbig_blackjudas.png")
    StageAPI.AddPlayerGraphicsInfo("Lazarus", "gfx/ui/boss/playerportrait_09_lazarus.png", "gfx/ui/boss/playername_10_lazarus.png", "gfx/ui/stage/playerportraitbig_09_lazarus.png")
    StageAPI.AddPlayerGraphicsInfo("Lazarus II", "gfx/ui/boss/playerportrait_10_lazarus2.png", "gfx/ui/boss/playername_10_lazarus.png", "gfx/ui/stage/playerportraitbig_10_lazarus2.png")

    function StageAPI.GetStageSpot()
        if StageAPI.InNewStage() then
            return StageAPI.CurrentStage.BossSpot or "gfx/ui/boss/bossspot.png", StageAPI.CurrentStage.PlayerSpot or "gfx/ui/boss/playerspot.png"
        else
            local stage, stype = level:GetStage(), level:GetStageType()
            local spot = StageAPI.FloorInfo[stage][stype]
            return "gfx/ui/boss/bossspot_" .. spot .. ".png", "gfx/ui/boss/playerspot_" .. spot .. ".png"
        end
    end

    function StageAPI.TryGetPlayerGraphicsInfo(player)
        local playerName = string.gsub(string.lower(player:GetName()), "%s+", "")
        if StageAPI.PlayerBossInfo[playerName] then
            return StageAPI.PlayerBossInfo[playerName].Portrait, StageAPI.PlayerBossInfo[playerName].Name, StageAPI.PlayerBossInfo[playerName].PortraitBig, StageAPI.PlayerBossInfo[playerName].NoShake
        else -- worth a shot, most common naming convention
            return "gfx/ui/boss/playerportrait_" .. playerName .. ".png", "gfx/ui/boss/playername_" .. playerName .. ".png", "gfx/ui/stage/playerportraitbig_" .. playerName .. ".png"
        end
    end

    StageAPI.BossSprite = Sprite()
    StageAPI.BossSprite:Load("gfx/ui/boss/versusscreen.anm2", false)
    function StageAPI.PlayBossAnimationManual(portrait, name, spot, playerPortrait, playerName, playerSpot, portraitTwo)
        spot = spot or "gfx/ui/boss/bossspot.png"
        name = name or "gfx/ui/boss/bossname_20.0_monstro.png"
        portrait = portrait or "gfx/ui/boss/portrait_20.0_monstro.png"
        playerSpot = playerSpot or "gfx/ui/boss/bossspot.png"
        playerName = playerName or "gfx/ui/boss/bossname_20.0_monstro.png"
        playerPortrait = playerPortrait or "gfx/ui/boss/portrait_20.0_monstro.png"

        StageAPI.BossSprite:ReplaceSpritesheet(2, spot)
        StageAPI.BossSprite:ReplaceSpritesheet(3, playerSpot)
        StageAPI.BossSprite:ReplaceSpritesheet(4, portrait)
        StageAPI.BossSprite:ReplaceSpritesheet(5, playerPortrait)
        StageAPI.BossSprite:ReplaceSpritesheet(6, playerName)
        StageAPI.BossSprite:ReplaceSpritesheet(7, name)

        if portraitTwo then
            StageAPI.BossSprite:ReplaceSpritesheet(9, portraitTwo)
            StageAPI.BossSprite:Play("DoubleTrouble", true)
        else
            StageAPI.BossSprite:Play("Scene", true)
        end

        StageAPI.BossSprite:LoadGraphics()
    end

    StageAPI.IsOddRenderFrame = nil
    local menuConfirmTriggered
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        StageAPI.IsOddRenderFrame = not StageAPI.IsOddRenderFrame
        local isPlaying = StageAPI.BossSprite:IsPlaying("Scene") or StageAPI.BossSprite:IsPlaying("DoubleTrouble")

        if game:IsPaused() and isPlaying and not menuConfirmTriggered then
            if StageAPI.IsOddRenderFrame then
                StageAPI.BossSprite:Update()
            end

            StageAPI.BossSprite:Render(StageAPI.GetScreenCenterPosition(), zeroVector, zeroVector)
        elseif isPlaying then
            StageAPI.BossSprite:Stop()
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
        return id
    end

    function StageAPI.GetBossData(id)
        return StageAPI.Bosses[id]
    end

    StageAPI.DummyBoss = {}
    function StageAPI.PlayBossAnimation(boss)
        local bSpot, pSpot = StageAPI.GetStageSpot()
        local playerPortrait, playerName = StageAPI.TryGetPlayerGraphicsInfo(StageAPI.Players[1])
        StageAPI.PlayBossAnimationManual(boss.Portrait, boss.Bossname, boss.Spot or bSpot, playerPortrait, playerName, pSpot, boss.PortraitTwo)
    end

    local horsemanTypes = {
        EntityType.ENTITY_WAR,
        EntityType.ENTITY_FAMINE,
        EntityType.ENTITY_DEATH,
        EntityType.ENTITY_HEADLESS_HORSEMAN,
        EntityType.ENTITY_PESTILENCE
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
    function StageAPI.SelectBoss(bosses, allowHorseman, rng)
        local bossID = StageAPI.CallCallbacks("PRE_BOSS_SELECT", true, bosses, allowHorseman, rng)
        if not bossID then
            local forceHorseman = false
            if allowHorseman then
                for _, t in ipairs(horsemanTypes) do
                    if #Isaac.FindByType(t, -1, -1, false, false) > 0 then
                        forceHorseman = true
                    end
                end
            end

            local totalUnencounteredWeight = 0
            local totalValidWeight = 0
            local unencounteredBosses = {}
            local validBosses = {}
            for _, potentialBossID in ipairs(bosses) do
                local potentialBoss = StageAPI.GetBossData(potentialBossID)
                if StageAPI.IsIn(potentialBoss.Shapes, room:GetRoomShape()) then
                    local encountered = StageAPI.GetBossEncountered(potentialBoss.Name)
                    if not encountered and potentialBoss.NameTwo then
                        encountered = StageAPI.GetBossEncountered(potentialBoss.NameTwo)
                    end

                    local weight = potentialBoss.Weight or 1
                    if not encountered then
                        totalUnencounteredWeight = totalUnencounteredWeight + weight
                        unencounteredBosses[#unencounteredBosses + 1] = {potentialBossID, weight}
                    end

                    totalValidWeight = totalValidWeight + weight
                    validBosses[#validBosses + 1] = {potentialBossID, weight}
                end
            end

            if not rng then
                rng = StageAPI.BossSelectRNG
                rng:SetSeed(room:GetSpawnSeed(), 0)
            end

            if #unencounteredBosses > 0 then
                bossID = StageAPI.WeightedRNG(unencounteredBosses, rng, nil, totalUnencounteredWeight)
            elseif #validBosses > 0 then
                bossID = StageAPI.WeightedRNG(validBosses, rng, nil, totalValidWeight)
            else
                Isaac.ConsoleOutput("[StageAPI] Trying to select boss, but none are valid!!\n")
                for _, potentialBossID in ipairs(bosses) do
                    Isaac.ConsoleOutput(potentialBossID .. "\n")
                end
                Isaac.ConsoleOutput("Were the options\n")
            end
        end

        return bossID
    end
end

Isaac.DebugString("[StageAPI] Loading Transition Handler")
do -- Transition
    StageAPI.StageTypeToString = {
        [StageType.STAGETYPE_ORIGINAL] = "",
        [StageType.STAGETYPE_WOTL] = "a",
        [StageType.STAGETYPE_AFTERBIRTH] = "b"
    }

    StageAPI.StageTypes = {
        StageType.STAGETYPE_ORIGINAL,
        StageType.STAGETYPE_WOTL,
        StageType.STAGETYPE_AFTERBIRTH
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
                local name = StageAPI.CurrentStage.DisplayName or StageAPI.CurrentStage.Name
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
        return StageAPI.TransitionAnimation:IsPlaying("Scene") or StageAPI.TransitionAnimation:IsPlaying("SceneNoShake") or StageAPI.BossSprite:IsPlaying("Scene") or StageAPI.BossSprite:IsPlaying("DoubleTrouble") or (room:GetType() == RoomType.ROOM_BOSS and room:GetFrameCount() <= 0 and game:IsPaused() and not spriteOnly)
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
        local base = StageAPI.FloorInfo[stage][stype]
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
        local _, _, portraitbig, noshake = StageAPI.TryGetPlayerGraphicsInfo(players[1])
        StageAPI.PlayTransitionAnimationManual(portraitbig, stage.TransitionIcon, stage.TransitionMusic, stage.Music[RoomType.ROOM_DEFAULT], noshake)
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
            StageAPI.PreReseed = true
            local stageType = stage.StageType
            if not stageType then
                StageAPI.StageRNG:SetSeed(StageAPI.Seeds:GetStageSeed(stage.Stage), 0)
                stageType = StageAPI.StageTypes[StageAPI.Random(1, #StageAPI.StageTypes, StageAPI.StageRNG)]
            end

            if playTransition then
                local _, _, portraitbig, noshake = StageAPI.TryGetPlayerGraphicsInfo(players[1])
                StageAPI.PlayTransitionAnimationManual(portraitbig, StageAPI.GetLevelTransitionIcon(stage.Stage, stageType), nil, nil, noshake)
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

Isaac.DebugString("[StageAPI] Loading Rock Alt Breaking Override")
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

            local stateCheck = 2
            if type(StageAPI.SpawnOverriddenGrids[grindex]) == "number" then
                stateCheck = StageAPI.SpawnOverriddenGrids[grindex]
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

Isaac.DebugString("[StageAPI] Loading Core Callbacks")
do -- Callbacks
    StageAPI.NonOverrideMusic = {
        Music.MUSIC_GAME_OVER,
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
        Music.MUSIC_JINGLE_TREASUREROOM_ENTRY_3
    }

    function StageAPI.StopOverridingMusic(music, allowOverrideQueue)
        if allowOverrideQueue ~= nil then
            StageAPI.NonOverrideMusic[#StageAPI.NonOverrideMusic + 1] = {music, allowOverrideQueue}
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
                    return false, id[2]
                end
            end
        end

        return true
    end

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom then
            local isClear = currentRoom.IsClear
            currentRoom.IsClear = room:IsClear()
            currentRoom.JustCleared = nil
            if not isClear and currentRoom.IsClear then
                StageAPI.CallCallbacks("POST_ROOM_CLEAR", false)
                currentRoom.JustCleared = true
            end
        end
    end)

    StageAPI.RoomGrids = {}

    function StageAPI.PreventRoomGridRegrowth()
        StageAPI.RoomGrids[StageAPI.GetCurrentRoomID()] = {}
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

        StageAPI.RoomGrids[roomIndex] = grids
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
    StageAPI.OldBackdropType = nil
    StageAPI.PreviousGridCount = nil

    function StageAPI.ReprocessRoomGrids()
        StageAPI.PreviousGridCount = nil
    end

    mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, StageAPI.ReprocessRoomGrids, CollectibleType.COLLECTIBLE_D12)

    StageAPI.OverriddenD7 = Isaac.GetItemIdByName("D7 ")
    StageAPI.JustUsedD7 = nil

    function StageAPI.UseD7()
        local currentRoom = StageAPI.GetCurrentRoom()
        if currentRoom then
            StageAPI.JustUsedD7 = true
        else
            players[1]:UseActiveItem(CollectibleType.COLLECTIBLE_D7, false, true, true, false)
        end

        return true
    end

    mod:AddCallback(ModCallbacks.MC_USE_ITEM, StageAPI.UseD7, StageAPI.OverriddenD7)

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

    mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, t, v, s, po, ve, sp, se)
        if t == EntityType.ENTITY_PICKUP and v == PickupVariant.PICKUP_COLLECTIBLE and s == CollectibleType.COLLECTIBLE_D7 then
            return {t, v, StageAPI.OverriddenD7, se}
        end
    end)

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

        if currentRoom or StageAPI.InExtraRoom or (not inStartingRoom and StageAPI.InNewStage() and (room:GetType() == RoomType.ROOM_DEFAULT or (StageAPI.CurrentStage.Bosses and room:GetType() == RoomType.ROOM_BOSS))) then
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

    function StageAPI.CheckStageTrapdoor(grid, index)
        if not (grid.Desc.Type == GridEntityType.GRID_TRAPDOOR and grid.State == 1) then
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
            StageAPI.SpawnCustomTrapdoor(room:GetGridPosition(index), nextStage, nil, 32, true)
            room:RemoveGridEntity(index, 0, false)
        end
    end

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
            if StageAPI.RoomGrids[currentListIndex] then
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

            if gridsOverride then
                grids = gridsOverride
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
                local canOverride, canOverrideQueue = StageAPI.CanOverrideMusic(queuedID)
                if queuedID ~= shouldQueue and (canOverride or canOverrideQueue or disregardNonOverride) then
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

        if stype == StageType.STAGETYPE_ORIGINAL and (stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2) then
            local shouldPlayMusic, shouldLayer = StageAPI.ShouldPlayStageMusic()
            if shouldPlayMusic then
                local id = StageAPI.Music:GetCurrentMusicID()
                local musicID = StageAPI.UteroMusicID
                local queuedID = StageAPI.Music:GetQueuedMusicID()

                local canOverride, canOverrideQueue = StageAPI.CanOverrideMusic(queuedID)
                if queuedID ~= musicID and (canOverride or canOverrideQueue) then
                    StageAPI.Music:Queue(musicID)
                end

                local canOverride = StageAPI.CanOverrideMusic(id)
                if id ~= musicID and canOverride then
                    StageAPI.Music:Play(musicID, 0)
                end

                StageAPI.Music:UpdateVolume()

                if shouldLayer and not StageAPI.Music:IsLayerEnabled() then
                    StageAPI.Music:EnableLayer()
                elseif not shouldLayer and StageAPI.Music:IsLayerEnabled() then
                    StageAPI.Music:DisableLayer()
                end
            end
        end

        local btype = room:GetBackdropType()
        if btype == 10 then
            for _, grid in ipairs(pits) do
                StageAPI.CheckBridge(grid[1], grid[2], "stageapi/floors/utero/grid_bridge_womb.png")
            end
        end

        if StageAPI.OldBackdropType ~= btype then
            if btype == 5 and not StageAPI.InOverriddenStage() then
                StageAPI.ChangeRoomGfx(StageAPI.CatacombsRoomGfx)
            end

            StageAPI.OldBackdropType = btype
        end

        for _, player in ipairs(players) do
            if player:HasCollectible(CollectibleType.COLLECTIBLE_D7) then
                player:RemoveCollectible(CollectibleType.COLLECTIBLE_D7)
                player:AddCollectible(StageAPI.OverriddenD7, player:GetActiveCharge(), false)
            end
        end

        if StageAPI.RoomNamesEnabled then
            local currentRoom = StageAPI.LevelRooms[currentListIndex]
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
    end)

    function StageAPI.SetCurrentBossRoom(bossID, checkEncountered, bosses, hasHorseman, requireRoomTypeBoss, noPlayBossAnim)
        if not bossID then
            bossID = StageAPI.SelectBoss(bosses, hasHorseman)
        elseif checkEncountered then
            if StageAPI.GetBossEncountered(bossID) then
                return
            end
        end

        local boss = StageAPI.GetBossData(bossID)
        if not boss then
            StageAPI.Log("Trying to set boss with invalid ID: " .. tostring(bossID))
            return
        end

        StageAPI.SetBossEncountered(boss.Name)
        if boss.NameTwo then
            StageAPI.SetBossEncountered(boss.NameTwo)
        end

        local levelIndex = StageAPI.GetCurrentRoomID()
        local newRoom = StageAPI.LevelRoom(nil, boss.Rooms, nil, nil, nil, nil, nil, requireRoomTypeBoss, nil, nil, levelIndex)
        newRoom.PersistentData.BossID = bossID
        StageAPI.CallCallbacks("POST_BOSS_ROOM_INIT", false, newRoom, boss, bossID)
        StageAPI.SetCurrentRoom(newRoom)
        newRoom:Load()

        if not boss.IsMiniboss then
            StageAPI.PlayBossAnimation(boss)
        else
            StageAPI.PlayTextStreak(players[1]:GetName() .. " VS " .. boss.Name)
        end

        return newRoom, boss
    end

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        StageAPI.CallCallbacks("PRE_STAGEAPI_NEW_ROOM", false)

        local isNewStage, override = StageAPI.InOverriddenStage()
        local inStartingRoom = level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()
        StageAPI.CustomGridIndices = {}

        if inStartingRoom and room:IsFirstVisit() then
            StageAPI.CustomGrids = {}
            StageAPI.LevelRooms = {}
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
            end

            StageAPI.NextStage = nil
            if StageAPI.CurrentStage and StageAPI.CurrentStage.GetPlayingMusic then
                local musicID = StageAPI.CurrentStage:GetPlayingMusic()
                if musicID then
                    StageAPI.Music:Queue(musicID)
                end
            end
        end

        local enteringExtraRoomFromOffGridRoom
        if StageAPI.PreviousExtraRoom and room:GetType() == RoomType.ROOM_BARREN and level:GetCurrentRoomIndex() == -3 then
            StageAPI.CurrentExtraRoom = StageAPI.PreviousExtraRoom
            StageAPI.CurrentExtraRoomName = StageAPI.PreviousExtraRoomName
            StageAPI.InExtraRoom = true
            StageAPI.TransitionExitSlot = level.LeaveDoor
            StageAPI.PreviousExtraRoom = nil
            StageAPI.PreviousExtraRoomName = nil
            enteringExtraRoomFromOffGridRoom = true
        end

        if not StageAPI.TransitioningToExtraRoom() and not enteringExtraRoomFromOffGridRoom and not StageAPI.LoadingExtraRoomFromSave then
            if StageAPI.InExtraRoom and level:GetCurrentRoomIndex() < 0 then
                StageAPI.PreviousExtraRoom = StageAPI.CurrentExtraRoom
                StageAPI.PreviousExtraRoomName = StageAPI.CurrentExtraRoomName
            else
                StageAPI.PreviousExtraRoom = nil
                StageAPI.PreviousExtraRoomName = nil
            end

            StageAPI.CurrentExtraRoom = nil
            StageAPI.CurrentExtraRoomName = nil
            StageAPI.InExtraRoom = false
            StageAPI.LoadedExtraRoom = false
        end

        StageAPI.LoadingExtraRoomFromSave = nil

        if StageAPI.TransitionExitSlot then
            local pos = room:GetDoorSlotPosition(StageAPI.TransitionExitSlot) + (StageAPI.DoorOffsetsByDirection[StageAPI.DoorToDirection[StageAPI.TransitionExitSlot]] * 3)
            for _, player in ipairs(players) do
                player.Position = pos
            end

            StageAPI.TransitionExitSlot = nil
        end

        if StageAPI.CurrentExtraRoom then
            for i = 0, 7 do
                if room:GetDoor(i) then
                    room:RemoveDoor(i)
                end
            end

            StageAPI.CurrentExtraRoom:Load(true)
            StageAPI.LoadedExtraRoom = true
            StageAPI.PreviousExtraRoom = nil
            StageAPI.PreviousExtraRoomName = nil
            justGenerated = true
        else
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

        if not StageAPI.InExtraRoom and StageAPI.InNewStage() then
            local rtype = room:GetType()
            if not currentRoom and StageAPI.CurrentStage.SinRooms and (rtype == RoomType.ROOM_MINIBOSS or rtype == RoomType.ROOM_SECRET or rtype == RoomType.ROOM_SHOP) then
                local usingRoomsList
                local includedSins = {}
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
                        local levelIndex = StageAPI.GetCurrentRoomID()
                        local newRoom = StageAPI.LevelRoom(nil, usingRoomsList, nil, nil, nil, nil, nil, StageAPI.CurrentStage.RequireRoomTypeMatching, nil, nil, levelIndex)
                        StageAPI.SetCurrentRoom(newRoom)
                        newRoom:Load()
                        currentRoom = newRoom
                        justGenerated = true
                    end
                end
            end

            if not inStartingRoom and not currentRoom and StageAPI.CurrentStage.Rooms and StageAPI.CurrentStage.Rooms[rtype] then
                local levelIndex = StageAPI.GetCurrentRoomID()
                local newRoom = StageAPI.LevelRoom(nil, StageAPI.CurrentStage.Rooms[rtype], nil, nil, nil, nil, nil, StageAPI.CurrentStage.RequireRoomTypeMatching, nil, nil, levelIndex)
                StageAPI.SetCurrentRoom(newRoom)
                newRoom:Load()
                currentRoom = newRoom
                justGenerated = true
            end

            if not currentRoom and StageAPI.CurrentStage.Bosses and rtype == RoomType.ROOM_BOSS then
                local newRoom
                newRoom, boss = StageAPI.SetCurrentBossRoom(nil, true, StageAPI.CurrentStage.Bosses, StageAPI.CurrentStage.Bosses.HasHorseman, StageAPI.CurrentStage.RequireRoomTypeBoss)

                currentRoom = newRoom
                justGenerated = true
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

        --[[
        if StageAPI.RoomGrids[currentListIndex] and not justGenerated then
            StageAPI.RemoveExtraGrids(StageAPI.RoomGrids[currentListIndex])
        end]]

        if currentRoom and not StageAPI.InExtraRoom and not justGenerated then
            currentRoom:Load()
            if not room:IsClear() and boss then
                if not boss.IsMiniboss then
                    StageAPI.PlayBossAnimation(boss)
                else
                    StageAPI.PlayTextStreak(players[1]:GetName() .. " VS " .. boss.Name)
                end
            end
        end

        if not justGenerated then
            if StageAPI.CustomGrids[currentListIndex] then
                for name, grindices in pairs(StageAPI.CustomGrids[currentListIndex]) do
                    for grindex, exists in pairs(grindices) do
                        StageAPI.CustomGridTypes[name]:Spawn(grindex, nil, true)
                        StageAPI.CustomGridIndices[grindex] = true
                    end
                end
            end
        end

        if currentRoom then
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
                for _, player in ipairs(REVEL.players) do
                    player.Position = room:GetDoorSlotPosition(changeEntrance)
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
        elseif isNewStage then
            local rtype = StageAPI.GetCurrentRoomType()
            usingGfx = StageAPI.CurrentStage.RoomGfx[rtype]
        end

        if usingGfx then
            local callbacks = StageAPI.GetCallbacks("PRE_CHANGE_ROOM_GFX")
            for _, callback in ipairs(callbacks) do
                local ret = callback.Function(currentRoom, usingGfx)
                if ret ~= nil then
                    usingGfx = ret
                end
            end

            if usingGfx then
                StageAPI.ChangeRoomGfx(usingGfx)
            end

            local callbacks = StageAPI.GetCallbacks("POST_CHANGE_ROOM_GFX")
            for _, callback in ipairs(callbacks) do
                callback.Function()
            end
        else
            if room:GetBackdropType() == 5 then
                StageAPI.ChangeRoomGfx(StageAPI.CatacombsRoomGfx)
                StageAPI.OldBackdropType = 5
            end

            if room:GetType() ~= RoomType.ROOM_DUNGEON and room:GetBackdropType() ~= 16 then
                StageAPI.ChangeShading("_default")
            end
        end

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
                    local testRoom = StageAPI.LevelRoom("StageAPITest", nil, room:GetSpawnSeed(), selectedLayout.Shape, selectedLayout.Variant)
                    testRoom.RoomType = selectedLayout.Type
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
        if StageAPI.ShouldOverrideRoom() and (t >= 1000 or gridBlacklist[t]) and not StageAPI.InExtraRoom then
            local shouldReturn
            if room:IsFirstVisit() then
                shouldReturn = true
            else
                local currentListIndex = StageAPI.GetCurrentRoomID()
                if StageAPI.RoomGrids[currentListIndex] and not StageAPI.RoomGrids[currentListIndex][index] then
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

Isaac.DebugString("[StageAPI] Loading Save System")
do
    StageAPI.json = require("json")
    function StageAPI.GetSaveString()
        local levelSaveData = {}
        for index, roomGrids in pairs(StageAPI.RoomGrids) do
            local strindex = tostring(index)
            if not levelSaveData[strindex] then
                levelSaveData[strindex] = {}
            end

            for grindex, exists in pairs(roomGrids) do
                if exists then
                    if not levelSaveData[strindex].Grids then
                        levelSaveData[strindex].Grids = {}
                    end

                    levelSaveData[strindex].Grids[#levelSaveData[strindex].Grids + 1] = grindex
                end
            end
        end

        for lindex, customGrids in pairs(StageAPI.CustomGrids) do
            local strindex = tostring(lindex)
            if not levelSaveData[strindex] then
                levelSaveData[strindex] = {}
            end

            for name, indices in pairs(customGrids) do
                for index, value in pairs(indices) do
                    if not levelSaveData[strindex].CustomGrids then
                        levelSaveData[strindex].CustomGrids = {}
                    end

                    if not levelSaveData[strindex].CustomGrids[name] then
                        levelSaveData[strindex].CustomGrids[name] = {}
                    end

                    if value == true then
                        levelSaveData[strindex].CustomGrids[name][#levelSaveData[strindex].CustomGrids[name] + 1] = index
                    else
                        levelSaveData[strindex].CustomGrids[name][#levelSaveData[strindex].CustomGrids[name] + 1] = {index, value}
                    end
                end
            end
        end

        for index, customRoom in pairs(StageAPI.LevelRooms) do
            local strindex = tostring(index)
            if not levelSaveData[strindex] then
                levelSaveData[strindex] = {}
            end

            levelSaveData[strindex].Room = customRoom:GetSaveData()
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

        for strindex, roomSaveData in pairs(decoded.LevelInfo) do
            local lindex = tonumber(strindex) or strindex
            if roomSaveData.Grids then
                retRoomGrids[lindex] = {}
                for _, grindex in ipairs(roomSaveData.Grids) do
                    retRoomGrids[lindex][grindex] = true
                end
            end

            if roomSaveData.CustomGrids then
                retCustomGrids[lindex] = {}
                for name, indices in pairs(roomSaveData.CustomGrids) do
                    for _, index in ipairs(indices) do
                        if not retCustomGrids[lindex][name] then
                            retCustomGrids[lindex][name] = {}
                        end

                        if type(index) == "table" then
                            retCustomGrids[lindex][name][index[1]] = index[2]
                        else
                            retCustomGrids[lindex][name][index] = true
                        end
                    end
                end
            end

            if roomSaveData.Room then
                local customRoom = StageAPI.LevelRoom(nil, nil, nil, nil, nil, nil, roomSaveData.Room, nil, nil, nil, lindex)
                retLevelRooms[lindex] = customRoom
            end
        end

        if StageAPI.CurrentExtraRoomName then
            StageAPI.CurrentExtraRoom = retLevelRooms[StageAPI.CurrentExtraRoomName]
            StageAPI.InExtraRoom = true
            StageAPI.LoadingExtraRoomFromSave = true
        end

        StageAPI.RoomGrids = retRoomGrids
        StageAPI.LevelRooms = retLevelRooms
        StageAPI.CustomGrids = retCustomGrids
        StageAPI.CallCallbacks("POST_STAGEAPI_LOAD_SAVE", false)
    end
end

Isaac.DebugString("[StageAPI] Loading Miscellaneous Functions")
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

    function StageAPI.GetPitFramesForLayoutEntities(t, v, s, entities, width, height, hasExtraFrames)
        width = width or room:GetGridWidth()
        height = height or room:GetGridHeight()
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

        return StageAPI.GetPitFramesFromIndices(indicesWithEntity, width, height, hasExtraFrames)
    end
end

Isaac.DebugString("[StageAPI] Loading Editor Features")
do
    local recentlyDetonated = {}
    local d12Used = false
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
        d12Used = true
    end, CollectibleType.COLLECTIBLE_D12)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        local currentRoom = StageAPI.GetCurrentRoom()
        if not currentRoom then
            return
        end

        for index, timer in pairs(recentlyDetonated) do
            recentlyDetonated[index] = timer - 1
            if recentlyDetonated[index] <= 0 then
                recentlyDetonated[index] = nil
            end
        end

        for group, names in pairs(currentRoom.EntityMetadata.RecentTriggers) do
            for name, timer in pairs(names) do
                names[name] = timer + 1
            end
        end

        local width = room:GetGridWidth()
        for index, metadataSet in pairs(currentRoom.EntityMetadata) do
            if type(index) == "number" then
                if metadataSet["RoomClearTrigger"] and currentRoom.JustCleared then
                    currentRoom:TriggerIndexMetadata(index, "RoomClearTrigger")
                end

                if metadataSet["BridgeFailsafe"] then
                    if room:GetGridCollision(index) ~= 0 then
                        if d12Used then
                            room:GetGridEntity(index):ToPit():MakeBridge()
                        else
                            local adjacent = {index - 1, index + 1, index - width, index + width}
                            for _, index2 in ipairs(adjacent) do
                                local grid = room:GetGridEntity(index2)
                                if grid and room:GetGridCollision(index2) == 0 and (grid:ToRock() or grid.Desc.Type == GridEntityType.GRID_POOP) then
                                    room:GetGridEntity(index):ToPit():MakeBridge()
                                    break
                                end
                            end
                        end
                    end
                end

                --[[
                if metadataSet["Detonator"] then
                    if room:GetGridCollision(index) ~= 0 then
                        local checking = room:GetGridEntity(index)
                        local shouldDetonate = currentRoom:WasIndexTriggered(index, 100)
                        if not shouldDetonate then
                            local adjacent = {index - 1, index + 1, index - width, index + width}
                            for _, index2 in ipairs(adjacent) do
                                if not recentlyDetonated[index2] and currentRoom.EntityMetadata[index2] and currentRoom.EntityMetadata[index2]["Detonator"] then
                                    if room:GetGridCollision(index2) == 0 then
                                        local grid = room:GetGridEntity(index2)
                                        if grid then
                                            if checking:ToRock() and grid:ToRock() then
                                                checking:Destroy()
                                            elseif checking:ToPit() and grid:ToPit() then
                                                checking:ToPit():MakeBridge()
                                            end
                                            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, room:GetGridPosition(index), zeroVector, nil)
                                            recentlyDetonated[index] = 5

                                            if metadataSet["DetonatorTrigger"] then
                                                currentRoom:TriggerIndexMetadata(index, "DetonatorTrigger")
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        if shouldDetonate then
                            if checking:ToRock() then
                                checking:Destroy()
                            elseif checking:ToPit() then
                                checking:ToPit():MakeBridge()
                            end
                            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, room:GetGridPosition(index), zeroVector, nil)
                            recentlyDetonated[index] = 5
                            if metadataSet["DetonatorTrigger"] then
                                currentRoom:TriggerIndexMetadata(index, "DetonatorTrigger")
                            end
                        end
                    end
                end]]

                if metadataSet["Spawner"] then
                    if currentRoom:WasIndexTriggered(index, nil, 1) then
                        local blockedEntities = currentRoom.EntityMetadata.BlockedEntities[index]
                        if blockedEntities then
                            if #blockedEntities > 0 then
                                local spawn = blockedEntities[StageAPI.Random(1, #blockedEntities)]
                                Isaac.Spawn(spawn.Type or 20, spawn.Variant or 0, spawn.SubType or 0, room:GetGridPosition(index), zeroVector, nil)
                            end
                        end
                    end
                end

                --[[
                if metadataSet["DoorLocker"] then
                    if room:IsClear() then
                        local isClear = true
                        for _, entity in ipairs(Isaac.GetRoomEntities()) do
                            if entity:CanShutDoors() then
                                isClear = false
                                break
                            end
                        end

                        if isClear then
                            for i = 0, room:GetGridSize() do
                                local grid = room:GetGridEntity(i)
                                if grid and grid:ToPressurePlate() and grid:GetVariant() == 0 and grid.State ~= 3 then
                                    isClear = false
                                    break
                                end
                            end
                        end

                        if not isClear then
                            room:SetClear(false)
                            StageAPI.CloseDoors()
                        end
                    end
                end]]
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
                for _, entity in ipairs(Isaac.GetRoomEntities()) do
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

                local wave = StageAPI.ChooseRoomLayout(useWaves.ByShape, seed, room:GetRoomShape(), room:GetType(), false, false, nil, challengeWaveIDs)
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

Isaac.DebugString("[StageAPI] Loading BR Compatibility")
do -- BR Compatibility
    StageAPI.InTestMode = false

    local status, brTestRoom = pcall(require, 'basementrenovator.roomTest')
    if not status then
        StageAPI.Log('Error loading BR compatibility file: ' .. tostring(brTestRoom))
    elseif brTestRoom then
        local testList = StageAPI.RoomsList("BRTest", brTestRoom)
        local testLayout = testList.All[1]
        StageAPI.RegisterLayout("BRTest", testLayout)

        BasementRenovator = BasementRenovator or { subscribers = {} }
        BasementRenovator.subscribers['StageAPI'] = {
            PostTestInit = function(test)
                if test.Type    ~= testLayout.Type
                or test.Variant ~= testLayout.Variant
                or test.Subtype ~= testLayout.SubType
                or test.Name    ~= testLayout.Name then
                    StageAPI.Log("basementrenovator/roomTest.lua did not have values matching the BR test! Make sure your hooks are set up properly")
                    StageAPI.BadTestFile = true
                    return
                end

                StageAPI.InTestMode = true
                StageAPI.Log("Basement Renovator test mode")
            end,
            TestStage = function(test)
                if StageAPI.BadTestFile or not BasementRenovator.TestRoomData then return end
                -- TestStage fires in post_curse_eval,
                -- before StageAPI's normal stage handling code
                if test.IsModStage then
                    StageAPI.NextStage = StageAPI.CustomStages[test.StageName]
                end
            end,
            TestRoomEntitySpawn = function()
                if StageAPI.BadTestFile then return end
                -- makes sure placeholder/meta entities can't spawn
                return { 999, StageAPI.E.DeleteMeEffect.V, 0 }
            end
        }

        StageAPI.AddCallback("StageAPI", "PRE_STAGEAPI_NEW_ROOM_GENERATION", 0, function()
            if StageAPI.BadTestFile or not BasementRenovator.TestRoomData then return end

            if BasementRenovator.InTestStage() and BasementRenovator.InTestRoom() then
                local testRoom = StageAPI.LevelRoom("BRTest", nil, room:GetSpawnSeed(), testLayout.Shape, testLayout.Type, nil, nil, nil, nil, nil, StageAPI.GetCurrentRoomID())
                return testRoom
            end
        end)
    end
end

do -- Mod Compatibility
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
        if REVEL and REVEL.AddChangelog and not REVEL.AddedStageAPIChangelogs then
            REVEL.AddedStageAPIChangelogs = true

            REVEL.AddChangelog("StageAPI v1.78", [[-Fixed an issue where "fart damage" was
cancelled even with none in the room,
which broke Sharp Plug.
]])

            REVEL.AddChangelog("StageAPI v1.75 - 77", [[-Fixed an issue with nightmare
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

            REVEL.AddChangelog("StageAPI v1.72 - 74", [[-Basement renovator integration

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

            REVEL.AddChangelog("StageAPI v1.69 - 71", [[-Fixed transitions out of special rooms
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

            REVEL.AddChangelog("StageAPI v1.68", [[-Fixed some persistent entities
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

            REVEL.AddChangelog("StageAPI v1.67", [[-Missing door weight is now
scaled correctly by original weight
            ]])

            REVEL.AddChangelog("StageAPI v1.66", [[-Fixed persistent entity data
not always unloading when
the room changes

-Room weight is now scaled
by number of unavailable
doors to make rooms
with a large amount
of unavailable doors
more likely to appear
            ]])

            REVEL.AddChangelog("StageAPI v1.65", [[-Fixed dead slot machines
respawning in extra rooms
            ]])

            REVEL.AddChangelog("StageAPI v1.64", [[-Disabled backdrop setting
on non-custom floors
            ]])

            REVEL.AddChangelog("StageAPI v1.63", [[-Fixed stage shadows not
being properly centered
in some L shaped rooms

-Fixed black overlay in
stage and room transitions
not scaling with screen.
            ]])

            REVEL.AddChangelog("StageAPI v1.62", [[-Fixed extra rooms containing
persistent entities from the
previous room, after you
re-enter the room twice
            ]])

            REVEL.AddChangelog("StageAPI v1.61", [[-Fixed extra rooms containing
persistent entities from the
previous room
            ]])

            REVEL.AddChangelog("StageAPI v1.60", [[-Fixed Mom's Heart track
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

Isaac.DebugString("[StageAPI] Fully Loaded, loading dependent mods.")
StageAPI.MarkLoaded("StageAPI", "1.78", true, true)

StageAPI.Loaded = true
if StageAPI.ToCall then
    for _, fn in ipairs(StageAPI.ToCall) do
        fn()
    end
end
