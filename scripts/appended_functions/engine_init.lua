local simdefs = include( "sim/simdefs" )
local simengine = include( "sim/engine" )
local simquery = include( "sim/simquery" )

-----
-- Allow guards with npcPassiveKeyBits to use matching locked doors

local oldModifyExit = simengine.modifyExit

function simengine:modifyExit( cell, dir, exitOp, unit, stealth, ... )
	local exit = cell.exits[dir]
	assert( exit )

	if exitOp == simdefs.EXITOP_OPEN and exit.locked and unit and simquery._canUseLockedExit( unit, exitOp, exit ) == 'mm_npckey' then
		-- Unlock, but set to automatically close and lock
		local reverseExit = exit.cell.exits[simquery.getReverseDirection( dir )]
		exit.locked, reverseExit.locked = nil, nil
		exit.closeEndTurn, reverseExit.closeEndTurn = true, true
		exit.lockEndTurn, reverseExit.lockEndTurn = true, true
		exit.temporaryCloseEndTurn, reverseExit.temporaryCloseEndTurn = true, true
		exit.temporaryLockEndTurn, reverseExit.temporaryLockEndTurn = true, true
	end

	oldModifyExit( self, cell, dir, exitOp, unit, stealth, ... )

	if exitOp == simdefs.EXITOP_CLOSE and exit.temporaryLockEndTurn then
		local reverseExit = exit.cell.exits[simquery.getReverseDirection( dir )]
		assert( exit.closed and reverseExit.closed )
		-- Lock and clear the the temporary flags
		exit.locked, reverseExit.locked = true, true
		exit.closeEndTurn, reverseExit.closeEndTurn = nil, nil
		exit.lockEndTurn, reverseExit.lockEndTurn = nil, nil
		exit.temporaryCloseEndTurn, reverseExit.temporaryCloseEndTurn = nil, nil
		exit.temporaryLockEndTurn, reverseExit.temporaryLockEndTurn = nil, nil

		self:dispatchEvent( simdefs.EV_EXIT_MODIFIED, { cell = cell, dir = dir, exitOp = simdefs.EXITOP_LOCK } )
	end
end

-----
-- Add a sim trigger for simultaneous KO/Kill groups
--
-- To defer a hook until after simultaneous KOs/Kills have been processed, check hasDaemonQueue, and if so wait for MM-KOGROUP-END before continuing.
--
-- Relies on mods wrapping simultaneous KOs/Kills in startDaeemonQueue/processDaemonQueue, which vanilla only requires for simultaneous KO.
--

function simengine:hasDaemonQueue()
	return self._daemonQueue ~= nil
end

local oldProcessDaemonQueue = simengine.processDaemonQueue

function simengine:processDaemonQueue( ... )
	oldProcessDaemonQueue( self, ... )

	self:triggerEvent( 'MM-KOGROUP-END' )
end

-- for Assassination mission: ensure lethal laser grids in saferoom prefab
local simengine = include("sim/engine")
local oldInit = simengine.init

function simengine.init( self, params, levelData, ... )
	self._levelOutput = levelData:parseBoard( params.seed, params )
	if params.situationName == "assassination" then
		for i, unit in pairs(self._levelOutput.units) do
			if unit.template and unit.unitData and unit.unitData.traits and unit.unitData.traits.lethal_laser then
				unit.template = "security_laser_emitter_1x1"
			end
		end
	end
	oldInit( self, params, levelData, ... )
end

local sim_canPlayerSeeUnit_old = simengine.canPlayerSeeUnit
simengine.canPlayerSeeUnit = function( self, player, unit, ... )
	if (player == self:getPC()) and unit:getTraits().MM_invisible_to_PC then
		return false
	end
	return sim_canPlayerSeeUnit_old( self, player, unit, ... )
end

--other half of tracker edit is in aiplayer append --OLD
-- local _trackerAdvance = simengine.trackerAdvance
-- function simengine.trackerAdvance(self, delta, ...)
	-- local trackerBoost = self.missionTrackerBoost or 0
	-- delta = delta + trackerBoost
	-- return _trackerAdvance(self, delta, ...)
-- end
