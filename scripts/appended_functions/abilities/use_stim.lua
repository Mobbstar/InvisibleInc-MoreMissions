local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local use_stim = abilitydefs.lookupAbility( "use_stim" )
local use_stim_executeAbitlity_old = use_stim.executeAbility
use_stim.executeAbility = function( self, sim, unit, userUnit, target )
	use_stim_executeAbitlity_old( self, sim, unit, userUnit, target )
	local targetUnit = sim:getUnit(target)
	if unit:getTraits().impair_agent_AP and targetUnit:getTraits().mpMax then
		targetUnit:getTraits().mpMax = math.max(targetUnit:getTraits().mpMax - unit:getTraits().impair_agent_AP, 4)
	end
	if unit:getTraits().armorPiercingBuff then
		local armorBuff = unit:getTraits().armorPiercingBuff
		targetUnit:getTraits().genericPiercing = (targetUnit:getTraits().genericPiercing or 0) + armorBuff
	end
end
