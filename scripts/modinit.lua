local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
-- local simquery = include ( "sim/simquery" )
-- local itemdefs = include ("sim/unitdefs/itemdefs")

--for unloading
local default_missiontags = array.copy(serverdefs.ESCAPE_MISSION_TAGS)

local function init( modApi )
	modApi.requirements = { "Contingency Plan", "Sim Constructor" }

	-- Path for custom prefabs   
	local scriptPath = modApi:getScriptPath()  	
	rawset(_G,"SCRIPT_PATHS",rawget(_G,"SCRIPT_PATHS") or {})
    	SCRIPT_PATHS.more_missions = scriptPath

	local dataPath = modApi:getDataPath()
	KLEIResourceMgr.MountPackage( dataPath .. "/gui.kwad", "data" )
    -- KLEIResourceMgr.MountPackage( dataPath .. "/images.kwad", "data" )
    -- KLEIResourceMgr.MountPackage( dataPath .. "/sound.kwad", "data" )
    -- MOAIFmodDesigner.loadFEV("moremissions.fev")
    -- KLEIResourceMgr.MountPackage( dataPath .. "/characters.kwad", "data/anims" )
    -- KLEIResourceMgr.MountPackage( dataPath .. "/anims.kwad", "data" )
	
	modApi:addGenerationOption("executive_terminals",  STRINGS.MOREMISSIONS.OPTIONS.EXEC_TERMINAL , STRINGS.MOREMISSIONS.OPTIONS.EXEC_TERMINAL_TIP, {noUpdate=true} )
	modApi:addGenerationOption("ceo_office",  STRINGS.MOREMISSIONS.OPTIONS.CFO_OFFICE , STRINGS.MOREMISSIONS.OPTIONS.CFO_OFFICE_TIP, {noUpdate=true} )
	modApi:addGenerationOption("cyberlab",  STRINGS.MOREMISSIONS.OPTIONS.CYBERLAB , STRINGS.MOREMISSIONS.OPTIONS.CYBERLAB_TIP, {noUpdate=true} )
	modApi:addGenerationOption("detention_centre",  STRINGS.MOREMISSIONS.OPTIONS.DETENTION , STRINGS.MOREMISSIONS.OPTIONS.DETENTION_TIP, {noUpdate=true} )
	modApi:addGenerationOption("nanofab",  STRINGS.MOREMISSIONS.OPTIONS.NANOFAB , STRINGS.MOREMISSIONS.OPTIONS.NANOFAB_TIP, {noUpdate=true} )
	modApi:addGenerationOption("security",  STRINGS.MOREMISSIONS.OPTIONS.SECURITY , STRINGS.MOREMISSIONS.OPTIONS.SECURITY_TIP, {noUpdate=true} )
	modApi:addGenerationOption("server_farm",  STRINGS.MOREMISSIONS.OPTIONS.SERVER_FARM , STRINGS.MOREMISSIONS.OPTIONS.SERVER_FARM_TIP, {noUpdate=true} )
	modApi:addGenerationOption("vault",  STRINGS.MOREMISSIONS.OPTIONS.VAULT , STRINGS.MOREMISSIONS.OPTIONS.VAULT_TIP, {noUpdate=true} )
	--I really wish there were some kind of splitter right about now -M
	--Shirsh set those that not works to "false" until they'll be ready to not bug test playthroughs
	modApi:addGenerationOption("holostudio",  STRINGS.MOREMISSIONS.OPTIONS.HOLOSTUDIO , STRINGS.MOREMISSIONS.OPTIONS.HOLOSTUDIO_TIP, {noUpdate=true} )
	modApi:addGenerationOption("assassination",  STRINGS.MOREMISSIONS.OPTIONS.ASSASSINATION , STRINGS.MOREMISSIONS.OPTIONS.ASSASSINATION_TIP, {noUpdate=true, enabled = false} )
	modApi:addGenerationOption("landfill",  STRINGS.MOREMISSIONS.OPTIONS.LANDFILL , STRINGS.MOREMISSIONS.OPTIONS.LANDFILL_TIP, {noUpdate=true, enabled = false} )

	modApi:addGenerationOption("ea_hostage",  STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.MISSION_TITLE , STRINGS.MOREMISSIONS.LOCATIONS.EA_HOSTAGE.DESCRIPTION, {noUpdate=true, enabled = true} )
	
end

-- local function lateInit( modApi ) 
-- end

local function unloadCommon( modApi, options )
    local scriptPath = modApi:getScriptPath()
	
	local serverdefs_mod = include( scriptPath .. "/serverdefs" )
	array.removeAllElements(serverdefs.ESCAPE_MISSION_TAGS, serverdefs_mod.ESCAPE_MISSION_TAGS)
	array.removeAllElements(simdefs.DEFAULT_MISSION_TAGS, serverdefs_mod.ESCAPE_MISSION_TAGS)

	for i, tag in pairs(default_missiontags) do
		if not array.find(serverdefs.ESCAPE_MISSION_TAGS, tag) then
			table.insert(serverdefs.ESCAPE_MISSION_TAGS, tag)
		end
		if not array.find(simdefs.DEFAULT_MISSION_TAGS, tag) then
			table.insert(simdefs.DEFAULT_MISSION_TAGS, tag)
		end
	end
	
end

local function load( modApi, options, params )
	--before doing anything, clean up
	unloadCommon( modApi, options ) 
	
    local scriptPath = modApi:getScriptPath()
	
	
	local itemdefs = include( scriptPath .. "/itemdefs" )
	for name, itemDef in pairs(itemdefs) do
		modApi:addItemDef( name, itemDef )
	end
	local propdefs = include( scriptPath .. "/propdefs" )
	for i,item in pairs(propdefs) do  
		modApi:addPropDef( i, item, true )
	end
	local animdefs = include( scriptPath .. "/animdefs" )
	for name, animDef in pairs(animdefs) do
		modApi:addAnimDef( name, animDef )
	end
	local guarddefs = include( scriptPath .. "/guarddefs" )
	for name, guarddef in pairs(guarddefs) do
		modApi:addGuardDef( name, guarddef )
	end
	-- local mainframe_abilities = include( scriptPath .. "/mainframe_abilities" )
	-- for name, ability in pairs(mainframe_abilities) do
		-- modApi:addMainframeAbility( name, ability )
	-- end
	-- local npc_abilities = include( scriptPath .. "/npc_abilities" )
	-- for name, ability in pairs(npc_abilities) do
		-- modApi:addDaemonAbility( name, ability )
	-- end
	
	-- modApi:addAbilityDef( "inject_lethal", scriptPath .."/abilities/inject_lethal" )
	
	-- include( scriptPath .. "/simunits" )
	
	-- local corpworldPrefabs = include( scriptPath .. "/prefabs/corpworld/prefabt" )
	-- modApi:addWorldPrefabt(scriptPath, "corpworld", corpworldPrefabs)
	
	-- local escape_mission = include( scriptPath .. "/escape_mission" )
	-- modApi:addEscapeScripts(escape_mission)
	
	-- modApi:setCampaignEvent_setCampaignParam(nil,"contingency_plan",true)
	
	--mod_api:addTooltipDef( commondef ) --Lets us append all onTooltip functions
	
	local serverdefs_mod = include( scriptPath .. "/serverdefs" )
	-- Add the new custom situations
	for id,situation in pairs(serverdefs_mod.SITUATIONS) do
		modApi:addSituation( situation, id, scriptPath .."/missions" )
	end
	--remove vanilla tags if disabled
	for i = #serverdefs.ESCAPE_MISSION_TAGS, 1, -1 do
		if options[serverdefs.ESCAPE_MISSION_TAGS[i]] and not options[serverdefs.ESCAPE_MISSION_TAGS[i]].enabled then
			table.remove(serverdefs.ESCAPE_MISSION_TAGS, i)
		end
	end
	for i = #simdefs.DEFAULT_MISSION_TAGS, 1, -1 do
		if options[simdefs.DEFAULT_MISSION_TAGS[i]] and not options[simdefs.DEFAULT_MISSION_TAGS[i]].enabled then
			table.remove(simdefs.DEFAULT_MISSION_TAGS, i)
		end
	end
	--add new tags if enabled
	for i, tag in pairs(serverdefs_mod.ESCAPE_MISSION_TAGS) do
		if not options[tag] or options[tag].enabled then
			table.insert(serverdefs.ESCAPE_MISSION_TAGS, tag)
			table.insert(simdefs.DEFAULT_MISSION_TAGS, tag)
		end
	end
	
	local STORY_SCRIPTS = include( scriptPath .. "/story_scripts" )
	if STORY_SCRIPTS.INGAME then
		modApi:addMissionScripts( STORY_SCRIPTS.INGAME )
	end
	if STORY_SCRIPTS.CAMPAIGN_MAP and STORY_SCRIPTS.CAMPAIGN_MAP.MISSIONS then
		modApi:addMapScripts( STORY_SCRIPTS.CAMPAIGN_MAP.MISSIONS, "CAMPAIGN_MAP")  
	end

	--add prefabs:

	local sharedPrefabs = include( scriptPath .. "/prefabs/shared/prefabt" )
    	modApi:addPrefabt(sharedPrefabs)

	--local koPrefabs = include( scriptPath .. "/prefabs/ko/prefabt" )
 	--modApi:addWorldPrefabt(scriptPath, "ko", koPrefabs)

	--local ftmPrefabs = include( scriptPath .. "/prefabs/ftm/prefabt" )
  	-- modApi:addWorldPrefabt(scriptPath, "ftm", ftmPrefabs)

	--local skPrefabs = include( scriptPath .. "/prefabs/sankaku/prefabt" )
  	--modApi:addWorldPrefabt(scriptPath, "sankaku", skPrefabs)

	--local plastechPrefabs = include( scriptPath .. "/prefabs/plastech/prefabt" )
    	--modApi:addWorldPrefabt(scriptPath, "plastech", plastechPrefabs)
	
end

local function unload( modApi, options )
	unloadCommon( modApi, options )
end

local function initStrings(modApi)
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()

--separate mission strings
	local HOSTAGE = include(scriptPath .. "/mission_strings/hostage_strings" )	
	modApi:addStrings( dataPath, "MOREMISSIONS_HOSTAGE", HOSTAGE)

	local MOD_STRINGS = include( scriptPath .. "/strings" )	
	modApi:addStrings( dataPath, "MOREMISSIONS", MOD_STRINGS)

	
end

return {
    init = init,
    -- lateInit = lateInit,
    load = load,
    unload = unload,
    initStrings = initStrings,
}