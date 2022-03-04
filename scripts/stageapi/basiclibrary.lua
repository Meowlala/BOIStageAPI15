local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

StageAPI.LogMinor("Loading Core Functions")

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
        if priority >= callback.Priority then
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
    width = width or shared.Room:GetGridWidth()
    return width + 1 + (x + width * y)
end

function StageAPI.GridToVector(index, width)
    width = width or shared.Room:GetGridWidth()
    return (index % width) - 1, (math.floor(index / width)) - 1
end

function StageAPI.GetScreenBottomRight()
    return shared.Room:GetRenderSurfaceTopLeft() * 2 + Vector(442,286)
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
    streak.SpriteOffset   = streak.SpriteOffset   or Vector.Zero
    streak.TextOffset     = streak.TextOffset     or Vector.Zero
    streak.ExtraOffset    = streak.ExtraOffset    or Vector.Zero
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
    local spriteIndex
    -- First free streak sprite, in case indices between
    -- Streaks and StreakSprites got mixed because of 
    -- streaks being removed from Streaks
    for i = 1, #Streaks + 1 do
        if not StreakSprites[i] or StreakSprites[i].Free then
            spriteIndex = i
            break
        end
    end

    streak.SpriteIndex = spriteIndex

    local streakSprite = StreakSprites[spriteIndex]
    if not streakSprite then -- this system loads as many sprites as it has to play at once
        StreakSprites[spriteIndex] = {}
        streakSprite = StreakSprites[spriteIndex]
        streakSprite.Sprite = Sprite()
        streakSprite.Sprite:Load("stageapi/streak.anm2", true)
        streakSprite.Spritesheet = streakDefaultSpritesheet
        streakSprite.Free = false
    end

    if streak.Spritesheet ~= streakSprite.Spritesheet then
        streakSprite.Spritesheet = streak.Spritesheet
        streakSprite.Sprite:ReplaceSpritesheet(0, streak.Spritesheet)
        streakSprite.Sprite:LoadGraphics()
    end

    streakSprite.Sprite.Offset = streak.SpriteOffset
    streakSprite.Sprite:Play("Text", true)
    streakSprite.Free = false

    Streaks[index] = streak

    return streak
end

StageAPI.Streaks = Streaks

function StageAPI.GetTextStreakPosForFrame(frame)
    return TextStreakPositions[frame] or 0
end

function StageAPI.GetTextStreakScaleForFrame(frame)
    return TextStreakScales[frame] or oneVector
end

function StageAPI.UpdateTextStreak()
    for index, streakPlaying in StageAPI.ReverseIterate(Streaks) do
        local streakSprite = StreakSprites[streakPlaying.SpriteIndex]
        local sprite = streakSprite.Sprite

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
            streakSprite.Free = true
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
            sprite:Render(streakPlaying.RenderPos, Vector.Zero, Vector.Zero)

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

            StageAPI.CallCallbacks("POST_STREAK_RENDER", false, streakPlaying.RenderPos, streakPlaying)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, StageAPI.UpdateTextStreak)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, StageAPI.RenderTextStreak)


function StageAPI.SpawnFloorEffect(pos, velocity, spawner, anm2, loadGraphics, variant)
    local creep = StageAPI.E.FloorEffectCreep
    local eff = Isaac.Spawn(creep.T, creep.V, creep.S, pos or Vector.Zero, velocity or Vector.Zero, spawner)
    eff.Variant = variant or StageAPI.E.FloorEffect.V

    if anm2 then
        eff:GetSprite():Load(anm2, loadGraphics)
    end

    return eff
end

function StageAPI.InStartingRoom()
    return shared.Level:GetCurrentRoomDesc().SafeGridIndex == shared.Level:GetStartingRoomIndex()
end
