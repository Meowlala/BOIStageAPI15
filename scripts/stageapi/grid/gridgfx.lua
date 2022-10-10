local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading GridGfx Handler")

---@class GridGfx : StageAPIClass
---@field Decorations GridGfx.Decorations
---@field private Pits GridGfx.PitFile?
---@field private AltPits GridGfx.PitFile?
---@operator call : GridGfx
StageAPI.GridGfx = StageAPI.Class("GridGfx")

---@class GridGfx.PitFile
---@field File string
---@field HasExtraFrames boolean?

---@class GridGfx.Decorations
---@field Png string
---@field Anm2 string
---@field PropCount integer
---@field Prefix string
---@field Suffix string


function StageAPI.GridGfx:Init()
    self.Grids = false
    self.Doors = false
end

---@param filename string
---@param noBridge? boolean
function StageAPI.GridGfx:SetRocks(filename, noBridge)
    self.Rocks = filename

    if not self.Bridges and not noBridge then
        self.Bridges = filename
    end
end

---@param filename string
---@param t GridEntityType
---@param v integer?
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

---@param filenames string | GridGfx.PitFile[]
---@param alts string | GridGfx.PitFile[] | nil
---@param hasExtraFrames? boolean
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

---@param filename string
function StageAPI.GridGfx:SetBridges(filename)
    self.Bridges = filename
end

---@param filename string
---@param anm2? string
---@param propCount? integer
---@param prefix? string
---@param suffix? string
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

StageAPI.GridGfxRNG = RNG()

---@param rock StageAPI.GridGfxReplaceData
---@param filename string
function StageAPI.ChangeRock(rock, filename)
    local grid = rock.Grid

    filename = StageAPI.CallCallbacksWithParams(Callbacks.PRE_CHANGE_ROCK_GFX, true, 
        StageAPI.GetCurrentStage(),
        grid, rock.Index, filename
    ) or filename

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

---@param pit StageAPI.GridGfxReplaceData
---@param pitFile GridGfx.PitFile?
---@param bridgefilename string?
---@param alt GridGfx.PitFile?
function StageAPI.ChangePit(pit, pitFile, bridgefilename, alt)
    local grid = pit.Grid
    local gsprite = grid:GetSprite()

    local callbacks = StageAPI.GetCallbacks(Callbacks.PRE_CHANGE_PIT_GFX)
    for _, callback in ipairs(callbacks) do
        local succ, pitFileReturn, bridgeFilenameReturn, altReturn 
            = StageAPI.TryCallbackMultiReturnParams(callback, 
                StageAPI.GetCurrentStage(),
                grid, pit.Index, pitFile, bridgefilename, alt
            )
        if succ and (pitFileReturn or bridgeFilenameReturn or altReturn) then
            pitFile = pitFileReturn
            bridgefilename = bridgeFilenameReturn
            alt = altReturn
            break
        end
    end

    if pitFile then
        if gsprite:GetFilename() ~= "stageapi/pit.anm2" then
            gsprite:Load("stageapi/pit.anm2", true)
        end

        if alt and shared.Room:HasWaterPits() then
            gsprite:ReplaceSpritesheet(0, alt.File)
        else
            gsprite:ReplaceSpritesheet(0, pitFile.File)
        end
    end

    if bridgefilename then
        gsprite:ReplaceSpritesheet(1, bridgefilename)
    end

    gsprite:LoadGraphics()
end

---@param decoration StageAPI.GridGfxReplaceData
---@param decorations GridGfx.Decorations
function StageAPI.ChangeDecoration(decoration, decorations)
    local grid = decoration.Grid

    decorations = StageAPI.CallCallbacksWithParams(Callbacks.PRE_CHANGE_DECORATION_GFX, true, 
        StageAPI.GetCurrentStage(),
        grid, decoration.Index, decorations
    ) or decorations

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

---@class DoorInfo
---@field RequireCurrent RoomType[]
---@field RequireTarget RoomType[]
---@field RequireEither RoomType[]
---@field NotCurrent RoomType[]
---@field NotTarget RoomType[]
---@field NotEither RoomType[]

---@alias DoorSprites {[string] : (DoorSprite | string | {[RoomType]: string })}
--[[
DoorSprites
{
    -- Can be paired with the type of the current room
    Default = {
        [RoomType.ROOM_ANGEL] = "angel_door.png",
        [RoomType.ROOM_DEFAULT] = "default_door.png"
    },

    -- Can be a direct definition
    Angel = "angel_door.png",

    -- The table can be more detailed if you need to change the anm2 of the door or extra sprites
    Secret = {
        Anm2 = "secret_darkroom.anm2",
        Sprite = "secret_darkroom.png",
        ExtraAnm2 = "doublelock.anm2",
        ExtraSprite = "doublelock.png",
        LoadGraphics = false
    }
}
]]

---@class DoorSprite
---@field Anm2 string
---@field Sprite string
---@field ExtraAnm2 string
---@field ExtraSprite string
---@field LoadGraphics boolean

---@class DoorSpawn : DoorInfo
---@field IsBossAmbush boolean
---@field IsPayToPlay boolean
---@field IsSurpriseMiniboss boolean
---@field RequireVarData integer
---@field RequireTargetIndex integer
---@field Sprite string
---@field StateDoor string

---@param doorSprites DoorSprites
function StageAPI.GridGfx:SetDoorSprites(doorSprites)
    self.DoorSprites = doorSprites
end

---@param doorSpawns DoorSpawn[]
function StageAPI.GridGfx:SetDoorSpawns(doorSpawns)
    self.DoorSpawns = doorSpawns
end

-- legacy door system
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

---@param filename string
function StageAPI.GridGfx:SetPayToPlayDoor(filename)
    self.PayToPlayDoor = filename
end

---@param door GridEntity | Entity
---@param spriteData DoorSprite | string | string[]
function StageAPI.ChangeDoorSprite(door, spriteData)
    local sprite1, sprite2
    if door.ToDoor then -- is grid
        door = door:ToDoor()
        sprite1, sprite2 = door:GetSprite(), door.ExtraSprite
    else -- is custom door
        sprite1, sprite2 = door:GetSprite(), door:GetData().OverlaySprite
    end

    local replace1, replace2
    if type(spriteData) == "string" then
        replace1 = spriteData
    elseif spriteData[1] ~= nil or spriteData[2] ~= nil then
        replace1 = spriteData[1]
        replace2 = spriteData[2]
    else
        replace1 = spriteData.Sprite
        replace2 = spriteData.ExtraSprite

        if spriteData.Anm2 then
            local anim, frame = sprite1:GetAnimation(), sprite1:GetFrame()
            sprite1:Load(spriteData.Anm2, spriteData.LoadGraphics or false)
            sprite1:Play(anim, true)
            sprite1:SetFrame(frame)
        end

        if spriteData.ExtraAnm2 then
            local anim, frame = sprite2:GetAnimation(), sprite2:GetFrame()
            sprite2:Load(spriteData.ExtraAnm2, spriteData.LoadGraphics or false)
            sprite2:Play(anim, true)
            sprite2:SetFrame(frame)
        end
    end

    if replace1 then
        for i = 0, 5 do
            sprite1:ReplaceSpritesheet(i, replace1)
        end

        sprite1:LoadGraphics()
    end

    if replace2 then
        for i = 0, 5 do
            sprite2:ReplaceSpritesheet(i, replace2)
        end

        sprite2:LoadGraphics()
    end

    if door.ToDoor then
        door.ExtraSprite = sprite2
    end
end

-- TODO: consider deprecating passing door into DoesDoorMatch
---@param door any TODO: consider deprecating passing door into DoesDoorMatch
---@param doorSpawn DoorSpawn
---@param current RoomType
---@param target RoomType
---@param isBossAmbush? boolean
---@param isPayToPlay? boolean
---@param isSurpriseMiniboss? boolean
---@param varData? integer
---@param targetIndex? integer
---@return boolean
function StageAPI.DoesDoorMatch(door, doorSpawn, current, target, isBossAmbush, isPayToPlay, isSurpriseMiniboss, varData, targetIndex)
    -- REVEL.DebugLog(("DoesDoorMatch | cur %s ; target %s ; FLATFILE %s ; spawn : %s"):format(current, target, isFlatfiled, REVEL.ToString(doorSpawn)))

    current = current or door.CurrentRoomType
    target = target or door.TargetRoomType
    local valid = true
    if doorSpawn.RequireCurrent then
        local has = false
        for _, roomType in ipairs(doorSpawn.RequireCurrent) do
            if current == roomType then
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

    if valid and doorSpawn.IsSurpriseMiniboss ~= nil then
        if doorSpawn.IsSurpriseMiniboss then
            valid = not not isSurpriseMiniboss
        else
            valid = not isSurpriseMiniboss
        end
    end

    if valid and doorSpawn.IsBossAmbush ~= nil then
        if doorSpawn.IsBossAmbush then
            valid = not not isBossAmbush
        else
            valid = not isBossAmbush
        end
    end

    if valid and doorSpawn.IsPayToPlay ~= nil then
        if doorSpawn.IsPayToPlay then
            valid = not not isPayToPlay
        else
            valid = not isPayToPlay
        end
    end

    if valid and doorSpawn.RequireVarData then
        valid = varData == doorSpawn.RequireVarData
    end
    
    if valid and doorSpawn.RequireTargetIndex then
        valid = targetIndex == doorSpawn.RequireTargetIndex
    end

    return valid
end

StageAPI.DoorSprite = Sprite()
function StageAPI.ChangeDoor(door, doors, payToPlay)
    local grid = door.Grid:ToDoor()
    local gsprite = grid:GetSprite()
    local current, target = grid.CurrentRoomType, grid.TargetRoomType
    local isBossAmbush, isPayToPlay = shared.Level:HasBossChallenge(), grid:IsTargetRoomArcade() and target ~= RoomType.ROOM_ARCADE
    local varData = grid.VarData
    local targetIndex = grid.TargetRoomIndex

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
        if StageAPI.DoesDoorMatch(
            grid, doorOption, current, target, 
            isBossAmbush, isPayToPlay, false,
            varData, targetIndex
        ) then
            for i = 0, 5 do
                gsprite:ReplaceSpritesheet(i, doorOption.File)
            end

            gsprite:LoadGraphics()

            break
        end
    end
end

---@param doorSpawns DoorSpawn[]
---@param current RoomType
---@param target RoomType
---@param isBossAmbush? boolean
---@param isPayToPlay? boolean
---@param isSurpriseMiniboss? boolean
---@param varData? integer
---@param targetIndex? integer
---@return string useSprite
---@return string useDoor
function StageAPI.CompareDoorSpawns(doorSpawns, current, target, isBossAmbush, isPayToPlay, isSurpriseMiniboss, varData, targetIndex)
    local useSprite, useDoor
    for _, spawn in ipairs(doorSpawns) do
        if StageAPI.DoesDoorMatch(
            nil, spawn, current, target, 
            isBossAmbush, isPayToPlay, isSurpriseMiniboss,
            varData, targetIndex
        ) then
            useSprite = spawn.Sprite
            useDoor = spawn.StateDoor
            break
        end
    end

    return useSprite, useDoor
end

---@param door GridEntity | Entity
---@param doorSpawns DoorSpawn[]
---@param doorSprites DoorSprites
---@param roomType? RoomType
function StageAPI.CheckDoorSpawns(door, doorSpawns, doorSprites, roomType)
    local useSprite
    if door.ToDoor then
        ---@type GridEntityDoor
        door = door:ToDoor()
        local current, target = door.CurrentRoomType, door.TargetRoomType
        local isBossAmbush, isPayToPlay = shared.Level:HasBossChallenge(), door:IsTargetRoomArcade() and target ~= RoomType.ROOM_ARCADE
        local isSurpriseMiniboss = shared.Level:GetCurrentRoomDesc().SurpriseMiniboss
        local varData = door.VarData
        local targetRoomIndex = door.TargetRoomIndex

        useSprite = StageAPI.CompareDoorSpawns(
            doorSpawns, current, target, 
            isBossAmbush, isPayToPlay, isSurpriseMiniboss,
            varData, targetRoomIndex
        )
    else
        local data = door:GetData()
        if data.DoorSprite then
            useSprite = data.DoorSprite
        end

        if data.DoorData.DoorSprite then
            useSprite = data.DoorData.DoorSprite
        end
    end

    if useSprite and doorSprites[useSprite] then
        local spriteData = doorSprites[useSprite]
        local changeSprite
        if type(spriteData) == "table" then
            ---@diagnostic disable-next-line: undefined-field
            if spriteData.Sprite or spriteData.ExtraSprite or spriteData.Anm2 or spriteData.ExtraAnm2 then
                changeSprite = spriteData
            else
                changeSprite = spriteData[roomType or StageAPI.GetCurrentRoomType()]
            end
        else
            changeSprite = spriteData
        end

        if changeSprite then
            StageAPI.ChangeDoorSprite(door, changeSprite)
        end
    end
end

function StageAPI.ChangeGrid(sent, filename)
    local grid = sent.Grid
    local sprite = grid:GetSprite()

    if type(filename) == "table" then
        filename = filename[StageAPI.Random(1, #filename, StageAPI.GridGfxRNG)]
    end

    filename = StageAPI.CallCallbacksWithParams(Callbacks.PRE_CHANGE_MISC_GRID_GFX, true, 
        StageAPI.GetCurrentStage(),
        grid, sent.Index, filename
    ) or filename

    sprite:ReplaceSpritesheet(0, filename)
    sprite:LoadGraphics()
end

---@class StageAPI.GridGfxReplaceData
---@field Grid GridEntity
---@field Index integer
---@field Type GridEntityType
---@field Desc GridEntityDesc

---@param grid GridEntity
---@param grids GridGfx
---@param i integer
function StageAPI.ChangeSingleGrid(grid, grids, i)
    local desc = grid.Desc
    local gtype = desc.Type
    local send = {Grid = grid, Index = i, Type = gtype, Desc = desc}
    if gtype == GridEntityType.GRID_DOOR and (grids.Doors or grids.DoorSpawns or grids.DoorSprites) then
        if grids.Doors then
            StageAPI.ChangeDoor(send, grids.Doors, grids.PayToPlayDoor)
        else
            StageAPI.CheckDoorSpawns(grid, grids.DoorSpawns, grids.DoorSprites)
        end
    elseif StageAPI.RockTypes[gtype] and grids.Rocks then
        StageAPI.ChangeRock(send, grids.Rocks)
    elseif gtype == GridEntityType.GRID_PIT and (grids.Pits or grids.Bridges) then
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
        local doorSpawns, doorSprites
        local payToPlay
        local gridGfx
        if doors.Type == "GridGfx" then
            gridGfx = doors
        elseif doors.Type == "CustomStage" and doors.RoomGfx then
            local roomgfx = doors.RoomGfx[StageAPI.GetCurrentRoomType()]
            if roomgfx and roomgfx.Grids then
                gridGfx = roomgfx.Grids
            end
        elseif doors.Type == "RoomGfx" and doors.Grids then
            gridGfx = doors.Grids
        end

        if gridGfx then
            doorSpawns = gridGfx.DoorSpawns
            doorSprites = gridGfx.DoorSprites
            payToPlay = gridGfx.PayToPlayDoor
            doors = gridGfx.Doors
        end

        if doorSpawns or doorSprites then
            for i = 0, 7 do
                local door = shared.Room:GetDoor(i)
                if door then
                    StageAPI.CheckDoorSpawns(door, doorSpawns, doorSprites)
                end
            end

            for _, door in ipairs(Isaac.FindByType(StageAPI.E.Door.T, StageAPI.E.Door.V, -1, false, false)) do
                StageAPI.CheckDoorSpawns(door, doorSpawns, doorSprites)
            end
        elseif doors then
            for i = 0, 7 do
                local door = shared.Room:GetDoor(i)
                if door then
                    StageAPI.ChangeDoor({Grid = door}, doors, payToPlay)
                end
            end
        end
    end
end

---@param grids GridGfx
function StageAPI.ChangeGrids(grids)
    StageAPI.GridGfxRNG:SetSeed(shared.Room:GetDecorationSeed(), 0)

    local doneDoors
    if grids.Doors or grids.DoorSpawns or grids.DoorSprites then
        StageAPI.ChangeDoors(grids)
        doneDoors = true
    end

    if grids.PitFiles then
        grids.Pits = grids.PitFiles[StageAPI.Random(1, #grids.PitFiles, StageAPI.GridGfxRNG)]
    end
    if grids.AltPitFiles then
        grids.AltPits = grids.AltPitFiles[StageAPI.Random(1, #grids.AltPitFiles, StageAPI.GridGfxRNG)]
    end

    local pitsToUse = shared.Room:HasWaterPits() and grids.AltPits or grids.Pits
    local hasExtraPitFrames = pitsToUse and pitsToUse.HasExtraFrames

    local gridCount = 0
    local pits = {}
    for i = 0, shared.Room:GetGridSize() do
        local customGrids = StageAPI.GetCustomGrids(i)
        local customGridBlocking = false
        for _, cgrid in ipairs(customGrids) do
            if not cgrid.GridConfig.NoOverrideGridSprite then
                customGridBlocking = true
            end
        end

        if not customGridBlocking then
            local grid = shared.Room:GetGridEntity(i)
            if grid then
                if hasExtraPitFrames and grid.Desc.Type == GridEntityType.GRID_PIT then
                    pits[i] = grid
                elseif grid.Desc.Type ~= GridEntityType.GRID_DOOR or not doneDoors then
                    StageAPI.ChangeSingleGrid(grid, grids, i)
                end
            end
        end
    end

    StageAPI.CallGridPostInit()

    if hasExtraPitFrames and next(pits) then
        local width = shared.Room:GetGridWidth()
        for index, pit in pairs(pits) do
            StageAPI.ChangePit({Grid = pit, Index = index}, grids.Pits, grids.Bridges, grids.AltPits)
            local sprite = pit:GetSprite()

            local adj = {index - 1, index + 1, index - width, index + width, index - width - 1, index + width - 1, index - width + 1, index + width + 1}
            local adjPits = {}
            for _, ind in ipairs(adj) do
                local grid = shared.Room:GetGridEntity(ind)
                adjPits[#adjPits + 1] = not not (grid and grid.Desc.Type == GridEntityType.GRID_PIT)
            end

            adjPits[#adjPits + 1] = true
            sprite:SetFrame("pit", StageAPI.GetPitFrame(table.unpack(adjPits)))
        end
    end
end