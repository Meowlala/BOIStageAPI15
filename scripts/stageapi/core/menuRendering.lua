local mod = include("scripts.stageapi.mod")
local json = require("json")

local continueFont = Font()
continueFont:Load("font/teammeatfont12.fnt")

-- TODO: sync this anm2 with them continueSprite anm2 just in case someone's changed it
local loadedContinueSprite = Sprite()
loadedContinueSprite:Load("gfx/ui/main menu/continueprogress_widget.anm2")
loadedContinueSprite:LoadGraphics()
loadedContinueSprite:Play("Character")

if REPENTOGON then
    -- It's okay for this number to be a magic number because it's completely hardcoded
    local PAGE_OFFSET_POSITION = Vector(33, 109)

    -- Also hardcoded, no need to bother changing it since there's no way to access a sprite's text
    local CONTINUE_DEFAULT_COLOR = KColor(56 / 255, 44 / 255, 46 / 255, 1)

    -- Arbitrary magic numbers
    local PAGE_MASK_PADDING = 2
    local VERTICAL_SEPARATION = 1.25

    local storedStageName, customStage, checkForStage = {}, nil, true
    local function onMenuRender()
        if checkForStage then
            -- attempt to obtain custom stage
            if Isaac.HasModData(mod) then
                local data = Isaac.LoadModData(mod)
                local attemptedDecode = StageAPI.SaveTableUnmarshal(json.decode(data))
                if attemptedDecode.Stage then
                    customStage = StageAPI.CustomStages[attemptedDecode.Stage]
                end
                if customStage then
                    local stageName = customStage:GetDisplayName()
                    for i in string.gmatch(stageName, "%S+") do
                        table.insert(storedStageName, i)
                    end
                    -- combine the last two
                    local listLength = #storedStageName
                    if listLength > 1 then
                        -- It's okay to insert a space here, as we are removing one anyways
                        storedStageName[listLength - 1] = storedStageName[listLength - 1] .. " " .. storedStageName[listLength]
                        storedStageName[listLength] = nil
                    end
                end
            end
            checkForStage = false
        end
        if ((MenuManager.GetActiveMenu() == MainMenuType.GAME) and (#storedStageName >= 1)) then
            local continueSprite = MainMenu.GetContinueWidgetSprite()
            local stageTextPosition = loadedContinueSprite:GetNullFrame("Stage"):GetPos()
            -- This is not a typo, it is called that in the files for some reason
            if continueSprite and (not (continueSprite:GetAnimation() == "Dissapear"
            and continueSprite:GetFrame() >= (continueSprite:GetCurrentAnimationData():GetLength() - 1))) then
                local spriteMenuPosition = Isaac.WorldToMenuPosition(MainMenuType.GAME, PAGE_OFFSET_POSITION)

                local nullFrame = continueSprite:GetNullFrame("Guide")
                local textSize = Vector.One
                local offsetPosition = spriteMenuPosition
                if nullFrame then
                    textSize = nullFrame:GetScale()
                    offsetPosition = offsetPosition + nullFrame:GetPos()
                end
                
                local stageName = "Flooded Caves XL" --[[
                    I'm a little lazy right now, and haven't found a way to procedurally get the
                    replaced floor's original name, so I've settled on just making the longest possible
                    string based on vanilla floor names. Should work fine for now

                    P.S. this is technically not true, Flooded Caves XL wraps around, but it's the size of the
                    widget so it works well enough for now until someone takes issue with it.
                --]]
                loadedContinueSprite.Scale = textSize
                local textLength = continueFont:GetStringWidth(stageName)

                -- Attempt to mask the widget with itself
                local animationFrame = loadedContinueSprite:GetCurrentAnimationData():GetLayer(1):GetFrame(1)
                if animationFrame then
                    local pivotPosition = animationFrame:GetPivot()
                    local leftMargin = pivotPosition.X - (textLength / 2)
                    local rightMargin = animationFrame:GetWidth() - (pivotPosition.X + (textLength / 2))
                    loadedContinueSprite:RenderLayer(1, offsetPosition, 
                        Vector(leftMargin - PAGE_MASK_PADDING, (pivotPosition.Y + stageTextPosition.Y) - PAGE_MASK_PADDING), 
                        Vector(rightMargin - PAGE_MASK_PADDING, pivotPosition.Y - (pivotPosition.Y - stageTextPosition.Y) + PAGE_MASK_PADDING)
                    )
                end
                local halfLineHeight = continueFont:GetLineHeight() / 2
                for i = 0, #storedStageName do
                    local stringSection = (storedStageName[i] or "")
                    continueFont:DrawStringScaledUTF8(stringSection, 
                        offsetPosition.X - (continueFont:GetStringWidth(stringSection) / 2) * textSize.X, 
                        offsetPosition.Y + (((stageTextPosition.Y - 4) + (halfLineHeight * VERTICAL_SEPARATION) * (i - 1)) * textSize.Y), 
                        textSize.X, textSize.Y, 
                        CONTINUE_DEFAULT_COLOR, 
                        0, true
                    )
                end
            end
        end
    end
    mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, onMenuRender)

    -- Ensure and check stage types after runs are exited
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, shouldSave)
        checkForStage = true
        customStage = nil
        storedStageName = {}
    end)
end