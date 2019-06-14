local array = include( "modules/array" )
local util = include( "modules/util" )
local mathutil = include( "modules/mathutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local mission_util = include( "sim/missions/mission_util" )
local win_conditions = include( "sim/win_conditions" )
local strings = include( "strings" )
local astar = include( "modules/astar" )
local astar_handlers = include("sim/astar_handlers")
local escape_mission = include( "sim/missions/escape_mission" )

---------------------------------------------------------------------------------------------
-- Local helpers

local MISSION_REWARD = 1200 -- raised from vanilla 800
local VITAL_SIGN_START = 10

local HOSTAGE_RESCUE =
{
	trigger = "hostage_rescued", 
}

local HOSTAGE_DEAD =
{
	trigger = "hostage_dead",
}

local HOSTAGE_KO =
{
	trigger = simdefs.TRG_UNIT_KO,
	fn = function( sim, evData )
		return evData.unit:getTraits().hostage
	end,	
}

local HOSTAGE_ESCAPED = 
{
	trigger = "hostage_escaped",
}

local PC_HOSTAGE_MOVED =
{
	action = "moveAction",
	fn = function( sim, unitID, moveTable )
		return unitID and sim:getUnit( unitID ):isPC() and sim:getUnit( unitID ):getTraits().hostage 
	end,
}

local PC_HOSTAGE_STARTED_MOVE =
{
	pre=true,
	action = "moveAction",
	fn = function( sim, unitID, moveTable )
		return unitID and sim:getUnit( unitID ):isPC() and sim:getUnit( unitID ):getTraits().hostage 
	end,
}


local function checkNoHostageGameOver( script, sim )
	script:waitFor( mission_util.PC_WON )

	script:removeAllHooks( script )
	sim:getTags().delayPostGame = true

	script:clearQueue()
	script:queue( { type="clearEnemyMessage" } )
	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.CENTRAL_COMPLETE_MISSION_NO_COURIER, type="operatorMessage", profileAnim="portraits/central_face", profileBuild="portraits/central_face" } )
	script:waitFrames( 240 )
	script:queue( { type="clearOperatorMessage" } )

	sim:getTags().delayPostGame = false
end

local function checkHostageDeath( script, sim )

	while true do
		script:waitFor( HOSTAGE_DEAD, HOSTAGE_KO )
        print( "HOSTAGE DEATH!" )
		local hostage = nil
		sim:forEachUnit(
			function(unit)
				if unit:getTraits().hostage then 
					hostage = unit
				end
			end
		)

		--local hostage = getHostage(sim)
		local x, y = hostage:getLocation()
		local subtext = STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_VITALS_SUBTEXT_DEATH
		script:queue( { soundPath="SpySociety/Actions/guard/guard_heart_flatline", type="operatorVO" } )
		script:queue( { 
			type="displayHUDInstruction", 
			text=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_VITALS, 
			subtext=subtext,
			x=x, y=y } )

		--hostage:killUnit( sim )]]

		script:waitFrames( 2*cdefs.SECONDS )
		script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.CENTRAL_HOSTAGE_DEATH, type="operatorMessage", profileAnim="portraits/central_face", profileBuild="portraits/central_face" } )
		sim:setMissionReward( 0 )

		script:waitFor( mission_util.PC_ANY )	
		script:queue( { type="clearOperatorMessage" } )

		script:addHook( checkNoHostageGameOver )
	end

end

local function updateVitalStatus( script, sim, playSound )
	sim:forEachUnit(
		function(unit)
			if unit:getTraits().hostage then 
				local x, y = unit:getLocation()
				local subtext = ""
				if unit:getTraits().vitalSigns > 0 then
					if playSound then 
						script:queue( { soundPath="SpySociety/Actions/guard/guard_heart_stage3", type="operatorVO" } )
					end
					subtext = string.format( STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_VITALS_SUBTEXT, unit:getTraits().vitalSigns )
				else
					if playSound then 
						script:queue( { soundPath="SpySociety/Actions/guard/guard_heart_flatline", type="operatorVO" } )
					end
					subtext = STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_VITALS_SUBTEXT_DEATH
				end
				script:queue( { 
					type="displayHUDInstruction", 
					text=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_VITALS, 
					subtext=subtext,
					x=x, y=y } )
			end
		end)
end

local function hostageBanter( script, sim )

	local i = 0
	local gameOver = false
	while true do
		script:waitFor( mission_util.PC_START_TURN )

		local hostage = nil
		sim:forEachUnit(
			function(unit)
				if unit:getTraits().hostage then 
					hostage = unit
				end
			end
		)

		if hostage and not hostage:isKO() and not hostage:isDead() then
			hostage:getTraits().vitalSigns = hostage:getTraits().vitalSigns - 1
			if hostage:getTraits().vitalSigns <= 0 then

				script:removeHook( checkHostageDeath )
				script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_PASS_OUT, header=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_NAME, type="enemyMessage" } )
				script:waitFrames( 2*cdefs.SECONDS )

				script:queue( { soundPath="SpySociety/Agents/Agent_1/Regular/die", type="operatorVO" } )
				sim:damageUnit( hostage, hostage:getTraits().woundsMax )
				updateVitalStatus(script, sim, true)

				script:waitFrames( 1*cdefs.SECONDS )
				script:queue( { type="clearEnemyMessage" } )

				script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.CENTRAL_PASS_OUT, type="operatorMessage", profileAnim="portraits/central_face", profileBuild="portraits/central_face" } )
				script:queue( 3*cdefs.SECONDS )
				script:queue( { type="clearOperatorMessage" } )

				hostage:killUnit( sim )

				gameOver = true

				--add the no hostage gameover check
				script:addHook( checkNoHostageGameOver )
			end

			if not gameOver then
				updateVitalStatus(script, sim, true)

				script:queue( 1*cdefs.SECONDS )
				i = i + 1
				if i < #STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_BANTER then
					script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_BANTER[i], header=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_NAME, type="enemyMessage" } )
					script:queue( 4*cdefs.SECONDS )		
					script:queue( { type="clearEnemyMessage" } )
				end
				script:queue( { type="clearEnemyMessage" } )
			end
		end
	end

end

local function clearHostageStatusAfterMove( script, sim )

	while true do
		script:waitFor( PC_HOSTAGE_STARTED_MOVE )
		script:queue( { type="hideHUDInstruction" } )
	end
end

local function clearStatusAfterEndTurn( script, sim )

	while true do
		--updateVitalStatus(script, sim)
		script:waitFor( mission_util.PC_END_TURN )
		script:queue( { type="hideHUDInstruction" } )
		--script:queue( 1*cdefs.SECONDS )
	end

end

local function getExit(sim)

	local exitcell = nil
	sim:forEachCell(
		function( c )
			for i, exit in pairs( c.exits ) do
				local cell = exit.cell
				if cell and ((cell.exitID ~= nil and cell.exitID ~= simdefs.EXITID_VENT) or cell.ventID ~= nil) then
					exitcell = cell
				end
			end
		end )

	return exitcell
end

local function calculateHostageVitalSigns( sim )

	local hostage = nil
	sim:forEachUnit(
		function(unit)
			if unit:getTraits().hostage then 
				hostage = unit
			end
		end)

	assert(hostage)
	local startcell = sim:getCell( hostage:getLocation() )

	assert(startcell)
	local endcell = getExit(sim)

	assert(endcell)

	local pather = astar.AStar:new( astar_handlers.handler:new( sim, nil, nil, nil, true ) )
	local path = pather:findPath( startcell, endcell )

	assert(path)

	local distToExit = path:getTotalMoveCost()

	local maxTurns = math.floor(distToExit*2 / hostage:getMPMax())
	local minTurns = math.floor(distToExit*1.5 / hostage:getMPMax())

	hostage:getTraits().vitalSigns = sim:nextRand(minTurns, maxTurns)
end

local function startPhase( script, sim )

	script:waitFor( mission_util.UI_INITIALIZED )

	mission_util.makeAgentConnection( script, sim )

	sim:setMissionReward( MISSION_REWARD )

	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.OPERATOR_OPEN, type="operatorMessage", profileAnim="portraits/central_face", profileBuild="portraits/central_face" } )
	script:waitFrames( 0.5*cdefs.SECONDS )

	script:waitFor( mission_util.PC_ANY )	
	script:queue( { type="clearOperatorMessage" } )

	sim:addObjective( STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.OBJECTIVE_FIND_HOSTAGE, "hostage_1" )

	sim:getTags().no_escape = true

	--See the hostage
	script:waitFor( mission_util.PC_SAW_UNIT("hostage") )
	sim:forEachUnit(
		function(unit)
			if unit:getTraits().hostage then 
				local x, y = unit:getLocation()
				script:queue( { type="displayHUDInstruction", text="RAPID PULSE READING", x=x, y=y } )
				script:queue( { type="pan", x=x, y=y } )
				--unit:getTraits().vitalSigns = VITAL_SIGN_START
				--print( "vital signs: "..unit:getTraits().vitalSigns )
			end
		end)
	script:queue( 0.5*cdefs.SECONDS )
	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_SIGHTED, type="operatorMessage", profileAnim="portraits/central_face", profileBuild="portraits/central_face" } )

	script:waitFor( mission_util.PC_ANY )	
	script:queue( { type="clearOperatorMessage" } )

	sim:removeObjective( "hostage_1" )
	sim:addObjective( STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.OBJECTIVE_RESCUE_HOSTAGE, "hostage_2" )

	script:waitFor( HOSTAGE_RESCUE )

	sim:openElevator()
	calculateHostageVitalSigns(sim)

	script:queue( { type="hideHUDInstruction" } )
	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_CONVO1, header=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_NAME, type="enemyMessage" } )
	script:queue( 160 )	
	script:queue( { type="clearEnemyMessage" } )
	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.OPERATOR_CONVO1, type="operatorMessage", profileAnim="portraits/central_face", profileBuild="portraits/central_face" } )
	script:queue( 160 )	
	script:queue( { type="clearOperatorMessage" } )
	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_CONVO2, header=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_NAME, type="enemyMessage" } )
	script:queue( 160 )	
	script:queue( { type="clearEnemyMessage" } )
	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.OPERATOR_CONVO2, type="operatorMessage", profileAnim="portraits/central_face", profileBuild="portraits/central_face" } )
	script:queue( 5*cdefs.SECONDS )	

	updateVitalStatus(script, sim, true)

	local player = sim:getCurrentPlayer()

	script:addHook( clearHostageStatusAfterMove )
	script:addHook( clearStatusAfterEndTurn )
	script:addHook( checkHostageDeath )

	script:waitFor( mission_util.PC_START_TURN )	
	script:clearQueue()
	script:queue( { type="clearOperatorMessage" } )

	script:addHook( hostageBanter )

	sim:removeObjective( "hostage_2" )
	sim:addObjective( STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.OBJECTIVE_ESCAPE, "hostage_3" )
	sim:getTags().no_escape = nil

	script:waitFor( HOSTAGE_ESCAPED )
	sim:getTags().delayPostGame = true
	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.OPERATOR_ESCAPE, type="operatorMessage", profileAnim="portraits/central_face", profileBuild="portraits/central_face" } )
	script:waitFrames( 200 )

	script:queue( { type="clearOperatorMessage" } )
	sim:getTags().delayPostGame = false
end

---------------------------------------------------------------------------------------------
-- Begin!

local hostage_mission = class( mission_util.campaign_mission )
--local hostage_mission = class( escape_mission )

function hostage_mission:init( scriptMgr, sim )
    mission_util.campaign_mission.init( self, scriptMgr, sim )
--	escape_mission.init( self, scriptMgr, sim )

	scriptMgr:addHook( "HOSTAGE", startPhase )
end

function hostage_mission.pregeneratePrefabs( cxt, tagSet ) -- was tags instead of tagSet
	escape_mission.pregeneratePrefabs( cxt, tagSet ) -- added
	table.insert( tagSet[1], "hostage" )
	--table.insert( tags, "hostage" )
end

function hostage_mission.finalizeProcgen( cxt )
	local hostageUnit = cxt:pickUnit( function(u) return u.template == "hostage_capture" end )
	local startX, startY = cxt:pickCell( cxt.IS_DEPLOY_CELL )
	local exitX, exitY = cxt:pickCell( cxt.IS_EXIT_CELL )
	log:write( "FINALIZE: hostage@ <%d, %d>, start<%d, %d>, end<%d, %d>", hostageUnit.x, hostageUnit.y, startX, startY, exitX, exitY )
	local p0 = cxt:findPath( startX, startY, hostageUnit.x, hostageUnit.y )
	local p1 = cxt:findPath( hostageUnit.x, hostageUnit.y, exitX, exitY )
	local rlen = mathutil.dist2d( 0, 0, cxt.board.width, cxt.board.height ) * 2.5
	local len0 = p0 and p0:getTotalMoveCost() or -1
	local len1 = p1 and p1:getTotalMoveCost() or -1
	log:write( "\tPATH TO HOSTAGE ( %d ) + PATH TO EXIT( %d ) == %d >= %d (%.2f)", len0, len1, len0 + len1, rlen, (len0 + len1) / rlen )
	return (len0 + len1) / rlen
end

return hostage_mission
