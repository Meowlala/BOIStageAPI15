local shared = require("scripts.stageapi.shared")

StageAPI.LogMinor("Loading Overlay System")

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

            sprite:Render(pos, Vector.Zero, Vector.Zero)
            if StageAPI.DebugTiling then
                timesRendered = timesRendered + 1
                Isaac.RenderText("RenderPoint (" .. tostring(timesRendered) .. "): " .. tostring(x) .. ", " .. tostring(y), pos.X, pos.Y, 255, 0, 0, 1)
            end
        end
    end
end

StageAPI.OverlayDefaultSize = Vector(512, 512)

---@param file string
---@param velocity? Vector
---@param offset? Vector
---@param size? Vector
---@param alpha? number
function StageAPI.Overlay(file, velocity, offset, size, alpha)
end

---@class StageAPIOverlay
StageAPI.Overlay = StageAPI.Class("Overlay")
function StageAPI.Overlay:Init(file, velocity, offset, size, alpha)
    self.Sprite = Sprite()
    self.Sprite:Load(file, true)
    self.Sprite:Play("Idle", true)
    self.Position = Vector.Zero
    self.Velocity = velocity or Vector.Zero
    self.Offset = offset or Vector.Zero
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

    StageAPI.RenderSpriteTiled(self.Sprite, self.Position + (self.Offset or Vector.Zero) + (additionalOffset or Vector.Zero), self.Size, centerCorrect)

    if StageAPI.DebugTiling then
        Isaac.RenderText("OriginPoint: " .. tostring(self.Position.X) .. ", " .. tostring(self.Position.Y), self.Position.X, self.Position.Y, 0, 255, 0, 1)
    end
end