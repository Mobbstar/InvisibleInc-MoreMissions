local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local function runAppend( modApi )
	local scriptPath = modApi:getScriptPath()
	local assassination_mission = include( scriptPath .. "/missions/assassination" )
	local melee = abilitydefs.lookupAbility("melee")
	local melee_canUse_old = melee.canUseAbility
	melee.canUseAbility = function(self, sim, unit, userUnit, targetID, ...)
		local result, reason1, reason2, reason3 = melee_canUse_old(self, sim, unit, userUnit, targetID, ...)
		local tazerUnit = simquery.getEquippedMelee( unit )
		if (result == true) and targetID and tazerUnit then
			local targetUnit = sim:getUnit(targetID)

			if tazerUnit:getRequirements() then
				for skill,level in pairs( tazerUnit:getRequirements() ) do
					if not unit:hasSkill(skill, level) and not unit:getTraits().useAnyItem then

						local skilldefs = include( "sim/skilldefs" )
						local skillDef = skilldefs.lookupSkill( skill )

						return false, string.format( STRINGS.UI.TOOLTIP_REQUIRES_SKILL_LVL, util.toupper(skillDef.name), level )
					end
				end
			end
		end
		return result, reason1, reason2, reason3
	end

	-- Assassination
	local melee_executeOld = melee.executeAbility
	melee.executeAbility = function( self, sim, unit, userUnit, target, ... )
		local targetUnit = sim:getUnit(target)
		if targetUnit:getTraits().MM_decoy then
			-- punch animation, un-disguise, stagger
			local x0,y0 = unit:getLocation()
			local x1,y1 = targetUnit:getLocation()	
			local facing = simquery.getDirectionFromDelta(x1-x0,y1-y0)
			local pinning, pinnee = simquery.isUnitPinning(sim, unit)
			if pinning and pinnee ~= targetUnit then
				pinning = false
			end
			-- sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR, { unitID = unit:getID(), facing = facing } )
			sim:dispatchEvent( simdefs.EV_UNIT_MELEE, { unit = unit, targetUnit = targetUnit, grapple = false, pinning = pinning, lethal = true} )	
			assassination_mission.revealDecoy( sim, targetUnit, true )
			-- sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR_PST, { unitID = unit:getID(), facing = facing } )	
			return
		end
		return melee_executeOld( self, sim, unit, userUnit, target, ... )
	end
end

return { runAppend = runAppend }