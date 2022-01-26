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
    BlueSecret = StageAPI.RoomGfx(BackdropType.BLUE_WOMB_PASS, nil, "_default")
}

end


do -- Overriden Stages Reimplementation

-- Catacombs --
StageAPI.Catacombs = StageAPI.CustomStage("Catacombs", nil, true)
StageAPI.Catacombs:SetStageMusic(Music.MUSIC_CATACOMBS)
StageAPI.Catacombs:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)
StageAPI.Catacombs.GenerateLevel = StageAPI.GenerateBaseLevel

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
StageAPI.NecropolisOverlays = {
    StageAPI.Overlay("stageapi/floors/necropolis/overlay.anm2", Vector(0.33, -0.15), nil, nil, 0.5),
    StageAPI.Overlay("stageapi/floors/necropolis/overlay.anm2", Vector(-0.33, -0.15), Vector(128, 128), nil, 0.5),
    StageAPI.Overlay("stageapi/floors/necropolis/overlay.anm2", Vector(0.33, 0.1), nil, nil, 0.5),
}

StageAPI.Necropolis = StageAPI.CustomStage("Necropolis", nil, true)
StageAPI.Necropolis:SetStageMusic(Music.MUSIC_NECROPOLIS)
StageAPI.Necropolis:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)
StageAPI.Necropolis.GenerateLevel = StageAPI.GenerateBaseLevel
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
StageAPI.Utero = StageAPI.CustomStage("Utero", nil, true)
StageAPI.Utero:SetStageMusic(Music.MUSIC_UTERO)
StageAPI.Utero:SetBossMusic({Music.MUSIC_BOSS, Music.MUSIC_BOSS2}, Music.MUSIC_BOSS_OVER)
StageAPI.Utero.GenerateLevel = StageAPI.GenerateBaseLevel
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
end

do -- Base Floor Info
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
end
