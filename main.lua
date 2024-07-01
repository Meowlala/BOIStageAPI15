if debug then -- reload mod if luadebug is enabled, fixes luamod
    package.loaded["scripts.stageapi.mod"] = false
end

require("scripts.stageapi.mod")

-- Documentation moved to doc.md

if not StageAPI then
    StageAPI = {}
end

local loadOrder = include("scripts.stageapi.loadOrder")

StageAPI.Enum = {}

for _, module in ipairs(loadOrder) do
    include(module)
end

StageAPI.LogMinor("Fully Loaded, loading dependent mods.")
StageAPI.MarkLoaded("StageAPI", "2.30", true, true)

StageAPI.Loaded = true
if StageAPI.ToCall then
    for _, fn in ipairs(StageAPI.ToCall) do
        fn()
    end
end
