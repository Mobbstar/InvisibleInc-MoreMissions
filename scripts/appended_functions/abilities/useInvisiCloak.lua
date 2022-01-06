local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

--attack-proof cloak
local useInvisiCloak = abilitydefs.lookupAbility( "useInvisiCloak" )
local useInvisiCloak_executeOld = useInvisiCloak.executeAbility
useInvisiCloak.executeAbility = function( self, sim, unit, ... )
	local userUnit = unit:getUnitOwner()
	if unit:getTraits().MM_attackproof_cloak then
		userUnit:getTraits().MM_attackproof_cloak = true
	end
	return useInvisiCloak_executeOld( self, sim, unit, ... )
end