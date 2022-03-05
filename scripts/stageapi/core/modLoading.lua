local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

StageAPI.LoadedMods = {}
StageAPI.RunWhenLoaded = {}
function StageAPI.MarkLoaded(name, version, prntVersionOnNewGame, prntVersion, prefix)
    StageAPI.LoadedMods[name] = {Name = name, Version = version, PrintVersion = prntVersionOnNewGame, Prefix = prefix or "v"}
    if StageAPI.RunWhenLoaded[name] then
        for _, fn in ipairs(StageAPI.RunWhenLoaded[name]) do
            fn()
        end
    end

    if prntVersion then
        prefix = prefix or "v"
        StageAPI.Log(name .. " Loaded " .. prefix .. version)
    end
end

local versionPrintTimer = 0
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    versionPrintTimer = 60
end)

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if versionPrintTimer > 0 then
        versionPrintTimer = versionPrintTimer - 1
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if versionPrintTimer > 0 then
        local bottomRight = StageAPI.GetScreenBottomRight()
        local renderY = bottomRight.Y - 12
        local renderX = 12
        local isFirst = true
        for name, modData in pairs(StageAPI.LoadedMods) do
            if modData.PrintVersion then
                local text = name .. " " .. modData.Prefix .. modData.Version
                if isFirst then
                    isFirst = false
                else
                    text = ", " .. text
                end

                Isaac.RenderScaledText(text, renderX, renderY, 0.5, 0.5, 1, 1, 1, (versionPrintTimer / 60) * 0.5)
                renderX = renderX + Isaac.GetTextWidth(text) * 0.5
            end
        end
    end
end)

function StageAPI.RunWhenMarkedLoaded(name, fn)
    if StageAPI.LoadedMods[name] then
        fn()
    else
        if not StageAPI.RunWhenLoaded[name] then
            StageAPI.RunWhenLoaded[name] = {}
        end

        StageAPI.RunWhenLoaded[name][#StageAPI.RunWhenLoaded[name] + 1] = fn
    end
end