StageAPI.LogMinor("Loading Reimplementation Data")

local subModules = {
    "doors",
    "gfx",
    "stages",
    -- "bossAnimations", not needed as it was empty in the original version
    "bosses",
    "floorInfo",
}

for _, subModule in ipairs(subModules) do
    include("scripts.stageapi.data." .. subModule)
end