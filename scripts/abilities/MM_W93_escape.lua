local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )
local unitdefs = include( "sim/unitdefs" )
local inventory = include( "sim/inventory" )

-------------------------------------------------------------------

local MM_W93_escape =
{
	name = STRINGS.MOREMISSIONS.ABILITIES.W93_ESCAPE,
	onTooltip = function( self, hud, sim, abilityOwner, abilityUser )
		return abilityutil.hotkey_tooltip( self, sim, abilityOwner, STRINGS.MOREMISSIONS.ABILITIES.W93_ESCAPE_DESC )
	end,

	profile_icon = "gui/actions/escape1.png",
	proxy = false,

	getName = function( self, sim, unit )
		return self.name
	end,

	canUseAbility = function( self, sim, unit )
		local cell = sim:getCell( unit:getLocation() )
		if unit:getUnitOwner() then
			cell = sim:getCell(unit:getUnitOwner():getLocation() )
		end
		if cell.exitID == nil then
			return false, STRINGS.UI.REASON.NOT_EXIT
		end

		if sim:hasTag( "no_escape" ) then
			return false, STRINGS.UI.REASON.CANT_ESCAPE
		end

		return true
	end,

	executeAbility = function( self, sim, abilityOwner )
		local cell = sim:getCell( abilityOwner:getLocation() )
		if abilityOwner:getUnitOwner() then
			cell = sim:getCell( abilityOwner:getUnitOwner():getLocation() )
		end
		local escapedUnits = {}

		if cell.exitID then
			local units = {}

			for _, unit in pairs( sim:getAllUnits() ) do
				local c = sim:getCell( unit:getLocation() )
				if unit:getUnitOwner() then
					c = sim:getCell( unit:getUnitOwner():getLocation() )
				end
				if c and c.exitID and unit:hasAbility( "MM_W93_escape" ) then
					table.insert(units,unit)
				end
			end


			for i, unit in ipairs(units)do
				if unit:getUnitOwner() then
					inventory.dropItem( sim, unit:getUnitOwner(), unit )
				end
			end
			sim:dispatchEvent( simdefs.EV_TELEPORT, { units=units, warpOut = true } )
			sim:triggerEvent( simdefs.TRG_MAP_EVENT, { event=simdefs.MAP_EVENTS.TELEPORT, units=units })

			for i, unit in ipairs(units)do
				if unit:getTraits().cashInReward then
					local value = sim:getQuery().scaleCredits(sim, unit:getTraits().cashInReward)
					sim._resultTable.credits_gained.stolengoods = sim._resultTable.credits_gained.stolengoods and sim._resultTable.credits_gained.stolengoods + value or value
					sim:addMissionReward(value)
				end

				sim:warpUnit( unit, nil )
				sim:despawnUnit( unit )

				table.insert( escapedUnits, unit )
				simlog( "%s escaped!", unit:getName())
			end

			while #escapedUnits > 0 do
				sim:triggerEvent( simdefs.TRG_UNIT_ESCAPED, table.remove( escapedUnits ))
			end

			sim:processReactions()
			sim:updateWinners()
		end
	end,
}
return MM_W93_escape
