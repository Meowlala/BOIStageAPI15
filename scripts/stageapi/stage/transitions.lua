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

StageAPI.TransitionNightmares = {}
for i = 1, 17 do
    StageAPI.TransitionNightmares[i] = "gfx/ui/stage/nightmare" .. i .. ".anm2"
end

function StageAPI.AddTransitionNightmare(anm)
    if type(anm) == 'string' then
        StageAPI.TransitionNightmares[#StageAPI.TransitionNightmares+1] = anm
    end
end

local IntroAlpha = {[0] = 0,[2] = 0.02,[4] = 0.04,[6] = 0.06,[8] = 0.24,[10] = 0.47,[12] = 0.7,[14] = 0.78,[16] = 0.86,[18] = 1,}
local ExtraPortraitOffsets = {
    [false] = {
        [0] = Vector(-73,-19),
        [1] = Vector(-72,-19),
        [2] = Vector(-71,-19),
        [3] = Vector(-72,-19), 
    },
    [true] = {
        [0] = Vector(-72,-19),
    }
}

local SetBlockCallbacks
local BlockCallbacks = {
    {ModCallbacks.MC_ENTITY_TAKE_DMG , function() --PlayerDamageBlockCallback
        if StageAPI.TransitionAnimationData.State ~= 0 then
            return false
        else
            SetBlockCallbacks(true)
        end
    end, EntityType.ENTITY_PLAYER},
    {ModCallbacks.MC_PRE_USE_ITEM , function() --PlayerItemBlockCallback 
        if StageAPI.TransitionAnimationData.State ~= 0 then
            return true
        else
            SetBlockCallbacks(true)
        end
    end},
    {ModCallbacks.MC_POST_EFFECT_INIT , function()  --MomFootBlockCallback 
        if StageAPI.TransitionAnimationData.State ~= 0 then
            e:Remove()
        else
            SetBlockCallbacks(true)
        end
    end, EffectVariant.MOM_FOOT_STOMP},
    {ModCallbacks.MC_FAMILIAR_UPDATE , function(_,npc)  --FamiliarBlock For Blood Oath
        if StageAPI.TransitionAnimationData.State ~= 0 then
            npc:GetSprite():SetFrame(0)
            npc.Velocity = Vector(0,0)
        else
            SetBlockCallbacks(true)
        end
    end},
    {ModCallbacks.MC_POST_GAME_STARTED , function()  --Reset transition when restarting
        StageAPI.TransitionAnimationData.State = 0
        StageAPI.TransitionAnimationData.Frame = 0
        StageAPI.TransitionAnimationData.Sprites.Stages = {}
        StageAPI.TransitionAnimationData.StageIcon = nil
        StageAPI.TransitionAnimationData.CurrentStageID = nil
        StageAPI.TransitionAnimationData.NextStageID = nil
        StageAPI.TransitionAnimationData.GotoStage = nil
        StageAPI.TransitionAnimationData.QueueMusic = nil

        --SetBlockCallbacks(true) --self-removing callbacks break runCallback, for MC_POST_GAME_STARTED this is critical
        
    end},
}

SetBlockCallbacks = function(bool)
    if not bool then
        for i,cal in pairs(BlockCallbacks) do
            if cal[1] and cal[2] then
                mod:AddPriorityCallback(cal[1],CallbackPriority.LATE,cal[2],cal[3])
            end
        end
    else
        for i,cal in pairs(BlockCallbacks) do
            if cal[1] and cal[2] then
                mod:RemoveCallback(cal[1],cal[2])
            end
        end
    end
end

local TempCollData = {} -- Returns the collision even if the transition has been broke
TempCollData.ToUpdate = {}
local function UpdateTempCollision(ent, index)
    if ent then
        local data = ent:GetData()
        local returncol
        if data.StageAPI_TempCollData then
            if data.StageAPI_TempCollData.timeout and type(data.StageAPI_TempCollData.timeout) == "number" then
                data.StageAPI_TempCollData.timeout = data.StageAPI_TempCollData.timeout - 1
                if data.StageAPI_TempCollData.timeout <= 0 then
                    returncol = true
                end
            else
                returncol = true
            end
            if returncol then
                if ent:ToPlayer() then
                    ent:ToPlayer():AddCacheFlags(CacheFlag.CACHE_FLYING)
                else
                    ent.GridCollisionClass = data.StageAPI_TempCollData.gridColl or ent.GridCollisionClass
                end
                ent.EntityCollisionClass = data.StageAPI_TempCollData.entColl or ent.EntityCollisionClass
                TempCollData.ToUpdate[ent.Index] = nil
		data.StageAPI_TempCollData = nil
            end
        end
    elseif index then
        TempCollData.ToUpdate[Index] = nil
    end
end

function SetTempCollision(ent, timeout, gridColl, entColl)
    if ent and (gridColl or entColl) then
        local data = ent:GetData()
        data.StageAPI_TempCollData = data.StageAPI_TempCollData or {}
        data.StageAPI_TempCollData.timeout = timeout
        data.StageAPI_TempCollData.gridColl = data.StageAPI_TempCollData.gridColl or ent.GridCollisionClass
        data.StageAPI_TempCollData.entColl = data.StageAPI_TempCollData.entColl or ent.EntityCollisionClass
        
        ent.GridCollisionClass = gridColl or ent.GridCollisionClass
        ent.EntityCollisionClass = entColl or ent.EntityCollisionClass
        TempCollData.ToUpdate[ent.Index] = ent
        if not TempCollData.Callbacked then
            TempCollData.Callbacked = true
            mod:AddCallback(ModCallbacks.MC_POST_UPDATE, TempCollData.UpdateCallback)
        end
    end
end

function TempCollData.UpdateCallback()
    if Game():GetFrameCount() <= 2 then
        TempCollData.Callbacked = false
        mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, TempCollData.UpdateCallback)
        TempCollData.ToUpdate = {}
        return
    end
    local num = 0
    for i, k in pairs(TempCollData.ToUpdate) do
        UpdateTempCollision(k,i)
        num = num + 1
    end
    if num == 0 then
        if TempCollData.Callbacked then
            TempCollData.Callbacked = false
            mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, TempCollData.UpdateCallback)
        end
    end 
end

StageAPI.TransitionAnimationData = {
    Progress = {},
    LoadedProgress = {},
    Sprites = {},
    State = 0,
    Frame = 0,
}

StageAPI.TransitionAnimationData.Sprites.BG = Sprite()
StageAPI.TransitionAnimationData.Sprites.BG:Load("gfx/ui/stage/nightmare_bg.anm2", true)

StageAPI.TransitionAnimationData.Sprites.Connector = Sprite()
StageAPI.TransitionAnimationData.Sprites.Connector:Load("stageapi/transition/progress.anm2",true)
StageAPI.TransitionAnimationData.Sprites.Connector:Play("Connector",true)
	
StageAPI.TransitionAnimationData.Sprites.IsaacIndicator = Sprite()
StageAPI.TransitionAnimationData.Sprites.IsaacIndicator:Load("stageapi/transition/progress.anm2",true)
StageAPI.TransitionAnimationData.Sprites.IsaacIndicator:Play("IsaacIndicator",true)

StageAPI.TransitionAnimationData.Sprites.Clock = Sprite()
StageAPI.TransitionAnimationData.Sprites.Clock:Load("stageapi/transition/progress.anm2",true)
StageAPI.TransitionAnimationData.Sprites.Clock:Play("Clock",true)

StageAPI.TransitionAnimationData.Sprites.Nightmare = Sprite()

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
    StageAPI.BlackScreenOverlay.Scale = StageAPI.GetScreenScale(true) * 20
    StageAPI.BlackScreenOverlay.Color = Color(1, 1, 1, alpha, 0, 0, 0)
    StageAPI.BlackScreenOverlay:Render(StageAPI.GetScreenCenterPosition(), Vector.Zero, Vector.Zero)
end

local renderListOrder = {0,3,1,5,4,2,6,7,8,9,10}

local IsOddRenderFrame
function StageAPI.TransitionAnimationData.DefaultTransition(data)
    local stop
    for _, player in ipairs(shared.Players) do
        player.ControlsCooldown = 80

        if Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, player.ControllerIndex) or
        Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, player.ControllerIndex) then
            stop = true
        end
    end
        
    if IsOddRenderFrame then
        data.Sprites.BG:Update()
        if data.Sprites.Stages then
            data.Sprites.Connector:Update()
            data.Sprites.IsaacIndicator:Update()
            if data.Sprites.BG:IsPlaying('Loop') and data.IsaacIndicatorNextPos then
                local dist = data.IsaacIndicatorNextPos:Distance(data.IsaacIndicatorPos)
                if dist > 0.5 then
                    data.IsaacIndicatorPos = data.IsaacIndicatorPos + (data.IsaacIndicatorNextPos-data.IsaacIndicatorPos):Resized(math.max(1,dist/40))
                end
            end
        end

        if data.Sprites.Stages and data.Sprites.BG:GetAnimation() == 'Intro' and IntroAlpha[data.Sprites.BG:GetFrame()] then
            local alpha = IntroAlpha[data.Sprites.BG:GetFrame()]
            data.Sprites.Connector.Color = Color(alpha,alpha,alpha,1)
            data.Sprites.Clock.Color = Color(alpha,alpha,alpha,1)
            data.Sprites.IsaacIndicator.Color = Color(alpha,alpha,alpha,1)
            if data.Sprites.BossIndicator then
                data.Sprites.BossIndicator.Color = Color(alpha,alpha,alpha,1)
            end
        end
        if data.UseExtraPortrait ~= nil then
            StageAPI.PlayerPortraitExtra:Update()
            if ExtraPortraitOffsets[data.UseExtraPortrait] and ExtraPortraitOffsets[data.UseExtraPortrait][data.Sprites.BG:GetFrame()%4] then
                StageAPI.PlayerPortraitExtra.Offset = ExtraPortraitOffsets[data.UseExtraPortrait][data.Sprites.BG:GetFrame()%4]
            end
            if data.Sprites.BG:GetAnimation() == 'Intro' and IntroAlpha[data.Sprites.BG:GetFrame()] then
                local alpha = IntroAlpha[data.Sprites.BG:GetFrame()]
                StageAPI.PlayerPortraitExtra.Color = Color(alpha,alpha,alpha,1)
            end
        end  
        if data.Sprites.BG:IsEventTriggered('startNightmare') or data.Sprites.BG:IsFinished('Intro') 
        and not data.Sprites.BG:WasEventTriggered('startNightmare') then
            data.Sprites.BG:Play('Loop')
            data.Sprites.Nightmare:SetLastFrame()
            data.NightmareLastFrame = data.Sprites.Nightmare:GetFrame()
            data.Sprites.Nightmare:SetFrame(0)
        elseif data.Sprites.BG:IsPlaying('Loop') then
            data.Sprites.Nightmare:Update()
            if data.Sprites.Nightmare:IsFinished(data.Sprites.Nightmare:GetAnimation()) or
            data.NightmareLastFrame == data.Sprites.Nightmare:GetFrame() then
                stop = true
            end
        end
    end

    local pos = StageAPI.GetScreenCenterPosition()
    for _, layer in pairs(renderListOrder) do
        data.Sprites.BG:RenderLayer(layer, pos)

        if layer == 6  then
            if StageAPI.TransitionAnimationData.UseExtraPortrait ~= nil then
                StageAPI.PlayerPortraitExtra:Render(pos)
            end
            if data.Sprites.BG:IsPlaying('Loop') then
                data.Sprites.Nightmare:Render(pos)
            end
            
            data.Sprites.Nightmare:Render(pos)
            if data.Sprites.Stages then
                data.Sprites.Connector:Render(data.ConnectorPos)
                for _,spr in pairs(data.Sprites.Stages) do
                    if data.Sprites.BG:GetAnimation() == 'Intro' and IntroAlpha[data.Sprites.BG:GetFrame()] then
                        local alpha = IntroAlpha[data.Sprites.BG:GetFrame()]
                        spr.sprite.Color = Color(alpha,alpha,alpha,1)
                    end
                    spr.sprite:Render(spr.pos)
                end
                data.Sprites.Clock:Render(data.ClockPos)
                if data.Sprites.BossIndicator then
                    data.Sprites.BossIndicator:Render(data.BossIndicatorPos)
                end
                data.Sprites.IsaacIndicator:Render(data.IsaacIndicatorPos)
            end
        end
    end
    if data.NightmareLastFrame and (data.Sprites.Nightmare:GetFrame() >= data.NightmareLastFrame-20) then
        StageAPI.RenderBlackScreen( (data.Sprites.Nightmare:GetFrame()-data.NightmareLastFrame+21) / 20 )
    end
    if shared.Music:GetCurrentMusicID() ~= data.TransitionMusic then
        data.TransitionMusic = shared.Music:GetCurrentMusicID()
        shared.Music:Pause()             
    end

    if stop then
        data.State = 3
        data.Sprites.Stages = {}
        shared.Music:Play(data.QueueMusic,Options.MusicVolume)
    end
end


mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, name)
    if name == "StageAPI-TransitionPixelation" then
        IsOddRenderFrame = not IsOddRenderFrame
        local ShaTabl = { PixelAmount = 0.005 + 0.002*StageAPI.TransitionAnimationData.Frame}

        if StageAPI.TransitionAnimationData.State == 0 then  --no transition
            local Tabl = {PixelAmount = 0}
	    return Tabl
        elseif StageAPI.TransitionAnimationData.State == 1 then  --fade in
	    if IsOddRenderFrame then
                StageAPI.TransitionAnimationData.Frame = StageAPI.TransitionAnimationData.Frame + 2.6
            end
            for _, player in ipairs(shared.Players) do
                player.ControlsCooldown = math.max(player.ControlsCooldown,80)
            end

            StageAPI.RenderBlackScreen(StageAPI.TransitionAnimationData.Frame*0.007) 

            if StageAPI.TransitionAnimationData.Frame > 150 then 
                for _, player in ipairs(shared.Players) do --drop Bforgotten down from the soul
                    player:ThrowHeldEntity(Vector(10,10))
                    player:AddCacheFlags(CacheFlag.CACHE_FLYING)
                end

                if StageAPI.DelayedNextStage then
                    StageAPI.NextStage = StageAPI.DelayedNextStage
                    StageAPI.DelayedNextStage = nil
                end

                if StageAPI.TransitionAnimationData.GotoStage then
                    Isaac.ExecuteCommand("stage " .. StageAPI.TransitionAnimationData.GotoStage)
                end
                local queue = shared.Music:GetCurrentMusicID() 
                StageAPI.TransitionAnimationData.QueueMusic = StageAPI.TransitionAnimationData.QueueMusic or queue
                shared.Music:Play(StageAPI.TransitionAnimationData.TransitionMusic,0)
                shared.Music:Queue(StageAPI.TransitionAnimationData.QueueMusic)
                shared.Music:UpdateVolume()
                
                if StageAPI.TransitionAnimationData.StageIcon then
                    StageAPI.TransitionAnimationData.Progress[StageAPI.TransitionAnimationData.NextStageID] = {path = StageAPI.TransitionAnimationData.StageIcon}
                end
                if StageAPI.TransitionAnimationData.NextStageID then
                    if shared.Level:GetCurses() & 2 ~= 0 and StageAPI.InNewStage() then --XL Stage
                        StageAPI.TransitionAnimationData.Progress[StageAPI.CurrentStage.StageNumber - 1] = {path = 17}
                        StageAPI.TransitionAnimationData.NextStageID = StageAPI.CurrentStage.StageNumber or StageAPI.TransitionAnimationData.NextStageID
                    end
                    StageAPI.TransitionAnimationData.GenProgressBar()
                end

                StageAPI.TransitionAnimationData.StageIcon = nil
                StageAPI.TransitionAnimationData.CurrentStageID = nil
                StageAPI.TransitionAnimationData.NextStageID = nil
                StageAPI.TransitionAnimationData.GotoStage = nil
                StageAPI.TransitionAnimationData.State = 2
		
                local Tabl = {PixelAmount = 0}
	        return Tabl
            elseif StageAPI.TransitionAnimationData.Frame > 145 then
                local Tabl = {PixelAmount = 0}
	        return Tabl
            else
                return ShaTabl
            end

        elseif StageAPI.TransitionAnimationData.State == 2 then  -- transition animation
            for _, player in ipairs(shared.Players) do
                player.ControlsCooldown = math.max(player.ControlsCooldown,80)
            end
            if StageAPI.TransitionAnimationData.TransitionRenderFunction then
                StageAPI.TransitionAnimationData.TransitionRenderFunction(StageAPI.TransitionAnimationData)
            else
                StageAPI.TransitionAnimationData.State = 3
            end
            StageAPI.TransitionIsPlaying = true

            local Tabl = {PixelAmount = 0}
	    return Tabl
        elseif StageAPI.TransitionAnimationData.State == 3 then  --fade out
            if IsOddRenderFrame then
                StageAPI.TransitionAnimationData.Frame = StageAPI.TransitionAnimationData.Frame - 2.6
            end
            StageAPI.RenderBlackScreen(StageAPI.TransitionAnimationData.Frame*0.007)

            for _, player in ipairs(shared.Players) do
                player.ControlsCooldown = math.max(player.ControlsCooldown,80)
                if not player:IsHoldingItem() then
                    player:AnimateAppear()
                end
            end
            StageAPI.TransitionIsPlaying = false
            if StageAPI.TransitionAnimationData.Frame <= 0 then
                StageAPI.TransitionAnimationData.Frame = 0
                StageAPI.TransitionAnimationData.State = 0
                SetBlockCallbacks(true)

                if StageAPI.CurrentStage then
                    local name = StageAPI.CurrentStage:GetDisplayName()
                    StageAPI.PlayTextStreak{
                        Text = name,
                        AboveHud = true,
                    }
                end
            end
            
            return ShaTabl
        end
    end
end)

function StageAPI.TransitionAnimationData.StartTransition()
    StageAPI.TransitionAnimationData.State = 1
    SetBlockCallbacks(true)
    SetBlockCallbacks()
end

function StageAPI.IsHUDAnimationPlaying(spriteOnly)
    return StageAPI.TransitionIsPlaying
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

function StageAPI.TransitionAnimationData.StagesProgressTracking()
    local StageID = shared.Level:GetStage()
    local id = shared.Level:GetAbsoluteStage()
    local Stype = shared.Level:GetStageType()
    if StageID == 9 then
        StageAPI.TransitionAnimationData.Saw9Stage = true  --Blue Womb and Corpse 2
    end
    if StageAPI.InNewStage() then
        StageID = StageAPI.CurrentStage.StageNumber or StageID
        StageAPI.TransitionAnimationData.Progress[StageID] = {path = StageAPI.CurrentStage.TransitionIcon, IsCustomStage = true, Name = StageAPI.CurrentStage.Name} 
    else
        if Stype > 3 then
            StageID = StageID + 1
        end
        local icon = StageAPI.GetLevelTransitionIcon(id, Stype)
        StageAPI.TransitionAnimationData.Progress[StageID] = {path = icon, stage = id, StageType = Stype} 
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    StageAPI.TransitionAnimationData.StagesProgressTracking()
end)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    StageAPI.TransitionAnimationData.Progress = {}
    StageAPI.TransitionAnimationData.StagesProgressTracking()
    if StageAPI.TransitionAnimationData.LoadedProgress then
        StageAPI.TransitionAnimationData.Progress = StageAPI.DeepCopy(StageAPI.TransitionAnimationData.LoadedProgress)
        StageAPI.TransitionAnimationData.LoadedProgress = nil 
    end
end)


function StageAPI.GetLevelTransitionIcon(stage, stype)
    local floorInfo = StageAPI.GetBaseFloorInfo(stage, stype)
    if not floorInfo then
        return "stageapi/none.png"
    end

    local base = floorInfo.Prefix
    if base == "07_womb" and stype == StageType.STAGETYPE_WOTL then
        base = "utero"
    end

    return "stageapi/transition/levelicons/" .. base .. ".png"
end

local function GetStageProgressNum() --Number of icons in the progress bar
    local maxnum = 0
    for i in pairs(StageAPI.TransitionAnimationData.Progress) do
        maxnum = math.max(maxnum,i)
        if not StageAPI.TransitionAnimationData.Saw9Stage and i == 9 then
            StageAPI.TransitionAnimationData.Saw9Stage = true
        end
    end
    local num = math.max(shared.Game:IsGreedMode() and 7 or 8, 
        StageAPI.TransitionAnimationData.NextStageID or 0,
        maxnum or 0,
        shared.Level:GetStage())
    return not StageAPI.TransitionAnimationData.Saw9Stage and num > 8 and num-1 or num, num
end

function StageAPI.TransitionAnimationData.GenProgressBar() 
    local renderPos = Vector(StageAPI.GetScreenCenterPosition().X, 20)

    StageAPI.TransitionAnimationData.Sprites.Stages = {}
    local Stages = StageAPI.TransitionAnimationData.Sprites.Stages
    
    local Stagenum, trueStagenum = GetStageProgressNum()
    local length = (Stagenum-1)*26 + Stagenum
    local CenPos = renderPos.X-length/2
    local IsaacIndicatorPos = renderPos
    local IsaacIndicatorNextPos = renderPos
    local BossIndicatorPos
    local num = 1

    for i=1, trueStagenum do
        if i ~= 9 or StageAPI.TransitionAnimationData.Saw9Stage then
            local onetwo = not StageAPI.TransitionAnimationData.Saw9Stage and i > 9 and 2 or 1
            local nPos = Vector(CenPos+26*(i-onetwo)+i,renderPos.Y)
            Stages[num] = {}
            Stages[num].pos = nPos
            Stages[num].sprite = Sprite()
            Stages[num].sprite.Color = Color(0,0,0,1)
            Stages[num].sprite:Load("stageapi/transition/progress.anm2",true)
            if StageAPI.TransitionAnimationData.Progress[i] and type(StageAPI.TransitionAnimationData.Progress[i].path) == "string" then
                Stages[num].sprite:ReplaceSpritesheet(2, StageAPI.TransitionAnimationData.Progress[i].path)   
                Stages[num].sprite:Play('Levels')
                Stages[num].sprite:SetLayerFrame(2, 1)
                Stages[num].sprite:LoadGraphics(true)
            elseif StageAPI.TransitionAnimationData.Progress[i] and type(StageAPI.TransitionAnimationData.Progress[i].path) == "number" then
                Stages[num].sprite:Play('Levels')
                Stages[num].sprite:SetLayerFrame(0, StageAPI.TransitionAnimationData.Progress[i].path)
            else
                if i < StageAPI.TransitionAnimationData.NextStageID then 
                    Stages[num].sprite:Play('Levels')
                    Stages[num].sprite:SetLayerFrame(0, 17)
                    Stages[num].sprite:SetLayerFrame(3, 1)
                else
                    Stages[num].sprite:Play('NotClearFloor')
                end
            end
            if i == StageAPI.TransitionAnimationData.CurrentStageID then
                IsaacIndicatorPos = nPos
            end
            if i == StageAPI.TransitionAnimationData.NextStageID then
                IsaacIndicatorNextPos = nPos
            elseif StageAPI.TransitionAnimationData.Progress[i] then
                Stages[num].sprite:SetLayerFrame(3, 1)
            end
            if i < 9 and num == Stagenum then
                BossIndicatorPos = nPos
            end

            num = num + 1
        end
    end

    StageAPI.TransitionAnimationData.Sprites.Connector.Scale = Vector(Stagenum/1.5,1)
    StageAPI.TransitionAnimationData.ConnectorPos = renderPos

    StageAPI.TransitionAnimationData.Sprites.IsaacIndicator:Play("IsaacIndicator",true)
    StageAPI.TransitionAnimationData.Sprites.IsaacIndicator.Color = Color(0,0,0,1)
    StageAPI.TransitionAnimationData.IsaacIndicatorPos = IsaacIndicatorPos
    StageAPI.TransitionAnimationData.IsaacIndicatorNextPos = IsaacIndicatorNextPos 

    StageAPI.TransitionAnimationData.Sprites.Clock.Color = Color(0,0,0,1)
    local Procent = shared.Game.TimeCounter / shared.Game.BossRushParTime
    local dist = 136  
    local ClockPos = dist*Procent
    StageAPI.TransitionAnimationData.ClockPos = Vector(CenPos+ClockPos+1,renderPos.Y)

    if BossIndicatorPos then
        StageAPI.TransitionAnimationData.Sprites.BossIndicator = Sprite()
        StageAPI.TransitionAnimationData.Sprites.BossIndicator:Load("stageapi/transition/progress.anm2",true)
        local anim = shared.Game:IsGreedMode() and "GreedIndicator" or "BossIndicator"
        StageAPI.TransitionAnimationData.Sprites.BossIndicator:Play(anim,true)
        StageAPI.TransitionAnimationData.Sprites.BossIndicator.Color = Color(0,0,0,1)
        StageAPI.TransitionAnimationData.BossIndicatorPos = BossIndicatorPos
    else
        StageAPI.TransitionAnimationData.Sprites.BossIndicator = nil
    end 
end

function StageAPI.PlayTransitionAnimationManual(portrait, icon, ground, bg, transitionmusic, queue, noshake, extraportrait, nightmare)
    portrait = portrait or "gfx/ui/stage/playerportrait_isaac.png"
    icon = icon or "stageapi/transition/levelicons/unknown.png"
    ground = ground or "stageapi/transition/bossspot_01_basement.png"
    bg = bg or "stageapi/transition/nightmares_bg_mask.png"
    transitionmusic = transitionmusic or Music.MUSIC_JINGLE_NIGHTMARE
    nightmare = nightmare or StageAPI.TransitionNightmares[StageAPI.Random(1, #StageAPI.TransitionNightmares)]

    StageAPI.TransitionAnimationData.Sprites.BG:Load("stageapi/transition/customnightmare.anm2", true)

    StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(3, ground)
    StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(1, bg)
    if noshake then
        StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(6, portrait)
        StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(2, "stageapi/none.png")
    else
        StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(2, portrait)
        StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(6, "stageapi/none.png")
    end
    StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(7, icon)
    StageAPI.TransitionAnimationData.Sprites.BG:LoadGraphics()
    StageAPI.TransitionAnimationData.Sprites.BG:Play("Intro", true)

    StageAPI.TransitionAnimationData.Sprites.Nightmare:Load(nightmare, true)
    StageAPI.TransitionAnimationData.Sprites.Nightmare:Play(StageAPI.TransitionAnimationData.Sprites.Nightmare:GetDefaultAnimationName(), true)

    if extraportrait then
        StageAPI.PlayerPortraitExtra:Load(extraportrait,true)
        StageAPI.PlayerPortraitExtra:Play(StageAPI.PlayerPortraitExtra:GetDefaultAnimationName(),true)
        StageAPI.TransitionAnimationData.UseExtraPortrait = noshake or false
        StageAPI.PlayerPortraitExtra.Offset = ExtraPortraitOffsets[StageAPI.TransitionAnimationData.UseExtraPortrait][0]
        StageAPI.PlayerPortraitExtra.Color = Color(0,0,0,1)
        StageAPI.PlayerPortraitExtra.Scale = Vector(1,1)
    else
        StageAPI.TransitionAnimationData.UseExtraPortrait = nil
    end

    StageAPI.TransitionAnimationData.TransitionMusic = transitionmusic

    StageAPI.TransitionAnimationData.QueueMusic = queue
    
    StageAPI.TransitionAnimationData.Sprites.Stages = nil
    StageAPI.TransitionAnimationData.StartTransition()
end

function StageAPI.PlayFullStageTransition(tab)
    local gfxData = StageAPI.TryGetPlayerGraphicsInfo(shared.Players[1])
    local nightmare = tab.Nightmare or StageAPI.TransitionNightmares[StageAPI.Random(1, #StageAPI.TransitionNightmares)]
    local floorInfo = StageAPI.GetBaseFloorInfo()
    local ground
    if floorInfo then
        ground = "gfx/ui/boss/bossspot_" .. floorInfo.Prefix .. ".png"
    else
        ground = "stageapi/none.png"
    end
    StageAPI.PlayTransitionAnimationManual(gfxData.Portrait, tab.TransitionIcon, tab.TransitionGround or ground, tab.TransitionBackground, tab.TransitionMusic, tab.Music, gfxData.NoShake, gfxData.ExtraPortrait)
    
    StageAPI.TransitionAnimationData.Sprites.BG:Load("gfx/ui/stage/nightmare_bg.anm2", true)
    StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(3, tab.TransitionGround or ground)
    if tab.TransitionBackground then
        StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(1, tab.TransitionBackground)
    end
    if gfxData.NoShake then
        StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(6, gfxData.Portrait or "gfx/ui/stage/playerportrait_isaac.png")
        StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(2, "stageapi/none.png")
    else
        StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(2, gfxData.Portrait or "gfx/ui/stage/playerportrait_isaac.png")
        StageAPI.TransitionAnimationData.Sprites.BG:ReplaceSpritesheet(6, "stageapi/none.png")
    end
    StageAPI.TransitionAnimationData.Sprites.BG:LoadGraphics()
    StageAPI.TransitionAnimationData.Sprites.BG:Play("Intro", true)

    StageAPI.TransitionAnimationData.Sprites.Nightmare:Load(nightmare, true)
    StageAPI.TransitionAnimationData.Sprites.Nightmare:Play(StageAPI.TransitionAnimationData.Sprites.Nightmare:GetDefaultAnimationName(), true)

    StageAPI.TransitionAnimationData.StageIcon = tab.TransitionIcon
    StageAPI.TransitionAnimationData.CurrentStageID = tab.CurrentStageID or StageAPI.CurrentStage and StageAPI.CurrentStage.StageNumber or shared.Level:GetStage()
    StageAPI.TransitionAnimationData.NextStageID = tab.NextStageID or StageAPI.NextStage and StageAPI.NextStage.StageNumber or shared.Level:GetStage()

    StageAPI.TransitionAnimationData.GotoStage = tab.GotoStage
    StageAPI.TransitionAnimationData.TransitionRenderFunction = tab.RenderFunction or StageAPI.TransitionAnimationData.DefaultTransition 

    StageAPI.TransitionAnimationData.StartTransition()
    if tab.Immediately then
        StageAPI.TransitionAnimationData.Frame = 151
    end
end

function StageAPI.PlayTransitionAnimation(stage, full) --if full is false, then the transition animation plays without a full progress bar
    local gfxData = StageAPI.TryGetPlayerGraphicsInfo(shared.Players[1])
    if not full then
        StageAPI.PlayTransitionAnimationManual(gfxData.Portrait, stage.TransitionIcon, stage.TransitionGround, stage.TransitionBackground, stage.TransitionMusic, stage.Music and stage.Music[RoomType.ROOM_DEFAULT], gfxData.NoShake, gfxData.ExtraPortrait)
    else
        local extraData = type(full) == "table" and full or {}

        local Currentstage = StageAPI.CurrentStage and StageAPI.CurrentStage.StageNumber 
            or not StageAPI.CurrentStage and shared.Level:GetStageType() > 3 and shared.Level:GetStage() + 1 or shared.Level:GetStage()
        local Nextstageoffset = stage.NormalStage and stage.StageType > 3 and 1 or 0

        local tab = {
            TransitionIcon = extraData.TransitionIcon or stage.TransitionIcon,
            TransitionGround = extraData.TransitionGround or stage.TransitionGround,
            TransitionBackground = extraData.TransitionBackground or stage.TransitionBackground,
            TransitionMusic = extraData.TransitionMusic or stage.TransitionMusic,
            Music = extraData.Music or (stage.Music and stage.Music[RoomType.ROOM_DEFAULT]),
            CurrentStageID = extraData.CurrentStageID or Currentstage, --for Isaac indicator icon
            NextStageID = extraData.NextStageID or (stage.StageNumber + Nextstageoffset),
            GotoStage = extraData.GotoStage, --if nil there will be no transition to the stage at the end of the animation
            Nightmare = extraData.Nightmare, --if nil will be random
            RenderFunction = extraData.RenderFunction,
            Immediately = extraData.Immediately, --skipping initial pixelation
        }
        StageAPI.PlayFullStageTransition(tab)
    end
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
            local floorInfo = StageAPI.GetBaseFloorInfo(stage.Stage, stageType)
            local ground
            if floorInfo then
                ground = "gfx/ui/boss/bossspot_" .. floorInfo.Prefix .. ".png"
            else
                ground = "stageapi/none.png"
            end
            local bg = "stageapi/transition/nightmares_bg_mask.png"

            local tab = {
                TransitionIcon = StageAPI.GetLevelTransitionIcon(stage.Stage, stageType),
                TransitionGround = ground,
                CurrentStageID = StageAPI.CurrentStage and StageAPI.CurrentStage.StageNumber or shared.Level:GetStage(),
                NextStageID = stageType > 3 and stage.Stage + 1 or stage.Stage,
                GotoStage = (tostring(stage.Stage) .. StageAPI.StageTypeToString[stageType]),
            }
            StageAPI.PlayFullStageTransition(tab)
        else
            Isaac.ExecuteCommand("stage " .. tostring(stage.Stage) .. StageAPI.StageTypeToString[stageType])
        end
    else
        local replace = stage.Replaces
        local absolute = replace.OverrideStage
        StageAPI.NextStage = stage
        if playTransition then
            StageAPI.DelayedNextStage = stage  --The transition does not happen immediately and it can be triggered by another callback
            StageAPI.NextStage = nil
            local gotoStage = stage.LevelgenStage and (tostring(stage.LevelgenStage.Stage) .. StageAPI.StageTypeToString[stage.LevelgenStage.StageType])
                or (tostring(absolute) .. StageAPI.StageTypeToString[replace.OverrideStageType])

            StageAPI.PlayTransitionAnimation(stage, {GotoStage = gotoStage}) 
        else
            if stage.LevelgenStage then
                Isaac.ExecuteCommand("stage " .. tostring(stage.LevelgenStage.Stage) .. StageAPI.StageTypeToString[stage.LevelgenStage.StageType])
            else
                Isaac.ExecuteCommand("stage " .. tostring(absolute) .. StageAPI.StageTypeToString[replace.OverrideStageType])
            end
        end
    end
end

function StageAPI.SpawnCustomTrapdoor(position, goesTo, anm2, size, alreadyEntering)
    anm2 = anm2 or "gfx/grid/door_11_trapdoor.anm2"
    size = size or 24
    local trapdoor = Isaac.Spawn(StageAPI.E.Trapdoor.T, StageAPI.E.Trapdoor.V, StageAPI.E.Trapdoor.S, position, Vector.Zero, nil)
    trapdoor.SortingLayer = 0
    trapdoor.Size = size
    local sprite, data = trapdoor:GetSprite(), trapdoor:GetData()
    sprite:Load(anm2, true)

    if alreadyEntering then
        sprite:Play("Opened", true)
        data.alreadyEntering = true
        data.TrapdoorOpened = true
        data.StartTransition = true
    else
        sprite:Play("Closed", true)
    end

    data.GoesTo = goesTo
    return trapdoor
end

function StageAPI.IsFullFledgedPlayer(player)
    if not player.Parent 
    and not player:IsCoopGhost()
    and not ((player:GetPlayerType() == PlayerType.PLAYER_LAZARUS_B or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B) 
    and (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) or (player:GetOtherTwin() and player:GetOtherTwin():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT))) 
    and (player:GetMainTwin().Index ~= player.Index or player:GetMainTwin().InitSeed ~= player.InitSeed)) then
        return true
    end
    return false
end

local blocking_anim = {WalkLeft = true,WalkUp = true,WalkRight = true,WalkDown = true}
local function CanInteract(player)
    if player then
        return blocking_anim[player:GetSprite():GetAnimation()]
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff) --custom trapdoor logic
    local sprite, data = eff:GetSprite(), eff:GetData()

    if data.GoesTo and (eff.FrameCount < 30 or data.PlayerToClose) and not data.TrapdoorOpened then
        local PlayerToClose = false
        sprite:Play("Open Animation",false)
        for _, player in ipairs(shared.Players) do
            local size = (eff.Size + player.Size + 30)
            if not player.Parent and player.Position:DistanceSquared(eff.Position) < size * size then
                PlayerToClose = true
                break
            end
        end
        if PlayerToClose then
            data.PlayerToClose = true
            sprite:Play("Closed",true)
        elseif eff.FrameCount > 40 then
            data.PlayerToClose = false
        end
    end
    if data.GoesTo and not data.PlayerToClose and (eff.FrameCount > 30 or data.TrapdoorOpened) then
        if sprite:IsPlaying("Closed") or sprite:IsFinished("Closed") then
            sprite:Play("Open Animation",true)
        elseif sprite:IsFinished("Open Animation") then
            sprite:Play("Opened",true)
            data.TrapdoorOpened = true
        end
        if data.TrapdoorOpened then  
            if not data.StartTransition and not data.Transition or data.alreadyEntering then
                data.PlayerReady = {}
                data.Playerquery = {}
                for _, player in ipairs(shared.Players) do
                    if CanInteract(player) and StageAPI.IsFullFledgedPlayer(player) and player.Position:Distance(eff.Position) < eff.Size then
                        data.StartTransition = true
                        break
                    end
                end
                if data.StartTransition or data.alreadyEntering then
                    for i, player in ipairs(shared.Players) do
                        player.ControlsCooldown = math.max(Isaac.GetPlayer(i).ControlsCooldown,100)
                        player.Velocity = Vector.Zero
                        data.Playerquery[i] = player
                    end
                    data.NumPlayer = shared.Game:GetNumPlayers()
                    data.Num = 0
                    data.INNum = 0
                    data.Timeout = 0
                    data.alreadyEntering = nil

                    table.sort(data.Playerquery, function(a,b) if a and b then 
                        return a.Position:Distance(eff.Position) < b.Position:Distance(eff.Position) 
                        else return nil end 
                    end)

                    for _, ent in pairs(Isaac.FindByType(eff.Type, eff.Variant, eff.SubType, false, false)) do
                        if eff.Index ~= ent.Index then
                            ent:GetData().GoesTo = nil
                        end
                    end
                end
            elseif data.StartTransition and not data.Transition then
                if data.Timeout<=0 and data.NumPlayer-data.Num ~= 0 then
                    data.Timeout = 5
                    if data.Playerquery[data.Num+1] and data.Playerquery[data.Num+1]:GetSprite():GetAnimation() ~= "Trapdoor" then
                        data.Playerquery[data.Num+1]:AnimateTrapdoor()
                        SetTempCollision(data.Playerquery[data.Num+1], 10, EntityGridCollisionClass.GRIDCOLL_NONE)
                    end
                    data.Num = data.Num+1
                    if data.NumPlayer-data.Num == 0 then
                        data.Timeout = 20
                    end
                elseif data.Timeout<=0 and data.NumPlayer-data.Num == 0 then
                    data.Transition = 1
                end
                data.Timeout = data.Timeout - 1
                if data.Num>0 then
                    for i=0,data.Num-1 do
                        local player = data.Playerquery[i+1]  
                        if player then
                            local dist = player.Position:Distance(eff.Position)
                            player.Velocity = (eff.Position-player.Position):Resized(dist / 4)
                            if player.Position:Distance(eff.Position)<40          
                            and (player:IsExtraAnimationFinished() or player:GetSprite():GetFrame() >= 15 ) 
                            and not data.PlayerReady[i] then
                                player.PositionOffset = Vector(0, 800)
                                sprite:Play("Player Exit",true)
                                data.PlayerReady[i] = true
                                local poof = Isaac.Spawn(1000, EffectVariant.POOF01, 2, eff.Position+Vector(0, 10), Vector(0, 0), eff)
                                poof.DepthOffset = -10
                                poof:GetSprite().Color = Color(1,1,1,0.5)
                                poof:GetSprite():SetFrame(3)
                            end
                            if player:GetSprite():GetAnimation() ~= "Trapdoor" and player.PositionOffset.Y<400 then  
                                player:AnimateTrapdoor()
                            end
                        end
                    end
                end
            elseif data.Transition == 1 then
                StageAPI.GotoCustomStage(data.GoesTo, true)
                data.Transition = 2
            elseif data.Transition == 2 then
                for _, player in ipairs(shared.Players) do
                    local dist = player.Position:Distance(eff.Position)
                    player.Velocity = (eff.Position-player.Position):Resized(dist/10)   
                end
            end
        end
    end
end, StageAPI.E.Trapdoor.V)
