local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local stealCreditsAbility = abilitydefs.lookupAbility("stealCredits")
local stealCredits_canUse_old = stealCreditsAbility.canUseAbility
--need custom hack here because the vanilla emp_safe trait does nothing for vault boxes
abilitydefs._abilities.stealCredits.canUseAbility = function(self, sim, unit, userUnit, ...)
	local result = stealCredits_canUse_old (self,sim,unit,userUnit,...)
	if unit:getTraits().MM_emp_safe and (unit:getTraits().mainframe_status ~= "active") then
		return false, STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_EMP_SAFE
	end
	return result
end