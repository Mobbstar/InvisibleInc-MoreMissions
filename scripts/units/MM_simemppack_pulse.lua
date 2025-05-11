----------------------------------------------------------------
-- Copyright (c) 2012 Klei Entertainment Inc.
-- All Rights Reserved.
-- SPY SOCIETY.
----------------------------------------------------------------

local util = include( "modules/util" )
local array = include( "modules/array" )
local simunit = include( "sim/simunit" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local simfactory = include( "sim/simfactory" )
local mathutil = include( "modules/mathutil" )
local cdefs = include( "client_defs" )

-----------------------------------------------------
-- Local functions

local emp = { ClassType = "MM_simemppack_pulse" }

function emp:detonate( sim )
	local x0,y0 = self:getLocation()

	if self:getTraits().flash_pack then
		local sim, player = self:getSim(), self:getPlayerOwner()

		sim:startTrackerQueue(true)
		sim:startDaemonQueue()
	    sim:dispatchEvent( simdefs.EV_KO_GROUP, true )
	    local cells = self:getExplodeCells()

		sim:dispatchEvent( simdefs.EV_FLASH_VIZ, {x = x0, y = y0, units = nil, range = self:getTraits().range} )

		for i, cell in ipairs(cells) do
			for i, cellUnit in ipairs( cell.units ) do
				if self:getTraits().baseDamage and simquery.isEnemyAgent( player, cellUnit) and not cellUnit:getTraits().isDrone then
					if self:getTraits().canSleep then

						local damage = self:getTraits().baseDamage
						damage = cellUnit:processKOresist( damage )

						cellUnit:setKO(sim, damage)
					else
						sim:damageUnit(cellUnit, self:getTraits().baseDamage)
					end
				end
			end
		end

	    sim:dispatchEvent( simdefs.EV_KO_GROUP, false )
		sim:startTrackerQueue(false)
		sim:processDaemonQueue()
	else

	    local units = self:getTargets( x0, y0 )

		-- CHANGES FROM VANILLA HERE
		for i = self:getTraits().multiPulse, 1, -1 do
			-- sim:dispatchEvent( simdefs.EV_OVERLOAD_VIZ, {x = x0, y = y0, units = units, range = self:getTraits().range } )
			sim:emitSound( simdefs.SOUND_SMALL, x0, y0, nil )
			sim:dispatchEvent( simdefs.EV_OVERLOAD_VIZ, {x = x0, y = y0, range = self:getTraits().range } )
			sim:getLevelScript():queue(0.2*cdefs.SECONDS)
			for i, unit in ipairs(units) do
				if unit and unit:isValid() and unit:getLocation() then
					unit:processEMP( self:getTraits().emp_duration, true )
				end
			end
		end

	end

	-- Destroy the DEVICE.
	sim:processReactions(self)

	sim:warpUnit( self, nil )
	sim:despawnUnit( self )
end

function emp:onWarp(sim)
	if not self:getTraits().trigger_mainframe then
		if self:getLocation() then
			sim:addTrigger( simdefs.TRG_END_TURN, self )
		else
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
		end
	end
end

function emp:onTrigger( sim, evType, evData )
	if evType == simdefs.TRG_END_TURN then
		if self:getTraits().primed then
			self:detonate( sim )
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self} )
		end

	end
end

function emp:getTargets( x0, y0 )

	local cells = {}

	if self:getTraits().flash_pack then
		local currentCell = self:getSim():getCell( x0, y0 )
		cells = {currentCell}
		if self:getTraits().range then
			local fillCells = simquery.fillCircle( self:getSim(), x0, y0, self:getTraits().range, 0)

			for i, cell in ipairs(fillCells) do
				if cell ~= currentCell then
					local raycastX, raycastY = self._sim:getLOS():raycast(x0, y0, cell.x, cell.y)
					if raycastX == cell.x and raycastY == cell.y then
						table.insert(cells, cell)
					end
				end
			end
		end
	else
		cells = simquery.rasterCircle( self._sim, x0, y0, self:getTraits().range )
	end

    local units = {}
    for i, x, y in util.xypairs( cells ) do
        local cell = self._sim:getCell( x, y )
        if cell then
            for _, cellUnit in ipairs(cell.units) do
            	local player = self:getPlayerOwner()
                if cellUnit ~= self and (cellUnit:getTraits().mainframe_status or cellUnit:getTraits().heartMonitor) and (not self:getTraits().flash_pack or (simquery.isEnemyAgent( player, cellUnit) and not cellUnit:getTraits().isDrone)) then
                    table.insert( units, cellUnit )
                end
            end
		end
	end

    return units
end

-- get cells for FLASH PACK
function emp:getExplodeCells(x0,y0)

	assert(self:getTraits().range)

	if not x0 and not y0 then
    	x0, y0 = self:getLocation()
    end

	local currentCell = self:getSim():getCell( x0, y0 )
	local cells = {currentCell}
	if self:getTraits().range then
		local coords = simquery.rasterCircle( self._sim, x0, y0, self:getTraits().range )

		for i=1,#coords-1,2 do
			local cell = self._sim:getCell(coords[i],coords[i+1])
			if cell then
			local raycastX, raycastY = self._sim:getLOS():raycast(x0, y0, cell.x, cell.y)
				if raycastX == cell.x and raycastY == cell.y then
					table.insert(cells, cell)
				end
			end
		end
	end
    return cells
end

-- for FLASH PACK
function emp:toggle( sim )
	self:detonate( sim )
end

-----------------------------------------------------
-- Interface functions

local function createEMPPack( unitData, sim )
	return simunit.createUnit( unitData, sim, emp )
end

simfactory.register( createEMPPack )

return
{
	createEMPPack = createEMPPack,
}

