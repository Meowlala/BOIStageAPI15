-- Tables

function StageAPI.IsIn(tbl, v, fn)
    fn = fn or ipairs
    for k, v2 in fn(tbl) do
        if v2 == v then
            return k or true
        end
    end
end

function StageAPI.Copy(tbl)
    local t = {}
    for k, v in pairs(tbl) do
        t[k] = v
    end
    return t
end

function StageAPI.DeepCopy(tbl)
    local t = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            t[k] = StageAPI.DeepCopy(v)
        else
            t[k] = v
        end
    end

    return t
end

function StageAPI.Merged(...)
    local t = {}
    for _, tbl in ipairs({...}) do
        local orderedIndices = {}
        for i, v in ipairs(tbl) do
            orderedIndices[i] = true
            t[#t + 1] = v
        end

        for k, v in pairs(tbl) do
            if not orderedIndices[k] then
                t[k] = v
            end
        end
    end

    return t
end
