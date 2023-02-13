local shared = require("scripts.stageapi.shared")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.LogMinor("Loading CustomStage Handler")

StageAPI.CustomStages = {}

---@class OverrideStage
---@field OverrideStage number
---@field OverrideStageType number
---@field ReplaceWith CustomStage
---@field GreedMode boolean

---@param name string
---@param replaces? OverrideStage #default: StageAPI.StageOverride.CatacombsOne
---@param noSetReplaces? boolean
function StageAPI.CustomStage(name, replaces, noSetReplaces)
end

---@class CustomStage : StageAPIClass
---@field Music table<RoomType, Music>
StageAPI.CustomStage = StageAPI.Class("CustomStage")

function StageAPI.CustomStage:Init(name, replaces, noSetReplaces)
    self.Name = name
    self.Alias = name

    if not noSetReplaces then
        self.Replaces = replaces or StageAPI.StageOverride.CatacombsOne
    end

    if name then
        StageAPI.CustomStages[name] = self
    end
end

function StageAPI.CustomStage:InheritInit(name, noSetAlias)
    if not noSetAlias then
        self.Alias = self.Name
    end

    self.Name = name
    if name then
        StageAPI.CustomStages[name] = self
    end
end

function StageAPI.CustomStage:SetName(name)
    self.Name = name or self.Name
    if self.Name then
        StageAPI.CustomStages[self.Name] = self
    end

end

function StageAPI.CustomStage:GetDisplayName()
    return self.DisplayName or self.Name
end

function StageAPI.CustomStage:SetDisplayName(name)
    self.DisplayName = name or self.DisplayName or self.Name
end

function StageAPI.CustomStage:SetReplace(replaces)
    self.Replaces = replaces
end

function StageAPI.CustomStage:SetNextStage(stage)
    self.NextStage = stage
end

function StageAPI.CustomStage:SetXLStage(stage)
    self.XLStage = stage
end

function StageAPI.CustomStage:SetStageNumber(num, stageHPNumber)
    self.StageNumber = num
    self.StageHPNumber = stageHPNumber or num
end

function StageAPI.CustomStage:SetNoChampions(bool)
    self.NoChampions = bool
end

function StageAPI.CustomStage:SetIgnoreDifficultyRules(bool)
    self.IgnoreDifficultyRules = bool
end

function StageAPI.CustomStage:SetIsSecondStage(isSecondStage)
    self.IsSecondStage = isSecondStage
end

-- If set, custom stage will use the layout of the stage specified, while still using the visuals / features of the override stage it replaces.
function StageAPI.CustomStage:SetLevelgenStage(stage, stageType)
    self.LevelgenStage = {
        Stage = stage,
        StageType = stageType or StageType.STAGETYPE_ORIGINAL
    }
end

function StageAPI.CustomStage:SetRoomGfx(gfx, rtype)
    if not self.RoomGfx then
        self.RoomGfx = {}
    end

    if type(rtype) == "table" then
        for _, roomtype in ipairs(rtype) do
            self.RoomGfx[roomtype] = gfx
        end
    else
        self.RoomGfx[rtype] = gfx
    end
end

function StageAPI.CustomStage:SetRooms(rooms, rtype, subtype)
    if not self.Rooms then
        self.Rooms = {}
    end

    if type(rooms) == "table" and rooms.Type ~= "RoomsList" then
        for rtype, rooms in pairs(rooms) do
            if not self.Rooms[rtype] then
                self.Rooms[rtype] = {}
            end

            if rooms.Type == "RoomsList" then
                self.Rooms[rtype].Default = rooms
            elseif type(rooms) == "table" then
                if not self.Rooms[rtype].Subtypes then
                    self.Rooms[rtype].Subtypes = {}
                end

                for subtype, rooms in pairs(rooms) do
                    if subtype == 0 then
                        self.Rooms[rtype].Default = rooms
                    else
                        self.Rooms[rtype].Subtypes[subtype] = rooms
                    end
                end
            end
        end
    else
        rtype = rtype or RoomType.ROOM_DEFAULT
        if not self.Rooms[rtype] then
            self.Rooms[rtype] = {}
        end

        if subtype then
            if not self.Rooms[rtype].Subtypes then
                self.Rooms[rtype].Subtypes = {}
            end

            self.Rooms[rtype].Subtypes[subtype] = rooms
        else
            self.Rooms[rtype].Default = rooms
        end
    end
end

local DIMENSION_DEATH_CERTIFICATE = 2

function StageAPI.CustomStage:WillOverrideRoom(roomDesc)
    local rtype = roomDesc.Data.Type
    local isStartingRoom = roomDesc.SafeGridIndex == shared.Level:GetStartingRoomIndex()
    local dimension = StageAPI.GetDimension(roomDesc)

    if dimension == DIMENSION_DEATH_CERTIFICATE then
        return false
    elseif rtype == RoomType.ROOM_BOSS and self.Bosses then
        return true
    elseif isStartingRoom and self.StartingRooms then
        return true
    elseif self.Rooms[rtype] then
        local rooms = self.Rooms[rtype]
        local subtype = roomDesc.Data.Subtype
        if rooms.Default or (rooms.Subtypes and rooms.Subtypes[subtype]) then
            return true
        end
    end

    return false
end

function StageAPI.CustomStage:SetChallengeWaves(rooms, bossChallengeRooms)
    self.ChallengeWaves = {
        Normal = rooms,
        Boss = bossChallengeRooms
    }
end

function StageAPI.CustomStage:SetGreedModeWaves(rooms, bossRooms, devilRooms)
    self.GreedWaves = {
        Normal = rooms,
        Boss = bossRooms,
        Devil = devilRooms
    }
end

---@param music Music
---@param rtype RoomType
function StageAPI.CustomStage:SetMusic(music, rtype)
    if not self.Music then
        self.Music = {}
    end

    if type(rtype) == "table" then
        for _, roomtype in ipairs(rtype) do
            self.Music[roomtype] = music
        end
    else
        self.Music[rtype] = music
    end
end

function StageAPI.CustomStage:SetStageMusic(music)
    self:SetMusic(music, {
        RoomType.ROOM_DEFAULT,
        RoomType.ROOM_TREASURE,
        RoomType.ROOM_CURSE,
        RoomType.ROOM_CHALLENGE,
        RoomType.ROOM_BARREN,
        RoomType.ROOM_ISAACS,
        RoomType.ROOM_SACRIFICE,
        RoomType.ROOM_DICE,
        RoomType.ROOM_CHEST,
        RoomType.ROOM_DUNGEON
    })
end

function StageAPI.CustomStage:SetTransitionMusic(music)
    self.TransitionMusic = music
    StageAPI.StopOverridingMusic(music)
end

function StageAPI.CustomStage:SetBossMusic(music, clearedMusic, intro, outro)
    self.BossMusic = {
        Fight = music,
        Cleared = clearedMusic,
        Intro = intro,
        Outro = outro
    }
end

-- By default, miniboss = sins
function StageAPI.CustomStage:SetMinibossMusic(music, clearedMusic, intro, outro)
    self.MinibossMusic = {
        Fight = music,
        Cleared = clearedMusic,
        Intro = intro,
        Outro = outro
    }
end

function StageAPI.CustomStage:SetChallengeMusic(music, clearedMusic, intro, outro)
    self.ChallengeMusic = {
        Fight = music,
        Cleared = clearedMusic,
        Intro = intro,
        Outro = outro
    }
end

function StageAPI.CustomStage:SetRenderStartingRoomControls(doRender)
    self.RenderStartingRoomControls = doRender
end

function StageAPI.CustomStage:SetFloorTextColor(color)
    self.FloorTextColor = color
end

function StageAPI.CustomStage:SetSpots(bossSpot, playerSpot, bgColor, dirtColor)
    self.BossSpot = bossSpot
    self.PlayerSpot = playerSpot
    self.BackgroundColor = bgColor      --info: https://imgur.com/a/HFigk7d
    self.DirtColor = dirtColor
end

function StageAPI.CustomStage:SetTrueCoopSpots(twoPlayersSpot, fourPlayersSpot, threePlayersSpot) -- if a three player spot is not defined, uses four instead.
    self.CoopSpot2P = twoPlayersSpot
    self.CoopSpot3P = threePlayersSpot
    self.CoopSpot4P = fourPlayersSpot
end

function StageAPI.CustomStage:SetBosses(bosses)
    if bosses.Pool then
        self.Bosses = bosses
    else
        self.Bosses = {
            Pool = bosses
        }
    end
end

StageAPI.SinsSplitData = {
    {
        Type = EntityType.ENTITY_GLUTTONY,
        Variant = 0,
        ListName = "Gluttony",
        MultipleListName = "SuperGluttony"
    },
    {
        Type = EntityType.ENTITY_ENVY,
        Variant = 0,
        ListName = "Envy",
        MultipleListName = "SuperEnvy"
    },
    {
        Type = EntityType.ENTITY_GREED,
        Variant = 0,
        ListName = "Greed",
        MultipleListName = "SuperGreed"
    },
    {
        Type = EntityType.ENTITY_WRATH,
        Variant = 0,
        ListName = "Wrath",
        MultipleListName = "SuperWrath"
    },
    {
        Type = EntityType.ENTITY_PRIDE,
        Variant = 0,
        ListName = "Pride",
        MultipleListName = "SuperPride"
    },
    {
        Type = EntityType.ENTITY_LUST,
        Variant = 0,
        ListName = "Lust",
        MultipleListName = "SuperLust"
    },
    {
        Type = EntityType.ENTITY_SLOTH,
        Variant = 0,
        ListName = "Sloth",
        MultipleListName = "SuperSloth"
    },
    {
        Type = EntityType.ENTITY_GLUTTONY,
        Variant = 1,
        ListName = "SuperGluttony"
    },
    {
        Type = EntityType.ENTITY_ENVY,
        Variant = 1,
        ListName = "SuperEnvy"
    },
    {
        Type = EntityType.ENTITY_GREED,
        Variant = 1,
        ListName = "SuperGreed"
    },
    {
        Type = EntityType.ENTITY_WRATH,
        Variant = 1,
        ListName = "SuperWrath"
    },
    {
        Type = EntityType.ENTITY_PRIDE,
        Variant = 1,
        ListName = "SuperPride"
    },
    {
        Type = EntityType.ENTITY_LUST,
        Variant = 1,
        ListName = "SuperLust"
    },
    {
        Type = EntityType.ENTITY_SLOTH,
        Variant = 1,
        ListName = "SuperSloth"
    },
    {
        Type = EntityType.ENTITY_SLOTH,
        Variant = 2,
        ListName = "UltraPride"
    }
}

---Set rooms for sins; noSuperSins should be true in stages
-- equivalent to chapter one to match vanilla behavior
---@param sins string | {[string]: RoomsList}
---@param noSuperSins? boolean
function StageAPI.CustomStage:SetSinRooms(sins, noSuperSins)
    if type(sins) == "string" then -- allows passing in a prefix to a room list name, which all sins can be grabbed from
        self.SinRooms = {}
        for _, sin in ipairs(StageAPI.SinsSplitData) do
            self.SinRooms[sin.ListName] = StageAPI.RoomsLists[sins .. sin.ListName]
        end
    else
        self.SinRooms = sins
    end

    self.NoSuperSins = noSuperSins
end

function StageAPI.CustomStage:SetStartingRooms(starting)
    self.StartingRooms = starting
end

---@param stage CustomStage
local function SinMatchesSplitData(stage, entry, sin)
    -- For chapter 1 stages (set as a stage field NoSuperSins)
    -- replace super sin rooms with normal sin rooms
    local variantToUse = entry.Variant
    local replacedSuper = false
    if stage.NoSuperSins then
        variantToUse = 0
        replacedSuper = entry.Variant > 0
    end

    return entry.Type == sin.Type 
        and (sin.Variant and variantToUse == sin.Variant) 
        and (
            (sin.ListName and stage.SinRooms[sin.ListName]) 
            or (sin.MultipleListName and stage.SinRooms[sin.MultipleListName])
        ),
        replacedSuper and (sin.ListName or sin.MultipleListName)
end

local DIMENSION_DEATH_CERTIFICATE = 2

-- To more easily replace GenerateRoom on your stage, can call this function after running custom generation logic
---@param currentStage CustomStage
---@param roomDescriptor? RoomDescriptor
---@param isStartingRoom? boolean
---@param fromLevelGenerator? boolean
---@param roomArgs? LevelRoomArgs
---@return LevelRoom?
---@return BossData?
function StageAPI.CustomStageGenerateRoom(currentStage, roomDescriptor, isStartingRoom, fromLevelGenerator, roomArgs)
    local roomData
    if roomDescriptor then
        if roomDescriptor.OverrideData then
            roomData = roomDescriptor.OverrideData
        else
            roomData = roomDescriptor.Data
        end
    end

    local rtype = (roomArgs and roomArgs.RoomType) or (roomData and roomData.Type) or RoomType.ROOM_DEFAULT
    local shape = (roomArgs and roomArgs.Shape) or (roomData and roomData.Shape) or RoomShape.ROOMSHAPE_1x1
    local subtype = (roomArgs and roomArgs.Subtype) or (roomData and roomData.Subtype) or 0
    local dimension = StageAPI.GetDimension(roomDescriptor)

    if currentStage.SinRooms and (rtype == RoomType.ROOM_MINIBOSS or rtype == RoomType.ROOM_SECRET or rtype == RoomType.ROOM_SHOP) then
        local usingRoomsList
        local includedSins = {}
        local lastReplacedSuperSin

        if roomData then
            StageAPI.ForAllSpawnEntries(roomData, function(entry, spawn)
                for i, sin in ipairs(StageAPI.SinsSplitData) do
                    local matches, replacedSuper = SinMatchesSplitData(currentStage, entry, sin)
                    if matches  then
                        if not includedSins[i] then
                            includedSins[i] = 0
                        end

                        includedSins[i] = includedSins[i] + 1
                        lastReplacedSuperSin = replacedSuper or lastReplacedSuperSin
                        break
                    end
                end
            end)
        else
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                for i, sin in ipairs(StageAPI.SinsSplitData) do
                    local matches, replacedSuper = SinMatchesSplitData(currentStage, entity, sin)
                    if matches  then
                        if not includedSins[i] then
                            includedSins[i] = 0
                        end

                        includedSins[i] = includedSins[i] + 1
                        lastReplacedSuperSin = replacedSuper or lastReplacedSuperSin
                        break
                    end
                end
            end
        end

        for ind, count in pairs(includedSins) do
            local sin = StageAPI.SinsSplitData[ind]
            local listName = sin.ListName
            if count > 1 and sin.MultipleListName then
                listName = sin.MultipleListName
            end

            usingRoomsList = currentStage.SinRooms[listName]
        end

        if usingRoomsList then
            if usingRoomsList:GetRooms(shape) then
                local replaceVsText
                if lastReplacedSuperSin then
                    replaceVsText = StageAPI.SanitizeString(shared.Players[1]:GetName()) .. " VS " .. lastReplacedSuperSin
                end

                local newRoom = StageAPI.LevelRoom(StageAPI.Merged({
                    RoomsList = usingRoomsList,
                    RoomDescriptor = roomDescriptor,
                    RequireRoomType = currentStage.RequireRoomTypeSin,
                    ReplaceVSStreak = replaceVsText,
                }, roomArgs))

                return newRoom
            end
        end
    end

    if not isStartingRoom and currentStage.Rooms and currentStage.Rooms[rtype]
    and dimension ~= DIMENSION_DEATH_CERTIFICATE 
    then
        local rooms = currentStage.Rooms[rtype].Default
        if currentStage.Rooms[rtype].Subtypes and currentStage.Rooms[rtype].Subtypes[subtype] ~= nil then -- can set rooms for a subtype to "false" to not override them
            rooms = currentStage.Rooms[rtype].Subtypes[subtype]
        end

        if rooms then
            local newRoom = StageAPI.LevelRoom(StageAPI.Merged({
                RoomsList = rooms,
                RoomDescriptor = roomDescriptor,
                RequireRoomType = currentStage.RequireRoomTypeMatching
            }, roomArgs))
            return newRoom
        end
    elseif isStartingRoom and currentStage.StartingRooms then
        local newRoom = StageAPI.LevelRoom(StageAPI.Merged({
            RoomsList = currentStage.StartingRooms,
            RoomDescriptor = roomDescriptor
        }, roomArgs))
        return newRoom
    end

    if currentStage.Bosses and rtype == RoomType.ROOM_BOSS then
        local newRoom, boss = StageAPI.GenerateBossRoom({
            Bosses = currentStage.Bosses,
            CheckEncountered = true,
            NoPlayBossAnim = fromLevelGenerator
        }, StageAPI.Merged({
            RoomDescriptor = roomDescriptor,
            RequireRoomType = currentStage.RequireRoomTypeBoss
        }, roomArgs))

        return newRoom, boss
    end
end

function StageAPI.CustomStage:GenerateRoom(roomDescriptor, isStartingRoom, fromLevelGenerator, roomArgs)
    StageAPI.LogMinor("Generating room for stage " .. self:GetDisplayName())
    return StageAPI.CustomStageGenerateRoom(self, roomDescriptor, isStartingRoom, fromLevelGenerator, roomArgs)
end

-- Replace sin VS streak if they were replaced
---@param levelRoom LevelRoom
---@param wasFirstLoad boolean
---@param isExtraRoom boolean
StageAPI.AddCallback("StageAPI", Callbacks.POST_ROOM_LOAD, 0, function(levelRoom, wasFirstLoad, isExtraRoom)
    if not levelRoom.IsClear and levelRoom.ReplaceVSStreak then
        shared.Game:GetHUD():ShowItemText(levelRoom.ReplaceVSStreak, "")
    end
end)

function StageAPI.CustomStage:SetPregenerationEnabled(setTo)
    self.PregenerationEnabled = setTo
end

function StageAPI.CustomStage:HasMirrorDimension()
    return (self.LevelgenStage.Stage == LevelStage.STAGE1_2 and (self.LevelgenStage.StageType == StageType.STAGETYPE_REPENTANCE or self.LevelgenStage.StageType == StageType.STAGETYPE_REPENTANCE_B))
end

function StageAPI.CustomStage:GenerateLevel()
    if not self.PregenerationEnabled then
        return
    end

    local startingRoomIndex = shared.Level:GetStartingRoomIndex()
    local roomsList = shared.Level:GetRooms()
    local hasMirror = self:HasMirrorDimension()
    for i = 0, roomsList.Size - 1 do
        local roomDesc = roomsList:Get(i)
        if roomDesc and not (hasMirror and StageAPI.GetDimension(roomDesc) == 1) then
            local isStartingRoom = startingRoomIndex == roomDesc.SafeGridIndex
            local newRoom = self:GenerateRoom(roomDesc, isStartingRoom, true)
            if newRoom then
                local listIndex = roomDesc.ListIndex
                StageAPI.SetLevelRoom(newRoom, listIndex)

                if hasMirror and roomDesc.SafeGridIndex > -1 and StageAPI.GetDimension(roomDesc) == 0 then
                    local mirroredRoom = newRoom:Copy(roomDesc)
					local mirroredDesc = shared.Level:GetRoomByIdx(roomDesc.SafeGridIndex, 1)
					StageAPI.SetLevelRoom(mirroredRoom, mirroredDesc.ListIndex, 1)
                    StageAPI.LogMinor("Mirroring!")
                end
            end
        end
    end
end

---@return Music? musicId
---@return boolean? shouldLayer
---@return Music? shouldQueue
---@return boolean? disregardNonOverride
function StageAPI.CustomStage:GetPlayingMusic()
    local roomType = shared.Room:GetType()
    local id = shared.Music:GetCurrentMusicID()
    local roomDesc = shared.Level:GetCurrentRoomDesc()
    if roomType == RoomType.ROOM_BOSS then
        if self.BossMusic then
            local music = self.BossMusic
            local musicID, queue, disregardNonOverride
            local isCleared = shared.Room:GetAliveBossesCount() < 1 or shared.Room:IsClear()

            if (music.Outro and (id == Music.MUSIC_JINGLE_BOSS_OVER or id == Music.MUSIC_JINGLE_BOSS_OVER2 or id == music.Outro or (type(music.Outro) == "table" and StageAPI.IsIn(music.Outro, id))))
            or (music.Intro and (id == Music.MUSIC_JINGLE_BOSS or id == music.Intro or (type(music.Intro) == "table" and StageAPI.IsIn(music.Intro, id)))) then
                if id == Music.MUSIC_JINGLE_BOSS or id == music.Intro or (type(music.Intro) == "table" and StageAPI.IsIn(music.Intro, id)) then
                    musicID, queue = music.Intro, music.Fight
                else
                    musicID, queue = music.Outro, music.Cleared
                end

                disregardNonOverride = true
            else
                if isCleared then
                    musicID = music.Cleared
                else
                    musicID = music.Fight
                end
            end

            if type(musicID) == "table" then
                StageAPI.MusicRNG:SetSeed(shared.Room:GetDecorationSeed(), 0)
                musicID = musicID[StageAPI.Random(1, #musicID, StageAPI.MusicRNG)]
            end

            local newMusicID = StageAPI.CallCallbacks(Callbacks.POST_SELECT_BOSS_MUSIC, true, self, musicID, isCleared, StageAPI.MusicRNG)
            if newMusicID then
                musicID = newMusicID
            end

            if musicID then
                return musicID, not shared.Room:IsClear(), queue, disregardNonOverride
            end
        end
    elseif roomDesc.SurpriseMiniboss or roomType == RoomType.ROOM_MINIBOSS then
        if self.MinibossMusic then
            local music = self.MinibossMusic
            local musicID, queue, disregardNonOverride
            local isCleared = shared.Room:GetAliveBossesCount() < 1 or shared.Room:IsClear()

            if (music.Outro and (id == Music.MUSIC_JINGLE_BOSS_OVER or id == Music.MUSIC_JINGLE_BOSS_OVER2 or id == music.Outro or (type(music.Outro) == "table" and StageAPI.IsIn(music.Outro, id))))
            or (music.Intro and (id == Music.MUSIC_JINGLE_BOSS or id == music.Intro or (type(music.Intro) == "table" and StageAPI.IsIn(music.Intro, id)))) then
                if id == Music.MUSIC_JINGLE_BOSS or id == music.Intro or (type(music.Intro) == "table" and StageAPI.IsIn(music.Intro, id)) then
                    musicID, queue = music.Intro, music.Fight
                else
                    musicID, queue = music.Outro, music.Cleared
                end

                disregardNonOverride = true
            else
                if isCleared then
                    musicID = music.Cleared
                else
                    musicID = music.Fight
                end
            end

            if type(musicID) == "table" then
                StageAPI.MusicRNG:SetSeed(shared.Room:GetDecorationSeed(), 0)
                musicID = musicID[StageAPI.Random(1, #musicID, StageAPI.MusicRNG)]
            end

            local newMusicID = StageAPI.CallCallbacks(Callbacks.POST_SELECT_MINIBOSS_MUSIC, true, self, musicID, isCleared, StageAPI.MusicRNG)
            if newMusicID then
                musicID = newMusicID
            end

            if musicID then
                return musicID, not shared.Room:IsClear(), queue, disregardNonOverride
            end
        end
    elseif roomType ~= RoomType.ROOM_CHALLENGE 
    or not (shared.Room:IsAmbushActive() or shared.Room:IsAmbushDone())
    then
        local music = self.Music
        if music then
            local musicID = music[roomType]
            local newMusicID = StageAPI.CallCallbacks(Callbacks.POST_SELECT_STAGE_MUSIC, true, self, musicID, roomType, StageAPI.MusicRNG)
            if newMusicID then
                musicID = newMusicID
            end

            if musicID then
                return musicID, not shared.Room:IsClear()
            end
        end
    else -- challenge room active/done
        if self.ChallengeMusic then
            local music = self.ChallengeMusic
            local musicID, queue, disregardNonOverride
            local isCleared = shared.Room:IsAmbushDone()

            if (
                music.Outro and (
                    id == Music.MUSIC_JINGLE_CHALLENGE_OUTRO 
                    or id == music.Outro 
                    or (type(music.Outro) == "table" and StageAPI.IsIn(music.Outro, id))
                )
            )
            or (
                music.Intro and (
                    id == Music.MUSIC_JINGLE_CHALLENGE_ENTRY 
                    or id == music.Intro 
                    or (type(music.Intro) == "table" and StageAPI.IsIn(music.Intro, id))
                )
            ) 
            then
                if id == Music.MUSIC_JINGLE_CHALLENGE_ENTRY 
                or id == music.Intro 
                or (type(music.Intro) == "table" and StageAPI.IsIn(music.Intro, id)) then
                    musicID, queue = music.Intro, music.Fight
                else
                    musicID, queue = music.Outro, music.Cleared
                end

                disregardNonOverride = true
            else
                if isCleared then
                    musicID = music.Cleared
                else
                    musicID = music.Fight
                end
            end

            if type(musicID) == "table" then
                StageAPI.MusicRNG:SetSeed(shared.Room:GetDecorationSeed(), 0)
                musicID = musicID[StageAPI.Random(1, #musicID, StageAPI.MusicRNG)]
            end

            local newMusicID = StageAPI.CallCallbacks(Callbacks.POST_SELECT_CHALLENGE_MUSIC, true, self, musicID, isCleared, StageAPI.MusicRNG)
            if newMusicID then
                musicID = newMusicID
            end

            if musicID then
                return musicID, not shared.Room:IsClear(), queue, disregardNonOverride
            end
        end
    end
end

function StageAPI.CustomStage:OverrideRockAltEffects(rooms)
    self.OverridingRockAltEffects = rooms or true
end

function StageAPI.CustomStage:OverrideTrapdoors()
    self.OverridingTrapdoors = true
end

function StageAPI.CustomStage:SetTransitionIcon(icon, ground, bg)
    self.TransitionIcon = icon
    self.TransitionGround = ground
    self.TransitionBackground = bg
end

function StageAPI.IsSameStage(base, comp, noAlias)
    if not base then return false end

    return base.Name == comp.Name or (not noAlias and base.Alias == comp.Alias)
end

function StageAPI.CustomStage:IsStage(noAlias)
    return StageAPI.IsSameStage(StageAPI.CurrentStage, self, noAlias)
end

function StageAPI.CustomStage:IsNextStage(noAlias)
    return StageAPI.IsSameStage(StageAPI.NextStage, self, noAlias)
end

function StageAPI.CustomStage:SetRequireRoomTypeMatching()
    self.RequireRoomTypeMatching = true
end

function StageAPI.CustomStage:SetRequireRoomTypeBoss()
    self.RequireRoomTypeBoss = true
end

function StageAPI.CustomStage:SetRequireRoomTypeSin()
    self.RequireRoomTypeSin = true
end

function StageAPI.ShouldPlayStageMusic()
    return shared.Room:GetType() == RoomType.ROOM_DEFAULT or shared.Room:GetType() == RoomType.ROOM_TREASURE, not shared.Room:IsClear()
end