local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

-- Amnesiac function as append of paralyze
local paralyze = abilitydefs.lookupAbility("paralyze")
local paralyze_executeAbility_old = paralyze.executeAbility
local paralyze_createToolTip_old = paralyze.createToolTip
paralyze.createToolTip = function( self, sim, abilityOwner, ...)
	if abilityOwner:getTraits().amnesiac then
		return abilityutil.formatToolTip(STRINGS.MOREMISSIONS.UI.TOOLTIPS.PARALYZE_AMNESIAC, util.sformat(STRINGS.MOREMISSIONS.UI.TOOLTIPS.PARALYZE_AMNESIAC_DESC,abilityOwner:getTraits().impare_sight), simdefs.DEFAULT_COST) --impare_AP 2 [sic] in itemdef traits
	end
	return paralyze_createToolTip_old( self, sim, abilityOwner, ... )
end

paralyze.executeAbility = function( self, sim, unit, userUnit, target, ... )
	paralyze_executeAbility_old( self, sim, unit, userUnit, target, ... )
	local targetUnit = sim:getUnit(target)
	local x0, y0 = targetUnit:getLocation()
	if x0 and y0 and unit:getTraits().amnesiac then
		targetUnit:getTraits().MM_amnesiac = true
		targetUnit:getTraits().witness = nil
		sim:triggerEvent( "used_amnesiac", { userUnit = userUnit, targetUnit = targetUnit } )
		sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(STRINGS.MOREMISSIONS.UI.WITNESS_CLEARED),x=x0,y=y0,color={r=1,g=1,b=0,a=1}} )
	end
	if unit:getTraits().impare_sight then
		targetUnit:getTraits().MM_impairedVision = unit:getTraits().impare_sight
	end
end