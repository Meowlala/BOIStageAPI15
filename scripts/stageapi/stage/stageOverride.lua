local shared = require("scripts.stageapi.shared")

StageAPI.LogMinor("Loading Stage Override Definitions")

function StageAPI.BackdropHelper(backdrop, prefix, suffix)
    if #backdrop < 1 then
        backdrop = {backdrop}
    end

    for i, backdropVariant in ipairs(backdrop) do
        for k, backdropFiles in pairs(backdropVariant) do
            for i2, file in ipairs(backdropFiles) do
                if type(file) == "table" then
                    for i3, file2 in ipairs(file) do
                        backdrop[i][k][i2][i3] = prefix .. file2 .. suffix
                    end
                else
                    backdrop[i][k][i2] = prefix .. file .. suffix
                end
            end
        end
    end

    return backdrop
end

StageAPI.StageOverride = {}

function StageAPI.AddOverrideStage(name, overrideStage, overrideStageType, replaceWith, isGreedMode)
    StageAPI.StageOverride[name] = {
        OverrideStage = overrideStage,
        OverrideStageType = overrideStageType,
        ReplaceWith = replaceWith,
        GreedMode = isGreedMode
    }
end

function StageAPI.InOverriddenStage()
    for name, override in pairs(StageAPI.StageOverride) do
        if (not not override.GreedMode) == shared.Game:IsGreedMode() then
            local isStage = shared.Level:GetStage() == override.OverrideStage and
                            shared.Level:GetStageType() == override.OverrideStageType
            if isStage then
                return true, override, name
            end
        end
    end
end

function StageAPI.InOverrideStage()
    for name, override in pairs(StageAPI.StageOverride) do
        if override.ReplaceWith:IsStage() then
            return true
        end
    end
end

StageAPI.NextStage = nil
StageAPI.CurrentStage = nil

function StageAPI.InNewStage()
    return StageAPI.CurrentStage and not StageAPI.InOverrideStage()
end

function StageAPI.GetCurrentStage()
    return StageAPI.CurrentStage
end

function StageAPI.GetNextStage()
    return StageAPI.NextStage
end

function StageAPI.GetCurrentStageDisplayName()
    if StageAPI.CurrentStage then
        return StageAPI.CurrentStage:GetDisplayName()
    end
end

function StageAPI.GetCurrentListIndex()
    return shared.Level:GetCurrentRoomDesc().ListIndex
end