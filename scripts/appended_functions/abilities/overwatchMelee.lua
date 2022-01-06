local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local overwatchMelee = abilitydefs.lookupAbility("overwatchMelee")
local overwatchMelee_canUse_old = overwatchMelee.canUseAbility
overwatchMelee.canUseAbility = function( self, sim, unit, ... )

	local result, reason1, reason2, reason3 = overwatchMelee_canUse_old(self, sim, unit, ... )
	local tazerUnit = simquery.getEquippedMelee( unit )
	if result == true then
		if not unit:getPlayerOwner():isNPC() and tazerUnit then
			if tazerUnit:getRequirements() then
				for skill,level in pairs( tazerUnit:getRequirements() ) do
					if not unit:hasSkill(skill, level) and not unit:getTraits().useAnyItem then

						local skilldefs = include( "sim/skilldefs" )
						local skillDef = skilldefs.lookupSkill( skill )

						return false, string.format( STRINGS.UI.TOOLTIP_REQUIRES_SKILL_LVL, util.toupper(skillDef.name), level )
					end
				end
			end

		end
	end
	return result, reason1, reason2, reason3
end