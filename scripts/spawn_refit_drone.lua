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
	
local function spawnDroney( sim, cell, name )
	local template = "MM_refit_drone_friend"
	local unitData = unitdefs.lookupTemplate( template )
	local newUnit = simfactory.createUnit( unitData, sim )
	local player = sim:getPC()
	newUnit:setPlayerOwner(player)
	newUnit:getTraits().customName = name
	-- newUnit:giveAbility("MM_renameDrone")
	sim:spawnUnit( newUnit )
	sim:warpUnit( newUnit, cell )
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
			spawnDroney(sim, cell, name)
		end
	end
	
	-- remove old drone
	local agency = sim:getParams().agency
	script:waitFor ( PC_WON )
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
	script:addHook(spawnDroneFriend) 
end

return spawnDroneFn