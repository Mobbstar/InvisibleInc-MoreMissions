local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local mission_util = include( "sim/missions/mission_util" )
local escape_mission = include( "sim/missions/escape_mission" )
local unitdefs = include( "sim/unitdefs" )
local simfactory = include( "sim/simfactory" )
local itemdefs = include( "sim/unitdefs/itemdefs" )
local serverdefs = include( "modules/serverdefs" )
local cdefs = include( "client_defs" )

local SCRIPTS = include('client/story_scripts')

-- Tech Expo mission:
---------------------------------------------------------------------------------------------
-- Design summary:

-- Objective room has five lootable boxes with powerful weapons in each
-- EMP immune (?), regular firewalls, however, breaking all firewalls on ONE will immediately increase firewalls on the remaining ones
-- This security measure can be disabled by activating two relay switches randomly located on the map
-- After looting ONE, two androids will come online (one normal and one specops version) 1 turn later
-- This security measure cannot be disabled
-- -Hek


-- Local helpers
local OBJECTIVE_ID = "tech_expo"
local ice_boost = 2 --variable for firewall-boosting security measure

local function queueCentral(script, scripts) --really informative huh
	for k, v in pairs(scripts) do
		script:queue( { script=v, type="newOperatorMessage" } )
		script:queue(0.5*cdefs.SECONDS)
	end	
end

-- DISABLING SECURITY MEASURE
local SWITCH_RESET =
    {
        trigger = simdefs.TRG_MAP_EVENT,
        fn = function( sim, eventData )
            if eventData.event == simdefs.MAP_EVENTS.RESET_SWITCH then 
				-- log:write("LOG map event")
				-- log:write(util.stringize(eventData,3))
                return true
            end 
        end
    }


local MULTISWITCHES_USED =
    {
        trigger = simdefs.TRG_MAP_EVENT,
        fn = function( sim, eventData )
            if eventData.event == simdefs.MAP_EVENTS.SWITCH then 
				-- log:write("LOG map event2")
				-- log:write(util.stringize(eventData,3))		
				if eventData.data == "MM_multilock" then --need to test how this interacts with vanilla switches. IIRC the power relay switch trigger doesn't check for eventData.data. So you could get erroneous triggering in one direction but not the other
					-- log:write("LOG multiswitches used")
					return true
				end
            end 
        end
    }

	
local function androidFX(script,sim)

	local android_number = 2 --1,2 or 3 based on difficulty, TO DO 
	
	local droid_props = {}
	for i,unit in pairs(sim:getAllUnits()) do
		if unit:hasTag("MM_droid_dummy") then
			table.insert(droid_props,unit)
		end
	end
	
	local spawnedpool = {}
	while #spawnedpool < android_number do
		local i = sim:nextRand(1,#droid_props)
		droid_props[i]:addTag("spawningDroid")
		table.insert(spawnedpool,droid_props[i])
		table.remove(droid_props,i)
	end

	for i,unit in pairs(spawnedpool) do
		local cell = sim:getCell( unit:getLocation() )
		script:queue( {type="finalHallLight",cell=cell,console=unit} ) --I LIKE MY FX OKAY
	end
	sim.androidSpawnedPool = spawnedpool
	
	for i,simunit in pairs (sim:getAllUnits()) do
		if simunit:getTraits().cell_door then
			sim:dispatchEvent( simdefs.EV_UNIT_PLAY_ANIM, {unit= simunit, anim="open", sound="SpySociety/Objects/detention_door_shutdown" } )			
			sim:warpUnit( simunit, nil )
			sim:despawnUnit( simunit )
		end
	end	
	
end	
	
local function spawnAndroids(script,sim)
	local enemy = mission_util.findUnitByTag( sim, "spawningDroid" ) 
	enemy:createTab( STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_DROIDS_WARNING,STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_DROIDS_WARNING_SUB) 
	local x1,y1 = enemy:getLocation()
	script:queue( {type = "pan", x=x1, y=y1 } )
	script:queue(1*cdefs.SECONDS )  
	local scripts = SCRIPTS.INGAME.WEAPONS_EXPO.LOOTED_CASE_DROIDS_BOOTING
	queueCentral(script, scripts)

	script:waitFor( mission_util.PC_START_TURN )
	enemy:destroyTab()

	local droid_props = sim.androidSpawnedPool
	for i=#droid_props, 1, -1 do
		local unit = droid_props[i]
		local facing = unit:getFacing()
		local template = unitdefs.lookupTemplate("MM_prototype_droid") 
		if unit:getTraits().spec_droid then
			template = unitdefs.lookupTemplate("MM_prototype_droid_spec")
		end
		local newUnit = simfactory.createUnit(template,sim)
		local cell = sim:getCell( unit:getLocation() )
		sim:warpUnit( unit, nil )
		sim:despawnUnit( unit )
		
		sim:spawnUnit( newUnit )
		newUnit:setFacing(facing)			
		sim:warpUnit( newUnit, cell )
		newUnit:setPlayerOwner(sim:getNPC())
		newUnit:setPather(sim:getNPC().pather)
		sim:dispatchEvent( simdefs.EV_UNIT_APPEARED, { unitID = newUnit:getID() } )	--no idea what this does but vanilla code has it so....
		newUnit:setAlerted(true)
		sim:getNPC():createOrJoinHuntSituation(newUnit)
		sim:getPC():glimpseCell(sim, cell)
		sim:processReactions( newUnit )
		
		local x0, y0 = newUnit:getLocation()
		newUnit:getBrain():spawnInterest(x0,y0, sim:getDefs().SENSE_DEBUG, sim:getDefs().REASON_NOTICED) --lazy way of making it investigate its own tile first
		-- if newUnit:getBrain() then
			-- newUnit:getBrain():getSenses():addInterest( x0, y0, simdefs.REASON_KO, newUnit )
		-- end
		sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = newUnit } )	
		sim.exit_warning = nil	
	end
end

-- TRANSFORMER SUB GOAL
local function MM_transformer_seeswitch( script, sim ) 
    local _, switch1 = script:waitFor( mission_util.SAW_SPECIAL_TAG(script, "MM_switch_subgoal_seen", STRINGS.DLC1.MISSIONS.SIDEMISSIONS.TRANSFORMER_RELAY_SWITCH,"" ) )   
    if not sim:hasTag("MM_transformer_start") then
        sim:getTags().MM_transformer_start = true
        switch1:removeTag("MM_switch_subgoal_seen")
        local x1, y1 = switch1:getLocation()
        script:queue( { type="pan", x=x1, y=y1 } )
        script:queue(1*cdefs.SECONDS )  
		
		local scripts = SCRIPTS.INGAME.WEAPONS_EXPO.SAW_SWITCH
		queueCentral(script, scripts)
		sim:removeObjective("find_switches")
        sim:addObjective( STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_SWITCHES_OBJECTIVE, "MM_transformer_switches" )
    end

    local _, switch2 = script:waitFor( mission_util.SAW_SPECIAL_TAG(script, "MM_switch_subgoal_seen", STRINGS.DLC1.MISSIONS.SIDEMISSIONS.TRANSFORMER_RELAY_SWITCH,"" ) ) 
    script:waitFor( MULTISWITCHES_USED )
    switch1:destroyTab()
    switch2:destroyTab()
end

local function MM_transformer_switchReset( script, sim )
    script:waitFor( SWITCH_RESET )    
    script:queue( 1*cdefs.SECONDS )
    script:queue( { script=SCRIPTS.INGAME.SIDEMISSIONS.CENTRAL_SWITCH_RESET, type="newOperatorMessage" } ) --can keep vanilla for this I guess
    script:addHook( MM_transformer_switchReset )
end

local function MM_transformer( script, sim ) 

    for i,unit in pairs(sim:getAllUnits())do
        if unit:hasTag("MM_switch_subgoal") then
            unit:addTag( "MM_switch_subgoal_seen" )
        end
    end
    script:addHook( MM_transformer_seeswitch )
    script:addHook( MM_transformer_switchReset )

    script:waitFor( MULTISWITCHES_USED )
    sim:removeObjective( "MM_transformer_switches" )
	sim.MM_security_disabled = true
	-- log:write("LOG disable security")
    script:queue( 1*cdefs.SECONDS )     
	local scripts = SCRIPTS.INGAME.WEAPONS_EXPO.DISABLED_SWITCH
	queueCentral(script, scripts)
end
-------- END OF disabling security measure

----- SECURITY MEASURE: firewalls boosted on devices
local SAFE_HACKED =
	{
		trigger = simdefs.TRG_ICE_BROKEN,
		fn = function( sim, eventData )
			if eventData.unit:hasTag("MM_topGear") and eventData.unit:getTraits().mainframe_ice and (eventData.unit:getTraits().mainframe_ice <= 0) then
				return eventData.unit
			end
		end
		}

	--boost firewalls on all other lootcases except the one just hacked
local function boost_firewalls(script, sim)
	local _, vaultcase = script:waitFor( SAFE_HACKED )
	if not sim.MM_security_disabled then
		sim:dispatchEvent( simdefs.EV_SHOW_WARNING, {txt=STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_FIREWALLS, color=cdefs.COLOR_CORP_WARNING, sound = "SpySociety/Actions/mainframe_deterrent_action" } )
		for i, unit in pairs(sim:getAllUnits()) do
			if unit:hasTag("MM_topGear") and (vaultcase ~= unit) and unit:getTraits().mainframe_ice and (unit:getTraits().mainframe_ice > 0) and (unit:getTraits().mainframe_status == "active") then
				unit:increaseIce( sim, ice_boost )
			end
		end
	end
	script:addHook( boost_firewalls )
end

local function MM_checkTopGearSafes( sim )
	-- log:write("spawning special gear")
	local itemList = {}
	for k,v in pairs(itemdefs) do
		if v.traits and v.traits.MM_tech_expo_item then
			table.insert(itemList,v)				
		end
	end
	
	log:write(util.stringize(itemList,2))

	for i,unit in pairs(sim:getAllUnits()) do
		if unit:hasTag("MM_topGear") then
            -- Add a random item to unit (presumably a safe)
			local item = itemList[ sim:nextRand( 1, #itemList ) ]
			local newItem = simfactory.createUnit( item, sim )						
            newItem:addTag("MM_topGearItem") -- For the UI loot hook
			sim:spawnUnit( newItem )
			newItem:getTraits().artifact = true --for safe to display the loot symbol
			unit:addChild( newItem )	
			sim.totalTopGear = sim.totalTopGear or 0 
			sim.totalTopGear = sim.totalTopGear + 1 
		end
	end
	-- log:write("LOG sim.totalTopGear " ..tostring(sim.totalTopGear))
end

local function MM_checkTopGearItem( script, sim )	
	local _, topGearSafe = script:waitFor( mission_util.PC_SAW_UNIT("MM_topGear") )
	-- topGearSafe:createTab( STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_DROIDS_WARNING,STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_DROIDS_WARNING_SUB) 
	local scripts = SCRIPTS.INGAME.WEAPONS_EXPO.FOUND_EXPO_DISABLED_SEC
	if not sim.MM_security_disabled then
		scripts = SCRIPTS.INGAME.WEAPONS_EXPO.FOUND_EXPO
		sim:addObjective( STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_FIND_SWITCHES, "find_switches" )
	end
	queueCentral(script, scripts)
	topGearSafe:destroyTab()
	
	local _, item, agent = script:waitFor( mission_util.PC_TOOK_UNIT_WITH_TAG( "MM_topGearItem" ))
    
	sim:setClimax(true)
    script:waitFor( mission_util.UI_LOOT_CLOSED )
    sim:removeObjective( OBJECTIVE_ID )        
    script:waitFrames( .5*cdefs.SECONDS )

	androidFX(script,sim)
	script:addHook(spawnAndroids)
	
	script:waitFrames( 1.5*cdefs.SECONDS )
	
	scripts = SCRIPTS.INGAME.WEAPONS_EXPO.LOOTED_CASE_DROIDS_BOOTING
	

end

local UNIT_ESCAPE =
{
	trigger = simdefs.TRG_UNIT_ESCAPED,
	fn = function( sim, triggerUnit )
		if triggerUnit then
			return triggerUnit
		end
	end,
}

local function isNotKO( unit )
    return not unit:isKO()
end


local function countUnstolenTech(script,sim,mission)
	script:waitFor(UNIT_ESCAPE)

	local fieldUnits, escapingUnits = simquery.countFieldAgents( sim )

	-- A partial escape means someone alive is left on the field.
	local isPartialEscape = array.findIf( fieldUnits, isNotKO ) ~= nil

	--we don't want central to consider the mission failed if you stole something but already sold it or already escaped with it, so let's check for any objective items that are not in an agency unit's inventory

	if isPartialEscape then
		script:addhook(countUnstolenTech)
	else
		local not_stolen = {}
		for i,unit in pairs(sim:getAllUnits()) do
			if unit:hasTag("MM_topGearItem") then
				local owner = unit:getUnitOwner()
				if (owner == nil) or (owner and owner:getPlayerOwner() == sim:getPC()) then --any lootables not in an escaping unit's inventory
					table.insert(not_stolen, unit)
				end
			end
		end
		local stolen = sim.totalTopGear -(#not_stolen)  --sim.totalTopGear should always be 5 with these prefabs
		if stolen > 0 then 
			sim.exit_warning = nil
			sim.TA_mission_success = true -- flag for Talkative Agents
			mission.MM_got_partial_tech = true
		end
		if stolen >= sim.totalTopGear then
			mission.MM_got_all_tech = true
			sim.TA_mission_success = true
		end
	end

end
			

---------------------------------------------------------------------------------------------
-- Mission

local mission = class( escape_mission )

function mission:init( scriptMgr, sim )
    escape_mission.init( self, scriptMgr, sim )
	
    -- local isEndless = sim:getParams().difficultyOptions.maxHours == math.huge
  
	MM_checkTopGearSafes( sim )

	sim.exit_warning = STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_WARN_EXIT
	scriptMgr:addHook( "TECH_EXPO_TOP_GEAR", MM_checkTopGearItem )
	scriptMgr:addHook( "TECH_EXPO_BOOST_FIREWALLS", boost_firewalls )
	scriptMgr:addHook( "TECH_EXPO_COUNT_UNSTOLEN_TECH", countUnstolenTech, nil, self )
	scriptMgr:addHook( "MM_TRANSFORMER", MM_transformer )
    sim:addObjective( STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_OBJECTIVE, OBJECTIVE_ID )			
			
    --This picks a reaction rant from Central on exit based upon whether or not an agent has escaped with the loot yet.
    local scriptfn = function()
		local scripts = (self.MM_got_all_tech and SCRIPTS.INGAME.WEAPONS_EXPO.CENTRAL_JUDGEMENT.GOT_FULL) or (self.MM_got_partial_tech and SCRIPTS.INGAME.WEAPONS_EXPO.CENTRAL_JUDGEMENT.GOT_PARTIAL) or SCRIPTS.INGAME.WEAPONS_EXPO.CENTRAL_JUDGEMENT.NO_LOOT
        local scr = scripts[sim:nextRand(1, #scripts)]
        return scr
    end
    scriptMgr:addHook( "FINAL", mission_util.CreateCentralReaction(scriptfn))
		
end


function mission.pregeneratePrefabs( cxt, tagSet )
    escape_mission.pregeneratePrefabs( cxt, tagSet )
    -- table.insert( tagSet[1], "weapons_expo1" )
	-- table.insert( tagSet[1], "weapons_expo2" )
	-- table.insert( tagSet[1], "weapons_expo3" ) --for testing
	table.insert( tagSet[1], "weapons_expo" ) --for final version
end

function mission.generatePrefabs( cxt, candidates )
    local prefabs = include( "sim/prefabs" )   
    prefabs.generatePrefabs( cxt, candidates, "MM_lock_switch", 2 )

end

return mission
