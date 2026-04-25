-- Boss Subtype = { id, isTrinket }
-- -1 is a random worm trinket

local ThemedDrops = {
	[1] = { CollectibleType.COLLECTIBLE_MONSTROS_TOOTH, }, -- Monstro
	[2] = { -1, true }, -- Larry Jr.
	[3] = { CollectibleType.COLLECTIBLE_LITTLE_CHUBBY, }, -- Chub
	[4] = { CollectibleType.COLLECTIBLE_LIL_GURDY, }, -- Gurdy
	[5] = { CollectibleType.COLLECTIBLE_MONSTROS_LUNG, }, -- Monstro II
	-- Mom
	[7] = { -1, true }, -- Scolex
	-- Mom's Heart
	[9] = { TrinketType.TRINKET_LOCUST_OF_FAMINE, true }, -- Famine
	[10] = { TrinketType.TRINKET_LOCUST_OF_PESTILENCE, true }, -- Pestilence
	[11] = { TrinketType.TRINKET_LOCUST_OF_WRATH, true }, -- War
	[12] = { TrinketType.TRINKET_LOCUST_OF_DEATH, true }, -- Death
	[13] = { CollectibleType.COLLECTIBLE_HALO_OF_FLIES, }, -- Duke of Flies
	[14] = { CollectibleType.COLLECTIBLE_FREE_LEMONADE, }, -- Peep
	[15] = { CollectibleType.COLLECTIBLE_LOKIS_HORNS, }, -- Loki
	[16] = { CollectibleType.COLLECTIBLE_LIL_SPEWER, }, -- Blastocyst
	[17] = { CollectibleType.COLLECTIBLE_GEMINI, }, -- Gemini
	[18] = { CollectibleType.COLLECTIBLE_LEPROSY, }, -- Fistula
	-- Gish
	-- Steven
	-- C.H.A.D.
	-- Headless Horseman
	[23] = { CollectibleType.COLLECTIBLE_BRIMSTONE_BOMBS, }, -- The Fallen
	-- Satan
	-- It Lives
	[26] = { -1, true }, -- The Hollow
	[27] = { CollectibleType.COLLECTIBLE_BONE_SPURS, }, -- Carrion Queen
	[28] = { CollectibleType.COLLECTIBLE_LIL_GURDY, }, -- Gurdy Jr.
	[29] = { CollectibleType.COLLECTIBLE_INFESTATION, }, -- The Husk
	[30] = { CollectibleType.COLLECTIBLE_PEEPER, }, -- The Bloat
	[31] = { CollectibleType.COLLECTIBLE_LIL_LOKI, }, -- Lokii
	[32] = { CollectibleType.COLLECTIBLE_LOST_SOUL, }, -- Blighted Ovum
	[33] = { CollectibleType.COLLECTIBLE_TINYTOMA, }, -- Teratoma
	[34] = { CollectibleType.COLLECTIBLE_SPIDERBABY, }, -- The Widow
	[35] = { CollectibleType.COLLECTIBLE_INFAMY, }, -- Mask of Infamy
	[36] = { CollectibleType.COLLECTIBLE_JUICY_SACK, }, -- The Wretched
	[37] = { -1, true }, -- Pin
	[38] = { TrinketType.TRINKET_LOCUST_OF_CONQUEST, true }, -- Conquest
	-- Isaac
	-- ???
	[41] = { CollectibleType.COLLECTIBLE_DADDY_LONGLEGS, }, -- Daddy Long Legs
	[42] = { CollectibleType.COLLECTIBLE_SPIDER_BITE, }, -- Triachnid
	[43] = { CollectibleType.COLLECTIBLE_LIL_HAUNT, }, -- The Haunt
	[44] = { CollectibleType.COLLECTIBLE_POOP, }, -- Dingle
	[45] = { CollectibleType.COLLECTIBLE_CONTINUUM, }, -- Mega Maw
	[46] = { CollectibleType.COLLECTIBLE_HOST_HAT, }, -- The Gate
	[47] = { CollectibleType.COLLECTIBLE_THUNDER_THIGHS, }, -- Mega Fatty
	[48] = { CollectibleType.COLLECTIBLE_BIRD_CAGE, }, -- The Cage
	[49] = { CollectibleType.COLLECTIBLE_LIL_GURDY, }, -- Mama Gurdy
	[50] = { CollectibleType.COLLECTIBLE_DARK_MATTER, }, -- Dark One
	[51] = { CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT, }, -- Adversary
	[52] = { CollectibleType.COLLECTIBLE_GIANT_CELL, }, -- Polycephalus
	[53] = { CollectibleType.COLLECTIBLE_HARLEQUIN_BABY, }, -- Mr. Fred
	-- The Lamb
	-- Mega Satan
	[56] = { CollectibleType.COLLECTIBLE_LIL_GURDY, }, -- Gurglings
	[57] = { CollectibleType.COLLECTIBLE_WORM_FRIEND, }, -- The Stain
	[58] = { CollectibleType.COLLECTIBLE_DIRTY_MIND, }, -- Brownie
	[59] = { CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD, }, -- The Forsaken
	[60] = { CollectibleType.COLLECTIBLE_LITTLE_HORN, }, -- Little Horn
	[61] = { CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS, }, -- Rag Man
	-- Ultra Greed
	-- Hush
	[64] = { CollectibleType.COLLECTIBLE_MONTEZUMAS_REVENGE, }, -- Dangle
	[65] = { CollectibleType.COLLECTIBLE_NUMBER_TWO, }, -- Turdlings
	[66] = { CollectibleType.COLLECTIBLE_BRITTLE_BONES, }, -- The Frail
	[67] = { CollectibleType.COLLECTIBLE_SPOON_BENDER, }, -- Rag Mega
	[68] = { CollectibleType.COLLECTIBLE_GIMPY, }, -- Sisters Vis
	[69] = { CollectibleType.COLLECTIBLE_LITTLE_HORN, }, -- Big Horn
	-- Delirium
	-- Ultra Greedier
	[72] = { CollectibleType.COLLECTIBLE_BIG_CHUBBY, }, -- The Matriarch
	[73] = { CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE, }, -- The Pile
	[74] = { CollectibleType.COLLECTIBLE_THE_WIZ, }, -- Reap Creep
	[75] = { CollectibleType.COLLECTIBLE_AQUARIUS, }, -- Lil Blub
	[76] = { CollectibleType.COLLECTIBLE_LEECH, }, -- Wormwood
	[77] = { CollectibleType.COLLECTIBLE_DEPRESSION, }, -- Rainmaker
	[78] = { CollectibleType.COLLECTIBLE_EMPTY_HEART, }, -- The Visage
	[79] = { TrinketType.TRINKET_FORGOTTEN_LULLABY, true }, -- The Siren
	[80] = { CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL, }, -- Tuff Twins
	[81] = { CollectibleType.COLLECTIBLE_CEREMONIAL_ROBES, }, -- The Heretic
	[82] = { CollectibleType.COLLECTIBLE_HOT_BOMBS, }, -- Hornfel
	[83] = { CollectibleType.COLLECTIBLE_GNAWED_LEAF, }, -- Great Gideon
	-- Baby Plum
	[85] = { CollectibleType.COLLECTIBLE_MAGIC_SKIN, }, -- The Scourge
	[86] = { CollectibleType.COLLECTIBLE_DECAP_ATTACK, }, -- Chimera
	[87] = { CollectibleType.COLLECTIBLE_YUCK_HEART, }, -- Rotgut
	-- Mother
	-- Mausoleum Mom
	-- Mausoleum Mom's Heart
	[91] = { CollectibleType.COLLECTIBLE_SMART_FLY, }, -- Min-Min
	[92] = { CollectibleType.COLLECTIBLE_FLUSH, }, -- Clog
	[93] = { CollectibleType.COLLECTIBLE_BIRDS_EYE, }, -- Singe
	-- Bumbino
	[95] = { CollectibleType.COLLECTIBLE_BUTT_BOMBS, }, -- Colostomia
	[96] = { CollectibleType.COLLECTIBLE_AKELDAMA, }, -- The Shell
	[97] = { CollectibleType.COLLECTIBLE_BROWN_NUGGET, }, -- Turdlet
	-- Raglich
	-- Dogma
	-- The Beast
	[101] = { TrinketType.TRINKET_THE_TWINS, true }, -- Horny Boys
	[102] = { CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION, }, -- Clutch
	-- Cadavra
}

-- Check if the given pickup is a themed drop for the current room
function StageAPI.IsThemedBossDrop(variant, subType, roomSubType)
	local entry = ThemedDrops[roomSubType]

	if entry then
		local isTrinket = entry[2]

		if (variant == PickupVariant.PICKUP_COLLECTIBLE and not isTrinket)
		or (variant == PickupVariant.PICKUP_TRINKET 	   and 	   isTrinket) then
			return subType == entry[1]
		end
	end
	return false
end