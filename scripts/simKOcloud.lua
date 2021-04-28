----------------------------------------------------------------
-- Copyright (c) 2012 Klei Entertainment Inc.
-- All Rights Reserved.
-- SPY SOCIETY.
----------------------------------------------------------------

local util = include( "modules/util" )
local array = include( "modules/array" )
local simunit = include( "sim/simunit" )
local prop_templates = include( "sim/unitdefs/propdefs" )
local simquery = include( "sim/simquery" )
local simdefs = include( "sim/simdefs" )
local simfactory = include( "sim/simfactory" )
local cdefs = include( "client_defs" )
local propdefs = include("sim/unitdefs/propdefs")

-----------------------------------------------------
-- Local functions

local simKOcloud = { ClassType = "simKOcloud" } --based on Neptune frost cloud

local function occludeSight( sim, targetCell, smokeRadius, self )
	local cells = simquery.floodFill( sim, nil, targetCell, smokeRadius, simquery.getManhattanMoveCost, simquery.canPathBetween )
	for i, cell in pairs(cells) do
		cell.KOgas = (cell.KOgas or 0) + 1
	end
	return cells
end

local function KOagents( sim, cells )
	local agents = {}
	for i, frostcell in pairs(cells) do
		if frostcell.units then
			for k, unit in pairs(frostcell.units) do
				if (unit:getPlayerOwner() == sim:getPC()) and not unit:getTraits().isDrone then
					log:write("LOG inserting agent")
					table.insert( agents, unit )
				end
			end
		end
	end
	return agents
end
-----------------------------------------------------
-- Interface functions

function simKOcloud:onWarp(sim, oldcell, cell)
	if oldcell then
		for i, cell in pairs(self._cells) do
			cell.KOgas = cell.KOgas - 1
		end
		self._cells = nil
	end
	local agents = {}
    if cell then
        self._cells = occludeSight( sim, cell, self:getTraits().radius, self )
		agents = KOagents( sim, self._cells )
    end
    sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self } ) 
	if (#agents > 0) and self:getTraits().KOgas then
		sim:getLevelScript():queue( 2 * cdefs.SECONDS )
		-- sim:dispatchEvent( simdefs.EV_KO_GROUP, true )
		for i, agent in pairs(agents) do
			agent:setKO( sim, 3 ) --will immediately tick down to 2
		end
		-- sim:dispatchEvent( simdefs.EV_KO_GROUP, false )
	end
end

function simKOcloud:onEndTurn( sim )
    -- There is no simunit base behaviour we desire at this time.
    self:getTraits().lifetime = self:getTraits().lifetime - 1
    if self:getTraits().lifetime <= 0 then
		local cell = sim:getCell(self:getLocation())
        sim:warpUnit( self, nil )
        sim:despawnUnit( self )
		if self:getTraits().spawnKOgas then --harmless cloud spawns KO cloud 
			local KOcloud = simfactory.createUnit( propdefs.MM_gas_cloud, sim )
			sim:spawnUnit( KOcloud )
			sim:warpUnit( KOcloud, cell )
		elseif not self:getTraits().KOgasdispersal then --which spawns harmless cloud
			local KOcloud = simfactory.createUnit( propdefs.MM_gas_cloud_dispersal, sim )
			sim:spawnUnit( KOcloud )
			sim:warpUnit( KOcloud, cell )
		end
    end
	if sim:getCurrentPlayer() == sim:getNPC() then
		if self and sim:getCell(self:getLocation()) then
			self._cells = occludeSight( sim, sim:getCell(self:getLocation()), self:getTraits().radius, self )
			local agents = KOagents( sim, self._cells )
			if (#agents > 0) and self:getTraits().KOgas then
				sim:getLevelScript():queue( 1 * cdefs.SECONDS )
				sim:dispatchEvent( simdefs.EV_KO_GROUP, true )
				for i, agent in pairs(agents) do
					agent:setKO( sim, 3 )
					if agent:getTraits().koTimer and (agent:getTraits().koTimer < 2) and not agent:getTraits().isDrone then
						agent:getTraits().koTimer = 2
					end					
				end
				sim:dispatchEvent( simdefs.EV_KO_GROUP, false )
			end
		end
	end
end

function simKOcloud:getSmokeCells()
    return self._cells
end

function simKOcloud:getSmokeEdge()
    return {}
end
-----------------------------------------------------
-- Interface functions

local function createSmokePlume( unitData, sim )
	return simunit.createUnit( unitData, sim, simKOcloud )
end

simfactory.register( createSmokePlume )

return simKOcloud
