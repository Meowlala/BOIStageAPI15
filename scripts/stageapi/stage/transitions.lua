local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local fakeTR = require("scripts.stageapi.stage.transitionRender")

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

StageAPI.TransitionNightmaresList = {
	"gfx/ui/stage/nightmare1.anm2",
	"gfx/ui/stage/nightmare2.anm2",
	"gfx/ui/stage/nightmare3.anm2",
	"gfx/ui/stage/nightmare4.anm2",
	"gfx/ui/stage/nightmare5.anm2",
	"gfx/ui/stage/nightmare6.anm2",
	"gfx/ui/stage/nightmare7.anm2",
	"gfx/ui/stage/nightmare8.anm2",
	"gfx/ui/stage/nightmare9.anm2",
	"gfx/ui/stage/nightmare10.anm2",
	"gfx/ui/stage/nightmare11.anm2",
	"gfx/ui/stage/nightmare12.anm2",
	"gfx/ui/stage/nightmare13.anm2",
	"gfx/ui/stage/nightmare14.anm2",
	"gfx/ui/stage/nightmare15.anm2",
	"gfx/ui/stage/nightmare16.anm2",
	"gfx/ui/stage/nightmare17.anm2",
	}

function StageAPI.AddTransitionNightmare(anm)
	if type(anm) == 'string' then
		StageAPI.TransitionNightmaresList[#StageAPI.TransitionNightmaresList+1] = anm
	end
end

StageAPI.TransitionAnimation = Sprite()
StageAPI.TransitionAnimation:Load("stageapi/transition/customnightmare.anm2", true)

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

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if StageAPI.TransitionAnimation:IsPlaying("Scene") or StageAPI.TransitionAnimation:IsPlaying("SceneNoShake") or StageAPI.TransitionAnimation:IsPlaying("Intro") then
        if StageAPI.IsOddRenderFrame then
            StageAPI.TransitionAnimation:Update()
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

function StageAPI.PlayTransitionAnimationManual(portrait, icon, ground, bg, transitionmusic, queue, noshake)
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

    shared.Music:Play(transitionmusic, 0)
    shared.Music:UpdateVolume()

    if queue ~= false then
        shared.Music:Queue(queue)
    end
end

function StageAPI.PlayTransitionAnimation(stage)
    local gfxData = StageAPI.TryGetPlayerGraphicsInfo(shared.Players[1])
    StageAPI.PlayTransitionAnimationManual(gfxData.Portrait, stage.TransitionIcon, stage.TransitionGround, stage.TransitionBackground, stage.TransitionMusic, stage.Music and stage.Music[RoomType.ROOM_DEFAULT], gfxData.NoShake)
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

        if playTransition then  ----Because of the principle of new animation, the old way remains, but is not used
            --local gfxData = StageAPI.TryGetPlayerGraphicsInfo(shared.Players[1])
            --local floorInfo = StageAPI.GetBaseFloorInfo()
            --local ground
            --if floorInfo then
            --    ground = "gfx/ui/boss/bossspot_" .. floorInfo.Prefix .. ".png"
            --else
            --    ground = "stageapi/none.png"
            --end

            --local bg = "stageapi/transition/nightmares_bg_mask.png"
            --StageAPI.PlayTransitionAnimationManual(gfxData.Portrait, StageAPI.GetLevelTransitionIcon(stage.Stage, stageType), ground, bg, nil, nil, gfxData.NoShake)

            fakeTR.PreGenProgressAnm(tostring(stage.Stage) .. StageAPI.StageTypeToString[stageType])
            local CurrentPos = nil 
            if StageAPI.CurrentStage and StageAPI.CurrentStage.StageNumber then
            	CurrentPos = StageAPI.CurrentStage.StageNumber
            end
            fakeTR.SetIndicatorPos(CurrentPos)  

            fakeTR.StartTransition()
        else

            Isaac.ExecuteCommand("stage " .. tostring(stage.Stage) .. StageAPI.StageTypeToString[stageType])
        end
    else
        local replace = stage.Replaces
        local absolute = replace.OverrideStage
        StageAPI.NextStage = stage
        if playTransition then
            --StageAPI.PlayTransitionAnimation(stage)
            
		    if stage.LevelgenStage then   --
            	fakeTR.PreGenProgressAnm(tostring(stage.LevelgenStage.Stage) .. StageAPI.StageTypeToString[stage.LevelgenStage.StageType], true)
		    else
			    fakeTR.PreGenProgressAnm(tostring(absolute) .. StageAPI.StageTypeToString[replace.OverrideStageType], true)
		    end
		    local CurrentPos,NextPos = nil, stage.StageNumber
		    if StageAPI.CurrentStage and StageAPI.CurrentStage.StageNumber then
		    	CurrentPos = StageAPI.CurrentStage.StageNumber
		    end
		    fakeTR.SetIndicatorPos(CurrentPos,NextPos)  
		    fakeTR.SetStageIcon(stage.StageNumber, stage.TransitionIcon)
		    if stage.BossSpot then 
		    	fakeTR.SetStageSpot(stage.BossSpot)
		    end

		    fakeTR.StartTransition()
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

local function CheckLazarusHologram(player)
	if player and player:ToPlayer() then
		if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS_B or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) or
			(player:GetOtherTwin() and player:GetOtherTwin():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
				if player:GetMainTwin().Index ~= player.Index or player:GetMainTwin().InitSeed ~= player.InitSeed then
					return true
				end
			end
		end
	end
	return nil
end


mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    --[[local sprite, data = eff:GetSprite(), eff:GetData()      --Old ai
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
    end]]

	local s = eff:GetSprite()
	local d = eff:GetData()
	local Room = Game():GetRoom()

	--[[if d.GoesTo and e.FrameCount < 2 then  --Thing to fix spawn position. Causes problems
		e.DepthOffset = -50
		local NewPos = e.Position
		for i=0,DoorSlot.NUM_DOOR_SLOTS-1 do
			local door = Room:GetDoor(i)
			if door then
				local GVec = Vector(0,40)	
				local loop = 0

				::redo::
				local doorCheck = true
				if door.Position:Distance(NewPos) < 100 then
					doorCheck = false
					local angle = (NewPos-door.Position):GetAngleDegrees()
					NewPos = Room:FindFreeTilePosition(NewPos+GVec:Rotated(angle+math.random(-90,90)),80)
					NewPos = Room:GetGridPosition(Room:GetGridIndex(NewPos))

					GVec = GVec + Vector(0,10)

					loop = loop + 1
					if loop< 100 and not doorCheck then
						goto redo
					end
				end
			end
		end
		e.Position = NewPos or e.Position
	else]] 
    if d.GoesTo and (eff.FrameCount < 30 or d.PlayerToClose) then
		local PlayerToClose = false
		s:Play("Open Animation",false)
		for _, player in ipairs(shared.Players) do
			local size = (eff.Size + player.Size + 40)
			if not player.Parent and player.Position:DistanceSquared(eff.Position) < size * size then
			--if not player.Parent and player.Position:Distance(eff.Position)<100 then
				PlayerToClose = true
				break
			end
		end
		if PlayerToClose then
			d.PlayerToClose = true
			s:Play("Closed",true)
		elseif eff.FrameCount > 40 then
			d.PlayerToClose = false
		end
	end
	if d.GoesTo and not d.PlayerToClose and eff.FrameCount > 30 then
		if s:IsPlaying("Closed") or s:IsFinished("Closed") then
			s:Play("Open Animation",true)
		elseif s:IsFinished("Open Animation") then
			s:Play("Opened",true)
			d.trapdoorState = 2
		end

		if d.trapdoorState and d.trapdoorState == 2 then  
			
			if not d.StartTransition and not d.Transition then
				d.PlayerCollision = {}
				d.PlayerReady = {}
				d.Playerquery = {}
				for _, player in ipairs(shared.Players) do
					local size = (eff.Size + player.Size)
					--if not player.Parent and not CheckLazarusHologram(player)    --Too big a radius, temporarily left it
					--and player.Position:DistanceSquared(eff.Position) < size * size then
                    if not player.Parent and player.Position:Distance(e.Position)<30   
                    and not CheckLazarusHologram(player) then
						d.StartTransition = true
						break
					end
				end
				if d.StartTransition then
					
					for i=0,Game():GetNumPlayers()-1 do
						local player = Isaac.GetPlayer(i)
						player.ControlsCooldown = math.max(Isaac.GetPlayer(i).ControlsCooldown,100)
						player.Velocity = Vector.Zero
						d.Playerquery[i] = player
						d.PlayerCollision[i] = player.GridCollisionClass
						player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
						d.NumPlayer = Game():GetNumPlayers()
						d.Num = 0
						d.INNum = 0
						d.Timeout = 0
					end
					table.sort(d.Playerquery, function(a,b) if a and b then 
						return a.Position:Distance(eff.Position) < b.Position:Distance(eff.Position) 
						else return nil end 
					end)
				end
			elseif d.StartTransition and not d.Transition then
				if d.Timeout<=0 and d.NumPlayer-d.Num ~= 0 then
					d.Timeout = 5
					if Isaac.GetPlayer(d.Num):GetSprite():GetAnimation() ~= "Trapdoor" then 
						Isaac.GetPlayer(d.Num):AnimateTrapdoor()
					end
					d.Num = d.Num+1
				end
				d.Timeout = d.Timeout - 1
				if d.Num>0 then
					for i=0,d.Num-1 do
						local player = Isaac.GetPlayer(i)
						if player then
							
							local angle = (eff.Position-player.Position):GetAngleDegrees()
							local dist = player.Position:Distance(eff.Position)
							player.Velocity = Vector.FromAngle(angle):Resized(dist/4)

							if  player.Position:Distance(eff.Position)<40          
							and (player:IsExtraAnimationFinished() or player:GetSprite():GetFrame() >= 15 ) 
							and not d.PlayerReady[i] then

								player.PositionOffset = Vector(0,800)
								s:Play("Player Exit",true)
								
								d.PlayerReady[i] = true
								
								local poof = Isaac.Spawn(1000,EffectVariant.POOF01,2,eff.Position+Vector(0,10),Vector(0,0),eff)
								poof.DepthOffset = -10
								poof:GetSprite().Color = Color(1,1,1,0.5)
								poof:GetSprite():SetFrame(3)
							end
							
							if player:GetSprite():GetAnimation() ~= "Trapdoor" and player.PositionOffset.Y<400 then  
								player:AnimateTrapdoor()
							end
						end
					end
					local num = 0
					for k,player in pairs(d.PlayerReady) do
						num = num + 1
					end
					if num >= d.NumPlayer then
						d.Transition = 1
						for i, coll in pairs(d.PlayerCollision) do
							Isaac.GetPlayer(i).GridCollisionClass = coll
						end
					end
				end
			elseif d.Transition == 1 then
				StageAPI.GotoCustomStage(d.GoesTo, true)
				d.Transition = 2
			elseif d.Transition == 2 then
				for _, player in ipairs(shared.Players) do
					local angle = (eff.Position-player.Position):GetAngleDegrees()
					local dist = player.Position:Distance(eff.Position)
					player.Velocity = Vector.FromAngle(angle):Resized(dist/10)
				end
			end
		end
	end

end, StageAPI.E.Trapdoor.V)
