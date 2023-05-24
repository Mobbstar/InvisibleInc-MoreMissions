local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local assassination_mission = include( SCRIPT_PATHS.more_missions .. "/missions/assassination" )

-- SIMUNIT ------------------------------------------------
-- setAlerted edit to allow un-alerting for Amnesiac function
local simunit = include("sim/simunit")
local simunit_setAlerted_old = simunit.setAlerted
simunit.setAlerted = function( self, alerted, ... )
	if self and self:getTraits().MM_amnesiac and self._sim then
		self:getTraits().alerted = nil
		self:getTraits().MM_amnesiac = nil --clear the trait after it's used
	else
		return simunit_setAlerted_old( self, alerted, ... )
	end
end

local oldGetname = simunit.getName
simunit.getName = function( self, ... )
	if self:getTraits().customName then
		return tostring(self:getTraits().customName)
	end
	return oldGetname ( self)
end

-- for clearing mainframe witnesses
local processEMP_old = simunit.processEMP
simunit.processEMP = function( self, bootTime, noEmpFX, ... )
	processEMP_old( self, bootTime, noEmpFX, ... ) 
	if self:getTraits().witness and self:getTraits().mainframe_item and (self:getTraits().isDrone or self:getTraits().mainframe_camera) then
		self:getTraits().witness = nil
		self:getSim():triggerEvent("MM_processed_EMP_on_witness")
		local x0, y0 = self:getLocation()
		if x0 and y0 then
			self._sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(STRINGS.MOREMISSIONS.UI.WITNESS_CLEARED),x=x0,y=y0,color={r=1,g=1,b=1,a=1}} )
		end
	end
	if self:getTraits().MM_decoy then
		local newTarget = assassination_mission.revealDecoy( self:getSim(), self, nil, { bootTime = bootTime, noEmpFX = noEmpFX } )
		if newTarget and newTarget:isValid() then
			processEMP_old( newTarget, bootTime, noEmpFX, ... )
		else
			return
		end
	end		
end

-- update stopHacking to refresh database hacking state
local stopHacking_old = simunit.stopHacking
simunit.stopHacking = function(self, sim, ... ) --refreshes the hacking anim state for the mole's database hack. we don't care about legit uses of monster_hacking because that's handled by ending_1
	stopHacking_old( self, sim, ... )
	if self:getTraits().monster_hacking then
		local target = sim:getUnit(self:getTraits().monster_hacking)
		if target:getTraits().MM_personneldb or target:getTraits().MM_camera_core then
			self:getTraits().data_hacking = nil
			self:getSounds().spot = nil
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self })
		end
	end
end

-- this keeps the personnel DB hack from erroneously triggering actual data bank hacking scripts
local simunit_progressHack_old = simunit.progressHack
simunit.progressHack = function( self, ... )
	if self:getTraits().MM_personneldb then
		return
	end
	return simunit_progressHack_old( self, ... )
end

-- ASSASSINATION bodyguard
local simunit_onDamage_old = simunit.onDamage
simunit.onDamage = function( self, damage, ... )
	simunit_onDamage_old( self, damage, ... )
	if self and self:isValid() and self:getLocation() and not self:getTraits().isDead and (self:getTraits().MM_bodyguard or self:getTraits().MM_bounty_target) then
		if (self:getTraits().wounds < self:getTraits().woundsMax) and not self:isKO() then
			self:getSim():dispatchEvent( simdefs.EV_UNIT_HIT, {unit = self, result = 0} ) --stagger FX
		end
	end
end

local simunit_setKO_old = simunit.setKO --for flash grenade
simunit.setKO = function( self, sim, ticks, fx, ... )
	if self:getTraits().MM_decoy then
		assassination_mission.revealDecoy( sim, self )
		return
	end
	return simunit_setKO_old( self, sim, ticks, fx, ... )
end

local simunit_setInvisible_old = simunit.setInvisible
simunit.setInvisible = function( self, state, duration, ... )
	if (state == false) and self:getTraits().MM_attackproof_cloak then
		if self:getTraits().invisDuration then
			return --prevent premature decloaking while cloak is active
		else --cloak has expired!
			self:getTraits().MM_attackproof_cloak = nil --remove trait and let rest of decloaking function run as normal
		end

	end
	self:getSim():triggerEvent( "TRG_UNIT_INVIS", { unit = self, state = state, duration = duration } )
	return simunit_setInvisible_old( self, state, duration, ... )
end

-- for Texpo
local simunit_increaseIce_old = simunit.increaseIce
simunit.increaseIce = function( self, sim, iceInc, ... )
	if sim.MM_security_disabled and self:hasTag("MM_topGear") and (iceInc > 0) then
		return
	end
	simunit_increaseIce_old( self, sim, iceInc, ... )
end

-- for Tech Expo androids visual glitch
local simunit_takeControl_old = simunit.takeControl
simunit.takeControl = function( self, player, ... )
	if self:getTraits().LOSperipheralRange then
		self:getTraits().hasSight = false
		self:getTraits().hadSight = true
		self:getSim():refreshUnitLOS( self )
	end
	simunit_takeControl_old( self, player, ... )
	if self:getTraits().hadSight then
		self:getTraits().hasSight = true
		self:getTraits().hadSight = nil
	end
end

-- SIMDRONE ------------------------------------------------
local simdrone = include("sim/units/simdrone")
local simdrone_processEMP_old = simdrone.processEMP
simdrone.processEMP = function(self, empTime, noEmpFx, noAttack, ignoreMagRei, ...)
	-- log:write("LOG custom process EMP drone")
	simdrone_processEMP_old(self, empTime, noEmpFx, noAttack, ignoreMagRei, ...)
	if self:getTraits().witness then
		self:getTraits().witness = nil
		sim:triggerEvent("MM_processed_EMP_on_witness")
		local x0, y0 = self:getLocation()
		if x0 and y0 then
			self._sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(STRINGS.MOREMISSIONS.UI.WITNESS_CLEARED),x=x0,y=y0,color={r=1,g=1,b=1,a=1}} )
		end
	end
end
