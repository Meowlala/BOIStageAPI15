StageAPI.LogMinor("Loading Reimplementation Data")

do -- Base Game Doors, Door Spawns

-- Base Game Custom State Doors
StageAPI.BaseDoorOpenState = {
    StartAnim = "Open",
    Anim = "Opened",
    StartSound = SoundEffect.SOUND_DOOR_HEAVY_OPEN,
    Triggers = {
        Unclear = "Closed"
    },
    Passable = true
}

StageAPI.BaseDoorClosedState = {
    StartAnim = "Close",
    Anim = "Closed",
    StartSound = SoundEffect.SOUND_DOOR_HEAVY_CLOSE,
    Triggers = {
        Clear = "Opened",
        Bomb = "BrokenOpen"
    }
}

StageAPI.BaseDoorBrokenOpenState = {
    StartAnim = "Break",
    Anim = "BrokenOpen",
    Passable = true,
    NoMemory = true
}

StageAPI.SpecialDoorClosedState = {
    StartAnim = "Close",
    Anim = "Closed",
    StartSound = SoundEffect.SOUND_DOOR_HEAVY_CLOSE,
    Triggers = {
        Clear = "Opened"
    }
}

StageAPI.SecretDoorHiddenState = {
    Anim = "Hidden",
    Triggers = {
        EnteredThrough = {
            State = "Opened",
            Anim = "Opened"
        },
        Bomb = {
            State = "Opened",
            Anim = "Opened",
            Jingle = Music.MUSIC_JINGLE_SECRETROOM_FIND,
            Particles = {
                {Variant = EffectVariant.ROCK_PARTICLE},
                {Variant = EffectVariant.DUST_CLOUD, Timeout = 40, LifeSpan = 40, Rotation = -3, Count = 2, Velocity = 2}
            }
        }
    }
}

StageAPI.SecretDoorClosedState = {
    Anim = "Close",
    StartAnim = "Close",
    Triggers = {
        Clear = "Opened"
    }
}

StageAPI.SecretDoorOpenedState = {
    Anim = "Opened",
    StartAnim = "Open",
    Triggers = {
        Unclear = "Closed"
    },
    Passable = true
}

StageAPI.BaseDoorStates = {
    Default = {
        Default = "Opened",
        Closed = StageAPI.BaseDoorClosedState,
        Opened = StageAPI.BaseDoorOpenState,
        BrokenOpen = StageAPI.BaseDoorBrokenOpenState
    },
    SpecialInterior = {
        Default = "Opened",
        Opened = StageAPI.BaseDoorOpenState,
        Closed = StageAPI.SpecialDoorClosedState
    },
    Vault = {
        Default = "TwoChains",
        TwoChains = {
            Anim = "Closed",
            OverlayAnim = "TwoChains",
            Triggers = {
                GoldKey = {
                    State = "AwaitChain",
                    OverlayAnim = "GoldenKeyOpenChain1"
                },
                Key = {
                    State = "AwaitChain",
                    OverlayAnim = "KeyOpenChain1"
                }
            }
        },
        AwaitChain = {
            Anim = "Closed",
            OverlayAnim = "OneChain",
            Triggers = {
                FinishOverlayTrigger = "OneChain"
            },
            RememberAs = "OneChain"
        },
        OneChain = {
            Anim = "Closed",
            OverlayAnim = "OneChain",
            Triggers = {
                GoldKey = {
                    State = "Opened",
                    OverlayAnim = "GoldenKeyOpenChain2"
                },
                Key = {
                    State = "Opened",
                    OverlayAnim = "KeyOpenChain2"
                }
            }
        },
        Closed = StageAPI.SpecialDoorClosedState,
        Opened = StageAPI.BaseDoorOpenState
    },
    Bedroom = {
        Default = "TwoBombs",
        TwoBombs = {
            Anim = "Closed",
            OverlayAnim = "Idle",
            Triggers = {
                Bomb = {
                    State = "OneBomb",
                    Particle = {
                        Variant = EffectVariant.WOOD_PARTICLE,
                    }
                }
            }
        },
        OneBomb = {
            Anim = "Closed",
            OverlayAnim = "Damaged",
            Triggers = {
                Bomb = {
                    State = "Opened",
                    Particle = {
                        Variant = EffectVariant.WOOD_PARTICLE,
                    }
                }
            }
        },
        Closed = StageAPI.SpecialDoorClosedState,
        Opened = StageAPI.BaseDoorOpenState
    },
    Key = {
        Default = "Locked",
        Locked = {
            Anim = "KeyClosed",
            Triggers = {
                GoldKey = {
                    State = "Opened",
                    Anim = "GoldenKeyOpen"
                },
                Key = {
                    State = "Opened",
                    Anim = "KeyOpen"
                }
            }
        },
        Closed = StageAPI.SpecialDoorClosedState,
        Opened = StageAPI.BaseDoorOpenState
    },
    Arcade = {
        Default = "Locked",
        Locked = {
            Anim = "KeyClosed",
            Triggers = {
                Coin = {
                    State = "Opened",
                    Anim = "KeyOpen"
                }
            }
        },
        Closed = StageAPI.SpecialDoorClosedState,
        Opened = StageAPI.BaseDoorOpenState
    },
    Secret = {
        Default = "Hidden",
        Hidden = StageAPI.SecretDoorHiddenState,
        Closed = StageAPI.SecretDoorClosedState,
        Opened = StageAPI.SecretDoorOpenedState
    },
    Miniboss = {
        Default = "Barred",
        Barred = {
            Anim = "Closed",
            OverlayAnim = "Appear",
            Triggers = {
                Clear = {
                    State = "Opened",
                    OverlayAnim = "Vanish"
                }
            }
        },
        Closed = StageAPI.SpecialDoorClosedState,
        Opened = StageAPI.BaseDoorOpenState
    },
    MinibossSecret = {
        Default = "Barred",
        Barred = {
            Anim = "Close",
            StartAnim = "Close",
            OverlayAnim = "Appear",
            Triggers = {
                Clear = {
                    State = "Opened",
                    OverlayAnim = "Vanish"
                }
            }
        },
        Closed = StageAPI.SecretDoorClosedState,
        Opened = StageAPI.SecretDoorOpenedState
    },
    CurseInterior = {
        Default = "Opened",
        Opened = {
            StartAnim = "Open",
            Anim = "Opened",
            StartSound = SoundEffect.SOUND_DOOR_HEAVY_OPEN,
            Triggers = {
                Unclear = "Closed",
                Function = function(door, data, sprite, doorData, gridData)
                    for _, player in ipairs(StageAPI.Players) do
                        if player.Position:DistanceSquared(door.Position) < (player.Size) ^ 2 then
                            player:TakeDamage(1, DamageFlag.DAMAGE_CURSED_DOOR, EntityRef(player), 0)
                        end
                    end
                end
            },
            Passable = true
        },
        Closed = StageAPI.SpecialDoorClosedState,
    },
    Curse = {
        Default = "Opened",
        Opened = {
            StartAnim = "Open",
            Anim = "Opened",
            StartSound = SoundEffect.SOUND_DOOR_HEAVY_OPEN,
            Triggers = {
                Unclear = "Closed",
                Function = function(door, data, sprite, doorData, gridData)
                    for _, player in ipairs(StageAPI.Players) do
                        if not player.CanFly and player.Position:DistanceSquared(door.Position) < (player.Size) ^ 2 then
                            player:TakeDamage(1, DamageFlag.DAMAGE_CURSED_DOOR, EntityRef(player), 0)
                        end
                    end
                end
            },
            Passable = true
        },
        Closed = StageAPI.SpecialDoorClosedState,
    },
    Ambush = {
        Default = "Closed",
        Opened = {
            StartAnim = "Open",
            Anim = "Opened",
            StartSound = SoundEffect.SOUND_DOOR_HEAVY_OPEN,
            Triggers = {
                Unclear = "Closed",
                Function = function(door, data, sprite, doorData, gridData)
                    local p1 = StageAPI.Players[1]
                    if (p1:GetHearts() + p1:GetSoulHearts()) < p1:GetMaxHearts() then
                        return "Closed"
                    end
                end
            },
            Passable = true
        },
        Closed = {
            StartAnim = "Close",
            Anim = "Closed",
            StartSound = SoundEffect.SOUND_DOOR_HEAVY_CLOSE,
            Triggers = {
                Function = function(door, data, sprite, doorData, gridData)
                    if not StageAPI.Room:IsClear() then
                        return
                    end

                    local p1 = StageAPI.Players[1]
                    if (p1:GetHearts() + p1:GetSoulHearts()) >= p1:GetMaxHearts() then
                        return "Opened"
                    end
                end
            }
        }
    },
    BossAmbush = {
        Default = "Closed",
        Opened = {
            StartAnim = "Open",
            Anim = "Opened",
            StartSound = SoundEffect.SOUND_DOOR_HEAVY_OPEN,
            Triggers = {
                Unclear = "Closed",
                Function = function(door, data, sprite, doorData, gridData)
                    local p1 = StageAPI.Players[1]
                    if p1:GetHearts() > 2 then
                        return "Closed"
                    end
                end
            },
            Passable = true
        },
        Closed = {
            StartAnim = "Close",
            Anim = "Closed",
            StartSound = SoundEffect.SOUND_DOOR_HEAVY_CLOSE,
            Triggers = {
                Function = function(door, data, sprite, doorData, gridData)
                    if not StageAPI.Room:IsClear() then
                        return
                    end

                    local p1 = StageAPI.Players[1]
                    if p1:GetHearts() <= 2 then
                        return "Opened"
                    end
                end
            }
        }
    }
}

StageAPI.BaseDoors = {
    Default = StageAPI.CustomStateDoor("DefaultDoor", nil, StageAPI.BaseDoorStates.Default),
    SpecialInterior = StageAPI.CustomStateDoor("SpecialDoor", nil, StageAPI.BaseDoorStates.SpecialInterior),
    Shop = StageAPI.CustomStateDoor("ShopDoor", nil, StageAPI.BaseDoorStates.Key),
    Treasure = StageAPI.CustomStateDoor("TreasureDoor", "gfx/grid/door_02_treasureroomdoor.anm2", StageAPI.BaseDoorStates.Key),
    Boss = StageAPI.CustomStateDoor("BossDoor", "gfx/grid/door_10_bossroomdoor.anm2", StageAPI.BaseDoorStates.SpecialInterior),
    Secret = StageAPI.CustomStateDoor("SecretDoor", "gfx/grid/door_08_holeinwall.anm2", StageAPI.BaseDoorStates.Secret, nil, nil, StageAPI.SecretDoorOffsetsByDirection),
    Arcade = StageAPI.CustomStateDoor("ArcadeDoor", "gfx/grid/door_05_arcaderoomdoor.anm2", StageAPI.BaseDoorStates.Arcade),
    Bedroom = StageAPI.CustomStateDoor("BedroomDoor", nil, StageAPI.BaseDoorStates.Bedroom, nil, "gfx/grid/door_18_crackeddoor.anm2"),
    Vault = StageAPI.CustomStateDoor("VaultDoor", nil, StageAPI.BaseDoorStates.Vault, nil, "gfx/grid/door_16_doublelock.anm2"),
    Miniboss = StageAPI.CustomStateDoor("MinibossDoor", nil, StageAPI.BaseDoorStates.Miniboss, nil, "gfx/grid/door_17_bardoor.anm2"),
    MinibossSecret = StageAPI.CustomStateDoor("MinibossSecretDoor", "gfx/grid/door_08_holeinwall.anm2", StageAPI.BaseDoorStates.MinibossSecret, nil, "gfx/grid/door_17_bardoor.anm2", StageAPI.SecretDoorOffsetsByDirection),
    Devil = StageAPI.CustomStateDoor("DevilDoor", "gfx/grid/door_07_devilroomdoor.anm2", StageAPI.BaseDoorStates.SpecialInterior),
    Angel = StageAPI.CustomStateDoor("AngelDoor", "gfx/grid/door_07_holyroomdoor.anm2", StageAPI.BaseDoorStates.SpecialInterior),
    Curse = StageAPI.CustomStateDoor("CurseDoor", "gfx/grid/door_04_selfsacrificeroomdoor.anm2", StageAPI.BaseDoorStates.Curse),
    CurseInterior = StageAPI.CustomStateDoor("CurseInteriorDoor", "gfx/grid/door_04_selfsacrificeroomdoor.anm2", StageAPI.BaseDoorStates.CurseInterior),
    Ambush = StageAPI.CustomStateDoor("AmbushDoor", "gfx/grid/door_03_ambushroomdoor.anm2", StageAPI.BaseDoorStates.Ambush),
    BossAmbush = StageAPI.CustomStateDoor("BossAmbushDoor", "gfx/grid/door_09_bossambushroomdoor.anm2", StageAPI.BaseDoorStates.BossAmbush)
}

-- these two are redundant but being kept for now since they are used in the old door system
StageAPI.DefaultDoorSpawn = {
    RequireCurrent = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS, RoomType.ROOM_SACRIFICE, RoomType.ROOM_SHOP, RoomType.ROOM_LIBRARY, RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS, RoomType.ROOM_DICE, RoomType.ROOM_CHEST},
    RequireTarget = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS, RoomType.ROOM_SACRIFICE, RoomType.ROOM_SHOP, RoomType.ROOM_LIBRARY, RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS, RoomType.ROOM_DICE, RoomType.ROOM_CHEST}
}

StageAPI.SecretDoorSpawn = {
    RequireTarget = {RoomType.ROOM_SECRET, RoomType.ROOM_SUPERSECRET},
    NotCurrent = {RoomType.ROOM_SECRET, RoomType.ROOM_SUPERSECRET}
}

StageAPI.DefaultDoorEntrances = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS, RoomType.ROOM_SACRIFICE}
StageAPI.BaseDoorSpawns = {
    Default = {
        Sprite = "Default",
        StateDoor = "DefaultDoor",
        RequireCurrent = {RoomType.ROOM_DEFAULT},
        RequireTarget = StageAPI.DefaultDoorEntrances
    },
    SpecialInterior = { -- same as default door, but cannot be blown up
        Sprite = "Default",
        StateDoor = "SpecialDoor",
        NotCurrent = {RoomType.ROOM_DEFAULT, RoomType.ROOM_CURSE},
        RequireTarget = StageAPI.DefaultDoorEntrances
    },
    Miniboss = {
        Sprite = "Default",
        StateDoor = "MinibossDoor",
        RequireCurrent = {RoomType.ROOM_MINIBOSS},
        RequireTarget = StageAPI.DefaultDoorEntrances
    },
    MinibossSecret = {
        Sprite = "Secret",
        StateDoor = "MinibossSecretDoor",
        RequireCurrent = {RoomType.ROOM_SECRET},
        IsSurpriseMiniboss = true
    },
    MinibossSurprise = {
        Sprite = "Default",
        StateDoor = "MinibossDoor",
        IsSurpriseMiniboss = true,
        NotCurrent = {RoomType.ROOM_DEFAULT}
    },
    Secret = {
        Sprite = "Secret",
        StateDoor = "SecretDoor",
        RequireEither = {RoomType.ROOM_SECRET, RoomType.ROOM_SUPERSECRET}
    },
    Lock = {
        Sprite = "Default",
        StateDoor = "ShopDoor",
        RequireCurrent = {RoomType.ROOM_DEFAULT},
        RequireTarget = {RoomType.ROOM_SHOP, RoomType.ROOM_LIBRARY}
    },
    Treasure = {
        Sprite = "Treasure",
        StateDoor = "TreasureDoor",
        RequireCurrent = {RoomType.ROOM_DEFAULT},
        RequireTarget = {RoomType.ROOM_TREASURE}
    },
    Boss = {
        Sprite = "Boss",
        StateDoor = "BossDoor",
        RequireCurrent = {RoomType.ROOM_DEFAULT},
        RequireTarget = {RoomType.ROOM_BOSS}
    },
    BossInterior = {
        Sprite = "Boss",
        StateDoor = "BossDoor",
        RequireCurrent = {RoomType.ROOM_BOSS},
        RequireTarget = StageAPI.DefaultDoorEntrances
    },
    Ambush = {
        Sprite = "Ambush",
        StateDoor = "AmbushDoor",
        RequireCurrent = {RoomType.ROOM_DEFAULT},
        RequireTarget = {RoomType.ROOM_CHALLENGE},
        IsBossAmbush = false
    },
    BossAmbush = {
        Sprite = "BossAmbush",
        StateDoor = "BossAmbushDoor",
        RequireCurrent = {RoomType.ROOM_DEFAULT},
        RequireTarget = {RoomType.ROOM_CHALLENGE},
        IsBossAmbush = true
    },
    Boarded = {
        Sprite = "Boarded",
        StateDoor = "BedroomDoor",
        RequireCurrent = {RoomType.ROOM_DEFAULT},
        RequireTarget = {RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS}
    },
    DoubleLock = {
        Sprite = "DoubleLock",
        StateDoor = "VaultDoor",
        RequireCurrent = {RoomType.ROOM_DEFAULT},
        RequireTarget = {RoomType.ROOM_CHEST, RoomType.ROOM_DICE}
    },
    CurseInterior = {
        Sprite = "Default",
        StateDoor = "CurseInteriorDoor",
        RequireCurrent = {RoomType.ROOM_CURSE},
        RequireTarget = StageAPI.DefaultDoorEntrances
    },
    Curse = {
        Sprite = "Curse",
        StateDoor = "CurseDoor",
        RequireCurrent = {RoomType.ROOM_DEFAULT},
        RequireTarget = {RoomType.ROOM_CURSE}
    },
    Devil = {
        Sprite = "Devil",
        StateDoor = "DevilDoor",
        RequireTarget = {RoomType.ROOM_DEVIL}
    },
    Angel = {
        Sprite = "Angel",
        StateDoor = "AngelDoor",
        RequireTarget = {RoomType.ROOM_ANGEL}
    },
    PayToPlay = {
        Sprite = "PayToPlay",
        StateDoor = "ArcadeDoor",
        IsPayToPlay = true
    }
}
StageAPI.BaseDoorSpawnList = {StageAPI.BaseDoorSpawns.PayToPlay, StageAPI.BaseDoorSpawns.Devil, StageAPI.BaseDoorSpawns.Angel, StageAPI.BaseDoorSpawns.MinibossSecret, StageAPI.BaseDoorSpawns.Secret, StageAPI.BaseDoorSpawns.CurseInterior, StageAPI.BaseDoorSpawns.Curse, StageAPI.BaseDoorSpawns.BossInterior, StageAPI.BaseDoorSpawns.MinibossSurprise, StageAPI.BaseDoorSpawns.Miniboss, StageAPI.BaseDoorSpawns.SpecialInterior} -- in priority order

for k, v in pairs(StageAPI.BaseDoorSpawns) do
    if not StageAPI.IsIn(StageAPI.BaseDoorSpawnList, v) and k ~= "Default" then
        StageAPI.BaseDoorSpawnList[#StageAPI.BaseDoorSpawnList + 1] = v
    end
end

StageAPI.BaseDoorSpawnList[#StageAPI.BaseDoorSpawnList + 1] = StageAPI.BaseDoorSpawns.Default

end

do -- Reimplementation of most base game GridGfx, Backdrops, RoomGfx

-- Base Game Backdrops
local function autoBackdrop(name, wallVariants, extraFloors, extraWalls, lfloors, nfloors)
    lfloors = lfloors or 1
    nfloors = nfloors or 1

    local backdrop = {WallVariants = {}, Floors = {}}

    for var, count in ipairs(wallVariants) do
        backdrop.WallVariants[var] = {Corners = {}}

        for i = 1, count do
            backdrop.WallVariants[var][#backdrop.WallVariants[var] + 1] = "stageapi/floors/" .. name .. "/" .. name .. tostring(var) .. "_" .. tostring(i) .. ".png"
            backdrop.Floors[#backdrop.Floors + 1] = "stageapi/floors/" .. name .. "/" .. name .. tostring(var) .. "_" .. tostring(i) .. ".png"
        end

        backdrop.WallVariants[var].Corners[#backdrop.WallVariants[var].Corners + 1] = "stageapi/floors/" .. name .. "/" .. name .. tostring(var) .. "_corner.png"
    end

    if extraFloors then
        for i = 1, extraFloors do
            backdrop.Floors[#backdrop.Floors + 1] = "stageapi/floors/" .. name .. "/" .. name .. "extrafloor_" .. tostring(i) .. ".png"
        end
    end

    if extraWalls then
        for var, count in ipairs(extraWalls) do
            if not backdrop.WallVariants[var] then
                backdrop.WallVariants[var] = {}
            end

            if count > 0 then
                for i = 1, count do
                    backdrop.WallVariants[var][#backdrop.WallVariants[var] + 1] = "stageapi/floors/" .. name .. "/" .. name .. tostring(var) .. "extrawall_" .. tostring(i) .. ".png"
                end
            end
        end
    end

    if lfloors > 0 then
        backdrop.LFloors = {}
        for i = 1, lfloors do
            if lfloors == 1 then
                backdrop.LFloors[#backdrop.LFloors + 1] = "stageapi/floors/" .. name .. "/" .. name .. "_lfloor"
            else
                backdrop.LFloors[#backdrop.LFloors + 1] = "stageapi/floors/" .. name .. "/" .. name .. "_lfloor" .. tostring(i)
            end
        end
    end

    if nfloors > 0 then
        backdrop.NFloors = {}
        for i = 1, nfloors do
            if nfloors == 1 then
                backdrop.NFloors[#backdrop.NFloors + 1] = "stageapi/floors/" .. name .. "/" .. name .. "_nfloor"
            else
                backdrop.NFloors[#backdrop.NFloors + 1] = "stageapi/floors/" .. name .. "/" .. name .. "_nfloor" .. tostring(i)
            end
        end
    end

    return backdrop
end

StageAPI.BaseBackdrops = {
    Basement = autoBackdrop("basement", {3}, 2),
    Cellar = autoBackdrop("cellar", {2, 2}, 2),
    BurningBasement = autoBackdrop("burningbasement", {2, 2}, 2),
    Caves = autoBackdrop("caves", {3, 3}),
    Catacombs = autoBackdrop("catacombs", {2, 1}, 3),
    FloodedCaves = autoBackdrop("floodedCaves", {3, 3}),
    Depths = autoBackdrop("depths", {3}, 3, nil, nil, 2),
    Necropolis = autoBackdrop("necropolis", {1}, nil, nil, nil, 2),
    DankDepths = autoBackdrop("dankdepths", {5}, nil, nil, nil, 2),
    Womb = autoBackdrop("womb", {1}, 5),
    Utero = autoBackdrop("utero", {4}),
    ScarredWomb = autoBackdrop("scarredwomb", {3, 1}, nil, {0, 2}, nil, 2),
    BlueWomb = autoBackdrop("bluewomb", {3}, 3, nil, 0, 0),
    Sheol = autoBackdrop("sheol", {1}),
    Cathedral = {
        FloorVariants = {{"stageapi/floors/cathedral/cathedralfloor_1.png"},{"stageapi/floors/cathedral/cathedralfloor_2.png"},{"stageapi/floors/cathedral/cathedralfloor_3.png"}},
        Walls = {"stageapi/floors/cathedral/cathedral1_1.png","stageapi/floors/cathedral/cathedral1_2.png","stageapi/floors/cathedral/cathedral1_3.png","stageapi/floors/cathedral/cathedral1_4.png"},
        Corners = {"stageapi/floors/cathedral/cathedral1_corner.png"},
        LFloors = {"stageapi/floors/cathedral/cathedral_lfloor.png"},
        NFloors = {"stageapi/floors/cathedral/cathedral_nfloor.png"},
        FloorAnm2 = "stageapi/floors/cathedral/FloorBackdrop.anm2",
        PreFloorSheetFunc = function(sprite)
            sprite:ReplaceSpritesheet(20, "stageapi/floors/cathedral/cathedral_bigfloor.png")
        end
    },
    -- Dark room not included yet due to replication difficulty
    Chest = autoBackdrop("chest", {4}),

    -- Special Rooms
    Shop = autoBackdrop("shop", {4}, nil, nil, 0),
    Library = autoBackdrop("library", {1}, nil, nil, 0),
    Secret = autoBackdrop("secret", {2}, 1, nil, 0),
    Barren = autoBackdrop("barren", {2}, 4, nil, 0, 0),
    Isaacs = autoBackdrop("isaacs", {2}, 4, nil, 0, 0),
    Arcade = autoBackdrop("arcade", {4}, 2, nil, 0, 0),
    Dice = autoBackdrop("dice", {4}, 2, nil, 0),
    BlueSecret = autoBackdrop("bluesecret", {2}, 1, nil, 0, 0)
}

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

StageAPI.BaseRoomGfx = {
    Basement = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Basement, StageAPI.BaseGridGfx.Basement, "_default"),
    Cellar = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Cellar, StageAPI.BaseGridGfx.Cellar, "_default"),
    BurningBasement = StageAPI.RoomGfx(StageAPI.BaseBackdrops.BurningBasement, StageAPI.BaseGridGfx.BurningBasement, "_default"),
    Caves = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Caves, StageAPI.BaseGridGfx.Caves, "_default"),
    Catacombs = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Catacombs, StageAPI.BaseGridGfx.Catacombs, "_default"),
    FloodedCaves = StageAPI.RoomGfx(StageAPI.BaseBackdrops.FloodedCaves, StageAPI.BaseGridGfx.FloodedCaves, "_default"),
    Depths = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Depths, StageAPI.BaseGridGfx.Depths, "_default"),
    Necropolis = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Necropolis, StageAPI.BaseGridGfx.Necropolis, "_default"),
    DankDepths = StageAPI.RoomGfx(StageAPI.BaseBackdrops.DankDepths, StageAPI.BaseGridGfx.DankDepths, "_default"),
    Womb = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Womb, StageAPI.BaseGridGfx.Womb, "_default"),
    Utero = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Utero, StageAPI.BaseGridGfx.Utero, "_default"),
    ScarredWomb = StageAPI.RoomGfx(StageAPI.BaseBackdrops.ScarredWomb, StageAPI.BaseGridGfx.ScarredWomb, "_default"),
    BlueWomb = StageAPI.RoomGfx(StageAPI.BaseBackdrops.BlueWomb, StageAPI.BaseGridGfx.BlueWomb, "_default"),
    Sheol = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Sheol, StageAPI.BaseGridGfx.Sheol, "_default"),
    Cathedral = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Cathedral, StageAPI.BaseGridGfx.Cathedral, "_default"),
    DarkRoom = StageAPI.RoomGfx(StageAPI.BaseBackdrops.DarkRoom, StageAPI.BaseGridGfx.DarkRoom, "_default"),
    Chest = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Chest, StageAPI.BaseGridGfx.Chest, "_default"),

    -- Special Rooms
    Shop = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Shop, StageAPI.BaseGridGfx.Basement, "_default"),
    Library = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Library, StageAPI.BaseGridGfx.Basement, "_default"),
    Secret = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Secret, StageAPI.BaseGridGfx.Secret, "_default"),
    Barren = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Barren, StageAPI.BaseGridGfx.Basement, "_default"),
    Isaacs = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Isaacs, StageAPI.BaseGridGfx.Basement, "_default"),
    Arcade = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Arcade, StageAPI.BaseGridGfx.Basement, "_default"),
    Dice = StageAPI.RoomGfx(StageAPI.BaseBackdrops.Dice, StageAPI.BaseGridGfx.Basement, "_default"),
    BlueSecret = StageAPI.RoomGfx(StageAPI.BaseBackdrops.BlueSecret, nil, "_default")
}

end


do -- Overriden Stages Reimplementation

-- Catacombs --

-- this stuff is legacy but a few mods might use it, so we're not removing it yet, there's no need to actually set the roomgfx for the stage because stageapi doesn't remove any of the existing gfx
StageAPI.CatacombsGridGfx = StageAPI.BaseGridGfx.Catacombs
StageAPI.CatacombsBackdrop = StageAPI.BaseBackdrops.Catacombs
StageAPI.CatacombsRoomGfx = StageAPI.BaseRoomGfx.Catacombs
--StageAPI.Catacombs:SetRoomGfx(StageAPI.BaseRoomGfx.Catacombs, {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})

StageAPI.Catacombs = StageAPI.CustomStage("Catacombs", nil, true)
StageAPI.Catacombs:SetStageMusic(Music.MUSIC_CATACOMBS)
StageAPI.Catacombs:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)

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

-- Necropolis --

-- this stuff is legacy but a few mods might use it, so we're not removing it yet, there's no need to actually set the roomgfx for the stage because stageapi doesn't remove any of the existing gfx
StageAPI.NecropolisGridGfx = StageAPI.BaseGridGfx.Necropolis
StageAPI.NecropolisBackdrop = StageAPI.BaseBackdrops.Necropolis
StageAPI.NecropolisRoomGfx = StageAPI.BaseRoomGfx.Necropolis
--StageAPI.Necropolis:SetRoomGfx(StageAPI.BaseRoomGfx.Necropolis, {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})

StageAPI.NecropolisOverlays = {
    StageAPI.Overlay("stageapi/floors/necropolis/overlay.anm2", Vector(0.33, -0.15), nil, nil, 0.5),
    StageAPI.Overlay("stageapi/floors/necropolis/overlay.anm2", Vector(-0.33, -0.15), Vector(128, 128), nil, 0.5),
    StageAPI.Overlay("stageapi/floors/necropolis/overlay.anm2", Vector(0.33, 0.1), nil, nil, 0.5),
}

StageAPI.Necropolis = StageAPI.CustomStage("Necropolis", nil, true)
StageAPI.Necropolis:SetStageMusic(Music.MUSIC_NECROPOLIS)
StageAPI.Necropolis:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)
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

-- Utero --

-- this stuff is legacy but a few mods might use it, so we're not removing it yet, there's no need to actually set the roomgfx for the stage because stageapi doesn't remove any of the existing gfx
StageAPI.UteroGridGfx = StageAPI.BaseGridGfx.Utero
StageAPI.UteroBackdrop = StageAPI.BaseBackdrops.Utero
StageAPI.UteroRoomGfx = StageAPI.BaseRoomGfx.Utero
--StageAPI.Utero:SetRoomGfx(StageAPI.BaseRoomGfx.Utero, {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})

StageAPI.Utero = StageAPI.CustomStage("Utero", nil, true)
StageAPI.Utero:SetStageMusic(Music.MUSIC_UTERO)
StageAPI.Utero:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)
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

end

do -- Boss Animation Data
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
