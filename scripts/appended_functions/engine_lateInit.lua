local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local assassination_mission = include( SCRIPT_PATHS.more_missions .. "/missions/assassination" )

local simengine = include("sim/engine")
local simengine_tryShootAt_old = simengine.tryShootAt
simengine.tryShootAt = function( self, sourceUnit, targetUnit, dmgt, equipped, ... )
	if targetUnit:getTraits().MM_decoy
	and not equipped:getTraits().noTargetAlert and not equipped:getTraits().targetNotAlerted 
	then
		local newTarget = assassination_mission.revealDecoy( sourceUnit:getSim(), targetUnit )
		if newTarget and newTarget:isValid() then
			if dmgt.ko then
				return
			else
				targetUnit = newTarget
			end
		else
			return
		end
	end
	simengine_tryShootAt_old( self, sourceUnit, targetUnit, dmgt, equipped, ... )
	if targetUnit and targetUnit:isValid() and not targetUnit:isKO() and targetUnit:getTraits().MM_bodyguard then
		self:triggerEvent("MM_shotAtBodyguard", {sourceUnit = sourceUnit, targetUnit = targetUnit, dmgt = dmgt, equipped = equipped })
	end		
end

local simengine_hitUnit_old = simengine.hitUnit
simengine.hitUnit = function( self, sourceUnit, targetUnit, dmgt, ... )
	--hitUnit is called as part of tryShootAt but it's also called in other cases so we need to cover those as well
	if targetUnit:getTraits().MM_decoy and not dmgt.canTag then
		local newTarget = assassination_mission.revealDecoy( sourceUnit:getSim(), targetUnit )
		if newTarget and newTarget:isValid() then
			targetUnit = newTarget
		else
			return
		end
	end
	simengine_hitUnit_old( self, sourceUnit, targetUnit, dmgt, ... )
end

local sim_damageUnit_old = simengine.damageUnit
simengine.damageUnit = function( self,  targetUnit, srcDamage, kodamage, fx, sourceUnit, ... )
	local x1,y1 = targetUnit:getLocation()
	local damage = srcDamage	
	if targetUnit:getTraits().MM_decoy then
		local newTarget = assassination_mission.revealDecoy( self, targetUnit )
		if newTarget and newTarget:isValid() then
			targetUnit = newTarget
		else
			return
		end
	end
	sim_damageUnit_old( self,  targetUnit, srcDamage, kodamage, fx, sourceUnit, ... )
end
