local shared = require("scripts.stageapi.shared")

-- Base Game Doors, Door Spawns

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
        Bomb = "BrokenOpen",
        DadsKey = {
            State = "Opened",
            ForcedOpen = true
        }
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
        Clear = "Opened",
        DadsKey = {
            State = "Opened",
            ForcedOpen = true
        }
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
        },
        DadsKey = {
            State = "Opened",
            ForcedOpen = true
        }
    }
}

StageAPI.SecretDoorClosedState = {
    Anim = "Close",
    StartAnim = "Close",
    Triggers = {
        Clear = "Opened",
        DadsKey = {
            State = "Opened",
            ForcedOpen = true
        }
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
    DoubleLock = {
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
                    OverlayAnim = "KeyOpenChain1",
                    NoPayToPlay = true
                },
                Coin = {
                    State = "AwaitChain",
                    OverlayAnim = "KeyOpenChain1",
                    PayToPlay = true
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
                    OverlayAnim = "KeyOpenChain2",
                    NoPayToPlay = true
                },
                Coin = {
                    State = "AwaitChain",
                    OverlayAnim = "KeyOpenChain1",
                    PayToPlay = true
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
    Locked = {
        Default = "Locked",
        DefaultPayToPlay = "LockedCoin",
        LockedCoin = {
            Anim = "CoinClosed",
            Triggers = {
                GoldKey = {
                    State = "Opened",
                    Anim = "CoinOpen"
                },
                Coin = {
                    State = "Opened",
                    Anim = "CoinOpen"
                }
            }
        },
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
                    for _, player in ipairs(shared.Players) do
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
                    for _, player in ipairs(shared.Players) do
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
                    local p1 = shared.Players[1]
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
                    if not shared.Room:IsClear() then
                        return
                    end

                    local p1 = shared.Players[1]
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
                    local p1 = shared.Players[1]
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
                    if not shared.Room:IsClear() then
                        return
                    end

                    local p1 = shared.Players[1]
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
    Locked = StageAPI.CustomStateDoor("LockedDoor", nil, StageAPI.BaseDoorStates.Locked),
    Treasure = StageAPI.CustomStateDoor("TreasureDoor", "gfx/grid/door_02_treasureroomdoor.anm2", StageAPI.BaseDoorStates.Locked),
    DevilTreasure = StageAPI.CustomStateDoor("DevilTreasureDoor", "gfx/grid/door_02_treasureroomdoor_devil.anm2", StageAPI.BaseDoorStates.Locked),
    Planetarium = StageAPI.CustomStateDoor("PlanetariumDoor", "gfx/grid/door_00x_planetariumdoor.anm2", StageAPI.BaseDoorStates.Locked),
    Boss = StageAPI.CustomStateDoor("BossDoor", "gfx/grid/door_10_bossroomdoor.anm2", StageAPI.BaseDoorStates.SpecialInterior),
    Secret = StageAPI.CustomStateDoor("SecretDoor", "gfx/grid/door_08_holeinwall.anm2", StageAPI.BaseDoorStates.Secret, nil, nil, StageAPI.SecretDoorOffsetsByDirection),
    Arcade = StageAPI.CustomStateDoor("ArcadeDoor", "gfx/grid/door_05_arcaderoomdoor.anm2", StageAPI.BaseDoorStates.Arcade),
    Bedroom = StageAPI.CustomStateDoor("BedroomDoor", nil, StageAPI.BaseDoorStates.Bedroom, nil, "gfx/grid/door_18_crackeddoor.anm2"),
    DoubleLock = StageAPI.CustomStateDoor("DoubleLockedDoor", nil, StageAPI.BaseDoorStates.DoubleLock, nil, "gfx/grid/door_16_doublelock.anm2"),
    Chest = StageAPI.CustomStateDoor("ChestDoor", "gfx/grid/door_02_treasureroomdoor.anm2", StageAPI.BaseDoorStates.DoubleLock, nil, "gfx/grid/door_16_doublelock.anm2"),
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
    RequireCurrent = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS},
    RequireTarget = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS}
}

StageAPI.SecretDoorSpawn = {
    RequireTarget = {RoomType.ROOM_SECRET, RoomType.ROOM_SUPERSECRET},
    NotCurrent = {RoomType.ROOM_SECRET, RoomType.ROOM_SUPERSECRET}
}

StageAPI.DefaultDoorEntrances = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS}
StageAPI.BaseDoorSpawns = {
    Default = {
        Sprite = "Default",
        StateDoor = "DefaultDoor",
        RequireCurrent = {RoomType.ROOM_DEFAULT},
        RequireTarget = StageAPI.DefaultDoorEntrances
    },
    Sacrifice = {
        Sprite = "Sacrifice",
        StateDoor = "DefaultDoor",
        RequireTarget = {RoomType.ROOM_SACRIFICE}
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
    Shop = {
        Sprite = "Shop",
        StateDoor = "LockedDoor",
        RequireTarget = {RoomType.ROOM_SHOP}
    },
    Library = {
        Sprite = "Library",
        StateDoor = "LockedDoor",
        RequireTarget = {RoomType.ROOM_LIBRARY}
    },
    Treasure = {
        Sprite = "Treasure",
        StateDoor = "TreasureDoor",
        RequireTarget = {RoomType.ROOM_TREASURE}
    },
    Planetarium = {
        Sprite = "Planetarium",
        StateDoor = "PlanetariumDoor",
        RequireTarget = {RoomType.ROOM_PLANETARIUM}
    },
    Boss = {
        Sprite = "Boss",
        StateDoor = "BossDoor",
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
        RequireTarget = {RoomType.ROOM_CHALLENGE},
        IsBossAmbush = false
    },
    BossAmbush = {
        Sprite = "BossAmbush",
        StateDoor = "BossAmbushDoor",
        RequireTarget = {RoomType.ROOM_CHALLENGE},
        IsBossAmbush = true
    },
    Boarded = {
        Sprite = "Boarded",
        StateDoor = "BedroomDoor",
        RequireTarget = {RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS}
    },
    Chest = {
        Sprite = "Chest",
        StateDoor = "ChestDoor",
        RequireTarget = {RoomType.ROOM_CHEST}
    },
    Dice = {
        Sprite = "Dice",
        StateDoor = "DoubleLockedDoor",
        RequireTarget = {RoomType.ROOM_DICE}
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
        RequireTarget = {RoomType.ROOM_CURSE},
    },
    CurseFlatfile = {
        Sprite = "CurseFlatfile",
        StateDoor = "CurseDoor",
        RequireTarget = {RoomType.ROOM_CURSE},
        RequireVarData = 1
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
    Mirror = {
        Sprite = "Mirror",
        StateDoor = "DefaultDoor", -- unimplemented
        RequireTargetIndex = GridRooms.ROOM_MIRROR_IDX
    },
    Mineshaft = {
        Sprite = "Mineshaft",
        StateDoor = "DefaultDoor", -- unimplemented
        RequireTargetIndex = GridRooms.ROOM_MINESHAFT_IDX
    },
    SecretExit = { -- entrance to downpour, mines, mausoleum, as well as post-quest mom's heart fight in mausoleum
        Sprite = "SecretExit",
        StateDoor = "DefaultDoor", -- unimplemented
        RequireTargetIndex = GridRooms.ROOM_SECRET_EXIT_IDX
    },
}

-- in priority order
StageAPI.BaseDoorSpawnList = {
    StageAPI.BaseDoorSpawns.Mirror,
    StageAPI.BaseDoorSpawns.Mineshaft,
    StageAPI.BaseDoorSpawns.SecretExit,
    StageAPI.BaseDoorSpawns.Devil,
    StageAPI.BaseDoorSpawns.Angel,
    StageAPI.BaseDoorSpawns.MinibossSecret,
    StageAPI.BaseDoorSpawns.Secret,
    StageAPI.BaseDoorSpawns.CurseInterior,
    StageAPI.BaseDoorSpawns.CurseFlatfile,
    StageAPI.BaseDoorSpawns.Curse,
    StageAPI.BaseDoorSpawns.BossInterior,
    StageAPI.BaseDoorSpawns.MinibossSurprise,
    StageAPI.BaseDoorSpawns.Miniboss,
    StageAPI.BaseDoorSpawns.SpecialInterior
}

for k, v in pairs(StageAPI.BaseDoorSpawns) do
    if not StageAPI.IsIn(StageAPI.BaseDoorSpawnList, v) and k ~= "Default" then
        StageAPI.BaseDoorSpawnList[#StageAPI.BaseDoorSpawnList + 1] = v
    end
end

StageAPI.BaseDoorSpawnList[#StageAPI.BaseDoorSpawnList + 1] = StageAPI.BaseDoorSpawns.Default
