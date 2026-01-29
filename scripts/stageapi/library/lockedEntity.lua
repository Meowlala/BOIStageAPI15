-- Pickups and entities that are locked on a fresh save file and must be replaced if placed in a room and not unlocked
local LockedEntities = {
    [EntityType.ENTITY_PICKUP] = {
        [PickupVariant.PICKUP_HEART] = {
            [HeartSubType.HEART_GOLDEN] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF},
                Achievement = 224, -- Golden Hearts
            },
            [HeartSubType.HEART_HALF_SOUL] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL},
                Achievement = 33, -- Everything is Terrible
            },
            [HeartSubType.HEART_SCARED] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL},
                Achievement = 328, -- Mr. Resetter
            },
            [HeartSubType.HEART_BONE] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF},
                Achievement = 390, -- The Forgotten
            },
            [HeartSubType.HEART_ROTTEN] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF},
                Achievement = 411, -- Rotten Hearts
            },
        },

        [PickupVariant.PICKUP_COIN] = {
            [CoinSubType.COIN_LUCKYPENNY] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY},
                Achievement = 242, -- Lucky Pennies
            },
            [CoinSubType.COIN_STICKYNICKEL] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY},
                Achievement = 240, -- Sticky Nickel
            },
            [CoinSubType.COIN_GOLDEN] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY},
                Achievement = 613, -- Golden Pennies
            },
        },

        [PickupVariant.PICKUP_BOMB] = {
            [BombSubType.BOMB_GOLDEN] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL},
                Achievement = 226, -- Golden Bombs
            },
        },

        [PickupVariant.PICKUP_KEY] = {
            [KeySubType.KEY_CHARGED] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL},
                Achievement = 333, -- Charged Key
            },
        },

        [PickupVariant.PICKUP_LIL_BATTERY] = {
            [BatterySubType.BATTERY_MICRO] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL},
                Achievement = 33, -- Everything is Terrible
            },
            [BatterySubType.BATTERY_GOLDEN] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL},
                Achievement = 615, -- Golden Battery
            },
        },

        [PickupVariant.PICKUP_GRAB_BAG] = {
            [SackSubType.SACK_BLACK] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, SackSubType.SACK_NORMAL},
                Achievement = 604, -- Black Sack
            },
        },

        [PickupVariant.PICKUP_WOODENCHEST] = {
            Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, ChestSubType.CHEST_CLOSED},
            Achievement = 609, -- Wooden Chest
        },

        [PickupVariant.PICKUP_MEGACHEST] = {
            Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, ChestSubType.CHEST_CLOSED},
            Achievement = 601, -- Mega Chest
        },

        [PickupVariant.PICKUP_HAUNTEDCHEST] = {
            Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, ChestSubType.CHEST_CLOSED},
            Achievement = 611, -- Haunted Chest
        },

        [PickupVariant.PICKUP_TAROTCARD] = {
            -- Reverse Tarot Cards
            [Card.CARD_REVERSE_FOOL] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 524, -- Reverse Fool
            },

            [Card.CARD_REVERSE_MAGICIAN] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 525, -- Reverse Magician
            },

            [Card.CARD_REVERSE_HIGH_PRIESTESS] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 526, -- Reverse High Priestess
            },

            [Card.CARD_REVERSE_EMPRESS] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 527, -- Reverse Empress
            },

            [Card.CARD_REVERSE_EMPEROR] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 528, -- Reverse Emperor
            },

            [Card.CARD_REVERSE_HIEROPHANT] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 529, -- Reverse Hierophant
            },

            [Card.CARD_REVERSE_LOVERS] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 530, -- Reverse Lovers
            },

            [Card.CARD_REVERSE_CHARIOT] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 531, -- Reverse Chariot
            },

            [Card.CARD_REVERSE_JUSTICE] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 532, -- Reverse Justice
            },

            [Card.CARD_REVERSE_HERMIT] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 533, -- Reverse Hermit
            },

            [Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 534, -- Reverse Wheel of Fortune
            },

            [Card.CARD_REVERSE_STRENGTH] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 535, -- Reverse Strength
            },

            [Card.CARD_REVERSE_HANGED_MAN] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 536, -- Reverse Hanged Man
            },

            [Card.CARD_REVERSE_DEATH] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 537, -- Reverse Death
            },

            [Card.CARD_REVERSE_TEMPERANCE] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 538, -- Reverse Temperance
            },

            [Card.CARD_REVERSE_DEVIL] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 539, -- Reverse Devil
            },

            [Card.CARD_REVERSE_TOWER] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 540, -- Reverse Tower
            },

            [Card.CARD_REVERSE_STARS] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 541, -- Reverse Stars
            },

            [Card.CARD_REVERSE_MOON] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 542, -- Reverse Sun and Moon
            },

            [Card.CARD_REVERSE_SUN] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 542, -- Reverse Sun and Moon
            },

            [Card.CARD_REVERSE_JUDGEMENT] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 543, -- Reverse Judgement
            },

            [Card.CARD_REVERSE_WORLD] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 544, -- Reverse Worl
            },


            -- Playing cards
            [Card.CARD_ACE_OF_CLUBS] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 322, -- Ace of Clubs
            },

            [Card.CARD_ACE_OF_DIAMONDS] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 326, -- Ace of Diamonds
            },

            [Card.CARD_ACE_OF_SPADES] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 327, -- Ace of Spades
            },

            [Card.CARD_QUEEN_OF_HEARTS] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 602, -- Queen of Hearts
            },

            [Card.CARD_SUICIDE_KING] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 120, -- Suicide King
            },

            [Card.CARD_RULES] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 99, -- Rules Card
            },


            -- Special cards
            [Card.CARD_CHAOS] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 97, -- Chaos Card
            },

            [Card.CARD_HUGE_GROWTH] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 361, -- Huge Growth
            },

            [Card.CARD_ANCIENT_RECALL] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 362, -- Ancient Recall
            },

            [Card.CARD_ERA_WALK] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 363, -- Era Walk
            },

            [Card.CARD_CREDIT] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 98, -- Credit Card
            },

            [Card.CARD_HUMANITY] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 100, -- Card Against Humanity
            },

            [Card.CARD_GET_OUT_OF_JAIL] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 225, -- Get out of Jail Free Card
            },

            [Card.CARD_HOLY] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 293, -- Holy Card
            },

            [Card.CARD_WILD] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 610, -- Wild Card
            },


            -- Runes (still replaced by Tarot Cards)
            [Card.RUNE_HAGALAZ] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 89, -- Hagalax
            },

            [Card.RUNE_JERA] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 90, -- Jera
            },

            [Card.RUNE_EHWAZ] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 91, -- Ehwaz
            },

            [Card.RUNE_DAGAZ] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 92, -- Dagaz
            },

            [Card.RUNE_ANSUZ] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 93, -- Ansuz
            },

            [Card.RUNE_PERTHRO] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 94, -- Perthro
            },

            [Card.RUNE_ALGIZ] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 96, -- Algiz
            },

            [Card.RUNE_BLANK] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 233, -- Blank Rune
            },

            [Card.RUNE_BLACK] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 309, -- Black Rune
            },


            -- Soul Stones
            [Card.CARD_SOUL_ISAAC] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 618, -- Soul of Isaac
            },

            [Card.CARD_SOUL_MAGDALENE] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 619, -- Soul of Magdalene
            },

            [Card.CARD_SOUL_CAIN] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 620, -- Soul of Cain
            },

            [Card.CARD_SOUL_JUDAS] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 621, -- Soul of Judas
            },

            [Card.CARD_SOUL_BLUEBABY] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 622, -- Soul of ???
            },

            [Card.CARD_SOUL_EVE] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 623, -- Soul of Eve
            },

            [Card.CARD_SOUL_SAMSON] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 624, -- Soul of Samson
            },

            [Card.CARD_SOUL_AZAZEL] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 625, -- Soul of Azazel
            },

            [Card.CARD_SOUL_LAZARUS] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 626, -- Soul of Lazarus
            },

            [Card.CARD_SOUL_EDEN] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 627, -- Soul of Eve
            },

            [Card.CARD_SOUL_LOST] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 628, -- Soul of Lost
            },

            [Card.CARD_SOUL_LILITH] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 629, -- Soul of Lilith
            },

            [Card.CARD_SOUL_KEEPER] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 630, -- Soul of The Keeper
            },

            [Card.CARD_SOUL_APOLLYON] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 631, -- Soul of Apollyon
            },

            [Card.CARD_SOUL_FORGOTTEN] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 632, -- Soul of The Forgotten
            },

            [Card.CARD_SOUL_BETHANY] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 633, -- Soul of Bethany
            },

            [Card.CARD_SOUL_JACOB] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 634, -- Soul of Jacob and Esau
            },


            -- Objects
            [Card.CARD_CRACKED_KEY] = {
                Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_NULL},
                Achievement = 415, -- Red Key
            },
        },

        -- Horse pills, rune shards, and old chests are not replaced in vanilla
    },

    [EntityType.ENTITY_SLOT] = {
        -- Crane Game
        [16] = {
            Replacement = {EntityType.ENTITY_SLOT, 1, 0}, -- Slot Machine
            Achievement = 607, -- Crane Game
        },

        -- Confessional
        [17] = {
            Replacement = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL}, -- Yes this is accurate
            Achievement = 616, -- Confessional
        },
    },

    -- Special shopkeepers are not replaced in vanilla
}

-- Gets the replacement for a vanilla entity if it's locked and REPENTOGON is enabled, otherwise returns nil.
-- Replacement is {type, variant, subtype}.
function StageAPI.GetLockedEntityReplacement(entityType, entityVariant, entitySubType)
    if LockedEntities[entityType] then
        local info = LockedEntities[entityType][entityVariant]
        if info and not info.Replacement then
            info = LockedEntities[entityType][entityVariant][entitySubType]
        end

        if info and not StageAPI.TryCheckAchievement(info.Achievement) then
            return info.Replacement
        end
    end
end