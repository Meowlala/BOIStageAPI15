local shared = require("scripts.stageapi.shared")

StageAPI.LogMinor("Loading Backdrop & RoomGfx Handling")

StageAPI.BackdropRNG = RNG()

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
    local roomShape = shared.Room:GetRoomShape()
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
            walls = backdrop.WallVariants[StageAPI.Random(1, #backdrop.WallVariants, StageAPI.BackdropRNG)]
            corners = walls.Corners or backdrop.Corners
        else
            walls = backdrop.Walls
            corners = backdrop.Corners
        end

        if walls then
            for num = 1, StageAPI.ShapeToWallAnm2Layers[shapeName] do
                local wall_to_use = walls[StageAPI.Random(1, #walls, StageAPI.BackdropRNG)]
                sprite:ReplaceSpritesheet(num, wall_to_use)
            end
        end

        if corners and string.sub(shapeName, 1, 1) == "L" then
            local corner_to_use = corners[StageAPI.Random(1, #corners, StageAPI.BackdropRNG)]
            sprite:ReplaceSpritesheet(0, corner_to_use)
        end
    elseif mode == 2 then
        sprite:Load(backdrop.FloorAnm2 or "stageapi/FloorBackdrop.anm2", false)

        if backdrop.PreFloorSheetFunc then
            backdrop.PreFloorSheetFunc(sprite, backdrop, mode, shapeName)
        end

        local floors
        if backdrop.FloorVariants then
            floors = backdrop.FloorVariants[StageAPI.Random(1, #backdrop.FloorVariants, StageAPI.BackdropRNG)]
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
                    sprite:ReplaceSpritesheet(i, floors[StageAPI.Random(1, #floors, StageAPI.BackdropRNG)])
                end
            end
        end

        if backdrop.NFloors and string.sub(shapeName, 1, 1) == "I" then
            for num = 18, 19 do
                sprite:ReplaceSpritesheet(num, backdrop.NFloors[StageAPI.Random(1, #backdrop.NFloors, StageAPI.BackdropRNG)])
            end
        end

        if backdrop.LFloors and string.sub(shapeName, 1, 1) == "L" then
            for num = 16, 17 do
                sprite:ReplaceSpritesheet(num, backdrop.LFloors[StageAPI.Random(1, #backdrop.LFloors, StageAPI.BackdropRNG)])
            end
        end
    end

    sprite:LoadGraphics()

    local renderPos = shared.Room:GetTopLeftPos()
    if mode ~= 2 then
        renderPos = renderPos - Vector(80, 80)
    end

    sprite:Play(shapeName, true)

    return renderPos, needsExtra, sprite
end

function StageAPI.ChangeBackdrop(backdrop, justWalls, storeBackdropEnts)
    if type(backdrop) == "number" then
        shared.Game:ShowHallucination(0, backdrop)
        shared.Sfx:Stop(SoundEffect.SOUND_DEATH_CARD)

        return
    end

    StageAPI.BackdropRNG:SetSeed(shared.Room:GetDecorationSeed(), 1)
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

        local backdropEntity = Isaac.Spawn(StageAPI.E.Backdrop.T, StageAPI.E.Backdrop.V, 0, Vector.Zero, Vector.Zero, nil)
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

    return backdropEnts
end

StageAPI.StageShadowRNG = RNG()
function StageAPI.ChangeStageShadow(prefix, count, opacity)
    prefix = prefix or "stageapi/floors/catacombs/overlays/"
    count = count or 5
    opacity = opacity or 1

    local shadows = Isaac.FindByType(StageAPI.E.StageShadow.T, StageAPI.E.StageShadow.V, -1, false, false)
    for _, e in ipairs(shadows) do
        e:Remove()
    end

    local roomShape = shared.Room:GetRoomShape()
    local anim

    if roomShape == RoomShape.ROOMSHAPE_1x1 or roomShape == RoomShape.ROOMSHAPE_IH or roomShape == RoomShape.ROOMSHAPE_IV then anim = "1x1"
    elseif roomShape == RoomShape.ROOMSHAPE_1x2 or roomShape == RoomShape.ROOMSHAPE_IIV then anim = "1x2"
    elseif roomShape == RoomShape.ROOMSHAPE_2x1 or roomShape == RoomShape.ROOMSHAPE_IIH then anim = "2x1"
    elseif roomShape == RoomShape.ROOMSHAPE_2x2 or roomShape == RoomShape.ROOMSHAPE_LBL or roomShape == RoomShape.ROOMSHAPE_LBR or roomShape == RoomShape.ROOMSHAPE_LTL or roomShape == RoomShape.ROOMSHAPE_LTR then anim = "2x2"
    end

    if anim then
        StageAPI.StageShadowRNG:SetSeed(shared.Room:GetDecorationSeed(), 0)
        local usingShadow = StageAPI.Random(1, count, StageAPI.StageShadowRNG)
        local sheet = prefix .. anim .. "_overlay_" .. tostring(usingShadow) .. ".png"

        local shadowEntity = Isaac.Spawn(StageAPI.E.StageShadow.T, StageAPI.E.StageShadow.V, 0, Vector.Zero, Vector.Zero, nil)
        shadowEntity:GetData().Sheet = sheet
        shadowEntity:GetData().Animation = anim
        shadowEntity.Position = StageAPI.Lerp(shared.Room:GetTopLeftPos(), shared.Room:GetBottomRightPos(), 0.5)
        shadowEntity.Color = Color(1,1,1,opacity)
        shadowEntity.DepthOffset = 99999
        shadowEntity:GetSprite():ReplaceSpritesheet(0, sheet)
        shadowEntity:GetSprite():LoadGraphics()
        shadowEntity:GetSprite():SetFrame(anim, 0)
        shadowEntity:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
    end
end

---@param roomgfx RoomGfx
function StageAPI.ChangeRoomGfx(roomgfx)
    StageAPI.BackdropRNG:SetSeed(shared.Room:GetDecorationSeed(), 0)
    if roomgfx.Backdrops then
        if type(roomgfx.Backdrops) ~= "number" and #roomgfx.Backdrops > 0 then
            local backdrop = StageAPI.Random(1, #roomgfx.Backdrops, StageAPI.BackdropRNG)
            StageAPI.ChangeBackdrop(roomgfx.Backdrops[backdrop])
        else
            StageAPI.ChangeBackdrop(roomgfx.Backdrops)
        end
    end

    if roomgfx.Grids then
        StageAPI.ChangeGrids(roomgfx.Grids)
    end
end

---@param backdrops BackdropType | BackdropType[]
---@param grids GridGfx
function StageAPI.RoomGfx(backdrops, grids)
end

---@class RoomGfx
StageAPI.RoomGfx = StageAPI.Class("RoomGfx")
function StageAPI.RoomGfx:Init(backdrops, grids)
    self.Backdrops = backdrops
    self.Grids = grids
end
