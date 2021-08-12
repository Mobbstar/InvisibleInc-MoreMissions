local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )

local function existWitnesses( sim )
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().witness and (unit:getTraits().mainframe_camera) then
			return true
		end
	end
	return false
end

local function clearWitnesses( sim )
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().witness and unit:getTraits().mainframe_camera then
			unit:getTraits().witness = nil
			unit:destroyTab()
		end
	end
end

local MM_scrubcameradb = --tweaked version of monster root hub hack
	{
		name = STRINGS.MOREMISSIONS.ABILITIES.SCRUB_CAMERADB,

		createToolTip = function( self, sim, unit )
			return abilityutil.formatToolTip(STRINGS.MOREMISSIONS.ABILITIES.SCRUB_CAMERADB,STRINGS.MOREMISSIONS.ABILITIES.SCRUB_CAMERADB_DESC) 
		end,

		proxy = true,

		getName = function( self, sim, abilityOwner, abilityUser, targetUnitID )
			return self.name
		end,
		
		alwaysShow = true,
		
		profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",

		isTarget = function( self, abilityOwner, unit, targetUnit )
		
			if targetUnit:getTraits().mainframe_status ~= "active" then
				return false
			end
			
			return true
		end,

		acquireTargets = function( self, targets, game, sim, abilityOwner, unit )
			local units = {}
			
			-- if sim:getTags().finished_DB_hack then
				-- return targets.unitTarget( game, units, self, abilityOwner, unit )
			-- end 

			for _, targetUnit in pairs(sim:getAllUnits()) do
				local x1, y1 = targetUnit:getLocation()
				if x1 and self:isTarget( abilityOwner, unit, targetUnit ) and simquery.canUnitReach( sim, unit, x1, y1 ) then
					table.insert( units, targetUnit )
				end
			end

			return targets.unitTarget( game, units, self, abilityOwner, unit )
		end,

		canUseAbility = function( self, sim, abilityOwner, unit, targetUnitID )
			local targetUnit = sim:getUnit( targetUnitID )
			local userUnit = abilityOwner:getUnitOwner()

			if abilityOwner:getTraits().cooldown and abilityOwner:getTraits().cooldown > 0 then
				return false,  util.sformat(STRINGS.UI.REASON.COOLDOWN,abilityOwner:getTraits().cooldown)
			end	
			if abilityOwner:getTraits().usesCharges and abilityOwner:getTraits().charges < 1 then
				return false, util.sformat(STRINGS.UI.REASON.CHARGES)
			end				

			if unit:getTraits().monster_hacking == true then 
				return false, STRINGS.UI.REASON.ALREADY_HACKING 
			end 

			-- if unit:getTraits().MM_mole ~= true then 
				-- return false, STRINGS.ABILITIES.HACK_ONLY_MOLE --only mole
			-- end 

			if abilityOwner:getTraits().mainframe_ice > 0 then 
				return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
			end
			
			if not existWitnesses(sim) then
				return false, STRINGS.MOREMISSIONS.UI.NO_CAMERADB_WITNESSES
			end

			return abilityutil.checkRequirements( abilityOwner, userUnit )
		end,
		
		onSpawnAbility = function( self, sim, unit )
			self.abilityOwner = unit
			sim:addTrigger( simdefs.TRG_START_TURN, self )
		end,
		
		onDespawnAbility = function( self, sim, unit )
			self.abilityOwner = nil
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,		
		
		onTrigger = function( self, sim, evType, evData )
			-- warp stuff taken care of in simunit.stopHacking
			if (evType == simdefs.TRG_START_TURN) and evData:isPC() then
				local hacker = sim:getUnit( self.abilityOwner:getTraits().MM_hacker )

				if hacker and ( hacker:getTraits().monster_hacking == self.abilityOwner:getID() ) then
					-- log:write("LOG clearing witnesses")
					clearWitnesses( sim )
					local x0, y0 = self.abilityOwner:getLocation()
					sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(STRINGS.MOREMISSIONS.UI.CAMERADB_SCRUBBED),x=x0,y=y0,color={r=1,g=1,b=1,a=1}} )
					hacker:getTraits().monster_hacking = nil
					self.abilityOwner:getTraits().MM_hacker = nil
					hacker:getSounds().spot = nil
					sim:dispatchEvent( simdefs.EV_UNIT_TINKER_END, { unit = hacker } )					
					sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit= hacker } )
					sim:triggerEvent( "cameradb_scrubbed" )
				end
			end
		
		end,
		
		executeAbility = function( self, sim, abilityOwner, unit, targetUnitID )
			local targetUnit = sim:getUnit( targetUnitID )

			local x0,y0 = unit:getLocation()
			local x1,y1 = targetUnit:getLocation()			
			local tempfacing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )
			unit:setFacing(tempfacing)	
			sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = unit:getID(), facing = tempfacing, sound = "SpySociety/Actions/monst3r_jackin" , soundFrame = 16, useTinkerMonst3r=true } )
			-- sim:triggerEvent( "mole_DB_hack_start" )

			unit:getTraits().monster_hacking = abilityOwner:getID() --trait to set looped tinker anim
			abilityOwner:getTraits().MM_hacker = unit:getID()
			
			-- self.abilityOwner:getTraits().progress = abilityOwner:getTraits().progress or 0 			
			unit:getSounds().spot = "SpySociety/Actions/monst3r_hacking"
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = unit })
		end,

	}
	
return MM_scrubcameradb