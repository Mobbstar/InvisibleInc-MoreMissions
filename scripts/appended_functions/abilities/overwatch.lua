local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local overwatch = abilitydefs.lookupAbility("overwatch")
local overwatch_canUse_old = overwatch.canUseAbility
overwatch.canUseAbility = function(self, sim, unit, ... )
	local result, reason1, reason2, reason3 = overwatch_canUse_old(self, sim, unit, ... )
	local weaponUnit = simquery.getEquippedGun(unit)
	if (result == true) and weaponUnit and weaponUnit:getRequirements()then
		for skill,level in pairs( weaponUnit:getRequirements() ) do
			if not unit:hasSkill(skill, level) and not unit:getTraits().useAnyItem then

				local skilldefs = include( "sim/skilldefs" )
				local skillDef = skilldefs.lookupSkill( skill )

				return false, string.format( STRINGS.UI.TOOLTIP_REQUIRES_SKILL_LVL, util.toupper(skillDef.name), level )
			end
		end
	end
	return result, reason1, reason2, reason3
end