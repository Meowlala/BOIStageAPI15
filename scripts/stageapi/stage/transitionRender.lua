local self = {}
local mod = require("scripts.stageapi.mod")   --This shit is written by Goganidze. If it doesn't work, blame him.
local shared = require("scripts.stageapi.shared")

local horsemanRoomSubtypes = {
    9, -- Famine
    10, -- Pestilence
    11, -- War
    12, -- Death
    22, -- Headless Horseman
    38 -- Conquest
}

local BossEncountered = {}

local function TryPredictBoss(roomDesc)
    if roomDesc then
        local bossID
        local bosses
        if StageAPI.CurrentStage and StageAPI.CurrentStage.Bosses then
	    bosses = StageAPI.CurrentStage.Bosses
        else
	    bosses = StageAPI.GetBaseFloorInfo(shared.Level:GetAbsoluteStage(), shared.Level:GetStageType(), false)
            if not bosses.Bosses then return 
            else
                 bosses = bosses.Bosses
            end 
        end
        local roomSubtype = roomDesc.Data.Subtype
        local isHorsemanRoom = StageAPI.IsIn(horsemanRoomSubtypes, roomSubtype)

        local floatWeights
        local totalUnencounteredWeight = 0
        local totalValidWeight = 0
        local totalForcedWeight = 0
        local unencounteredBosses = {}
        local validBosses = {}
        local forcedBosses = {}
        local pool = bosses.Pool or bosses
        for _, potentialBossID in ipairs(pool) do
            local poolEntry
            if type(potentialBossID) == "table" then
                poolEntry = potentialBossID
                potentialBossID = poolEntry.BossID
            else
                poolEntry = {
                    BossID = potentialBossID
                }
            end

            local potentialBoss = StageAPI.GetBossData(potentialBossID)
            local encountered = StageAPI.GetBossEncountered(potentialBoss.Name) or BossEncountered[potentialBossID]
            if not encountered and potentialBoss.NameTwo then
                encountered = StageAPI.GetBossEncountered(potentialBoss.NameTwo)
            end

            local weight = poolEntry.Weight or potentialBoss.Weight or 1
            local forced
            local invalid
            if potentialBoss.Rooms then
                local validRooms, validRoomWeights = StageAPI.GetValidRoomsForLayout{
                    RoomList = potentialBoss.Rooms,
                    RoomDescriptor = roomDesc
                }

                if #validRooms == 0 or validRoomWeights == 0 then
                    invalid = true
                end
            end

            if not invalid then
                if isHorsemanRoom then
                    if poolEntry.AlwaysReplaceHorsemen or potentialBoss.AlwaysReplaceHorsemen then
                        forced = true
                    elseif poolEntry.TryReplaceHorsemen or potentialBoss.TryReplaceHorsemen then
                        forced = not encountered
                    elseif not (poolEntry.Horseman or potentialBoss.Horseman) then
                        invalid = true
                    end
                elseif poolEntry.OnlyReplaceHorsemen or potentialBoss.OnlyReplaceHorsemen then
                    invalid = true
                end

                if poolEntry.AlwaysReplaceSubtype and not invalid then
                    if roomSubtype == poolEntry.AlwaysReplaceSubtype then
                        forced = true
                    end
                elseif poolEntry.TryReplaceSubtype and not invalid then
                    if roomSubtype == poolEntry.TryReplaceSubtype then
                        forced = not encountered
                    end
                end

                if poolEntry.OnlyReplaceSubtype and not invalid then
                    if roomSubtype ~= poolEntry.OnlyReplaceSubtype then
                        invalid = true
                    end
                end
            end

            if not invalid then
                if forced then
                    totalForcedWeight = totalForcedWeight + weight
                    forcedBosses[#forcedBosses + 1] = {potentialBossID, weight}
                end

                if not encountered then
                    totalUnencounteredWeight = totalUnencounteredWeight + weight
                    unencounteredBosses[#unencounteredBosses + 1] = {potentialBossID, weight}
                end

                totalValidWeight = totalValidWeight + weight
                validBosses[#validBosses + 1] = {potentialBossID, weight}
            end

            if weight % 1 ~= 0 then
                floatWeights = true
            end
        end

        local rng = StageAPI.BossSelectRNG
        rng:SetSeed(roomDesc.SpawnSeed, 0)

        if #forcedBosses > 0 then
            bossID = StageAPI.WeightedRNG(forcedBosses, rng, nil, totalForcedWeight, floatWeights)
        elseif #unencounteredBosses > 0 then
            bossID = StageAPI.WeightedRNG(unencounteredBosses, rng, nil, totalUnencounteredWeight, floatWeights)
        elseif #validBosses > 0 then
            bossID = StageAPI.WeightedRNG(validBosses, rng, nil, totalValidWeight, floatWeights)
        end
	if bossID then
	    BossEncountered[bossID] = true
        end

        return bossID
    end
end

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
		local spr = Sprite() --stageapi/transition/nightmare_bg.anm2
		spr:Load("gfx/ui/stage/nightmare_bg.anm2",true)
		spr:Play("Intro",true)
		return spr
	else
		anm:Load("gfx/ui/stage/nightmare_bg.anm2",true)
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
	{ModCallbacks.MC_FAMILIAR_UPDATE , function(_,npc)  --FamiliarBlock --Blood Oath fix
			npc:GetSprite():SetFrame(0)
			npc.Velocity = Vector(0,0)
		end, },
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

gfxTabl.ItemsDeathPortrait = {}

gfxTabl.DreamCatcherSprites = {}

gfxTabl.DreamCatcherItemType = 1 

gfxTabl.DreamCatcher1ItemPos = {[29]=Vector(-5,-32),[33]=Vector(-5,-33),[37]=Vector(-5,-32),[41]=Vector(-5,-33),
	[45]=Vector(-5,-32),[49]=Vector(-5,-33),[53]=Vector(-5,-32),[57]=Vector(-5,-33),[61]=Vector(-5,-32),[65]=Vector(-5,-33),}
gfxTabl.DreamCatcher2ItemPos = {[29]=Vector(24,-32),[33]=Vector(24,-33),[37]=Vector(24,-32),[41]=Vector(24,-33),
	[45]=Vector(24,-32),[49]=Vector(24,-33),[53]=Vector(24,-32),[57]=Vector(24,-33),[61]=Vector(24,-32),[65]=Vector(24,-33),}

gfxTabl.DreamCatcherItemPos = {
		[0]=Vector(5,-21),[2]=Vector(5,-20.5),[5]=Vector(5,-20),[10]=Vector(5,-20.5),[11]=Vector(5,-21)
	}
gfxTabl.DreamCatcherBossPos = {[0]={Vector(100,-48),0,1.1}, [1]={Vector(90,-48),0.25,1.13}, [2]={Vector(80,-48),0.5,1.15}, [3]={Vector(70,-48),0.75,1.17}, [4]={Vector(60,-48),1,1.2},
		[5]={Vector(57,-48),1,1.0}, [6]={Vector(55,-48),1,0.8}, [8]={Vector(55,-48),1,1.0}, [64]={Vector(45,-48),1,1.0},
	}

gfxTabl.DreamCatcherBossPosNew = {
	{0,Vector(100,-48),Vector(1.1,0.9),Color(1,1,1,0),true},
	{1,Vector(90,-48),Vector(1.13,0.87),Color(1,1,1,0.25),true},
	{2,Vector(80,-48),Vector(1.15,0.85),Color(1,1,1,0.5),true},
	{3,Vector(70,-48),Vector(1.17,0.83),Color(1,1,1,0.75),true},
	{4,Vector(60,-48),Vector(1.2,0.8),Color(1,1,1,1.0),true},
	{5,Vector(57,-48),Vector(1.0,1.0),Color(1,1,1,1.0),true},
	{6,Vector(55,-48),Vector(0.8,1.2),Color(1,1,1,1.0),true},
	{8,Vector(55,-48),Vector(1.0,1.0),Color(1,1,1,1.0),true},
	{64,Vector(45,-48),Vector(1.0,1.0),Color(1,1,1,1.0),true},
	{68,Vector(45,-48),Vector(1.0,1.0),Color(1,1,1,-1.0),true},
}
gfxTabl.DreamCatcherBossPosBestiary = {
	{0,Vector(121,-48-30),Vector(1.1,0.9),Color(1,1,1,0),true},
	{1,Vector(111,-48-30),Vector(1.13,0.87),Color(1,1,1,0.25),true},
	{2,Vector(101,-48-30),Vector(1.15,0.85),Color(1,1,1,0.5),true},
	{3,Vector(70+21,-48-30),Vector(1.17,0.83),Color(1,1,1,0.75),true},
	{4,Vector(60+21,-48-30),Vector(1.2,0.8),Color(1,1,1,1.0),true},
	{5,Vector(57+21,-48-30),Vector(1.0,1.0),Color(1,1,1,1.0),true},
	{6,Vector(55+21,-48-30),Vector(0.8,1.2),Color(1,1,1,1.0),true},
	{8,Vector(55+21,-48-30),Vector(1.0,1.0),Color(1,1,1,1.0),true},
	{64,Vector(45+21,-48-30),Vector(1.0,1.0),Color(1,1,1,1.0),true},
	{68,Vector(45+21,-48-30),Vector(1.0,1.0),Color(1,1,1,-1.0),true},
}
gfxTabl.DreamCatcherBossPosName = {
	{0,Vector(100-48,-48+32),Vector(0.55,0.45),Color(1,1,1,0),true},
	{1,Vector(90-48,-48+32),Vector(0.565,0.435),Color(1,1,1,0.25),true},
	{2,Vector(80-48,-48+32),Vector(0.575,0.425),Color(1,1,1,0.5),true},
	{3,Vector(70-48,-48+32),Vector(0.585,0.415),Color(1,1,1,0.75),true},
	{4,Vector(60-48,-48+32),Vector(0.6,0.4),Color(1,1,1,1.0),true},
	{5,Vector(57-48,-48+32),Vector(0.5,0.5),Color(1,1,1,1.0),true},
	{6,Vector(55-48,-48+32),Vector(0.4,0.6),Color(1,1,1,1.0),true},
	{8,Vector(55-48,-48+32),Vector(0.5,0.5),Color(1,1,1,1.0),true},
	{64,Vector(45-48,-48+32),Vector(0.5,0.5),Color(1,1,1,1.0),true},
	{68,Vector(45-48,-48+32),Vector(0.5,0.5),Color(1,1,1,-1.0),true},
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

gfxTabl.DreamCatcherScenes = {}
gfxTabl.DreamCatcherRoomReplace = {}

local function SetDreamCatcherBoss(bossID)
	local bossData 
	if type(bossID) == "table" then
		bossData = bossID
	else
		bossData = StageAPI.GetBossData(bossID)
	end

	local spr = Sprite()
	local tablPos = gfxTabl.DreamCatcherBossPosName
	if bossData.BestiaryIcon then
		spr = bossData.BestiaryIcon[1]
		spr:Play(spr:GetDefaultAnimation())
		spr:SetFrame(bossData.BestiaryIcon[2])
		tablPos = gfxTabl.DreamCatcherBossPosBestiary
	elseif bossData.Bossname then
		spr:Load('gfx/ui/boss/versusscreen.anm2',false)
		spr:Play(spr:GetDefaultAnimation())
		for l=0,14 do
			if l~=7 then
				spr:ReplaceSpritesheet(l,"stageapi/none.png")
			end
		end
		spr:ReplaceSpritesheet(7,bossData.Bossname)
		spr:SetFrame(37)
		spr.Offset = Vector(-117,94)
		spr:LoadGraphics(true)  
		tablPos = gfxTabl.DreamCatcherBossPosName
	end
	return spr,tablPos
end

function gfxTabl.DreamCatcherCheck()
	gfxTabl.DreamCatcherScenes = {}
	gfxTabl.DreamCatcherRoomReplace = {}
	BossEncountered = {}

	local check = false
	local TwoItem = false
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

		local pool = Game():GetItemPool()
		local seed = Game():GetSeeds():GetStartSeed()
		
		local level = Game():GetLevel()
		local RoomsTable = level:GetRooms()

		local bossroomlist = {}
		gfxTabl.DreamCatcherItemType = -1
		local blacklist = {}
		for i=0,168 do
		   roomdesc = level:GetRoomByIdx(i,0)
	   	   if roomdesc and roomdesc.Data and not blacklist[roomdesc.SafeGridIndex] then 
			blacklist[roomdesc.SafeGridIndex] = true

		   	local roomdata = roomdesc.Data 
			
		   	if roomdata and roomdata.Type == RoomType.ROOM_TREASURE then
				local spawnlist = roomdata.Spawns
				local itemcount = 0
				for j=0,#spawnlist-1 do
					local spawnEntry = spawnlist:Get(j)
					for i=0,#spawnEntry.Entries - 1 do
						local entr = spawnEntry.Entries:Get(i)
						
						if entr.Type == 5 and entr.Variant == 100 then
							itemcount = itemcount + 1
						end
					end
				end
				if TwoItem then 
					itemcount = 2
				end  

				local rng = RNG()
				rng:SetSeed(roomdesc.SpawnSeed, 35)
				local I1 = pool:GetCollectible(ItemPoolType.POOL_TREASURE,false,rng:GetSeed(),CollectibleType.COLLECTIBLE_NULL)
				rng:Next()
				local I2 = pool:GetCollectible(ItemPoolType.POOL_TREASURE,false,rng:GetSeed(),CollectibleType.COLLECTIBLE_NULL)
				local S1,S2 = Sprite(),Sprite()
				if itemcount > 0 then
					if StageAPI.GetItemDeathPortrait(I1) then
						S1 = StageAPI.GetItemDeathPortrait(I1)
						--S1.Offset = Vector(0,10)
					else
						S1:Load("gfx/ui/death screen.anm2",true)
						S1:Play(S1:GetDefaultAnimation())
						for g=0,8 do
							if g~=6 then
								S1:ReplaceSpritesheet(g,"stageapi/none.png")
							end
						end
						S1.Offset = Vector(84,-20)
						S1:LoadGraphics(true)
						S1:SetFrame(I1 and (I1-1>731 and 669 or I1-1))
					end
					local GreyColor = Color(1, 1, 1, 1)
					GreyColor:SetColorize(1, 1, 1, 1)
					S1.Color = GreyColor
				end
				if itemcount > 1 then
					if StageAPI.GetItemDeathPortrait(I2) then
						S2 = StageAPI.GetItemDeathPortrait(I2)
					else
						S2:Load("gfx/ui/death screen.anm2",true)
						S2:Play(S2:GetDefaultAnimation())
						for g=0,8 do
							if g~=6 then
								S2:ReplaceSpritesheet(g,"stageapi/none.png")
							end
						end
						S2.Offset = Vector(84,-20)
						S2:LoadGraphics(true)
						S2:SetFrame(I2 and (I2-1>731 and 669 or I2-1))
					end
					local GreyColor = Color(1, 1, 1, 1)
					GreyColor:SetColorize(1, 1, 1, 1)
					S2.Color = GreyColor
				end

				gfxTabl.DreamCatcherScenes[#gfxTabl.DreamCatcherScenes+1] = {
					SceneType = itemcount > 1 and "TreasureRoomDouble" or itemcount > 0 and "TreasureRoom" or "TreasureRoomPoop",
					Index = roomdesc.SafeGridIndex,   
					num = itemcount,
					ItemType = itemcount < 3 and itemcount or 2,
					Item1 = S1,
					Item2 = S2,
				}
				gfxTabl.DreamCatcherRoomReplace[roomdesc.SafeGridIndex] = {  
					(itemcount > 0 and I1 or nil),
					(itemcount > 1 and I2 or nil), 
					hash = GetPtrHash(roomdesc),
				}
				gfxTabl.DreamCatcherRoomReplace.num = gfxTabl.DreamCatcherRoomReplace.num and gfxTabl.DreamCatcherRoomReplace.num+1 or 1
				
			elseif roomdata.Type == RoomType.ROOM_BOSS then
				bossroomlist[#bossroomlist+1] = roomdesc
			end
		   end
		end

		for i,p in pairs(bossroomlist) do
			local num = #gfxTabl.DreamCatcherScenes+1
			gfxTabl.DreamCatcherScenes[num] = {
				SceneType = "Boss",
				Index = p.SafeGridIndex, 
				bossSubType = p.Data.Subtype,
			}
			local bossID = TryPredictBoss(p)
			local bossData = StageAPI.GetBossData(bossID)
			
			if bossData and not bossData.BaseGameBoss then
				gfxTabl.DreamCatcherScenes[num].Sprite,gfxTabl.DreamCatcherScenes[num].PosTabl = SetDreamCatcherBoss(bossID)
				gfxTabl.DreamCatcherScenes[num].Frame = gfxTabl.DreamCatcherScenes[num].Sprite:GetFrame()
			else
				local S1 = Sprite()
				S1:Load("gfx/ui/death screen.anm2",true)
				S1:Play(S1:GetDefaultAnimation())
				for g=0,8 do
					if g~=3 then
						S1:ReplaceSpritesheet(g,"stageapi/none.png")
					end
				end
				S1.Offset = Vector(84,-10)
				S1:LoadGraphics(true)
				S1:SetFrame(p.Data.Subtype and tonumber(gfxTabl.BossDeathPortrait[p.Data.Subtype]) or 0)
				gfxTabl.DreamCatcherScenes[num].Sprite = S1
				gfxTabl.DreamCatcherScenes[num].Frame = S1:GetFrame()
			end
		end
	end
	return check
end

local function InterpolateAnim(anm,frame,animTabl)
    if anm and frame and animTabl then
        local startdata,enddata
        for i,data in ipairs(animTabl) do
            if frame<data[1] then
                startdata,enddata = animTabl[i-1],data
                break
            end
        end
        if startdata and enddata then
            if enddata[5] then
                local procent = (frame-startdata[1])/(enddata[1]-startdata[1])
                local offset = startdata[2]+(enddata[2]-startdata[2])*procent
                local scale = startdata[3]+(enddata[3]-startdata[3])*procent
                local color = Color(
	            startdata[4].R+(enddata[4].R-startdata[4].R)*procent,
                    startdata[4].G+(enddata[4].G-startdata[4].G)*procent,
                    startdata[4].B+(enddata[4].B-startdata[4].B)*procent,
                    startdata[4].A+(enddata[4].A-startdata[4].A)*procent)
                anm.Offset = offset
                anm.Scale = scale
                anm.Color = color
            else
                anm.Offset = startdata[2]
                anm.Scale = startdata[3]
                anm.Color = startdata[4]
            end
        end
    end
end

local CTGfx = gfxTabl
local TRData = {}

TRData.DontAddStage = false

TRData.Nightmare_bg = CTGfx.Nightmare_bg()
TRData.BlackCube = CTGfx.BlackNotCube

TRData.NightmareAnm = Sprite()

TRData.PlayerExtra = Sprite()

local bg_RenderPos = Vector(240,135)  
local nm_RenderPos = Vector(240,20)
local Render_Extra_Offset = Vector(-72,-19)

local ProgressAnm = {}

TRData.BlueWomb = CTGfx.StartBlueWomb 
TRData.StageProgNum = CTGfx.StartStageNum
TRData.CurrentStage = CTGfx.StartCurrentStage 
TRData.NextStageID = 2
TRData.NextStage = "2"
TRData.MusikID = 0
TRData.Stages = {}
--local FakeStages = {}
--local OffsetStages = {}
TRData.Nightmare = nil
TRData.PlSpot = nil
TRData.DontReplacePlSpot = nil
TRData.PlayerGfx = nil
TRData.Sdelay = 0
TRData.RenderFrame = 0
TRData.StartDisap = nil
TRData.ExtraFrame = CTGfx.PlayersExtraFrame
local MusicOnPause = false
local DreamCatcher = false
local OnlyAnim = false

local DefaultTransitionMusik = Music.MUSIC_JINGLE_NIGHTMARE
local TransitionMusik = DefaultTransitionMusik

TRData.ShaderState = 0
local PIxelAmonStart = 0.002
local PIxelAmon = PIxelAmonStart
local IsOddRenderFrame = false

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
	if IsOddRenderFrame then
		TRData.Nightmare_bg:Update()

		if TRData.Nightmare_bg:IsFinished("Intro") then
			TRData.Nightmare_bg:Play("Loop",true)
		elseif TRData.Nightmare_bg:IsPlaying("Loop") then
			if TRData.NightmareAnm:GetFrame() == 0 then
				TRData.NightmareAnm:SetLastFrame()
				NightmareFrameCount = TRData.NightmareAnm:GetFrame()
				TRData.NightmareAnm:SetFrame(0)
			end
			TRData.NightmareAnm:Update()
		end
		if NightmareFrameCount and TRData.NightmareAnm:GetFrame() >= NightmareFrameCount-20  or 
		TRData.NightmareAnm:IsFinished("Scene") then
			if TRData.BlackCube.Color.A >= 2.0 then
				TRData.StartDisap = true
			end  
			TRData.BlackCube.Color = Color(1,1,1,TRData.BlackCube.Color.A+0.05)
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
	if IsOddRenderFrame then
		TRData.Nightmare_bg:Update()

		if TRData.Nightmare_bg:IsFinished("Intro") then
			TRData.Nightmare_bg:Play("Loop",true)
		elseif TRData.Nightmare_bg:IsPlaying("Loop") then
			TRData.NightmareAnm:Update()
		end
		
		if TRData.NightmareAnm:IsFinished("Scene") then
			DCSprite.nightmare:Update()
			
			if not NightmareFrameCount and DCSprite.State == #CTGfx.DreamCatcherScenes then
				DCSprite.nightmare:SetLastFrame()
				NightmareFrameCount = TRData.NightmareAnm:GetFrame()
				DCSprite.nightmare:SetFrame(0)
			end

			local currentScene = CTGfx.DreamCatcherScenes[DCSprite.State]
			
			if currentScene and CTGfx.DreamCatcherScenes[DCSprite.State+1]
			or (currentScene and NightmareFrameCount and DCSprite.nightmare:GetFrame() <= NightmareFrameCount-20) then 
			   
			    if currentScene.SceneType == "Boss" then 
				local postabl = currentScene.PosTabl or CTGfx.DreamCatcherBossPosNew
				InterpolateAnim(currentScene.Sprite,DCSprite.nightmare:GetFrame(),postabl)
				local GreyColor = Color(1, 1, 1, currentScene.Sprite.Color.A)
				GreyColor:SetColorize(1, 1, 1, 1)
				currentScene.Sprite.Color = GreyColor

				if DCSprite.nightmare:IsFinished(currentScene.SceneType) then

					DCSprite.State = DCSprite.State+1

					if CTGfx.DreamCatcherScenes[DCSprite.State] then
						local curScene = CTGfx.DreamCatcherScenes[DCSprite.State]
						if curScene.Sprite then
							if curScene.Frame then
								curScene.Sprite:SetFrame(curScene.Frame)
							end
							curScene.Sprite.Color = Color(1,1,1,0.0)
						end
						DCSprite.nightmare:Play(curScene.SceneType,true)
					end
				end
			    else
				if DCSprite.nightmare:GetFrame() == 64 then
					currentScene.Item1.Color = Color(1,1,1,0.5)
					currentScene.Item2.Color = Color(1,1,1,0.5)
				elseif DCSprite.nightmare:GetFrame() >= 65 then
					DCSprite.State = DCSprite.State+1
					if CTGfx.DreamCatcherScenes[DCSprite.State] then
						local curScene = CTGfx.DreamCatcherScenes[DCSprite.State]
						if curScene.Sprite then
							if curScene.Frame then
								curScene.Sprite:SetFrame(curScene.Frame)
							end
							curScene.Sprite.Color = Color(1,1,1,0.0)
						end
						DCSprite.nightmare:Play(curScene.SceneType,true)
					else
						if TRData.BlackCube.Color.A >= 2.0 then
							TRData.StartDisap = true
						end  
						TRData.BlackCube.Color = Color(1,1,1,TRData.BlackCube.Color.A+0.05)
					end
				end
			    end
			else
				if CTGfx.DreamCatcherScenes[DCSprite.State] and CTGfx.DreamCatcherScenes[DCSprite.State].SceneType == "Boss"  then 
				  
					local currentScene = CTGfx.DreamCatcherScenes[DCSprite.State]
					local postabl = currentScene.PosTabl or CTGfx.DreamCatcherBossPosNew
					InterpolateAnim(currentScene.Sprite,DCSprite.nightmare:GetFrame(),postabl)
					local GreyColor = Color(1, 1, 1, currentScene.Sprite.Color.A)
					GreyColor:SetColorize(1, 1, 1, 1)
					currentScene.Sprite.Color = GreyColor
				elseif CTGfx.DreamCatcherScenes[DCSprite.State-1] and CTGfx.DreamCatcherScenes[DCSprite.State-1].SceneType == "Boss" then
				  
					local currentScene = CTGfx.DreamCatcherScenes[DCSprite.State-1]
					local postabl = currentScene.PosTabl or CTGfx.DreamCatcherBossPosNew
					InterpolateAnim(currentScene.Sprite,DCSprite.nightmare:GetFrame(),postabl)
					local GreyColor = Color(1, 1, 1, currentScene.Sprite.Color.A)
					GreyColor:SetColorize(1, 1, 1, 1)
					currentScene.Sprite.Color = GreyColor
				end
				if TRData.BlackCube.Color.A >= 2.0 then
					TRData.StartDisap = true
				end  
				TRData.BlackCube.Color = Color(1,1,1,TRData.BlackCube.Color.A+0.05)
			end
		end
	end
	if TRData.NightmareAnm:IsFinished("Scene") then
		local Ioffset = CTGfx.DreamCatcherItemPos
		local Ioffset1 = CTGfx.DreamCatcher1ItemPos
		local Ioffset2 = CTGfx.DreamCatcher2ItemPos
		local Boffset = CTGfx.DreamCatcherBossPos

		DCSprite.nightmare:Render(bg_RenderPos)
		local currentScene = CTGfx.DreamCatcherScenes[DCSprite.State]

		if currentScene then
		    if currentScene.SceneType ~= "Boss" and DCSprite.nightmare:GetFrame() >= 29 then
			local frame = DCSprite.nightmare:GetFrame()
			if currentScene.SceneType == "TreasureRoomDouble" then  
				DCSprite.item1Offset = Vector(Ioffset1[29] and Ioffset1[29].X or DCSprite.item1Offset.X,Ioffset[(frame-29)%12] and Ioffset[(frame-29)%12].Y or DCSprite.item1Offset.Y)
				DCSprite.item2Offset = Vector(Ioffset2[29] and Ioffset2[29].X or DCSprite.item2Offset.X,Ioffset[(frame-29)%12] and Ioffset[(frame-29)%12].Y or DCSprite.item2Offset.Y)

				currentScene.Item1:Render(bg_RenderPos+DCSprite.item1Offset)
				currentScene.Item2:Render(bg_RenderPos+DCSprite.item2Offset)
			elseif currentScene.SceneType == "TreasureRoom" then  
				DCSprite.item1Offset = Ioffset[(frame-29)%12] or DCSprite.item1Offset

				currentScene.Item1:Render(bg_RenderPos+DCSprite.item1Offset)
			end
		    elseif currentScene.SceneType == "Boss" then
			DCSprite.nightmare:Render(bg_RenderPos)
			local frame = DCSprite.nightmare:GetFrame()
			
			if frame < 8 then
				local Offset = Vector(0,28) 
				currentScene.Sprite:Render(bg_RenderPos+Offset*1.54)
			elseif frame >= 8 then
				local RenderPos = Vector(0,29)  
				currentScene.Sprite:Render(bg_RenderPos+RenderPos*1.54)
			end
		    end
		elseif CTGfx.DreamCatcherScenes[DCSprite.State-1] then
			local currentScene = CTGfx.DreamCatcherScenes[DCSprite.State-1]
			if currentScene.SceneType == "Boss" then
				local RenderPos = Vector(0,28) 
				currentScene.Sprite:Render(bg_RenderPos+RenderPos*1.54)
			end
		end
	end
end

local function DreamCatcherItemReplace() --Instead of predicting the next items, the code overrides them
	local RoomDesc = shared.Level:GetCurrentRoomDesc()
	local RoomData = RoomDesc.Data	

	if RoomData and RoomData.Type and RoomData.Type == RoomType.ROOM_TREASURE
	and CTGfx.DreamCatcherRoomReplace[RoomDesc.SafeGridIndex] 
	and CTGfx.DreamCatcherRoomReplace[RoomDesc.SafeGridIndex].hash == GetPtrHash(RoomDesc)
	and shared.Room:IsFirstVisit() then
		local items = CTGfx.DreamCatcherRoomReplace[RoomDesc.SafeGridIndex]
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

		if not CantReplace and num == #items then 
			for i,e in pairs(Isaac.FindByType(5,100,-1,false,false)) do
				if items[i] then
					print("[StageAPI]: Item has been replaced, original ID =",e.SubType)
					e:ToPickup():Morph(5,100,items[i] or e.SubType,false,true,false)
				end
			end
		end
		if CTGfx.DreamCatcherRoomReplace.num <= 0 then
			mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, DreamCatcherItemReplace)
			DCSprite.ItemCallbackActivated = false
		end
	end
end

local function TransitionRender(_, name)
	TRData.RenderFrame = TRData.RenderFrame+1
	for _, player in ipairs(shared.Players) do
		player.ControlsCooldown = math.max(player.ControlsCooldown,80)
	end

	TRData.Nightmare_bg:Render(bg_RenderPos,Vector.Zero,Vector.Zero)

	if StageAPI.PlayerBossInfo[shared.Players[1]:GetPlayerType()].ExtraPortrait then
		if not TRData.PlayerGfx.NoShake then
			TRData.PlayerExtra.Offset = CTGfx.ExtraAnmOffset[TRData.ExtraFrame]
		end
		TRData.PlayerExtra:Render(bg_RenderPos+Render_Extra_Offset)
		TRData.PlayerExtra.Color = not (TRData.Nightmare_bg:IsPlaying("Intro") and TRData.Nightmare_bg:GetFrame()<=19) and TRData.Nightmare_bg.Color or TRData.PlayerExtra.Color
		
		if IsOddRenderFrame then
			TRData.PlayerExtra:Update()
			TRData.ExtraFrame = TRData.ExtraFrame + 1
			if TRData.ExtraFrame >= 5 then TRData.ExtraFrame = 1 end
		end
		if TRData.Nightmare_bg:IsPlaying("Intro") and TRData.Nightmare_bg:GetFrame()<=18 then
			TRData.PlayerExtra.Color = CTGfx.ExtraAnmColor[TRData.Nightmare_bg:GetFrame()+2]
		end
	end
	TRData.NightmareAnm:Render(bg_RenderPos,Vector.Zero,Vector.Zero)

	if not DreamCatcher then
		StandartNightmare()
	else
		DreamCatcherNightmare()
	end
	
	if ProgressAnm and #ProgressAnm>0 then
		if IsOddRenderFrame then
					
			if not MusicOnPause and MusicManager():GetCurrentMusicID() ~= TransitionMusik then
				MusicOnPause = true
				MusicManager():Pause()
			end

			ProgressAnm.IsaacIndicator:Update()

			if TRData.Nightmare_bg:IsPlaying("Loop") and ProgressAnm.IsaacIndicatorPos:Distance(ProgressAnm.IsaacIndicatorNextPos) > 1 then
				local Ang = (ProgressAnm.IsaacIndicatorNextPos-ProgressAnm.IsaacIndicatorPos):GetAngleDegrees()
				local Nextpos = Vector.FromAngle(Ang):Resized(ProgressAnm.IsaacIndicatorMovSpeed)
				ProgressAnm.IsaacIndicatorPos = ProgressAnm.IsaacIndicatorPos+Nextpos
			elseif TRData.Nightmare_bg:IsPlaying("Intro") and ProgressAnm.IsaacIndicator.Color.R < 1 then
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
				if IsOddRenderFrame then
					if TRData.Nightmare_bg:IsPlaying("Intro") and k.spr.Color.R < 1 then
						k.spr.Color = Color(k.spr.Color.R+0.05, k.spr.Color.G+0.05, k.spr.Color.B+0.05, 1)
					end
				end
			end
		end
		if shared.Game.TimeCounter < shared.Game.BossRushParTime then
			ProgressAnm.Clock:Render(ProgressAnm.ClockPos)
		end
		if TRData.StageProgNum<10 then
			ProgressAnm.BossIndicator:Render(ProgressAnm.BossIndicatorPos)
		end
		ProgressAnm.IsaacIndicator:Render(ProgressAnm.IsaacIndicatorPos)
	end

	TRData.BlackCube:Render(bg_RenderPos)

	if  (Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, shared.Players[1].ControllerIndex) or 
	Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, shared.Players[1].ControllerIndex)) then
		TRData.StartDisap = true
	end

	if TRData.StartDisap then
		TRData.Nightmare_bg.Color = Color(1,1,1,1)
		TRData.NightmareAnm.Color = Color(1,1,1,1)

		if TRData.MusikID then
			shared.Music:Play(TRData.MusikID,Options.MusicVolume)
		end
		MusicOnPause = false
		TransitionMusik = DefaultTransitionMusik

		shared.Game:GetHUD():SetVisible(true)

		TRData.ExtraFrame = CTGfx.PlayersExtraFrame
		TRData.ShaderState = 3
		TRData.RenderFrame = 0
		
		--BlockCallbacks(true)
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

		for i=TRData.StageProgNum,1,-1 do
			if i>OriginalId+StageOffset then
				TRData.Stages[i+1] = TRData.Stages[i]
			end
		end

		TRData.Stages[OriginalId+StageOffset] = {frame = frame,IsSecond = (OriginalId)%2==0 and OriginalId<9}
	end
end]]


function self.AddDefaultProgressStage()
	if not TRData.DontAddStage then
		local level = shared.Level
		local StageI = level:GetAbsoluteStage()
		
		if not TRData.BlueWomb and ( level:GetAbsoluteStage() == LevelStage.STAGE4_3 or
		((level:GetAbsoluteStage() == LevelStage.STAGE4_1 or level:GetAbsoluteStage() == LevelStage.STAGE4_2)
		and level:GetStageType()>=4)) then
			TRData.BlueWomb = true
		end
	
		--local StageOffset = calcStageOffset(StageI)

		if level:GetStageType()>=4 and StageI<9 then
			TRData.Stages[StageI+1] = { frame = CTGfx.StageIcons[StageI][level:GetStageType()], IsSecond = (StageI)%2==0}
		else
			TRData.Stages[StageI] = {frame = CTGfx.StageIcons[StageI][level:GetStageType()],IsSecond = (StageI)%2==0 and StageI<9}
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
		TRData.PlayerGfx = StageAPI.PlayerBossInfo[player:GetPlayerType()]
	else
		TRData.PlayerGfx = StageAPI.PlayerBossInfo[0]
	end

	if not TRData.DontReplacePlSpot then
		TRData.PlSpot = CTGfx.BossSpots[level:GetAbsoluteStage()][level:GetStageType()]
		TRData.Nightmare_bg:ReplaceSpritesheet(3,TRData.PlSpot)
	else
		TRData.DontReplacePlSpot = nil
	end	

	if not TRData.PlayerGfx.NoShake then
		TRData.Nightmare_bg:ReplaceSpritesheet(2,TRData.PlayerGfx.Portrait)
		TRData.Nightmare_bg:ReplaceSpritesheet(6,"stageapi/none.png")
	else
		TRData.Nightmare_bg:ReplaceSpritesheet(6,TRData.PlayerGfx.Portrait)
		TRData.Nightmare_bg:ReplaceSpritesheet(2,"stageapi/none.png")
	end
	TRData.Nightmare_bg:Play("Intro",true)

	if TRData.PlayerGfx.ExtraPortrait then
		if type(TRData.PlayerGfx.ExtraPortrait) == 'table' then
			TRData.PlayerExtra:Load(TRData.PlayerGfx.ExtraPortrait[1],true)
			if TRData.PlayerGfx.ExtraPortrait[2] then
				TRData.Nightmare_bg:ReplaceSpritesheet(6,"stageapi/none.png")
				TRData.Nightmare_bg:ReplaceSpritesheet(2,"stageapi/none.png")
			end
		else
			TRData.PlayerExtra:Load(TRData.PlayerGfx.ExtraPortrait,true)
		end
		TRData.PlayerExtra:Play(TRData.PlayerExtra:GetDefaultAnimation(),true)
		TRData.PlayerExtra.Color = Color(0,0,0,1) 
	end

	TRData.Nightmare_bg:LoadGraphics(true)

	TRData.Nightmare = StageAPI.TransitionNightmaresList[math.random(1,#StageAPI.TransitionNightmaresList)]
	TRData.NightmareAnm:Load(TRData.Nightmare,true)
	TRData.NightmareAnm:Play("Scene",true)
	
	TRData.StartDisap = false
	TRData.ExtraFrame = 1

	if CTGfx.StageMusicID[level:GetAbsoluteStage()] and CTGfx.StageMusicID[level:GetAbsoluteStage()][level:GetStageType()] then
		TRData.MusikID = CTGfx.StageMusicID[level:GetAbsoluteStage()][level:GetStageType()]
	else
		TRData.MusikID = nil	
	end
	if StageAPI.NextStage and StageAPI.NextStage.Music and StageAPI.NextStage.Music[1] then
		TRData.MusikID = StageAPI.NextStage.Music[1]
	end

	TRData.ShaderState = 2
	local PIxelAmon = PIxelAmonStart

	local queue = shared.Music:GetCurrentMusicID()

	local Musik = TransitionMusik or DefaultTransitionMusik
	shared.Music:Play(Musik,Options.MusicVolume)

	NightmareFrameCount = nil

	if DreamCatcher then
		CTGfx.DreamCatcherSprites.Bubble(TRData.NightmareAnm)
		TRData.NightmareAnm:Play("Scene",true)

		DCSprite.item1.Color = Color.Default
		DCSprite.item2.Color = Color.Default

		if CTGfx.DreamCatcherScenes[1] and CTGfx.DreamCatcherScenes[1].SceneType then
			DCSprite.State = 1
			DCSprite.nightmare:Play(CTGfx.DreamCatcherScenes[1].SceneType,true)
			DCSprite.boss.Offset = Vector(0,250)
			
			if not DCSprite.ItemCallbackActivated then
				mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DreamCatcherItemReplace)
				DCSprite.ItemCallbackActivated = true
			end
		end
	end
	
end

local function GenProgressAnm()
	local ScreenWidth = Isaac.GetScreenWidth()
	bg_RenderPos = Vector(ScreenWidth/2,135)   
	nm_RenderPos = Vector(ScreenWidth/2,20)

	local Num = not TRData.BlueWomb and (TRData.StageProgNum-1) or TRData.StageProgNum+0
	Num = math.max(Num,TRData.StageProgNum-1,8)
	local leght = (Num-1)*26 + Num
	local CenPos = nm_RenderPos.X-leght/2
	local IsaacIndicatorPos	= nm_RenderPos
	local IsaacIndicatorNextPos = nm_RenderPos
	local BossIndicatorPos = nm_RenderPos

	for i=1,TRData.StageProgNum do
		if i ~= 9 or TRData.BlueWomb then 

			local nPos = Vector(CenPos+26*(i-1)+i,nm_RenderPos.Y)

			ProgressAnm[i] = {}
			ProgressAnm[i].pos = nPos
			ProgressAnm[i].spr = Sprite()
			ProgressAnm[i].spr.Color = Color(0,0,0,1)
			ProgressAnm[i].spr:Load("stageapi/transition/progress.anm2",true)
			ProgressAnm[i].ID = i
			if not TRData.Stages[i] then
				ProgressAnm[i].spr:Play("NotClearFloor",true)
				if i <= TRData.NextStageID then
					ProgressAnm[i].spr:SetFrame(1)
				else
					ProgressAnm[i].spr:SetFrame(0)
				end
			elseif TRData.Stages[i] then
				ProgressAnm[i].spr:Play("Levels",true)

				if TRData.Stages[i].frame then
					ProgressAnm[i].spr:SetLayerFrame(0,TRData.Stages[i].frame)
				elseif TRData.Stages[i].custom then
					ProgressAnm[i].spr:SetLayerFrame(0,28)
					ProgressAnm[i].spr:ReplaceSpritesheet(4, TRData.Stages[i].custom)
					ProgressAnm[i].spr:LoadGraphics()
				end

				if i < TRData.NextStageID then 
					ProgressAnm[i].spr:SetLayerFrame(3,1)
					if i == TRData.CurrentStage then
						IsaacIndicatorPos = nPos
					end
				else
					ProgressAnm[i].spr:SetLayerFrame(3,0)
				end
				if i == TRData.CurrentStage then
					IsaacIndicatorPos = nPos
				end
				if i == TRData.NextStageID then
					IsaacIndicatorNextPos = nPos
					if TRData.NextStage:find("c") or TRData.NextStage:find("d") then    
						IsaacIndicatorNextPos = Vector(CenPos+26*(i-1)+i,nm_RenderPos.Y)
					end
				end
			end
			if i>9 and not TRData.BlueWomb then
				local nPos = Vector(CenPos+26*(i-2)+i,nm_RenderPos.Y)
				ProgressAnm[i].pos = nPos
				if i == TRData.CurrentStage then
					IsaacIndicatorPos = nPos
				end
				
				if i == TRData.NextStageID then
					IsaacIndicatorNextPos = nPos
				end
			end
			if i == TRData.StageProgNum then
				local ni = i>9 and not TRData.BlueWomb and 2 or 1
				local BPos = Vector(CenPos+26*(i-ni)+i,nm_RenderPos.Y)
				BossIndicatorPos = BPos
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
		TRData.DontAddStage = true
	end
	local level = shared.Level
	local preId = level:GetAbsoluteStage()
	
	TRData.NextStage = stage
	CTGfx.Nightmare_bg(TRData.Nightmare_bg)

	for _, player in ipairs(shared.Players) do
		player:ThrowHeldEntity(Vector(0,0))
	end
	
	if not TRData.Stages[preId] then
		self.AddDefaultProgressStage()
	end

	local AltOffset = level:GetStageType()>=4 and 1 or 0
	TRData.CurrentStage = preId+AltOffset
	if TRData.CurrentStage == 9 then TRData.BlueWomb = true end

	if (TRData.NextStage:find("8") or TRData.NextStage:find("7")) and (TRData.NextStage:find("c") or TRData.NextStage:find("d")) then
		TRData.BlueWomb = true
	end
	
	local NextId 
	for i=1,2 do
		local IsNum = tonumber(TRData.NextStage:sub(i,i))
		if IsNum then
			NextId = NextId and (NextId .. IsNum) or IsNum
		end
	end
	TRData.NextStageID = tonumber(NextId)
	if TRData.NextStage:find("c") or TRData.NextStage:find("d") then TRData.NextStageID = TRData.NextStageID+1 end 
	
	TRData.StageProgNum = math.max(TRData.StageProgNum,(TRData.BlueWomb and 9 or 8), tonumber(NextId)) 
	TRData.Sdelay = 1

	BlockCallbacks()
end

function self.SetIndicatorPos(CurrentPos,NextPos)
	if CurrentPos then
		TRData.CurrentStage = CurrentPos
	end
	if NextPos then
		TRData.NextStageID = NextPos
		TRData.StageProgNum = math.max(TRData.StageProgNum,TRData.NextStageID)
	end
end

function self.SetStageIcon(stagenum,gfx)
	if type(gfx) == "string" then
		TRData.Stages[stagenum] = {custom = gfx}
	elseif type(gfx) == "number" then
		TRData.Stages[stagenum] = {frame = gfx}
	end
end

function self.SetStageSpot(gfx)
	TRData.DontReplacePlSpot = true
	TRData.Nightmare_bg:ReplaceSpritesheet(3,gfx)
	TRData.Nightmare_bg:LoadGraphics(true)
end

function self.StartTransition(OA)
	TRData.ShaderState = 1
	OnlyAnim = OA
end

function self.IsTransitionPlaying()
	return TRData.ShaderState == 1 or TRData.ShaderState == 2
end

function self.SetTransitionMusic(music)
	if music then
		TransitionMusik = music
	end
end


function StageAPI.SetItemsDeathPortrait(anm,firstItemID,FirstFrame,LastFrame)
	local firstFrame,lastFrame = FirstFrame or 1,LastFrame
 	if anm and type(anm) == 'string' and firstItemID then
		if not lastFrame then
			spr:SetLastFrame()
			lastFrame = spr:GetFrame()
			spr:SetFrame(0)
		end
		for i=firstFrame,lastFrame do
			gfxTabl.ItemsDeathPortrait[firstItemID+i-firstFrame] = {anm,i}
		end
	elseif anm and type(anm) == 'table' and firstItemID then
		for i,e in pairs(anm) do
			if type(i) == 'number' then
				gfxTabl.ItemsDeathPortrait[i+firstItemID-firstFrame] = {anm.anm,e}
			end
		end
	end
end

function StageAPI.GetItemDeathPortrait(ItemID)
	if ItemID and ItemID<732 then
		local spr = Sprite()
		spr:Load("gfx/ui/death screen.anm2",true)
		spr:Play(spr:GetDefaultAnimation())
		for g=0,8 do
			if g~=6 then
				spr:ReplaceSpritesheet(g,"stageapi/none.png")
			end
		end
		spr.Offset = Vector(84,-20)
		spr:LoadGraphics(true)
		spr:SetFrame(ItemID-1)
		return spr
	elseif ItemID and gfxTabl.ItemsDeathPortrait[ItemID] then
		local spr = Sprite()
		spr:Load(gfxTabl.ItemsDeathPortrait[ItemID][1],true)
		spr:Play(spr:GetDefaultAnimation(),true)
		spr:SetFrame(gfxTabl.ItemsDeathPortrait[ItemID][2])
		return spr
	end
end

local function CTAClean(_,NewGame)
	if NewGame == false then
		TRData.CurrentStage = CTGfx.StartCurrentStage 
		TRData.NextStageID = nil
		TRData.NextStage = 2	
		TRData.BlueWomb = CTGfx.StartBlueWomb
		TRData.StageProgNum = CTGfx.StartStageNum
		TRData.Stages = {}
		ProgressAnm = {}

		self.AddDefaultProgressStage()
	end
end


local function RenderTrick()  --very strange way to fix the backdrop in Dark Room
	if TRData.Sdelay > 150 then
		if OnlyAnim ~= true then
			Isaac.ExecuteCommand("stage " .. TRData.NextStage)

			if not TRData.DontAddStage then
				self.AddDefaultProgressStage()
			end
		end
		TRData.DontAddStage = false
		OnlyAnim = false

		GenProgressAnm()
		DreamCatcher = CTGfx.DreamCatcherCheck()
		TransitionActivation()
		
		TRData.BlackCube.Color = Color(1,1,1,0)

		--mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_RENDER,RenderTrick)
		
		if TRData.NextStage == "11" then
			local backdropID = shared.Room:GetBackdropType() 
			shared.Game:ShowHallucination(0,backdropID)
			shared.Sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
		end
	end
end

local function ShaderRender(_, name)
  if name == "StageAPI-TransitionPixelation" then
     IsOddRenderFrame = not IsOddRenderFrame
     local ShaTabl = { PixelAm = 0.005 + PIxelAmon*TRData.Sdelay}
     if TRData.ShaderState == 0 then
	local Tabl = {PixelAm = 0}
	return Tabl
     elseif TRData.ShaderState == 1 then
	if IsOddRenderFrame then
		TRData.Sdelay = TRData.Sdelay+2.6  
	end
	TRData.BlackCube.Color = Color(1,1,1,(PIxelAmonStart*TRData.Sdelay)*3.5)
	TRData.BlackCube:Render(bg_RenderPos) 
	
	if TRData.Sdelay > 150 then
		for _, player in ipairs(shared.Players) do
			player:ThrowHeldEntity(Vector(10,10))
			player.PositionOffset = Vector.Zero
		end
		RenderTrick()
		--mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER,RenderTrick)
		
		local Tabl = {PixelAm = 0}
		return Tabl
	elseif TRData.Sdelay > 145 then
		local Tabl = {PixelAm = 0}
		return Tabl
	else
		return ShaTabl
	end
     elseif TRData.ShaderState == 3 then
	if IsOddRenderFrame then	
		TRData.Sdelay = TRData.Sdelay-2.6
	end
	TRData.BlackCube.Color = Color(1,1,1,(PIxelAmonStart*TRData.Sdelay)*3.5)
	TRData.BlackCube:Render(bg_RenderPos)
	for _, player in ipairs(shared.Players) do
		player.ControlsCooldown = math.max(player.ControlsCooldown,80)

		if not player:IsHoldingItem() then
			player:AnimateAppear()
		end
	end
	if TRData.Sdelay <= 0 then
		BlockCallbacks(true)
		shared.Game:GetHUD():SetVisible(true)
		TRData.ShaderState = 0
	else
		return ShaTabl
	end
     elseif TRData.ShaderState == 2 then
	if TRData.RenderFrame < 2 and MusicManager():GetCurrentMusicID() ~= TransitionMusik then
		shared.Music:Play(TransitionMusik,Options.MusicVolume)
	end

     	TransitionRender()

	local Tabl = {PixelAm = 0}
	return Tabl
     end
  end
end

--mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DreamCatcherItemReplace)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, self.AddDefaultProgressStage)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, CTAClean)
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS,ShaderRender)

return self
