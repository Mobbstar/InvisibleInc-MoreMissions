local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local inventory = include("sim/inventory")
local abilityutil = include( "sim/abilities/abilityutil" )
local speechdefs = include("sim/speechdefs")
local mathutil = include( "modules/mathutil" )

local MM_activateLuxuryNanofab =
	{
		name = STRINGS.MOREMISSIONS.ABILITIES.UNLOCK_LUXURY_NANOFAB,
        proxy = true,

		onTooltip = function( self, hud, sim, abilityOwner, abilityUser, targetUnitID )
			local tooltip = util.tooltip( hud._screen )
			local section = tooltip:addSection()
			local canUse, reason = abilityUser:canUseAbility( sim, self, abilityOwner, targetUnitID )
			local targetUnit = sim:getUnit( targetUnitID )
	        section:addLine( STRINGS.MOREMISSIONS.ABILITIES.UNLOCK_LUXURY_NANOFAB )
			if reason then
				section:addRequirement( reason )
			end
			return tooltip
		end,

		getName = function( self, sim, abilityOwner, abilityUser, targetUnitID )
			return self.name
		end,

		profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",

        getProfileIcon = function( self, sim, abilityOwner )
            return abilityOwner:getUnitData().profile_icon or self.profile_icon
        end,

		isTarget = function( self, abilityOwner, unit, targetUnit )
			if not targetUnit:getTraits().luxuryNanofab then
				return false
			end

			-- if targetUnit:getTraits().mainframe_status ~= "active" then
				-- return false
			-- end

			return true
		end,

		acquireTargets = function( self, targets, game, sim, abilityOwner, unit )

			local x0, y0 = unit:getLocation()
			local units = {}
			for _, targetUnit in pairs(sim:getAllUnits()) do
				local x1, y1 = targetUnit:getLocation()
				if x1 and self:isTarget( abilityOwner, unit, targetUnit ) then
					local range = mathutil.dist2d( x0, y0, x1, y1 )
					-- This handles manual jacking. (heh)
					if range <= 1 and simquery.isConnected( sim, sim:getCell( x0, y0 ), sim:getCell( x1, y1 ) ) then
						table.insert( units, targetUnit )
					end
				end
			end

			return targets.unitTarget( game, units, self, abilityOwner, unit )
		end,

		canUseAbility = function( self, sim, abilityOwner, unit, targetUnitID )
            -- This is a proxy ability, but only usable if the proxy is in the inventory of the user.
            if abilityOwner ~= unit and abilityOwner:getUnitOwner() ~= unit then
                return false
            end

			local targetUnit = sim:getUnit( targetUnitID )

			if abilityOwner:getTraits().cooldown and abilityOwner:getTraits().cooldown > 0 then
				return false, string.format(STRINGS.UI.REASON.COOLDOWN,abilityOwner:getTraits().cooldown)
			end

			-- if targetUnit and targetUnit:getPlayerOwner() ~= unit:getPlayerOwner() then
				-- return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
			-- end

			return abilityutil.checkRequirements( abilityOwner, unit )
		end,

		-- Mainframe system.

		executeAbility = function( self, sim, abilityOwner, unit, targetUnitID )
			sim:emitSpeech( unit, speechdefs.EVENT_HIJACK )

			local targetUnit = sim:getUnit( targetUnitID )
			assert( targetUnit, "No target : "..tostring(targetUnitID))
			local x1, y1 = targetUnit:getLocation()

			local x0,y0 = unit:getLocation()
			local facing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )
			sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = unit:getID(), targetID= targetUnit:getID(), facing = facing, sound=simdefs.SOUNDPATH_USE_CONSOLE, soundFrame=10 } )


			if abilityOwner:getTraits().disposable then
				inventory.trashItem( sim, unit, abilityOwner )
			else
				inventory.useItem( sim, unit, abilityOwner )
			end

			if abilityOwner:getTraits().charges then
				abilityOwner:getTraits().charges = abilityOwner:getTraits().charges - 1
				if abilityOwner:getTraits().charges <= 0 then
					inventory.trashItem( sim, unit, abilityOwner )
				end
			end

			sim:processReactions( abilityOwner )
			sim:getCurrentPlayer():glimpseUnit( sim, targetUnit:getID() )
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = targetUnit } )

			targetUnit:getTraits().mainframe_booting = 1
			sim:triggerEvent( "MM_unlockedLuxuryNanoab", { unit = unit, targetUnit = targetUnit } )
		end,
	}
return MM_activateLuxuryNanofab