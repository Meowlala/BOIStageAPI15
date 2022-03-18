local mod = require("scripts.stageapi.mod")
local shared = require("scripts.stageapi.shared")

-- Is pause menu open, from Revelations, itself a modified version of code from Dynamic Note Items

local MenuItems = {
	OPTIONS = 1,
	RESUME = 2,
	EXIT = 3
}

local MenuLevel = {
    MAIN = 1,
    OPTIONS = 2,
}

local APPEAR_DURATION = 12
local APPEAR_DURATION_BG = 5
local DISAPPEAR_DURATION = 10 -- or "Dissapear", as they say
local DISAPPEAR_DURATION_BG = 6

local IsPaused = false
local CurrentMenuItem = MenuItems.RESUME
local CurrentMenuLevel = MenuLevel.MAIN
local AppearAnimFrame = -1
local IsAppearAnim = true -- false when disappearing

-- Not perfect: won't detect pause menu opened from switching windows
function StageAPI.IsPauseMenuOpen()
    return shared.Game:IsPaused() and IsPaused
end

-- Returns percentage of pause menu open/close anim
function StageAPI.GetPauseMenuAppearPct()
    if AppearAnimFrame < 0 then
        return 0
    end

    if IsAppearAnim then
        return AppearAnimFrame / APPEAR_DURATION
    else
        return AppearAnimFrame / DISAPPEAR_DURATION
    end
end

local function Saturate(x)
    return math.max(0, math.min(1, x))
end

-- Returns how much the pause menu is darkened
function StageAPI.GetPauseMenuDarkPct()
    if AppearAnimFrame < 0 then
        return 0
    end

    if IsAppearAnim then
        return Saturate(AppearAnimFrame / APPEAR_DURATION_BG)
    else
        return Saturate(AppearAnimFrame / DISAPPEAR_DURATION_BG)
    end
end

local function IsPausePressed(player)
	return Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, player.ControllerIndex) 
        or Input.IsActionTriggered(ButtonAction.ACTION_PAUSE, player.ControllerIndex) 
end

local function isPaused_PostRender()
    local isGamePaused = shared.Game:IsPaused()

    if AppearAnimFrame >= 0 
    and AppearAnimFrame <= APPEAR_DURATION
    -- and StageAPI.IsOddRenderFrame -- it actually seems to be 60fps
    then
        if IsAppearAnim and AppearAnimFrame < APPEAR_DURATION then
            AppearAnimFrame = AppearAnimFrame + 1
        elseif not IsAppearAnim then
            AppearAnimFrame = AppearAnimFrame - 1
            if AppearAnimFrame < 0 then
                IsAppearAnim = true
            end
        end
    end

    if not isGamePaused and IsPaused then
        IsPaused = false
        CurrentMenuItem = MenuItems.RESUME
        CurrentMenuLevel = MenuLevel.MAIN
        AppearAnimFrame = -1
        IsAppearAnim = true
        return
    end

    local player = shared.Players[1]

    local justPaused = false

	if not IsPaused and IsPausePressed(player) then
		IsPaused = true
        justPaused = true
        CurrentMenuLevel = MenuLevel.MAIN
        AppearAnimFrame = 0
	end

	if IsPaused then
        -- if in main pause menu
		if CurrentMenuLevel == MenuLevel.MAIN then
            --track cursor movement
			if Input.IsActionTriggered(ButtonAction.ACTION_MENUUP, player.ControllerIndex) then
				if CurrentMenuItem > MenuItems.OPTIONS then
					CurrentMenuItem = CurrentMenuItem - 1
				else
					CurrentMenuItem = MenuItems.EXIT
				end
			elseif Input.IsActionTriggered(ButtonAction.ACTION_MENUDOWN, player.ControllerIndex) then
				if CurrentMenuItem < MenuItems.EXIT then
					CurrentMenuItem = CurrentMenuItem + 1
				else
					CurrentMenuItem = MenuItems.OPTIONS
				end
			elseif Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, player.ControllerIndex) then
				if CurrentMenuItem == MenuItems.OPTIONS then
					CurrentMenuLevel = MenuLevel.OPTIONS
                elseif CurrentMenuItem == MenuItems.RESUME then
                    IsPaused = false
                    IsAppearAnim = false
                    AppearAnimFrame = DISAPPEAR_DURATION
				end
			elseif not justPaused and Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, player.ControllerIndex) then
                IsPaused = false
                IsAppearAnim = false
                AppearAnimFrame = DISAPPEAR_DURATION
			end
		elseif CurrentMenuLevel == MenuLevel.OPTIONS then
			if Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, player.ControllerIndex) then
				CurrentMenuLevel = MenuLevel.MAIN
			end
        else
            CurrentMenuItem = MenuItems.RESUME
            CurrentMenuLevel = MenuLevel.MAIN
        end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, isPaused_PostRender)
