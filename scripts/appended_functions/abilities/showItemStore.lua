local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local showItemStore = abilitydefs.lookupAbility( "showItemStore")
local showItemStore_executeOld = showItemStore.executeAbility

-- This changes the nanofab UI strings when one accesses the luxury  nanofab and stores the old strings in sim

showItemStore.executeAbility = function( self, sim, unit, userUnit, ... )
-- note: unit is nanofab, userUnit is agent
	if unit:getTraits().luxuryNanofab and sim.luxuryNanofabItemType then

		local strings_screens = include( "strings_screens" )
		sim.old_augmenttip, sim.old_weapontip, sim.old_itemtip = strings_screens.STR_346165218, strings_screens.STR_2618909495, strings_screens.STR_590530336
		local itemType = sim.luxuryNanofabItemType
		local new_tooltip = [[]]
		if itemType == 1 then
			new_tooltip = [[ITEMS]]
		elseif itemType ==2 then
			new_tooltip = [[AUGMENTS]]
		elseif itemType == 3 then
			new_tooltip = [[WEAPONS]]
		end

		strings_screens.STR_346165218 = new_tooltip
		strings_screens.STR_2618909495 = new_tooltip
		strings_screens.STR_590530336 = new_tooltip

	end

	showItemStore_executeOld(self, sim, unit, userUnit, ...)
end
