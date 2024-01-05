local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )

local MM_renameDrone =
	{
		name = STRINGS.MOREMISSIONS.ABILITIES.RENAME_DRONE,

		createToolTip = function( self, sim, unit )

			local title = STRINGS.MOREMISSIONS.ABILITIES.RENAME..util.toupper(unit:getTraits().customName or "Refit Drone")
			local body = STRINGS.MOREMISSIONS.ABILITIES.RENAME_DRONE_DESC

			if unit:getTraits().activate_txt_title then
				title = unit:getTraits().activate_txt_title
			end
			if unit:getTraits().activate_txt_body then
				body = unit:getTraits().activate_txt_body
			end

			return abilityutil.formatToolTip( title,  body )
		end,

		proxy = true,
		HUDpriority = 1,
		getName = function( self, sim, abilityOwner, abilityUser, targetUnitID )
			return self.name
		end,

		profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",

		-- NEEDS FIXING TO DISALLOW DIAGONAL INTERACTION
		acquireTargets = function( self, targets, game, sim, abilityOwner, unit )
            if simquery.canUnitReach( sim, unit, abilityOwner:getLocation() ) and (unit ~= abilityOwner) then
			    return targets.unitTarget( game, { abilityOwner }, self, abilityOwner, unit )
            end
		end,

		canUseAbility = function( self, sim, abilityOwner, unit )
			if abilityOwner == unit then
				return false
			end

			if abilityOwner:getTraits().alreadyRenamed then
				return false
			end

            return true -- simquery.canUnitReach(sim, unit, abilityOwner:getLocation())
		end,

		executeAbility = function( self, sim, abilityOwner, unit )
			local x0,y0 = unit:getLocation()
			local x1, y1 = abilityOwner:getLocation()

			local facing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )

			sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = unit:getID(), targetID= abilityOwner:getID(), facing = facing, sound=simdefs.SOUNDPATH_USE_CONSOLE, soundFrame=10 } )

			local result = sim:dispatchChoiceEvent( "NameDialog" )
			abilityOwner:getTraits().customName = result.txt
			abilityOwner:getTraits().alreadyRenamed = true

		end,
	}

return MM_renameDrone
