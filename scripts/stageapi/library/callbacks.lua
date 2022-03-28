local shared = require("scripts.stageapi.shared")

---@class StageAPICallback
---@field ModID any
---@field Function function
---@field Params table
---@field Priority number

---@alias callbackId any

---@type table<callbackId, table<integer, StageAPICallback>>
StageAPI.Callbacks = {}

local function Reverse_Iterator(t,i)
    i=i-1
    local v=t[i]
    if v==nil then return v end
    return i,v
end

---@param t table
function StageAPI.ReverseIterate(t)
    return Reverse_Iterator, t, #t+1
end

---@param modID any
---@param id any
---@param priority number
---@param fn function
---@param ... any # params for the callback
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

---@param id callbackId
---@return table
function StageAPI.GetCallbacks(id)
    return StageAPI.Callbacks[id] or {}
end

---@param id callbackId
---@param breakOnFirstReturn boolean
---@param ... any # callback args
---@return any # return type of the callback
function StageAPI.CallCallbacks(id, breakOnFirstReturn, ...)
    for _, callback in ipairs(StageAPI.GetCallbacks(id)) do
        local ret = callback.Function(...)
        if breakOnFirstReturn and ret ~= nil then
            return ret
        end
    end
end

---@param id callbackId
---@param breakOnFirstReturn boolean
---@param matchParams any | table # can be a single param, or a table of params to match
---@param ... any # callback args
---@return any # return type of the callback
function StageAPI.CallCallbacksWithParams(id, breakOnFirstReturn, matchParams, ...)
    if type(matchParams) ~= "table" then
        matchParams = {matchParams}
    end

    local callbacks = StageAPI.GetCallbacks(id)
    for _, callback in ipairs(callbacks) do
        local matches = true
        for i, param in ipairs(matchParams) do
            matches = matches and (param == callback.Params[i] or not callback.Params[i])
        end
        if matches then
            local ret = callback.Function(...)
            if breakOnFirstReturn and ret ~= nil then
                return ret
            end
        end
    end
end
