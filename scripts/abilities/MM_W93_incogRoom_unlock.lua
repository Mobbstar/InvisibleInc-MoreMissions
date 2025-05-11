local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local inventory = include("sim/inventory")
local abilityutil = include( "sim/abilities/abilityutil" )
local speechdefs = include("sim/speechdefs")
local mathutil = include( "modules/mathutil" )

local function findCell( sim, tag )
	local cells = sim:getCells( tag )
	return cells and cells[1]
end

local MM_W93_incogRoom_unlock =
	{
		name = STRINGS.MOREMISSIONS.ABILITIES.INCOGROOM_UNLOCK,
        proxy = true,
		alwaysShow = true,
		ghostable = true,
		profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",

		getProfileIcon = function( self, sim, unit )
			return self.profile_icon
		end,

		getName = function( self, sim, unit )
			return unit:getName()
		end,

		onTooltip = function( self, hud, sim, abilityOwner, abilityUser, targetUnitID )
			local tooltip = util.tooltip( hud._screen )
			local section = tooltip:addSection()
			local canUse, reason = abilityUser:canUseAbility( sim, self, abilityOwner, targetUnitID )
			local targetUnit = sim:getUnit( targetUnitID )
	        	section:addLine( abilityOwner:getName( self, sim, abilityOwner ) )
			section:addAbility( self.name, STRINGS.MOREMISSIONS.ABILITIES.INCOGROOM_UNLOCK_DESC, "gui/items/icon-action_hack-console.png" )
			if reason then
				section:addRequirement( reason )
			end
			return tooltip
		end,

		canUseAbility = function( self, sim, unit, userUnit )
			if not simquery.canUnitReach( sim, userUnit, unit:getLocation() ) then
				return false
			end

			if unit:getPlayerOwner() ~= userUnit:getPlayerOwner() and unit:getTraits().mainframe_status == "active" then
				return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
			end

			if unit:getTraits().mainframe_status ~= "active" then
				return false, STRINGS.UI.REASON.ALREADY_USED
			end

			return true
		end,

		executeAbility = function ( self, sim, unit, userUnit)
			local x0,y0 = userUnit:getLocation()
			local x1,y1 = unit:getLocation()
			local facing = simquery.getDirectionFromDelta(x1-x0,y1-y0)
			sim:emitSpeech( userUnit, speechdefs.EVENT_HIJACK )
			sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = userUnit:getID(), targetID=unit:getID(), facing = facing, sound=simdefs.SOUNDPATH_USE_CONSOLE, soundFrame=10 } )
			if not sim:getPC():getTraits().W93_incogRoom_unlock then
				sim:getPC():getTraits().W93_incogRoom_unlock = 0
			end
			sim:getPC():getTraits().W93_incogRoom_unlock = sim:getPC():getTraits().W93_incogRoom_unlock + 1
			unit:getTraits().mainframe_status = "off"
			sim:triggerEvent( simdefs.TRG_UNIT_DISABLED, unit )
			sim:getCurrentPlayer():glimpseUnit( sim, unit:getID() )
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = unit } )
			sim:triggerEvent( simdefs.TRG_UI_ACTION, { W93_incogLock = true })
		end,
	}
return MM_W93_incogRoom_unlock