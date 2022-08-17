local mod = require("scripts.stageapi.mod")

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
    if MinimapAPI and not StageAPI.LoadedMinimapAPICompat then
        StageAPI.LoadMinimapAPICompat()
        StageAPI.LoadedMinimapAPICompat = true
    end

    if not addedChangelogs and ((DeadSeaScrollsMenu and DeadSeaScrollsMenu.AddChangelog) or (REVEL and REVEL.AddChangelog and not REVEL.AddedStageAPIChangelogs)) then
        addedChangelogs = true

        if not (DeadSeaScrollsMenu and DeadSeaScrollsMenu.AddChangelog) then
            REVEL.AddedStageAPIChangelogs = true
        end

        TryAddChangelog("v2.05 - 08", [[- StageAPI now includes
an embedded version
of Mod Compatibility Hack

- A spawner entity can
now be specified for easy
placement of custom grids

- StageAPI's challenge wave
system now supports
boss challenge rooms

- Added support for Devil's
Crown treasure rooms on
custom stages

- Numerous tweaks to
custom grids to expose
more helpful features

- Fixes for custom grids
and luarooms with curse
of the maze and ascent

- Fixed movable TNT
persisting improperly

- Fixed movable fireplace
variants persisting
improperly

- Fixed door overlay
sprites being rendered
at the wrong positions

- StageAPI no longer
runs level gen code
while testing with
Basement Renovator

- Added some new commands:
"ascent" - warps to ascent
of current floor

"boss" - warps to boss

"mirror" - warps to mirror
of current room

"mineshaft" - warps to
mines escape sequence

- Improvements to StageAPI's
documentation

- Added support for Vanishing
Twin on custom bosses

- Fixed pickups with prices
persisting improperly

- Improvements to custom state
door capabilities

- Added PRE_CHANGE_GFX callbacks
for a variety of grids

- Min-Min and The Fallen rooms
are now overridden when custom
bosses replace them, fixing
mist and boss pool issues
]])

        TryAddChangelog("v2.03 - 04", [[- Fixes for extra
rooms and custom grids with
save and continue.

- POST_UPDATE_GRID_GFX callback.

- Improved error handling with
StageAPI callbacks.

- Fixed challenge waves with
persistent entities.

- Fixes for boss pools on
XL floors.

- Bosses overriding The Heretic
no longer spawn a pentagram.

- Improvements to StageAPI room
editor utilities

- Fix for a mod compatibility issue
with floor layout change detection

- Further fixes for custom grids
not loading properly
]])

        TryAddChangelog("v2.02", [[- Split StageAPI into
multiple files.

- Added support for
custom stages in
Greed Mode.

- Added above-HUD
rendering capabilities,
which are used to
render stage streaks now.
This means stage streaks
should now render
properly at all times
rather than as I or II.

- Added custom challenge room
music support for
custom stages.

- StageAPI no longer
overrides the names of
Catacombs, Necropolis, and
Utero.

- Fixed a large number of
typos that may have
caused some bugs

- Fixes for versus screen
should make it more
accurate to the base game

- Fixed Blood Puppy and
Luna light beams being
removed when entering
lua rooms.
]])

        TryAddChangelog("v2.01", [[- Lots of bug fixes

- Removed starting room
controls override

- Updated AddPlayerGraphicsInfo
and related features for
compatibility with
Repentance portraits
]])

        TryAddChangelog("v2.0", [[- StageAPI now supports
Custom Floor Generation,
implemented via
a new LevelMap System.

- Most extra room
functionality has been
replaced by LevelMaps,
including extending base
floors with StageAPI's
DefaultLevelMap.

- Every shape of every
room type that is
used in the base
game is now preloaded
and usable in extra
rooms. Additional shapes
or types can be
requested by mods via
a function.

- Custom Grid Entities
have been overhauled.
Each CustomGridEntity in
a room is now
its own object.
This enables things
like custom effects for
Polties and
Mom's Bracelet.
Additional support
has also been added
for Dirty Mind and
Poop Gibs.

- Metadata Entities
have been overhauled.
Each Metadata Entity
in a room is now
its own object.
This simplifies searching
for Metadata Entities,
which is now done
with a single function.

- Metadata Entities can
now take advantage of
their Subtype, allowing
room editor defined
variation. For instance,
Groups can now be
given any 16-bit
integer ID.

- Added new
Metadata Entities:

-- Entered From Trigger.
Triggers the associated
group ID when the
player enters the room
near its position.
Can be used to
change the layout
of rooms depending
on which door you
enter from.

-- Shop Item Modifier.
When placed on a
pickup, turns it
into a shop item
with a specified
price.

-- Options Pickup Modifier.
When placed on
pickups, turns them
into an Options
group of a
specified ID.
You can only pick
one pickup from
the group.

-- Cancel Clear Award.
Disables the room's
clear award.

-- Set Player Position.
Sets the player's
position when the
room is entered.
Can be set to
only occur when
the room is not
yet cleared.

-- Button Trigger.
Reimplements
Event Buttons from
the base game, as
a trigger tied
to a group.

-- Boss Identifier.
When placed on a
boss, attempts to
locate the StageAPI
definition of that
boss, and convert the
boss room into a
StageAPI boss room
for that boss ID.
Mostly useful to
play the right boss
animation for extra
boss rooms or
modded bosses.

-- Room.
Custom LevelMaps can
be loaded from a
room file. The Room
Metadata Entity
indicates which room
to load and where
to put it on
the LevelMap.

-- Stage.
Allows setting the
stage of rooms on
a LevelMap room file,
when placed overlapping
a Room entity.
Alternatively, if
placed not overlapping
any entity, sets the
default stage for
ALL Room entities

- Rooms with Metadata
Entities are now
automatically taken
over by StageAPI, and
thus functional on
base game floors

- Updated all of
the icons for
StageAPI editor
entities.

- Custom Floors now
support pre-generation
of rooms, rather than
generating each room
as you enter it,
optionally.

- Added a custom boss
pool system that
enables multiple mods
to add bosses to
the same floor via
StageAPI's pool.

- Improved entity and
grid persistence in
extra rooms significantly
]])

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
