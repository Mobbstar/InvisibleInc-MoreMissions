local array = include( "modules/array" )
local util = include( "modules/util" )
local mathutil = include( "modules/mathutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local simfactory = include( "sim/simfactory" )
local simquery = include( "sim/simquery" )
local mission_util = include( "sim/missions/mission_util" )
local unitdefs = include( "sim/unitdefs" )
local win_conditions = include( "sim/win_conditions" )
local strings = include( "strings" )
local astar = include( "modules/astar" )
local astar_handlers = include("sim/astar_handlers")
local speechdefs = include("sim/speechdefs")

local SCRIPTS = include('client/story_scripts')
local escape_mission = include( "sim/missions/escape_mission" ) -- in case if  we initiate mission as escape_mission class
								-- instead of mission_util.campaign_mission class

---------------------------------------------------------------------------------------------
-- Local helpers
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
	trigger = simdefs.TRG_UNIT_ESCAPED,
	fn = function( sim, triggerUnit )
		if triggerUnit and triggerUnit:hasTag("MM_hostage") then
			return triggerUnit
		end
	end,
}

--for the sole purpose of removing the UI tab
local HOSTAGE_ESCAPING =
{
	trigger = simdefs.TRG_MAP_EVENT,
	fn = function( sim, evData )
		if evData.units then
			for i, unit in pairs(evData.units) do
				if unit:hasTag("MM_hostage") then
					return unit
				end
			end
		end
	end,
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

local NPC_END_TURN =
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

local CAPTAIN_SAW_FREE_HOSTAGE =
{
	-- Based on mission_util.PC_SAW_UNIT, but for the Captain.
	trigger = simdefs.TRG_UNIT_APPEARED,
	fn = function( sim, evData )
		local seer = sim:getUnit( evData.seerID )
		if not seer or not seer:hasTag("MM_captain") then
			return false
		end

	 -- Hostage "agent" and prop both have MM_hostage but untie_anim is prop-specific.
		if evData.unit:hasTag("MM_hostage") and not evData.unit:getTraits().untie_anim then
			return evData.unit, seer
		else
			return false
		end
	end,
}

local CAPTAIN_SAW_DISCARDED_MANACLES =
{
	-- Based on mission_util.PC_SAW_UNIT, but for the Captain.
	trigger = simdefs.TRG_UNIT_APPEARED,
	fn = function( sim, evData )
		local seer = sim:getUnit( evData.seerID )
		if not seer or not seer:hasTag("MM_captain") then
			return false
		end

		if evData.unit:hasTag("MM_discarded_manacles") then
			return evData.unit, seer
		else
			return false
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

-- replaced with a regular Central Judgement
-- local function checkNoHostageGameOver( script, sim )
	-- script:waitFor( PC_WON )

	-- script:removeAllHooks( script )
	-- sim:getTags().delayPostGame = true

	-- script:clearQueue()
	-- script:queue( { type="clearEnemyMessage" } )
	-- script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_COMPLETE_MISSION_NO_COURIER[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_COMPLETE_MISSION_NO_COURIER)], type="newOperatorMessage" })
	-- script:waitFrames( 240 )
	-- script:queue( { type="clearOperatorMessage" } )

	-- sim:getTags().delayPostGame = false
-- end

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
					subtext = util.sformat( STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_VITALS_SUBTEXT, unit:getTraits().vitalSigns )
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
				script:removeHook( "checkHostageDeath" )
				sim:getTags().MM_hostageExpired = true
				script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_PASS_OUT,
					header=STRINGS.MOREMISSIONS.AGENTS.EA_HOSTAGE.NAME, type="enemyMessage",
					profileAnim="portraits/portrait_animation_template",
					profileBuild="portraits/courier_face",
				} )
				script:waitFrames( 2*cdefs.SECONDS )

				script:queue( { soundPath="SpySociety/Agents/Agent_1/Regular/die", type="operatorVO" } )
				sim:damageUnit( hostage, hostage:getTraits().woundsMax )
				updateVitalStatus(script, sim, true)

				script:waitFrames( 1*cdefs.SECONDS )
				script:queue( { type="clearEnemyMessage" } )

				-- script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_PASSEDOUT[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_PASSEDOUT)], type="newOperatorMessage" })
				script:queue( 1*cdefs.SECONDS )
				script:queue( { type="clearOperatorMessage" } )

				--hostage:killUnit( sim )
				sim:removeObjective( "hostage_3" )
				gameOver = true

				--add the no hostage gameover check
				-- script:addHook( checkNoHostageGameOver )
			end

			if not gameOver then
				updateVitalStatus(script, sim, true)

				script:queue( 1*cdefs.SECONDS )
				i = i + 1
				if i < #STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_BANTER then
					script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_BANTER[i],
					header=STRINGS.MOREMISSIONS.AGENTS.EA_HOSTAGE.NAME, type="enemyMessage",
					profileAnim="portraits/portrait_animation_template",
					profileBuild="portraits/courier_face",
				} )
					script:queue( 4*cdefs.SECONDS )
					script:queue( { type="clearEnemyMessage" } )
				end
				script:queue( { type="clearEnemyMessage" } )
				if hostage:getTraits().vitalSigns == 3 then -- Central warns player
					script:waitFrames( 0.5*cdefs.SECONDS )
					script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_PASSOUT_WARNING[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_PASSOUT_WARNING)], type="newOperatorMessage" } )
				end
			end
		end
	end

end

local function clearHostageStatusAfterTeleport( script, sim )
	local _, hostage = script:waitFor(HOSTAGE_ESCAPING)
	hostage:destroyTab()
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

-- if default exit, get cell just outside of the elevator
-- if endless exit, get cell on the other side of vault door
-- so calculateHostageVitalSigns can always find a path,
-- even when AGP's simquery.canPathBetween override is not present.
-- (it makes the A* findPath possible to ignore locked doors when a unit isn't passed to it) 
local function getExit(sim)
	for _, room in ipairs(sim._rooms) do
		if room.tags.exit then
			for _, rect in ipairs(room.rects) do
				for x = rect.x0, rect.x1 do
					for y = rect.y0, rect.y1 do
						local cell = sim:getCell(x, y)
						if cell.exitID == simdefs.DEFAULT_EXITID then
							for _, dir in ipairs(simdefs.DIR_SIDES) do
								local nCell = cell.exits[dir] and cell.exits[dir].cell
								if
									nCell
									and nCell.exitID ~= simdefs.DEFAULT_EXITID
									and nCell.tileIndex ~= cdefs.TILE_SOLID
								then
									return nCell
								end
							end
						end
					end
				end
			end
		elseif room.tags.exit_vault then
			for _, rect in ipairs(room.rects) do
				for x = rect.x0, rect.x1 do
					for y = rect.y0, rect.y1 do
						local cell = sim:getCell(x, y)
						if simquery.cellHasTag(sim, cell, "noguard") then
							for _, dir in ipairs(simdefs.DIR_SIDES) do
								local exit = cell.exits[dir]
								if exit and exit.keybits == simdefs.DOOR_KEYS.SPECIAL_EXIT then
									return exit.cell
								end
							end
						end
					end
				end
			end
		end
	end
end

local function keepExitLocked( script, sim )
	while true do
		script:waitFor( mission_util.PC_END_TURN )
		
		if sim._elevator_inuse == 1 then
			sim._elevator_inuse = 2
			sim._elevatorHeldByHostage = true
		else
			sim._elevatorHeldByHostage = false
		end
	end
end

local function calculateHostageVitalSigns( sim )

	local extraSigns = 1
	local isEndless = isEndlessMode(sim:getParams(), HISEC_EXIT_DAY)
	if isEndless then
		extraSigns = 2
	end
	if sim:getParams().difficultyOptions.MM_difficulty and (sim:getParams().difficultyOptions.MM_difficulty == "easy") then
		extraSigns = 3
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

	-- last argument is includeTeleports for Facility Flux
	local pather = astar.AStar:new( astar_handlers.handler:new( sim, nil, nil, nil, true, true ) )
	local path = pather:findPath( startcell, endcell )

	assert(path)

	local distToExit = path:getTotalMoveCost()
	local maxTurns = math.floor(distToExit*2 / hostage:getMPMax())
	local minTurns = math.floor(distToExit*1.5 / hostage:getMPMax())
	local newSigns = sim:nextRand(minTurns, maxTurns) + extraSigns
	--print( "vital signs should be: "..newSigns )

	log:write("[MM] distToExit: "..distToExit)
	log:write( "vital signs: "..newSigns )
	return newSigns
end

local function checkCaptainSeenFreeHostage(script, sim)
	local _, _, captain = script:waitFor( CAPTAIN_SAW_FREE_HOSTAGE )
	captain:getTraits().mmCaptainSawFreeHostage = 1
end

local function alertCaptainForMissingHostage(script, sim)
	local _, manacles, captain = script:waitFor( CAPTAIN_SAW_DISCARDED_MANACLES )

	-- Don't investigate if the captain already knows the hostage is free.
	if captain:getBrain() and (not captain:isAlerted() or not captain:getTraits().mmCaptainSawFreeHostage) then
		local x, y = manacles:getLocation()
		captain:setAlerted(true)
		captain:getBrain():getSenses():addInterest(x, y, simdefs.SENSE_SIGHT, simdefs.REASON_LOSTTARGET, manacles)
	end
end

local function isCaptain(unit)
	return unit:hasTag("MM_captain")
end

local function courier_guard_banter(script, sim)
	script:waitFor( mission_util.PC_START_TURN )

	local hostage = mission_util.findUnitByTag(sim, "MM_hostage")
	local captain = simquery.findUnit(sim:getNPC():getUnits(), isCaptain ) --this version doesn't cause assertion error if captain has been killed i.e. despawned already

	if hostage and captain and captain:getBrain() and not captain:isAlerted() and captain:getBrain():getSituation().ClassType == simdefs.SITUATION_IDLE and not hostage:isKO() and not captain:isKO() and sim:canPlayerSeeUnit(sim:getPC(), hostage) and	sim:canPlayerSeeUnit(sim:getPC(), captain) then
		script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.GUARD_INTERROGATE1,
						header=captain:getUnitData().name, type="enemyMessage",
						profileAnim="portraits/portrait_animation_template",
						profileBuild = captain:getUnitData().profile_build or captain:getUnitData().profile_anim,
					} )
		script:queue( 5*cdefs.SECONDS )
		script:queue( { type="clearEnemyMessage" } )

		local text =  {{
			text = STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.COURIER_INTERROGATE1,
			anim = "portraits/portrait_animation_template",
			build = "portraits/courier_face",
			name = STRINGS.MOREMISSIONS.AGENTS.EA_HOSTAGE.NAME,
			timing = 5,
			voice = nil,
		}}

		script:queue( { script=text, type="newOperatorMessage", doNotQueue=true } )

	end
end

local function createManacles(sim)
	local hostage = mission_util.findUnitByTag(sim, "MM_hostage")
	local cell = sim:getCell(hostage:getLocation())
	local manacles = simfactory.createUnit(unitdefs.lookupTemplate("MM_item_discarded_manacles"), sim)
	sim:spawnUnit(manacles)
	manacles:addTag("MM_discarded_manacles")
	sim:warpUnit(manacles, cell)
	sim:emitSound(simdefs.SOUND_ITEM_PUTDOWN, cell.x, cell.y)
end


-- Remove continuous hooks
local function removeHostageHooks( script )
	script:removeHook( courier_guard_banter )
	script:removeHook( clearHostageStatusAfterMove )
	script:removeHook( clearHostageStatusAfterTeleport )
	script:removeHook( clearStatusAfterEndTurn )
	script:removeHook( updateHostageStatusAfterMove )

	-- The following 1-time hooks are left active, in case they haven't triggered yet, or to ensure they finish cleanup
	-- checkCaptainSeenFreeHostage
	-- alertCaptainForMissingHostage
	-- checkHostageKO
	-- checkHostageDeath
	-- hostageBanter
end

local function checkHostageKO( script, sim )
	script:waitFor( HOSTAGE_KO )
	log:write( "HOSTAGE KO!" )
	removeHostageHooks( script )

	script:waitFor( PC_HOSTAGE_HIT_END, mission_util.NPC_WARP, NPC_END_TURN, mission_util.PC_ANY )

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
	if hostage:isKO() then
		local hostageID = hostage:getID()
		hostage:killUnit( hostage._sim )
		sim:getPC():glimpseUnit( sim, hostageID ) -- KO icon likes to stuck until an agents see corpse so...
	end
end

local function checkHostageDeath( script, sim )
	script:waitFor( HOSTAGE_DEAD )
	log:write( "HOSTAGE DEATH!" )
	removeHostageHooks( script )

	script:queue( { soundPath="SpySociety/Actions/guard/guard_heart_flatline", type="operatorVO" } )

	script:waitFrames( 2*cdefs.SECONDS )
	local agents = checkForAgents(sim)
	-- if agents then
		if sim:getTags().MM_hostageExpired then
			script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_PASSEDOUT[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_PASSEDOUT)], type="newOperatorMessage" })
		else
			script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.DEATH_SHOT[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.DEATH_SHOT)], type="newOperatorMessage" })
		end
	-- else
		-- script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_LONE_DEATH[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_HOSTAGE_LONE_DEATH)], type="newOperatorMessage" })
	-- end

	sim:removeObjective( "hostage_3" )
	script:waitFor( mission_util.PC_ANY )
	script:queue( { type="clearOperatorMessage" } )

	-- script:addHook( checkNoHostageGameOver )
end

local function startPhase( script, sim )

	sim:addObjective( STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.OBJECTIVE_FIND_HOSTAGE, "hostage_1" )
	-- sim:getTags().no_escape = true

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
	script:addHook(courier_guard_banter)

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

	sim:triggerEvent( "TRG_OBJ_COMPLETE", { missionType = "EA_hostage" })
	script:removeHook( keepExitLocked )
	local vital_signs = calculateHostageVitalSigns(sim)
	
	-- if sim._elevatorHeldByHostage and sim._elevator_inuse == 1 then
		-- sim._elevator_inuse = nil
		-- sim._elevatorHeldByHostage = nil
	-- else
		-- local elevator_status = sim._elevator_inuse
		-- sim:closeElevator( )
		-- sim._elevator_inuse = elevator_status
	-- end

	script:addHook( clearHostageStatusAfterMove )
	script:addHook( clearHostageStatusAfterTeleport )
	script:addHook( clearStatusAfterEndTurn )
	script:addHook( updateHostageStatusAfterMove )
	script:addHook( checkCaptainSeenFreeHostage )
	script:addHook( alertCaptainForMissingHostage )
	script:addHook( checkHostageKO )
	script:addHook( checkHostageDeath )
	script:addHook( hostageBanter )

	createManacles(sim)

	script:queue( { type="clearOperatorMessage" } )
	script:queue( { type="clearEnemyMessage" } )

	script:queue( 0.5*cdefs.SECONDS )
	--calculateHostageVitalSigns(sim)
	--updateVitalStatus(script, sim, true)
	
	script:queue( { soundPath="SpySociety/Actions/guard/guard_heart_stage3", type="operatorVO" } )
		
	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_CONVO1,
					header=STRINGS.MOREMISSIONS.AGENTS.EA_HOSTAGE.NAME, type="enemyMessage",
					profileAnim="portraits/portrait_animation_template",
					profileBuild="portraits/courier_face",
				} )
	script:queue( 160 )
	script:queue( { type="clearEnemyMessage" } )
	script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.OPERATOR_CONVO1[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.OPERATOR_CONVO1)], type="newOperatorMessage" } )
	--script:queue( 160 )
	script:queue( { type="clearOperatorMessage" } )
	script:queue( { body=STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.HOSTAGE_CONVO2,
					header=STRINGS.MOREMISSIONS.AGENTS.EA_HOSTAGE.NAME, type="enemyMessage",
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
	-- sim:getTags().no_escape = nil

	script:waitFor( mission_util.PC_ANY )
	
	local hostage = nil
	sim:forEachUnit(
		function(unit)
			if unit:getTraits().MM_hostage then 
				hostage = unit
			end
		end)
	assert(hostage)
	
	hostage:getTraits().vitalSigns = vital_signs
	updateVitalStatus(script, sim, false)

	script:waitFor( HOSTAGE_ESCAPED )
	sim.TA_mission_success = true -- flag for Talkative Agents
	sim:getTags().EA_hostage_rescued = true
	-- sim:setMissionReward( simquery.scaleCredits( sim, MISSION_REWARD )) --removed for now as we want the new sites to be the only reward from this.
	sim:removeObjective( "hostage_3" )

	-- Spawn new missions in the same corp but otherwise unspecified
	local serverdefs = include( "modules/serverdefs" )
	local tags = util.tmerge( { sim:getParams().world, "2max", "close_by", }, serverdefs.ESCAPE_MISSION_TAGS )
	array.removeIf(tags, function(v) return v == "executive_terminals" or v == "ea_hostage" end) -- These are not satisfying rewards to the player.

	for i = 1, 3 do
		sim:addNewLocation(util.tdupe(tags))
	end

	-- sim:getTags().delayPostGame = true
	script:waitFrames( 0.5*cdefs.SECONDS )
	script:queue( { script=SCRIPTS.INGAME.EA_HOSTAGE.OPERATOR_ESCAPE[sim:nextRand(1, #SCRIPTS.INGAME.EA_HOSTAGE.OPERATOR_ESCAPE)], type="newOperatorMessage" } )
	-- script:waitFrames( 200 )

	-- script:queue( { type="clearOperatorMessage" } )
	-- sim:getTags().delayPostGame = false
end

local function hostageFitness(cxt, prefab, x, y)
    local tileCount = cxt:calculatePrefabLinkage(prefab, x, y)
    if tileCount == 0 then
        return 0
    end

    -- mission_util.calculatePrefabDistance is searching for a string in the filename, so the endless exit is already included
    local maxDist = mission_util.calculatePrefabDistance(cxt, x, y, "entry", "exit")
    return tileCount + maxDist ^ 2
end

---------------------------------------------------------------------------------------------
-- Begin!

local hostage_mission = class( mission_util.campaign_mission )
--local hostage_mission = class( escape_mission )

function hostage_mission:init( scriptMgr, sim )
	sim.TA_mission_success = false
	escape_mission.init( self, scriptMgr, sim ) --let vanilla escape_mission.init run but follow it up with custom version of the sim:closeElevator code which doesn't set a 2 turn timer
	-- nvm, scrap the elevator mechanic after much debate -H
	-- local elevator_status = sim._elevator_inuse
	-- sim:closeElevator( )
	
	-- if elevator_status and elevator_status > 0 then
		-- sim._elevator_inuse = elevator_status
	-- else
		-- sim._elevator_inuse = 1
		-- sim._elevatorHeldByHostage = true
	-- end
	
	-- scriptMgr:addHook( "DOORLOCK", keepExitLocked )
	scriptMgr:addHook( "HOSTAGE", startPhase )

	local scriptfn = function()
        local scripts = SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_JUDGEMENT.COURIER_MIA
		if sim:getTags().EA_hostage_rescued then
			scripts = SCRIPTS.INGAME.EA_HOSTAGE.CENTRAL_JUDGEMENT.COURIER_ESCAPED
		end
        local scr = scripts[sim:nextRand(1, #scripts)]
        return scr
    end
	scriptMgr:addHook( "FINAL", mission_util.CreateCentralReaction(scriptfn))

end

function hostage_mission.pregeneratePrefabs( cxt, tagSet )
	local prefabs = include("sim/prefabs")
	escape_mission.pregeneratePrefabs( cxt, tagSet )
	-- tagSet[1].fitnessSelect = prefabs.SELECT_HIGHEST -- not sure why this is in vanilla, it just maximises tilecount between the default room prefabs
    table.insert(
        tagSet, {
            {"hostage", hostageFitness},
            fitnessSelect = prefabs.SELECT_HIGHEST
        }
    )
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

return hostage_mission
