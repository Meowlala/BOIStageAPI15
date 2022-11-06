local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

StageAPI.LogMinor("Loading Transition Handler")

StageAPI.StageTypeToString = {
    [StageType.STAGETYPE_ORIGINAL] = "",
    [StageType.STAGETYPE_WOTL] = "a",
    [StageType.STAGETYPE_AFTERBIRTH] = "b",
    [StageType.STAGETYPE_REPENTANCE] = "c",
    [StageType.STAGETYPE_REPENTANCE_B] = "d"
}

StageAPI.BaseStageTypes = {
    StageType.STAGETYPE_ORIGINAL,
    StageType.STAGETYPE_WOTL,
    StageType.STAGETYPE_AFTERBIRTH,
}

StageAPI.AltPathStageTypes = {
    StageType.STAGETYPE_REPENTANCE,
    StageType.STAGETYPE_REPENTANCE_B
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
StageAPI.ExtraPortrait = Sprite()

StageAPI.RemovedHUD = false
StageAPI.TransitionIsPlaying = false

StageAPI.Seeds = shared.Game:GetSeeds()
StageAPI.HUD = shared.Game:GetHUD()

StageAPI.BlackScreenOverlay = Sprite()
StageAPI.BlackScreenOverlay:Load("stageapi/overlay_black.anm2", false)
StageAPI.BlackScreenOverlay:ReplaceSpritesheet(0, "stageapi/overlay_black.png")
StageAPI.BlackScreenOverlay:LoadGraphics()
StageAPI.BlackScreenOverlay:Play("Idle", true)
function StageAPI.RenderBlackScreen(alpha)
    alpha = alpha or 1
    StageAPI.BlackScreenOverlay.Scale = StageAPI.GetScreenScale(true) * 8
    StageAPI.BlackScreenOverlay.Color = Color(1, 1, 1, alpha, 0, 0, 0)
    StageAPI.BlackScreenOverlay:Render(StageAPI.GetScreenCenterPosition(), Vector.Zero, Vector.Zero)
end

StageAPI.ShakeOffset = -1
StageAPI.ShakeOffsetInc = 1 -- Inc = Increment
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if StageAPI.TransitionAnimation:IsPlaying("Scene") or StageAPI.TransitionAnimation:IsPlaying("SceneNoShake") or StageAPI.TransitionAnimation:IsPlaying("Intro") then
        if StageAPI.IsOddRenderFrame then
            StageAPI.TransitionAnimation:Update()
            StageAPI.ExtraPortrait:Update()

            StageAPI.ShakeOffset = StageAPI.ShakeOffset + StageAPI.ShakeOffsetInc
            if StageAPI.ShakeOffset >= 1 then
                StageAPI.ShakeOffsetInc = -1
            elseif StageAPI.ShakeOffset <= -1 then
                StageAPI.ShakeOffsetInc = 1
            end
        end

        local stop
        for _, player in ipairs(shared.Players) do
            player.ControlsCooldown = 80

            if Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, player.ControllerIndex) or
            Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, player.ControllerIndex) then
                stop = true
            end
        end

        -- Animate player appearance after stage transition animation is finished playing or cancelled
        if stop or StageAPI.TransitionAnimation:IsEventTriggered("LastFrame") then
            for _, player in ipairs(shared.Players) do
                if not shared.Game:IsGreedMode() then
                    player.Position = shared.Room:GetCenterPos()
                else
                    player.Position = shared.Room:GetGridPosition(67)
                end
                player:AnimateAppear()
            end

            StageAPI.TransitionAnimation:Stop()
        end

        StageAPI.TransitionIsPlaying = true
        StageAPI.RenderBlackScreen()
        StageAPI.TransitionAnimation:Render(StageAPI.GetScreenCenterPosition(), Vector.Zero, Vector.Zero)
        StageAPI.ExtraPortrait:Render(StageAPI.GetScreenCenterPosition() + Vector(-72 + StageAPI.ShakeOffset, -19)--[[Magic trial and error numbers to make it work without adjusting anm2 files]], Vector.Zero, Vector.Zero)
    elseif StageAPI.TransitionIsPlaying then -- Finished transition
        StageAPI.TransitionIsPlaying = false
        if StageAPI.CurrentStage then
            local name = StageAPI.CurrentStage:GetDisplayName()
            StageAPI.PlayTextStreak{
                Text = name,
                AboveHud = true,
            }
        end
    end

    if StageAPI.IsHUDAnimationPlaying() then
        if StageAPI.HUD:IsVisible() then
            StageAPI.HUD:SetVisible(false)
            StageAPI.RemovedHUD = true
        end
    elseif not StageAPI.HUD:IsVisible() and StageAPI.RemovedHUD then
        StageAPI.HUD:SetVisible(true)
        StageAPI.RemovedHUD = false
    end
end)

function StageAPI.IsHUDAnimationPlaying(spriteOnly)
    return StageAPI.TransitionAnimation:IsPlaying("Scene")
    or StageAPI.TransitionAnimation:IsPlaying("SceneNoShake")
    or StageAPI.TransitionAnimation:IsPlaying("Intro")
    or StageAPI.BossSprite:IsPlaying("Scene")
    or StageAPI.BossSprite:IsPlaying("DoubleTrouble")
    or (
        shared.Room:GetType() == RoomType.ROOM_BOSS
        and shared.Room:GetFrameCount() <= 0
        and not shared.Room:IsClear()
        and shared.Game:IsPaused()
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
    local floorInfo = StageAPI.GetBaseFloorInfo()
    if not floorInfo then
        return "stageapi/none.png"
    end

    local base = floorInfo.Prefix
    if base == "07_womb" and stype == StageType.STAGETYPE_WOTL then
        base = "utero"
    end

    return "stageapi/transition/levelicons/" .. base .. ".png"
end

function StageAPI.PlayTransitionAnimationManual(portrait, icon, ground, bg, transitionmusic, queue, noshake, extraportrait)
    portrait = portrait or "gfx/ui/stage/playerportrait_isaac.png"
    icon = icon or "stageapi/transition/levelicons/unknown.png"
    ground = ground or "stageapi/transition/bossspot_01_basement.png"
    bg = bg or "stageapi/transition/nightmares_bg_mask.png"
    transitionmusic = transitionmusic or Music.MUSIC_JINGLE_NIGHTMARE

    if queue ~= false then
        queue = queue or shared.Music:GetCurrentMusicID()
    end

    StageAPI.TransitionAnimation:ReplaceSpritesheet(3, ground)
    StageAPI.TransitionAnimation:ReplaceSpritesheet(1, bg)
    if noshake then
        StageAPI.TransitionAnimation:ReplaceSpritesheet(6, portrait)
        StageAPI.TransitionAnimation:ReplaceSpritesheet(2, "none.png")
    else
        StageAPI.TransitionAnimation:ReplaceSpritesheet(2, portrait)
        StageAPI.TransitionAnimation:ReplaceSpritesheet(6, "none.png")
    end
    StageAPI.TransitionAnimation:ReplaceSpritesheet(7, icon)
    StageAPI.TransitionAnimation:LoadGraphics()
    StageAPI.TransitionAnimation:Play("Intro", true)

    if extraportrait then
        StageAPI.ExtraPortrait:Load(extraportrait, true)
        StageAPI.ExtraPortrait:Play("Idle", true)
    else
        StageAPI.ExtraPortrait = Sprite()
    end

    StageAPI.ShakeOffset = -1
    StageAPI.ShakeOffsetInc = 1

    shared.Music:Play(transitionmusic, 0)
    shared.Music:UpdateVolume()

    if queue ~= false then
        shared.Music:Queue(queue)
    end
end

function StageAPI.PlayTransitionAnimation(stage)
    local gfxData = StageAPI.TryGetPlayerGraphicsInfo(shared.Players[1])
    StageAPI.PlayTransitionAnimationManual(gfxData.Portrait, stage.TransitionIcon, stage.TransitionGround, stage.TransitionBackground, stage.TransitionMusic, stage.Music and stage.Music[RoomType.ROOM_DEFAULT], gfxData.NoShake, gfxData.ExtraPortrait)
end

StageAPI.StageRNG = RNG()
function StageAPI.GotoCustomStage(stage, playTransition, noForgetSeed)
    if not noForgetSeed then
        local realstage, realStageType
        if stage.NormalStage then
            realstage = stage.Stage
            realStageType = stage.StageType
        else
            if stage.LevelgenStage then
                realstage = stage.LevelgenStage.Stage
                realStageType = stage.LevelgenStage.StageType
            else
                realstage = stage.Replaces.OverrideStage
                realStageType = stage.Replaces.OverrideStageType
            end
        end

        if realStageType == StageType.STAGETYPE_REPENTANCE or realStageType == StageType.STAGETYPE_REPENTANCE_B then
            StageAPI.Seeds:ForgetStageSeed(realstage + 1)
        else
            StageAPI.Seeds:ForgetStageSeed(realstage)
        end
    end

    if stage.NormalStage then
        local stageType = stage.StageType
        if not stageType then
            StageAPI.StageRNG:SetSeed(StageAPI.Seeds:GetStageSeed(stage.Stage), 0)

            if stage.AltPath then
                stageType = StageAPI.AltPathStageTypes[StageAPI.Random(1, #StageAPI.AltPathStageTypes, StageAPI.StageRNG)]
            else
                stageType = StageAPI.BaseStageTypes[StageAPI.Random(1, #StageAPI.BaseStageTypes, StageAPI.StageRNG)]
            end
        end

        if playTransition then
            local gfxData = StageAPI.TryGetPlayerGraphicsInfo(shared.Players[1])
            local floorInfo = StageAPI.GetBaseFloorInfo()
            local ground
            if floorInfo then
                ground = "gfx/ui/boss/bossspot_" .. floorInfo.Prefix .. ".png"
            else
                ground = "stageapi/none.png"
            end

            local bg = "stageapi/transition/nightmares_bg_mask.png"
            StageAPI.PlayTransitionAnimationManual(gfxData.Portrait, StageAPI.GetLevelTransitionIcon(stage.Stage, stageType), ground, bg, nil, nil, gfxData.NoShake)
        end

        Isaac.ExecuteCommand("stage " .. tostring(stage.Stage) .. StageAPI.StageTypeToString[stageType])
    else
        local replace = stage.Replaces
        local absolute = replace.OverrideStage
        StageAPI.NextStage = stage
        if playTransition then
            StageAPI.PlayTransitionAnimation(stage)
        end

        if stage.LevelgenStage then
            Isaac.ExecuteCommand("stage " .. tostring(stage.LevelgenStage.Stage) .. StageAPI.StageTypeToString[stage.LevelgenStage.StageType])
        else
            Isaac.ExecuteCommand("stage " .. tostring(absolute) .. StageAPI.StageTypeToString[replace.OverrideStageType])
        end
    end
end

function StageAPI.SpawnCustomTrapdoor(position, goesTo, anm2, size, alreadyEntering)
    anm2 = anm2 or "gfx/grid/door_11_trapdoor.anm2"
    size = size or 24
    local trapdoor = Isaac.Spawn(StageAPI.E.FloorEffectCreep.T, StageAPI.E.FloorEffectCreep.V, StageAPI.E.FloorEffectCreep.S, position, Vector.Zero, nil)
    trapdoor.Variant = StageAPI.E.Trapdoor.V
    trapdoor.SubType = StageAPI.E.Trapdoor.S
    trapdoor.Size = size
    local sprite, data = trapdoor:GetSprite(), trapdoor:GetData()
    sprite:Load(anm2, true)

    if alreadyEntering then
        sprite:Play("Opened", true)
        data.BeingEntered = true
        for _, player in ipairs(shared.Players) do
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
    elseif (sprite:IsPlaying("Closed") or sprite:IsFinished("Closed")) and shared.Room:IsClear() then
        local playerTooClose
        for _, player in ipairs(shared.Players) do
            local size = (eff.Size + player.Size + 40)
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
            for _, player in ipairs(shared.Players) do
                local size = (eff.Size + player.Size)
                if player.Position:DistanceSquared(eff.Position) < size * size then
                    touchingTrapdoor = true
                end
            end

            if touchingTrapdoor then
                data.BeingEntered = true
                for _, player in ipairs(shared.Players) do
                    player:AnimateTrapdoor()
                end
            end
        else
            local animationOver
            for _, player in ipairs(shared.Players) do
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
