local shared = require("scripts.stageapi.shared")

---@class StageAPICallback
---@field ModID any
---@field Function function
---@field Params table
---@field Priority number
---@field CallbackID any # used for error printing

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
---@param priority number # The higher the priority, the later it goes
---@param fn function
---@vararg any
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
        Params = {...},
        CallbackID = id,
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

---Ideally callbacks obtained this way should be called with TryCallback/TryCallbackParams
---to do the error check
---@param id callbackId
---@return StageAPICallback[]
function StageAPI.GetCallbacks(id)
    return StageAPI.Callbacks[id] or {}
end

---@param id callbackId
---@param breakOnFirstReturn? boolean
---@param ... any # callback args
---@return any # return type of the callback
function StageAPI.CallCallbacks(id, breakOnFirstReturn, ...)
    local finalRet
    for _, callback in ipairs(StageAPI.GetCallbacks(id)) do
        local success, ret = StageAPI.TryCallback(callback, ...)
        if success and ret ~= nil then
            if breakOnFirstReturn then
                return ret
            end
            finalRet = ret
        end
    end
    return finalRet
end

---@param callback StageAPICallback
---@param params table
local function MatchesParams(callback, params)
    local matches = true
    for i, param in ipairs(params) do
        if callback.Params[i] then
            if type(param) == "table" and param.Type == "CustomStage" then
                matches = matches and StageAPI.IsSameStage(param, callback.Params[i], false)
            else
                matches = matches and param == callback.Params[i]
            end
        end
    end
    return matches
end

---Calls callbacks that match params
---@param id callbackId
---@param breakOnFirstReturn boolean
---@param matchParams any # can be a single param, or a table of params to match
---@param ... any # callback args
---@return any # return type of the callback
function StageAPI.CallCallbacksWithParams(id, breakOnFirstReturn, matchParams, ...)
    if type(matchParams) ~= "table" then
        matchParams = {matchParams}
    end

    local finalRet

    local callbacks = StageAPI.GetCallbacks(id)
    for _, callback in ipairs(callbacks) do
        if MatchesParams(callback, matchParams) then
            local success, ret = StageAPI.TryCallbackParams(callback, matchParams, ...)
            if success and ret ~= nil then
                if breakOnFirstReturn then
                    return ret
                end
                finalRet = ret
            end
        end
    end

    return finalRet
end

---Calls callbacks, passing the last non nil return value
---as first argument to each (and starting with startValue)
---@generic V
---@param id callbackId
---@param startValue V
---@param ... any # callback args
---@return V # return type of the callback
function StageAPI.CallCallbacksAccumulator(id, startValue, ...)
    local finalRet = startValue
    for _, callback in ipairs(StageAPI.GetCallbacks(id)) do
        local success, ret = StageAPI.TryCallback(callback, finalRet, ...)
        if success and ret ~= nil then
            finalRet = ret
        end
    end
    return finalRet
end

---Calls callbacks, passing the last non nil return value
---as first argument to each (and starting with startValue)
---and also using params
---@generic V
---@param id callbackId
---@param matchParams any # can be a single param, or a table of params to match
---@param startValue V
---@param ... any # callback args
---@return V # return type of the callback
function StageAPI.CallCallbacksAccumulatorParams(id, matchParams, startValue, ...)
    if type(matchParams) ~= "table" then
        matchParams = {matchParams}
    end

    local finalRet = startValue
    for _, callback in ipairs(StageAPI.GetCallbacks(id)) do
        if MatchesParams(callback, matchParams) then
            local success, ret = StageAPI.TryCallbackParams(callback, matchParams, finalRet, ...)
            if success and ret ~= nil then
                finalRet = ret
            end
        end
    end
    return finalRet
end

---@param callback StageAPICallback
---@return boolean, any # returns success, return value of callback
function StageAPI.TryCallback(callback, ...)
    local success, ret = pcall(callback.Function, ...)
    if success then
        return true, ret
    else
        StageAPI.LogErr(("[Callback: %s]"):format(tostring(callback.CallbackID)), ret)
        return false
    end
end

---@param callback StageAPICallback
---@param params any
---@return boolean, any # returns success, return value of callback
function StageAPI.TryCallbackParams(callback, params, ...)
    local success, ret = pcall(callback.Function, ...)
    if success then
        return true, ret
    else
        local paramString
        if type(params) == "table" then
            local stringParams = {}
            for i, param in ipairs(params) do
                stringParams[i] = tostring(param)
            end
            paramString = table.concat(stringParams, ", ")
        else
            paramString = tostring(params)
        end
        StageAPI.LogErr(("[Callback: %s <%s>]"):format(tostring(callback.CallbackID), paramString), ret)
        return false
    end
end

---Separate function as table packing/unpacking 
---would be slower for generic-purpose calls (that
---might be made for each room entitiy, multiple times, 
---etc.); difference not too big, but might as well
---@param callback StageAPICallback
---@return boolean, any, ... # returns success, return value of callback
function StageAPI.TryCallbackMultiReturn(callback, ...)
    local rets = {pcall(callback.Function, ...)}
    local success = rets[1]
    if success then
        return true, table.unpack(rets, 2)
    else
        StageAPI.LogErr(("[Callback: %s]"):format(tostring(callback.CallbackID)), rets[2])
        return false
    end
end

---Separate function as table packing/unpacking 
---would be slower for generic-purpose calls (that
---might be made for each room entitiy, multiple times, 
---etc.); difference not too big, but might as well
---@param callback StageAPICallback
---@param params any
---@return boolean, any, ... # returns success, return value of callback
function StageAPI.TryCallbackMultiReturnParams(callback, params, ...)
    local rets = {pcall(callback.Function, ...)}
    local success = rets[1]
    if success then
        return true, table.unpack(rets, 2)
    else
        local paramString
        if type(params) == "table" then
            local stringParams = {}
            for i, param in ipairs(params) do
                stringParams[i] = tostring(param)
            end
            paramString = table.concat(stringParams, ", ")
        else
            paramString = tostring(params)
        end
        StageAPI.LogErr(("[Callback: %s <%s>]"):format(tostring(callback.CallbackID), paramString), rets[2])
        return false
    end
end


local TEST = false

if TEST then
    local TestModId = "TestCall"
    local TestCallback = "TestCallback"

    --use lua <funcname>() for these

    function CallTestAccumulator()
        StageAPI.UnregisterCallbacks(TestModId)
        StageAPI.Log("Start test CallTestAccumulator:")
        StageAPI.AddCallback(TestModId, TestCallback, 1, function(x, b) return x + b end)
        StageAPI.AddCallback(TestModId, TestCallback, 1, function(x, b) return x + 2 * b end)
        local result = StageAPI.CallCallbacksAccumulator(TestCallback, 1, 2)
        assert(result == 7, "result wrong! " .. tostring(result))
        StageAPI.Log("Success!")
    end

    function CallTestAccumulatorParams()
        StageAPI.UnregisterCallbacks(TestModId)
        StageAPI.Log("Start test CallTestAccumulatorParams:")
        StageAPI.AddCallback(TestModId, TestCallback, 1, function(x, b) return x + b end, "A")
        StageAPI.AddCallback(TestModId, TestCallback, 1, function(x, b) return x + 2 * b end)
        local result = StageAPI.CallCallbacksAccumulatorParams(TestCallback, "A", 1, 2)
        assert(result == 7, "result wrong! should be 7, is " .. tostring(result))
        result       = StageAPI.CallCallbacksAccumulatorParams(TestCallback, "B", 1, 2)
        assert(result == 5, "result wrong! should be 5, is " .. tostring(result))
        StageAPI.Log("Success!")
    end
end