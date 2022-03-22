local array = include( "modules/array" )
local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local simfactory = include( "sim/simfactory" )
local mission_util = include( "sim/missions/mission_util" )
local escape_mission = include( "sim/missions/escape_mission" )
local unitdefs = include( "sim/unitdefs" )
local itemdefs = include( "sim/unitdefs/itemdefs" )
local SCRIPTS = include('client/story_scripts')
local level = include( "sim/level" )
local astar = include ("modules/astar" )
local astar_handlers = include("sim/astar_handlers")

---------------------------------------------------------------------------------------------
-- Local helpers

-- Design summary:
-- Agent/operative escape begins on turn 1. Alarm level rises at the usual+1 rate for this entire level!
--Turn 2: Investigation point on operative's original spawn point from nearby guard.
--Agent's non-augment inventory is emptied and deposited into a random safe on the map, but they start with a custom disrupter.
--If no safe available, their stuff stays on them.
-- -Hek

local function findClosestUnitByPath( units, x0, y0, fn ) --edit of vanilla fn to reflect path length rather than absolute distance on grid
	local closestRange = math.huge
	local closestUnit = nil
	for i,unit in pairs(units) do
		if fn == nil or fn( unit ) then
			local x1, y1 = unit:getLocation()
			if x1 then
				local sim = unit:getSim()
				local start_cell = sim:getCell(x0, y0)
				local end_cell = sim:getCell(unit:getLocation())
				local pather = astar.AStar:new(astar_handlers.aihandler:new(unit) )
				local path = pather:findPath( start_cell, end_cell )
				if path then
					local range = path:getTotalMoveCost()
					if range < closestRange then
						closestRange = range
						closestUnit = unit
					end
				end
			end
		end
	end

	return closestUnit, math.sqrt( closestRange )
end

local OPERATIVE_ESCAPED =
{
	trigger = simdefs.TRG_UNIT_ESCAPED,
	fn = function( sim, triggerUnit )
		if triggerUnit and triggerUnit:hasTag("escapedAgent") then
		--log:write("LOG trg unit escaped")
			return triggerUnit
		end
	end,
}

local OPERATIVE_DESPAWNED =
{
	trigger = simdefs.TRG_UNIT_WARP,
	fn = function( sim, triggerData )
		if triggerData.unit and triggerData.unit:hasTag("escapedAgent") and not triggerData.to_cell then --on despawn (and not just escaping). Permadeath or NCT or...
			--log:write("LOG escapedAgent despawned")
			return triggerData
		end
	end
}
-- This is the chance that an agent will load in the detention centre.  If not, a hostage
-- will be placed there.
local CHANCE_OF_AGENT_IN_DETENTION = 0.5 --make customisable param?


--[[
local ALARM_INCREASE =
{
	trigger = simdefs.TRG_ALARM_INCREASE,
	fn = function( sim, evData )
		return true
	end,
}
]]

local AGENT_CONNECTION =
{
	trigger = "agentConnectionDone", --custom 'hook' in makeAgentConnection append in modinit
	fn = function( sim, evData )
		return true
	end,
}

local GEAR_SAFE_LOOTED =
{
	trigger = simdefs.TRG_SAFE_LOOTED,
	fn = function( sim, triggerData )
		if triggerData.targetUnit and triggerData.targetUnit:hasTag("agent_gear_storage") then
			-- log:write("LOg safe looted1")
			return triggerData.targetUnit
		end
	end,
}

local function findCell( sim, tag )
	local cells = sim:getCells( tag )
	return cells and cells[1]
end

local function make_gear( sim, newUnit, agentTemplate )

	-- Comparable vanilla rewards: (scaling @E/E+ = 0.75-1.3  @E++ = 0.5-0.875)
	-- * Detention Centre (prisoner): 800*scaling (reward)
	-- * Security Dispatch: 150*scaling ("safe") + item of floor weight 3+
	--   * item value (vanilla+DLC): mean=1030, min=600, max=1500
	-- * CFO: 450*scaling (CFO) + vault_passcard
	--
	-- Distress Call (Lien): 800*scaling (reward) + 80*scaling (guard) + vault_passcard (500) + 1 of these
	-- * 300-600cr, other than the non-purchaseable prototype drive
	-- * mean=420
	local template_list = serverdefs.MM_DISTRESS_CALL_ITEMS
	local new_items = {}
	local captured_items = {} --separate table for these as they're already spawned
	if newUnit:getUnitData().agentID then

		local items = newUnit:getChildren() or {}
			for i = #items, 1, -1 do
				if not items[i]:getTraits().installed then
					-- table.remove(items,i) --this will empty their inventory even if they would normally have it at detention centers
					if items[i] then
						if newUnit:getTraits().MM_captureTime then
							-- log:write("LOG MM_captureTime")
							if items[i]:getTraits().equipped then 
								items[i]:getTraits().equipped = false
							end
							table.insert(captured_items, items[i])
							newUnit:removeChild( items[i] )
						else
							newUnit:removeChild( items[i] )
							--sim:despawnUnit( items[i] )
						end
					end
				end
			end
			if agentTemplate and not newUnit:getTraits().MM_captureTime then
				for k,v in pairs(agentTemplate.upgrades) do
					local itemdef = unitdefs.lookupTemplate( v )
					if itemdef.traits.installed == nil then
						table.insert(new_items, v)
					end
				end
			end

	else --random useful junk if it's not an agent
		-- table.insert(new_items,"item_corpIntel")
		table.insert(new_items,"vault_passcard")
		table.insert(new_items, template_list[sim:nextRand(1,#template_list)])
	end

	items_output = {}
	
	if newUnit:getTraits().MM_captureTime then
		for k, item in pairs(captured_items) do
			table.insert(items_output, item) --these already existed in the inventory and don't need to be spawned in
		end
	else
		for k,template in pairs(new_items) do
			local newItem = simfactory.createUnit( unitdefs.lookupTemplate( template ), sim )
			sim:spawnUnit( newItem )
			table.insert(items_output, newItem)
		end
	end

	return items_output

end

--[[
local function increaseAlarm(script, sim, mission)
	script:waitFor( ALARM_INCREASE )
	sim:trackerAdvance(1)
	script:addHook( increaseAlarm, true ) --this may be too harsh. may need generation option

end
]]

local function checkGuard( unit )
	return unit and unit:getTraits().isGuard and not unit:isKO() and not unit:getTraits().pacifist
end

local function makeGuardInvestigate( script, sim )
		local cell = findCell( sim, "distressSpawn")
		if cell then
			--script:queue( { type="pan", x=cell.x, y=cell.y } )
			local guard = findClosestUnitByPath( sim:getNPC():getUnits(), cell.x, cell.y, checkGuard )
			local agent = mission_util.findUnitByTag( sim, "escapedAgent" )
			if agent and guard and guard:getBrain() then
				guard:getBrain():getSenses():addInterest(cell.x, cell.y, simdefs.SENSE_RADIO, simdefs.REASON_HUNTING, agent)
				-- sim:processReactions()
				sim:setClimax(true)
			end
		end
end

local function getLostAgent( agency )
    -- Get the earliest captured agent from the list.
    local minCaptureTime, lostAgent = math.huge, nil
    for i, agentDef in ipairs(agency.unitDefsPotential) do
        if (agentDef.captureTime or math.huge) < minCaptureTime then
            minCaptureTime, lostAgent = agentDef.captureTime, agentDef
        end
    end

    return lostAgent
end

local function startAgentEscape( script, sim, mission )
	-- log:write("LOG starting agent escape")
	script:waitFor( AGENT_CONNECTION )

	--copypasted chunk from mission_detention_centre with some changes--
	local unit = mission_util.findUnitByTag( sim, "escapedAgent" )
    if unit == nil then
        return -- No prisoner to swap?!
    end

    unit:getTraits().detention = true

    local agency = sim:getParams().agency
    local agentDef = getLostAgent( agency )

    -- If there aren't any lost agents, pick one of the remaining potentials at random.
	if agentDef == nil and #agency.unitDefsPotential > 0 then

        if (sim:nextRand() < CHANCE_OF_AGENT_IN_DETENTION or sim:getParams().foundPrisoner == true ) or 
           (sim:getParams().campaignDifficulty == simdefs.NORMAL_DIFFICULTY and sim:getParams().agentsFound == 0) then		
    		local wt = util.weighted_list()
            for i, agentDef in ipairs(agency.unitDefsPotential) do
                wt:addChoice( agentDef, 1 )
            end
            agentDef = wt:removeChoice( sim:nextRand( 1, wt:getTotalWeight() ))
        end
    end

    if #sim:getPC():getAgents() >= simdefs.AGENT_LIMIT then
        agentDef = nil -- Maxxed out agents
    end

	local agentTemplate = nil

	local newOperative = nil

    if agentDef then --this whole bit could be streamlined but \o/ -Hek
		mission.agent_distressed = true
		local template = unitdefs.prop_templates.agent_capture
		local newUnit = simfactory.createUnit( template, sim )
		agentTemplate = unitdefs.lookupTemplate( agentDef.template )

		newUnit._unitData.kanim = agentTemplate.kanim
		newUnit:getTraits().template = agentDef.template
		newUnit:getTraits().rescueID = agentDef.id
		newUnit:setFacing( unit:getFacing() )
		newUnit:getTraits().rescued = true
        newUnit:getTraits().detention = true
		
		local cell = sim:getCell( unit:getLocation() )
        assert( cell )
		sim:spawnUnit( newUnit )
		sim:warpUnit( newUnit, cell )

		local facing = unit:getFacing()
		sim:warpUnit( unit, nil )
		sim:despawnUnit( unit )
        sim:getTags().hadAgent = agentDef.id

		newOperative = sim:getPC():hireUnit( sim, newUnit, cell, facing )
		newOperative:addTag("escapedAgent")
		newOperative:addTag("MM_distressCallAgent") --used by TA
		if agentDef.captureTime then
			newOperative:getTraits().MM_captureTime = true
		end

	else
		mission.operative_distressed = true
		local new_template = unitdefs.lookupTemplate( "MM_agent_009" )
		local newUnit = simfactory.createUnit(new_template, sim)
		-- newUnit._traits.template = new_template.template
		-- newUnit._unitData.kanim = new_template.kanim
		local facing = unit:getFacing()
		newUnit:getTraits().rescued = true
        newUnit:getTraits().detention = true
		newUnit:addTag("escapedAgent")
		newUnit:addTag("MM_distressCallAgent") --used by TA
		local cell = sim:getCell( unit:getLocation() )
        assert( cell )
		sim:warpUnit( unit, nil )
		sim:despawnUnit( unit )
		sim:spawnUnit( newUnit )
		newUnit:setPlayerOwner(sim:getPC()) --needs to be before warp or causes agentrig yield error
		sim:warpUnit( newUnit, cell, facing )
		newOperative = newUnit

	end
	
	if newOperative then
			
		local x0,y0 = newOperative:getLocation()
		local unit_cell = sim:getCell(x0, y0)
		local guardTemplate = unitdefs.lookupTemplate( "important_guard" )
		local newGuard = simfactory.createUnit( guardTemplate, sim ) --captain
		sim:spawnUnit( newGuard )
		newGuard:setPlayerOwner( sim:getNPC() )
		newGuard:setPather(sim:getNPC().pather)
		sim:warpUnit( newGuard, unit_cell )
		newGuard:setKO( sim, 3 )
		local item_passcard = simfactory.createUnit( unitdefs.lookupTemplate( "passcard" ), sim )  --this is less effort than fiddling with spyface to make sure the door to that room can never be locked...
		sim:spawnUnit( item_passcard )
		newGuard:addChild( item_passcard )
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = newOperative } )
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = newGuard } )


		local safeUnit
		local safes = {}
		--log:write("searching for safe")
		for k,unit in pairs(sim:getAllUnits()) do
			if unit:getTraits().safeUnit and not (unit:getUnitData().id == "guard_locker") then
				table.insert(safes,unit)
			end
		end
		if #safes > 0 then
			safeUnit = safes[sim:nextRand(1,#safes)]
			--log:write("found safe")
		end

		local gear = make_gear( sim, newOperative, agentTemplate ) --handles inventory wrangling & spawning

		if safeUnit then
			--log:write("putting stuff in safe")
			safeUnit:addTag("agent_gear_storage")

			if #gear > 0 then
				for k,item in pairs(gear) do
					safeUnit:addChild(item) --put in safe
				end
			end

			local tazer_template = "MM_item_tazer_old"
			if sim:getParams().difficulty >=10 then --will probably need tuning
				tazer_template = "MM_item_tazer_old_armour"
			end

			local newItem = simfactory.createUnit( unitdefs.lookupTemplate( tazer_template ), sim )

			newItem:getTraits().cooldown = newItem:getTraits().cooldownMax
			sim:spawnUnit( newItem )
			newOperative:addChild( newItem )

		else  --edge case for no safes on map: put all the stuff in the inventory, in which case they shouldn't need the taser
			log:write("populating agent inventory")
			if #gear > 0 then
				for k,item in pairs(gear) do
					newOperative:addChild(item) --put in agent inventory
				end
			end

		end
		script:queue(0.2*cdefs.SECONDS)
		sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/hostage/free_hostage" )
		script:queue(1*cdefs.SECONDS)
		script:queue( { type="pan", x=x0, y=y0, zoom=0.27 } )
		script:queue(2*cdefs.SECONDS) --without this Central's message gets "skipped" for some reason because of the agent stating oneliner still playing

		if (sim:getParams().difficultyOptions.MM_difficulty == nil ) or sim:getParams().difficultyOptions.MM_difficulty and (sim:getParams().difficultyOptions.MM_difficulty == "hard") then
			makeGuardInvestigate(script, sim)
		end
		
		local scripts = SCRIPTS.INGAME.DISTRESS_CALL.SAW_AGENT
		if not newOperative:getUnitData().agentID then
			scripts = SCRIPTS.INGAME.DISTRESS_CALL.SAW_OTHER
		end
		for k, v in pairs(scripts) do
			-- script:queue( { type="clearOperatorMessage" } )
			script:queue( { script=v, type="newOperatorMessage" } )
			script:queue(0.5*cdefs.SECONDS)
		end
		
		-- make objectives
		sim:addObjective( util.sformat(STRINGS.MOREMISSIONS.UI.DISTRESS_OBJECTIVE_SECONDARY,newOperative:getUnitData().name), "find_agent_gear" )	--get gear	
				
		local agent_id
		if newOperative:getUnitData().agentID then
			agent_id = newOperative:getUnitData().agentID
			-- sim:removeObjective( "rescue_agent" )
			sim:addObjective( string.format(STRINGS.MISSIONS.ESCAPE.OBJ_RESCUE_AGENT,newOperative:getUnitData().name), "rescue_agent" )
		else
			agent_id = "agent009"
			sim:addObjective( string.format(STRINGS.MISSIONS.ESCAPE.OBJ_RESCUE_AGENT,newOperative:getUnitData().name), "rescue_agent" )
		end
		
		-- custom oneliner from operative -----
		if STRINGS.MOREMISSIONS.AGENT_LINES.DISTRESS_CALL[agent_id] ~= nil then
			local anim = newOperative:getUnitData().profile_anim
			local build = newOperative:getUnitData().profile_anim
			if newOperative:getUnitData().profile_build then
				build = newOperative:getUnitData().profile_build
			end
			script:queue( {
				body=STRINGS.MOREMISSIONS.AGENT_LINES.DISTRESS_CALL[agent_id],
				header=tostring(newOperative:getUnitData().name),
				type="enemyMessage",
				profileAnim= anim,
				profileBuild= build,
				} )
			script:queue( 4*cdefs.SECONDS )

			script:queue( { type="clearEnemyMessage" } )
		end
		--------
		--script:addHook( increaseAlarm, true )
		sim.missionTrackerBoost = 1 --rest is in modinit.lua/init()

		script:waitFor( OPERATIVE_DESPAWNED )

	end
end

local function got_operative(script, sim, mission)
	script:waitFor( OPERATIVE_ESCAPED )

	if mission.agent_distressed then
		mission.agent_extracted = true
		sim.TA_mission_success = true -- flag for Talkative Agents
	else
		mission.operative_extracted = true
		sim:setMissionReward( simquery.scaleCredits( sim, 800 )) --keep this money reward unless we can think of something more exciting/original
		sim.TA_mission_success = true
	end
	sim:removeObjective( "rescue_agent" )

end

local function gearSafeReaction( script, sim, mission )

	local _, agent_gear_safe = script:waitFor( mission_util.SAW_SPECIAL_TAG(script, "agent_gear_storage", STRINGS.MOREMISSIONS.UI.DISTRESS_AGENT_GEAR_CONTAINER, STRINGS.MOREMISSIONS.UI.DISTRESS_AGENT_GEAR_CONTAINER_DESC ) )
	local x0, y0 = agent_gear_safe:getLocation()
	script:queue( { type="pan", x=x0, y=y0, zoom=0.27 } )

	script:queue( { script=SCRIPTS.INGAME.DISTRESS_CALL.SAW_GEAR_CONTAINER[1], type="newOperatorMessage" } )

	script:waitFor(GEAR_SAFE_LOOTED)
	--log:write("LOG safe looted!")
	sim:removeObjective( "find_agent_gear" )

    	agent_gear_safe:destroyTab()


end

local function activateCam( sim )
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().MM_camera and (unit:getTraits().mainframe_status ~= "active") then
			-- unit:activate( sim )
			unit:getTraits().mainframe_status = "active"
			unit:getTraits().hasSight = true
			sim:refreshUnitLOS( unit )
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = unit } )	
			sim:addTrigger( simdefs.TRG_OVERWATCH, unit )	
		end
	end

end

local function detentionFitness( cxt, prefab, x, y )
    local tileCount = cxt:calculatePrefabLinkage( prefab, x, y )
    if tileCount == 0 then
        return 0 -- Doesn't link up
    end

    -- Maximize distance to exit AND entrance prefab.
    local maxDist = mission_util.calculatePrefabDistance( cxt, x, y, "entry", "exit" )
    return tileCount + maxDist^2
end
---------------------------------------------------------------------------------------------
-- Begin!

local mission = class( escape_mission )

function mission:init( scriptMgr, sim )
    sim:getTags().skipBanter = true
	sim.TA_mission_success = false
    escape_mission.init( self, scriptMgr, sim )
	activateCam( sim )

	-- sim:addObjective( STRINGS.MOREMISSIONS.UI.DISTRESS_OBJECTIVE, "rescue_agent" )
	scriptMgr:addHook( "START_AGENT_ESCAPE", startAgentEscape, nil, self )
	-- sim:addObjective( util.sformat(STRINGS.MOREMISSIONS.UI.DISTRESS_OBJECTIVE_SECONDARY,sim.MM_distressedName), "find_agent_gear" )	--get gear --> moved to startAgentEscape
	scriptMgr:addHook( "GEAR SAFE REACTION", gearSafeReaction, nil, self)
	scriptMgr:addHook( "GOT_OPERATIVE", got_operative, nil, self )
    --This picks a reaction rant from Central on exit based upon whether or not an agent has escaped with the loot yet.
    local scriptfn = function()

        local scripts = SCRIPTS.INGAME.CENTRAL_JUDGEMENT.DETENTION.GOTNOTHING

       if self.agent_extracted then
            scripts = SCRIPTS.INGAME.DISTRESS_CALL.CENTRAL_JUDGEMENT.GOT_AGENT
        elseif self.agent_distressed then
            scripts = SCRIPTS.INGAME.DISTRESS_CALL.CENTRAL_JUDGEMENT.LOST_AGENT
        elseif self.operative_extracted then
            scripts = SCRIPTS.INGAME.DISTRESS_CALL.CENTRAL_JUDGEMENT.GOT_OTHER
        else --if self.operative_distressed then
            scripts = SCRIPTS.INGAME.DISTRESS_CALL.CENTRAL_JUDGEMENT.LOST_OTHER
        end
        local scr = scripts[sim:nextRand(1, #scripts)]
        return scr
    end

    scriptMgr:addHook( "FINAL", mission_util.CreateCentralReaction(scriptfn))
	
    sim:getTags().cbfCouldHaveAgent = true

end


function mission.pregeneratePrefabs( cxt, tagSet )
    local prefabs = include( "sim/prefabs" )
    escape_mission.pregeneratePrefabs( cxt, tagSet )
    tagSet[1].fitnessSelect = prefabs.SELECT_HIGHEST
    table.insert( tagSet, { { "MM_distresscall_interrogation", detentionFitness }, fitnessSelect = prefabs.SELECT_HIGHEST })
end


return mission
