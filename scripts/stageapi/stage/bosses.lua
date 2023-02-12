local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading Boss Handler")

StageAPI.FloorInfo = {}
StageAPI.FloorInfoGreed = {}

local stageToGreed = {
    [LevelStage.STAGE1_1] = LevelStage.STAGE1_GREED,
    [LevelStage.STAGE2_1] = LevelStage.STAGE2_GREED,
    [LevelStage.STAGE3_1] = LevelStage.STAGE3_GREED,
    [LevelStage.STAGE4_1] = LevelStage.STAGE4_GREED,
}

local stageToSecondStage = {
    [LevelStage.STAGE1_1] = LevelStage.STAGE1_2,
    [LevelStage.STAGE2_1] = LevelStage.STAGE2_2,
    [LevelStage.STAGE3_1] = LevelStage.STAGE3_2,
    [LevelStage.STAGE4_1] = LevelStage.STAGE4_2,
}

StageAPI.StageTypes = {
    StageType.STAGETYPE_ORIGINAL,
    StageType.STAGETYPE_WOTL,
    StageType.STAGETYPE_AFTERBIRTH,
    StageType.STAGETYPE_REPENTANCE,
    StageType.STAGETYPE_REPENTANCE_B
}

local noBossStages = {
    [LevelStage.STAGE3_2] = true,
    [LevelStage.STAGE4_2] = true
}

local ExtraPortraitAnimationTable = {
    NoShake = {
        {0,Vector(-510,53),Vector(1.0,1.0),Color(1,1,1,0),true}, {4,Vector(-510,53),Vector(1.6,0.4),Color(1,1,1,0),true},
        {11,Vector(-220,-24),Vector(1.0,1.0),Color(1,1,1,1),true}, {12,Vector(-194,-50),Vector(0.8,1.2),Color(1,1,1,1),true},
        {14,Vector(-228,-11),Vector(1.1,0.9),Color(1,1,1,1),true}, {16,Vector(-215,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {89,Vector(-201,-24),Vector(1.0,1.0),Color(1,1,1,1),true}, {91,Vector(-187,-49),Vector(0.8,1.2),Color(1,1,1,1),true},
        {92,Vector(-187,-49),Vector(0.8,1.2),Color(1,1,1,1),true}, {98,Vector(-510,53),Vector(1.6,0.4),Color(1,1,1,0),true},
    },
    Shake = {
        {0,Vector(-510,53),Vector(1.0,1.0),Color(1,1,1,0),true}, {4,Vector(-510,53),Vector(1.6,0.4),Color(1,1,1,0),true},
        {11,Vector(-220,-24),Vector(1.0,1.0),Color(1,1,1,1),true}, {12,Vector(-194,-50),Vector(0.8,1.2),Color(1,1,1,1),true},
        {14,Vector(-228,-11),Vector(1.1,0.9),Color(1,1,1,1),true}, {16,Vector(-215,-24),Vector(1.0,1.0),Color(1,1,1,1),true},
        {17,Vector(-214,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {19,Vector(-216,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {21,Vector(-213,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {23,Vector(-215,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {25,Vector(-213,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {27,Vector(-214,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {29,Vector(-212,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {31,Vector(-214,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {33,Vector(-211,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {35,Vector(-213,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {37,Vector(-211,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {39,Vector(-212,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {41,Vector(-210,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {43,Vector(-212,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {45,Vector(-209,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {47,Vector(-211,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {49,Vector(-209,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {51,Vector(-210,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {53,Vector(-208,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {55,Vector(-210,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {57,Vector(-207,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {59,Vector(-209,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {61,Vector(-207,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {63,Vector(-208,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {65,Vector(-206,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {67,Vector(-208,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {69,Vector(-205,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {71,Vector(-207,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {73,Vector(-204,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {75,Vector(-206,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {77,Vector(-203,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {79,Vector(-205,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {81,Vector(-202,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {83,Vector(-204,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {85,Vector(-201,-24),Vector(1.0,1.0),Color(1,1,1,1)}, {87,Vector(-203,-24),Vector(1.0,1.0),Color(1,1,1,1)},
        {89,Vector(-201,-24),Vector(1.0,1.0),Color(1,1,1,1),true}, {91,Vector(-187,-49),Vector(0.8,1.2),Color(1,1,1,1)},
        {92,Vector(-187,-49),Vector(0.8,1.2),Color(1,1,1,1),true}, {98,Vector(-510,53),Vector(1.6,0.4),Color(1,1,1,0),true},
    }
}

-- if doGreed is false, will not add to greed at all, if true, will only add to greed. nil for both.
-- if stagetype is true, will set floorinfo for all stagetypes
function StageAPI.SetFloorInfo(info, stage, stagetype, doGreed)
    if stagetype == true then
        for _, stype in ipairs(StageAPI.StageTypes) do
            StageAPI.SetFloorInfo(StageAPI.DeepCopy(info), stage, stype, doGreed)
        end

        return
    end

    if doGreed ~= true then
        StageAPI.FloorInfo[stage] = StageAPI.FloorInfo[stage] or {}
        StageAPI.FloorInfo[stage][stagetype] = info

        local stageTwo = stageToSecondStage[stage]
        if stageTwo then
            StageAPI.FloorInfo[stageTwo] = StageAPI.FloorInfo[stageTwo] or {}

            local stageTwoInfo = StageAPI.DeepCopy(info)
            if noBossStages[stageTwo] then
                stageTwoInfo.Bosses = nil
            end

            StageAPI.FloorInfo[stageTwo][stagetype] = stageTwoInfo
        end
    end

    if doGreed ~= false then
        local greedStage = stage
        if doGreed == nil then
            greedStage = stageToGreed[stage] or stage
        end

        local greedInfo = StageAPI.DeepCopy(info)
        greedInfo.Bosses = nil

        StageAPI.FloorInfoGreed[greedStage] = StageAPI.FloorInfoGreed[greedStage] or {}
        StageAPI.FloorInfoGreed[greedStage][stagetype] = greedInfo
    end
end

function StageAPI.GetBaseFloorInfo(stage, stageType, isGreed)
    if stage == nil and stageType == nil and isGreed == nil then
        stage, stageType, isGreed = shared.Level:GetStage(), shared.Level:GetStageType(), shared.Game:IsGreedMode()
    end

    if isGreed then
        if not StageAPI.FloorInfoGreed[stage] then return end
        return StageAPI.FloorInfoGreed[stage][stageType]
    else
        if not StageAPI.FloorInfo[stage] then return end
        return StageAPI.FloorInfo[stage][stageType]
    end
end

StageAPI.PlayerBossInfo = {
    [PlayerType.PLAYER_ISAAC] = {name = "isaac", id = "01"},
    [PlayerType.PLAYER_MAGDALENE] = {name = "magdalene", id = "02"},
    [PlayerType.PLAYER_CAIN] = {name = "cain", id = "03"},
    [PlayerType.PLAYER_JUDAS] = {name = "judas", id = "04"},
    [PlayerType.PLAYER_EVE] = {name = "eve", id = "05"},
    [PlayerType.PLAYER_BLUEBABY] = {name = "bluebaby", id = "06"},
    [PlayerType.PLAYER_SAMSON] = {name = "samson", id = "07"},
    [PlayerType.PLAYER_AZAZEL] = {name = "azazel", id = "08"},
    [PlayerType.PLAYER_LAZARUS] = {name = "lazarus", id = "09"},
    [PlayerType.PLAYER_EDEN] = {name = "eden", id = "09"},
    [PlayerType.PLAYER_THELOST] = {name = "thelost", id = "12"},
    [PlayerType.PLAYER_LILITH] = {name = "lilith", id = "13"},
    [PlayerType.PLAYER_KEEPER] = {name = "keeper", bossname = "thekeeper", id = "14"},
    [PlayerType.PLAYER_APOLLYON] = {name = "apollyon", id = "15"},
    [PlayerType.PLAYER_THEFORGOTTEN] = {name = "theforgotten", id = "16"},
    [PlayerType.PLAYER_THESOUL] = {name = "theforgotten", id = "16"},
    [PlayerType.PLAYER_BETHANY] = {name = "bethany", id = "01x"},
    -- Esau isn't used in the transitions

    [PlayerType.PLAYER_ISAAC_B] = {name = "isaac", id = "01", b = true},
    [PlayerType.PLAYER_MAGDALENE_B] = {name = "magdalene", id = "02", b = true},
    [PlayerType.PLAYER_CAIN_B] = {name = "cain", id = "03", b = true},
    [PlayerType.PLAYER_JUDAS_B] = {name = "judas", id = "04", b = true},
    [PlayerType.PLAYER_EVE_B] = {name = "eve", id = "05", b = true},
    [PlayerType.PLAYER_BLUEBABY_B] = {name = "bluebaby", id = "06", b = true},
    [PlayerType.PLAYER_SAMSON_B] = {name = "samson", id = "07", b = true},
    [PlayerType.PLAYER_AZAZEL_B] = {name = "azazel", id = "08", b = true},
    [PlayerType.PLAYER_LAZARUS_B] = {name = "lazarus", id = "09", b = true},
    [PlayerType.PLAYER_EDEN_B] = {name = "eden", id = "09", b = true},
    [PlayerType.PLAYER_THELOST_B] = {name = "thelost", id = "12", b = true},
    [PlayerType.PLAYER_LILITH_B] = {name = "lilith", id = "13", b = true},
    [PlayerType.PLAYER_KEEPER_B] = {name = "keeper", bossname = "thekeeper", id = "14", b = true},
    [PlayerType.PLAYER_APOLLYON_B] = {name = "apollyon", id = "15", b = true},
    [PlayerType.PLAYER_THEFORGOTTEN_B] = {name = "theforgotten", id = "16", b = true},
    [PlayerType.PLAYER_THESOUL_B] = {name = "theforgotten", id = "16", b = true},
    [PlayerType.PLAYER_BETHANY_B] = {name = "bethany", id = "01x", b = true},
}

for k, v in pairs(StageAPI.PlayerBossInfo) do
    local use = v.name
    local name
    if v.bossname then
        name = "gfx/ui/boss/playername_" .. v.id .. "_" .. v.bossname .. ".png"
    else
        name = "gfx/ui/boss/playername_" .. v.id .. "_" .. use .. ".png"
    end

    local portraitPath
    if v.b then
        portraitPath = "gfx/ui/stage/playerportrait_" .. use .. "_b.png"
    else
        portraitPath = "gfx/ui/stage/playerportrait_" .. use .. ".png"
    end

    StageAPI.PlayerBossInfo[k] = {
        Portrait = portraitPath,
        Name = name,
    }
end

StageAPI.PlayerBossInfo[PlayerType.PLAYER_BLUEBABY].NoShake = true
StageAPI.PlayerBossInfo[PlayerType.PLAYER_KEEPER].NoShake = true
StageAPI.PlayerBossInfo[PlayerType.PLAYER_THEFORGOTTEN].NoShake = true
StageAPI.PlayerBossInfo[PlayerType.PLAYER_THESOUL].NoShake = true
StageAPI.PlayerBossInfo[PlayerType.PLAYER_THEFORGOTTEN].ControlsFrame = 1
StageAPI.PlayerBossInfo[PlayerType.PLAYER_THESOUL].ControlsFrame = 1
StageAPI.PlayerBossInfo[PlayerType.PLAYER_THELOST].NoShake = true

StageAPI.PlayerBossInfo[PlayerType.PLAYER_BLUEBABY_B].NoShake = true
StageAPI.PlayerBossInfo[PlayerType.PLAYER_KEEPER_B].NoShake = true
StageAPI.PlayerBossInfo[PlayerType.PLAYER_THEFORGOTTEN_B].NoShake = true
StageAPI.PlayerBossInfo[PlayerType.PLAYER_THESOUL_B].NoShake = true
StageAPI.PlayerBossInfo[PlayerType.PLAYER_THEFORGOTTEN_B].ControlsFrame = 1
StageAPI.PlayerBossInfo[PlayerType.PLAYER_THESOUL_B].ControlsFrame = 1
StageAPI.PlayerBossInfo[PlayerType.PLAYER_THELOST_B].NoShake = true
StageAPI.PlayerBossInfo[PlayerType.PLAYER_EDEN_B].ExtraPortrait = "gfx/ui/stage/eden_b_head.anm2"

-- bossportrait is optional since Repentance, used if you want
-- your character to have a different boss portrait than the stage one
function StageAPI.AddPlayerGraphicsInfo(playertype, portrait, namefile, noshake, bossportrait, extraportrait)
    local args = portrait
    if type(args) ~= "table" then
        args = {
            Portrait = portrait,
            ExtraPortrait = extraportrait,
            Name = namefile,
            BossPortrait = bossportrait,
            NoShake = noshake,
            Controls = nil,
            ControlsFrame = 0,
            ControlsOffset = nil,
        }
    end

    StageAPI.PlayerBossInfo[playertype] = args
end

StageAPI.AddPlayerGraphicsInfo(PlayerType.PLAYER_BLACKJUDAS, "gfx/ui/stage/playerportrait_darkjudas.png", "gfx/ui/boss/playername_04_judas.png")
StageAPI.AddPlayerGraphicsInfo(PlayerType.PLAYER_LAZARUS2, "gfx/ui/stage/playerportrait_lazarus2.png", "gfx/ui/boss/playername_10_lazarus.png")
StageAPI.AddPlayerGraphicsInfo(PlayerType.PLAYER_LAZARUS2_B, "gfx/ui/stage/playerportrait_lazarus_b_dead.png", "gfx/ui/boss/playername_10_lazarus.png")
StageAPI.AddPlayerGraphicsInfo(PlayerType.PLAYER_JACOB, "gfx/ui/stage/playerportrait_jacob.png", "gfx/ui/boss/playername_02x_jacob_esau.png")
StageAPI.AddPlayerGraphicsInfo(PlayerType.PLAYER_JACOB_B, "gfx/ui/stage/playerportrait_jacob_b.png", "gfx/ui/boss/playername_02x_jacob.png")

StageAPI.PlayerBossInfo[PlayerType.PLAYER_JACOB].ControlsFrame = 2

StageAPI.DefaultVSBackgroundColor = Color(30/255, 18/255, 15/255, 1, 0, 0, 0)
StageAPI.DefaultVSDirtColor = Color(94/255, 56/255, 54/255, 1, 0, 0, 0)
function StageAPI.GetStageSpot()
    if StageAPI.InNewStage() then
        return StageAPI.CurrentStage.BossSpot or "gfx/ui/boss/bossspot.png",
            StageAPI.CurrentStage.PlayerSpot or "gfx/ui/boss/playerspot.png",
            StageAPI.CurrentStage.BackgroundColor or StageAPI.DefaultVSBackgroundColor,
            StageAPI.CurrentStage.DirtColor or StageAPI.DefaultVSDirtColor
    else
        local bossSpot = "gfx/ui/boss/bossspot.png"
        local playerSpot = "gfx/ui/boss/playerspot.png"
        local bgColor = StageAPI.DefaultVSBackgroundColor
        local dirtColor = StageAPI.DefaultVSDirtColor
        local floorInfo = StageAPI.GetBaseFloorInfo()
        if floorInfo then
            local prefix = floorInfo.Prefix
            bossSpot, playerSpot = "gfx/ui/boss/bossspot_" .. prefix .. ".png", "gfx/ui/boss/playerspot_" .. prefix .. ".png"
            bgColor, dirtColor = floorInfo.VsBgColor, floorInfo.VsDirtColor
        end
        return bossSpot, playerSpot, bgColor, dirtColor
    end
end

-- returns nil if no special color
function StageAPI.GetStageFloorTextColor()
    if StageAPI.InNewStage() then
        return StageAPI.CurrentStage.FloorTextColor
    else
        local floorInfo = StageAPI.GetBaseFloorInfo()
        if floorInfo then
            return floorInfo.FloorTextColor
        end
    end
end

function StageAPI.TryGetPlayerGraphicsInfo(player)
    local playerType
    if type(player) == "number" then
        playerType = player
    else
        playerType = player:GetPlayerType()
    end

    if StageAPI.PlayerBossInfo[playerType] then
        return StageAPI.PlayerBossInfo[playerType]
    else
        -- worth a shot, most common naming convention
        local playerName
        if type(player) == "string" then
            playerName = player
        elseif type(player) ~= "number" then
            playerName = player:GetName()
        else
            return StageAPI.PlayerBossInfo[PlayerType.PLAYER_ISAAC]
        end

        playerName = string.gsub(string.lower(playerName), "%s+", "")

        return {
            Portrait    = "gfx/ui/stage/playerportrait_" .. playerName .. ".png",
            Name        = "gfx/ui/boss/playername_" .. playerName .. ".png",
        }
    end
end

StageAPI.BossSprite = Sprite()
StageAPI.BossSprite:Load("gfx/ui/boss/versusscreen.anm2", false)
StageAPI.BossSprite:ReplaceSpritesheet(0, "none.png")
StageAPI.BossSprite:ReplaceSpritesheet(11, "stageapi/boss/overlay.png")

StageAPI.BossSpriteBg = Sprite()
StageAPI.BossSpriteBg:Load("gfx/ui/boss/versusscreen.anm2", true)
for i=1, 14 do
    StageAPI.BossSpriteBg:ReplaceSpritesheet(i, "none.png")
end

StageAPI.BossSpriteDirt = Sprite()
StageAPI.BossSpriteDirt:Load("gfx/ui/boss/versusscreen.anm2", true)
for i=0, 14 do
    StageAPI.BossSpriteDirt:ReplaceSpritesheet(i, "none.png")
end

StageAPI.PlayerPortraitExtra = Sprite()

StageAPI.PlayingBossSprite = nil
StageAPI.PlayingBossSpriteBg = nil
StageAPI.PlayingBossSpriteDirt = nil
StageAPI.UnskippableBossAnim = nil
StageAPI.BossOffset = nil
StageAPI.UsePlayerExtraPortrait = nil

function StageAPI.PlayBossAnimationManual(portrait, name, spot, playerPortrait, playerName, playerSpot, portraitTwo, unskippable, bgColor, dirtColor, noShake, playerExtraPortrait)
    local paramTable = portrait
    if type(paramTable) ~= "table" then
        paramTable = {
            BossPortrait = portrait,
            BossPortraitTwo = portraitTwo,
            BossName = name,
            BossSpot = spot,
            PlayerPortrait = playerPortrait,
            PlayerExtraPortrait = playerExtraPortrait,
            PlayerName = playerName,
            PlayerSpot = playerSpot,
            Unskippable = unskippable,
            BackgroundColor = bgColor,
            DirtColor = dirtColor,
            NoShake = noShake
        }
    end

    if paramTable.Sprite then -- if you need to use a different sprite (ex for a special boss animation) this could help
        StageAPI.PlayingBossSprite = paramTable.Sprite
    else
        StageAPI.PlayingBossSprite = StageAPI.BossSprite
        StageAPI.PlayingBossSpriteBg = StageAPI.BossSpriteBg
        StageAPI.PlayingBossSpriteDirt = StageAPI.BossSpriteDirt
    end

    if not paramTable.NoLoadGraphics then
        StageAPI.PlayingBossSprite:ReplaceSpritesheet(2, paramTable.BossSpot or "gfx/ui/boss/bossspot.png")
        StageAPI.PlayingBossSprite:ReplaceSpritesheet(3, paramTable.PlayerSpot or "gfx/ui/boss/bossspot.png")
        StageAPI.PlayingBossSprite:ReplaceSpritesheet(4, paramTable.BossPortrait or "gfx/ui/boss/portrait_20.0_monstro.png")
        StageAPI.PlayingBossSpriteDirt:ReplaceSpritesheet(13, paramTable.BossPortrait or "gfx/ui/boss/portrait_20.0_monstro.png")
        StageAPI.PlayingBossSprite:ReplaceSpritesheet(6, paramTable.PlayerName or "gfx/ui/boss/bossname_20.0_monstro.png")
        StageAPI.PlayingBossSprite:ReplaceSpritesheet(7, paramTable.BossName or "gfx/ui/boss/bossname_20.0_monstro.png")
        if paramTable.NoShake then
            StageAPI.PlayingBossSprite:ReplaceSpritesheet(5, "none.png")
            StageAPI.PlayingBossSprite:ReplaceSpritesheet(12, paramTable.PlayerPortrait or "gfx/ui/boss/portrait_20.0_monstro.png")
        else
            StageAPI.PlayingBossSprite:ReplaceSpritesheet(5, paramTable.PlayerPortrait or "gfx/ui/boss/portrait_20.0_monstro.png")
            StageAPI.PlayingBossSprite:ReplaceSpritesheet(12, "none.png")
        end

        StageAPI.UsePlayerExtraPortrait = nil
        if paramTable.PlayerExtraPortrait then
            StageAPI.PlayerPortraitExtra:Load(paramTable.PlayerExtraPortrait,true)
            if paramTable.NoShake then
                StageAPI.UsePlayerExtraPortrait = false
            else
                StageAPI.UsePlayerExtraPortrait = true
            end
            StageAPI.PlayerPortraitExtra:Play(StageAPI.PlayerPortraitExtra:GetDefaultAnimationName(),true)
            StageAPI.PlayerPortraitExtra.Offset = Vector(-500,200)
        end

        if paramTable.BossPortraitTwo then
            StageAPI.PlayingBossSprite:ReplaceSpritesheet(9, paramTable.BossPortraitTwo)
            StageAPI.PlayingBossSpriteDirt:ReplaceSpritesheet(14, paramTable.BossPortraitTwo)
            paramTable.Animation = paramTable.Animation or "DoubleTrouble"
        end

        StageAPI.PlayingBossSprite:Play(paramTable.Animation or "Scene", true)
        StageAPI.PlayingBossSprite:LoadGraphics()

        StageAPI.PlayingBossSpriteBg.Color = paramTable.BackgroundColor or Color(0, 0, 0, 1, 0, 0, 0)
        StageAPI.PlayingBossSpriteBg:Play(paramTable.Animation or "Scene", true)

        StageAPI.PlayingBossSpriteDirt.Color = paramTable.DirtColor or Color(1, 1, 1, 1, 0, 0, 0)
        StageAPI.PlayingBossSpriteDirt:Play(paramTable.Animation or "Scene", true)
        StageAPI.PlayingBossSpriteDirt:LoadGraphics()
    end

    if paramTable.BossOffset then
        StageAPI.BossOffset = paramTable.BossOffset
    else
        StageAPI.BossOffset = nil
    end

    StageAPI.UnskippableBossAnim = paramTable.Unskippable
end

StageAPI.IsOddRenderFrame = nil
local menuConfirmTriggered
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    StageAPI.IsOddRenderFrame = not StageAPI.IsOddRenderFrame
    local isPlaying = StageAPI.PlayingBossSprite and StageAPI.PlayingBossSprite:IsPlaying()

    if isPlaying and ((shared.Game:IsPaused() and not menuConfirmTriggered) or StageAPI.UnskippableBossAnim) then
        if StageAPI.IsOddRenderFrame then
            StageAPI.PlayingBossSprite:Update()
            StageAPI.PlayingBossSpriteBg:Update()
            StageAPI.PlayingBossSpriteDirt:Update()
            StageAPI.PlayerPortraitExtra:Update()
            local tab = StageAPI.UsePlayerExtraPortrait and 'Shake' or 'NoShake'
            StageAPI.InterpolateSprite(StageAPI.PlayerPortraitExtra,StageAPI.PlayingBossSprite:GetFrame(),ExtraPortraitAnimationTable[tab])
        end

        local centerPos = StageAPI.GetScreenCenterPosition()
        --local layerRenderOrder = {0,1,2,3,14,9,13,4,5,6,7,8,10}       --ab+ classy vs screen's compability layer order
        local layerRenderOrder = {0,1,2,3,9,14,13,4,5,12,11,6,7,8,10}

        StageAPI.PlayingBossSpriteBg:RenderLayer(0, centerPos)

        for _, layer in ipairs(layerRenderOrder) do
            local pos = centerPos
            if StageAPI.BossOffset then
                local isDoubleTrouble = StageAPI.BossOffset.One or StageAPI.BossOffset.Two
                if isDoubleTrouble then  -- Double trouble, table {One = Vector, Two = Vector}
                    if layer == 4 or layer == 13 then
                        pos = pos + StageAPI.BossOffset.One or Vector.Zero
                    elseif layer == 9 or layer == 14 then
                        pos = pos + StageAPI.BossOffset.Two or Vector.Zero
                    end
                elseif layer == 4 or layer == 13 then
                    pos = pos + StageAPI.BossOffset
                end
            end

            if StageAPI.UsePlayerExtraPortrait ~= nil and layer == 12 then
                StageAPI.PlayerPortraitExtra:Render(pos)
            end
            if layer == 13 or layer == 14 then
                StageAPI.PlayingBossSpriteDirt:RenderLayer(layer, pos)
            else
                StageAPI.PlayingBossSprite:RenderLayer(layer, pos)
            end
        end
    elseif isPlaying or StageAPI.PlayingBossSprite then
        StageAPI.PlayingBossSprite:Stop()
        StageAPI.PlayingBossSprite = nil
        StageAPI.PlayingBossSpriteBg:Stop()
        StageAPI.PlayingBossSpriteBg = nil
        StageAPI.PlayingBossSpriteDirt:Stop()
        StageAPI.PlayingBossSpriteDirt = nil
    end

    if not isPlaying then
        StageAPI.UnskippableBossAnim = nil
        StageAPI.BossOffset = nil
    end

    menuConfirmTriggered = nil
    for _, player in ipairs(shared.Players) do
        if Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, player.ControllerIndex) then
            menuConfirmTriggered = true
            break
        end
    end
end)

---@class BossData
---@field Name string
---@field Weight number
---@field NameTwo string
---@field Portrait string
---@field PortraitTwo string
---@field Horseman boolean
---@field Rooms RoomsList
---@field Shapes RoomShape[]
---@field BaseGameBoss boolean

---@type table<string, BossData>
StageAPI.Bosses = {}
function StageAPI.AddBossData(id, bossData)
    StageAPI.Bosses[id] = bossData

    if not bossData.Name then
        bossData.Name = id
    end

    if not bossData.Weight then
        bossData.Weight = 1
    end

    return id
end

function StageAPI.GetBossData(id)
    return StageAPI.Bosses[id]
end

function StageAPI.PlayBossAnimation(boss, unskippable)
    local bSpot, pSpot, bgColor, dirtColor = StageAPI.GetStageSpot()
    local gfxData = StageAPI.TryGetPlayerGraphicsInfo(shared.Players[1])
    StageAPI.PlayBossAnimationManual({
        BossPortrait = boss.Portrait,
        BossPortraitTwo = boss.PortraitTwo,
        BossName = boss.BossName or boss.Bossname,
        BossSpot = boss.Spot or bSpot,
        PlayerPortrait = gfxData.BossPortrait or gfxData.Portrait,
	PlayerExtraPortrait = gfxData.ExtraPortrait,
        PlayerName = gfxData.Name,
        PlayerSpot = pSpot,
        Unskippable = unskippable,
        BossOffset = boss.Offset,
        BackgroundColor = bgColor,
        DirtColor = dirtColor,
        NoShake = gfxData.NoShake
    })
end

local horsemanRoomSubtypes = {
    9, -- Famine
    10, -- Pestilence
    11, -- War
    12, -- Death
    22, -- Headless Horseman
    38 -- Conquest
}

StageAPI.EncounteredBosses = {}
function StageAPI.SetBossEncountered(name, encountered)
    if encountered == nil then
        encountered = true
    end

    StageAPI.EncounteredBosses[name] = encountered
end

function StageAPI.GetBossEncountered(name)
    return StageAPI.EncounteredBosses[name]
end

StageAPI.BossSelectRNG = RNG()
function StageAPI.SelectBoss(bosses, rng, roomDesc, ignoreNoOptions)
    local bossID = StageAPI.CallCallbacks(Callbacks.PRE_BOSS_SELECT, true, bosses, rng, roomDesc, ignoreNoOptions)
    if type(bossID) == "table" then
        bosses = bossID
        bossID = nil
    end

    if not bossID then
        roomDesc = roomDesc or shared.Level:GetCurrentRoomDesc()
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
            local encountered = StageAPI.GetBossEncountered(potentialBoss.Name)
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

        if not rng then
            rng = StageAPI.BossSelectRNG
            rng:SetSeed(roomDesc.SpawnSeed, 0)
        end

        if #forcedBosses > 0 then
            bossID = StageAPI.WeightedRNG(forcedBosses, rng, nil, totalForcedWeight, floatWeights)
        elseif #unencounteredBosses > 0 then
            bossID = StageAPI.WeightedRNG(unencounteredBosses, rng, nil, totalUnencounteredWeight, floatWeights)
        elseif #validBosses > 0 then
            bossID = StageAPI.WeightedRNG(validBosses, rng, nil, totalValidWeight, floatWeights)
        elseif not ignoreNoOptions then
            local err = "Trying to select boss, but none are valid! Options were:\n"
            for _, potentialBossID in ipairs(bosses) do
                err = err .. potentialBossID .. "\n"
            end

            StageAPI.LogErr(err)
        end
    end

    return bossID
end

function StageAPI.AddBossToBaseFloorPool(poolEntry, stage, stageType, noStageTwo)
    if not poolEntry or type(poolEntry) ~= "table" or not poolEntry.BossID then
        StageAPI.LogErr("AddBossToBaseFloorPool requires a PoolEntry table with BossID set")
        return
    end

    if not StageAPI.GetBossData(poolEntry.BossID) then
        StageAPI.LogErr("Attempting to add invalid boss id " .. poolEntry.BossID .. " to pool")
        return
    end

    local floorInfo = StageAPI.GetBaseFloorInfo(stage, stageType, false)
    if not floorInfo then
        StageAPI.LogErr("Attempting to add boss to invalid stage " .. tostring(stage) .. " " .. tostring(stageType))
        return
    end

    floorInfo.HasCustomBosses = true
    if not floorInfo.Bosses then
        floorInfo.Bosses = {Pool = {}}
    end

    floorInfo.Bosses.Pool[#floorInfo.Bosses.Pool + 1] = poolEntry

    if not noStageTwo then
        local stageTwo = stageToSecondStage[stage]
        if stageTwo and not noBossStages[stageTwo] then
            StageAPI.AddBossToBaseFloorPool(poolEntry, stageTwo, stageType, true)
        end
    end
end
