local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )
local jackin = abilitydefs._abilities["jackin"]
local simdefs = include("sim/simdefs")
local speechdefs = include("sim/speechdefs")
local abilityutil = include( "sim/abilities/abilityutil" )
local simquery = include("sim/simquery")

local MM_workshop_reroute_pwr =
{
	name = STRINGS.MOREMISSIONS.ABILITIES.REROUTE_PWR,
	
	profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",
	
	proxy = true,
	
	onTooltip = function( self, hud, sim, abilityOwner, abilityUser )
		local tooltip = util.tooltip( hud._screen )
		local section = tooltip:addSection()
		local canUse, reason = abilityUser:canUseAbility( sim, self, abilityOwner, abilityUser )		
		section:addLine( abilityOwner:getName() )
		if (abilityOwner:getTraits().cpus or 0) > 0 then
			section:addAbility( self:getName(sim, abilityOwner, abilityUser), STRINGS.MOREMISSIONS.ABILITIES.REROUTE_PWR_DESC, "gui/items/icon-action_hack-console.png" )
		end
		if reason then
			section:addRequirement( reason )
		end
		return tooltip
	end,
	
	getName = function( self, sim, abilityOwner, abilityUser )
		if abilityOwner then
			local cpus, bonus = self:calculateCPUs( abilityOwner, abilityUser )
			local pwr = cpus + (bonus or 0)
			return util.sformat( STRINGS.MOREMISSIONS.ABILITIES.REROUTE_PWR, pwr )
		end
		
		return false
	end,
	
	calculateCPUs = function( self, abilityOwner, unit)
		local bonus = unit:getTraits().hacking_bonus or 0
		
		return math.ceil( abilityOwner:getTraits().cpus ), bonus
	end,
	
	canUseAbility = function( self, sim, unit, userUnit )
			   
		if not simquery.canUnitReach( sim, userUnit, unit:getLocation() ) then
			return false
		end

		if not userUnit:hasAbility( "jackin" ) then
			return false --tied to jackin ability
		end

		if unit:getTraits().mainframe_status ~= "active" then
			return false
		end

		if (unit:getTraits().cpus or 0) <= 0 then
			return false
		end
		
		if sim.MM_workshop_complete then
			return false
		end
		
		if unit:getTraits().mainframe_console_lock > 0 then
			return false, STRINGS.UI.REASON.CONSOLE_LOCKED
		end

		return true
	end,
	
	executeAbility = function( self, sim, abilityOwner, unit )
		sim:emitSpeech( unit, speechdefs.EVENT_HIJACK )

		sim._resultTable.consoles_hacked = sim._resultTable.consoles_hacked and sim._resultTable.consoles_hacked + 1 or 1
		
		local x1, y1 = abilityOwner:getLocation()

		local x0, y0 = unit:getLocation()
		local facing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )
		sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = unit:getID(), targetID= abilityOwner:getID(), facing = facing, sound=simdefs.SOUNDPATH_USE_CONSOLE, soundFrame=10 } )

		local triggerData = sim:triggerEvent(simdefs.TRG_UNIT_HIJACKED, { unit=abilityOwner, sourceUnit=unit } )
		if not triggerData.abort then

			local cpus, bonus = self:calculateCPUs( abilityOwner, unit )
			local pwr = cpus + (bonus or 0)
		    
		    	sim.MM_workshop_pwr = (sim.MM_workshop_pwr or 0) + pwr
			sim:triggerEvent( "MM_reroute_power", {abilityOwner=abilityOwner, unit=unit, pwr=pwr} )

			abilityOwner:getTraits().hijacked = true
			abilityOwner:getTraits().mainframe_suppress_range = nil
			abilityOwner:setPlayerOwner(unit:getPlayerOwner())			
			abilityOwner:getTraits().cpus = 0
		end
		if not unit:getTraits().wireless_range then
			sim:processReactions( unit )
		end

		sim:getCurrentPlayer():glimpseUnit( sim, abilityOwner:getID() )
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = abilityOwner } )
	end,
}

return MM_workshop_reroute_pwr
