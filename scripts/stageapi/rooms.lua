
StageAPI.LogMinor("Loading Room List Handler")

local subModules = {
    "layout",
    "roomsList",
    "levelRoom",
    "roomMetadata",
    "persistentEnts",
    "roomHandler",
}

for _, subModule in ipairs(subModules) do
    include("scripts.stageapi.rooms." .. subModule)
end