local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

-- FOR TECH EXPO CUSTOM ITEM
local icebreak = abilitydefs.lookupAbility("icebreak")
local icebreak_executeAbility_old = icebreak.executeAbility
icebreak.executeAbility = function( self, sim, unit, userUnit, target, ... ) --this might be worth moving to FuncLib...
	if unit:getTraits().killDaemon then
		local targetUnit = sim:getUnit(target)
		targetUnit:getTraits().mainframe_program = nil
		sim:dispatchEvent( simdefs.EV_KILL_DAEMON, {unit = targetUnit})
		if targetUnit:getTraits().daemonHost then
			sim:getUnit(targetUnit:getTraits().daemonHost):killUnit(sim)
			targetUnit:getTraits().daemonHost =nil
		end
	end
	icebreak_executeAbility_old( self, sim, unit, userUnit, target, ... )
end