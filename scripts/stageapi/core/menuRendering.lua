local mod = require("scripts.stageapi.mod")
local json = require("json")

local continueFont = Font()
continueFont:Load("font/teammeatfont12.fnt")

local noneSprite = Sprite()
noneSprite:Load("stageapi/continue_overlay.anm2", true)
noneSprite:Play("Idle", true)

local continueDefaultColor = KColor(56 / 255, 44 / 255, 46 / 255, 1, 0, 0, 0)
local storedStageName = {}
local pivotDistance = 26 -- Obtained from subtracting Text Position Y from Pivot Y on sprite (no way to procedurally do that)
local verticalSeparation = 1.25

if REPENTOGON then
    local checkForStage = true
    local customStage = nil
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
        elseif #storedStageName >= 1 then
            local menuPosition = Isaac.WorldToMenuPosition(MainMenuType.GAME, Vector.Zero)
            local offsetPosition = Vector(33.5, 129 - pivotDistance) -- I'll be honest, this one was just trial and error
            local textSize = Vector.One
            local continueSprite = MainMenu.GetContinueWidgetSprite()
            if continueSprite and MenuManager.GetActiveMenu() == MainMenuType.GAME
            and (not (continueSprite:GetAnimation() == "Dissapear" -- my code works FINE it was just SPELT WRONG
            and continueSprite:GetFrame() >= (continueSprite:GetCurrentAnimationData():GetLength() - 1))) then
                local nullFrame = continueSprite:GetNullFrame("Guide")
                if nullFrame then
                    offsetPosition = offsetPosition + nullFrame:GetPos()
                    textSize = nullFrame:GetScale() 
                end

                local stageName = "Flooded Caves XL" --[[
                    I'm a little lazy right now, and haven't found a way to procedurally get the
                    replaced floor's original name, so I've settled on just making the longest possible
                    string based on vanilla floor names. Should work fine for now
                --]]
                local halfLineHeight = continueFont:GetLineHeight() / 2
                for i = 0, #storedStageName do
                    local halfLineWidth = continueFont:GetStringWidth((i == 0) and stageName or storedStageName[i]) / 2
                    local textCenterPosition = (menuPosition + offsetPosition) 
                        - (Vector(halfLineWidth, -pivotDistance) * textSize)
                    if i == 0 then
                        -- Draw Quad obstructing previous text
                        noneSprite.Scale = Vector(halfLineWidth * 2, halfLineHeight * 2) * textSize
                        noneSprite:Render(textCenterPosition + Vector(0, 2))
                    else
                        continueFont:DrawStringScaled(storedStageName[i], 
                            textCenterPosition.X, textCenterPosition.Y + ((halfLineHeight * verticalSeparation) * (i - 1) * textSize.Y), 
                            textSize.X, textSize.Y, 
                            continueDefaultColor, 
                            0, true
                        )
                    end
                end
            end
        end
    end
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, shouldSave)
        checkForStage = true
        customStage = nil
        storedStageName = {}
    end)
    mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, onMenuRender)
end