local shared = require("scripts.stageapi.shared")
local mod = require("scripts.stageapi.mod")

function StageAPI.LoadIntoMinecart(minecart, ent)
    minecart.Child = ent
    minecart:GetData().IsStageAPIMinecart = true
    ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    ent:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    ent.DepthOffset = 0.01
    ent:GetData().StageAPIMinecart = minecart
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
			
			local y
			if minecartSprite:IsPlaying("Move1") or minecartSprite:IsFinished("Move1") then
				y = -5
			elseif  minecartSprite:IsPlaying("Move2") or minecartSprite:IsFinished("Move2") then
				y = -4
			elseif  minecartSprite:IsPlaying("Move3") or minecartSprite:IsFinished("Move3") then
				y = -3
			elseif  minecartSprite:IsPlaying("Move4") or minecartSprite:IsFinished("Move4") then
				y = -1
			elseif  minecartSprite:IsPlaying("Move5") or minecartSprite:IsFinished("Move5") then
				y = 1
			elseif  minecartSprite:IsPlaying("Move6") or minecartSprite:IsFinished("Move6") then
				y = -1
			elseif  minecartSprite:IsPlaying("Move7") or minecartSprite:IsFinished("Move7") then
				y = -3
			elseif  minecartSprite:IsPlaying("Move8") or minecartSprite:IsFinished("Move8") then
				y = -4
			else
				return
			end
			
			if minecartSprite:GetFrame() >= 3 then
				y = y + 1
			end
			
			minecart.Child.SpriteOffset = Vector(0, y)
		end
	end
end, EntityType.ENTITY_MINECART)

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc, offset)
	if npc:GetData().StageAPIMinecart then
		local minecart = npc:GetData().StageAPIMinecart

		local minecartSprite = minecart:GetSprite()
		minecartSprite:RenderLayer(1, Isaac.WorldToRenderPosition(minecart.Position + minecart.PositionOffset) + (minecart:GetData().StageAPIMinecartRenderOffset or Vector.Zero))
	end
end)