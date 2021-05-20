local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local mission_util = include( "sim/missions/mission_util" )
local unitdefs = include( "sim/unitdefs" )
local simfactory = include( "sim/simfactory" )
local itemdefs = include( "sim/unitdefs/itemdefs" )
local serverdefs = include( "modules/serverdefs" )
local SCRIPTS = include('client/story_scripts')
local inventory = include( "sim/inventory" )
local itemdefs = include("sim/unitdefs/itemdefs")
local escape_mission = include( "sim/missions/escape_mission" )
local worldgen = include( "sim/worldgen" )--------------------------------------------------------------------------------
-- Mole Insertion
--
-- Escort a mole to the personnel database.
-- Until the mole has assumed his identity (custom disguise), don't let him be seen. Then, mole must be escorted to a special exit
-- Witnesses (guards, drones, cameras) get WITNESS tooltip/tag
-- Guard and drone witnesses need their HUD wiped manually or killed.
-- Cameras and sighted drone witnesses need to be wiped at the Camera Database or destroyed
-- Guard witnesses can be killed or KO'd and injected with an AMNESIAC that scrambles their memory  (slow and confused when wake up)
-- Mission reward: intel bonuses for future  missions
-- benefit: reveal all doors?

-- Various todos:
-- Custom disguise unit -- scrapped?
-- Guarantee camera database spawns DONE
-- setAlerted hack DONE
-- code amnesiac (append of doInjection) DONE
-- make amnesiac itemdef DONE
-- code mission rewards (persistent daemon) DONE
-- database hijacking ability DONE
-- database propdef DONE
-- mole agentdef: DONE
-- mole spawn on mission entry DONE
-- redo witness system to only apply to informant DONE
-- ability: scrub camera db DONE
-- ability: escape for mole (guard elevator) DONE
-- add various HUD instructions for objectives and witnesses DONE?
-- finder's fee for informant: scrapped
-- Central comments: Mole escaped, mole dead
-- Central judgement

-- TAGS:
-- personneldb_door  - just outside security door, add HUD instruction pointing to here when seen
-- personneldb_nearby: door cell and connected public terminal prop cells, speech line like 'the servers we want should be near thos eterminals -- unused, doesn't feel necessary
--------------------------------------------------------------------------------

-- Mission definition

local mission = class( escape_mission )

-- Local helpers
local MOLE_BONUS_FULL = 3		--how many missions you get the bonus if no witnesses
local MOLE_BONUS_PARTIAL = 1	--how many missions you get the bonus if witnesses
local PATROLS_REVEALED = 0.75	--which % of guards is revealed by that bonus

local function queueCentral(script, scripts) --really informative huh
	for k, v in pairs(scripts) do
		script:queue( { script=v, type="newOperatorMessage" } )
		script:queue(0.5*cdefs.SECONDS)
	end	
end


local STARTED_DBHACK = 
{
	trigger = "mole_DB_hack_start",
}


local FINISHED_DBHACK =
{
	trigger = "mole_DB_hack_end",
}

local ALARM_CHANGE = 
{
	trigger = simdefs.TRG_ALARM_STATE_CHANGE,
}

local MOLE_ESCAPED_AGENT =  --we don't actually want this because it means mission failure, but the option should be there -- maybe reward should be adding another mole mission to the map? DONE
{
    trigger = simdefs.TRG_UNIT_ESCAPED,
	fn = function( sim, triggerData )

		local unit = triggerData
        if unit and unit:getTraits().MM_mole then
            return true -- note that unit has escaped so it is DESPAWNED and not actually valid.
        end
	end,
}

local MOLE_DEAD =
{
	trigger = simdefs.TRG_UNIT_KILLED,
	fn = function( sim, triggerData )
		if triggerData.unit:getTraits().MM_mole then
			return triggerData.unit
		end
	end,
}

local MOLE_ESCAPED_GUARD_ELEVATOR = 
{
    trigger = "mole_final_escape",
}

local MADE_AGENT_CONNECTION = 
{
	trigger = "agentConnectionDone"
}	

local PC_SAW_GUARD_EXIT = 
	{
		trigger = simdefs.TRG_LOS_REFRESH,
		fn = function( sim, evData )
			local seer =  evData.seer 
			if not seer or not seer:isPC() then
				return false
			end

			for i = 1, #evData.cells, 2 do
				local cell = sim:getCell(evData.cells[i],evData.cells[i+1])

				if cell then
					for i, exit in pairs(cell.exits) do
						if exit.keybits and (exit.keybits == simdefs.DOOR_KEYS.GUARD) then
							return cell
						end
					end
				end
			end

			return false
		end,
	}

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

		if evData.unit:hasTag("MM_mole") then
			return evData.unit, seer
		else
			return false
		end
	end,
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

		if evData.unit:hasTag("MM_mole") then
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
	trigger = "vip_escaped",
	fn = function( sim, triggerData )
		if triggerData.unit:getTraits().witness then
			return triggerData.unit
		end
	end,
}

local witnessEscaped = function( script, sim )
	local _, witness = script:waitFor( WITNESS_ESCAPED )
	-- sim:getTags().MM_escapedWitness = true --this is set in npc_abilities by the UI daemon! just putting this here for reference
	if sim:getNPC():hasMainframeAbility("MM_informant_witness") then
		local scripts = SCRIPTS.INGAME.MOLE_INSERTION.WITNESS_FLED_LEVEL_RETRY -- if mole hasn't escaped yet, have Central suggest you abort the mission
		if sim:getTags().MM_informant_success then -- mole already escaped through guard exit
			scripts = SCRIPTS.INGAME.MOLE_INSERTION.WITNESS_FLED_LEVEL
		end
		script:waitFor( util.extend( mission_util.PC_START_TURN ){ priority = -1 } )
		script:queue( 2*cdefs.SECONDS )
		queueCentral( script, scripts )
	end
end	
			
mission.existsLivingWitness = function(sim)
	--Guard or drone or camera that has directly seen the mole
	if sim:getTags().MM_escapedWitness then --set in mole UI daemon ability
		if sim:hasObjective("kill_witness") then
			sim:removeObjective("kill_witness")
			sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.OBJ_KILL_WITNESS_FAILED, "kill_witness_failed" )
		end
		return true
	end
	for unitID, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().witness and not unit:isDead() then
			return true
		end
	end
	return false
end

local function moleOnLevel( sim )
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().MM_mole then
			return true
		end
	end
	return false
end

-- this could be cleaned up into one function but whatever
local function guardWitnessesAgent(script, sim)
	_, agent, seer = script:waitFor( GUARD_SAW_MOLE )
	
	-- Add a new instance of the hook, since it's possible that multiple guards saw the agent at the same time
	script:addHook( guardWitnessesAgent )
	
	script:waitFor( { trigger = simdefs.TRG_OVERWATCH } )
	
	if seer:isValid() and not seer:isKO() and not seer:getTraits().witness then
		seer:getTraits().witness = true
		local x0, y0 = seer:getLocation()
		script:queue( { type="pan", x=x0, y=y0, zoom=0.27 } )
		
		if seer:getTraits().isDrone then
			if not sim:getTags().Monster_dronecomment then
				sim:getTags().Monster_dronecomment = true
				local scripts = SCRIPTS.INGAME.MOLE_INSERTION.MOLE_SEEN_BY_DRONE
				script:queue( 2 * cdefs.SECONDS )
				queueCentral( script, scripts )
				
			end
		else
			if not sim:getTags().Central_guardcomment then
				sim:getTags().Central_guardcomment = true
				local scripts = SCRIPTS.INGAME.MOLE_INSERTION.MOLE_SEEN_BY_GUARD
				script:queue( 2 * cdefs.SECONDS )
				queueCentral( script, scripts )
			end
		end
		
		-- if seer:getTraits().isDrone then
			-- seer:createTab( STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.WITNESS_DETECTED, "WITNESS" )
		-- end

		if not sim:hasObjective( "kill_witness" ) then
			sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.OBJ_KILL_WITNESS, "kill_witness" )
		end
	end
end

local function cameraWitnessesAgent(script, sim)
	while true do
		_, agent, seer = script:waitFor( CAMERA_SAW_MOLE )
		seer:getTraits().witness = true
		local x0, y0 = seer:getLocation()
		script:queue( { type="pan", x=x0, y=y0, zoom=0.27 } )
		if not sim:getTags().Monster_cameracomment then
		-- log:write("LOG central reaction to camera")
			sim:getTags().Monster_cameracomment = true
			local scripts = SCRIPTS.INGAME.MOLE_INSERTION.MOLE_SEEN_BY_CAMERA
			script:queue( 2 * cdefs.SECONDS )
			queueCentral( script, scripts )
		end
		seer:createTab( STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.WITNESS_DETECTED, "" ) -- keep this for now even though it's inconsistent with the lack of tab on moving witnesses

		if not sim:hasObjective( "kill_witness" ) then
			sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.OBJ_KILL_WITNESS, "kill_witness" )
		end
	end
end

local function witnessDied(script, sim, mission)
	while true do
		_, witness = script:waitFor( WITNESS_DEAD )

		if not mission.existsLivingWitness(sim) and not moleOnLevel(sim) then
			sim:removeObjective( "kill_witness" )
			sim:getNPC():removeAbility(sim, "MM_informant_witness") --despawn the UI "daemon"
		end
	end
end

local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


local function spawnMole( script, sim )
	script:waitFor( MADE_AGENT_CONNECTION )
	script:queue( 3*cdefs.SECONDS )
	-- CENTRAL REACTION?
	
	local agent_cells = {}
	for i, agent in pairs(sim:getPC():getUnits()) do
		local cell = sim:getCell(agent:getLocation())
		table.insert(agent_cells, cell)
	end

	local adjacent_cells = {}
	for i, cell in ipairs(agent_cells) do
		for dir, exit in pairs(cell.exits) do
			if not (tablelength(exit.cell.units) > 0) and exit.cell.impass == 0  and not exit.closed and not simquery.isCellWatched(sim, sim:getPC(), cell.x, cell.y) then
				table.insert(adjacent_cells, exit.cell)
			end
		end
	end
				
	local spawn_cell = adjacent_cells[sim:nextRand(1, #adjacent_cells)]
	local unitData = unitdefs.lookupTemplate("MM_mole")
	if sim:nextRand() < 0.5 then
		unitData = unitdefs.lookupTemplate("MM_mole2") --alt skin
	end
	local newUnit = simfactory.createUnit( unitData, sim )
	assert(newUnit)
	local player = sim:getPC()
	newUnit:setPlayerOwner(player)
	sim:spawnUnit( newUnit )	
	sim:warpUnit( newUnit, spawn_cell )
	sim:dispatchEvent( simdefs.EV_TELEPORT, { units={newUnit}, warpOut =false } )
	sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = newUnit } )
	
	--banter
	local newOperative = newUnit
	local anim = newOperative:getUnitData().profile_anim
	local build = newOperative:getUnitData().profile_anim
	if newOperative:getUnitData().profile_build then
		build = newOperative:getUnitData().profile_build
	end
	script:queue( {
		body=STRINGS.MOREMISSIONS.AGENT_LINES.MOLE_INSERTION.MOLE_MISSION_START,
		header=tostring(newOperative:getUnitData().name),
		type="enemyMessage",
		profileAnim= anim,
		profileBuild= build,
		} )
	script:queue( 5*cdefs.SECONDS )

	script:queue( { type="clearEnemyMessage" } )
	-- how will this interact with banters?
end

local function progressDBhack(sim, database, hacker, script)
	database:getTraits().MMprogress = database:getTraits().MMprogress + 1
	if database:getSounds().stageAdvance then
		local x1,y1 = database:getLocation()
		database:getSim():dispatchEvent( simdefs.EV_PLAY_SOUND, {sound=database:getSounds().stageAdvance , x=x1,y=y1} )	
	end
	-- database:getSim():dispatchEvent(simdefs.EV_UNIT_SWTICH_FX,{unit=database,transition=true})
	
	sim:triggerEvent( "mole_DB_hack", {unit=database} )
	if database:getTraits().MMprogress == database:getTraits().MMprogressMax then
		sim:getTags().finished_DB_hack = true
		local x, y = hacker:getLocation()
		script:queue( { type="pan", x=x, y=y, zoom=0.27 } )
		script:queue( 1 * cdefs.SECONDS )
		sim:triggerEvent( "databank_hack_end", {unit=database, hacker=hacker} )
		hacker:getTraits().monster_hacking = nil
		hacker:getSounds().spot = nil
		sim:dispatchEvent( simdefs.EV_UNIT_TINKER_END, { unit = hacker } ) 	
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = hacker })
		database:getTraits().MMprogress = nil		
		-- database:getTraits().mainframe_status = "off"
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = database })
		sim:removeObjective( "hack_personnel_DB" )
		sim:triggerEvent( "mole_DB_hack_end")
		-- hacker:removeAbility(sim, "escape")
	end
end

local function activateCamera(script, sim)
	for i, cameraUnit in pairs(sim:getAllUnits()) do
		if cameraUnit:hasTag("MM_personneldb_camera") and cameraUnit:getTraits().mainframe_status =="off" and
        not cameraUnit:getTraits().mainframe_booting and not cameraUnit:getTraits().dead then
			cameraUnit:getTraits().mainframe_camera = true
			cameraUnit:getTraits().mainframe_status_old = "active"
			cameraUnit:getTraits().mainframe_booting = 1
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = cameraUnit } )
			local x0, y0 = cameraUnit:getLocation()
			cameraUnit:createTab( STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_DROIDS_WARNING,STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_DROIDS_WARNING_SUB ) 
			script:queue( { type="pan", x=x0, y=y0, zoom=0.25 } )
			script:waitFor( util.extend( mission_util.NPC_START_TURN ){ priority = -1 } )
			cameraUnit:destroyTab()
		end
	end
end

local function DBhack( script, sim )
	local mole = nil
	local progress = 0
	while sim:hasObjective("hack_personnel_DB") do
		script:waitFor( util.extend( mission_util.PC_START_TURN ){ priority = -1 } )
		script:queue( .5*cdefs.SECONDS )
			
		local pcplayer = sim:getPC()
		for i, agent in pairs( pcplayer:getUnits() ) do 
			if agent:getTraits().monster_hacking and agent:getTraits().MM_mole then
				mole = agent
				-- if progress > 0 then
					local x2,y2 = mole:getLocation()
					sim:getNPC():spawnInterest(x2,y2, simdefs.SENSE_RADIO, simdefs.REASON_ALARMEDSAFE, mole) --keep spawning interest for duration of hack
				-- end		
				local database = sim:getUnit(agent:getTraits().monster_hacking)
				progressDBhack(sim, database, mole, script)
				sim:incrementTimedObjective( "hack_personnel_DB" )
				progress = progress + 1
				if progress == 3 then
					activateCamera(script, sim)
				end
			end 
		end 	
			
	end
end
	
local function moleEscaped( script, sim)
	--mole has escaped via agent elevator, so objectives cannot be completed anymore
	script:waitFor( MOLE_ESCAPED_AGENT )
	sim:removeObjective("hack_personnel_DB")
	sim:removeObjective("findDB")
	sim:removeObjective("mole_escape")
	sim:removeObjective("kill_witness")
	sim:getTags().MM_mole_escaped = true
	-- log:write("LOG mole escaped through agent elevator")
	local scripts = SCRIPTS.INGAME.MOLE_INSERTION.MOLE_ESCAPED_TO_JET
	queueCentral( script, scripts )
	
	sim:addNewLocation( {sim:getParams().world, "mole_insertion"} )
end	

mission.bonus_types = {
	[1] = "layout",
	[2] = "patrols",
	[3] = "consoles",
	[4] = "safes",
	[5] = "cameras",
	[6] = "daemons",	
	[7] = "doors",
	[8] = "exit",
}

mission.revealMoleBonus = function(sim, bonusType) --need to call on this from modinit
	local unitlist = {} --collect units to be revealed for relevant bonuses
	local randomAgent = sim:getPC():getUnits()[sim:nextRand(1,#sim:getPC():getUnits())] --it's turn 1 so just pick any agent so we have somewhere to display the float text
	local x0, y0 = randomAgent:getLocation()
	local currentPlayer = sim:getPC()
	local script = sim:getLevelScript()
	
	if bonusType == "layout" then
		sim._showOutline = true
		sim:dispatchEvent( simdefs.EV_WALL_REFRESH )
		if x0 and y0 then
			local color = {r=1,g=1,b=41/255,a=1}
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.UI.FLY_TXT.FACILITY_REVEALED,x=x0,y=y0,color=color,alwaysShow=true} )		
		end
	elseif bonusType == "patrols" then
		local total_guards = 0
		for _, unit in pairs(sim:getAllUnits() ) do
			if (unit:getPlayerOwner() ~= currentPlayer) and unit:getTraits().isGuard then
				total_guards = total_guards + 1
			end
		end
		local to_tag = math.floor(PATROLS_REVEALED * total_guards)
		local tagged_guards = 0
		for _, unit in pairs( sim:getAllUnits() ) do 
			-- if sim:nextRand() <= (PATROLS_REVEALED or 0.75) then --don't tag all the guards, just most of them
			if tagged_guards < to_tag then
				if unit:getPlayerOwner() ~= currentPlayer and unit:getTraits().isGuard and not unit:getTraits().tagged then 										
					unit:setTagged() -- need to consider PE's hostile AI interaction..
					sim:dispatchEvent( simdefs.EV_UNIT_TAGGED, {unit = unit} )
					sim:getPC():glimpseUnit(sim, unit:getID())
					tagged_guards = tagged_guards + 1
					-- tag + glimpse may be OP... maybe just tag... keep uncertainty about which guards are on the level...
				end
			end
		end	
	elseif bonusType == "consoles" then
		sim:forEachUnit(
			function ( u )
				if u:getTraits().mainframe_console ~= nil then
					table.insert(unitlist,u:getID())		
					currentPlayer:glimpseUnit( sim, u:getID() )				
				end
			end )
		
	elseif bonusType == "safes" then
		sim:forEachUnit(
			function ( u )
				if u:getTraits().safeUnit ~= nil then
					table.insert(unitlist,u:getID())		
					currentPlayer:glimpseUnit( sim, u:getID() )				
				end
			end )	
	elseif bonusType == "cameras" then --also turrets
		sim:forEachUnit(
			function ( u )
				if (u:getTraits().mainframe_camera ~= nil) or (u:getTraits().mainframe_turret ~= nil) then
					table.insert(unitlist,u:getID())		
					currentPlayer:glimpseUnit( sim, u:getID() )				
				end
			end )	
	elseif bonusType == "daemons" then
			sim:forEachUnit(
			function ( u )
				if u:getTraits().mainframe_program ~= nil then
					u:getTraits().daemon_sniffed = true 
				end
			end )
	elseif bonusType == "doors" then
			sim:forEachCell(
			function ( cell )
				for dir, exit in pairs( cell.exits ) do
					if (simquery.isDoorExit(exit)) and not cell.exitID and not (exit.keybits == simdefs.DOOR_KEYS.GUARD) and not (exit.keybits == simdefs.DOOR_KEYS.ELEVATOR) then -- deliberately exempt exits, make that a separate bonus
						sim:getPC():glimpseCell(sim, cell)
					end
				end
			end )
			if x0 and y0 then
				local color = {r=1,g=1,b=41/255,a=1}
				sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.MOREMISSIONS.UI.DOORS_REVEALED,x=x0,y=y0,color=color,alwaysShow=true} )		
			end	
			sim:dispatchEvent( simdefs.EV_WALL_REFRESH )
	elseif bonusType == "exit" then
			local exit_procGen = nil
			sim:forEachCell(
			function ( cell )
				if cell.exitID then
					exit_procGen = cell.procgenRoom
				end
			end )
			sim:forEachCell(
			function ( cell )
				if exit_procGen and (cell.procgenRoom == exit_procGen) then
					sim:getPC():glimpseCell(sim, cell)
					if cell.units then
						for i, unit in pairs(cell.units) do
							sim:getPC():glimpseUnit( sim, unit:getID() )
						end
					end
				end
			end )
			if x0 and y0 then
				local color = {r=1,g=1,b=41/255,a=1}
				sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.MOREMISSIONS.UI.EXIT_REVEALED,x=x0,y=y0,color=color,alwaysShow=true} )		
			end		
			sim:dispatchEvent( simdefs.EV_WALL_REFRESH )
	end
	if #unitlist > 0 then --for any bonuses that reveal units
		sim:dispatchEvent( simdefs.EV_UNIT_MAINFRAME_UPDATE, {units=unitlist,reveal = true} )
	end
end

-- local function cameraSawMole( script, sim )
-- GUARD_SAW_MOLE
-- return evData.unit, seer

-- end

-- local function guardSawMole( script, sim ) --Central reaction for the first time this happens
	-- CAMERA_SAW_MOLE
	-- return evData.unit, seer
-- end

local function moleDied( script, sim )
	script:waitFor( MOLE_DEAD )
	sim:removeObjective("hack_personnel_DB")
	sim:removeObjective("findDB")
	sim:removeObjective("mole_escape")	
	sim:removeObjective("kill_witness")
	sim:getTags().MM_mole_died = true
	sim:getNPC():removeAbility(sim, "MM_informant_witness")
	-- log:write("LOG mole died")
	local scripts = SCRIPTS.INGAME.MOLE_INSERTION.MOLE_DIED[sim:nextRand(1,#SCRIPTS.INGAME.MOLE_INSERTION.MOLE_DIED)]
	queueCentral( script, scripts )
end

local function seeGuardExit( script, sim )
	local _, cell = script:waitFor( PC_SAW_GUARD_EXIT )
	script:queue( { type="pan", x=cell.x, y=cell.y, zoom=0.27 } )
	script:queue( 1 * cdefs.SECONDS )
	local scripts = SCRIPTS.INGAME.MOLE_INSERTION.SEE_GUARD_EXIT
	queueCentral( script, scripts )
end

-- local function followWitness( script, sim )
	-- -- local guardUnit = nil
	-- sim:forEachUnit(
	-- function(unit)
		-- if unit:getTraits().witness then 
			-- -- guardUnit = unit
			-- local x, y = unit:getLocation()
			-- script:queue( { type="displayHUDInstruction", text=STRINGS.MISSIONS.UTIL.HEAT_SIGNATURE_DETECTED, x=x, y=y } )
			-- -- script:queue( { type="pan", x=x, y=y } )
		-- end
	-- end)

	-- while true do 
		-- local ev, triggerData = script:waitFor( mission_util.UNIT_WARP )
		-- if triggerData.unit:getTraits().witness then
			-- script:queue( { type="hideHUDInstruction" } ) 
			-- local x, y = triggerData.unit:getLocation()
            -- if x and y then
			    -- script:queue( { type="displayHUDInstruction", text=STRINGS.MISSIONS.UTIL.HEAT_SIGNATURE_DETECTED, x=x, y=y } )
			    -- -- script:queue( { type="pan", x=x, y=y } )
            -- end
		-- end 
	-- end
-- end
local function sawCameraDB( script, sim, mission )

	local _, cameraDB = script:waitFor( mission_util.SAW_SPECIAL_TAG(script, "MM_camera_core", STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.CAMERADB, STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.CAMERADB_TIP ) )

	local scripts = SCRIPTS.INGAME.MOLE_INSERTION.SEE_CAMERADB
	queueCentral( script, scripts )
	
	script:waitFor( MOLE_ESCAPED_GUARD_ELEVATOR )

	if not mission.existsLivingWitness(sim) then
		cameraDB:destroyTab()
	end
end

local function investigateMole( script, sim )
	while true do
		script:waitFor( ALARM_CHANGE )
		local mole
		for i, agent in pairs(sim:getPC():getUnits()) do
			if agent:getTraits().MM_mole then
				mole = agent
			end
		end
		if mole then
			local x0, y0 = mole:getLocation()
			sim:dispatchEvent( simdefs.EV_SHOW_DIALOG, { dialog = "locationDetectedDialog", dialogParams = { mole }} )
			sim:getNPC():spawnInterest(x0,y0, simdefs.SENSE_RADIO, simdefs.REASON_ALARMEDSAFE, mole)
		end
	end
end

local function moleMission( script, sim )

	local a, cell = script:waitFor( mission_util.PC_SAW_CELL_WITH_TAG(script, "personneldb_door" ) )
	script:queue( { type="pan", x=cell.x, y=cell.y, zoom=0.27 } )
	-- log:write("PC saw door")
	script:queue( 1*cdefs.SECONDS )
	local scripts = SCRIPTS.INGAME.MOLE_INSERTION.SEE_OBJECTIVE_DOOR
	queueCentral( script, scripts)
	
	local _, hackConsole = script:waitFor( mission_util.SAW_SPECIAL_TAG(script, "personneldb", STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.PERSONNEL_DB, STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.HACK_WITH_MOLE ) )
	local x0, y0 = hackConsole:getLocation()
	script:queue( { type="pan", x=x0, y=y0, zoom=0.27 } )
	script:queue( 1*cdefs.SECONDS )
	scripts = SCRIPTS.INGAME.MOLE_INSERTION.SEE_OBJECTIVE_DB
	queueCentral( script, scripts )
	sim:removeObjective( "findDB" )
	-- log:write("LOG pc saw db")
	
	sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.HACK_DB, "hack_personnel_DB", 5 )
	script:waitFor( STARTED_DBHACK )
	script:addHook( DBhack )
	script:waitFor( FINISHED_DBHACK )
	hackConsole:destroyTab()
	sim:getTags().MM_DBhack_finished = true	
	sim.exit_warning = STRINGS.MOREMISSIONS.UI.MOLE_EXIT_WARNING2
	--display HUD on guard elevators
	
	sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.ESCAPE, "mole_escape" ) -- mole escapes through guard elevator
	scripts = SCRIPTS.INGAME.MOLE_INSERTION.FINISHED_DB_HACK
	script:queue( 1*cdefs.SECONDS )
	queueCentral( script, scripts )
	
	script:addHook( investigateMole )
	script:addHook( seeGuardExit )
	script:waitFor( MOLE_ESCAPED_GUARD_ELEVATOR )	
	sim:getTags().MM_informant_success = true --successfully planted mole
	sim:removeObjective("mole_escape")
	
	local scripts = SCRIPTS.INGAME.MOLE_INSERTION.MOLE_ESCAPED_WITNESSES
	
	if not mission.existsLivingWitness(sim) and not moleOnLevel(sim) then
		sim:removeObjective( "kill_witness" )
		sim:getNPC():removeAbility(sim, "MM_informant_witness") --despawn the UI "daemon"
		scripts = SCRIPTS.INGAME.MOLE_INSERTION.MOLE_ESCAPED_NOWITNESSES
	end	
	sim.TA_mission_success = true --flag for Talkative Agents
	sim.exit_warning = nil
	
	queueCentral(script, scripts)
	
end

local function findCell( sim, tag )
	local cells = sim:getCells( tag )
	return cells and cells[1]
end

local function spawnEliteGuard( sim ) --spawns a high-tier stationary guard at the door to the database room, also initially deactivates the camera
	for i, cameraUnit in pairs(sim:getAllUnits()) do
		if cameraUnit:getTraits().mainframe_camera and cameraUnit:hasTag("MM_personneldb_camera") then
			cameraUnit:getTraits().mainframe_camera = nil --prevents camera from being activated at alarm level 1
			cameraUnit:deactivate(sim)
			cameraUnit:getTraits().mainframe_status = "off"
		end
	end

	if not (sim:getParams().campaignDifficulty == simdefs.NORMAL_DIFFICULTY) then
	
		local templateName = "important_guard"
		local door_cell = findCell( sim, "personneldb_door" )
		local world = worldgen[sim:getParams().world:upper()]
		local list = world.THREAT_FIX or world.THREAT
		local wt = util.weighted_list( list )
		if list then
			templateName = wt:getChoice( sim:nextRand( 1, wt:getTotalWeight() ) )
		end
		local guardTemplate = unitdefs.lookupTemplate( templateName )
		local newGuard = simfactory.createUnit( guardTemplate, sim ) 
		sim:spawnUnit( newGuard )
		newGuard:setPlayerOwner( sim:getNPC() )
		newGuard:setPather(sim:getNPC().pather)
		newGuard:getTraits().nopatrol = true
		newGuard:getTraits().patrolPath = { { x = door_cell.x, y = door_cell.y } }
		newGuard:getTraits().mm_nopatrolchange = true
		
		local facing = 0
		-- make him face away from the door
		for dir, exit in pairs(door_cell.exits) do
			if simquery.isDoorExit(exit) then
				-- log:write("LOG setting facing")
				local x1, y1 = exit.cell.x, exit.cell.y
				facing = simquery.getDirectionFromDelta( door_cell.x - x1, door_cell.y - y1 )
			end
		end
		newGuard:setFacing(facing)
		sim:warpUnit( newGuard, door_cell )
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = newGuard } )
	end
end
----------------
local function despawnRedundantCameraDB(sim)
	local cameraDBs = {}
	for i,unit in pairs(sim:getAllUnits()) do
		if unit:getUnitData().id == "camera_core" then
			table.insert(cameraDBs, unit)
			unit:getTraits().MM_camera_core = true
			unit:getTraits().sightable = true --required for triggering on unit appeared
			unit:addTag("MM_camera_core")
			unit:giveAbility("MM_scrubcameradb") --ability that allows witness scrubbing
			local daemonList = sim:getIcePrograms()
			if daemonList:getCount() > 0 then
				unit:getTraits().mainframe_program = daemonList:getChoice( sim:nextRand( 1, daemonList:getTotalWeight() )) --make it fun y'know?
			end
		end
	end
	if #cameraDBs > 1 then
		sim:warpUnit( cameraDBs[2], nil )
		sim:despawnUnit( cameraDBs[2] )
	end
end
--------------------------------------------------------------------------------

function mission:init( scriptMgr, sim )
	sim:getTags().skipBanter = true
	despawnRedundantCameraDB(sim)
	escape_mission.init( self, scriptMgr, sim )
	spawnEliteGuard( sim )
	sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.FIND_DB, "findDB" ) 
	
	sim:getTags().MM_informantMission = true -- for DoFinishMission
	sim.MM_mole_duration_full = MOLE_BONUS_FULL
	sim.MM_mole_duration_partial = MOLE_BONUS_PARTIAL
	--Eyewitnesses that directly see agents
	sim.exit_warning = STRINGS.MOREMISSIONS.UI.MOLE_EXIT_WARNING
	scriptMgr:addHook( "guardWitnessesAgent", guardWitnessesAgent)
	scriptMgr:addHook( "cameraWitnessesAgent", cameraWitnessesAgent )
	scriptMgr:addHook( "witnessDied", witnessDied, nil, self)
	scriptMgr:addHook( "moleMission", moleMission )
	scriptMgr:addHook( "moleDied", moleDied )
	scriptMgr:addHook( "spawnMole", spawnMole )
	scriptMgr:addHook( "moleEscaped", moleEscaped )
	scriptMgr:addHook( "sawCameraDB", sawCameraDB, nil, self)
	scriptMgr:addHook( "witnessEscaped", witnessEscaped )
	sim:getNPC():addMainframeAbility( sim, "MM_informant_witness", nil, 0 )
	
    --This picks a reaction rant from Central on exit based upon whether or not an agent has escaped with the loot yet.
    local scriptfn = function()
		local scripts = SCRIPTS.INGAME.MOLE_INSERTION.CENTRAL_JUDGEMENT.WIN_NO_WITNESSES
		if sim:getTags().MM_mole_escaped then
			scripts = SCRIPTS.INGAME.MOLE_INSERTION.CENTRAL_JUDGEMENT.MOLE_JET_ESCAPE
		end
		if sim:getTags().MM_informant_success and mission.existsLivingWitness(sim) then
			scripts = SCRIPTS.INGAME.MOLE_INSERTION.CENTRAL_JUDGEMENT.WIN_WITH_WITNESSES
		end
		if sim:getTags().MM_mole_died then
			scripts = SCRIPTS.INGAME.MOLE_INSERTION.CENTRAL_JUDGEMENT.MOLE_DIED
		end
			
        local scr = scripts[sim:nextRand(1, #scripts)]
        return scr
    end
    scriptMgr:addHook( "FINAL", mission_util.CreateCentralReaction(scriptfn))		
	
end

local function moleFitness( cxt, prefab, x, y )
    local tileCount = cxt:calculatePrefabLinkage( prefab, x, y )
    if tileCount == 0 then
        return 0 -- Doesn't link up
    end

    local maxDist = mission_util.calculatePrefabDistance( cxt, x, y, "moleinsertion" )
    return tileCount + maxDist^2
end

function mission.pregeneratePrefabs( cxt, tagSet )
    escape_mission.pregeneratePrefabs( cxt, tagSet )
    table.insert( tagSet[1], "moleinsertion" )
end

function mission.generatePrefabs( cxt, candidates )
    local prefabs = include( "sim/prefabs" )  
	cxt.defaultFitnessFn = cxt.defaultFitnessFn or {}
	cxt.defaultFitnessSelect = cxt.defaultFitnessSelect or {}
	cxt.maxCountOverride = cxt.maxCountOverride or {}
	cxt.defaultFitnessFn["entry_guard"] = moleFitness
	cxt.defaultFitnessSelect["entry_guard"] = prefabs.SELECT_HIGHEST
	cxt.maxCountOverride["entry_guard"] = 1	
	escape_mission.generatePrefabs( cxt, candidates )
	prefabs.generatePrefabs( cxt, candidates, "MM_cameradb", 1 ) --force-spawn a camera db, then later despawn any redundant one
	-- log:write("LOG spawning cameradb")
end

return mission
