--------------------------------------------------------------------------------
-- Mole Insertion
--
-- Escort a mole to the console.
-- Until the mole has assumed his identity, don't let him be seen.
-- Guard and drone witnesses need their HUD wiped manually or killed.
-- Camera witnesses need to be wiped at the Camera Database.
--------------------------------------------------------------------------------

local mission_util = include( "sim/missions/mission_util" )
local escape_mission = include( "sim/missions/escape_mission" )

--------------------------------------------------------------------------------
-- Local helpers

local GUARD_SAW_MOLE =
{
	trigger = simdefs.TRG_UNIT_APPEARED,
	fn = function( sim, evData )
		local seer = sim:getUnit( evData.seerID )
		--NPC-controlled. Don't penalize the player for moving hacked enemies.
		if not seer or not seer:isNPC() then
			return false
		end
		local isGuardDrone = seer:getTraits().isGuard or seer:getTraits().isDrone
		local isAlreadyWitness = seer:getTraits().witness
		if not isGuardDrone or isAlreadyWitness then
			return false
		end

		if evData.unit:hasTag("mole") then
			return evData.unit, seer
		else
			return false
		end
	end,
}
local WITNESS_DEAD =
{
	trigger = simdefs.TRG_UNIT_KILLED,
	fn = function( sim, triggerData )
		if triggerData.unit:getTraits().witness then
			return triggerData.unit
		end
	end,
}
local WITNESS_KOED =
{
	trigger = simdefs.TRG_UNIT_KO,
	fn = function( sim, triggerData )
		if triggerData.unit:getTraits().witness then
			return triggerData.unit
		end
	end,
}
local WITNESS_ESCAPED =
{
	-- TODO: Compile side-mission scientist, AGP sysadmin
}

local CAMERA_SAW_MOLE =
{
	trigger = simdefs.TRG_UNIT_APPEARED,
	fn = function( sim, evData )
		local seer = sim:getUnit( evData.seerID )
		--Depending on mods, enemy cameras are either neutral or enemy owned
		if not seer or seer:isPC() then
			return false
		end
		if not seer:getTraits().mainframe_camera then
			return false
		end

		if evData.unit:hasTag("mole") then
			return evData.unit, seer
		else
			return false
		end
	end,
}

local function existsLivingWitness(sim)
	--Guard or drone that has directly seen an agent.
	for unitID, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().witness and not unit:isDead() then
			return true
		end
	end
	return false
end

local function guardWitnessesAgent(script, sim)
	while true do
		_, agent, seer = script:waitFor( GUARD_SAW_MOLE )
		seer:getTraits().witness = true
		--TODO: Tabs get cleared too often on guards.
		seer:createTab( STRINGS.MOREMISSIONS.MISSIONS.MOLE.WITNESS_DETECTED, "" )

		if not sim:hasObjective( "kill_witness" ) then
			sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.MOLE.OBJ_KILL_WITNESS, "kill_witness" )
		end
	end
end

local function witnessDied(script, sim)
	while true do
		_, witness = script:waitFor( WITNESS_DEAD )

		if not existsLivingWitness(sim) then
			sim:removeObjective( "kill_witness" )
		end
	end
end

--------------------------------------------------------------------------------
-- Mission definition

local mission = class( escape_mission )

function mission:init( scriptMgr, sim )
	escape_mission.init( self, scriptMgr, sim )

	--Eyewitnesses that directly see agents
	scriptMgr:addHook( "new_witness", guardWitnessesAgent)
	scriptMgr:addHook( "dead_witness", witnessDied)
end

function mission.pregeneratePrefabs( cxt, tagSet )
    escape_mission.pregeneratePrefabs( cxt, tagSet )

	-- Place primary node room normally. Will be placed with most other rooms in a random order.
    table.insert( tagSet[1], "moleinsertion_a" )
	-- Place secondary node after other rooms. Tends to be singly-attached and on the edge of the level.
    table.insert( tagSet, { "moleinsertion_b" } )
end

return mission
