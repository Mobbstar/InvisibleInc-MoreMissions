local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )

local 	MM_summonGuard = 
	{
		name = STRINGS.MOREMISSIONS.ABILITIES.ACTIVATE_NANOFAB_CONSOLE,

		-- onTooltip = function( self, hud, sim, abilityOwner, abilityUser, targetUnitID )
			-- local tooltip = util.tooltip( hud._screen )
			-- local section = tooltip:addSection()
			-- local canUse, reason = abilityUser:canUseAbility( sim, self, abilityOwner, targetUnitID )		
			-- local targetUnit = sim:getUnit( targetUnitID )
	        -- section:addLine( targetUnit:getName() )
			-- if targetUnit:getTraits().luxuryNanofab_console then
				-- util.sformat(STRINGS.MOREMISSIONS.ABILITIES.ACTIVATE_NANOFAB_CONSOLE_DESC, STRINGS.MOREMISSIONS.ABILITIES.ACTIVATE_NANOFAB_CONSOLE, "gui/items/icon-action_hack-console.png" )
			-- end
			-- if reason then
				-- section:addRequirement( reason )
			-- end
			-- return tooltip
		-- end,
		
		createToolTip = function( self, sim, unit )
			return abilityutil.formatToolTip(STRINGS.MOREMISSIONS.ABILITIES.ACTIVATE_NANOFAB_CONSOLE, STRINGS.MOREMISSIONS.ABILITIES.ACTIVATE_NANOFAB_CONSOLE_DESC )
		end,

		proxy = true,

		getName = function( self, sim, abilityOwner, abilityUser, targetUnitID )
			return self.name
		end,
		
		profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",

		isTarget = function( self, abilityOwner, unit, targetUnit )
		
			if targetUnit:getTraits().mainframe_status ~= "active" then
				return false
			end

			return true
		end,

		acquireTargets = function( self, targets, game, sim, abilityOwner, unit )
			local units = {}
			for _, targetUnit in pairs(sim:getAllUnits()) do
				local x1, y1 = targetUnit:getLocation()
				if x1 and self:isTarget( abilityOwner, unit, targetUnit ) and targetUnit:getTraits().luxuryNanofab_console and simquery.canUnitReach( sim, unit, x1, y1 ) then
					table.insert( units, targetUnit )
				end
			end

			return targets.unitTarget( game, units, self, abilityOwner, unit )
		end,

		canUseAbility = function( self, sim, abilityOwner, unit, targetUnitID )
			local targetUnit = sim:getUnit( targetUnitID )
			local userUnit = abilityOwner:getUnitOwner()

			if abilityOwner:getTraits().cooldown and abilityOwner:getTraits().cooldown > 0 then
				return false, util.sformat(STRINGS.UI.REASON.COOLDOWN,unit:getTraits().cooldown)
			end	

			if abilityOwner:getPlayerOwner() ~= unit:getPlayerOwner() then 
				return false,  STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
			end

			return abilityutil.checkRequirements( abilityOwner, userUnit )
		end,

		-- Mainframe system.

		executeAbility = function( self, sim, abilityOwner, unit, targetUnitID )
		
			local targetUnit = sim:getUnit( targetUnitID )			
			local x0,y0 = unit:getLocation()
			local x1, y1 = targetUnit:getLocation()

			local facing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )

			sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = unit:getID(), targetID= targetUnitID, facing = facing, sound=simdefs.SOUNDPATH_USE_CONSOLE, soundFrame=10 } )			
			-- sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/HUD/mainframe/node_capture" )
			
			sim:triggerEvent( "MM_nanofab_summonedGuard", { unit = targetUnit, consoleUnit = abilityOwner } )

			abilityOwner:getTraits().mainframe_status =  "inactive"
		end,

	}
return MM_summonGuard