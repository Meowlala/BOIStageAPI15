
StageAPI.LogMinor("Loading Room List Handler")

local subModules = {
    "layout",
    "roomsList",
    "levelRoom",
    "roomMetadata",
    "persistentEnts",
    "roomHandler",
}

local moduleName = "room"

for _, subModule in ipairs(subModules) do
    include("scripts.stageapi." .. moduleName .. "." .. subModule)
end