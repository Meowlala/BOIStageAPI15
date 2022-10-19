StageAPI.LogMinor("Loading Reimplementation Data")

-- originally was data.lua, used more
-- descriptive name

local subModules = {
    "doors",
    "gfx",
    "stages",
    -- "bossAnimations", not needed as it was empty in the original version
    "bosses",
    "floorInfo",
    "music",
    "entityconfig",
}

local moduleName = "reimpl"

for _, subModule in ipairs(subModules) do
    include("scripts.stageapi." .. moduleName .. "." .. subModule)
end