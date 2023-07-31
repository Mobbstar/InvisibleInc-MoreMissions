local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local speechdefs = include("sim/speechdefs")
local abilityutil = include( "sim/abilities/abilityutil" )

------------------------------------------------------------------
--

local MM_workshop_place_item =
{
	name = "PLACEHOLDER",

	getName = function( self, sim, unit, userUnit )
		return self.name
	end,

	onTooltip = abilityutil.onAbilityTooltip,

	profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",
	proxy = true,
	--alwaysShow = true,
	--ghostable = true,

	canUseAbility = function( self, sim, unit, userUnit )
		if (unit:getTraits().credits or 0) == 0 and #unit:getChildren() == 0 and not unit:getTraits().stashable then
			return false
		end

		if unit:getTraits().mainframe_status ~= "active" then
			return false, STRINGS.C_WAR.ABILITIES.UNLOCK_WITH_STATION
		end

		if not simquery.canUnitReach( sim, userUnit, unit:getLocation() ) then
			return false
		end

		if unit:getTraits().mainframe_ice > 0 then
			return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
		end

		if userUnit:getTraits().isDrone then
			return false -- Drones have no hands to loot with
		end

		return true
	end,

	executeAbility = function ( self, sim, unit, userUnit)
		local x0,y0 = userUnit:getLocation()
		local x1,y1 = unit:getLocation()
		local facing = simquery.getDirectionFromDelta(x1-x0,y1-y0)
		if not unit:getTraits().noOpenAnim then
			local sound = simdefs.SOUNDPATH_SAFE_OPEN

			if unit:getSounds().open_safe then
				sound = "SpySociety/Objects/securitysafe_open"
			end
			sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR, { unitID = userUnit:getID(), facing = facing, sound = sound, soundFrame = 1 } )
		else
			sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = userUnit:getID(), targetID= unit:getID(), facing = facing, sound=simdefs.SOUNDPATH_USE_CONSOLE, soundFrame=10 } )
		end

		-- Loot items within
		--if sim:getQuery().canSteal( sim, userUnit, unit ) then
			sim:dispatchEvent( simdefs.EV_ITEMS_PANEL, { targetUnit = unit, unit = userUnit } )

		--end
    		unit:checkOverload( sim )
		sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR_PST, { unitID = userUnit:getID(), facing = facing } )
	end,
}

return MM_workshop_place_item
