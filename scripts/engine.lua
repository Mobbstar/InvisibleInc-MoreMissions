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
