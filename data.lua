StageAPI.LogMinor("Loading Reimplementation Data")

do -- Overriden Stages Reimplementation
    -- Catacombs --

    StageAPI.CatacombsGridGfx = StageAPI.GridGfx()
    StageAPI.CatacombsGridGfx:SetRocks("gfx/grid/rocks_catacombs.png")
    StageAPI.CatacombsGridGfx:SetPits("gfx/grid/grid_pit_catacombs.png", "gfx/grid/grid_pit_water_catacombs.png")
    StageAPI.CatacombsGridGfx:SetDecorations("gfx/grid/props_03_caves.png")

    StageAPI.CatacombsFloors = {
        {"Catacombs1_1", "Catacombs1_2"},
        {"Catacombs2_1", "Catacombs2_2"},
        {"CatacombsExtraFloor_1", "CatacombsExtraFloor_2"}
    }

    StageAPI.CatacombsBackdrop = {
        {
            Walls = {"Catacombs1_1", "Catacombs1_2"},
            FloorVariants = StageAPI.CatacombsFloors,
            NFloors = {"Catacombs_nfloor"},
            LFloors = {"Catacombs_lfloor"},
            Corners = {"Catacombs1_corner"}
        },
        {
            Walls = {"Catacombs2_1", "Catacombs2_2"},
            FloorVariants = StageAPI.CatacombsFloors,
            NFloors = {"Catacombs_nfloor"},
            LFloors = {"Catacombs_lfloor"},
            Corners = {"Catacombs2_corner"}
        }
    }

    StageAPI.CatacombsBackdrop = StageAPI.BackdropHelper(StageAPI.CatacombsBackdrop, "stageapi/floors/catacombs/", ".png")
    StageAPI.CatacombsRoomGfx = StageAPI.RoomGfx(--[[StageAPI.CatacombsBackdrop]] nil, StageAPI.CatacombsGridGfx, "_default")
    StageAPI.Catacombs = StageAPI.CustomStage("Catacombs", nil, true)
    StageAPI.Catacombs:SetStageMusic(Music.MUSIC_CATACOMBS)
    StageAPI.Catacombs:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)
    -- There's no reason to override Catacombs' room gfx, because none of it is reimplemented by StageAPI
    -- StageAPI.Catacombs:SetRoomGfx(StageAPI.CatacombsRoomGfx, {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})
    StageAPI.Catacombs.DisplayName = "Catacombs I"

    StageAPI.CatacombsTwo = StageAPI.Catacombs("Catacombs 2")
    StageAPI.CatacombsTwo.DisplayName = "Catacombs II"

    StageAPI.CatacombsXL = StageAPI.Catacombs("Catacombs XL")
    StageAPI.CatacombsXL.DisplayName = "Catacombs XL"
    StageAPI.Catacombs:SetXLStage(StageAPI.CatacombsXL)

    StageAPI.CatacombsGreed = StageAPI.Catacombs("Catacombs Greed")
    StageAPI.CatacombsGreed.DisplayName = "Catacombs"

    StageAPI.AddOverrideStage("CatacombsOne", LevelStage.STAGE2_1, StageType.STAGETYPE_WOTL, StageAPI.Catacombs)
    StageAPI.AddOverrideStage("CatacombsTwo", LevelStage.STAGE2_2, StageType.STAGETYPE_WOTL, StageAPI.CatacombsTwo)
    StageAPI.AddOverrideStage("CatacombsGreed", LevelStage.STAGE2_GREED, StageType.STAGETYPE_WOTL, StageAPI.CatacombsGreed, true)

    StageAPI.Catacombs:SetReplace(StageAPI.StageOverride.CatacombsOne)
    StageAPI.CatacombsTwo:SetReplace(StageAPI.StageOverride.CatacombsTwo)
    StageAPI.CatacombsGreed:SetReplace(StageAPI.StageOverride.CatacombsGreed)

    -- Necropolis --

    StageAPI.NecropolisGridGfx = StageAPI.GridGfx()
    StageAPI.NecropolisGridGfx:SetRocks("gfx/grid/rocks_depths.png")
    StageAPI.NecropolisGridGfx:SetPits("gfx/grid/grid_pit_necropolis.png")
    StageAPI.NecropolisGridGfx:SetDecorations("gfx/grid/props_05_depths.png", "gfx/grid/props_05_depths.anm2", 43)

    StageAPI.NecropolisBackdrop = {
        {
            Walls = {"necropolis1_1"},
            NFloors = {"necropolis_nfloor1", "necropolis_nfloor2"},
            LFloors = {"necropolis_lfloor"},
            Corners = {"necropolis1_corner"}
        }
    }

    StageAPI.NecropolisOverlays = {
        StageAPI.Overlay("stageapi/floors/necropolis/overlay.anm2", Vector(0.33, -0.15), nil, nil, 0.5),
        StageAPI.Overlay("stageapi/floors/necropolis/overlay.anm2", Vector(-0.33, -0.15), Vector(128, 128), nil, 0.5),
        StageAPI.Overlay("stageapi/floors/necropolis/overlay.anm2", Vector(0.33, 0.1), nil, nil, 0.5),
    }

    StageAPI.NecropolisBackdrop = StageAPI.BackdropHelper(StageAPI.NecropolisBackdrop, "stageapi/floors/necropolis/", ".png")
    StageAPI.NecropolisRoomGfx = StageAPI.RoomGfx(--[[StageAPI.NecropolisBackdrop]] nil, StageAPI.NecropolisGridGfx, "_default")
    StageAPI.Necropolis = StageAPI.CustomStage("Necropolis", nil, true)
    StageAPI.Necropolis:SetStageMusic(Music.MUSIC_NECROPOLIS)
    StageAPI.Necropolis:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)
    -- There's no reason to override Necropolis' room gfx, because none of it is reimplemented by StageAPI
    -- StageAPI.Necropolis:SetRoomGfx(StageAPI.NecropolisRoomGfx, {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})
    StageAPI.Necropolis.DisplayName = "Necropolis I"

    StageAPI.NecropolisTwo = StageAPI.Necropolis("Necropolis 2")
    StageAPI.NecropolisTwo.DisplayName = "Necropolis II"

    StageAPI.NecropolisXL = StageAPI.Necropolis("Necropolis XL")
    StageAPI.NecropolisXL.DisplayName = "Necropolis XL"
    StageAPI.Necropolis:SetXLStage(StageAPI.NecropolisXL)

    StageAPI.NecropolisGreed = StageAPI.Necropolis("Necropolis Greed")
    StageAPI.NecropolisGreed.DisplayName = "Necropolis"

    StageAPI.AddOverrideStage("NecropolisOne", LevelStage.STAGE3_1, StageType.STAGETYPE_WOTL, StageAPI.Necropolis)
    StageAPI.AddOverrideStage("NecropolisTwo", LevelStage.STAGE3_2, StageType.STAGETYPE_WOTL, StageAPI.NecropolisTwo)
    StageAPI.AddOverrideStage("NecropolisGreed", LevelStage.STAGE3_GREED, StageType.STAGETYPE_WOTL, StageAPI.NecropolisGreed, true)

    StageAPI.Necropolis:SetReplace(StageAPI.StageOverride.NecropolisOne)
    StageAPI.NecropolisTwo:SetReplace(StageAPI.StageOverride.NecropolisTwo)
    StageAPI.NecropolisGreed:SetReplace(StageAPI.StageOverride.NecropolisGreed)

    -- Utero --

    StageAPI.UteroGridGfx = StageAPI.GridGfx()
    StageAPI.UteroGridGfx:SetRocks("gfx/grid/rocks_utero.png")
    StageAPI.UteroGridGfx:SetPits("gfx/grid/grid_pit_utero.png")
    StageAPI.UteroGridGfx:SetDecorations("gfx/grid/props_07_utero.png", "gfx/grid/props_07_utero.anm2", 43)

    StageAPI.UteroBackdrop = {
        {
            Walls = {"utero1_1", "utero1_2", "utero1_3", "utero1_4"},
            NFloors = {"utero_nfloor"},
            LFloors = {"utero_lfloor"},
            Corners = {"utero1_corner"}
        }
    }

    StageAPI.UteroBackdrop = StageAPI.BackdropHelper(StageAPI.UteroBackdrop, "stageapi/floors/utero/", ".png")
    StageAPI.UteroRoomGfx = StageAPI.RoomGfx(--[[StageAPI.UteroBackdrop]] nil, StageAPI.UteroGridGfx, "_default")
    StageAPI.Utero = StageAPI.CustomStage("Utero", nil, true)
    StageAPI.Utero:SetStageMusic(Music.MUSIC_UTERO)
    StageAPI.Utero:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)
    -- There's no reason to override Utero's room gfx, because none of it is reimplemented by StageAPI
    -- StageAPI.Utero:SetRoomGfx(StageAPI.UteroRoomGfx, {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})
    StageAPI.Utero.DisplayName = "Utero I"

    StageAPI.UteroTwo = StageAPI.Utero("Utero 2")
    StageAPI.UteroTwo.DisplayName = "Utero II"

    StageAPI.UteroXL = StageAPI.Utero("Utero XL")
    StageAPI.UteroXL.DisplayName = "Utero XL"
    StageAPI.Utero:SetXLStage(StageAPI.UteroXL)

    StageAPI.UteroGreed = StageAPI.Utero("Utero Greed")
    StageAPI.UteroGreed.DisplayName = "Utero"

    StageAPI.AddOverrideStage("UteroOne", LevelStage.STAGE4_1, StageType.STAGETYPE_WOTL, StageAPI.Utero)
    StageAPI.AddOverrideStage("UteroTwo", LevelStage.STAGE4_2, StageType.STAGETYPE_WOTL, StageAPI.UteroTwo)
    StageAPI.AddOverrideStage("UteroGreed", LevelStage.STAGE4_GREED, StageType.STAGETYPE_WOTL, StageAPI.UteroGreed, true)

    StageAPI.Utero:SetReplace(StageAPI.StageOverride.UteroOne)
    StageAPI.UteroTwo:SetReplace(StageAPI.StageOverride.UteroTwo)
    StageAPI.UteroGreed:SetReplace(StageAPI.StageOverride.UteroGreed)
end

do -- Boss Data
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
    StageAPI.AddBossData(quickBossData("Blue Baby", {102, 0}))
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
end

do -- Base Floor Info
    local function poolWrap(pool)
        return {Pool = pool}
    end

    local settingStage = LevelStage.STAGE1_1
    StageAPI.SetFloorInfo({
        Prefix = "01_basement",
        Backdrop = BackdropType.BASEMENT,
        Bosses = poolWrap{
            {BossID = "Monstro"},
            {BossID = "Gemini"},
            {BossID = "Larry Jr"},
            {BossID = "Dingle"},
            {BossID = "Dangle", Weight = 0.25},
            {BossID = "Gurglings"},
            {BossID = "Turdlings", Weight = 0.25},
            {BossID = "Steven", Weight = 0.25},
            {BossID = "Duke of Flies"},
            {BossID = "Little Horn"},
            {BossID = "Baby Plum"},
            {BossID = "Famine", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_ORIGINAL)

    StageAPI.SetFloorInfo({
        Prefix = "02_cellar",
        Backdrop = BackdropType.CELLAR,
        Bosses = poolWrap{
            {BossID = "Pin"},
            {BossID = "Widow"},
            {BossID = "Blighted Ovum"},
            {BossID = "The Haunt"},
            {BossID = "Duke of Flies"},
            {BossID = "Little Horn"},
            {BossID = "Rag Man"},
            {BossID = "Baby Plum"},
            {BossID = "Famine", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_WOTL)

    StageAPI.SetFloorInfo({
        Prefix = "13_burning_basement",
        Backdrop = BackdropType.BURNT_BASEMENT,
        FloorTextColor = Color(0.5,0.5,0.5,1,0,0,0),
        Bosses = poolWrap{
            {BossID = "Monstro"},
            {BossID = "Gemini"},
            {BossID = "Larry Jr"},
            {BossID = "Dingle"},
            {BossID = "Dangle", Weight = 0.25},
            {BossID = "Gurglings"},
            {BossID = "Turdlings", Weight = 0.25},
            {BossID = "Steven", Weight = 0.25},
            {BossID = "Duke of Flies"},
            {BossID = "Little Horn"},
            {BossID = "Baby Plum"},
            {BossID = "Famine", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_AFTERBIRTH)

    StageAPI.SetFloorInfo({
        Prefix = "01x_downpour",
        Backdrop = BackdropType.DOWNPOUR,
        Bosses = poolWrap{
            {BossID = "Lil Blub"},
            {BossID = "Wormwood"},
            {BossID = "The Rainmaker"},
            {BossID = "Min-Min"}
        }
    }, settingStage, StageType.STAGETYPE_REPENTANCE)

    local downpourTwo = StageAPI.GetBaseFloorInfo(settingStage + 1, StageType.STAGETYPE_REPENTANCE, false)
    downpourTwo.HasMirrorLevel = true

    StageAPI.SetFloorInfo({
        Prefix = "02x_dross",
        Backdrop = BackdropType.DROSS,
        Bosses = poolWrap{
            {BossID = "Lil Blub"},
            {BossID = "Wormwood"},
            {BossID = "Clog"},
            {BossID = "Colostomia"},
            {BossID = "Turdlet"}
        }
    }, settingStage, StageType.STAGETYPE_REPENTANCE_B)

    local downpourTwo = StageAPI.GetBaseFloorInfo(settingStage + 1, StageType.STAGETYPE_REPENTANCE_B, false)
    downpourTwo.HasMirrorLevel = true

    settingStage = LevelStage.STAGE2_1
    StageAPI.SetFloorInfo({
        Prefix = "03_caves",
        Backdrop = BackdropType.CAVES,
        Bosses = poolWrap{
            {BossID = "Chub"},
            {BossID = "Gurdy"},
            {BossID = "Fistula"},
            {BossID = "Mega Maw"},
            {BossID = "Mega Fatty"},
            {BossID = "Chad", Weight = 0.25},
            {BossID = "Peep"},
            {BossID = "Gurdy Jr"},
            {BossID = "The Stain"},
            {BossID = "Rag Mega"},
            {BossID = "Big Horn"},
            {BossID = "Bumbino"},
            {BossID = "Pestilence", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_ORIGINAL)

    StageAPI.SetFloorInfo({
        Prefix = "04_catacombs",
        Backdrop = BackdropType.CATACOMBS,
        Bosses = poolWrap{
            {BossID = "The Hollow"},
            {BossID = "The Husk"},
            {BossID = "Dark One"},
            {BossID = "Polycephalus"},
            {BossID = "Carrion Queen"},
            {BossID = "The Wretched"},
            {BossID = "Peep"},
            {BossID = "Gurdy Jr"},
            {BossID = "The Forsaken"},
            {BossID = "The Frail"},
            {BossID = "Rag Mega"},
            {BossID = "Big Horn"},
            {BossID = "Bumbino"},
            {BossID = "Pestilence", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_WOTL)

    StageAPI.SetFloorInfo({
        Prefix = "14_drowned_caves",
        Backdrop = BackdropType.FLOODED_CAVES,
        Bosses = poolWrap{
            {BossID = "Chub"},
            {BossID = "Gurdy"},
            {BossID = "Fistula"},
            {BossID = "Mega Maw"},
            {BossID = "Mega Fatty"},
            {BossID = "Chad", Weight = 0.25},
            {BossID = "Peep"},
            {BossID = "Gurdy Jr"},
            {BossID = "The Stain"},
            {BossID = "The Forsaken"},
            {BossID = "The Frail"},
            {BossID = "Rag Mega"},
            {BossID = "Big Horn"},
            {BossID = "Bumbino"},
            {BossID = "Pestilence", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_AFTERBIRTH)

    StageAPI.SetFloorInfo({
        Prefix = "03x_mines",
        Backdrop = BackdropType.MINES,
        Bosses = poolWrap{
            {BossID = "Reap Creep"},
            {BossID = "Tuff Twins"},
            {BossID = "Hornfel"},
            {BossID = "Great Gideon"},
        }
    }, settingStage, StageType.STAGETYPE_REPENTANCE)

    StageAPI.SetFloorInfo({
        Prefix = "04x_ashpit",
        Backdrop = BackdropType.ASHPIT,
        Bosses = poolWrap{
            {BossID = "The Pile"},
            {BossID = "The Shell"},
            {BossID = "Singe"},
            {BossID = "Great Gideon"},
        }
    }, settingStage, StageType.STAGETYPE_REPENTANCE_B)

    settingStage = LevelStage.STAGE3_1
    StageAPI.SetFloorInfo({
        Prefix = "05_depths",
        Backdrop = BackdropType.DEPTHS,
        Bosses = poolWrap{
            {BossID = "The Cage"},
            {BossID = "Monstro 2"},
            {BossID = "The Gate"},
            {BossID = "Gish", Weight = 0.25},
            {BossID = "Loki"},
            {BossID = "Brownie"},
            {BossID = "Sisters Vis"},
            {BossID = "Reap Creep"},
            {BossID = "War", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_ORIGINAL)

    StageAPI.SetFloorInfo({
        Prefix = "06_necropolis",
        Backdrop = BackdropType.NECROPOLIS,
        Bosses = poolWrap{
            {BossID = "The Adversary"},
            {BossID = "The Bloat"},
            {BossID = "Mask of Infamy"},
            {BossID = "Loki"},
            {BossID = "Brownie"},
            {BossID = "Sisters Vis"},
            {BossID = "The Pile"},
            {BossID = "War", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_WOTL)

    StageAPI.SetFloorInfo({
        Prefix = "15_dank_depths",
        Backdrop = BackdropType.DANK_DEPTHS,
        Bosses = poolWrap{
            {BossID = "The Cage"},
            {BossID = "Monstro 2"},
            {BossID = "The Gate"},
            {BossID = "Gish", Weight = 0.25},
            {BossID = "Loki"},
            {BossID = "Brownie"},
            {BossID = "Sisters Vis"},
            {BossID = "Reap Creep"},
            {BossID = "War", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_AFTERBIRTH)

    StageAPI.SetFloorInfo({
        Prefix = "05x_mausoleum",
        Backdrop = BackdropType.MAUSOLEUM,
        Bosses = poolWrap{
            {BossID = "The Siren"},
            {BossID = "The Heretic"},
        }
    }, settingStage, StageType.STAGETYPE_REPENTANCE)

    StageAPI.SetFloorInfo({
        Prefix = "06x_gehenna",
        Backdrop = BackdropType.GEHENNA,
        Bosses = poolWrap{
            {BossID = "The Visage"},
            {BossID = "Horny Boys"},
        }
    }, settingStage, StageType.STAGETYPE_REPENTANCE_B)

    settingStage = LevelStage.STAGE4_1
    StageAPI.SetFloorInfo({
        Prefix = "07_womb",
        Backdrop = BackdropType.WOMB,
        Bosses = poolWrap{
            {BossID = "Scolex"},
            {BossID = "Mama Gurdy"},
            {BossID = "Lokii"},
            {BossID = "Mr. Fred"},
            {BossID = "Blastocyst"},
            {BossID = "The Matriarch", Weight = 0.25},
            {BossID = "Death", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Conquest", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_ORIGINAL)

    StageAPI.SetFloorInfo({
        Prefix = "07_womb",
        Backdrop = BackdropType.UTERO,
        Bosses = poolWrap{
            {BossID = "Teratoma"},
            {BossID = "Lokii"},
            {BossID = "Daddy Long Legs"},
            {BossID = "Triachnid"},
            {BossID = "The Bloat"},
            {BossID = "Death", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Conquest", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_WOTL)

    StageAPI.SetFloorInfo({
        Prefix = "16_scarred_womb",
        Backdrop = BackdropType.SCARRED_WOMB,
        Bosses = poolWrap{
            {BossID = "Scolex"},
            {BossID = "Mama Gurdy"},
            {BossID = "Lokii"},
            {BossID = "Mr. Fred"},
            {BossID = "Blastocyst"},
            {BossID = "Triachnid"},
            {BossID = "The Matriarch", Weight = 2},
            {BossID = "Death", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Conquest", Horseman = true, OnlyReplaceHorsemen = true},
            {BossID = "Headless Horseman", Horseman = true, OnlyReplaceHorsemen = true},
        }
    }, settingStage, StageType.STAGETYPE_AFTERBIRTH)

    StageAPI.SetFloorInfo({
        Prefix = "07x_corpse",
        Backdrop = BackdropType.CORPSE,
        Bosses = poolWrap{
            {BossID = "The Scourge"},
            {BossID = "Chimera"},
            {BossID = "Rotgut"},
        }
    }, settingStage, StageType.STAGETYPE_REPENTANCE)

    StageAPI.SetFloorInfo({
        Prefix = "07x_corpse",
        Backdrop = BackdropType.MORTIS
    }, settingStage, StageType.STAGETYPE_REPENTANCE_B)

    settingStage = LevelStage.STAGE5
    StageAPI.SetFloorInfo({
        Prefix = "09_sheol",
        Backdrop = BackdropType.SHEOL
    }, settingStage, StageType.STAGETYPE_ORIGINAL, false)

    StageAPI.SetFloorInfo({
        Prefix = "10_cathedral",
        Backdrop = BackdropType.CATHEDRAL
    }, settingStage, StageType.STAGETYPE_WOTL, false)

    settingStage = LevelStage.STAGE6
    StageAPI.SetFloorInfo({
        Prefix = "11_darkroom",
        Backdrop = BackdropType.DARKROOM
    }, settingStage, StageType.STAGETYPE_ORIGINAL, false)

    StageAPI.SetFloorInfo({
        Prefix = "12_chest",
        Backdrop = BackdropType.CHEST
    }, settingStage, StageType.STAGETYPE_WOTL, false)

    -- Special Floors
    StageAPI.SetFloorInfo({
        Prefix = "17_blue_womb",
        Backdrop = BackdropType.BLUE_WOMB
    }, LevelStage.STAGE4_3, true, false)

    StageAPI.SetFloorInfo({
        Prefix = "19_void",
        Backdrop = BackdropType.NUM_BACKDROPS
    }, LevelStage.STAGE7, true, false)

    StageAPI.SetFloorInfo({
        Prefix = "0ex_dogma",
        Backdrop = BackdropType.ISAACS_BEDROOM
    }, LevelStage.STAGE8, true, false)

    -- Greed Floors
    StageAPI.SetFloorInfo({
        Prefix = "09_sheol",
        Backdrop = BackdropType.SHEOL
    }, LevelStage.STAGE5_GREED, true, true)

    StageAPI.SetFloorInfo({
        Prefix = "bossspot_18_shop",
        Backdrop = BackdropType.SHOP
    }, LevelStage.STAGE6_GREED, true, true)

    StageAPI.SetFloorInfo({
        Prefix = "bossspot_18_shop",
        Backdrop = BackdropType.SHOP
    }, LevelStage.STAGE7_GREED, true, true)
end
