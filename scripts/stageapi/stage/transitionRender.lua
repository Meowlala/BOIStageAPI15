local self = {}
local mod = require("scripts.stageapi.mod")   --This shit is written by Goganidze. If it doesn't work, blame him.
local shared = require("scripts.stageapi.shared")

--local CTGfx = require("scripts.stageapi.stage.CTGfx")

local gfxTabl = {}  --It was a separate file

gfxTabl.StartStageNum = 8
gfxTabl.StartCurrentStage = 1
gfxTabl.StartBlueWomb = false

gfxTabl.ExtraAnmOffset = {Vector(-1,0),Vector(0,0),Vector(1,0),Vector(0,0)}
gfxTabl.ExtraAnmColor = {Color(0,0,0,1),Color(0,0,0,1), --0
	Color(0.02,0.02,0.02,1),Color(0.02,0.02,0.02,1), --2
	Color(0.04,0.04,0.04,1),Color(0.04,0.04,0.04,1), --4
	Color(0.059,0.059,0.059,1),Color(0.059,0.059,0.059,1), --6
	Color(0.235,0.235,0.235,1),Color(0.235,0.235,0.235,1), --8 
	Color(0.47,0.47,0.47,1),Color(0.47,0.47,0.47,1),       --10
	Color(0.705,0.705,0.705,1),Color(0.705,0.705,0.705,1), 
	Color(0.784,0.784,0.784,1),Color(0.784,0.784,0.784,1), 
	Color(0.86,0.86,0.86,1),Color(0.86,0.86,0.86,1), 
	Color(1,1,1,1),Color(1,1,1,1), 
	}


gfxTabl.IconAnm = Sprite()
gfxTabl.IconAnm:Load("stageapi/transition/progress.anm2",false)
gfxTabl.IconAnm:ReplaceSpritesheet(1,"gfx/ui/stage/progress.png")
gfxTabl.IconAnm:ReplaceSpritesheet(0,"gfx/ui/stage/progress.png")
gfxTabl.IconAnm:LoadGraphics(true)
gfxTabl.IconAnm.Scale = Vector(1,1)

function gfxTabl.Nightmare_bg(anm)
	if not anm then
		spr = Sprite()
		spr:Load("stageapi/transition/nightmare_bg.anm2",true)
		spr:Play("Intro",true)
		return spr
	else
		anm:Load("stageapi/transition/nightmare_bg.anm2",true)
		anm:Play("Intro",true)
	end
end

gfxTabl.BlackNotCube = Sprite()
gfxTabl.BlackNotCube:Load("stageapi/transition/nightmare_bg.anm2",true)
gfxTabl.BlackNotCube:Play("ПрямоугольникМалевича",true)
gfxTabl.BlackNotCube.Color = Color(1,1,1,0)

gfxTabl.PlayersExtraFrame = 1

gfxTabl.BossSpots = {
	[LevelStage.STAGE1_1] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_01_basement.png",
		[StageType.STAGETYPE_WOTL] = "gfx/ui/boss/bossspot_02_cellar.png",
		[StageType.STAGETYPE_AFTERBIRTH] = "gfx/ui/boss/bossspot_13_burning_basement.png",
		[StageType.STAGETYPE_REPENTANCE] = "gfx/ui/boss/bossspot_01x_downpour.png",
		[StageType.STAGETYPE_REPENTANCE_B] = "gfx/ui/boss/bossspot_02x_dross.png",
		},
	[LevelStage.STAGE1_2] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_01_basement.png",
		[StageType.STAGETYPE_WOTL] = "gfx/ui/boss/bossspot_02_cellar.png",
		[StageType.STAGETYPE_AFTERBIRTH] = "gfx/ui/boss/bossspot_13_burning_basement.png",
		[StageType.STAGETYPE_REPENTANCE] = "gfx/ui/boss/bossspot_01x_downpour.png",
		[StageType.STAGETYPE_REPENTANCE_B] = "gfx/ui/boss/bossspot_02x_dross.png",
		},
	[LevelStage.STAGE2_1] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_03_caves.png",
		[StageType.STAGETYPE_WOTL] = "gfx/ui/boss/bossspot_04_catacombs.png",
		[StageType.STAGETYPE_AFTERBIRTH] = "gfx/ui/boss/bossspot_14_drowned_caves.png",
		[StageType.STAGETYPE_REPENTANCE] = "gfx/ui/boss/bossspot_03x_mines.png",
		[StageType.STAGETYPE_REPENTANCE_B] = "gfx/ui/boss/bossspot_04x_ashpit.png",
		},
	[LevelStage.STAGE2_2] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_03_caves.png",
		[StageType.STAGETYPE_WOTL] = "gfx/ui/boss/bossspot_04_catacombs.png",
		[StageType.STAGETYPE_AFTERBIRTH] = "gfx/ui/boss/bossspot_14_drowned_caves.png",
		[StageType.STAGETYPE_REPENTANCE] = "gfx/ui/boss/bossspot_03x_mines.png",
		[StageType.STAGETYPE_REPENTANCE_B] = "gfx/ui/boss/bossspot_04x_ashpit.png",
		},
	[LevelStage.STAGE3_1] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_05_depths.png",
		[StageType.STAGETYPE_WOTL] = "gfx/ui/boss/bossspot_06_necropolis.png",
		[StageType.STAGETYPE_AFTERBIRTH] = "gfx/ui/boss/bossspot_15_dank_depths.png",
		[StageType.STAGETYPE_REPENTANCE] = "gfx/ui/boss/bossspot_05x_mausoleum.png",
		[StageType.STAGETYPE_REPENTANCE_B] = "gfx/ui/boss/bossspot_06x_gehenna.png",
		},
	[LevelStage.STAGE3_2] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_05_depths.png",
		[StageType.STAGETYPE_WOTL] = "gfx/ui/boss/bossspot_06_necropolis.png",
		[StageType.STAGETYPE_AFTERBIRTH] = "gfx/ui/boss/bossspot_15_dank_depths.png",
		[StageType.STAGETYPE_REPENTANCE] = "gfx/ui/boss/bossspot_05x_mausoleum.png",
		[StageType.STAGETYPE_REPENTANCE_B] = "gfx/ui/boss/bossspot_06x_gehenna.png",
		},
	[LevelStage.STAGE4_1] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_07_womb.png",
		[StageType.STAGETYPE_WOTL] = "gfx/ui/boss/bossspot_08_utero.png",
		[StageType.STAGETYPE_AFTERBIRTH] = "gfx/ui/boss/bossspot_16_scarred_womb.png",
		[StageType.STAGETYPE_REPENTANCE] = "gfx/ui/boss/bossspot_07x_corpse.png",
		[StageType.STAGETYPE_REPENTANCE_B] = "gfx/ui/boss/bossspot_07x_corpse.png",
		},
	[LevelStage.STAGE4_2] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_07_womb.png",
		[StageType.STAGETYPE_WOTL] = "gfx/ui/boss/bossspot_08_utero.png",
		[StageType.STAGETYPE_AFTERBIRTH] = "gfx/ui/boss/bossspot_16_scarred_womb.png",
		[StageType.STAGETYPE_REPENTANCE] = "gfx/ui/boss/bossspot_07x_corpse.png",
		[StageType.STAGETYPE_REPENTANCE_B] = "gfx/ui/boss/bossspot_07x_corpse.png",
		},
	[LevelStage.STAGE4_3] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_17_blue_womb.png",
		},
	[LevelStage.STAGE5] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_09_sheol.png",
		[StageType.STAGETYPE_WOTL] = "gfx/ui/boss/bossspot_10_cathedral.png",
		},
	[LevelStage.STAGE6] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_11_darkroom.png",
		[StageType.STAGETYPE_WOTL] = "gfx/ui/boss/bossspot_12_chest.png",
		},
	[LevelStage.STAGE7] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_19_void.png",
		}, 
	[LevelStage.STAGE8] = {
		[StageType.STAGETYPE_ORIGINAL] = "gfx/ui/boss/bossspot_02_cellar.png",
		},
	}

gfxTabl.StageIcons = {
	[LevelStage.STAGE1_1] = {
		[StageType.STAGETYPE_ORIGINAL] = 0,
		[StageType.STAGETYPE_WOTL] = 1,
		[StageType.STAGETYPE_AFTERBIRTH] = 2,
		[StageType.STAGETYPE_REPENTANCE] = 19,
		[StageType.STAGETYPE_REPENTANCE_B] = 20,
		},
	[LevelStage.STAGE1_2] = {
		[StageType.STAGETYPE_ORIGINAL] = 0,
		[StageType.STAGETYPE_WOTL] = 1,
		[StageType.STAGETYPE_AFTERBIRTH] = 2,
		[StageType.STAGETYPE_REPENTANCE] = 19,
		[StageType.STAGETYPE_REPENTANCE_B] = 20,
		},
	[LevelStage.STAGE2_1] = {
		[StageType.STAGETYPE_ORIGINAL] = 3,
		[StageType.STAGETYPE_WOTL] = 4,
		[StageType.STAGETYPE_AFTERBIRTH] = 5,
		[StageType.STAGETYPE_REPENTANCE] = 21,
		[StageType.STAGETYPE_REPENTANCE_B] = 22,
		},
	[LevelStage.STAGE2_2] = {
		[StageType.STAGETYPE_ORIGINAL] = 3,
		[StageType.STAGETYPE_WOTL] = 4,
		[StageType.STAGETYPE_AFTERBIRTH] = 5,
		[StageType.STAGETYPE_REPENTANCE] = 21,
		[StageType.STAGETYPE_REPENTANCE_B] = 22,
		},
	[LevelStage.STAGE3_1] = {
		[StageType.STAGETYPE_ORIGINAL] = 6,
		[StageType.STAGETYPE_WOTL] = 7,
		[StageType.STAGETYPE_AFTERBIRTH] = 8,
		[StageType.STAGETYPE_REPENTANCE] = 23,
		[StageType.STAGETYPE_REPENTANCE_B] = 24,
		},
	[LevelStage.STAGE3_2] = {
		[StageType.STAGETYPE_ORIGINAL] = 6,
		[StageType.STAGETYPE_WOTL] = 7,
		[StageType.STAGETYPE_AFTERBIRTH] = 8,
		[StageType.STAGETYPE_REPENTANCE] = 23,
		[StageType.STAGETYPE_REPENTANCE_B] = 24,
		},
	[LevelStage.STAGE4_1] = {
		[StageType.STAGETYPE_ORIGINAL] = 9,
		[StageType.STAGETYPE_WOTL] = 10,
		[StageType.STAGETYPE_AFTERBIRTH] = 11,
		[StageType.STAGETYPE_REPENTANCE] = 25,
		--[StageType.STAGETYPE_REPENTANCE_B] = 26,
		},
	[LevelStage.STAGE4_2] = {
		[StageType.STAGETYPE_ORIGINAL] = 9,
		[StageType.STAGETYPE_WOTL] = 10,
		[StageType.STAGETYPE_AFTERBIRTH] = 11,
		[StageType.STAGETYPE_REPENTANCE] = 25,
		--[StageType.STAGETYPE_REPENTANCE_B] = 26,
		},
	[LevelStage.STAGE4_3] = {
		[StageType.STAGETYPE_ORIGINAL] = 12,
		},
	[LevelStage.STAGE5] = {
		[StageType.STAGETYPE_ORIGINAL] = 13,
		[StageType.STAGETYPE_WOTL] = 14,
		},
	[LevelStage.STAGE6] = {
		[StageType.STAGETYPE_ORIGINAL] = 15,
		[StageType.STAGETYPE_WOTL] = 16,
		},
	[LevelStage.STAGE7] = {
		[StageType.STAGETYPE_ORIGINAL] = 18,
		},
	[LevelStage.STAGE8] = {
		[StageType.STAGETYPE_ORIGINAL] = 27,
		},
	}

gfxTabl.StringToStageType = {
	[""] = StageType.STAGETYPE_ORIGINAL,
	["a"] = StageType.STAGETYPE_WOTL,
	["b"] = StageType.STAGETYPE_AFTERBIRTH,
	["c"] = StageType.STAGETYPE_REPENTANCE,
	["d"] = StageType.STAGETYPE_REPENTANCE_B,
	}

gfxTabl.StageTypeToString = {
	[StageType.STAGETYPE_ORIGINAL] = "",
	[StageType.STAGETYPE_WOTL] = "a",
	[StageType.STAGETYPE_AFTERBIRTH] = "b",
	[StageType.STAGETYPE_REPENTANCE] = "c",
	[StageType.STAGETYPE_REPENTANCE_B] = "d",
	}

gfxTabl.StageMusicID = {
	[LevelStage.STAGE1_1] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_BASEMENT,
		[StageType.STAGETYPE_WOTL] = Music.MUSIC_CELLAR,
		[StageType.STAGETYPE_AFTERBIRTH] = Music.MUSIC_BURNING_BASEMENT,
		[StageType.STAGETYPE_REPENTANCE] = Music.MUSIC_DOWNPOUR,
		[StageType.STAGETYPE_REPENTANCE_B] = Music.MUSIC_DROSS,
		},
	[LevelStage.STAGE1_2] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_BASEMENT,
		[StageType.STAGETYPE_WOTL] = Music.MUSIC_CELLAR,
		[StageType.STAGETYPE_AFTERBIRTH] = Music.MUSIC_BURNING_BASEMENT,
		[StageType.STAGETYPE_REPENTANCE] = Music.MUSIC_DOWNPOUR,
		[StageType.STAGETYPE_REPENTANCE_B] = Music.MUSIC_DROSS,
		},

	[LevelStage.STAGE2_1] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_CAVES,
		[StageType.STAGETYPE_WOTL] = Music.MUSIC_CATACOMBS,
		[StageType.STAGETYPE_AFTERBIRTH] = Music.MUSIC_FLOODED_CAVES,
		[StageType.STAGETYPE_REPENTANCE] = Music.MUSIC_MINES,
		[StageType.STAGETYPE_REPENTANCE_B] = Music.MUSIC_ASHPIT,
		},
	[LevelStage.STAGE2_2] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_CAVES,
		[StageType.STAGETYPE_WOTL] = Music.MUSIC_CATACOMBS,
		[StageType.STAGETYPE_AFTERBIRTH] = Music.MUSIC_FLOODED_CAVES,
		[StageType.STAGETYPE_REPENTANCE] = Music.MUSIC_MINES,
		[StageType.STAGETYPE_REPENTANCE_B] = Music.MUSIC_ASHPIT,
		},

	[LevelStage.STAGE3_1] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_DEPTHS,
		[StageType.STAGETYPE_WOTL] = Music.MUSIC_NECROPOLIS,
		[StageType.STAGETYPE_AFTERBIRTH] = Music.MUSIC_DANK_DEPTHS,
		[StageType.STAGETYPE_REPENTANCE] = Music.MUSIC_MAUSOLEUM,
		[StageType.STAGETYPE_REPENTANCE_B] = Music.MUSIC_GEHENNA,
		},
	[LevelStage.STAGE3_2] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_DEPTHS,
		[StageType.STAGETYPE_WOTL] = Music.MUSIC_NECROPOLIS,
		[StageType.STAGETYPE_AFTERBIRTH] = Music.MUSIC_DANK_DEPTHS,
		[StageType.STAGETYPE_REPENTANCE] = Music.MUSIC_MAUSOLEUM,
		[StageType.STAGETYPE_REPENTANCE_B] = Music.MUSIC_GEHENNA,
		},

	[LevelStage.STAGE4_1] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_WOMB_UTERO,
		[StageType.STAGETYPE_WOTL] = Music.MUSIC_UTERO,
		[StageType.STAGETYPE_AFTERBIRTH] = Music.MUSIC_SCARRED_WOMB,
		[StageType.STAGETYPE_REPENTANCE] = Music.MUSIC_CORPSE,
		[StageType.STAGETYPE_REPENTANCE_B] = Music.MUSIC_MORTIS,
		},
	[LevelStage.STAGE4_2] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_WOMB_UTERO,
		[StageType.STAGETYPE_WOTL] = Music.MUSIC_UTERO,
		[StageType.STAGETYPE_AFTERBIRTH] = Music.MUSIC_SCARRED_WOMB,
		[StageType.STAGETYPE_REPENTANCE] = Music.MUSIC_CORPSE,
		[StageType.STAGETYPE_REPENTANCE_B] = Music.MUSIC_MORTIS,
		},

	[LevelStage.STAGE4_3] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_BLUE_WOMB,
		},

	[LevelStage.STAGE5] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_SHEOL,
		[StageType.STAGETYPE_WOTL] = Music.MUSIC_CATHEDRAL,
		},
	[LevelStage.STAGE6] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_DARK_ROOM,
		[StageType.STAGETYPE_WOTL] = Music.MUSIC_CHEST,
		},
	[LevelStage.STAGE7] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_VOID,
		},
	[LevelStage.STAGE8] = {
		[StageType.STAGETYPE_ORIGINAL] = Music.MUSIC_ISAACS_HOUSE,
		},
	}

gfxTabl.Callbacks = {
	--[[{ModCallbacks.MC_POST_UPDATE , function()   --SoundBlockCallback = function()
			for name, sound in pairs(SoundEffect) do
				
   				if SFXManager():IsPlaying(sound) then
    					SFXManager():Stop(sound)
				end
			end
		end, },]]
	{ModCallbacks.MC_ENTITY_TAKE_DMG , function() --PlayerDamageBlockCallback 
			return false
		end,EntityType.ENTITY_PLAYER },
	{ModCallbacks.MC_PRE_USE_ITEM , function() --PlayerItemBlockCallback 
			return true
		end, },
	{ModCallbacks.MC_POST_EFFECT_INIT , function()  --MomFootBlockCallback 
			e:Remove()
		end, EffectVariant.MOM_FOOT_STOMP},
	}

gfxTabl.BossDeathPortrait = {
		"2","0","3","6","7","9","26","47","27","28","29","31","32","34","36","44","49","38","8","50","4","22","52","55","48",
	       -- 1  2   3   4   5   6   7    8    9    10   11   12   13   14   15   16   17   18  19   20  21   22   23   24   25
	 	"1","5","57","33","35","37","51","41","58","56","59","25","30","62","63","60","61","64","65","66","67","68","69","70","71",
	     --  26   27  28  29   30   31   32   33   34   35   36   37   38   39   40   41   42   43   44   45   46   47   48   49   50
		"72","73","74","76","77","93","79","80","81","83","82","84","85","86","92","87","88","89","90","91","84","94","98","100","101",
	      -- 51   52   53   54   55   56   57   58   59   60   61   62   63   64   65   66   67   68   69   70   71   72   73   74    75
		"102","103","104","105","106","107","108","110","111","112","113","116","119","9","47","121","122","123","124","125","126","127","128","129","131",
	      -- 76    77    78    79    80    81    82    83    84    85    86    87    88    89  90   91    92    93    94    95    96    97    98    99    100
		"136","137","140"
	      -- 101   102   103
	}

gfxTabl.DreamCatcherSprites = {}

gfxTabl.DreamCatcherItemType = 1

gfxTabl.DreamCatcher1ItemPos = {[29]=Vector(-5,-32),[33]=Vector(-5,-33),[37]=Vector(-5,-32),[41]=Vector(-5,-33),
	[45]=Vector(-5,-32),[49]=Vector(-5,-33),[53]=Vector(-5,-32),[57]=Vector(-5,-33),[61]=Vector(-5,-32),[65]=Vector(-5,-33),}
gfxTabl.DreamCatcher2ItemPos = {[29]=Vector(24,-32),[33]=Vector(24,-33),[37]=Vector(24,-32),[41]=Vector(24,-33),
	[45]=Vector(24,-32),[49]=Vector(24,-33),[53]=Vector(24,-32),[57]=Vector(24,-33),[61]=Vector(24,-32),[65]=Vector(24,-33),}

gfxTabl.DreamCatcherItemPos = {
		[0]=Vector(5,-31),[2]=Vector(5,-30.5),[5]=Vector(5,-30),[10]=Vector(5,-30.5),[11]=Vector(5,-31)
	}

gfxTabl.DreamCatcherBossPos = {[0]={Vector(100,-48),0,1.1}, [1]={Vector(90,-48),0.25,1.13}, [2]={Vector(80,-48),0.5,1.15}, [3]={Vector(70,-48),0.75,1.17}, [4]={Vector(60,-48),1,1.2},
		[5]={Vector(57,-48),1,1.0}, [6]={Vector(55,-48),1,0.8}, [8]={Vector(55,-48),1,1.0}, [64]={Vector(45,-48),1,1.0},
	}

function gfxTabl.DreamCatcherSprites.Bubble(anm)
	anm:Load("gfx/ui/stage/nightmare_dc.anm2",true)
end

gfxTabl.DreamCatcherSprites.Nightmare = Sprite()
gfxTabl.DreamCatcherSprites.Nightmare:Load("gfx/ui/stage/nightmare_dc.anm2",true)

gfxTabl.DreamCatcherSprites.Item1 = Sprite()
gfxTabl.DreamCatcherSprites.Item1:Load("gfx/ui/death screen.anm2",true)
gfxTabl.DreamCatcherSprites.Item1:Play(gfxTabl.DreamCatcherSprites.Item1:GetDefaultAnimation())
gfxTabl.DreamCatcherSprites.Item1:ReplaceSpritesheet(0,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item1:ReplaceSpritesheet(1,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item1:ReplaceSpritesheet(2,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item1:ReplaceSpritesheet(3,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item1:ReplaceSpritesheet(4,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item1:ReplaceSpritesheet(5,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item1:ReplaceSpritesheet(7,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item1:ReplaceSpritesheet(8,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item1.Offset = Vector(84,-10)
gfxTabl.DreamCatcherSprites.Item1:LoadGraphics(true)

gfxTabl.DreamCatcherSprites.Item2 = Sprite()
gfxTabl.DreamCatcherSprites.Item2:Load("gfx/ui/death screen.anm2",true)
gfxTabl.DreamCatcherSprites.Item2:Play(gfxTabl.DreamCatcherSprites.Item2:GetDefaultAnimation())
gfxTabl.DreamCatcherSprites.Item2:ReplaceSpritesheet(0,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item2:ReplaceSpritesheet(1,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item2:ReplaceSpritesheet(2,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item2:ReplaceSpritesheet(3,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item2:ReplaceSpritesheet(4,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item2:ReplaceSpritesheet(5,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item2:ReplaceSpritesheet(7,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item2:ReplaceSpritesheet(8,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Item2.Offset = Vector(84,-10)
gfxTabl.DreamCatcherSprites.Item2:LoadGraphics(true)

gfxTabl.DreamCatcherSprites.Boss = Sprite()
gfxTabl.DreamCatcherSprites.Boss:Load("gfx/ui/death screen.anm2",true)
gfxTabl.DreamCatcherSprites.Boss:Play(gfxTabl.DreamCatcherSprites.Boss:GetDefaultAnimation())
gfxTabl.DreamCatcherSprites.Boss:ReplaceSpritesheet(0,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Boss:ReplaceSpritesheet(1,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Boss:ReplaceSpritesheet(2,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Boss:ReplaceSpritesheet(4,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Boss:ReplaceSpritesheet(5,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Boss:ReplaceSpritesheet(6,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Boss:ReplaceSpritesheet(7,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Boss:ReplaceSpritesheet(8,"stageapi/none.png")
gfxTabl.DreamCatcherSprites.Boss.Offset = Vector(-21,30)
gfxTabl.DreamCatcherSprites.Boss:LoadGraphics(true)

gfxTabl.DreamCatcherItems = {}

function gfxTabl.DreamCatcherCheck()
	local check = false
	local TwoItem = false
	--for i=0,Game().GetNumPlayers(Game())-1 do --Isaac.GetPlayer(i)
	for _, player in ipairs(shared.Players) do
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DREAM_CATCHER,false) then
			check = true
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS,false) then
			TwoItem = true
		end
	end
	if check then
		local bossSubType

		--local level = shared.Level  
		local RoomsTable = shared.Level:GetRooms()
		gfxTabl.DreamCatcherItemType = -1
		for i=1,#RoomsTable do
	   	   if RoomsTable:Get(i-1) then
		   	local roomdata = RoomsTable:Get(i-1).Data
		   	if roomdata.Type == RoomType.ROOM_TREASURE then
				local spawnlist = roomdata.Spawns
				local itemcount = 0
				for j=0,#spawnlist-1 do
					local spawnEntry = spawnlist:Get(j)
					local entR = spawnEntry:PickEntry(0)
					if entR.Type == 5 and entR.Variant == 100 then
						itemcount = itemcount + 1
					end
				end
				gfxTabl.DreamCatcherItemType = itemcount < 3 and itemcount or 2
				if gfxTabl.DreamCatcherItemType > 0 and TwoItem then gfxTabl.DreamCatcherItemType = 2 end
				TwoItem = itemcount >= 2
			elseif roomdata.Type == RoomType.ROOM_BOSS then
				bossSubType = roomdata.Subtype
			end
		   end
		end
		local pool = shared.Game:GetItemPool()
		local seed = shared.Game:GetSeeds():GetStartSeed()
		local item1 = gfxTabl.DreamCatcherItemType > 0 and pool:GetCollectible(ItemPoolType.POOL_TREASURE,false,nil,CollectibleType.COLLECTIBLE_NULL)
		local item2 = gfxTabl.DreamCatcherItemType > 1 and pool:GetCollectible(ItemPoolType.POOL_TREASURE,false,nil,CollectibleType.COLLECTIBLE_NULL)
		gfxTabl.DreamCatcherItems = { item1,item2 }

		if item1 then 
			gfxTabl.DreamCatcherSprites.Item1:SetFrame((item1-1)<731 and item1-1 or 669)
		end
		if item2 then 
			gfxTabl.DreamCatcherSprites.Item2:SetFrame((item2-1)<731 and item2-1 or 669) 
		end
		if bossSubType then
			if gfxTabl.BossDeathPortrait[bossSubType] then
				local frame = tonumber(gfxTabl.BossDeathPortrait[bossSubType])
				gfxTabl.DreamCatcherSprites.Boss:SetFrame(frame)
			else
				gfxTabl.DreamCatcherSprites.Boss:SetFrame(bossSubType-1)
			end
		end
	end
	return check
end

local CTGfx = gfxTabl

local NightmareNum = 1
local DontAddStage = false

local IconAnm = CTGfx.IconAnm  

local Nightmare_bg = CTGfx.Nightmare_bg()
local BlackCube = CTGfx.BlackNotCube

local NightmareAnm = Sprite()

local PlayerExtra = Sprite()

local bg_RenderPos = Vector(240,135)  
local nm_RenderPos = Vector(240,20)
local Render_Extra_Offset = Vector(-72,-19)

local ProgressAnm = {}

local BlueWomb = CTGfx.StartBlueWomb 
local StageProgNum = CTGfx.StartStageNum
local CurrentStage = CTGfx.StartCurrentStage 
local NextStageID = 2
local NextStage = "2"
local MusikID
local Stages = {}
--local FakeStages = {}
--local OffsetStages = {}
local Nightmare
local PlSpot 
local DontReplacePlSpot
local PlayerGfx 
local Sdelay = 0
local StartDisap
local ExtraFrame = CTGfx.PlayersExtraFrame
local MusicOnPause = false
local DreamCatcher = false

local DefaultTransitionMusik = Music.MUSIC_JINGLE_NIGHTMARE
local TransitionMusik = DefaultTransitionMusik

local ShaderState = 0
local PIxelAmonStart = 0.002
local PIxelAmon = PIxelAmonStart

local function BlockCallbacks(mode)
    if not mode then
	for i,cal in pairs(CTGfx.Callbacks) do
		if cal[1] and cal[2] then
			mod:AddCallback(cal[1],cal[2],cal[3])
		end
	end
    else
	for i,cal in pairs(CTGfx.Callbacks) do
		if cal[1] and cal[2] then
			mod:RemoveCallback(cal[1],cal[2])
		end
	end
    end
end

local NightmareFrameCount = nil
local function StandartNightmare()
	if Isaac.GetFrameCount()%2 == 0 then
		Nightmare_bg:Update()

		if Nightmare_bg:IsFinished("Intro") then
			Nightmare_bg:Play("Loop",true)
		elseif Nightmare_bg:IsPlaying("Loop") then
			if NightmareAnm:GetFrame() == 0 then
				NightmareAnm:SetLastFrame()
				NightmareFrameCount = NightmareAnm:GetFrame()
				NightmareAnm:SetFrame(0)
			end
			NightmareAnm:Update()
		end
		if NightmareFrameCount and NightmareAnm:GetFrame() >= NightmareFrameCount-20  or 
		NightmareAnm:IsFinished("Scene") then
			if BlackCube.Color.A >= 2.0 then
				StartDisap = true
			end  
			BlackCube.Color = Color(1,1,1,BlackCube.Color.A+0.05)
		end
	end
end

local DCSprite = {}
DCSprite.nightmare = CTGfx.DreamCatcherSprites.Nightmare
DCSprite.item1 = CTGfx.DreamCatcherSprites.Item1
DCSprite.item2 = CTGfx.DreamCatcherSprites.Item2
DCSprite.boss = CTGfx.DreamCatcherSprites.Boss
DCSprite.State = 0
DCSprite.item1Offset = Vector.Zero
DCSprite.item2Offset = Vector.Zero

DCSprite.Items = CTGfx.DreamCatcherItems
DCSprite.ItemCallbackActivated = false

local function DreamCatcherNightmare()
	if Isaac.GetFrameCount()%2 == 0 then
		Nightmare_bg:Update()

		if Nightmare_bg:IsFinished("Intro") then
			Nightmare_bg:Play("Loop",true)
		elseif Nightmare_bg:IsPlaying("Loop") then
			NightmareAnm:Update()
		end
		if NightmareAnm:IsFinished("Scene") then
			DCSprite.nightmare:Update()
			if DCSprite.State == 0 then 
				if DCSprite.nightmare:GetFrame() == 64 then
					DCSprite.item1.Color = Color(1,1,1,0.5)
					DCSprite.item2.Color = Color(1,1,1,0.5)
				elseif DCSprite.nightmare:GetFrame() >= 65 then
					DCSprite.State = 1
					DCSprite.item1.Color = Color(1,1,1,0.0)
					DCSprite.item2.Color = Color(1,1,1,0.0)
					DCSprite.nightmare:Play("Boss",true)
				end
			elseif DCSprite.State == 1 then 
				if DCSprite.nightmare:GetFrame() >= 48 then
					if BlackCube.Color.A >= 2.0 then
						StartDisap = true
					end  
					BlackCube.Color = Color(1,1,1,BlackCube.Color.A+0.05)
				end
			end
		end
	end
	if NightmareAnm:IsFinished("Scene") then
		local Ioffset = CTGfx.DreamCatcherItemPos
		local Ioffset1 = CTGfx.DreamCatcher1ItemPos
		local Ioffset2 = CTGfx.DreamCatcher2ItemPos
		local Boffset = CTGfx.DreamCatcherBossPos

		DCSprite.nightmare:Render(bg_RenderPos)
		if DCSprite.State == 0 and DCSprite.nightmare:GetFrame() >= 29 then
			local frame = DCSprite.nightmare:GetFrame()
			if CTGfx.DreamCatcherItemType > 1 then
				DCSprite.item1Offset = Vector(Ioffset1[29] and Ioffset1[29].X or DCSprite.item1Offset.X,Ioffset[(frame-29)%12] and Ioffset[(frame-29)%12].Y or DCSprite.item1Offset.Y)-- or DCSprite.item1Offset
				DCSprite.item2Offset = Vector(Ioffset2[29] and Ioffset2[29].X or DCSprite.item2Offset.X,Ioffset[(frame-29)%12] and Ioffset[(frame-29)%12].Y or DCSprite.item2Offset.Y)-- or DCSprite.item2Offset

				DCSprite.item1:Render(bg_RenderPos+DCSprite.item1Offset)
				DCSprite.item2:Render(bg_RenderPos+DCSprite.item2Offset)
			elseif CTGfx.DreamCatcherItemType > 0 then
				DCSprite.item1Offset = Ioffset[(frame-29)%12] or DCSprite.item1Offset

				DCSprite.item1:Render(bg_RenderPos+DCSprite.item1Offset)
			end
		elseif DCSprite.State == 1 then
			DCSprite.nightmare:Render(bg_RenderPos)
			local frame = DCSprite.nightmare:GetFrame()
			if frame < 8 then
				local GreyColor = Color(1, 1, 1, Boffset[frame] and Boffset[frame][2] or DCSprite.boss.Color.A, 0, 0, 0)
				GreyColor:SetColorize(1, 1, 1, 1)

				DCSprite.item1Offset = Boffset[frame] and Boffset[frame][1] or DCSprite.item1Offset
				
				DCSprite.boss.Color = GreyColor
				DCSprite.boss.Scale = Vector(Boffset[frame] and Boffset[frame][3] or DCSprite.boss.Scale.X,
					Boffset[frame] and Boffset[frame][3] and (2-Boffset[frame][3]) or DCSprite.boss.Scale.Y)
				DCSprite.boss:Render(bg_RenderPos+DCSprite.item1Offset)
			elseif frame >= 8 then
				DCSprite.boss.Scale = Vector(Boffset[frame] and Boffset[frame][3] or DCSprite.boss.Scale.X,
					Boffset[frame] and Boffset[frame][3] and (2-Boffset[frame][3]) or DCSprite.boss.Scale.Y)
				local Pos1 = Boffset[8][1]
				local Pos2 = Boffset[64][1]
				local cof = ((frame-8)/59)
				local RenderPos = Pos1 * (1-cof) + Pos2 * (cof)

				DCSprite.boss:Render(bg_RenderPos+RenderPos)
			end
		end
	end
end

local function DreamCatcherItemReplace() --Instead of predicting the next items, the code overrides them
	local RoomDesc = shared.Level:GetCurrentRoomDesc()
	local RoomData = RoomDesc.Data	
	
	if RoomData and RoomData.Type and RoomData.Type == RoomType.ROOM_TREASURE then
		local num = 0
		local CantReplace = nil
		for i,e in pairs(Isaac.FindByType(5,100,-1,true,false)) do
			num = num + 1 
			if e:ToPickup():IsShopItem() then
				CantReplace = true
				break
			end
		end	

		local pool = shared.Game:GetItemPool()
		if not CantReplace and num == CTGfx.DreamCatcherItemType then
			for i,e in pairs(Isaac.FindByType(5,100,-1,false,false)) do

				if DCSprite.Items[i] then
					print("Item has been replaced, original ID =",e.SubType)
					e:ToPickup():Morph(5,100,DCSprite.Items[i],false,true,false)
				end
			end
		end
		mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, DreamCatcherItemReplace)
		DCSprite.ItemCallbackActivated = false
	end
end

local function TransitionRender(_, name)
	for _, player in ipairs(shared.Players) do
		player.ControlsCooldown = math.max(player.ControlsCooldown,80)
	end

	Nightmare_bg:Render(bg_RenderPos,Vector.Zero,Vector.Zero)

	if StageAPI.PlayerBossInfo[Isaac.GetPlayer(0):GetPlayerType()].ExtraPortrait then
		if not PlayerGfx.NoShake then
			PlayerExtra.Offset = CTGfx.ExtraAnmOffset[ExtraFrame]
		end
		PlayerExtra:Render(bg_RenderPos+Render_Extra_Offset)
		PlayerExtra.Color = not (Nightmare_bg:IsPlaying("Intro") and Nightmare_bg:GetFrame()<=19) and Nightmare_bg.Color or PlayerExtra.Color
		
		if Isaac.GetFrameCount()%2 == 0 then
			PlayerExtra:Update()
			ExtraFrame = ExtraFrame + 1
			if ExtraFrame >= 5 then ExtraFrame = 1 end
		end
		if Nightmare_bg:IsPlaying("Intro") and Nightmare_bg:GetFrame()<=18 then
			PlayerExtra.Color = CTGfx.ExtraAnmColor[Nightmare_bg:GetFrame()+2]
		end
	end
	NightmareAnm:Render(bg_RenderPos,Vector.Zero,Vector.Zero)

	if not DreamCatcher then
		StandartNightmare()
	else
		DreamCatcherNightmare()
	end
	
	if ProgressAnm and #ProgressAnm>0 then
		if Isaac.GetFrameCount()%2 == 0 then
					
			if not MusicOnPause and MusicManager():GetCurrentMusicID() ~= TransitionMusik then
				MusicOnPause = true
				--MusicManager():Play(TransitionMusik,0)
				MusicManager():Pause()
			end

			ProgressAnm.IsaacIndicator:Update()

			if Nightmare_bg:IsPlaying("Loop") and ProgressAnm.IsaacIndicatorPos:Distance(ProgressAnm.IsaacIndicatorNextPos) > 1 then
				local Ang = (ProgressAnm.IsaacIndicatorNextPos-ProgressAnm.IsaacIndicatorPos):GetAngleDegrees()
				local Nextpos = Vector.FromAngle(Ang):Resized(ProgressAnm.IsaacIndicatorMovSpeed)
				ProgressAnm.IsaacIndicatorPos = ProgressAnm.IsaacIndicatorPos+Nextpos
			elseif Nightmare_bg:IsPlaying("Intro") and ProgressAnm.IsaacIndicator.Color.R < 1 then
				local IIC = ProgressAnm.IsaacIndicator.Color 
				ProgressAnm.IsaacIndicator.Color = Color(IIC.R+0.05, IIC.G+0.05, IIC.B+0.05, 1)
				ProgressAnm.BossIndicator.Color = Color(IIC.R+0.05, IIC.G+0.05, IIC.B+0.05, 1)
				ProgressAnm.Clock.Color = Color(IIC.R+0.05, IIC.G+0.05, IIC.B+0.05, 1)
			end
		end

		ProgressAnm.Connector:Render(nm_RenderPos)
		for i,k in pairs(ProgressAnm) do
			if type(i) == "number" then
				local RPos = k.pos
				k.spr:Render(RPos)
				if Isaac.GetFrameCount()%2 == 0 then
					if Nightmare_bg:IsPlaying("Intro") and k.spr.Color.R < 1 then
						k.spr.Color = Color(k.spr.Color.R+0.05, k.spr.Color.G+0.05, k.spr.Color.B+0.05, 1)
					end
				end
			end
		end
		if shared.Game.TimeCounter < shared.Game.BossRushParTime then
			ProgressAnm.Clock:Render(ProgressAnm.ClockPos)
		end
		ProgressAnm.BossIndicator:Render(ProgressAnm.BossIndicatorPos)
		ProgressAnm.IsaacIndicator:Render(ProgressAnm.IsaacIndicatorPos)
	end

	BlackCube:Render(bg_RenderPos)

	if  (Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, Isaac.GetPlayer(0).ControllerIndex) or 
	Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, Isaac.GetPlayer(0).ControllerIndex)) then
		StartDisap = true
	end

	if StartDisap then
		Nightmare_bg.Color = Color(1,1,1,1)
		NightmareAnm.Color = Color(1,1,1,1)

		if MusikID then
			shared.Music:Play(MusikID,Options.MusicVolume)
		end
		MusicOnPause = false

		shared.Game:GetHUD():SetVisible(true)

		ExtraFrame = CTGfx.PlayersExtraFrame
		ShaderState = 3
		
		BlockCallbacks(true)
	end
end


--[[local function calcStageOffset(id)
	local offset = 0
	for i=1,id do
		if FakeStages[i] then
			offset = offset + #FakeStages[i]
		end
	end
	return offset
end]]

--[[local function AddProgressStageBetween(OriginalId,frame)
	if OriginalId and frame then
		OffsetStages[OriginalId] = OffsetStages[OriginalId] and (OffsetStages[OriginalId] + 1) or 1

		FakeStages[OriginalId] = FakeStages[OriginalId] and (FakeStages[OriginalId] + 1) or 1
		--FakeStages[OriginalId][#FakeStages[OriginalId]+1] = frame
		
		local StageOffset = calcStageOffset(OriginalId)

		for i=StageProgNum,1,-1 do
			if i>OriginalId+StageOffset then
				Stages[i+1] = Stages[i]
			end
		end

		Stages[OriginalId+StageOffset] = {frame = frame,IsSecond = (OriginalId)%2==0 and OriginalId<9}
	end
end]]


function self.AddDefaultProgressStage()
	if not DontAddStage then
		local level = shared.Level
		local StageI = level:GetAbsoluteStage()
		
		if not BlueWomb and ( level:GetAbsoluteStage() == LevelStage.STAGE4_3 or
		((level:GetAbsoluteStage() == LevelStage.STAGE4_1 or level:GetAbsoluteStage() == LevelStage.STAGE4_2)
		and level:GetStageType()>=4)) then
			BlueWomb = true
		end
	
		--local StageOffset = calcStageOffset(StageI)

		if level:GetStageType()>=4 and StageI<9 then
			Stages[StageI+1] = { frame = CTGfx.StageIcons[StageI][level:GetStageType()], IsSecond = (StageI)%2==0}
		else
			Stages[StageI] = {frame = CTGfx.StageIcons[StageI][level:GetStageType()],IsSecond = (StageI)%2==0 and StageI<9}
		end
	end
	if DCSprite.ItemCallbackActivated then
		mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, DreamCatcherItemReplace)
		DCSprite.ItemCallbackActivated = false
	end
	DreamCatcher = false
end

local function TransitionActivation()
	local level = shared.Level
	local Room = shared.Room

	shared.Game:GetHUD():SetVisible(false)

	local player = shared.Players[1] 

	if StageAPI.PlayerBossInfo[player:GetPlayerType()] then  
		PlayerGfx = StageAPI.PlayerBossInfo[player:GetPlayerType()]
	else
		PlayerGfx = StageAPI.PlayerBossInfo[0]
	end

	if not DontReplacePlSpot then
		PlSpot = CTGfx.BossSpots[level:GetAbsoluteStage()][level:GetStageType()]
		if StageAPI.NextStage and StageAPI.NextStage.BossSpot then
			PlSpot = StageAPI.NextStage.BossSpot
		end
		Nightmare_bg:ReplaceSpritesheet(3,PlSpot)
	else
		DontReplacePlSpot = nil
	end	

	if not PlayerGfx.NoShake then
		Nightmare_bg:ReplaceSpritesheet(2,PlayerGfx.Portrait)
		Nightmare_bg:ReplaceSpritesheet(6,"stageapi/none.png")
	else
		Nightmare_bg:ReplaceSpritesheet(6,PlayerGfx.Portrait)
		Nightmare_bg:ReplaceSpritesheet(2,"stageapi/none.png")
	end
	Nightmare_bg:Play("Intro",true)

	if PlayerGfx.ExtraPortrait then
		if type(PlayerGfx.ExtraPortrait) == 'table' then
			PlayerExtra:Load(PlayerGfx.ExtraPortrait[1],true)
			if PlayerGfx.ExtraPortrait[2] then
				Nightmare_bg:ReplaceSpritesheet(6,"stageapi/none.png")
				Nightmare_bg:ReplaceSpritesheet(2,"stageapi/none.png")
			end
		else
			PlayerExtra:Load(PlayerGfx.ExtraPortrait,true)
		end
		PlayerExtra:Play(PlayerExtra:GetDefaultAnimation(),true)
		PlayerExtra.Color = Color(0,0,0,1) 
	end

	Nightmare_bg:LoadGraphics(true)

	Nightmare = StageAPI.TransitionNightmaresList[math.random(1,#StageAPI.TransitionNightmaresList)]
	NightmareAnm:Load(Nightmare,true)
	NightmareAnm:Play("Scene",true)
	
	StartDisap = false
	ExtraFrame = 1

	if CTGfx.StageMusicID[level:GetAbsoluteStage()] and CTGfx.StageMusicID[level:GetAbsoluteStage()][level:GetStageType()] then
		MusikID = CTGfx.StageMusicID[level:GetAbsoluteStage()][level:GetStageType()]
	else
		MusikID = nil	
	end
	if StageAPI.NextStage and StageAPI.NextStage.Music and StageAPI.NextStage.Music[1] then
		MusikID = StageAPI.NextStage.Music[1]
	end

	ShaderState = 2
	local PIxelAmon = PIxelAmonStart

	local queue = shared.Music:GetCurrentMusicID()

	TransitionMusik = StageAPI.NextStage and StageAPI.NextStage.TransitionMusic or DefaultTransitionMusik
	shared.Music:Play(TransitionMusik,Options.MusicVolume)

	if DreamCatcher then
		CTGfx.DreamCatcherSprites.Bubble(NightmareAnm)
		NightmareAnm:Play("Scene",true)

		DCSprite.item1.Color = Color.Default
		DCSprite.item2.Color = Color.Default

		local INanm = CTGfx.DreamCatcherItemType > 1 and "TreasureRoomDouble"
			or CTGfx.DreamCatcherItemType > 0 and "TreasureRoom"
			or CTGfx.DreamCatcherItemType >= 0 and "TreasureRoomPoop"
		if INanm then
			DCSprite.nightmare:Play(INanm,true)
			DCSprite.State = 0
		elseif CTGfx.DreamCatcherItemType == -1 then
			DCSprite.nightmare:Play("Boss",true)
			DCSprite.State = 1
		end
		DCSprite.Items = CTGfx.DreamCatcherItems

		if not DCSprite.ItemCallbackActivated then
			mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DreamCatcherItemReplace)
			DCSprite.ItemCallbackActivated = true
		end
	end
	
end

local function GenProgressAnm()
	local ScreenWidth = Isaac.GetScreenWidth()
	bg_RenderPos = Vector(ScreenWidth/2,135)   
	nm_RenderPos = Vector(ScreenWidth/2,20)

	local Num = not BlueWomb and (StageProgNum-1) or StageProgNum+0
	Num = math.max(Num,StageProgNum-1,8)
	local leght = (Num-1)*26 + Num
	local CenPos = nm_RenderPos.X-leght/2
	local IsaacIndicatorPos	= nm_RenderPos
	local IsaacIndicatorNextPos = nm_RenderPos
	local BossIndicatorPos = nm_RenderPos

	for i=1,StageProgNum do
		if i ~= 9 or BlueWomb then 

			local nPos = Vector(CenPos+26*(i-1)+i,nm_RenderPos.Y)

			ProgressAnm[i] = {}
			ProgressAnm[i].pos = nPos
			ProgressAnm[i].spr = Sprite()
			ProgressAnm[i].spr.Color = Color(0,0,0,1)
			ProgressAnm[i].spr:Load("stageapi/transition/progress.anm2",true)
			ProgressAnm[i].ID = i
			if not Stages[i] then
				ProgressAnm[i].spr:Play("NotClearFloor",true)
				if i <= NextStageID then
					ProgressAnm[i].spr:SetFrame(1)
				else
					ProgressAnm[i].spr:SetFrame(0)
				end
			elseif Stages[i] then
				ProgressAnm[i].spr:Play("Levels",true)

				if Stages[i].frame then
					ProgressAnm[i].spr:SetLayerFrame(0,Stages[i].frame)
				elseif Stages[i].custom then
					ProgressAnm[i].spr:SetLayerFrame(0,28)
					ProgressAnm[i].spr:ReplaceSpritesheet(4, Stages[i].custom)
					ProgressAnm[i].spr:LoadGraphics()
				end

				if i < NextStageID then 
					ProgressAnm[i].spr:SetLayerFrame(3,1)
					if i == CurrentStage then
						IsaacIndicatorPos = nPos
					end
				else
					ProgressAnm[i].spr:SetLayerFrame(3,0)
				end
				if i == CurrentStage then
					IsaacIndicatorPos = nPos
				end
				if i == NextStageID then
					IsaacIndicatorNextPos = nPos
					if NextStage:find("c") or NextStage:find("d") then    
						IsaacIndicatorNextPos = Vector(CenPos+26*(i-1)+i,nm_RenderPos.Y)
					end
				end
			end
			if i>9 and not BlueWomb then
				local nPos = Vector(CenPos+26*(i-2)+i,nm_RenderPos.Y)
				ProgressAnm[i].pos = nPos
				if i == CurrentStage then
					IsaacIndicatorPos = nPos
				end
				
				if i == NextStageID then
					IsaacIndicatorNextPos = nPos
				end
			end
			if i == StageProgNum then
				BossIndicatorPos = nPos
			end
		end
	end

	ProgressAnm.Connector = Sprite()
	ProgressAnm.Connector:Load("stageapi/transition/progress.anm2",true)
	ProgressAnm.Connector:Play("Connector",true)
	ProgressAnm.Connector.Scale = Vector(Num/1.5,1)
	
	ProgressAnm.IsaacIndicator = Sprite()
	ProgressAnm.IsaacIndicator:Load("stageapi/transition/progress.anm2",true)
	ProgressAnm.IsaacIndicator:Play("IsaacIndicator",true)
	ProgressAnm.IsaacIndicator.Color = Color(0,0,0,1)
	ProgressAnm.IsaacIndicatorPos = IsaacIndicatorPos
	ProgressAnm.IsaacIndicatorNextPos = IsaacIndicatorNextPos  
	ProgressAnm.IsaacIndicatorMovSpeed = ProgressAnm.IsaacIndicatorPos:Distance(ProgressAnm.IsaacIndicatorNextPos)/40

	ProgressAnm.Clock = Sprite()
	ProgressAnm.Clock:Load("stageapi/transition/progress.anm2",true)
	ProgressAnm.Clock:Play("Clock",true)
	ProgressAnm.Clock.Color = Color(0,0,0,1)
	local Procent = shared.Game.TimeCounter / shared.Game.BossRushParTime
	local BREndPos = 26*(6-1)+6
	local ClockPos = BREndPos*Procent
	ProgressAnm.ClockPos = Vector(CenPos+ClockPos+1,nm_RenderPos.Y)
	
	ProgressAnm.BossIndicator = Sprite()
	ProgressAnm.BossIndicator:Load("stageapi/transition/progress.anm2",true)
	ProgressAnm.BossIndicator:Play("BossIndicator",true)
	ProgressAnm.BossIndicator.Color = Color(0,0,0,1)
	ProgressAnm.BossIndicatorPos = BossIndicatorPos 
end

function self.PreGenProgressAnm(stage,notAutoStage)
	if notAutoStage then
		DontAddStage = true
	end
	local level = shared.Level
	local preId = level:GetAbsoluteStage()
	
	NextStage = stage
	CTGfx.Nightmare_bg(Nightmare_bg)

	for _, player in ipairs(shared.Players) do
		player:ThrowHeldEntity(Vector(0,0))
	end
	
	if not Stages[preId] then
		self.AddDefaultProgressStage()
	end

	local AltOffset = level:GetStageType()>=4 and 1 or 0
	CurrentStage = preId+AltOffset
	if CurrentStage == 9 then BlueWomb = true end

	if (NextStage:find("8") or NextStage:find("7")) and (NextStage:find("c") or NextStage:find("d")) then
		BlueWomb = true
	end
	
	local NextId 
	for i=1,2 do
		local IsNum = tonumber(NextStage:sub(i,i))
		if IsNum then
			NextId = NextId and (NextId .. IsNum) or IsNum
		end
	end
	NextStageID = tonumber(NextId)
	if NextStage:find("c") or NextStage:find("d") then NextStageID = NextStageID+1 end  
	
	StageProgNum = math.max(StageProgNum,(BlueWomb and 9 or 8), tonumber(NextId)) 
	Sdelay = 1

	BlockCallbacks()
end

function self.SetIndicatorPos(CurrentPos,NextPos)
	if CurrentPos then
		CurrentStage = CurrentPos
	end
	if NextPos then
		NextStageID = NextPos
	end
end

function self.SetStageIcon(stagenum,gfx)
	Stages[stagenum] = {custom = gfx}
end

function self.SetStageSpot(gfx)
	DontReplacePlSpot = true
	Nightmare_bg:ReplaceSpritesheet(3,gfx)
	Nightmare_bg:LoadGraphics(true)
end

function self.StartTransition()
	ShaderState = 1
end

function self.IsTransitionPlaying()
	return ShaderState == 1 or ShaderState == 2
end

local function CTAClean(_,NewGame)
	if NewGame == false then
		CurrentStage = CTGfx.StartCurrentStage 
		NextStageID = nil
		NextStage = 2	
		BlueWomb = CTGfx.StartBlueWomb
		StageProgNum = CTGfx.StartStageNum
		Stages = {}
		ProgressAnm = {}

		self.AddDefaultProgressStage()
	end
end


local function RenderTrick()  --very strange way to fix the backdrop in Dark Room
	if Sdelay > 150 then
		Isaac.ExecuteCommand("stage " .. NextStage)

		if not DontAddStage then
			self.AddDefaultProgressStage()
		end
		DontAddStage = false

		GenProgressAnm()
		DreamCatcher = CTGfx.DreamCatcherCheck()
		TransitionActivation()
		
		BlackCube.Color = Color(1,1,1,0)

		mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_RENDER,RenderTrick)
		
		if NextStage == "11" then
			local backdropID = shared.Room:GetBackdropType() 
			shared.Game:ShowHallucination(0,backdropID)
			shared.Sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
		end
	end
end

local function ShaderRender(_, name)
  if name == "StageAPI-TransitionPixelation" then
     local ShaTabl = { PixelAm = 0.005 + PIxelAmon*Sdelay}
     if ShaderState == 0 then
	local Tabl = {PixelAm = 0}
	return Tabl
     elseif ShaderState == 1 then
	if Isaac.GetFrameCount()%2 == 0 then
		Sdelay = Sdelay+2.6  
	end
	BlackCube.Color = Color(1,1,1,(PIxelAmonStart*Sdelay)*3.5)
	BlackCube:Render(bg_RenderPos) 
	
	if Sdelay > 150 then
		for _, player in ipairs(shared.Players) do
			player:ThrowHeldEntity(Vector(10,10))
			player.PositionOffset = Vector.Zero
		end
		RenderTrick()
		--mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER,RenderTrick)
		
		local Tabl = {PixelAm = 0}
		return Tabl
	elseif Sdelay > 145 then
		local Tabl = {PixelAm = 0}
		return Tabl
	else
		return ShaTabl
	end
     elseif ShaderState == 3 then
	if Isaac.GetFrameCount()%2 == 0 then	
		Sdelay = Sdelay-2.6
	end
	BlackCube.Color = Color(1,1,1,(PIxelAmonStart*Sdelay)*3.5)
	BlackCube:Render(bg_RenderPos)
	--for i=0,Game().GetNumPlayers(Game())-1 do
	for _, player in ipairs(shared.Players) do
		player.ControlsCooldown = math.max(player.ControlsCooldown,80)

		if not player:IsHoldingItem() then
			player:AnimateAppear()
		end
	end
	if Sdelay <= 0 then
		shared.Game:GetHUD():SetVisible(true)
		ShaderState = 0
	else
		return ShaTabl
	end
     elseif ShaderState == 2 then
     	TransitionRender()

	local Tabl = {PixelAm = 0}
	return Tabl
     end
  end
end

local function TrCommand(_, cmd, params) 
	if cmd == "StadeapiCTT" then
		self.PreGenProgressAnm(params)
		self.StartTransition() 
	end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DreamCatcherItemReplace)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, self.AddDefaultProgressStage)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, CTAClean)
--mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, TrCommand)
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS,ShaderRender)

return self
