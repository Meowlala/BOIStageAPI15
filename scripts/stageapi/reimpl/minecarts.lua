local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

StageAPI.MinecartRailVectors = {
    [16] = Vector(-5.2,0),
    [17] = Vector(0,-5.2),
    [32] = Vector(5.2,0),
    [33] = Vector(0,5.2),
}

StageAPI.MinecartAnimOffsets = {
	["Move1"] = -5,
	["Move2"] = -4,
	["Move3"] = -3,
	["Move4"] = -1,
	["Move5"] = 1,
	["Move6"] = -1,
	["Move7"] = -3,
	["Move8"] = -4,
}

function StageAPI.MakeMinecart(gridIndex, railVariant, entToLoad)
	local vec = StageAPI.MinecartRailVectors[railVariant] or Vector(5.2,0)
	if REPENTOGON and entToLoad then
		entToLoad:GiveMinecart(shared.Room:GetGridPosition(gridIndex), vec)
		return entToLoad:GetMinecart()
	else
		local minecart = Isaac.Spawn(EntityType.ENTITY_MINECART, 1, 0, shared.Room:GetGridPosition(gridIndex), vec, nil):ToNPC()
		minecart:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		minecart.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		minecart.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		minecart.I1 = 1
		minecart.I2 = gridIndex
		minecart.V1 = vec
		minecart.V2 = Vector(1,0)
		minecart.TargetPosition = vec:Normalized()
		minecart:GetData().IsStageAPIMinecart = true
		if entToLoad then
			StageAPI.LoadEntIntoMinecart(entToLoad, minecart)
		end
	end
	return minecart
end

function StageAPI.LoadEntIntoMinecart(ent, minecart)
    minecart.Child = ent
	ent.Position = minecart.Position
    ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    ent:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    ent.DepthOffset = 0.01
    ent:GetData().StageAPIMinecart = minecart
end

function StageAPI.IsInMinecart(ent)
	if REPENTOGON then
		return ent:GetMinecart()
	else
		for _, minecart in ipairs(Isaac.FindByType(EntityType.ENTITY_MINECART)) do
            if minecart.Child and minecart.Child.InitSeed == ent.InitSeed then
                return minecart
            end
        end
	end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, minecart)
	if minecart:GetData().IsStageAPIMinecart and minecart.Child then
		minecart.Child:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		minecart.Child.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	end
end, EntityType.ENTITY_MINECART)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, minecart, offset)
	if minecart:GetData().IsStageAPIMinecart then
		minecart:GetData().StageAPIMinecartRenderOffset = offset
		
		if minecart.Child then
			local minecartSprite = minecart:GetSprite()
			local y = StageAPI.MinecartAnimOffsets[minecartSprite:GetAnimation()]
		
			if y then
				if minecartSprite:GetFrame() >= 3 then
					y = y + 1
				end
		
				minecart.Child.SpriteOffset = Vector(0, y)
			end
		end
	end
end, EntityType.ENTITY_MINECART)

mod:AddPriorityCallback(ModCallbacks.MC_NPC_UPDATE, CallbackPriority.LATE, function(_, npc)
	if npc:GetData().StageAPIMinecart then
		npc.Velocity = Vector.Zero
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc, offset)
	if npc:GetData().StageAPIMinecart then
		local minecart = npc:GetData().StageAPIMinecart
		minecart:GetSprite():RenderLayer(1, Isaac.WorldToRenderPosition(minecart.Position + minecart.PositionOffset) + (minecart:GetData().StageAPIMinecartRenderOffset or Vector.Zero))
	end
end)