local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

---@return RoomMetadata
function StageAPI.RoomMetadata()
end

---@class RoomMetadata
---@field LevelRoom LevelRoom
---@field BlockedEntities table<integer, EntityDef[]>
---@field IndexMetadata table<integer, MetadataEntity[]>
---@field Groups table<GroupID, table<integer, boolean>>
StageAPI.RoomMetadata = StageAPI.Class("RoomMetadata")
function StageAPI.RoomMetadata:Init()
    self.Groups = {}
    self.BlockedEntities = {}
    self.IndexMetadata = {}
end

---@alias GroupID integer

---@class EntityMeta
---@field Name string
---@field Tags string[]
---@field Tag string
---@field BitValues table<string, {Offset: integer, Length: integer}>
---@field ConflictTag string
---@field GroupID GroupID
---@field StoreAsGroup boolean
---@field Type integer
---@field Variant integer
---@field HasPersistentData boolean
---@field NoBlockIfTriggered boolean
---@field GroupIDIfUngrouped GroupID

---@class MetadataEntity
---@field Name string
---@field Metadata EntityMeta
---@field Entity EntityDef
---@field Index integer
---@field BitValues table
---@field PersistentIndex integer


---@class EntityMetaArgs : EntityMeta
---@field Tag string
---@field Group GroupID deprecated
---@field Conflicts string deprecated

---@param index integer
---@return GroupID[]
function StageAPI.RoomMetadata:GroupsWithIndex(index)
    local groups = {}
    for groupID, indices in pairs(self.Groups) do
        if indices[index] or not index then
            groups[#groups + 1] = groupID
        end
    end

    return groups
end

---@param index integer
---@param group GroupID
---@return boolean
function StageAPI.RoomMetadata:IsIndexInGroup(index, group)
    return self.Groups[group] and self.Groups[group][index]
end

---@param group GroupID
---@return integer[]
function StageAPI.RoomMetadata:IndicesInGroup(group)
    local indices = self.Groups[group]
    local out = {}
    for index, _ in pairs(indices) do
        out[#out + 1] = index
    end

    return out
end

---@param index integer
---@param group GroupID
function StageAPI.RoomMetadata:AddIndexToGroup(index, group)
    if type(index) == "table" then
        for _, idx in ipairs(index) do
            self:RemoveIndexFromGroup(idx, group)
        end
    elseif type(group) == "table" then
        for _, grp in ipairs(group) do
            self:RemoveIndexFromGroup(index, grp)
        end
    else
        if not self.Groups[group] then
            self.Groups[group] = {}
        end

        self.Groups[group][index] = true
    end
end

---@param index integer
---@param group GroupID
function StageAPI.RoomMetadata:RemoveIndexFromGroup(index, group)
    if type(index) == "table" then
        for _, idx in ipairs(index) do
            self:AddIndexToGroup(idx, group)
        end
    elseif type(group) == "table" then
        for _, grp in ipairs(group) do
            self:AddIndexToGroup(index, grp)
        end
    elseif self.Groups[group] and self.Groups[group][index] then
        self.Groups[group][index] = nil
    end
end

---@return integer
function StageAPI.RoomMetadata:GetNextGroupID()
    if not self.LastGroupID then
        self.LastGroupID = 0
    end

    self.LastGroupID = self.LastGroupID - 1
    return self.LastGroupID
end

---@param index integer
---@param entity? EntityDef | string
---@param persistentIndex? integer
---@return MetadataEntity
---@return integer? persistentIndex
function StageAPI.RoomMetadata:AddMetadataEntity(index, entity, persistentIndex) -- also accepts a name rather than an entity
    if not self.IndexMetadata[index] then
        self.IndexMetadata[index] = {}
    end

    local metadata
    local name
    if entity and type(entity) ~= "string" then
        metadata = StageAPI.GetMetadataEntity(entity)
        name = metadata.Name
    else
        if entity then
            name = entity
            entity = nil
        end

        metadata = StageAPI.GetMetadataByName(name)
    end

    local metaEntity = {
        Name = name,
        Metadata = metadata,
        Entity = entity,
        Index = index
    }

    if metadata.BitValues then
        local sub = 0
        if entity and entity.SubType then
            sub = entity.SubType
        end

        metaEntity.BitValues = {}
        for name, bitValue in pairs(metadata.BitValues) do
            local val = StageAPI.GetBits(sub, bitValue.Offset or 0, bitValue.Length) + (bitValue.ValueOffset or 0)
            metaEntity.BitValues[name] = val
        end
    end

    if metadata.HasPersistentData then
        if not persistentIndex and self.LevelRoom then
            persistentIndex = self.LevelRoom:GetNextPersistentIndex()
        else
            persistentIndex = (persistentIndex and persistentIndex + 1) or 0
        end

        metaEntity.PersistentIndex = persistentIndex
    end

    self.IndexMetadata[index][#self.IndexMetadata[index] + 1] = metaEntity

    return metaEntity, persistentIndex
end

---@param index integer
---@param setIfNot? boolean
---@return EntityDef[]
function StageAPI.RoomMetadata:GetBlockedEntities(index, setIfNot)
    if setIfNot and not self.BlockedEntities[index] then
        self.BlockedEntities[index] = {}
    end

    return self.BlockedEntities[index]
end

---@param index integer
---@param tbl EntityDef[]
function StageAPI.RoomMetadata:SetBlockedEntities(index, tbl)
    self.BlockedEntities[index] = tbl
end

--[[

METADATA SEARCH PARAMS

{
    Names = { -- Matches "Name" from metadata entity data
        string,
        ...
    },
    Name = string, -- Singular version of Names

    Indices = { -- List of indices to search for metadata entities on
        GridIndex,
        ...
    },
    Index = GridIndex, -- Singular version of Indices

    Groups = { -- List of group ids to search for metadata entities contained within
        GroupID,
        ...
    },
    Group = GroupID, -- Singular version of Groups
    RequireAllGroups = boolean, -- If set to true, will only return metadata entities within ALL of the specified groups.

    IndicesOrGroups = boolean, -- If set to true, will return if either Groups works out or Indices works out, rather than requiring both

    Tags = { -- List of tags to search for metadata entities with "Tag = string" matching the tag, or "Tags = {"string"}" containing the tag
        string,
        ...
    },
    Tag = string, -- Singular version of Tags
    RequireAllTags = boolean, -- If set to true, will only return metadata entities with ALL of the specified tags.

    Metadata = { -- Checks each metadata entity's data for the specified keys and values, only returns if all match
        Key = Value
    },

    Entity = { -- Checks each metadata entity for the specified keys and values, only returns if all match
        Key = Value
    },

    BitValues = { -- Checks each metadata entity's BitValues for the specified keys and values, only returns if all match
        Key = Value
    },

    IndexTable = boolean, -- If set to true, will return meta entities as a table formatted {[index] = {metaEntity, metaEntity}}
    IndexBooleanTable = boolean, -- If set to true, will return meta entities as a table formatted {[index] = true} for indices that have a matching metadata entity
}

]]

---@class EntityMeta.SearchParams
---@field Names string[]
---@field Name string
---@field Tags string[]
---@field Tag string
---@field RequireAllTags boolean
---@field Indices integer[]
---@field Index integer
---@field Groups any[] 
---@field Group any
---@field RequireAllGroups boolean
---@field IndicesOrGroups boolean
---@field Metadata table
---@field Entity table
---@field BitValues table
---@field IndexTable boolean
---@field IndexBooleanTable boolean

---@param index integer
---@param searchParams EntityMeta.SearchParams
---@param checkIndices? boolean
---@param checkGroups? boolean
---@return boolean
function StageAPI.RoomMetadata:IndexMatchesSearchParams(index, searchParams, checkIndices, checkGroups)
    if not checkIndices then
        checkIndices = searchParams.Indices or {}
        checkIndices[#checkIndices + 1] = searchParams.Index
        for _, index in ipairs(checkIndices) do
            checkIndices[index] = true
        end
    end

    local indexMatches = true
    if #checkIndices > 0 and not checkIndices[index] then
        if searchParams.IndicesOrGroups then
            indexMatches = false
        else
            return false
        end
    end

    if not checkGroups then
        checkGroups = searchParams.Groups or {}
        checkGroups[#checkGroups + 1] = searchParams.Group
    end

    local groupMatches = true
    if #checkGroups > 0 then
        local hasGroup
        for _, groupID in ipairs(checkGroups) do
            if self.Groups[groupID] and self.Groups[groupID][index] then
                hasGroup = true
                if not searchParams.RequireAllGroups then
                    break
                end
            elseif searchParams.RequireAllGroups then
                if searchParams.IndicesOrGroups then
                    groupMatches = false
                else
                    return false
                end
            end
        end

        if not hasGroup then
            if searchParams.IndicesOrGroups then
                groupMatches = false
            else
                return false
            end
        end
    end

    if searchParams.IndicesOrGroups then
        return indexMatches or groupMatches
    else
        return true
    end
end

---@param metadataEntity MetadataEntity
---@param searchParams EntityMeta.SearchParams
---@param checkNames? boolean
---@param checkTags? boolean
---@return boolean
function StageAPI.RoomMetadata:EntityMatchesSearchParams(metadataEntity, searchParams, checkNames, checkTags)
    if not checkNames then
        checkNames = searchParams.Names or {}
        checkNames[#checkNames + 1] = searchParams.Name
    end

    if #checkNames > 0 and not StageAPI.IsIn(checkNames, metadataEntity.Name) then
        return false
    end

    local metadata = metadataEntity.Metadata

    if not checkTags then
        checkTags = searchParams.Tags or {}
        checkTags[#checkTags + 1] = searchParams.Tag
    end

    if #checkTags > 0 then
        local hasTag
        for _, tag in ipairs(checkTags) do
            if metadata.Tag == tag or (metadata.Tags and StageAPI.IsIn(metadata.Tags, tag)) then
                hasTag = true
                if not searchParams.RequireAllTags then
                    break
                end
            elseif searchParams.RequireAllTags then
                return false
            end
        end

        if not hasTag then
            return false
        end
    end

    if searchParams.Metadata then
        for k, v in pairs(searchParams.Metadata) do
            if metadata[k] ~= v then
                return false
            end
        end
    end

    if searchParams.Entity then
        for k, v in pairs(searchParams.Entity) do
            if metadataEntity[k] ~= v then
                return false
            end
        end
    end

    if searchParams.BitValues then
        if not metadataEntity.BitValues then
            return false
        end

        for k, v in pairs(searchParams.BitValues) do
            if metadataEntity.BitValues[k] ~= v then
                return false
            end
        end
    end

    return true
end

---@param searchParams EntityMeta.SearchParams
---@param narrowEntities? MetadataEntity[]
---@return MetadataEntity[] | table<integer, MetadataEntity[]> | table<integer, boolean>
function StageAPI.RoomMetadata:Search(searchParams, narrowEntities)
    searchParams = searchParams or {}
    local checkIndices, checkGroups, checkNames, checkTags = searchParams.Indices or {}, searchParams.Groups or {}, searchParams.Names or {}, searchParams.Tags or {}
    checkIndices[#checkIndices + 1] = searchParams.Index
    checkGroups[#checkGroups + 1] = searchParams.Group
    checkNames[#checkNames + 1] = searchParams.Name
    checkTags[#checkTags + 1] = searchParams.Tag

    for _, index in ipairs(checkIndices) do
        checkIndices[index] = true
    end

    local matchingEntities = {}
    if narrowEntities then
        for _, metadataEntity in ipairs(narrowEntities) do
            if not searchParams.IndexBooleanTable or not matchingEntities[metadataEntity.Index] then
                if self:IndexMatchesSearchParams(metadataEntity.Index, searchParams, checkIndices, checkGroups) then
                    if self:EntityMatchesSearchParams(metadataEntity, searchParams, checkNames, checkTags) then
                        if searchParams.IndexBooleanTable then
                            matchingEntities[metadataEntity.Index] = true
                        elseif searchParams.IndexTable then
                            matchingEntities[metadataEntity.Index] = matchingEntities[metadataEntity.Index] or {}
                            matchingEntities[metadataEntity.Index][#matchingEntities[metadataEntity.Index] + 1] = metadataEntity
                        else
                            matchingEntities[#matchingEntities + 1] = metadataEntity
                        end
                    end
                end
            end
        end
    else
        for index, metadataEntities in pairs(self.IndexMetadata) do
            if self:IndexMatchesSearchParams(index, searchParams, checkIndices, checkGroups) then
                for _, metadataEntity in ipairs(metadataEntities) do
                    if self:EntityMatchesSearchParams(metadataEntity, searchParams, checkNames, checkTags) then
                        if searchParams.IndexBooleanTable then
                            matchingEntities[index] = true
                            break
                        elseif searchParams.IndexTable then
                            matchingEntities[index] = matchingEntities[index] or {}
                            matchingEntities[index][#matchingEntities[index] + 1] = metadataEntity
                        else
                            matchingEntities[#matchingEntities + 1] = metadataEntity
                        end
                    end
                end
            end
        end
    end

    return matchingEntities
end

---@param searchParams EntityMeta.SearchParams
---@param narrowEntities? MetadataEntity[]
---@return boolean
function StageAPI.RoomMetadata:Has(searchParams, narrowEntities)
    return #self:Search(searchParams, narrowEntities) > 0
end

---@param index integer
---@return number[]
function StageAPI.RoomMetadata:GetDirections(index)
    local directions = self:Search({Name = "Direction", Index = index})
    local outDirections = {}
    for _, direction in ipairs(directions) do
        local angle = direction.BitValues.Direction * (360 / 16)
        outDirections[#outDirections + 1] = angle
    end

    return outDirections
end

---@type table<integer, table<integer, EntityMeta>>
StageAPI.MetadataEntities = {
    [199] = {
        [0] = {
            Name = "Group",
            Tag = "Group",
            ConflictTag = "Group",
            OnlyConflictWith = "RandomizeGroup",
            BitValues = {
                GroupID = {Offset = 0, Length = 16}
            },
        },
        [1] = {
            Name = "RandomizeGroup"
        },
        [2] = {
            Name = "Direction",
            Tag = "Direction",
            ConflictTag = "Direction",
            PreventConflictWith = "PreventDirectionConflict",
            BitValues = {
                Direction = {Offset = 0, Length = 4}
            }
        },
        [3] = {
            Name = "PreventDirectionConflict"
        },
        [10] = {
            Name = "EnteredFromTrigger",
            Tag = "StageAPILoadEditorFeature",
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [11] = {
            Name = "ShopItem",
            Tag = "StageAPIPickupEditorFeature",
            BitValues = {
                Price = {Offset = 0, Length = 7, ValueOffset = -5}
            }
        },
        [12] = {
            Name = "OptionsPickup",
            Tag = "StageAPIPickupEditorFeature",
            BitValues = {
                OptionsIndex = {Offset = 0, Length = 16, ValueOffset = 100}
            }
        },
        [13] = {
            Name = "CancelClearAward"
        },
        [14] = {
            Name = "SetPlayerPosition",
            Tag = "StageAPILoadEditorFeature",
            BitValues = {
                UnclearedOnly = {Offset = 0, Length = 1},
                OffsetX = {Offset = 1, Length = 1},
                OffsetY = {Offset = 2, Length = 1},
            }
        },
        [20] = {
            Name = "Swapper",
            GroupIDIfUngrouped = "Swapper",
            BitValues = {
                GroupID = {Offset = 0, Length = 15, ValueOffset = -1},
                NoMetadata = {Offset = 15, Length = 1}
            }
        },
        [21] = {
            Name = "Detonator",
            Tags = {"StageAPIEditorFeature", "Triggerable"},
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [22] = {
            Name = "RoomClearTrigger",
            Tag = "StageAPIEditorFeature",
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [23] = {
            Name = "Spawner",
            Tags = {"StageAPIEditorFeature", "Triggerable"},
            BlockEntities = true,
            HasPersistentData = true,
            BitValues = {
                GroupID = {Offset = 0, Length = 14, ValueOffset = -1},
                SpawnAll = {Offset = 14, Length = 1},
                SingleActivation = {Offset = 15, Length = 1}
            }
        },
        [24] = {
            Name = "PreventRandomization"
        },
        [25] = {
            Name = "BridgeFailsafe",
            Tag = "StageAPIEditorFeature"
        },
        [26] = {
            Name = "DetonatorTrigger",
            Tag = "StageAPIEditorFeature",
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [27] = {
            Name = "DoorLocker",
            Tag = "StageAPIEditorFeature"
        },
        [28] = {
            Name = "GridDestroyer",
            Tags = {"StageAPIEditorFeature", "Triggerable"},
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [29] = {
            Name = "ButtonTrigger",
            Tag = "StageAPILoadEditorFeature",
            BitValues = {
                GroupID = {Offset = 0, Length = 16, ValueOffset = -1}
            }
        },
        [30] = {
            Name = "BossIdentifier"
        },
        [31] = {
            Name = "Member Card Trapdoor Position"
        },
        [40] = {
            Name = "Room"
        },
        [41] = {
            Name = "Stage"
        },
    }
}

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant ~= StageAPI.E.DeleteMeNPC.Variant then
        StageAPI.LogErr("Something is wrong! A StageAPI metadata entity has spawned at index <" .. tostring(shared.Room:GetGridIndex(npc.Position)) .. "> when it should have been removed.")
    end
end, StageAPI.E.MetaEntity.T)

---@type table<string, EntityMeta>
StageAPI.MetadataEntitiesByName = {}

StageAPI.UnblockableEntities = {}

for id, variants in pairs(StageAPI.MetadataEntities) do
    for variant, metadata in pairs(variants) do
        metadata.Variant = variant
        metadata.Type = id
        StageAPI.MetadataEntitiesByName[metadata.Name] = metadata
    end
end

---@param data EntityMetaArgs
---@param id? integer
---@param variant? integer
function StageAPI.AddMetadataEntity(data, id, variant)
    if data.Group then -- backwards compatibility features
        if not data.Tags then
            data.Tags = {}
        end

        data.Tags[#data.Tags + 1] = data.Group

        if data.Conflicts then
            data.ConflictTag = data.Group
        end
    end

    if data.StoreAsGroup then
        data.GroupID = data.Name
    end

    if id and variant then
        if not StageAPI.MetadataEntities[id] then
            StageAPI.MetadataEntities[id] = {}
        end

        data.Type = id
        data.Variant =  variant

        StageAPI.MetadataEntities[id][variant] = data
    end

    StageAPI.MetadataEntitiesByName[data.Name] = data
end

function StageAPI.AddMetadataEntities(tbl)
    if type(next(tbl)) == "table" and next(tbl).Name then
        for variant, data in pairs(tbl) do
            if type(variant) == "string" then
                StageAPI.AddMetadataEntity(data)
            else
                StageAPI.AddMetadataEntity(data, 199, variant)
            end
        end
    elseif #tbl > 0 and next(tbl).Name then
        for _, data in ipairs(tbl) do
            StageAPI.AddMetadataEntity(data)
        end
    else
        for id, variantTable in pairs(tbl) do
            if type(id) == "string" then
                StageAPI.AddMetadataEntity(variantTable)
            else
                for variant, data in pairs(variantTable) do
                    StageAPI.AddMetadataEntity(data, id, variant)
                end
            end
        end
    end
end

---@param etype integer
---@param variant integer
---@return EntityMeta
---@overload fun(entInfo: {Type: integer, Variant: integer}): EntityMeta
function StageAPI.IsMetadataEntity(etype, variant)
    return StageAPI.GetMetadataEntity(etype, variant)
end

---@param etype integer
---@param variant integer
---@return EntityMeta
---@overload fun(entInfo: {Type: integer, Variant: integer}): EntityMeta
function StageAPI.GetMetadataEntity(etype, variant)
    if type(etype) == "table" then
        variant = etype.Variant
        etype = etype.Type
    end

    return StageAPI.MetadataEntities[etype] and StageAPI.MetadataEntities[etype][variant]
end

---@param metadataName string
---@return EntityMeta
function StageAPI.GetMetadataByName(metadataName)
    return StageAPI.MetadataEntitiesByName[metadataName]
end

function StageAPI.RoomDataHasMetadataEntity(data)
    local spawns = data.Spawns
    for i = 0, spawns.Size - 1 do
        local spawn = spawns:Get(i)
        if spawn then
            local sumWeight = spawn.SumWeights
            local weight = 0
            for i = 1, spawn.EntryCount do
                local entry = spawn:PickEntry(weight)
                weight = weight + entry.Weight / sumWeight

                if StageAPI.GetMetadataEntity(entry.Type, entry.Variant) then
                    return true
                end
            end
        end
    end

    return false
end

function StageAPI.AddUnblockableEntities(etype, variant, subtype) -- an entity that will not be blocked by the Spawner or other BlockEntities triggers
    if type(etype) == "table" then
        for _, ent in ipairs(etype) do
            StageAPI.AddUnblockableEntities(ent[1], ent[2], ent[3])
        end
    else
        if not StageAPI.UnblockableEntities[etype] then
            if variant then
                StageAPI.UnblockableEntities[etype] = {}
                if subtype then
                    StageAPI.UnblockableEntities[etype][variant] = {}
                    StageAPI.UnblockableEntities[etype][variant][subtype] = true
                else
                    StageAPI.UnblockableEntities[etype][variant] = true
                end
            else
                StageAPI.UnblockableEntities[etype] = true
            end
        end
    end
end

function StageAPI.IsEntityUnblockable(etype, variant, subtype)
    return StageAPI.UnblockableEntities[etype] == true
    or StageAPI.UnblockableEntities[etype] and (StageAPI.UnblockableEntities[etype][variant] == true
    or (StageAPI.UnblockableEntities[etype][variant] and StageAPI.UnblockableEntities[etype][variant][subtype] == true))
end

--- temporary, for debug purposes
local table_to_string

--- temporary, for debug purposes
local function table_val_to_str(v)
    if "string" == type(v) then
        v = string.gsub(v, "\n", "\\n")
        if string.match(string.gsub(v,"[^'\"]",""), '^"+$') then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
    else
        return "table" == type( v ) and table_to_string( v ) or tostring( v )
    end
end

--- temporary, for debug purposes
local function table_key_to_str(k)
    if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
        return k
    else
        return "[" .. table_val_to_str(k) .. "]"
    end
end

--- temporary, for debug purposes
function table_to_string(tbl)
    local result, done = {}, {}
    for k, v in ipairs(tbl) do
        table.insert(result, table_val_to_str(v))
        done[k] = true
    end
    for k, v in pairs(tbl) do
        if not done[k] then
            table.insert(result,
            table_key_to_str(k) .. "=" .. table_val_to_str(v))
        end
    end
    return "{" .. table.concat(result, ",") .. "}"
end


---@param entities table<integer, RoomLayout_EntityData[]>
---@param grids table<integer, RoomLayout_GridData[]>
---@param seed? integer 
---@return table<integer, RoomLayout_EntityData[]> outEntities
---@return table<integer, RoomLayout_GridData[]> outGrids
---@return RoomMetadata metadata
---@return integer? persistentIndex
function StageAPI.SeparateEntityMetadata(entities, grids, seed)
    StageAPI.RoomLoadRNG:SetSeed(seed or shared.Room:GetSpawnSeed(), 1)
    local outEntities = {}
    local roomMetadata = StageAPI.RoomMetadata()

    local persistentIndex

    if not entities then
        error("SeparateEntityMetadata | entities is nil! This should never happen", 2)
    end

    for index, entityList in pairs(entities) do
        local outList = {}
        for _, entity in ipairs(entityList) do
            local metadata = StageAPI.GetMetadataEntity(entity.Type, entity.Variant)
            if metadata then
                local _, newPersistentIndex = roomMetadata:AddMetadataEntity(index, entity, persistentIndex)
                persistentIndex = newPersistentIndex
            else
                outList[#outList + 1] = entity
            end
        end

        outEntities[index] = outList
    end

    local outGrids = {}
    for index, gridList in pairs(grids) do
        outGrids[index] = gridList
    end

    StageAPI.CallCallbacks(Callbacks.PRE_PARSE_METADATA, false, roomMetadata, outEntities, outGrids, StageAPI.RoomLoadRNG)

    for index, metadataEntities in pairs(roomMetadata.IndexMetadata) do
        local setsOfConflicting = {}
        for _, metaEntity in StageAPI.ReverseIterate(metadataEntities) do
            local metadata = metaEntity.Metadata
            if metadata.ConflictTag and not setsOfConflicting[metadata.ConflictTag] then
                local shouldConflict = true
                if metadata.PreventConflictWith or metadata.OnlyConflictWith then
                    if metadata.PreventConflictWith then
                        shouldConflict = not roomMetadata:Has({Index = index, Name = metadata.PreventConflictWith})
                    elseif metadata.OnlyConflictWith then
                        shouldConflict = roomMetadata:Has({Index = index, Name = metadata.OnlyConflictWith})
                    end
                end

                if shouldConflict then
                    setsOfConflicting[metadata.ConflictTag] = {}

                    for i, metaEntity2 in StageAPI.ReverseIterate(metadataEntities) do
                        local metadata2 = metaEntity2.Metadata
                        if metadata2.ConflictTag and metadata2.ConflictTag == metadata.ConflictTag then
                            setsOfConflicting[metadata.ConflictTag][#setsOfConflicting[metadata.ConflictTag] + 1] = metaEntity
                            table.remove(metadataEntities, i)
                        end
                    end
                end
            end
        end

        for conflictTag, metaEntities in pairs(setsOfConflicting) do
            local use = metaEntities[StageAPI.Random(1, #metaEntities, StageAPI.RoomLoadRNG)]
            metadataEntities[#metadataEntities + 1] = use
        end

        for _, metaEntity in ipairs(metadataEntities) do
            local metadata = metaEntity.Metadata

            local groupID
            if metaEntity.BitValues and metaEntity.BitValues.GroupID and metaEntity.BitValues.GroupID ~= -1 then
                groupID = metaEntity.BitValues.GroupID
            elseif metadata.GroupID then
                groupID = metadata.GroupID
            end

            if groupID then
                roomMetadata:AddIndexToGroup(index, groupID)
            end
        end

        if #roomMetadata:GroupsWithIndex(index) == 0 then
            for _, metaEntity in ipairs(metadataEntities) do
                local groupID = metaEntity.Metadata.GroupIDIfUngrouped
                if groupID then
                    if not roomMetadata.Groups[groupID] then
                        roomMetadata.Groups[groupID] = {}
                    end

                    roomMetadata.Groups[groupID][index] = true
                end
            end
        end
    end

    StageAPI.CallCallbacks(Callbacks.POST_PARSE_METADATA, nil, roomMetadata, outEntities, outGrids)

    return outEntities, outGrids, roomMetadata, persistentIndex
end
