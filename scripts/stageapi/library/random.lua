-- Random

StageAPI.RandomRNG = RNG()
StageAPI.RandomRNG:SetSeed(Random(), 0)

local function traceback()
    if debug then
        return "\n" .. debug.traceback(nil, 1)
    else
        return ""
    end
end

local truncatedTableToString

function StageAPI.Random(a, b, rng)
    rng = rng or StageAPI.RandomRNG
    if a and b then
        -- TODO remove after Rev update
        if b - a < 0 then
            StageAPI.LogErr('Bad Random Range! ' .. a .. ', ' .. b, traceback())
            return b - a
        end
        return rng:Next() % (b - a + 1) + a
    elseif a then
        -- TODO remove after Rev update
        if a < 0 then
            StageAPI.LogErr('Bad Random Max! ' .. a, traceback())
            return a
        end
        return rng:Next() % (a + 1)
    end
    return rng:Next()
end

function StageAPI.RandomFloat(a, b, rng)
    rng = rng or StageAPI.RandomRNG
    local rand = rng:RandomFloat()
    if a and b then
        return (rand * (b - a)) + a
    elseif a then
        return rand * a
    end

    return rand
end

---@generic T
---@param args T[] | {[1]: T, [2]: number}[]
---@param rng? RNG
---@param key? any
---@param preCalculatedWeight? number
---@param floatWeights? boolean
---@return T?
---@return integer? index
function StageAPI.WeightedRNG(args, rng, key, preCalculatedWeight, floatWeights) -- takes tables {{obj, weight}, {"pie", 3}, {555, 0}}
    local weight_value = preCalculatedWeight or 0
    local iterated_weight = 1
    if not preCalculatedWeight then
        for _, potentialObject in ipairs(args) do
            if key then
                weight_value = weight_value + potentialObject[key]
            else
                weight_value = weight_value + potentialObject[2]
            end

            if weight_value % 1 ~= 0 then -- if any weight is a float, use float RNG
                floatWeights = true
            end
        end
    end

    rng = rng or StageAPI.RandomRNG
    local random_chance
    if weight_value % 1 == 0 and not floatWeights then
        if weight_value < 1 then
            StageAPI.LogErr("RandomWeight | Int weights added up to 0! Args:\ntbl:", 
                truncatedTableToString(args, 100), " rng:", not not rng, " key:", key, " total:", preCalculatedWeight, " isFloat:", floatWeights, traceback()
            )
            return nil, nil
        end

        random_chance = StageAPI.Random(1, weight_value, rng)
    else
        random_chance = StageAPI.RandomFloat(1, weight_value + 1, rng)
    end

    for i, potentialObject in ipairs(args) do
        if key then
            iterated_weight = iterated_weight + potentialObject[key]
        else
            iterated_weight = iterated_weight + potentialObject[2]
        end

        if iterated_weight > random_chance then
            local ret = potentialObject
            if key then
                return ret, i
            else
                return ret[1], i
            end
        end
    end
end

local table_to_string

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

local function table_key_to_str(k)
    if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
        return k
    else
        return "[" .. table_val_to_str(k) .. "]"
    end
end

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

function truncatedTableToString(tbl, maxLen)
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
    local content = table.concat(result, ",")
    if content:len() > maxLen then
        content = content:sub(0, maxLen-3) .. "..."
    end
    return "{" .. content .. "}"
end