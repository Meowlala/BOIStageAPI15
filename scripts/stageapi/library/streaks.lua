local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

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
local HudStreaks = {} -- render above hud

local streakFont = Font()
streakFont:Load("font/upheaval.fnt")

local streakSmallFont = Font()
streakSmallFont:Load("font/pftempestasevencondensed.fnt")

local streakDefaultHoldFrames = 52
local streakDefaultSpritesheet = "stageapi/streak.png"
local streakDefaultColor = KColor(1,1,1,1,0,0,0)
local streakDefaultPos = Vector(240, 48)

local oneVector = Vector(1, 1)
function StageAPI.PlayTextStreak(text, extratext, extratextOffset, extratextScaleMulti, replaceSpritesheet, spriteOffset, font, smallFont, color, aboveHud)
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
            Spritesheet = replaceSpritesheet,
            AboveHud = aboveHud,
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

    local streakTable = streak.AboveHud and HudStreaks or Streaks

    local index = #streakTable + 1
    local spriteIndex
    -- First free streak sprite, in case indices between
    -- Streaks and StreakSprites got mixed because of 
    -- streaks being removed from Streaks
    for i = 1, #streakTable + 1 do
        if not StreakSprites[i] or StreakSprites[i].Free then
            spriteIndex = i
            break
        end
    end
    -- Can happen very rarely with some odd combinations somehow
    if not spriteIndex then
        local highestIndex = -1
        for i, sprite in pairs(StreakSprites) do
            highestIndex = math.max(i, highestIndex)
        end
        spriteIndex = highestIndex + 1
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

    streakTable[index] = streak

    return streak
end

StageAPI.Streaks = Streaks
StageAPI.HudStreaks = HudStreaks

function StageAPI.GetTextStreakPosForFrame(frame)
    return TextStreakPositions[frame] or 0
end

function StageAPI.GetTextStreakScaleForFrame(frame)
    return TextStreakScales[frame] or oneVector
end

local function UpdateSingleStreak(streakTable, index, streakPlaying)
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
        table.remove(streakTable, index)
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

function StageAPI.UpdateTextStreak()
    for index, streakPlaying in StageAPI.ReverseIterate(Streaks) do
        UpdateSingleStreak(Streaks, index, streakPlaying)
    end
    for index, streakPlaying in StageAPI.ReverseIterate(HudStreaks) do
        UpdateSingleStreak(HudStreaks, index, streakPlaying)
    end
end

local function RenderStreaksInTable(streakTable)
    for index, streakPlaying in StageAPI.ReverseIterate(streakTable) do
        if streakPlaying.Updated then
            local sprite = StreakSprites[streakPlaying.SpriteIndex].Sprite
            sprite:Render(streakPlaying.RenderPos, Vector.Zero, Vector.Zero)

            local height = streakPlaying.Font:GetLineHeight() * streakPlaying.LineSpacing * streakPlaying.FontScale.Y
            for i, line in ipairs(streakPlaying.Text) do
                streakPlaying.Font:DrawStringScaledUTF8(line.Text,
                                                    line.PositionX + streakPlaying.TextOffset.X,
                                                    streakPlaying.RenderPos.Y - 9 + (i - 1) * height  + streakPlaying.TextOffset.Y,
                                                    streakPlaying.FontScale.X, streakPlaying.FontScale.Y,
                                                    streakPlaying.Color, 0, true)
            end
            if streakPlaying.ExtraText then
                streakPlaying.SmallFont:DrawStringScaledUTF8(streakPlaying.ExtraText, streakPlaying.ExtraPositionX + streakPlaying.ExtraOffset.X, (streakPlaying.RenderPos.Y - 9) + streakPlaying.ExtraOffset.Y, streakPlaying.FontScale.X * streakPlaying.ExtraFontScale.X, 1 * streakPlaying.ExtraFontScale.Y, streakPlaying.Color, 0, true)
            end

            StageAPI.CallCallbacks(Callbacks.POST_STREAK_RENDER, false, streakPlaying.RenderPos, streakPlaying)
        end
    end
end

function StageAPI.RenderTextStreak()
    RenderStreaksInTable(Streaks)
end

function StageAPI.RenderTextStreakHud(isPauseMenuOpen, pauseMenuDarkPct)
    -- Do not render with pause menu open, as it would render above the menu
    if isPauseMenuOpen then
        return
    end

    RenderStreaksInTable(HudStreaks)
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, StageAPI.UpdateTextStreak)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, StageAPI.RenderTextStreak)
StageAPI.AddCallback("StageAPI", Callbacks.POST_HUD_RENDER, 0, StageAPI.RenderTextStreakHud)
