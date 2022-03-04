local shared = require("scripts.stageapi.shared")

-- Boss Data

local function quickBossData(name, entity, ignoreEntity, mergeInAfter, filesName)
    local prefix = "gfx/ui/boss/"
    local midfix = ""
    if entity then
        if #entity > 0 then
            entity = {
                Type = entity[1],
                Variant = entity[2],
                SubType = entity[3]
            }
        end

        if not ignoreEntity then
            midfix = tostring(entity.Type) .. "." .. tostring(entity.Variant) .. "_"
        end
    end

    local cleanName = string.lower(filesName or name)
    cleanName = string.gsub(cleanName, " ", "")
    cleanName = string.gsub(cleanName, "%.", "")
    cleanName = string.gsub(cleanName, "'", "")
    cleanName = string.gsub(cleanName, "%-", "")

    local bossData = {
        Entity = entity,
        Portrait = prefix .. "portrait_" .. midfix .. cleanName .. ".png",
        Bossname = prefix .. "bossname_" .. midfix .. cleanName .. ".png",
        BaseGameBoss = true
    }

    if mergeInAfter then
        bossData = StageAPI.Merged(bossData, mergeInAfter)
    end

    return name, bossData
end

StageAPI.AddBossData(quickBossData("Larry Jr", {19, 0}))
StageAPI.AddBossData(quickBossData("The Hollow", {19, 1}))
StageAPI.AddBossData(quickBossData("Monstro", {20, 0}))
StageAPI.AddBossData(quickBossData("Chub", {28, 0}))
StageAPI.AddBossData(quickBossData("Chad", {28, 1}))
StageAPI.AddBossData(quickBossData("Carrion Queen", {28, 2}))
StageAPI.AddBossData(quickBossData("Gurdy", {36, 0}))
StageAPI.AddBossData(quickBossData("Monstro 2", {43, 0}))
StageAPI.AddBossData(quickBossData("Gish", {43, 1}))
StageAPI.AddBossData(quickBossData("Mom", {45, 0}))
StageAPI.AddBossData(quickBossData("Pin", {62, 0}))
StageAPI.AddBossData(quickBossData("Scolex", {62, 1}))
StageAPI.AddBossData(quickBossData("The Frail", {62, 2}, true))
StageAPI.AddBossData(quickBossData("Famine", {63, 0}, nil, {Horseman = true}))
StageAPI.AddBossData(quickBossData("Pestilence", {64, 0}, nil, {Horseman = true}))
StageAPI.AddBossData(quickBossData("War", {65, 0}, nil, {Horseman = true}))
StageAPI.AddBossData(quickBossData("Conquest", {65, 1}, nil, {Horseman = true}))
StageAPI.AddBossData(quickBossData("Death", {66, 0}, nil, {Horseman = true}))
StageAPI.AddBossData(quickBossData("Duke of Flies", {67, 0}))
StageAPI.AddBossData(quickBossData("The Husk", {67, 1}))
StageAPI.AddBossData(quickBossData("Peep", {68, 0}))
StageAPI.AddBossData(quickBossData("The Bloat", {68, 1}, nil, nil, "bloat"))
StageAPI.AddBossData(quickBossData("Loki", {69, 0}))
StageAPI.AddBossData(quickBossData("Lokii", {69, 1}))
StageAPI.AddBossData(quickBossData("Fistula", {71, 0}))
StageAPI.AddBossData(quickBossData("Teratoma", {71, 1}))
StageAPI.AddBossData(quickBossData("Blastocyst", {74, 0}))
StageAPI.AddBossData(quickBossData("Mom's Heart", {78, 0}))
StageAPI.AddBossData(quickBossData("It Lives", {78, 1}))
StageAPI.AddBossData(quickBossData("Gemini", {79, 0}))
StageAPI.AddBossData(quickBossData("Steven", {79, 1}))
StageAPI.AddBossData(quickBossData("Blighted Ovum", {79, 2}))
StageAPI.AddBossData(quickBossData("The Fallen", {81, 0}))
StageAPI.AddBossData(quickBossData("Krampus", {81, 1}))
StageAPI.AddBossData(quickBossData("Headless Horseman", {82, 0}))
StageAPI.AddBossData(quickBossData("Satan", {84, 0}))
StageAPI.AddBossData(quickBossData("Mask of Infamy", {97, 0}))
StageAPI.AddBossData(quickBossData("Gurdy Jr", {99, 0}))
StageAPI.AddBossData(quickBossData("Widow", {100, 0}))
StageAPI.AddBossData(quickBossData("The Wretched", {100, 1}))
StageAPI.AddBossData(quickBossData("Daddy Long Legs", {101, 0}))
StageAPI.AddBossData(quickBossData("Triachnid", {101, 1}))
StageAPI.AddBossData(quickBossData("Isaac", {102, 0}, nil, {Bossname = "gfx/ui/boss/playername_01_isaac.png"}))
StageAPI.AddBossData(quickBossData("Blue Baby", {102, 1}))
StageAPI.AddBossData(quickBossData("The Haunt", {260, 0}))
StageAPI.AddBossData(quickBossData("Dingle", {261, 0}))
StageAPI.AddBossData(quickBossData("Dangle", {261, 1}, true))
StageAPI.AddBossData(quickBossData("Mega Maw", {262, 0}))
StageAPI.AddBossData(quickBossData("The Gate", {263, 0}, nil, nil, "megamaw2"))
StageAPI.AddBossData(quickBossData("Mega Fatty", {264, 0}))
StageAPI.AddBossData(quickBossData("The Cage", {265, 0}, nil, nil, "fatty2"))
StageAPI.AddBossData(quickBossData("Mama Gurdy", {266, 0}))
StageAPI.AddBossData(quickBossData("Dark One", {267, 0}))
StageAPI.AddBossData(quickBossData("The Adversary", {268, 0}, nil, nil, "darkone2"))
StageAPI.AddBossData(quickBossData("Polycephalus", {269, 0}))
StageAPI.AddBossData(quickBossData("Mr. Fred", {270, 0}, nil, nil, "megafred"))
StageAPI.AddBossData(quickBossData("The Lamb", {273, 0}))
StageAPI.AddBossData(quickBossData("Mega Satan", {274, 0}))
StageAPI.AddBossData(quickBossData("Gurglings", {276, 0}, nil, {Entity = {Type = 276, Variant = 1}}))
StageAPI.AddBossData(quickBossData("Turdlings", {276, 2}, true))
StageAPI.AddBossData(quickBossData("The Stain", {401, 0}))
StageAPI.AddBossData(quickBossData("Brownie", {402, 0}))
StageAPI.AddBossData(quickBossData("The Forsaken", {403, 0}))
StageAPI.AddBossData(quickBossData("Little Horn", {404, 0}))
StageAPI.AddBossData(quickBossData("Rag Man", {405, 0}))
StageAPI.AddBossData(quickBossData("Ultra Greed", {406, 0}))
StageAPI.AddBossData(quickBossData("Hush", {407, 0}))
StageAPI.AddBossData(quickBossData("Rag Mega", {409, 0}, true))
StageAPI.AddBossData(quickBossData("Sisters Vis", {410, 0}, true))
StageAPI.AddBossData(quickBossData("Big Horn", {411, 0}, true))
StageAPI.AddBossData(quickBossData("Delirium", {412, 0}, true))
StageAPI.AddBossData(quickBossData("The Matriarch", {413, 0}, true, nil, "matriarch"))

-- Repentance
StageAPI.AddBossData(quickBossData("Tuff Twins", {19, 0}, true))
StageAPI.AddBossData(quickBossData("The Shell", {19, 1}, true, nil, "shell"))
StageAPI.AddBossData(quickBossData("Wormwood", {62, 3}, true))
StageAPI.AddBossData(quickBossData("The Pile", {269, 1}, true, nil, "polycephalus2"))

StageAPI.AddBossData(quickBossData("Reap Creep", {900, 0}, true))
StageAPI.AddBossData(quickBossData("Lil Blub", {901, 0}, true, nil, "beelzeblub"))
StageAPI.AddBossData(quickBossData("The Rainmaker", {902, 0}, true, nil, "rainmaker"))
StageAPI.AddBossData(quickBossData("The Visage", {903, 0}, true, nil, "visage"))
StageAPI.AddBossData(quickBossData("The Siren", {904, 0}, true, nil, "siren"))
StageAPI.AddBossData(quickBossData("The Heretic", {905, 0}, true, nil, "heretic"))
StageAPI.AddBossData(quickBossData("Hornfel", {906, 0}, true))
StageAPI.AddBossData(quickBossData("Great Gideon", {907, 0}, true, nil, "gideon"))
StageAPI.AddBossData(quickBossData("Baby Plum", {908, 0}, true))
StageAPI.AddBossData(quickBossData("The Scourge", {909, 0}, true, nil, "scourge"))
StageAPI.AddBossData(quickBossData("Chimera", {910, 0}, true))
StageAPI.AddBossData(quickBossData("Rotgut", {911, 0}, true))
StageAPI.AddBossData(quickBossData("Mother", {912, 0}, true))
StageAPI.AddBossData(quickBossData("Min-Min", {913, 0}, true))
StageAPI.AddBossData(quickBossData("Clog", {914, 0}, true))
StageAPI.AddBossData(quickBossData("Singe", {915, 0}, true))
StageAPI.AddBossData(quickBossData("Bumbino", {916, 0}, true))
StageAPI.AddBossData(quickBossData("Colostomia", {917, 0}, true))
StageAPI.AddBossData(quickBossData("Turdlet", {918, 0}, true))
StageAPI.AddBossData(quickBossData("Raglich", {919, 0}, true))
StageAPI.AddBossData(quickBossData("Horny Boys", {920, 0}, true))
StageAPI.AddBossData(quickBossData("Clutch", {921, 0}, true))
StageAPI.AddBossData(quickBossData("Dogma", {950, 0}, true))
