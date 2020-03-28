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

local SCRIPTS = include('client/story_scripts')
local escape_mission = include( "sim/missions/escape_mission" ) -- in case if  we initiate mission as escape_mission class
								-- instead of mission_util.campaign_mission class

---------------------------------------------------------------------------------------------
-- Local helpers

local MISSION_REWARD = 800 -- base reward, getting through "sim:setMissionReward ( simquery.scaleCredits( sim, MISSION_REWARD ))" 
				-- With 1x multiplier it's: 800 at 1st security level, 1000 at second, 1200 at third, 1400 at fourth and later
				-- With 0.75x it's: 600, 750, 900, 1050
local HISEC_EXIT_DAY = 5    

local HOSTAGE_DEAD =
{
	trigger = "hostage_dead",
}

local HOSTAGE_KO =
{
	trigger = simdefs.TRG_UNIT_KO,
	fn = function( sim, evData )
		return evData.unit:getTraits().MM_hostage
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
		return unitID and sim:getUnit( unitID ):isPC() and sim:getUnit( unitID ):getTraits().MM_hostage 
	end,
}

local PC_HOSTAGE_STARTED_MOVE =
{
	pre=true,
	action = "moveAction",
	fn = function( sim, unitID, moveTable )
		return unitID and sim:getUnit( unitID ):isPC() and sim:getUnit( unitID ):getTraits().MM_hostage 
	end,
}

local PC_HOSTAGE_HIT_END =
{
	trigger = simdefs.TRG_UNIT_HIT,
	fn = function( sim, evData )
		return evData.targetUnit:getTraits().MM_hostage
	end,	
}

NPC_END_TURN =
{
	trigger = simdefs.TRG_END_TURN,
	fn = function( sim, evData )
		if evData:isPC() then 
			return false 
		else
			return true 
		end  
	end,
}

local function isEndlessMode( params, day )
    if params.newHiSecExitDay then
        day = params.newHiSecExitDay
    end
    if params.difficultyOptions.maxHours == math.huge then
        return params.campaignHours >= 24 * (day - 1 )
    end

    return false
end


local function checkForAgents ( sim )
	local agents = false
	sim:forEachUnit(
		function(unit)
			if unit:getTraits().seesHidden and not unit:getTraits().notDraggable then -- 1st check for agents, second to exclude N-Umi's drone
				agents = true
			end
		end
	)
	return agents
end


local function checkNoHostageGameOver( script, sim )
	script:waitFor( mission_util.PC_WON )

	script:removeAllHooks( script )
	sim:getTags().delayPostGame = true

	script:clearQueue()
	script:queue( { type="clearEnemyMessage" } )
	script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_COMPLETE_MISSION_NO_COURIER[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_COMPLETE_MISSION_NO_COURIER)], type="newOperatorMessage" })
	script:waitFrames( 240 )
	script:queue( { type="clearOperatorMessage" } )

	sim:getTags().delayPostGame = false
end

local function checkHostageKO( script, sim )

	while true do
		script:waitFor( HOSTAGE_KO )
	        print( "HOSTAGE DEATH!" )
		script:removeAllHooks( script )
		local hostage = nil
		local hostageID = nil
		sim:forEachUnit(
			function(unit)
				if unit:getTraits().MM_hostage then 
					hostage = unit
					hostageID = hostage:getID()
				end
			end
		)

		--local hostage = getHostage(sim)
		local x, y = hostage:getLocation()
		local text=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_VITALS
		local subtext = STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_VITALS_SUBTEXT_DEATH
		script:queue( { soundPath="SpySociety/Actions/guard/guard_heart_flatline", type="operatorVO" } )
		
		sim:setMissionReward( 0 )
		local missionReward = sim:getMissionReward()
		print( "Mission reward: "..missionReward )
		--script:waitFor( PC_ANY )
		--script:waitFrames( 1*cdefs.SECONDS )
		--sim:forEachUnit(
		--	function(unit)
		--		if unit:getTraits().iscorpse and unit:getID()== hostageID then 
		--			hostage = unit
		--		end
		--	end
		--)
		
		--hostage:createTab( text, subtext )  
		script:waitFrames( 2*cdefs.SECONDS )
		local agents = checkForAgents(sim)
		if agents then 
			script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_DEATH[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_DEATH)], type="newOperatorMessage" })
		else
			script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_LONE_DEATH[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_LONE_DEATH)], type="newOperatorMessage" })
 		end

		sim:removeObjective( "hostage_3" )
		script:addHook( checkNoHostageGameOver )

		script:waitFor( PC_HOSTAGE_HIT_END, mission_util.NPC_WARP, NPC_END_TURN, mission_util.PC_ANY )	
		if hostage:isKO() then
				local hostageID = hostage:getID()
				hostage:killUnit( hostage._sim )
				sim:getPC():glimpseUnit( sim, hostageID ) -- KO icon likes to stuck until an agents see corpse so...
			end
		script:queue( { type="clearOperatorMessage" } )
		script:waitFrames( 2*cdefs.SECONDS )
		--hostage:destroyTab()		
		
		
	end

end

local function checkHostageDeath( script, sim )

	while true do
		script:waitFor( HOSTAGE_DEAD )
	        print( "HOSTAGE DEATH!" )
		script:removeAllHooks( script )		
	--	local hostage = nil
	--	sim:forEachUnit(
	--		function(unit)
	--			if unit:getTraits().hostage then 
	--				hostage = unit
	--			end
	--		end
	--	)

		--local hostage = getHostage(sim)
	--	local x, y = hostage:getLocation()
	--	local subtext = STRINGS.MISSIONS.HOSTAGE.HOSTAGE_VITALS_SUBTEXT_DEATH
		script:queue( { soundPath="SpySociety/Actions/guard/guard_heart_flatline", type="operatorVO" } )
	--	script:queue( { 
	--		type="displayHUDInstruction", 
	--		text=STRINGS.MISSIONS.HOSTAGE.HOSTAGE_VITALS, 
	--		subtext=subtext,
	--		x=x, y=y } )

		--hostage:killUnit( sim )]]
		
		script:waitFrames( 2*cdefs.SECONDS )
		local agents = checkForAgents(sim)
		if agents then 
			script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_DEATH[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_DEATH)], type="newOperatorMessage" })
		else
			script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_LONE_DEATH[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_LONE_DEATH)], type="newOperatorMessage" })
 		end

		sim:removeObjective( "hostage_3" )
		script:waitFor( mission_util.PC_ANY )	
		script:queue( { type="clearOperatorMessage" } )

		script:addHook( checkNoHostageGameOver )
		
	end

end

local function updateVitalStatus( script, sim, playSound )
	sim:forEachUnit(
		function(unit)
			if unit:getTraits().MM_hostage then 
				--unit:destroyTab()
				local x, y = unit:getLocation()
				local text = STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_VITALS 
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
				unit:createTab( text, subtext )  			
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
				if unit:getTraits().MM_hostage then 
					hostage = unit
				end
			end
		)

		if hostage and not hostage:isKO() and not hostage:isDead() then
			hostage:getTraits().vitalSigns = hostage:getTraits().vitalSigns - 1

			if hostage:getTraits().vitalSigns <= 0 then
				script:removeHook( checkHostageDeath )
				script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_PASS_OUT, 
					header=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_NAME, type="enemyMessage", 
					profileAnim="portraits/portrait_animation_template",
					profileBuild="portraits/courier_face",
				} )
				script:waitFrames( 2*cdefs.SECONDS )

				script:queue( { soundPath="SpySociety/Agents/Agent_1/Regular/die", type="operatorVO" } )
				sim:damageUnit( hostage, hostage:getTraits().woundsMax )
				updateVitalStatus(script, sim, true)

				script:waitFrames( 1*cdefs.SECONDS )
				script:queue( { type="clearEnemyMessage" } )

				script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_PASS_OUT[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_PASS_OUT)], type="newOperatorMessage" })	
				script:queue( 1*cdefs.SECONDS )
				script:queue( { type="clearOperatorMessage" } )

				--hostage:killUnit( sim )
				sim:removeObjective( "hostage_3" )
				gameOver = true

				--add the no hostage gameover check
				script:addHook( checkNoHostageGameOver )
			end

			if not gameOver then
				updateVitalStatus(script, sim, true)

				script:queue( 1*cdefs.SECONDS )
				i = i + 1
				if i < #STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_BANTER then					
					script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_BANTER[i], 
					header=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_NAME, type="enemyMessage", 
					profileAnim="portraits/portrait_animation_template",
					profileBuild="portraits/courier_face",
				} )
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
		local _, hostage = script:waitFor( PC_HOSTAGE_STARTED_MOVE )
		sim:forEachUnit(
		function(unit)
			if unit:getTraits().MM_hostage then 
				unit:destroyTab()				
			end
		end)	
	end
end

local function updateHostageStatusAfterMove( script, sim )

	while true do
		local _, hostage = script:waitFor( PC_HOSTAGE_MOVED )		
		updateVitalStatus(script, sim, false)
	end
end

local function clearStatusAfterEndTurn( script, sim )

	while true do
		--updateVitalStatus(script, sim)
		script:waitFor( mission_util.PC_END_TURN )
		local hostage = nil
		sim:forEachUnit(
			function(unit)
				if unit:getTraits().MM_hostage then 
					hostage = unit
					hostage:destroyTab()
				end
			end
		)		
	end

end

local function getExit(sim)

	local exitcell = nil
	local isEndless = isEndlessMode(sim:getParams(), HISEC_EXIT_DAY)
	if isEndless then
		local exitroom = nil
		sim:forEachCell(function(cell)
			if cell.exitID then 
				exitroom = cell.procgenRoom.roomIndex
			end
		end)
		sim:forEachCell(function(cell)
			if cell.procgenRoom.roomIndex == exitroom and cell.tags == nil and cell.exitID == nil 
					and cell.tileIndex ~= nil and cell.tileIndex ~= cdefs.TILE_SOLID then
			   	exitcell = cell 
			end
		end)	
	else
		sim:forEachCell(
			function( c )
				for i, exit in pairs( c.exits ) do
					local cell = exit.cell
					if cell and ((cell.exitID ~= nil and cell.exitID ~= simdefs.EXITID_VENT) or cell.ventID ~= nil) then
						exitcell = cell
					end
				end
			end )
	end
	return exitcell
end

local function calculateHostageVitalSigns( sim )

	local extraSigns = 1
	local isEndless = isEndlessMode(sim:getParams(), HISEC_EXIT_DAY)
	if isEndless then
		extraSigns = 2
	end

	local hostage = nil
	sim:forEachUnit(
		function(unit)
			if unit:getTraits().MM_hostage then 
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
	local newSigns = sim:nextRand(minTurns, maxTurns) + extraSigns	
	--print( "vital signs should be: "..newSigns )	
	hostage:getTraits().vitalSigns = newSigns
	print( "vital signs: "..hostage:getTraits().vitalSigns )
end

local function startPhase( script, sim )

	sim:addObjective( STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.OBJECTIVE_FIND_HOSTAGE, "hostage_1" )
	sim:getTags().no_escape = true
	
	--See the hostage	
	local _, hostage = script:waitFor( mission_util.SAW_SPECIAL_TAG(script, "MM_hostage", STRINGS.MISSIONS.UTIL.HEAT_SIGNATURE_DETECTED, STRINGS.MISSIONS.UTIL.RAPID_PULSE_READING ) )
	sim:forEachUnit(
		function(unit)
			if unit:getTraits().MM_hostage then 
				local x, y = unit:getLocation()			
				script:queue( { type="pan", x=x, y=y } )				
			end
		end)

	script:queue( 0.5*cdefs.SECONDS )

	script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.HOSTAGE_SIGHTED[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.HOSTAGE_SIGHTED)], type="newOperatorMessage" } )
	
	script:waitFor( mission_util.PC_ANY )	
	script:queue( { type="clearOperatorMessage" } )

	sim:removeObjective( "hostage_1" )
	sim:addObjective( STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.OBJECTIVE_RESCUE_HOSTAGE, "hostage_2" )

	
	script:waitFor( mission_util.PC_USED_ABILITY( "hostage_rescuable" ))
	sim:setClimax(true)
	sim:forEachUnit(
		function(unit)
			if unit:getTraits().MM_hostage then 
				unit:destroyTab()				
			end
		end)	
	
	sim:openElevator()	
	script:addHook( clearHostageStatusAfterMove )
	script:addHook( clearStatusAfterEndTurn )
	script:addHook( updateHostageStatusAfterMove )
	script:addHook( checkHostageKO )
	script:addHook( checkHostageDeath )
	script:addHook( hostageBanter )	

	script:queue( { type="clearOperatorMessage" } )
	script:queue( { type="clearEnemyMessage" } )

	script:queue( 0.5*cdefs.SECONDS )
	--calculateHostageVitalSigns(sim)	
	--updateVitalStatus(script, sim, true)

	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_CONVO1, 
					header=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_NAME, type="enemyMessage", 
					profileAnim="portraits/portrait_animation_template",
					profileBuild="portraits/courier_face",
				} )
	script:queue( 160 )	
	script:queue( { type="clearEnemyMessage" } )
	script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.OPERATOR_CONVO1[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.OPERATOR_CONVO1)], type="newOperatorMessage" } )	
	--script:queue( 160 )	
	script:queue( { type="clearOperatorMessage" } )
	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_CONVO2, 
					header=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_NAME, type="enemyMessage", 
					profileAnim="portraits/portrait_animation_template",
					profileBuild="portraits/courier_face",
				} )
	script:queue( 160 )	
	script:queue( { type="clearEnemyMessage" } )
	script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.OPERATOR_CONVO2[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.OPERATOR_CONVO2)], type="newOperatorMessage" } )	
	--script:queue( 5*cdefs.SECONDS )	

	--local player = sim:getCurrentPlayer()	

	sim:removeObjective( "hostage_2" )
	sim:addObjective( STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.OBJECTIVE_ESCAPE, "hostage_3" )
	sim:getTags().no_escape = nil

	script:waitFor( mission_util.PC_ANY )		
	calculateHostageVitalSigns(sim)	
	updateVitalStatus(script, sim, true)


	script:waitFor( HOSTAGE_ESCAPED )
	--sim:setMissionReward( MISSION_REWARD )
	sim:setMissionReward ( simquery.scaleCredits( sim, MISSION_REWARD ))		
	sim:removeObjective( "hostage_3" )

	sim:getTags().delayPostGame = true
	script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.OPERATOR_ESCAPE[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.OPERATOR_ESCAPE)], type="newOperatorMessage" } )
	script:waitFrames( 200 )

	script:queue( { type="clearOperatorMessage" } )
	sim:getTags().delayPostGame = false
end

-- DLC compatibility stuff

local checkFtmRouter = function( script, sim )
    local _, scanner = script:waitFor( mission_util.PC_SAW_UNIT("ftmrouter") ) 
    
    if not scanner:getTraits().scannerTabAdded then
        script:queue( { type="clearOperatorMessage" } )
        scanner:createTab( STRINGS.PROPS.ADVANCED_CORP_EQUIP, STRINGS.DLC1.PROPS.FTM_ROUTER_TAB )
        scanner:getTraits().scannerTabAdded = true
    end
end

local function routerDetected( script, sim )
    script:waitFor( mission_util.PC_START_TURN )
    -- Verify it hasn't been immediately hacked.
    local routerUnit = simquery.findUnit( sim:getAllUnits(), function( u ) return u:getTraits().router and u:getPlayerOwner() == nil end )

    local routers = 0
    
    for i,unit in pairs(sim:getAllUnits())do
        if unit:getTraits().router and unit:getPlayerOwner() ~= sim:getPC() and unit:getTraits().mainframe_status == "active" then
            routers = routers + 1
        end
    end

    if routerUnit then
        script:queue( { type="clearOperatorMessage" } )
        script:queue( { script=SCRIPTS.INGAME.CENTRAL_ROUTER_DETECTED, type="newOperatorMessage" } )   

        local num = routers
        if routers < 2 then
            num = nil    
        end

        if routers == 1 then
            sim:addObjective( STRINGS.DLC1.MISSIONS.OBJ_ROUTER, "router", num )
        else
            sim:addObjective( STRINGS.DLC1.MISSIONS.OBJ_ROUTERS, "router", num )    
        end
      
        if routers > 1 then
            while routers > 0 do                
                script:waitFor( mission_util.TRG_UNIT_DEACTIVATED( ))

                local newRouters = 0
                for i,unit in pairs(sim:getAllUnits())do
                    if unit:getTraits().router and unit:getPlayerOwner() ~= sim:getPC() and unit:getTraits().mainframe_status == "active" then                                
                        newRouters = newRouters + 1
                    end
                end

                if newRouters < routers then
                    sim:incrementTimedObjective( "router" )
                    routers = routers -1
                end
            end
            sim:removeObjective( "router" )
        else
            script:waitFor( mission_util.UNIT_DEACTIVATED( routerUnit ))        
            sim:removeObjective( "router" )
        end
        script:queue( 2*cdefs.SECONDS )
        script:queue( { script=SCRIPTS.INGAME.CENTRAL_ROUTER_DETECTED_2, type="newOperatorMessage" } )         
    end
end

local function powerCell( script, sim )

    sim:addObjective( STRINGS.DLC1.MISSIONS.OBJ_FIND_CELL, "findCell" ) 

    local _, powerNode = script:waitFor( mission_util.SAW_SPECIAL_TAG(script, "power_cell", STRINGS.DLC1.MISSIONS.POWER_CELL_DETECTED, STRINGS.DLC1.MISSIONS.POWER_CELL_DETECTED_DESC ) )  
    sim:removeObjective("findCell")    
    sim:addObjective( STRINGS.DLC1.MISSIONS.OBJ_GET_CELL, "getCell" ) 
    local x1, y1 = powerNode:getLocation()
    script:queue( { type="pan", x=x1, y=y1 } )

    script:waitFor( PC_LOOTED_POWER_CELL )
    powerNode:destroyTab()
    script:queue( 1*cdefs.SECONDS )
    script:queue( { script=SCRIPTS.INGAME.CENTRAL_GOT_POWER_CELL[sim:nextRand(1, #SCRIPTS.INGAME.CENTRAL_GOT_POWER_CELL)], type="newOperatorMessage" } )    
    
    sim:removeObjective("getCell") 
    sim:addObjective( STRINGS.DLC1.MISSIONS.OBJ_ESCAPE_CELL, "escapeWithCell" )

    sim:removeObjective("find_case")    

end

---------------------------------------------------------------------------------------------
-- Begin!

local hostage_mission = class( mission_util.campaign_mission )
--local hostage_mission = class( escape_mission )

function hostage_mission:init( scriptMgr, sim )
	-- escape_mission.init contains sim:openElevator, here same code but without opening exit doors:
    mission_util.campaign_mission.init( self, scriptMgr, sim )

    if isEndlessMode( sim:getParams(), HISEC_EXIT_DAY ) then
    	sim:addObjective( STRINGS.MISSIONS.ESCAPE.OBJ_EXIT_PASSCARD, "elevator_1" )
    else
        sim:addObjective( STRINGS.MISSIONS.ESCAPE.OBJECTIVE, "elevator_1" )
    end
	
    	scriptMgr:addHook( "CONNECT", mission_util.makeAgentConnection )
	scriptMgr:addHook( "FTM-SCANNER", mission_util.checkFtmScanner )	

    for i, mod in pairs(mod_manager.modMissionScripts)do
        if mod.init then
            mod.init(scriptMgr, sim )
        end
    end
	scriptMgr:addHook( "HOSTAGE", startPhase )

	    -- DLC missions stuff.
    for k,unit in pairs(sim:getAllUnits()) do
        if unit:getTraits().router then
            scriptMgr:addHook( "ROUTER-DETECT", routerDetected )
            scriptMgr:addHook( "FTM-ROUTER", checkFtmRouter )  
            break
        end
    end

    if sim:getParams().missionEvents and sim:getParams().missionEvents.needPowerCells then
        sim:getTags().needPowerCells = true
        scriptMgr:addHook( "POWER_CELL", powerCell )  
        sim:getTags().exit_reqiuired_item = "item_power_cell"
        local win_conditions = include( "sim/win_conditions" )
        sim:addWinCondition( win_conditions.escapedWithObjective )
        sim:getTags().failMessage = SCRIPTS.INGAME.FAIL_TO_GET_POWER_CELL      
    end
    
    local params = sim:getParams()    

    -- adjusted enldess 
    if params.difficultyOptions.maxHours == math.huge and params.extended_endless then          
        if params.difficulty >= 20 then       
            sim:getNPC():addMainframeAbility( sim, "chitonAlarm_3", nil, 0 )
            sim:getNPC():addMainframeAbility( sim, "shockAlarm_3", nil, 0 )     
        elseif params.difficulty >= 18 then       
            sim:getNPC():addMainframeAbility( sim, "chitonAlarm_3", nil, 0 )
            sim:getNPC():addMainframeAbility( sim, "shockAlarm_2", nil, 0 )     
        elseif params.difficulty >= 16 then             
            sim:getNPC():addMainframeAbility( sim, "chitonAlarm_2", nil, 0 )
            sim:getNPC():addMainframeAbility( sim, "shockAlarm_2", nil, 0 )            
        elseif params.difficulty >= 14 then            
            sim:getNPC():addMainframeAbility( sim, "chitonAlarm_2", nil, 0 )
            sim:getNPC():addMainframeAbility( sim, "shockAlarm", nil, 0 )            
        elseif params.difficulty >= 12 then
            sim:getNPC():addMainframeAbility( sim, "chitonAlarm", nil, 0 )
            sim:getNPC():addMainframeAbility( sim, "shockAlarm", nil, 0 )
        elseif params.difficulty >= 10 then
            sim:getNPC():addMainframeAbility( sim, "chitonAlarm", nil, 0 )
        end
    end
end

function hostage_mission.pregeneratePrefabs( cxt, tagSet ) 	-- was tags instead of tagSet
	escape_mission.pregeneratePrefabs( cxt, tagSet ) 	-- added
	table.insert( tagSet[1], "hostage" )
	
	 if cxt.params.missionEvents and cxt.params.missionEvents.needPowerCells then  
        	table.insert( tagSet, { { "powerCell", exitFitnessFn } })
   	 end

end

function hostage_mission.generatePrefabs( cxt, candidates )
    local prefabs = include( "sim/prefabs" )
    if isEndlessMode( cxt.params, HISEC_EXIT_DAY ) then
        prefabs.generatePrefabs( cxt, candidates, "safe_exit_vault", 1 )
    end

    for i, mod in pairs(mod_manager.modMissionScripts)do
        if mod.generatePrefabs then
            mod.generatePrefabs( cxt, candidates )
        end
    end
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
