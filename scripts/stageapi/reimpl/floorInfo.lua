local shared = require("scripts.stageapi.shared")

-- Base Floor Info
local function poolWrap(pool)
    return {Pool = pool}
end

local settingStage = LevelStage.STAGE1_1
StageAPI.SetFloorInfo({
    Prefix = "01_basement",
    VsBgColor = Color(26/255, 14/255, 12/255, 1, 0, 0, 0),
    VsDirtColor = Color(201/255, 114/255, 96/255, 1, 0, 0, 0),
    Backdrop = BackdropType.BASEMENT,
    RoomGfx = StageAPI.BaseRoomGfx.Basement,
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
    VsBgColor = Color(26/255, 17/255, 13/255, 1, 0, 0, 0),
    VsDirtColor = Color(229/255, 157/255, 111/255, 1, 0, 0, 0),
    Backdrop = BackdropType.CELLAR,
    RoomGfx = StageAPI.BaseRoomGfx.Cellar,
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
    VsBgColor = Color(28/255, 12/255, 10/255, 1, 0, 0, 0),
    VsDirtColor = Color(252/255, 108/255, 90/255, 1, 0, 0, 0),
    Backdrop = BackdropType.BURNT_BASEMENT,
    RoomGfx = StageAPI.BaseRoomGfx.BurningBasement,
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
    VsBgColor = Color(29/255, 30/255, 32/255, 1, 0, 0, 0),
    VsDirtColor = Color(149/255, 157/255, 167/255, 1, 0, 0, 0),
    Backdrop = BackdropType.DOWNPOUR,
    RoomGfx = StageAPI.BaseRoomGfx.Downpour,
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
    VsBgColor = Color(35/255, 35/255, 29/255, 1, 0, 0, 0),
    VsDirtColor = Color(179/255, 179/255, 143/255, 1, 0, 0, 0),
    Backdrop = BackdropType.DROSS,
    RoomGfx = StageAPI.BaseRoomGfx.Dross,
    Bosses = poolWrap{
        {BossID = "Lil Blub"},
        {BossID = "Wormwood"},
        {BossID = "Clog"},
        {BossID = "Colostomia"},
        {BossID = "Turdlet"}
    }
}, settingStage, StageType.STAGETYPE_REPENTANCE_B)

local drossTwo = StageAPI.GetBaseFloorInfo(settingStage + 1, StageType.STAGETYPE_REPENTANCE_B, false)
drossTwo.HasMirrorLevel = true

settingStage = LevelStage.STAGE2_1
StageAPI.SetFloorInfo({
    Prefix = "03_caves",
    VsBgColor = Color(18/255, 13/255, 8/255, 1, 0, 0, 0),
    VsDirtColor = Color(167/255, 111/255, 75/255, 1, 0, 0, 0),
    Backdrop = BackdropType.CAVES,
    RoomGfx = StageAPI.BaseRoomGfx.Caves,
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
    VsBgColor = Color(15/255, 10/255, 8/255, 1, 0, 0, 0),
    VsDirtColor = Color(135/255, 90/255, 80/255, 1, 0, 0, 0),
    Backdrop = BackdropType.CATACOMBS,
    RoomGfx = StageAPI.BaseRoomGfx.Catacombs,
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
    VsBgColor = Color(21/255, 28/255, 35/255, 1, 0, 0, 0),
    VsDirtColor = Color(111/255, 147/255, 180/255, 1, 0, 0, 0),
    Backdrop = BackdropType.FLOODED_CAVES,
    RoomGfx = StageAPI.BaseRoomGfx.FloodedCaves,
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
    VsBgColor = Color(17/255, 15/255, 12/255, 1, 0, 0, 0),
    VsDirtColor = Color(93/255, 85/255, 72/255, 1, 0, 0, 0),
    Backdrop = BackdropType.MINES,
    RoomGfx = StageAPI.BaseRoomGfx.Mines,
    Bosses = poolWrap{
        {BossID = "Reap Creep"},
        {BossID = "Tuff Twins"},
        {BossID = "Hornfel"},
        {BossID = "Great Gideon"},
    }
}, settingStage, StageType.STAGETYPE_REPENTANCE)

StageAPI.SetFloorInfo({
    Prefix = "04x_ashpit",
    VsBgColor = Color(12/255, 10/255, 10/255, 1, 0, 0, 0),
    VsDirtColor = Color(106/255, 102/255, 94/255, 1, 0, 0, 0),
    Backdrop = BackdropType.ASHPIT,
    RoomGfx = StageAPI.BaseRoomGfx.Ashpit,
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
    VsBgColor = Color(8/255, 8/255, 8/255, 1, 0, 0, 0),
    VsDirtColor = Color(70/255, 70/255, 72/255, 1, 0, 0, 0),
    Backdrop = BackdropType.DEPTHS,
    RoomGfx = StageAPI.BaseRoomGfx.Depths,
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
    VsBgColor = Color(10/255, 6/255, 6/255, 1, 0, 0, 0),
    VsDirtColor = Color(88/255, 67/255, 54/255, 1, 0, 0, 0),
    Backdrop = BackdropType.NECROPOLIS,
    RoomGfx = StageAPI.BaseRoomGfx.Necropolis,
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
    VsBgColor = Color(8/255, 8/255, 8/255, 1, 0, 0, 0),
    VsDirtColor = Color(70/255, 70/255, 72/255, 1, 0, 0, 0),
    Backdrop = BackdropType.DANK_DEPTHS,
    RoomGfx = StageAPI.BaseRoomGfx.DankDepths,
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
    VsBgColor = Color(14/255, 10/255, 14/255, 1, 0, 0, 0),
    VsDirtColor = Color(70/255, 59/255, 72/255, 1, 0, 0, 0),
    Backdrop = BackdropType.MAUSOLEUM,
    RoomGfx = StageAPI.BaseRoomGfx.Mausoleum,
    Bosses = poolWrap{
        {BossID = "The Siren"},
        {BossID = "The Heretic"},
    }
}, settingStage, StageType.STAGETYPE_REPENTANCE)

StageAPI.SetFloorInfo({
    Prefix = "06x_gehenna",
    VsBgColor = Color(15/255, 4/255, 4/255, 1, 0, 0, 0),
    VsDirtColor = Color(59/255, 41/255, 41/255, 1, 0, 0, 0),
    Backdrop = BackdropType.GEHENNA,
    RoomGfx = StageAPI.BaseRoomGfx.Gehenna,
    Bosses = poolWrap{
        {BossID = "The Visage"},
        {BossID = "Horny Boys"},
    }
}, settingStage, StageType.STAGETYPE_REPENTANCE_B)

for stageType = StageType.STAGETYPE_ORIGINAL, StageType.STAGETYPE_REPENTANCE_B do
    if stageType ~= StageType.STAGETYPE_GREEDMODE then
        local floorInfo = StageAPI.GetBaseFloorInfo(LevelStage.STAGE3_2, stageType, false)
        floorInfo.Bosses = poolWrap{
            {BossID = "Mom"}
        }
    end
end

settingStage = LevelStage.STAGE4_1
StageAPI.SetFloorInfo({
    Prefix = "07_womb",
    VsBgColor = Color(27/255, 3/255, 3/255, 1, 0, 0, 0),
    VsDirtColor = Color(241/255, 28/255, 28/255, 1, 0, 0, 0),
    Backdrop = BackdropType.WOMB,
    RoomGfx = StageAPI.BaseRoomGfx.Womb,
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
    Prefix = "08_utero",
    VsBgColor = Color(22/255, 6/255, 5/255, 1, 0, 0, 0),
    VsDirtColor = Color(199/255, 60/255, 48/255, 1, 0, 0, 0),
    Backdrop = BackdropType.UTERO,
    RoomGfx = StageAPI.BaseRoomGfx.Utero,
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
    VsBgColor = Color(42/255, 19/255, 10/255, 1, 0, 0, 0),
    VsDirtColor = Color(247/255, 152/255, 88/255, 1, 0, 0, 0),
    Backdrop = BackdropType.SCARRED_WOMB,
    RoomGfx = StageAPI.BaseRoomGfx.ScarredWomb,
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

for stageType = StageType.STAGETYPE_ORIGINAL, StageType.STAGETYPE_AFTERBIRTH do
    local floorInfo = StageAPI.GetBaseFloorInfo(LevelStage.STAGE4_2, stageType, false)
    floorInfo.Bosses = poolWrap{
        {BossID = "Mom's Heart", OnlyReplaceSubtype = 8},
        {BossID = "It Lives", OnlyReplaceSubtype = 25}
    }
end

StageAPI.SetFloorInfo({
    Prefix = "07x_corpse",
    VsBgColor = Color(13/255, 14/255, 12/255, 1, 0, 0, 0),
    VsDirtColor = Color(124/255, 134/255, 111/255, 1, 0, 0, 0),
    Backdrop = BackdropType.CORPSE,
    RoomGfx = StageAPI.BaseRoomGfx.Corpse,
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

for stageType = StageType.STAGETYPE_REPENTANCE, StageType.STAGETYPE_REPENTANCE_B do
    local floorInfo = StageAPI.GetBaseFloorInfo(LevelStage.STAGE4_2, stageType, false)
    floorInfo.Bosses = poolWrap{
        {BossID = "Mother"},
    }
end

settingStage = LevelStage.STAGE5
StageAPI.SetFloorInfo({
    Prefix = "09_sheol",
    VsBgColor = Color(6/255, 6/255, 6/255, 1, 0, 0, 0),
    VsDirtColor = Color(60/255, 54/255, 54/255, 1, 0, 0, 0),
    Backdrop = BackdropType.SHEOL,
    RoomGfx = StageAPI.BaseRoomGfx.Sheol,
    Bosses = poolWrap{
        {BossID = "Satan"}
    }
}, settingStage, StageType.STAGETYPE_ORIGINAL, false)

StageAPI.SetFloorInfo({
    Prefix = "10_cathedral",
    VsBgColor = Color(6/255, 13/255, 17/255, 1, 0, 0, 0),
    VsDirtColor = Color(44/255, 100/255, 111/255, 1, 0, 0, 0),
    Backdrop = BackdropType.CATHEDRAL,
    RoomGfx = StageAPI.BaseRoomGfx.Cathedral,
    Bosses = poolWrap{
        {BossID = "Isaac"}
    }
}, settingStage, StageType.STAGETYPE_WOTL, false)

settingStage = LevelStage.STAGE6
StageAPI.SetFloorInfo({
    Prefix = "11_darkroom",
    VsBgColor = Color(9/255, 4/255, 3/255, 1, 0, 0, 0),
    VsDirtColor = Color(80/255, 38/255, 20/255, 1, 0, 0, 0),
    Backdrop = BackdropType.DARKROOM,
    RoomGfx = StageAPI.BaseRoomGfx.DarkRoom,
    Bosses = poolWrap{
        {BossID = "The Lamb"}
    }
}, settingStage, StageType.STAGETYPE_ORIGINAL, false)

StageAPI.SetFloorInfo({
    Prefix = "12_chest",
    VsBgColor = Color(15/255, 9/255, 6/255, 1, 0, 0, 0),
    VsDirtColor = Color(175/255, 108/255, 72/255, 1, 0, 0, 0),
    Backdrop = BackdropType.CHEST,
    RoomGfx = StageAPI.BaseRoomGfx.Chest,
    Bosses = poolWrap{
        {BossID = "Blue Baby"}
    }
}, settingStage, StageType.STAGETYPE_WOTL, false)

-- Special Floors
StageAPI.SetFloorInfo({
    Prefix = "17_blue_womb",
    VsBgColor = Color(26/255, 32/255, 40/255, 1, 0, 0, 0),
    VsDirtColor = Color(157/255, 209/255, 255/255, 1, 0, 0, 0),
    Backdrop = BackdropType.BLUE_WOMB,
    RoomGfx = StageAPI.BaseRoomGfx.BlueWomb,
    Bosses = poolWrap{
        {BossID = "Hush"}
    }
}, LevelStage.STAGE4_3, true, false)

StageAPI.SetFloorInfo({
    Prefix = "19_void",
    VsBgColor = Color(0, 0, 0, 1, 0, 0, 0),
    VsDirtColor = Color(70/255, 5/255, 5/255, 1, 0, 0, 0),
    Backdrop = BackdropType.NUM_BACKDROPS
}, LevelStage.STAGE7, true, false)

StageAPI.SetFloorInfo({
    Prefix = "0ex_dogma",
    Backdrop = BackdropType.ISAACS_BEDROOM,
    RoomGfx = StageAPI.BaseRoomGfx.Isaacs
}, LevelStage.STAGE8, true, false)

-- Greed Floors
StageAPI.SetFloorInfo({
    Prefix = "09_sheol",
    VsBgColor = Color(6/255, 6/255, 6/255, 1, 0, 0, 0),
    VsDirtColor = Color(60/255, 54/255, 54/255, 1, 0, 0, 0),
    Backdrop = BackdropType.SHEOL,
    RoomGfx = StageAPI.BaseRoomGfx.Sheol
}, LevelStage.STAGE5_GREED, true, true)

StageAPI.SetFloorInfo({
    Prefix = "bossspot_18_shop",
    VsBgColor = Color(26/255, 17/255, 13/255, 1, 0, 0, 0),
    VsDirtColor = Color(229/255, 157/255, 111/255, 1, 0, 0, 0),
    Backdrop = BackdropType.SHOP,
    RoomGfx = StageAPI.BaseRoomGfx.Shop
}, LevelStage.STAGE6_GREED, true, true)

StageAPI.SetFloorInfo({
    Prefix = "bossspot_18_shop",
    VsBgColor = Color(26/255, 17/255, 13/255, 1, 0, 0, 0),
    VsDirtColor = Color(229/255, 157/255, 111/255, 1, 0, 0, 0),
    Backdrop = BackdropType.SHOP,
    RoomGfx = StageAPI.BaseRoomGfx.Shop
}, LevelStage.STAGE7_GREED, true, true)
