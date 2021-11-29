local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
-- local itemdefs = include ("sim/unitdefs/itemdefs")
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local unitdefs = include( "sim/unitdefs" )
local simfactory = include( "sim/simfactory" )
local mission_util = include("sim/missions/mission_util")

--local helpers
local 	PC_WON =
{		
	priority = 10,

	trigger = simdefs.TRG_GAME_OVER,
	fn = function( sim, evData )
		if sim:getWinner() then
			return sim:getPlayers()[sim:getWinner()]:isPC()
		else
			return false
		end
	end,
}

local MOLE_SPAWNED =
{
	trigger = "MM_spawned_mole",
	fn = function( sim, evData )
		return true
	end
}
	

local REFIT_DRONE_ESCAPED =
{
	trigger = simdefs.TRG_UNIT_ESCAPED,
	fn = function( sim, triggerUnit )
		if triggerUnit:getTraits().refitDroneFriend then
			return triggerUnit
		end
	end
}

local DRONE_MOVED =
{
	trigger = simdefs.TRG_UNIT_WARP,
	fn = function( sim, evData )
		if evData.unit:getTraits().refitDroneFriend then
			return evData.unit
		end
	end
}

local function hideDrone( script, sim )
	local _, drone = script:waitFor( DRONE_MOVED )
	drone:getTraits().hidesInCover = true
end

local function spawnDroney( sim, cell, name )
	local template = "MM_refit_drone_friend"
	local unitData = unitdefs.lookupTemplate( template )
	local newUnit = simfactory.createUnit( unitData, sim )
	local player = sim:getPC()
	newUnit:setPlayerOwner(player)
	newUnit:getTraits().customName = name
	sim:spawnUnit( newUnit )
	newUnit:getTraits().hidesInCover = false --this prevents the drone anim from being invisible when spawning into cover
	sim:warpUnit( newUnit, cell )
	sim:dispatchEvent( simdefs.EV_TELEPORT, { units={newUnit}, warpOut =false } )
	sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = newUnit } )
	-- newUnit:getTraits().hidesInCover = true
	return newUnit
end

local function droneFriendSurvived( script, sim )
	script:waitFor( REFIT_DRONE_ESCAPED )
	sim:getTags().MM_refitDroneFriendEscaped = true
end

local function spawnDroneFriend( script, sim )
	if sim:getParams().situationName == "mole_insertion" then
		script:waitFor( MOLE_SPAWNED )
	end
	
	--spawn new drone
	if sim:getParams().agency.MM_rescuedRefitDrone then
		local droneFriend = sim:getParams().agency.MM_rescuedRefitDrone[1]
		if droneFriend == nil then return end
		local name = droneFriend.name
		local agent = nil
		local cell = nil
		for i, unit in pairs(sim:getPC():getUnits()) do
			if unit:getUnitData().agentID and unit:getLocation() then
				agent = unit
				cell = sim:getCell(unit:getLocation())
				break
			end
		end
		if agent and cell then
			local droney = spawnDroney(sim, cell, name)
			script:addHook( hideDrone )
		end
	end
	
	-- remove old drone
	local agency = sim:getParams().agency
	script:waitFor ( PC_WON )
	if sim:getTags().MM_refitDroneFriendEscaped then
		agency.MM_droneFriendSurvived = true --can be used by Additional Banter
	end
	if agency.MM_rescuedRefitDrone then
		for i = #agency.MM_rescuedRefitDrone, 1, -1 do
			local droneFriend = agency.MM_rescuedRefitDrone[i]
			local gotDroneWhen = droneFriend.campaignHours
			if sim:getParams().campaignHours > gotDroneWhen then
				table.remove(agency.MM_rescuedRefitDrone,i)
			end
		end
	end
end

local function spawnDroneFn( script, sim )
	script:addHook( spawnDroneFriend )
	script:addHook( droneFriendSurvived )
end

return spawnDroneFn
