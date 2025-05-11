local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )

local function existWitnesses( sim )
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().witness and (unit:getTraits().mainframe_camera or unit:getTraits().isDrone) then
			return true
		end
	end
	return false
end

local function findWitnesses( sim )
	local witnesses = {}
	for _, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().witness and (unit:getTraits().mainframe_camera or unit:getTraits().isDrone) then
			table.insert(witnesses, unit)
		end
	end
	return witnesses
end
local function clearWitness( sim, db, unit )
	unit:getTraits().witness = nil
	unit:destroyTab()
	sim:triggerEvent( "MM_device_witness_scrubbed" , { db=db, unit=unit })
	sim:getPC():glimpseUnit( sim, unit:getID() ) -- To clear witness status from the ghost.
	local x0, y0 = unit:getLocation()
	if x0 then
		sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(STRINGS.MOREMISSIONS.UI.WITNESS_CLEARED),x=x0,y=y0,color={r=1,g=1,b=1,a=1}} )
	end
end

local function finishHacking(self, sim, hacker)
	local x0, y0 = self.abilityOwner:getLocation()
	sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(STRINGS.MOREMISSIONS.UI.CAMERADB_SCRUBBED),x=x0,y=y0,color={r=1,g=1,b=1,a=1}} )

	if not hacker then
		return -- DB was forcibly rebooted or similar disruption.
	end
	hacker:getTraits().data_hacking = nil
	self.abilityOwner:getTraits().hacker = nil
	hacker:getSounds().spot = nil
	sim:dispatchEvent( simdefs.EV_UNIT_TINKER_END, { unit = hacker } )
	sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit= hacker } )
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

            local x1, y1 = abilityOwner:getLocation()
            if x1 and abilityOwner:getTraits().mainframe_status == "active" and simquery.canUnitReach( sim, unit, x1, y1 ) then
                table.insert( units, abilityOwner )
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

			if unit:getTraits().data_hacking == abilityOwner:getID() or abilityOwner:getTraits().hacker then
				return false, STRINGS.UI.REASON.ALREADY_HACKING
			end

			-- if unit:getTraits().MM_mole ~= true then
				-- return false, STRINGS.ABILITIES.HACK_ONLY_MOLE --only mole
			-- end

			if abilityOwner:getPlayerOwner() ~= sim:getPC() then
				return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
			end

			if not existWitnesses(sim) then
				return false, STRINGS.MOREMISSIONS.UI.NO_CAMERADB_WITNESSES
			end

			return abilityutil.checkRequirements( abilityOwner, userUnit )
		end,

		onSpawnAbility = function( self, sim, unit )
			self.abilityOwner = unit

			-- Override vanilla progressHack (from data banks)
			function unit:progressHack()
				local scrub = self:hasAbility("MM_scrubcameradb")
				scrub:onProgressHack( sim )
			end
		end,

		onDespawnAbility = function( self, sim, unit )
			self.abilityOwner = nil
		end,

		-- Called by db:progressHack() installed by onSpawnAbility.
		onProgressHack = function( self, sim)
			local witnesses = findWitnesses( sim )

			if #witnesses > 0 then
				local unit = witnesses[sim:nextRand(1, #witnesses)]
				clearWitness( sim, self.abilityOwner, unit )
			end

			if #witnesses <= 1 then -- None, or last witness
				local hacker = sim:getUnit( self.abilityOwner:getTraits().hacker )
				finishHacking(self, sim, hacker)
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

			unit:getTraits().data_hacking = abilityOwner:getID() --trait to set looped tinker anim
			abilityOwner:getTraits().hacker = unit:getID()

			-- self.abilityOwner:getTraits().progress = abilityOwner:getTraits().progress or 0
			unit:getSounds().spot = "SpySociety/Actions/monst3r_hacking"
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = unit })
		end,

	}

return MM_scrubcameradb
