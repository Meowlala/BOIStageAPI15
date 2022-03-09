local mod = require("scripts.stageapi.mod")

function StageAPI.UpdateMinimapAPIPlayerPosition()
    if StageAPI.InExtraRoom() then
        local currentLevelMap = StageAPI.GetCurrentLevelMap()
        local roomData = currentLevelMap:GetCurrentRoomData()
        if roomData then
            if roomData.X and roomData.Y then
                return Vector(roomData.X, roomData.Y)
            else
                return Vector(-32768, -32768)
            end
        end
    end
end

function StageAPI.UpdateMinimapAPIDimension(currentDimension)
    if StageAPI.InExtraRoom() then
        local currentLevelMap = StageAPI.GetCurrentLevelMap()
        if currentLevelMap.OverlapDimension then
            if currentDimension ~= currentLevelMap.OverlapDimension then
                return currentLevelMap.OverlapDimension
            end
        else
            local level = MinimapAPI:GetLevel(currentLevelMap.Dimension)
            if not level then
                MinimapAPI:SetLevel({}, currentLevelMap.Dimension)
            end

            return currentLevelMap.Dimension
        end
    end
end

function StageAPI.LoadMinimapAPICompat()
    MinimapAPI:AddPlayerPositionCallback(mod, StageAPI.UpdateMinimapAPIPlayerPosition)
    MinimapAPI:AddDimensionCallback(mod, StageAPI.UpdateMinimapAPIDimension)
end
