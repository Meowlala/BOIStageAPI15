local shared = require("scripts.stageapi.shared")

-- Classes

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
    __call = StageAPI.ClassInit
})
