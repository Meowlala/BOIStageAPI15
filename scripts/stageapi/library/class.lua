local shared = require("scripts.stageapi.shared")

-- Classes

-- Classes doc annotations for constructors are done
-- using a placeholder function that will be replaced
-- immediately after by the actual class object, to make
-- the job of the Lua language server easier

---@param Type string
---@param AllowMultipleInit? boolean
---@return StageAPIClass
function StageAPI.Class(Type, AllowMultipleInit)
end

---@class StageAPIClass
---@field Type string
---@field private AllowMultipleInit number
---@field private Initialized boolean
---@field protected Init fun(self: StageAPIClass, ...: any)
---@field protected PostInit fun(self: StageAPIClass, ...: any)
---@field protected InheritInit fun(self: StageAPIClass, ...: any)
StageAPI.Class = {}

function StageAPI.ClassInit(tbl, ...)
    local inst = {}
    setmetatable(inst, tbl)
    tbl.__index = tbl
    tbl.__call = StageAPI.ClassInit

    if inst.AllowMultipleInit or not inst.Initialized then
        inst.Initialized = true
        if inst.Init then
            inst:Init(...)
        end

        if inst.PostInit then
            inst:PostInit(...)
        end
    else
        if inst.InheritInit then
            inst:InheritInit(...)
        end
    end

    return inst
end

function StageAPI.Class:Init(Type, AllowMultipleInit)
    self.Type = Type
    self.AllowMultipleInit = AllowMultipleInit
    self.Initialized = false
end

setmetatable(StageAPI.Class, {
    ---@generic C : StageAPIClass
    ---@param self C
    ---@return C
    __call = StageAPI.ClassInit
})