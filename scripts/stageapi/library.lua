local shared = require("scripts.stageapi.shared")

StageAPI.LogMinor("Loading Library")

local subModules = {
    "callbacks",
    "class",
    "random",
    "pits",
    "streaks",
    "tables",
    "misc",
    "pauseDetection",
	"deadendDetection",
    "lockedEntity",
}

for _, subModule in ipairs(subModules) do
    include("scripts.stageapi.library." .. subModule)
end
