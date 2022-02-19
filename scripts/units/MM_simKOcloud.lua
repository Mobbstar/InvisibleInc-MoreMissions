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

local simKOcloud = { ClassType = "MM_simKOcloud" } --based on Neptune frost cloud

local function clearVizSmoke( self )
	for i, cell in pairs(self._vizcells or {}) do
		if (cell.KOgas or 0) < 1 then -- only if there is truly no smoke left
			cell.vizKOgas = nil
			array.removeElement( self._vizcells, cell )
		end
	end
end

local function clearSmoke( self )
	for i, cell in pairs(self._cells or {}) do
		cell.KOgas = (cell.KOgas or 1) - 1
	end
	self._cells = {}
end

local function addVizSmokeToCell( self, cell )
	cell.vizKOgas = self
	if not array.find( self._vizcells, cell ) then
		table.insert( self._vizcells, cell )
	end
end

local function updateSmoke( sim, targetCell, smokeRadius, self )
	self._cells = self._cells or {}
	self._vizcells = self._vizcells or {}

	-- expand where possible
	local cells = simquery.floodFill( sim, nil, targetCell, smokeRadius, simquery.getManhattanMoveCost, simquery.canPathBetween )
	for i, cell in pairs(cells) do
		if not array.find( self._cells, cell ) then
			cell.KOgas = (cell.KOgas or 0) + 1
			table.insert( self._cells, cell )
		end
	end

	clearVizSmoke(self)

	-- add visuals
	-- local selfColor = self:getTraits().gasColor
	for i, cell in pairs(self._cells) do
		-- if there already is smoke, display the stronger one
		--TODO this doesn't quite work
		if cell.vizKOgas and cell.vizKOgas:isValid() then
			-- local otherColor = cell.vizKOgas:getTraits().gasColor
			-- if otherColor ~= nil and otherColor.a < selfColor.a then
				-- array.removeElement( cell.KOgas:getSmokeCells(), cell )
				-- addVizSmokeToCell(self, cell)
			-- end
			if cell.vizKOgas:getTraits().lifetime < self:getTraits().lifetime then
				addVizSmokeToCell(self, cell)
			end
			-- the other smoke is stronger, so don't take over
		else
			addVizSmokeToCell(self, cell)
		end
	end
end

local function findAgents( sim, cells )
	local agents = {}
	for i, cell in pairs(cells) do
		if cell.units then
			for k, unit in pairs(cell.units) do
				if (unit:getPlayerOwner() == sim:getPC()) and not unit:getTraits().isDrone then
					table.insert( agents, unit )
				end
			end
		end
	end
	return agents
end

local function koAgents( sim, agents )
	for i, agent in pairs(agents) do
		if agent:getTraits().canKO then
			agent:setKO( sim, 3 ) --will immediately tick down to 2
			if agent:getTraits().koTimer and (agent:getTraits().koTimer < 2) and not agent:getTraits().isDrone then
				agent:getTraits().koTimer = 2
			end
		end
	end
end

local function updateStage( self )
	local stages = self:getTraits().stages
	local lifetime = self:getTraits().lifetime
	local stage = self:getTraits().stage
	local new_data = {}
	local best = 0

	for lt, data in pairs( stages ) do
		if lt < lifetime and (not stage or lt > best) then
			best = lt
			new_data = data
		end
	end

	for k, v in pairs(new_data) do
		self:getTraits()[k] = v
	end

	self:getTraits().stage = best
end

-----------------------------------------------------
-- Interface functions

function simKOcloud:onSpawn( sim )
	-- init params
	updateStage(self)
end

function simKOcloud:onWarp(sim, oldcell, cell)
	-- clear old smoke
	clearSmoke(self)
	clearVizSmoke(self)

	-- place new smoke
	local agents = {}
    if cell then
        updateSmoke( sim, cell, self:getTraits().radius, self )
		agents = findAgents( sim, self._cells )
    end

    sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self } )
	
	-- do the KO stuff
	if (#agents > 0) and self:getTraits().KOgas then
		sim:getLevelScript():queue( 2 * cdefs.SECONDS )
		-- sim:dispatchEvent( simdefs.EV_KO_GROUP, true )
		koAgents(sim, agents)
		-- sim:dispatchEvent( simdefs.EV_KO_GROUP, false )
	end
end

function simKOcloud:onEndTurn( sim )
    -- There is no simunit base behaviour we desire at this time.

	-- handle buildup/dissipation
    self:getTraits().lifetime = self:getTraits().lifetime - 1
	if self:getTraits().lifetime <= 0 then
        sim:warpUnit( self, nil )
        sim:despawnUnit( self )
		return
    end
    updateStage( self )

	if sim:getCurrentPlayer() == sim:getNPC() and self:isValid() then
		-- adjust to doors
		updateSmoke( sim, sim:getCell(self:getLocation()), self:getTraits().radius, self )
		-- do the KO stuff
		local agents = findAgents( sim, self._cells )
		if (#agents > 0) and self:getTraits().KOgas then
			sim:getLevelScript():queue( 1 * cdefs.SECONDS )
			sim:dispatchEvent( simdefs.EV_KO_GROUP, true )
			koAgents(sim, agents)
			sim:dispatchEvent( simdefs.EV_KO_GROUP, false )
		end
	end
end

function simKOcloud:getSmokeCells()
    return self._vizcells
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
