if not ModCompatCallbackHack then
    local mod = RegisterMod("Embeddable Callback Hack", 1)

 	local overridenCallbacks = {}
	if REPENTANCE then
		overridenCallbacks = {
			[ModCallbacks.MC_PRE_PLAYER_COLLISION] = {}
		}
	else
		overridenCallbacks = {
			[ModCallbacks.MC_PRE_BOMB_COLLISION] = {},
			[ModCallbacks.MC_PRE_FAMILIAR_COLLISION] = {},
			[ModCallbacks.MC_PRE_KNIFE_COLLISION] = {},
			[ModCallbacks.MC_PRE_TEAR_COLLISION] = {},
			[ModCallbacks.MC_PRE_PICKUP_COLLISION] = {},
			[ModCallbacks.MC_PRE_NPC_COLLISION] = {},
			[ModCallbacks.MC_PRE_PLAYER_COLLISION] = {},
			[ModCallbacks.MC_PRE_PROJECTILE_COLLISION] = {},
			[ModCallbacks.MC_GET_SHADER_PARAMS] = {},
			[ModCallbacks.MC_PRE_NPC_UPDATE] = {},
			[ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD] = {}
		}
	end

    for callbackId, _ in pairs(overridenCallbacks) do
        mod:AddCallback(callbackId, function(_, arg1, ...)
            local callbacks = overridenCallbacks[callbackId]
            for _, callback in ipairs(callbacks) do
                local shouldCall = true
                if callback[3] and callback[3] ~= -1 then
                    if callbackId ~= ModCallbacks.MC_GET_SHADER_PARAMS then
                        if callbackId == ModCallbacks.MC_PRE_NPC_COLLISION or callbackId == ModCallbacks.MC_PRE_NPC_UPDATE then
                            shouldCall = arg1.Type == callback[3]
                        else
                            shouldCall = arg1.Variant == callback[3]
                        end
                    end
                end

                if shouldCall then
                    local ret = callback[2](callback[1], arg1, ...)
                    if ret ~= nil then
                        return ret
                    end
                end
            end
        end)
    end

    local addCallbackOld = Isaac.AddCallback
    function Isaac.AddCallback(ref, callbackId, callbackFn, entityId)
        if overridenCallbacks[callbackId] then
            overridenCallbacks[callbackId][#overridenCallbacks[callbackId] + 1] = {
                ref, callbackFn, entityId
            }
        else
            addCallbackOld(ref, callbackId, callbackFn, entityId)
        end
    end

    local function ripairs_it(t,i)
      i=i-1
      local v=t[i]
      if v==nil then return v end
      return i,v
    end

    local function ripairs(t)
      return ripairs_it, t, #t+1
    end

    local removeCallbackOld = Isaac.RemoveCallback
    function Isaac.RemoveCallback(ref, callbackId, callbackFn)
        if overridenCallbacks[callbackId] then
            for i, callback in ripairs(overridenCallbacks[callbackId]) do
                if callback[1].Name == ref.Name and tostring(callback[2]) == tostring(callbackFn) then
                    table.remove(overridenCallbacks[callbackId], i)
                end
            end
        else
            removeCallbackOld(ref, callbackId, callbackFn)
        end
    end

    local registerModOld = Isaac.RegisterMod
    function Isaac.RegisterMod(ref, modName, apiVersion)
        for callbackId, callbacks in pairs(overridenCallbacks) do
            for i, callback in ripairs(callbacks) do
                if callback[1].Name == ref.Name then
                    table.remove(callbacks, i)
                end
            end
        end

        registerModOld(ref, modName, apiVersion)
    end

    ModCompatCallbackHack = true
end