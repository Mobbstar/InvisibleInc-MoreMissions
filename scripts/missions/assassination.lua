local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local unitdefs = include( "sim/unitdefs" )
local simfactory = include( "sim/simfactory" )
local mission_util = include( "sim/missions/mission_util" )
local escape_mission = include( "sim/missions/escape_mission" )
local SCRIPTS = include("client/story_scripts")

---------------------------------------------------------------------------------------------
-- Local helpers


local BOUNTY_TARGET_DEAD =
{
	trigger = simdefs.TRG_UNIT_KILLED,
	fn = function( sim, triggerData )
		if triggerData.unit:hasTag("assassination") then
			triggerData.corpse:addTag("assassination") --track the body; no rest for the dead -M
			return true
		end
	end,
}
local BOUNTY_TARGET_KO =
{
	trigger = simdefs.TRG_UNIT_KO,
	fn = function( sim, triggerData )
		if triggerData.unit:hasTag("assassination") then
			return true
		end
	end,
}
local CEO_ALERTED =
{
	trigger = simdefs.TRG_UNIT_ALERTED,
	fn = function( sim, evData )
		if evData.unit:hasTag("assassination")  then
			return evData.unit
		end
	end,
}
local CEO_ESCAPED =
{
	trigger = "vip_escaped",
	fn = function( sim, evData )
		if evData.unit:hasTag("assassination") then
			return true
		end
	end,
}
local ESCAPE_WITH_BODY =
{
	trigger = simdefs.TRG_UNIT_ESCAPED,
	fn = function( sim, triggerData )
		for unitID, unit in pairs(sim:getAllUnits()) do
			if unit:hasTag("assassination") then
				local cell = sim:getCell( unit:getLocation() )
				if cell and cell.exitID == simdefs.DEFAULT_EXITID then
					return unit
				end
			end
		end
	end,
}


--keep track of when the loot gets actually extracted
local function gotloot(script, sim, mission)
	_, body = script:waitFor( ESCAPE_WITH_BODY )
	assert(body:hasTag("assassination"))

	if body:isDead() then
		mission.gotbody = true
	else
		mission.gotalive = true
	end
	sim:removeObjective( "drag" )
end

local function presawfn( script, sim, ceo )
	if not ceo:isDown() then
		--create that big white arrow pointing to the target
		ceo:createTab( STRINGS.MISSIONS.UTIL.HEAT_SIGNATURE_DETECTED, "" )
	end
	sim:removeObjective( "find" )
end

local function pstsawfn( script, sim, ceo )
	if ceo:isDown() then --somehow, the target got knocked out before we found it
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.OBJ_DRAG, "drag" )
	else
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.OBJ_KILL, "kill" )
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.OBJ_DRAG, "drag" )
		script:waitFor( BOUNTY_TARGET_DEAD, BOUNTY_TARGET_KO )
	end

	--The corpse is a separate unit, update the reference.
	for unitID, unit in pairs(sim:getAllUnits()) do
		if unit:hasTag("assassination") then
			ceo = unit
			break
		end
	end

	sim:removeObjective( "kill" )
	ceo:destroyTab() --Remove the big white arrow (if it is still there)

	sim:setClimax(true)
	script:waitFrames( .5*cdefs.SECONDS )

	--aftermath
	--TODO summon rival assassin instead? more like carrion eater hah!- M
	local x0,y0 = ceo:getLocation()
	--note that "REASON_FOUNDCORPSE" raises the alarm and alerts the guard
	sim:getNPC():spawnInterest(x0,y0, simdefs.SENSE_RADIO, simdefs.REASON_FOUNDCORPSE, ceo)

	--Why yes thank you Central, nearly did not notice something bad happened! -M
	script:waitFrames( 1.5*cdefs.SECONDS )
	script:queue( { script=SCRIPTS.INGAME.ASSASSINATION.AFTERMATH[sim:nextRand(1, #SCRIPTS.INGAME.ASSASSINATION.AFTERMATH)], type="newOperatorMessage" } )

end

local function ceoalerted(script, sim)
	local _, ceo = script:waitFor( CEO_ALERTED )
	if not ceo:isDown() then
	    script:queue( { script=SCRIPTS.INGAME.CENTRAL_CFO_RUNNING, type="newOperatorMessage" } )
		sim:getPC():glimpseUnit(sim, ceo:getID() )
	else
		script:addHook( script.hookFn )
	end
end
local function ceoescaped(script, sim, mission)
	script:waitFor( CEO_ESCAPED )
    if not mission.failed then
	   script:queue( { script=SCRIPTS.INGAME.CENTRAL_CFO_ESCAPED, type="newOperatorMessage" } )
	   mission.failed = true
       sim.exit_warning = nil
    end
end

local function exitWarning(sim)
	for unitID, unit in pairs(sim:getAllUnits()) do
		if unit:hasTag("assassination") then
			local cell = sim:getCell( unit:getLocation() )
			--check if the target is still there, but not in the exit zone yet
			if cell and cell.exitID ~= simdefs.DEFAULT_EXITID then
				return STRINGS.MOREMISSIONS.UI.HUD_WARN_EXIT_MISSION_ASSASSINATION
			end
		end
	end
end

local function judgement(sim, mission)
	local scripts =
		mission.gotalive and SCRIPTS.INGAME.ASSASSINATION.CENTRAL_JUDGEMENT.NOTDEAD or
		mission.gotbody and SCRIPTS.INGAME.ASSASSINATION.CENTRAL_JUDGEMENT.GOTBODY or
		SCRIPTS.INGAME.ASSASSINATION.CENTRAL_JUDGEMENT.NOTHING
	return scripts[sim:nextRand(1, #scripts)]
end

---------------------------------------------------------------------------------------------
-- Begin!

local mission = class( escape_mission )

function mission:init( scriptMgr, sim )
	escape_mission.init( self, scriptMgr, sim )

	sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.OBJ_FIND, "find" )

	sim.exit_warning = function() return exitWarning(sim) end

	scriptMgr:addHook( "SEE", mission_util.DoReportObject(mission_util.PC_SAW_UNIT("assassination"), SCRIPTS.INGAME.ASSASSINATION.OBJECTIVE_SIGHTED, presawfn, pstsawfn ) )

	scriptMgr:addHook( "GOTLOOT", gotloot, nil, self)

	--In case the target gets away, ripped straight from the CFO interrogation mission
    scriptMgr:addHook( "RUN", ceoalerted, nil, self)
    scriptMgr:addHook( "escaped", ceoescaped, nil, self)

	--This picks a reaction rant from Central on exit based upon whether or not an agent has escaped with the loot yet.
	scriptMgr:addHook( "FINAL", mission_util.CreateCentralReaction(function() judgement(sim, self) end))
end


function mission.pregeneratePrefabs( cxt, tagSet )
	escape_mission.pregeneratePrefabs( cxt, tagSet )
	table.insert( tagSet[1], "assassination" )


	-- local prefabs = include( "sim/prefabs" )

	-- table.insert( tagSet, { "entry_hotel_ground", makeTags( "struct", cxt.params.difficultyOptions.roomCount ) })
	-- -- table.insert( tagSet, { "entry", makeTags( "struct", cxt.params.difficultyOptions.roomCount ) })
	-- tagSet[1].fitnessSelect = prefabs.SELECT_HIGHEST

	-- --table.insert( tagSet, { "research_lab" })

	-- table.insert( tagSet, { "struct_small", "struct_small" })
	-- table.insert( tagSet, { { "exit", exitFitnessFn } })
end

-- function mission.generatePrefabs( cxt, candidates )
	-- local prefabs = include( "sim/prefabs" )
	-- prefabs.generatePrefabs( cxt, candidates, "switch", 2 )
-- end


return mission
