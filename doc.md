# Documentation

## Basic Features:

### Commands:

cstage or customstage <StageName> -- Warps to new stage.  
nstage or nextstage -- Warps to next stage.  
extraroom <ExtraRoomName> -- Warps to extra room  
extraroomexit -- Cleanly exits extra room to previous room.  
creseed -- Akin to reseed, but guaranteed to work for and only work for custom stages.  

### Classes:

`StageAPI.Class("Name", AllowMultipleInit)`: Returns a Class object, actually is one itself.

Classes can be constructed simply by calling them with (), i.e,

```
local myClass = StageAPI.Class("MyClass")
local myClassInst = myClass()
```

Classes can have a couple of functions, Init, PostInit, and InheritInit.
When called like in the example above, Init and PostInit are called, passing in whatever args.
However, you can keep going deeper, i.e,

```
local myClassInstCopy = myClassInst()
```

Which will generate another copy that inherits from myClassInst that inherits from myClass which inherits from StageAPI.Class.
In that case, InheritInit will be called instead of Init and PostInit, unless AllowMultipleInit was passed in to the initial myClass definition.

Classes are used for a majority of StageAPI objects.

## Callbacks:

`StageAPI.AddCallback(modID, id, priority, function, params...)`: Stores a function and its params in a table indexed by ID and sorted by priority, where low priority is at the start.

`StageAPI.UnregisterCallbacks(modID)`: Unregisters all mod callbacks, should be used when a mod loads, useful for luamod.

`StageAPI.CallCallbacks(id, breakOnFirstReturn, params...)`: Calls all callbacks with ID, passing in additional params. If breakOnFirstReturn is defined, breaks and returns the first non-nil return value.

`StageAPI.CallCallbacksWithParams(id, breakOnFirstReturn, matchParams, params...)`: only call callbacks matching some params, usually entity IDs. matchParams can
be a single param or a table of params. Callbacks with no param specified will be called, matching vanilla behavior. Example:

```
// Example callback: MY_POST_ENTITY_UPDATE, that can be added with a specified type, variant, subtype
StageAPI.CallCallbacksWithParams("MY_POST_ENTITY_UPDATE", true, 15, entity) // Will be called for all entities with Type == 15, and any Variant/SubType
StageAPI.CallCallbacksWithParams("MY_POST_ENTITY_UPDATE", true, {1, 2}, entity) // Will be called for all entities with Type == 1, Variant either == 1 or unspecified, and any SubType
```

`StageAPI.CallCallbacksAccumulator(id, startValue, params...)`: Calls callbacks passing an accumulator variable as the first parameter. The accumulator will be
replaced by every callback's return. So, callback 1 gets called with firstParam = startValue, returns secondValue; callback 2 gets called with firstParam = secondValue, returns thirdValue; etc.

`StageAPI.CallCallbacksAccumulatorParams(id, matchParams, startValue, params...)`: Combines the previous two.

StageAPI callbacks all use string IDs, i.e, `AddCallback("POST_CHECK_VALID_ROOM", 1, function, params)`

`StageAPI.GetCallbacks(id)`: Gets a list of callbacks from the table by the ID, sorted by priority.
It's recommended that if you use this functions you call the callbacks via one of the following functions:

`StageAPI.TryCallback(callback, params...)` and `StageAPI.TryCallbackParams(callback, matchParams, params...)`: they will try to call the callback,
and print an error if it fails. Only difference is that Params will include the matchParams in the error log, to be used when you are only calling
params for a specific entityId or similar.

`StageAPI.TryCallbackMultiReturn(callback, params...)` and `StageAPI.TryCallbackMultiReturnParams(callback, matchParams, params...)`: same as the previous
ones, but will allow returning multiple values in callback functions. They are slower, so use the previous ones for callbacks that are called many times
per frame.

You can also directly use the callback tables, but it's not recommended. Individual callbacks tables are arranged like so

```
{
    Priority = integer,
    Function = function,
    Params = {params...},
    ModID = modID,
    CallbackID = callbackID
}
```

Callback List:

- POST_CHECK_VALID_ROOM(layout, roomList, seed, shape, rtype, requireRoomType)

  - Return false to invalidate a room layout, return integer to specify new weight.

- PRE_SELECT_GRIDENTITY_LIST(GridDataList, spawnIndex)

  - Takes 1 return value. If false, cancels selecting the list. If GridData, selects it to spawn.
  - With no value, picks at random.

- PRE_SELECT_ENTITY_LIST(entityList, spawnIndex, roomMetadata)

  - Takes 3 return values, AddEntities, EntityList, StillAddRandom. If the first value is false, cancels selecting the list.
  - AddEntities and EntityList are lists of EntityData tables, described below.
  - Usually StageAPI will pick one entity from the EntityList to add to the AddEntities table at random, but that can be changed with this callback.
  - If StillAddRandom is true, StageAPI will still add a random entity from the entitylist to addentities, alongside ones you returned.

- PRE_SPAWN_ENTITY_LIST(entityList, spawnIndex, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData)

  - Takes 1 return value. If false, cancels spawning the entity list. If a table, uses it as the entity list. Any return value breaks out of future callbacks.
  - Every entity in the final entity list is spawned.
  - Note that this entity list contains EntityInfo tables rather than EntityData, which contain persistent room-specific data. Both detailed below.

- PRE_SPAWN_ENTITY(entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, shouldSpawnEntity)

  - Takes 1 return value. If false, cancels spawning the entity info. If a table, uses it as the entity info. Any return value breaks out of future callbacks.
  - Takes entity Type, Variant and SubType as callback parameters.

- POST_SPAWN_ENTITY(ent, entityInfo, entityList, index, doGrids, doPersistentOnly, doAutoPersistent, avoidSpawning, persistenceData, shouldSpawnEntity)

  - Called both by normal StageAPI room layout entity spawning, and Spawner metaentities.

- PRE_SPAWN_GRID(gridData, gridInformation, entities, gridSpawnRNG)

  - Takes 1 return value. If false, cancels spawning the grid. If a table, uses it as the grid data. Any return value breaks out of future callbacks.

- PRE_ROOMS_LIST_USE(room)

  - Called when deciding the layout of a room.
  - Return a room list table to use that instead of the default one or the room (the name of which is found in room.RoomsListName)

- PRE_ROOM_LAYOUT_CHOOSE(currentRoom, roomsList)

  - Takes 1 return value. If a table, uses it as the current room layout. Otherwise, chooses from the roomslist with seeded RNG. Breaks on first return.
  - Called both on initial room load and when continuing game, before INIT.

- POST_ROOM_INIT(currentRoom, fromSaveData, saveData)

  - Called when a room initializes. Can occur at two times, when a room is initially entered or when a room is loaded from save data. Takes no return values.

- POST_BOSS_ROOM_INIT(currentRoom, boss, bossID)

  - Called when a boss room is generated.

- POST_ROOM_LOAD(currentRoom, isFirstLoad, isExtraRoom)

  - Called when a room is loaded. Takes no return value.

- POST_SPAWN_CUSTOM_GRID(CustomGridEntity, force, respawning)

  - Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.

- POST_CUSTOM_GRID_UPDATE(CustomGridEntity)

  - Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.

- POST_CUSTOM_GRID_PROJECTILE_UPDATE(CustomGridEntity, projectile)

  - Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.
  - Used when the grid is lifted and shot as a projectile

- POST_CUSTOM_GRID_PROJECTILE_HELPER_UPDATE(CustomGridEntity, projectileHelper, projectileHelperParent)

  - Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.

- POST_CUSTOM_GRID_DESTROY(CustomGridEntity, projectile)

  - Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.
  - projectile is nil in case the grid is destroyed normally, and is set to the projectile entity in case the grid was lifted and shot as a projectile (see POST_CUSTOM_GRID_PROJECTILE_UPDATE)

- POST_CUSTOM_GRID_UNLOAD(CustomGridEntity)

  - Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.
  - Run any time a custom grid is unloaded, including via removal and via room transitions.

- POST_REMOVE_CUSTOM_GRID(CustomGridEntity, keepBaseGrid)

  - Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.
  - Run only when a custom grid is removed through the CustomGridEntity:Remove function, such as when its base grid is removed.

- POST_CUSTOM_GRID_POOP_GIB_SPAWN(CustomGridEntity, effect)

  - Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.

- POST_CUSTOM_GRID_DIRTY_MIND_SPAWN(CustomGridEntity, familiar)

  - Takes CustomGridTypeName as first callback parameter, and will only run if parameter not supplied or matches current grid.
  - Called for dips spawned by dirty mind from a custom grid entity whose base type is poop

- PRE_TRANSITION_RENDER()

  - Called before the custom room transition would render, for effects that should render before it.

- POST_SPAWN_CUSTOM_DOOR(door, data, sprite, CustomDoor, persistData, index, force, respawning, grid, CustomGrid)

  - Takes CustomDoorName as first callback parameter, and will only run if parameter not supplied or matches current door.

- POST_CUSTOM_DOOR_UPDATE(door, data, sprite, CustomDoor, persistData)

  - Takes CustomDoorName as first callback parameter, and will only run if parameter not supplied or matches current door.

- PRE_BOSS_SELECT(bosses, rng, roomDesc, ignoreNoOptions)

  - If a boss is returned, uses it instead.

- POST_OVERRIDDEN_ALT_ROCK_BREAK(gridpos, gridvar, brokenData, customGrid, projectile)

  - Called when an overridden grid reaches its break state and is considered broken. brokenData contains all deleted spawns from the grid. Breaks on first non-nil return.

- POST_GRID_UPDATE()

  - Calls when the number of grids changes or grids are reprocessed. This is when room grid graphics are changed.

- PRE_UPDATE_GRID_GFX()

  - Allows returning gridgfx to use in place of the stage's.

- POST_UPDATE_GRID_GFX()

  - Called when the number of grids changes or grids are reprocessed, after room grid graphics are changed. Good for postfixes.

- PRE_CHANGE_ROOM_GFX(currentRoom, usingGfx, onRoomLoad, currentDimension)

  - Allows returning roomgfx to use in place of the stage's.
  - Runs both on room load and when the backdrop is changed

- POST_CHANGE_ROOM_GFX(currentRoom, usingGfx, onRoomLoad, currentDimension)

  - Runs both on room load and when the backdrop is changed

- PRE_CHANGE_ROCK_GFX(grid: GridEntity, index: integer, usingFilename: string): string?
- PRE_CHANGE_DECORATION_GFX(grid: GridEntity, index: integer, usingDecorations: GridGfx.Decorations): GridGfx.Decorations?
- PRE_CHANGE_PIT_GFX(grid: GridEntity, index: integer, usingPitFile: GridGfx.PitFile?, usingBridgeFilename: string?, usingAlt: GridGfx.PitFile?): GridGfx.PitFile?, string?, GridGfx.PitFile?
- PRE_CHANGE_MISC_GRID_GFX(grid: GridEntity, index: integer, usingFilename: string): string?

  - All of the PRE_CHANGE\_<GRID\>\_GFX above can be used to change a specific grid's sprite, for example changing the spritesheet for rocks on a certain row or column
  - Can take a CustomStage as parameter to only work in that stage
  - Breaks on first returned value, see each specific callback for returned values/params (available in lua doc tags)
  - No PRE_CHANGE_DOOR_GFX as most usecases where you'd want to change door sprites are either handled by room types or Custom Doors

- PRE_STAGEAPI_NEW_ROOM()

  - Runs before most but not all stageapi room functionality. guaranteed to run before any room loads.

- PRE_STAGEAPI_NEW_ROOM_GENERATION(currentRoom, justGenerated, currentListIndex, currentDimension))

  - Allows returning currentRoom, justGenerated, boss
  - Run before normal room generation

- POST_STAGEAPI_NEW_ROOM_GENERATION(currentRoom, justGenerated, currentListIndex, boss, currentDimension))

  - Allows returning currentRoom, justGenerated, boss
  - Run after normal room generation but before reloading old rooms.

- POST_STAGEAPI_NEW_ROOM(justGenerated)

  - All loading and processing of new room generation and old room loading is done, but the gfx hasn't changed yet

- PRE_SELECT_NEXT_STAGE(currentstage)

  - Return a stage to go to instead of currentstage.NextStage or none.

- PRE_PARSE_METADATA(roomMetadata, outEntities, outGrids, roomLoadRNG)

  - Called after all metadata entities in a room are loaded, but before conflicts / groups are resolved
  - outEntities and outGrids are lists of entities / grids mapped to grid indices
  - roomMetadata, outEntities, and outGrids can all be edited within the callback to modify the room

- POST_PARSE_METADATA(roomMetadata, outEntities, outGrids)

  - Called after all metadata entities in a room are loaded, and all conflicts / groups are resolved
  - roomMetadata, outEntities, and outGrids can all be edited within the callback to modify the room

- POST_SELECT_BOSS_MUSIC(currentstage, musicID, isCleared, musicRNG)

  - Return a number to use that MusicID as music, not running further callbacks.

- POST_SELECT_CHALLENGE_MUSIC(currentstage, musicID, isCleared, musicRNG)

  - Return a number to use that MusicID as music, not running further callbacks.

- POST_SELECT_ROOM_MUSIC(currentstage, musicID, baseRoomType, roomId, musicRNG)

  - Return a number to use that MusicID as music, not running further callbacks.
  - Overrides stage callbacks if something is returned
  - Ran for StageAPI rooms, even in vanilla floors (in that case, extra rooms)

- POST_SELECT_STAGE_MUSIC(currentstage, musicID, roomType, musicRNG)

  - Return a number to use that MusicID as music, not running further callbacks.

- POST_ROOM_CLEAR()

- PRE_STAGEAPI_SELECT_BOSS_ITEM(pickup, currentRoom)

  - Return true to prevent StageAPI from randomly selecting a collectible to replace pickup with.
  - pickup is the collectible spawned by vanilla logic, that will be morphed into a random reward by StageAPI

- PRE_STAGEAPI_LOAD_SAVE()

  - Before loading stageapi save data

- POST_STAGEAPI_LOAD_SAVE()

  - Before loading stageapi save data

- CHALLENGE_WAVE_CHANGED()
- GREED_WAVE_CHANGED()

- PRE_PLAY_MINIBOSS_STREAK(currentRoom, boss, text)

  - Return false to not play "\<player\> VS \<boss.Name\>" as would be normally done, return a string to use that as the streak text instead

- POST_STREAK_RENDER(streakPos, streakPlaying)

  - After rendering a streak played with StageAPI.PlayTextStreak

- POST_HUD_RENDER(isPauseMenuOpen, pauseMenuDarkPct)

  - Runs after the vanilla hud is rendered
  - Uses a workaround with the shader callback
  - Use isPauseMenuOpen and pauseMenuDarkPct to work around the pause menu, as
    the things rendered now will render over that too; either disable
    them or darken them.
  - Handy constant: StageAPI.PAUSE_DARK_BG_COLOR, the color of the dark background
    rendered above the hud normally when paused

- PRE_LEVELMAP_SPAWN_DOOR(slot, doorData, levelRoom, targetLevelRoom, roomData, levelMap)

  - When a LevelMap has AutoDoors set, it automatically places doors based on room types
  - This callback runs before it places a door, allowing you to change it.
  - doorData is a table {ExitRoom = LevelMapRoomID, ExitSlot = slot}

- EARLY_NEW_ROOM()

  - Runs on the first PRE_ROOM_ENTITY_SPAWN in a room
  - Note that this means it will NOT run in empty rooms, and thus cannot be relied upon in all cases

## StageAPI Structures:

```
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

StageAPI Variables:

StageOverride {
    CatacombsOne = StageOverrideStage,
    CatacombsTwo = StageOverrideStage
}

DefaultDoorSpawn = DoorInfo -- where default doors should spawn
SecretDoorSpawn = DoorInfo -- where secret room doors should spawn
```

## StageAPI Objects:

- GridGfx()

  - SetGrid(filename, GridEntityType, variant)
  - SetRocks(filename)
  - SetPits(filename, altpitsfilename, hasExtraFrames): Alt Pits are used where water pits would be. HasExtraFrames controls for situations where the base game would not normally tile pits specially
  - OR, with lists of { File, HasExtraFrames }
  - SetPits(filenames, altpitsfilenames) (see utero override)
  - SetBridges(filename)
  - SetDecorations(filename)
  - AddDoors(filename, DoorInfo)
  - SetPayToPlayDoor(filename)

- RoomGfx(Backdrop, GridGfx)

- RoomsList(name, roomfiles...)

  - NAME IS NOT OPTIONAL. USED FOR SAVING / LOADING ROOMS.
  - AddRooms(roomfiles...): automatically called on init.

- LevelRoom(layoutName, roomsList, seed, shape, roomType, isExtraRoom, saveData, requireRoomType)

  - PostGetLayout(seed): second part of init that is called both when loaded from save and normally, after most other things are initialized. gets spawn ents and grids
  - RemovePersistentIndex(persistentIndex)
  - RemovePersistentEntity(entity)
  - Load(isExtraRoom)
  - SaveGridInformation() -- Save functions only called for extra rooms, usually.
  - SavePersistentEntities()
  - Save()
  - GetSaveData()
  - LoadSaveData(saveData)
  - SetTypeOverride(override)

- CustomStage(name, StageOverrideStage, noSetReplaces): replaces defaults to catacombs one if noSetReplaces is not set.

  - NAME IS NOT OPTIONAL. USED TO IDENTIFY STAGE AND FOR SAVING CURRENT STAGE.
  - InheritInit(name, noSetAlias): automatically aliases the new stage to the old one, if noSetAlias is not set, meaning that IsStage calls on either will return true if either is active. STILL NEEDS A UNIQUE NAME.
  - SetName(name)
  - SetDisplayName(name)
  - SetReplace(StageOverrideStage)
  - SetNextStage(CustomStage)
  - SetRoomGfx(RoomGfx)
  - SetRooms(RoomsList)
  - SetMusic(musicID, RoomType)
  - SetBossMusic(musicID, clearedMusicID, intro, outro)
  - SetChallengeMusic(musicID, clearedMusicID, intro, outro)
  - SetSpots(bossSpot, playerSpot, bgColor)
  - SetBosses(Bosses)
  - GetPlayingMusic()
  - OverrideRockAltEffects()
  - SetTransitionIcon(icon)
  - IsStage(noAlias)

- CustomGrid(name, GridEntityType, baseVariant, anm2, animation, frame, variantFrames, offset, overrideGridSpawns, overrideGridSpawnAtState, forceSpawning)

  - NAME IS NOT OPTIONAL. USED FOR IDENTIFICATION AFTER SAVING.
  - Spawn(grindex, force, reSpawning, initialPersistData): returns a new CustomGridEntity

- CustomGridEntity() -- Returned from various GetCustomGrid functions and callbacks

  - CustomGridEntity:Remove(keepBaseGrid)
  - CustomGridEntity.PersistentData -- data table automatically saved to file
  - CustomGridEntity.Data -- data table reset on new room
  - CustomGridEntity.GridIndex
  - CustomGridEntity.GridConfig -- associated CustomGrid object

- CustomDoor(name, anm2, openAnim, closeAnim, openedAnim, closedAnim, noAutoHandling, alwaysOpen)

  - NAME IS NOT OPTIONAL. USED FOR IDENTIFICATION AFTER SAVING.

- Overlay(anm2, velocity, offset, size)
  - SetAlpha(alpha, noCancelFade)
  - Fade(total, time, step): Fades from time to total incrementing by step. Use a step of -1 and a time equal to total to fade out.
  - Render(noCenterCorrect)

## Various useful tools:

```
Random(min, max, rng)
WeightedRNG(table, rng, weightKey, preCalculatedWeight)
GotoCustomStage(CustomStage, playTransition)` also accepts VanillaStage
SpawnCustomTrapdoor(position, goesTo<CustomStage>, anm2, size, alreadyEntering)

AddBossData(id, BossData): ID is needed for save / resume.
GetBossData(id)
IsDoorSlotAllowed(slot): needed in custom rooms

SpawnCustomDoor(slot, leadsToExtraRoomName, leadsToNormalRoomIndex, CustomDoorName, data(at persistData.Data), exitSlot)
SetDoorOpen(open, door)

GetCustomGridsByName(name): returns list of CustomGridIndexData
GetCustomGrids() -- returns list of CustomGridIndexData
GetCustomDoors(doorDataName): returns list of CustomGridIndexData
IsCustomGrid(index, name): if name not specified just returns if there is a custom grid at index

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
CheckPersistence(id, variant, subtype): returns PersistenceData
SetRoomFromList(roomsList, roomType, requireRoomType, isExtraRoom, load, seed, shape, fromSaveData): full room generation package. Initializes it, sets it, loads it, and returns it.
RemovePersistentEntity(entity): mapped directly to LevelRoom function of the same name

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
    AboveHud = true/false, if should render above the hud (and so vanilla streaks)
}
IsPauseMenuOpen()
GetPauseMenuAppearPct()
GetPauseMenuDarkPct()

IsIn(table, value, iterator): iterator defaults to ipairs
GetPlayingAnimation(sprite, animationList)
VectorToGrid(x, y, width)
GridToVector(index, width)
GetScreenCenterPosition()
GetScreenBottomRight()
Lerp(first, second, percent)
ReverseIterate() -- in place of ipairs / pairs.
```
