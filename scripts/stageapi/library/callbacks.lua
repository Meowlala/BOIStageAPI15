local shared = require("scripts.stageapi.shared")

-- callbacks

StageAPI.Callbacks = {}

local function Reverse_Iterator(t,i)
    i=i-1
    local v=t[i]
    if v==nil then return v end
    return i,v
end

function StageAPI.ReverseIterate(t)
    return Reverse_Iterator, t, #t+1
end

function StageAPI.AddCallback(modID, id, priority, fn, ...)
    if not StageAPI.Callbacks[id] then
        StageAPI.Callbacks[id] = {}
    end

    local index = 1

    for i, callback in StageAPI.ReverseIterate(StageAPI.Callbacks[id]) do
        if priority >= callback.Priority then
            index = i + 1
            break
        end
    end

    table.insert(StageAPI.Callbacks[id], index, {
        Priority = priority,
        Function = fn,
        ModID = modID,
        Params = {...}
    })
end

function StageAPI.UnregisterCallbacks(modID)
    for id, callbacks in pairs(StageAPI.Callbacks) do
        for i, callback in StageAPI.ReverseIterate(callbacks) do
            if callback.ModID == modID then
                table.remove(callbacks, i)
            end
        end
    end
end

StageAPI.UnregisterCallbacks("StageAPI")

function StageAPI.GetCallbacks(id)
    return StageAPI.Callbacks[id] or {}
end

function StageAPI.CallCallbacks(id, breakOnFirstReturn, ...)
    for _, callback in ipairs(StageAPI.GetCallbacks(id)) do
        local ret = callback.Function(...)
        if breakOnFirstReturn and ret ~= nil then
            return ret
        end
    end
end
