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
