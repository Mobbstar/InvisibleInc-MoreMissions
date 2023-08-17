local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )
local simfactory = include( "sim/simfactory" )
local unitdefs = include( "sim/unitdefs" )

-- Survey passive: initially spawn stationary in the middle of the (procgen) room or as close to it as possible. Do local scan at start of enemy turn. If still idle, rotate 90 degrees at end of enemy turn.

local function returnMin(t)
	local k = nil
	for i, v in pairs(t) do
	k = k or v
	if v < k then k = v end
	end
	return k
end

local function returnMax(t)
	local k
	for i, v in pairs(t) do
	k = k or v
	if v > k then k = v end
	end
	return k
end

local function cellIsClear( sim, cell )
	if not cell then
		return false
	end
	if cell.impass ~= 0 then
		return false
	end
	if cell.units and (#cell.units > 0) then
		return false
	end
	if simquery.cellHasTag(sim, cell, "guard_spawn") then
		return false
	end

	return true
end

local function roomCenterCell( sim, unit )
	local spawn_cell = sim:getCell(unit:getLocation())
	local room_cells = {}
	local x_coords = {}
	local y_coords = {}
	-- find cells in the same "room"
	sim:forEachCell(function(cell)
		if cell.procgenRoom and spawn_cell.procgenRoom and (cell.procgenRoom == spawn_cell.procgenRoom) then
			table.insert(room_cells, cell)
			table.insert(x_coords, cell.x)
			table.insert(y_coords, cell.y)
		end
	end)

	local x_min = returnMin(x_coords)
	local x_max = returnMax(x_coords)
	local y_min = returnMin(y_coords)
	local y_max = returnMax(y_coords)

	local x_mid = math.ceil( (x_min+x_max)/2 )
	local y_mid = math.ceil( (y_min+y_max)/2 )

	local mid_cell = sim:getCell(x_mid, y_mid)
	if cellIsClear( sim, mid_cell ) then
		return mid_cell
	elseif mid_cell then --middle cell is not clear, check neighbours
		for i = 1, #simdefs.OFFSET_NEIGHBOURS, 2 do
			local dx, dy = simdefs.OFFSET_NEIGHBOURS[i], simdefs.OFFSET_NEIGHBOURS[i+1]
			local targetCell = sim:getCell( mid_cell.x + dx, mid_cell.y + dy )
			if simquery.isConnected( sim, mid_cell, targetCell ) then
				if cellIsClear( sim, targetCell ) then
					return targetCell
				end
			end
		end
	end

	return nil -- give up and go with original spawn
end

local function spawnInRoomCenter( sim, unit )
	local central_cell = roomCenterCell( sim, unit )
	if central_cell then
		sim:warpUnit( unit, central_cell )
	end
end

local MM_surveyor =
{
	name = "SURVEYOR",
	getName = function( self, sim, unit )
		return self.name
	end,

	onSpawnAbility = function( self, sim, unit )
		self.seerUnits = {}
		self.abilityOwner = unit
		sim:addTrigger( simdefs.TRG_UNIT_WARP, self )
		sim:addTrigger( simdefs.TRG_START_TURN, self )
		sim:addTrigger( simdefs.TRG_END_TURN, self )
	end,

	onDespawnAbility = function( self, sim, unit )
		sim:removeTrigger( simdefs.TRG_START_TURN, self )
		sim:removeTrigger( simdefs.TRG_UNIT_WARP, self )
		sim:removeTrigger( simdefs.TRG_END_TURN, self )
		self.abilityOwner = nil
	end,

	onTrigger = function( self, sim, evType, evData )
		if evType == simdefs.TRG_START_TURN then
			if sim:getTurnCount() < 1 then
				spawnInRoomCenter( sim, self.abilityOwner )
				self.abilityOwner:getTraits().patrolPath = nil -- normally you'd set a guard to stationary by making sure its patrol point is its location, but that doesn't really play ball with the scan at start of turn. Plus, this makes it possible to distract the drone to a new stationary point and that's kinda interesting?
			end
			if evData:isNPC() then
				local droneUnit = self.abilityOwner
				if not droneUnit:isAlerted() and droneUnit:getBrain() and (droneUnit:getBrain():getSituation().ClassType == simdefs.SITUATION_IDLE) and droneUnit:getTraits().idle_scanning then
					local x0, y0 = droneUnit:getLocation()
					droneUnit:getBrain():getSenses():addInterest( x0, y0, simdefs.SENSE_PERIPHERAL, simdefs.REASON_SENSEDTARGET, droneUnit)
					droneUnit:getTraits().shouldRotate = true
				end
			end
		elseif evType == simdefs.TRG_END_TURN then
			if evData:isNPC() then
				local droneUnit = self.abilityOwner
				if droneUnit:getTraits().stationaryRotating and droneUnit:getBrain() and droneUnit:getTraits().shouldRotate and not droneUnit:isAlerted() then
					droneUnit:updateFacing((droneUnit:getFacing() + 2) % simdefs.DIR_MAX)
					sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = droneUnit } )
					sim:dispatchEvent( simdefs.EV_UNIT_UPDATE_INTEREST, { unit = droneUnit } )
					droneUnit:getTraits().shouldRotate = nil
				end
			end

		end
	end,
}

return MM_surveyor
