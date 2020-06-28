--------------------------------------------------------------------------------
-- Mole Insertion
--
-- Escort a mole to the console.
-- Until the mole has assumed his identity, don't let him be seen.
--------------------------------------------------------------------------------

local mission_util = include( "sim/missions/mission_util" )
local escape_mission = include( "sim/missions/escape_mission" )

--------------------------------------------------------------------------------
-- Local helpers

local GUARD_SAW_AGENT =
{
	trigger = simdefs.TRG_UNIT_APPEARED,
	fn = function( sim, evData )
		local seer = sim:getUnit( evData.seerID )
		--NPC-controlled.
		if not seer or not seer:isNPC() then
			return false
		end
		local isGuardDrone = seer:getTraits().isGuard or seer:getTraits().isDrone
		local isAlreadyWitness = seer:getTraits().witness
		-- The target will either die or things fail anyways. Don't track as a witness.
		local isBountyTarget = seer:hasTag("bounty_target")
		if not isGuardDrone or isAlreadyWitness or isBountyTarget then
			return false
		end

		--Agency agents prove Invisible Inc was involved in the assassination.
		local unitIsPlayerAgent = evData.unit:isPC() and sim:getQuery().isAgent(evData.unit)
		--Controlled drones and guards are fine.
		local unitIsGuard = evData.unit:getTraits().isGuard
		--Disguised agents are fine.
		local unitIsDisguised = evData.unit:getTraits().disguiseOn
		--TODO: LEVER_status (TRUSTED/LEGIT/HARMLESS)
		if unitIsPlayerAgent and not unitIsGuard and not unitIsDisguised then
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
	-- TODO
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
		_, agent, seer = script:waitFor( GUARD_SAW_AGENT )
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

return mission
