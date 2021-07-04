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

do -- Base Floor Info
    local settingStage = LevelStage.STAGE1_1
    StageAPI.SetFloorInfo({
        Prefix = "01_basement",
        Backdrop = BackdropType.BASEMENT
    }, settingStage, StageType.STAGETYPE_ORIGINAL)

    StageAPI.SetFloorInfo({
        Prefix = "02_cellar",
        Backdrop = BackdropType.CELLAR
    }, settingStage, StageType.STAGETYPE_WOTL)

    StageAPI.SetFloorInfo({
        Prefix = "13_burning_basement",
        Backdrop = BackdropType.BURNT_BASEMENT,
        FloorTextColor = Color(0.5,0.5,0.5,1,0,0,0)
    }, settingStage, StageType.STAGETYPE_AFTERBIRTH)

    StageAPI.SetFloorInfo({
        Prefix = "01x_downpour",
        Backdrop = BackdropType.DOWNPOUR
    }, settingStage, StageType.STAGETYPE_REPENTANCE)

    StageAPI.SetFloorInfo({
        Prefix = "02x_dross",
        Backdrop = BackdropType.DROSS
    }, settingStage, StageType.STAGETYPE_REPENTANCE_B)

    settingStage = LevelStage.STAGE2_1
    StageAPI.SetFloorInfo({
        Prefix = "03_caves",
        Backdrop = BackdropType.CAVES
    }, settingStage, StageType.STAGETYPE_ORIGINAL)

    StageAPI.SetFloorInfo({
        Prefix = "04_catacombs",
        Backdrop = BackdropType.CATACOMBS
    }, settingStage, StageType.STAGETYPE_WOTL)

    StageAPI.SetFloorInfo({
        Prefix = "14_drowned_caves",
        Backdrop = BackdropType.FLOODED_CAVES
    }, settingStage, StageType.STAGETYPE_AFTERBIRTH)

    StageAPI.SetFloorInfo({
        Prefix = "03x_mines",
        Backdrop = BackdropType.MINES
    }, settingStage, StageType.STAGETYPE_REPENTANCE)

    StageAPI.SetFloorInfo({
        Prefix = "04x_ashpit",
        Backdrop = BackdropType.ASHPIT
    }, settingStage, StageType.STAGETYPE_REPENTANCE_B)

    settingStage = LevelStage.STAGE3_1
    StageAPI.SetFloorInfo({
        Prefix = "05_depths",
        Backdrop = BackdropType.DEPTHS
    }, settingStage, StageType.STAGETYPE_ORIGINAL)

    StageAPI.SetFloorInfo({
        Prefix = "06_necropolis",
        Backdrop = BackdropType.NECROPOLIS
    }, settingStage, StageType.STAGETYPE_WOTL)

    StageAPI.SetFloorInfo({
        Prefix = "15_dank_depths",
        Backdrop = BackdropType.DANK_DEPTHS
    }, settingStage, StageType.STAGETYPE_AFTERBIRTH)

    StageAPI.SetFloorInfo({
        Prefix = "05x_mausoleum",
        Backdrop = BackdropType.MAUSOLEUM
    }, settingStage, StageType.STAGETYPE_REPENTANCE)

    StageAPI.SetFloorInfo({
        Prefix = "06x_gehenna",
        Backdrop = BackdropType.GEHENNA
    }, settingStage, StageType.STAGETYPE_REPENTANCE_B)

    settingStage = LevelStage.STAGE4_1
    StageAPI.SetFloorInfo({
        Prefix = "07_womb",
        Backdrop = BackdropType.WOMB
    }, settingStage, StageType.STAGETYPE_ORIGINAL)

    StageAPI.SetFloorInfo({
        Prefix = "07_womb",
        Backdrop = BackdropType.UTERO
    }, settingStage, StageType.STAGETYPE_WOTL)

    StageAPI.SetFloorInfo({
        Prefix = "16_scarred_womb",
        Backdrop = BackdropType.SCARRED_WOMB
    }, settingStage, StageType.STAGETYPE_AFTERBIRTH)

    StageAPI.SetFloorInfo({
        Prefix = "07x_corpse",
        Backdrop = BackdropType.CORPSE
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
