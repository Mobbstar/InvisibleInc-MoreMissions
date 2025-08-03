local array = include( "modules/array" )
local util = include( "modules/util" )
local mui_tooltip = include( "mui/mui_tooltip" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )

local pet_tooltip = abilityutil.uitr_ap_tooltip
if not pet_tooltip then
    pet_tooltip = function(hud, title, body, reason)
        -- cant-use-reason styled how agent_panel would when using createTooltip() instead of onTooltip().
        if reason then
            body = body .. "\n<c:ff0000>" .. reason .. "</>"
        end
        return mui_tooltip(title, body)
    end
end

local MM_petDrone =
	{
		name = STRINGS.MOREMISSIONS.ABILITIES.PET_DRONE,

		onTooltip = function( self, hud, sim, abilityOwner, abilityUser )
			local title = STRINGS.MOREMISSIONS.ABILITIES.PET..util.toupper(abilityOwner:getTraits().customName or "Refit Drone")
			local body = STRINGS.MOREMISSIONS.ABILITIES.PET_DRONE_DESC

			if abilityOwner:getTraits().activate_txt_title then
				title = abilityOwner:getTraits().activate_txt_title
			end
			if abilityOwner:getTraits().activate_txt_body then
				body = abilityOwner:getTraits().activate_txt_body
			end

			local _, reason = abilityUser:canUseAbility( sim, self, abilityOwner )
			local previewAPBoost = self._shouldShowAPBonus and self.ap_boost or 0
			return pet_tooltip( hud, title, body, reason, {{ unit=abilityUser, apCost=-previewAPBoost}} )
		end,

		proxy = true,
		ap_boost = 1,
		HUDpriority = 2,
		getName = function( self, sim, abilityOwner, abilityUser, targetUnitID )
			return self.name
		end,

		profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-action_pet_drone.png",

		onSpawnAbility = function( self )
			-- Use a settings 'seenOnce', to store if the user has ever pet a drone before.
			-- The AP Bonus UI preview is suppressed until the ability's effect has been seen.
			local settings = savefiles.getSettings( "settings" )
			local seenOnce = settings.data.seenOnce or {}
			self._shouldShowAPBonus = seenOnce[ "MM-petDrone-AP" ]
		end,

		-- Note that abilityOwner is the drone, unit is the agent!
		canUseAbility = function( self, sim, abilityOwner, unit )
			if abilityOwner == unit then
				return false
			end

			if unit:getTraits().hasAlreadyPetDrone then
				return false
			end

			-- canUnitReach reports BLOCKED or OUT OF REACH even if there's a wall in the way so rule that out first.
			-- But we want the OUT OF REACH message to help users discover this ability.
			local agentCell = sim:getCell(unit:getLocation())
			local droneCell = sim:getCell(abilityOwner:getLocation())
			if not simquery.canPathBetween(sim, unit, agentCell, droneCell) then
				return false
			end
			return simquery.canUnitReach(sim, unit, droneCell.x, droneCell.y)
		end,

		executeAbility = function( self, sim, abilityOwner, unit )
			local x0,y0 = unit:getLocation()
			local x1, y1 = abilityOwner:getLocation()

			local facing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )

			local droneSounds = {abilityOwner:getSounds().getko, abilityOwner:getSounds().getko, abilityOwner:getSounds().reboot_end}
			local droneSound = droneSounds[sim:nextRand(1, #droneSounds)]

			sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR, { unitID = unit:getID(), facing = facing, sound = nil, soundFrame = 1 } )

			sim:dispatchEvent( simdefs.EV_PLAY_SOUND, {sound=droneSound, x=x0,y=y0} )
			sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR_PST, { unitID = unit:getID(), facing = facing } )


			unit:getTraits().mp = unit:getTraits().mp + self.ap_boost

			sim:dispatchEvent( simdefs.EV_GAIN_AP, { unit = unit } )
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.UI.FLY_TXT.MOVEMENT_BOOSTED,x=x0,y=y0,color={r=1,g=1,b=1,a=1}} )

			unit:getTraits().hasAlreadyPetDrone = true

			if not self._shouldShowAPBonus then
				-- Player has seen the AP boost. The UI may now show it on other agents or in future games.
				local settings = savefiles.getSettings( "settings" )
				settings.data.seenOnce = settings.data.seenOnce or {}
				settings.data.seenOnce[ "MM-petDrone-AP" ] = true
				self._shouldShowAPBonus = true
				settings:save()
			end
		end,
	}

return MM_petDrone
