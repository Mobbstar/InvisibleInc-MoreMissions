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


local PC_LOOTED_SECURE_SAFE =
{
    trigger = simdefs.TRG_SAFE_LOOTED,
    fn = function( sim, triggerData )
        if triggerData.targetUnit:hasTag("topGear") then
            return triggerData 
        end
    end,
}

local function fillTopGearSafes( sim )
	local wishList = {
		"item_hologrenade",
		"item_cloakingrig_2",
		"item_cloakingrig_3",
		"item_laptop_holo",
		"item_hologrenade_hd",
		"item_disguise_charged",
		"item_decoy", --from Ghuff
	}
	local itemList = {}
	
	for i, name in pairs(wishList) do
		if unitdefs.lookupTemplate(name) then
			table.insert(itemList, unitdefs.lookupTemplate(name) )
		end
	end
	
	for i,unit in pairs(sim:getAllUnits()) do
		if unit:hasTag("topGear") then
            -- Add a random item to unit (presumably a safe)
			local item = itemList[ sim:nextRand( 1, #itemList ) ]
			local newItem = simfactory.createUnit( item, sim )						
            newItem:addTag("topGearItem") -- For the UI loot hook
			sim:spawnUnit( newItem )
			unit:addChild( newItem )
		end
	end
end

local function checkTopGearItem( script, sim )	
	local _, item, agent = script:waitFor( mission_util.PC_TOOK_UNIT_WITH_TAG( "topGearItem" ))
	local topGearSafe = mission_util.findUnitByTag( sim, "topGear" )
    topGearSafe:destroyTab()

	sim:setClimax(true)
    script:waitFor( mission_util.UI_LOOT_CLOSED )
    sim:removeObjective( "primaryLoot" )        
    script:waitFrames( .5*cdefs.SECONDS )

	if agent then
		local x2,y2 = agent:getLocation()
		sim:getNPC():spawnInterest(x2,y2, simdefs.SENSE_RADIO, simdefs.REASON_ALARMEDSAFE, agent)
	end

	script:waitFrames( 1.5*cdefs.SECONDS )
	script:queue( { script=SCRIPTS.INGAME.HOLOSTUDIO.AFTERMATH[sim:nextRand(1, #SCRIPTS.INGAME.HOLOSTUDIO.AFTERMATH)], type="newOperatorMessage" } )

end

--keep track of when the loot gets actually extracted
local function gotloot(script, sim, mission)
    script:waitFor( mission_util.ESCAPE_WITH_LOOT("topGearItem") )
    mission.got_the_loot = true
end

local function presawfn( script, sim, item )
	--create that big white arrow pointing to the target
	item:createTab( STRINGS.MISSIONS.UTIL.ADVANCED_TECHNOLOGY, "" )
	sim:removeObjective( "primaryLoot" )              
end

local function pstsawfn( script, sim, item )
	sim:addObjective( STRINGS.MISSIONS.ESCAPE.OBJ_SECURITY_2, "primaryLoot" )
	script:waitFor( PC_LOOTED_SECURE_SAFE ) 
end


---------------------------------------------------------------------------------------------
-- Begin!

local mission = class( escape_mission )

function mission:init( scriptMgr, sim )
    escape_mission.init( self, scriptMgr, sim )

    sim:addObjective( STRINGS.MISSIONS.ESCAPE.OBJ_SECURITY, "primaryLoot" )			
	fillTopGearSafes( sim )

	sim.exit_warning = mission_util.CheckForLeftItem(sim, "topGearItem", STRINGS.MOREMISSIONS.UI.HUD_WARN_EXIT_MISSION_HOLOSTUDIO)
	scriptMgr:addHook( "TOPGEAR", checkTopGearItem )

	scriptMgr:addHook( "SEE", mission_util.DoReportObject(mission_util.PC_SAW_UNIT("topGear"), SCRIPTS.INGAME.HOLOSTUDIO.OBJECTIVE_SIGHTED, presawfn, pstsawfn ) )

    scriptMgr:addHook("ESCAPEWITHLOOT", gotloot, nil, self)
    --This picks a reaction rant from Central on exit based upon whether or not an agent has escaped with the loot yet.
    local scriptfn = function()
        local scripts = self.got_the_loot and SCRIPTS.INGAME.HOLOSTUDIO.CENTRAL_JUDGEMENT.HASLOOT or SCRIPTS.INGAME.HOLOSTUDIO.CENTRAL_JUDGEMENT.NOLOOT
        return scripts[sim:nextRand(1, #scripts)]
    end
    scriptMgr:addHook( "FINAL", mission_util.CreateCentralReaction(scriptfn))

end


function mission.pregeneratePrefabs( cxt, tagSet )
    escape_mission.pregeneratePrefabs( cxt, tagSet )
    table.insert( tagSet[1], "guard_office" )
	
	
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
