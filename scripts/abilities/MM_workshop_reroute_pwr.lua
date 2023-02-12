local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )
local jackin = abilitydefs._abilities["jackin"]
local simdefs = include("sim/simdefs")
local speechdefs = include("sim/speechdefs")
local abilityutil = include( "sim/abilities/abilityutil" )
local simquery = include("sim/simquery")

local baseOnSpawn = jackin.onSpawnAbility
jackin.onSpawnAbility = function( self, sim, unit )
	if baseOnSpawn then
		baseOnSpawn( self, sim, unit )
	end
	
	if sim:getParams().side_mission == "MM_workshop" then --only add the ability, if the side mission is present
		unit:giveAbility( "MM_workshop_reroute_pwr" )
	end
end
local baseOnDespawn = jackin.onDespawnAbility
jackin.onDespawnAbility = function( self, sim, unit )
	if baseOnDespawn then
		baseOnDespawn( self, sim, unit )
	end
	
	unit:removeAbility( sim, "MM_workshop_reroute_pwr" ) --there is no error if the ability doesn't exist
end

local MM_workshop_reroute_pwr =
{
	name = STRINGS.MOREMISSIONS.ABILITIES.REROUTE_PWR,
	
	profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",
	
	proxy = true,
	
	onTooltip = function( self, hud, sim, abilityOwner, abilityUser, targetUnitID )
		local tooltip = util.tooltip( hud._screen )
		local section = tooltip:addSection()
		local canUse, reason = abilityUser:canUseAbility( sim, self, abilityOwner, targetUnitID )		
		local targetUnit = sim:getUnit( targetUnitID )
		section:addLine( targetUnit:getName() )
		if (targetUnit:getTraits().cpus or 0) > 0 then
			section:addAbility( self:getName(sim, abilityOwner, abilityUser, targetUnitID), STRINGS.MOREMISSIONS.ABILITIES.REROUTE_PWR_DESC, "gui/items/icon-action_hack-console.png" )
		end
		if reason then
			section:addRequirement( reason )
		end
		return tooltip
	end,
	
	getName = function( self, sim, abilityOwner, abilityUser, targetUnitID )
		local targetUnit = sim:getUnit( targetUnitID )
		if targetUnit then
			local cpus, bonus = self:calculateCPUs( abilityOwner, abilityUser, targetUnit )
			local pwr = cpus + (bonus or 0)
			return util.sformat( STRINGS.MOREMISSIONS.ABILITIES.REROUTE_PWR, pwr )
		end
		
		return false
	end,
	
	calculateCPUs = jackin.calculateCPUs,
	
	isTarget = jackin.isTarget,
	
	acquireTargets = jackin.acquireTargets,
	
	canUseAbility = jackin.canUseAbility,
	
	executeAbility = function( self, sim, abilityOwner, unit, targetUnitID )
		sim:emitSpeech( unit, speechdefs.EVENT_HIJACK )

		sim._resultTable.consoles_hacked = sim._resultTable.consoles_hacked and sim._resultTable.consoles_hacked + 1 or 1
		
		if unit:getTraits().wireless_range then
			sim:dispatchEvent( simdefs.EV_UNIT_WIRELESS_SCAN, { unitID = unit:getID(), targetUnitID = targetUnitID, hijack = true } )
		end

		local targetUnit = sim:getUnit( targetUnitID )
		assert( targetUnit, "No target : "..tostring(targetUnitID))
		local x1, y1 = targetUnit:getLocation()

		if not unit:getTraits().wireless_range then
			local x0, y0 = unit:getLocation()
			local facing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )
			sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = unit:getID(), targetID= targetUnit:getID(), facing = facing, sound=simdefs.SOUNDPATH_USE_CONSOLE, soundFrame=10 } )
		end

		local triggerData = sim:triggerEvent(simdefs.TRG_UNIT_HIJACKED, { unit=targetUnit, sourceUnit=unit } )
		if not triggerData.abort then

			local cpus, bonus = self:calculateCPUs( abilityOwner, unit, targetUnit )
			local pwr = cpus + (bonus or 0)
		    
		    	sim.MM_workshop_pwr = (sim.MM_workshop_pwr or 0) + pwr
			sim:triggerEvent( "MM_reroute_power", {abilityOwner=abilityOwner, unit=unit, pwr=pwr} )

			targetUnit:getTraits().hijacked = true
			targetUnit:getTraits().mainframe_suppress_range = nil
			targetUnit:setPlayerOwner(abilityOwner:getPlayerOwner())			
			targetUnit:getTraits().cpus = 0
		end
		if not unit:getTraits().wireless_range then
			sim:processReactions( abilityOwner )
		end

		sim:getCurrentPlayer():glimpseUnit( sim, targetUnit:getID() )
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = targetUnit } )
	end,
}

return MM_workshop_reroute_pwr
