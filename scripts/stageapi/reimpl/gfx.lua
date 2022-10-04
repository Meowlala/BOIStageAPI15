local shared = require("scripts.stageapi.shared")

-- Reimplementation of most base game GridGfx, Backdrops, RoomGfx

-- Base Game GridGfx
StageAPI.BaseGridGfx = {}

StageAPI.BaseGridGfx.Basement = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Basement:SetRocks("gfx/grid/rocks_basement.png")
StageAPI.BaseGridGfx.Basement:SetDecorations("gfx/grid/props_01_basement.png", "gfx/grid/props_01_basement.anm2", 43)
StageAPI.BaseGridGfx.Basement:SetDoorSprites{
    Default = {
        [RoomType.ROOM_DEFAULT] = "gfx/grid/door_01_normaldoor.png",
    },
    Secret = "gfx/grid/door_08_holeinwall.png"
}
StageAPI.BaseGridGfx.Basement:SetDoorSpawns(StageAPI.BaseDoorSpawnList)

StageAPI.BaseGridGfx.Cellar = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Cellar:SetRocks("gfx/grid/rocks_cellar.png")
StageAPI.BaseGridGfx.Cellar:SetDecorations("gfx/grid/props_01_basement.png", "gfx/grid/props_01_basement.anm2", 43)
StageAPI.BaseGridGfx.Cellar:SetDoorSprites{
    Default = {
        [RoomType.ROOM_DEFAULT] = "gfx/grid/door_12_cellardoor.png",
    },
    Secret = "gfx/grid/door_08_holeinwall.png"
}
StageAPI.BaseGridGfx.Cellar:SetDoorSpawns(StageAPI.BaseDoorSpawnList)

StageAPI.BaseGridGfx.BurningBasement = StageAPI.GridGfx()
StageAPI.BaseGridGfx.BurningBasement:SetRocks("gfx/grid/rocks_burningbasement.png")
StageAPI.BaseGridGfx.BurningBasement:SetDecorations("gfx/grid/props_01_basement.png", "gfx/grid/props_01_basement.anm2", 43)
StageAPI.BaseGridGfx.BurningBasement:SetDoorSprites{
    Default = {
        [RoomType.ROOM_DEFAULT] = "gfx/grid/door_01_burningbasement.png",
    },
    Secret = "gfx/grid/door_08_holeinwall.png"
}
StageAPI.BaseGridGfx.BurningBasement:SetDoorSpawns(StageAPI.BaseDoorSpawnList)

StageAPI.BaseGridGfx.Caves = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Caves:SetRocks("gfx/grid/rocks_caves.png")
StageAPI.BaseGridGfx.Caves:SetPits("gfx/grid/grid_pit.png", "gfx/grid/grid_pit_water.png")
StageAPI.BaseGridGfx.Caves:SetBridges("gfx/grid/grid_bridge.png")
StageAPI.BaseGridGfx.Caves:SetDecorations("gfx/grid/props_03_caves.png")
StageAPI.BaseGridGfx.Caves:SetDoorSprites{
    Default = {
        [RoomType.ROOM_DEFAULT] = "gfx/grid/door_01_normaldoor.png",
    },
    Secret = "gfx/grid/door_08_holeinwall_caves.png"
}
StageAPI.BaseGridGfx.Caves:SetDoorSpawns(StageAPI.BaseDoorSpawnList)

StageAPI.BaseGridGfx.Secret = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Secret:SetRocks("gfx/grid/rocks_secretroom.png")
StageAPI.BaseGridGfx.Secret:SetPits("gfx/grid/grid_pit.png", "gfx/grid/grid_pit_water.png")
StageAPI.BaseGridGfx.Secret:SetBridges("gfx/grid/grid_bridge.png")
StageAPI.BaseGridGfx.Secret:SetDecorations("gfx/grid/props_03_caves.png")
StageAPI.BaseGridGfx.Secret:SetDoorSprites{
    Default = "gfx/grid/door_08_holeinwall.png",
    Secret = "gfx/grid/door_08_holeinwall.png"
}
StageAPI.BaseGridGfx.Secret:SetDoorSpawns(StageAPI.BaseDoorSpawnList)

StageAPI.BaseGridGfx.Catacombs = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Catacombs:SetRocks("gfx/grid/rocks_catacombs.png")
StageAPI.BaseGridGfx.Catacombs:SetPits("gfx/grid/grid_pit_catacombs.png", "gfx/grid/grid_pit_water_catacombs.png")
StageAPI.BaseGridGfx.Catacombs:SetBridges("stageapi/floors/catacombs/grid_bridge_catacombs.png")
StageAPI.BaseGridGfx.Catacombs:SetDecorations("gfx/grid/props_03_caves.png")
StageAPI.BaseGridGfx.Catacombs:SetDoorSprites{
    Default = {
        [RoomType.ROOM_DEFAULT] = "gfx/grid/door_01_normaldoor.png",
    },
    Secret = "gfx/grid/door_08_holeinwall.png"
}
StageAPI.BaseGridGfx.Catacombs:SetDoorSpawns(StageAPI.BaseDoorSpawnList)

StageAPI.BaseGridGfx.FloodedCaves = StageAPI.GridGfx()
StageAPI.BaseGridGfx.FloodedCaves:SetRocks("gfx/grid/rocks_drownedcaves.png")
StageAPI.BaseGridGfx.FloodedCaves:SetPits("gfx/grid/grid_pit_water_drownedcaves.png", "gfx/grid/grid_pit_water_drownedcaves.png")
StageAPI.BaseGridGfx.FloodedCaves:SetBridges("gfx/grid/grid_bridge_drownedcaves.png")
StageAPI.BaseGridGfx.FloodedCaves:SetDecorations("gfx/grid/props_03_caves.png")
StageAPI.BaseGridGfx.FloodedCaves:SetDoorSprites{
    Default = {
        [RoomType.ROOM_DEFAULT] = "gfx/grid/door_27_drownedcaves.png",
    },
    Secret = "gfx/grid/door_08_holeinwall_cathedral.png"
}
StageAPI.BaseGridGfx.FloodedCaves:SetDoorSpawns(StageAPI.BaseDoorSpawnList)

StageAPI.BaseGridGfx.Depths = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Depths:SetRocks("gfx/grid/rocks_depths.png")
StageAPI.BaseGridGfx.Depths:SetPits("gfx/grid/grid_pit_depths.png")
StageAPI.BaseGridGfx.Depths:SetBridges("gfx/grid/grid_bridge_depths.png")
StageAPI.BaseGridGfx.Depths:SetDecorations("gfx/grid/props_05_depths.png", "gfx/grid/props_05_depths.anm2", 43)

StageAPI.BaseGridGfx.Necropolis = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Necropolis:SetRocks("gfx/grid/rocks_depths.png")
StageAPI.BaseGridGfx.Necropolis:SetPits("gfx/grid/grid_pit_necropolis.png")
StageAPI.BaseGridGfx.Necropolis:SetBridges("stageapi/floors/necropolis/grid_bridge_necropolis.png")
StageAPI.BaseGridGfx.Necropolis:SetDecorations("gfx/grid/props_05_depths.png", "gfx/grid/props_05_depths.anm2", 43)

StageAPI.BaseGridGfx.DankDepths = StageAPI.GridGfx()
StageAPI.BaseGridGfx.DankDepths:SetRocks("gfx/grid/rocks_depths.png")
StageAPI.BaseGridGfx.DankDepths:SetPits("gfx/grid/grid_pit_dankdepths.png","gfx/grid/grid_pit_water_dankdepths.png")
StageAPI.BaseGridGfx.DankDepths:SetBridges("gfx/grid/grid_bridge_dankdepths.png")
StageAPI.BaseGridGfx.DankDepths:SetDecorations("gfx/grid/props_05_depths.png", "gfx/grid/props_05_depths.anm2", 43)

StageAPI.BaseGridGfx.Womb = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Womb:SetRocks("gfx/grid/rocks_womb.png")
StageAPI.BaseGridGfx.Womb:SetPits("gfx/grid/grid_pit_womb.png", {
    { File = "gfx/grid/grid_pit_blood_womb.png" },
    { File = "gfx/grid/grid_pit_acid_womb.png" },
})
StageAPI.BaseGridGfx.Womb:SetBridges("stageapi/floors/utero/grid_bridge_womb.png")
StageAPI.BaseGridGfx.Womb:SetDecorations("gfx/grid/props_07_the womb.png", "gfx/grid/props_07_the womb.anm2", 43)

StageAPI.BaseGridGfx.Utero = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Utero:SetRocks("gfx/grid/rocks_womb.png")
StageAPI.BaseGridGfx.Utero:SetPits("gfx/grid/grid_pit_womb.png", {
    { File = "gfx/grid/grid_pit_blood_womb.png" },
    { File = "gfx/grid/grid_pit_acid_womb.png" },
})
StageAPI.BaseGridGfx.Utero:SetBridges("stageapi/floors/utero/grid_bridge_womb.png")
StageAPI.BaseGridGfx.Utero:SetDecorations("gfx/grid/props_07_the womb.png", "gfx/grid/props_07_the womb.anm2", 43)

StageAPI.BaseGridGfx.ScarredWomb = StageAPI.GridGfx()
StageAPI.BaseGridGfx.ScarredWomb:SetRocks("gfx/grid/rocks_scarredwomb.png")
StageAPI.BaseGridGfx.ScarredWomb:SetPits("gfx/grid/grid_pit_blood_scarredwomb.png")
StageAPI.BaseGridGfx.ScarredWomb:SetBridges("gfx/grid/grid_bridge_scarredwomb.png")
StageAPI.BaseGridGfx.ScarredWomb:SetDecorations("gfx/grid/props_07_the womb.png", "gfx/grid/props_07_the womb.anm2", 43)

StageAPI.BaseGridGfx.BlueWomb = StageAPI.GridGfx()
StageAPI.BaseGridGfx.BlueWomb:SetRocks("gfx/grid/rocks_bluewomb.png")
StageAPI.BaseGridGfx.BlueWomb:SetDecorations("gfx/grid/props_07_the womb_blue.png", "gfx/grid/props_07_the womb.anm2", 43)

StageAPI.BaseGridGfx.Cathedral = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Cathedral:SetRocks("gfx/grid/rocks_cathedral.png")
StageAPI.BaseGridGfx.Cathedral:SetPits("gfx/grid/grid_pit_cathedral.png")
StageAPI.BaseGridGfx.Cathedral:SetBridges("gfx/grid/grid_bridge_cathedral.png")
StageAPI.BaseGridGfx.Cathedral:SetDecorations("gfx/grid/props_10_cathedral.png", "gfx/grid/props_10_cathedral.anm2", 43)

StageAPI.BaseGridGfx.Sheol = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Sheol:SetRocks("gfx/grid/rocks_sheol.png")
StageAPI.BaseGridGfx.Sheol:SetPits("gfx/grid/grid_pit_depths.png")
StageAPI.BaseGridGfx.Sheol:SetBridges("gfx/grid/grid_bridge_depths.png")
StageAPI.BaseGridGfx.Sheol:SetDecorations("gfx/grid/props_09_sheol.png", "gfx/grid/props_09_sheol.anm2", 43)

StageAPI.BaseGridGfx.Chest = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Chest:SetDecorations("gfx/grid/props_11_chest.png", "gfx/grid/props_11_the chest.anm2", 43)

StageAPI.BaseGridGfx.DarkRoom = StageAPI.GridGfx()
StageAPI.BaseGridGfx.DarkRoom:SetPits("gfx/grid/grid_pit_darkroom.png")
StageAPI.BaseGridGfx.DarkRoom:SetDecorations("stageapi/none.png")

StageAPI.BaseGridGfx.Downpour = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Downpour:SetRocks("gfx/grid/rocks_downpour.png")
StageAPI.BaseGridGfx.Downpour:SetPits("gfx/grid/grid_pit_downpour.png")
StageAPI.BaseGridGfx.Downpour:SetDecorations("gfx/grid/props_01x_downpour.png", "gfx/grid/props_01x_downpour.anm2", 20)

StageAPI.BaseGridGfx.Dross = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Dross:SetRocks("gfx/grid/rocks_dross.png")
StageAPI.BaseGridGfx.Dross:SetPits("gfx/grid/grid_pit_dross.png")
StageAPI.BaseGridGfx.Dross:SetDecorations("gfx/grid/props_02x_dross.png", "gfx/grid/props_02x_dross.anm2", 30)

StageAPI.BaseGridGfx.Mines = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Mines:SetRocks("gfx/grid/rocks_secretroom.png")
StageAPI.BaseGridGfx.Mines:SetPits("gfx/grid/grid_pit_mines.png")
StageAPI.BaseGridGfx.Mines:SetDecorations("gfx/grid/props_03x_mines.png", "gfx/grid/props_03x_mines.anm2", 42)

StageAPI.BaseGridGfx.Ashpit = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Ashpit:SetRocks("gfx/grid/rocks_ashpit.png")
StageAPI.BaseGridGfx.Ashpit:SetPits("gfx/grid/grid_pit_ashpit.png", "gfx/grid/grid_pit_ashpit_ash.png")
StageAPI.BaseGridGfx.Ashpit:SetDecorations("gfx/grid/props_03x_mines.png", "gfx/grid/props_03x_mines.anm2", 42)

StageAPI.BaseGridGfx.Mausoleum = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Mausoleum:SetRocks("gfx/grid/rocks_mausoleum.png")
StageAPI.BaseGridGfx.Mausoleum:SetPits("gfx/grid/grid_pit_mausoleum.png")
StageAPI.BaseGridGfx.Mausoleum:SetDecorations("gfx/grid/props_03x_mines.png", "gfx/grid/props_03x_mines.anm2", 42)

StageAPI.BaseGridGfx.Gehenna = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Gehenna:SetRocks("gfx/grid/rocks_gehenna.png")
StageAPI.BaseGridGfx.Gehenna:SetPits("gfx/grid/grid_pit_gehenna.png")
StageAPI.BaseGridGfx.Gehenna:SetDecorations("gfx/grid/props_03x_mines.png", "gfx/grid/props_03x_mines.anm2", 42)

StageAPI.BaseGridGfx.Corpse = StageAPI.GridGfx()
StageAPI.BaseGridGfx.Corpse:SetRocks("gfx/grid/rocks_corpse.png")
StageAPI.BaseGridGfx.Corpse:SetPits("gfx/grid/grid_pit_corpse.png")
StageAPI.BaseGridGfx.Corpse:SetDecorations("gfx/grid/props_07_the corpse.png", "gfx/grid/props_07_the corpse.anm2", 42)

StageAPI.BaseRoomGfx = {
    Basement = StageAPI.RoomGfx(BackdropType.BASEMENT, StageAPI.BaseGridGfx.Basement, "_default"),
    Cellar = StageAPI.RoomGfx(BackdropType.CELLAR, StageAPI.BaseGridGfx.Cellar, "_default"),
    BurningBasement = StageAPI.RoomGfx(BackdropType.BURNT_BASEMENT, StageAPI.BaseGridGfx.BurningBasement, "_default"),
    Caves = StageAPI.RoomGfx(BackdropType.CAVES, StageAPI.BaseGridGfx.Caves, "_default"),
    Catacombs = StageAPI.RoomGfx(BackdropType.CATACOMBS, StageAPI.BaseGridGfx.Catacombs, "_default"),
    FloodedCaves = StageAPI.RoomGfx(BackdropType.FLOODED_CAVES, StageAPI.BaseGridGfx.FloodedCaves, "_default"),
    Depths = StageAPI.RoomGfx(BackdropType.DEPTHS, StageAPI.BaseGridGfx.Depths, "_default"),
    Necropolis = StageAPI.RoomGfx(BackdropType.NECROPOLIS, StageAPI.BaseGridGfx.Necropolis, "_default"),
    DankDepths = StageAPI.RoomGfx(BackdropType.DANK_DEPTHS, StageAPI.BaseGridGfx.DankDepths, "_default"),
    Womb = StageAPI.RoomGfx(BackdropType.WOMB, StageAPI.BaseGridGfx.Womb, "_default"),
    Utero = StageAPI.RoomGfx(BackdropType.UTERO, StageAPI.BaseGridGfx.Utero, "_default"),
    ScarredWomb = StageAPI.RoomGfx(BackdropType.SCARRED_WOMB, StageAPI.BaseGridGfx.ScarredWomb, "_default"),
    BlueWomb = StageAPI.RoomGfx(BackdropType.BLUE_WOMB, StageAPI.BaseGridGfx.BlueWomb, "_default"),
    Sheol = StageAPI.RoomGfx(BackdropType.SHEOL, StageAPI.BaseGridGfx.Sheol, "_default"),
    Cathedral = StageAPI.RoomGfx(BackdropType.CATHEDRAL, StageAPI.BaseGridGfx.Cathedral, "_default"),
    DarkRoom = StageAPI.RoomGfx(BackdropType.DARKROOM, StageAPI.BaseGridGfx.DarkRoom, "_default"),
    Chest = StageAPI.RoomGfx(BackdropType.CHEST, StageAPI.BaseGridGfx.Chest, "_default"),

    Downpour = StageAPI.RoomGfx(BackdropType.DOWNPOUR, StageAPI.BaseGridGfx.Downpour, "_default"),
    Dross = StageAPI.RoomGfx(BackdropType.DROSS, StageAPI.BaseGridGfx.Dross, "_default"),
    Mines = StageAPI.RoomGfx(BackdropType.MINES, StageAPI.BaseGridGfx.Mines, "_default"),
    Ashpit = StageAPI.RoomGfx(BackdropType.ASHPIT, StageAPI.BaseGridGfx.Ashpit, "_default"),
    Mausoleum = StageAPI.RoomGfx(BackdropType.MAUSOLEUM, StageAPI.BaseGridGfx.Mausoleum, "_default"),
    Gehenna = StageAPI.RoomGfx(BackdropType.GEHENNA, StageAPI.BaseGridGfx.Gehenna, "_default"),
    Corpse = StageAPI.RoomGfx(BackdropType.CORPSE, StageAPI.BaseGridGfx.Corpse, "_default"),

    -- Special Rooms
    Shop = StageAPI.RoomGfx(BackdropType.SHOP, StageAPI.BaseGridGfx.Basement, "_default"),
    Library = StageAPI.RoomGfx(BackdropType.LIBRARY, StageAPI.BaseGridGfx.Basement, "_default"),
    Secret = StageAPI.RoomGfx(BackdropType.SECRET, StageAPI.BaseGridGfx.Secret, "_default"),
    Barren = StageAPI.RoomGfx(BackdropType.BARREN, StageAPI.BaseGridGfx.Basement, "_default"),
    Isaacs = StageAPI.RoomGfx(BackdropType.ISAAC, StageAPI.BaseGridGfx.Basement, "_default"),
    Arcade = StageAPI.RoomGfx(BackdropType.ARCADE, StageAPI.BaseGridGfx.Basement, "_default"),
    Dice = StageAPI.RoomGfx(BackdropType.DICE, StageAPI.BaseGridGfx.Basement, "_default"),
    BlueSecret = StageAPI.RoomGfx(BackdropType.BLUE_WOMB_PASS, StageAPI.BaseGridGfx.BlueWomb, "_default")
}
