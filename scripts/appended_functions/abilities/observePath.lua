local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local observePath = abilitydefs.lookupAbility("observePath")
local observePath_execute_old = observePath.executeAbility

observePath.executeAbility = function( self, sim, unit, userUnit, target, ... )
	observePath_execute_old( self, sim, unit, userUnit, target, ... )
	local targetUnit = sim:getUnit(target)
	if targetUnit:getTraits().stationaryRotating and targetUnit:getBrain() and (targetUnit:getBrain():getSituation().ClassType == simdefs.SITUATION_IDLE) then
		targetUnit:destroyTab()
		targetUnit:createTab( STRINGS.GUARD_STATUS.STATUS, STRINGS.MOREMISSIONS.UI.TOOLTIPS.STATUS_SURVEYING)
	end
end
	
