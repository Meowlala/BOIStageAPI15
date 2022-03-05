local shared = require("scripts.stageapi.shared")

-- Takes whether or not there is a pit in each adjacent space, returns frame to set pit sprite to.
function StageAPI.GetPitFrame(L, R, U, D, UL, DL, UR, DR, hasExtraFrames)
    -- Words were shortened to make writing code simpler.
    local F = 0 -- Sprite frame to set

    -- First bitwise frames (works for all combinations of just left up right and down)
    if L  then F = F | 1 end
    if U  then F = F | 2 end
    if R  then F = F | 4 end
    if D  then F = F | 8 end

    -- Then a bunch of other combinations
    if U and L and not UL and not R and not D then          F = 17 end
    if U and R and not UR and not L and not D then          F = 18 end
    if L and D and not DL and not U and not R then          F = 19 end
    if R and D and not DR and not L and not U then          F = 20 end
    if L and U and R and D and not UL then                  F = 21 end
    if L and U and R and D and not UR then                  F = 22 end
    if U and R and D and not L and not UR then              F = 25 end
    if L and U and D and not R and not UL then              F = 26 end
    if hasExtraFrames then
        if U and L and D and UL and not DL then                                 F = 35 end
        if U and R and D and UR and not DR then                                 F = 36 end
    end
    if L and U and R and D and not DL and not DR then       F = 24 end
    if L and U and R and D and not UR and not UL then       F = 23 end
    if L and U and R and UL and not UR and not D then       F = 27 end
    if L and U and R and UR and not UL and not D then       F = 28 end
    if L and U and R and not D and not UR and not UL then   F = 29 end
    if L and R and D and DL and not U and not DR then       F = 30 end
    if L and R and D and DR and not U and not DL then       F = 31 end
    if L and R and D and not U and not DL and not DR then   F = 32 end

    if hasExtraFrames then
        if U and R and D and not L and not UR and not DR then                   F = 33 end
        if U and L and D and not R and not UL and not DL then                   F = 34 end
        if U and R and D and L and UL and UR and DL and not DR then             F = 37 end
        if U and R and D and L and UL and UR and DR and not DL then             F = 38 end
        if U and R and D and L and not UL and not UR and not DR and not DL then F = 39 end
        if U and R and D and L and DL and DR and not UL and not UR then F = 40 end
        if U and R and D and L and DL and UR and not UL and not DR then F = 41 end
        if U and R and D and L and UL and DR and not DL and not UR then F = 42 end
        if U and R and D and L and UL and not DL and not UR and not DR then F = 43 end
        if U and R and D and L and UR and not UL and not DL and not DR then F = 44 end
        if U and R and D and L and DL and not UL and not UR and not DR then F = 45 end
        if U and R and D and L and DR and not UL and not UR and not DL then F = 46 end
        if U and R and D and L and DL and DR and not UL and not UR then F = 47 end
        if U and R and D and L and DL and UL and not UR and not DR then F = 48 end
        if U and R and D and L and DR and UR and not UL and not DL then F = 49 end
    end

    return F
end

local AdjacentAdjustments = {
    {X = -1, Y = 0},
    {X = 1, Y = 0},
    {X = 0, Y = -1},
    {X = 0, Y = 1},
    {X = -1, Y = -1},
    {X = -1, Y = 1},
    {X = 1, Y = -1},
    {X = 1, Y = 1}
}

function StageAPI.GetPitFramesFromIndices(indices, width, height, hasExtraFrames)
    local frames = {}
    for index, _ in pairs(indices) do
        local x, y = StageAPI.GridToVector(index, width)
        local adjIndices = {}
        for _, adjust in ipairs(AdjacentAdjustments) do
            local nX, nY = x + adjust.X, y + adjust.Y
            if (nX >= 0 and nX <= width) and (nY >= 0 and nY <= height) then
                local backToGrid = StageAPI.VectorToGrid(nX, nY, width)
                if indices[backToGrid] then
                    adjIndices[#adjIndices + 1] = true
                else
                    adjIndices[#adjIndices + 1] = false
                end
            else
                adjIndices[#adjIndices + 1] = false
            end
        end
        adjIndices[#adjIndices + 1] = hasExtraFrames
        frames[tostring(index)] = StageAPI.GetPitFrame(table.unpack(adjIndices))
    end

    return frames
end

function StageAPI.GetPitFramesForLayoutEntities(t, v, s, entities, width, height, hasExtraFrames)
    width = width or shared.Room:GetGridWidth()
    height = height or shared.Room:GetGridHeight()
    local indicesWithEntity = StageAPI.GetIndicesWithEntity(t, v, s, entities)

    return StageAPI.GetPitFramesFromIndices(indicesWithEntity, width, height, hasExtraFrames)
end