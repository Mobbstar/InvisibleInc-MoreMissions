local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

--for unloading
local default_missiontags = array.copy(serverdefs.ESCAPE_MISSION_TAGS)

local function earlyInit( modApi )
	modApi.requirements = { "Contingency Plan", "Sim Constructor", "Function Library", "Advanced Guard Protocol", "Items Evacuation", "New Items And Augments","Advanced Cyberwarfare","Programs Extended","Offbrand Programs","Switch Content Mod", "Interactive Events","Generation Options+", "Additional Banter" }

	local scriptPath = modApi:getScriptPath()
	rawset(_G,"SCRIPT_PATHS",rawget(_G,"SCRIPT_PATHS") or {})
    SCRIPT_PATHS.more_missions = scriptPath	
	SCRIPT_PATHS.name_dialog = include( scriptPath .. "/hud/name_dialog" )
    include( scriptPath .. "/hud/hud_name_dialog" )
end

local function init( modApi )
	-- Path for custom prefabs
	local scriptPath = modApi:getScriptPath()
	local dataPath = modApi:getDataPath()
	KLEIResourceMgr.MountPackage( dataPath .. "/gui.kwad", "data" )
    -- KLEIResourceMgr.MountPackage( dataPath .. "/images.kwad", "data" )
    KLEIResourceMgr.MountPackage( dataPath .. "/sound.kwad", "data" )
    MOAIFmodDesigner.loadFEV("moremissions.fev")
    -- KLEIResourceMgr.MountPackage( dataPath .. "/characters.kwad", "data/anims" )
    -- KLEIResourceMgr.MountPackage( dataPath .. "/anims.kwad", "data" )
   	KLEIResourceMgr.MountPackage( dataPath .. "/moremissions_anims.kwad", "data" )
	KLEIResourceMgr.MountPackage( dataPath .. "/pedler_oil.kwad", "data" ) --taken from Shirsh's mod combo

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
	-- modApi:addGenerationOption("holostudio",  STRINGS.MOREMISSIONS.OPTIONS.HOLOSTUDIO , STRINGS.MOREMISSIONS.OPTIONS.HOLOSTUDIO_TIP, {noUpdate=true, enabled = false} )
	modApi:addGenerationOption("assassination",  STRINGS.MOREMISSIONS.OPTIONS.ASSASSINATION , STRINGS.MOREMISSIONS.OPTIONS.ASSASSINATION_TIP, {noUpdate=true} )
	-- modApi:addGenerationOption("landfill",  STRINGS.MOREMISSIONS.OPTIONS.LANDFILL , STRINGS.MOREMISSIONS.OPTIONS.LANDFILL_TIP, {noUpdate=true, enabled = false} )
	modApi:addGenerationOption("ea_hostage",  STRINGS.MOREMISSIONS.OPTIONS.EA_HOSTAGE , STRINGS.MOREMISSIONS.OPTIONS.EA_HOSTAGE_TIP, {noUpdate=true, enabled = true} )
	modApi:addGenerationOption("distress_call",  STRINGS.MOREMISSIONS.OPTIONS.DISTRESSCALL, STRINGS.MOREMISSIONS.OPTIONS.DISTRESSCALL_TIP, {noUpdate=true, enabled = true} )
	modApi:addGenerationOption("weapons_expo",  STRINGS.MOREMISSIONS.OPTIONS.WEAPONSEXPO, STRINGS.MOREMISSIONS.OPTIONS.WEAPONSEXPO_TIP, {noUpdate=true, enabled = true} )
	modApi:addGenerationOption("mole_insertion",  STRINGS.MOREMISSIONS.OPTIONS.MOLE_INSERTION, STRINGS.MOREMISSIONS.OPTIONS.MOLE_INSERTION_TIP, {noUpdate=true, enabled = true} )
	modApi:addGenerationOption("ai_terminal",  STRINGS.MOREMISSIONS.OPTIONS.AI_TERMINAL, STRINGS.MOREMISSIONS.OPTIONS.AI_TERMINAL_TIP, {noUpdate=true, enabled = true} )

	modApi:addGenerationOption("MM_sidemissions",  STRINGS.MOREMISSIONS.OPTIONS.SIDEMISSIONS , STRINGS.MOREMISSIONS.OPTIONS.SIDEMISSIONS_TIP, {noUpdate=true} ) --doesn't do anything yet
	
	modApi:addGenerationOption("MM_sidemission_rebalance",  STRINGS.MOREMISSIONS.OPTIONS.SIDEMISSIONS_REBALANCE , STRINGS.MOREMISSIONS.OPTIONS.SIDEMISSIONS_REBALANCE_TIP, {noUpdate=true} ) --doesn't do anything yet	

	modApi:addGenerationOption("MM_newday", STRINGS.MOREMISSIONS.OPTIONS.NEWDAY, STRINGS.MOREMISSIONS.OPTIONS.NEWDAY_DESC,
	{
		values = {0,1,2,3,4,5,6,7,8,9,10},
		value=4,
		noUpdate = true,
	})
	
	modApi:addGenerationOption("MM_exec_terminals", STRINGS.MOREMISSIONS.OPTIONS.EXEC_TERMINALS, STRINGS.MOREMISSIONS.OPTIONS.EXEC_TERMINALS_DESC,
	{ noUpdate = true,})	

	modApi:addGenerationOption("MM_spawnTable_droids" , STRINGS.MOREMISSIONS.OPTIONS.SPAWNTABLE_DROIDS, STRINGS.MOREMISSIONS.OPTIONS.SPAWNTABLE_DROIDS_DESC, {values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 99999}, value=7, strings = STRINGS.MOREMISSIONS.OPTIONS.SPAWNTABLE_DROIDS_VALUES, noUpdate = true} )		
	
	modApi:addGenerationOption("MM_hard_mode",  STRINGS.MOREMISSIONS.OPTIONS.HARD_MODE , STRINGS.MOREMISSIONS.OPTIONS.HARD_MODE_TIP, {enabled = false, noUpdate=true } )

	-- patch automatic tracker
	include( scriptPath .. "/appended_functions/simplayer" )
	
	--cannot set display string... local variable only -M
	table.insert(modApi.mod_manager.credit_sources, "assassinationreward")

	-- SIDE MISSIONS
	include( scriptPath .. "/appended_functions/abilities/showItemStore" )

	-- MOLE INSERTION
	include( scriptPath .. "/appended_functions/prefabs" )
	-- END OF MOLE INSERTION

	include( scriptPath .. "/appended_functions/simquery" )
	include( scriptPath .. "/appended_functions/engine_init" )
	include( scriptPath .. "/appended_functions/idle" )
	include( scriptPath .. "/appended_functions/laser" )
	include( scriptPath .. "/appended_functions/pcplayer" )
	include( scriptPath .. "/appended_functions/unitrig" )
	include( scriptPath .. "/btree/actions" )
	include( scriptPath .. "/btree/conditions" )
	include( scriptPath .. "/btree/bountytargetbrain" )

	include( scriptPath.."/hud/hud" )--from Interactive Events, required for modal dialog choice menu to work properly

	-- AI TERMINAL
	local modifyPrograms = include( scriptPath .. "/abilities/mainframe_abilities" )
	modifyPrograms()
	-- double-included here in init and in lateLoad to catch both vanilla overrides and mod additions. Upgraded programs with abilityOverride such as Fusion DO NOT WORK without this line!
	
	util.tmerge( STRINGS.LOADING_TIPS, STRINGS.MOREMISSIONS.LOADING_TIPS  ) --add new loading screen tooltips
	
	-- adding datalogs
	local logs = include( scriptPath .. "/logs" )
	for i,log in ipairs(logs) do      
		modApi:addLog(log)
	end
	
end

local function lateInit( modApi )
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()
	
	-- include( scriptPath .. "/appended_functions/talkingheadfix") -- prevent Operator messages during mainframe mode, if we want this
	
	-- MOLE_INSERTION
	-- custom intelligence benefit
	-- DoFinishMission: tick and despawn existing intel bonuses if needed
	local mod_mission_scoring = include( scriptPath .. "/appended_functions/mission_scoring")
	mod_mission_scoring.runAppend( modApi ) --other part in load

	-- start of mission: spawn intel bonuses if player has completed a mole mission
	--needs to run after FuncLib inits
	local mission_util_lateInit = include( scriptPath .. "/appended_functions/mission_util_lateInit")
	-- Similar edit is done in Load to mid_1!
	mission_util_lateInit.runAppend( modApi )
	
	-- includes simunit as well as simdrone appends
	include( scriptPath .. "/appended_functions/units_lateInit")
	
	include( scriptPath .. "/appended_functions/abilities/paralyze") -- Amnesiac functionality
	include( scriptPath .. "/appended_functions/abilities/icebreak")
	include( scriptPath .. "/appended_functions/abilities/useInvisiCloak")
	include( scriptPath .. "/appended_functions/abilities/use_stim")	
	include( scriptPath .. "/appended_functions/abilities/observePath")
	
	include( scriptPath .. "/appended_functions/engine_lateInit")
	local worldgen_append = include( scriptPath .. "/appended_functions/worldgen")
	worldgen_append.runAppend()
	
	include( scriptPath .. "/appended_functions/state-map-screen") --for Informant map screen UI
	
end

--The implementation of array.removeAllElements is not optimal for our purposes, and we also need something to remove dupes, so might as well combine it all. -M
local function removeAllElementsAndDupes(t0, t1)
	local t2 = {} --RaXaH: What is t2 used for?
	for i = 1, #t1, 1 do
		t2[t1[i]] = true
	end
	for i = #t0, 1, -1 do
		if t2[t0[i]] then
			table.remove(t0, i)
		else
			t2[t0[i]] = true
		end
	end
end

local function unloadCommon( modApi, options )
    local scriptPath = modApi:getScriptPath()

	local serverdefs_mod = include( scriptPath .. "/serverdefs" )
	removeAllElementsAndDupes(serverdefs.ESCAPE_MISSION_TAGS, serverdefs_mod.ESCAPE_MISSION_TAGS)
	removeAllElementsAndDupes(simdefs.DEFAULT_MISSION_TAGS, serverdefs_mod.ESCAPE_MISSION_TAGS)

	for i, tag in pairs(default_missiontags) do
		if not array.find(serverdefs.ESCAPE_MISSION_TAGS, tag) then
			-- log:write("restoring mission tag: ".. tag)
			table.insert(serverdefs.ESCAPE_MISSION_TAGS, tag)
		end
		if not array.find(simdefs.DEFAULT_MISSION_TAGS, tag) then
			table.insert(simdefs.DEFAULT_MISSION_TAGS, tag)
		end
	end	

end

local function earlyLoad( modApi, options, params )
    local scriptPath = modApi:getScriptPath()

	local serverdefs_appends = include( scriptPath .. "/appended_functions/serverdefs" )
	serverdefs_appends.earlyLoad()
end

local function load( modApi, options, params )
	--before doing anything, clean up
	unloadCommon( modApi, options )

    local scriptPath = modApi:getScriptPath()

	if params then
		params.mm_enabled = true
		if (options["MM_hard_mode"] and options["MM_hard_mode"].enabled) or (options["MM_hard_mode"] == nil) then
			params.MM_difficulty = "hard"
		elseif options["MM_hard_mode"] and not options["MM_hard_mode"].enabled then
			params.MM_difficulty = "easy"
		end
		if options["MM_exec_terminals"] and options["MM_exec_terminals"].enabled then
			params.MM_exec_terminals = true
		end	
		if options["MM_sidemission_rebalance"] and options["MM_sidemission_rebalance"].enabled then
			params.MM_sidemission_rebalance = true
		end
		if options["MM_spawnTable_droids"] and options["MM_spawnTable_droids"].value then
			params.MM_spawnTable_droids = options["MM_spawnTable_droids"].value
		end
	end
	
	local animdefs_vanilla = include( "animdefs" ).defs
	if animdefs_vanilla.kanim_drone_refit then
		if options["MM_sidemission_rebalance"] and options["MM_sidemission_rebalance"].enabled then
			if animdefs_vanilla.kanim_drone_refit.oldScale == nil then
				animdefs_vanilla.kanim_drone_refit.oldScale = animdefs_vanilla.kanim_drone_refit.scale
			end
			animdefs_vanilla.kanim_drone_refit.scale = 0.2 --smollify
		else
			if animdefs_vanilla.kanim_drone_refit.oldScale then
				animdefs_vanilla.kanim_drone_refit.scale = animdefs_vanilla.kanim_drone_refit.oldScale
			end
		end
	end
	
	if options["MM_exec_terminals"] and options["MM_exec_terminals"].enabled then
		-- new SC functions for Executive Terminal window override
		modApi:insertUIElements( include( scriptPath.."/screen_inserts" ).inserts_exec )
		modApi:modifyUIElements( include( scriptPath.."/screen_modifications" ) )
	end
	
	if options["ai_terminal"] and options["ai_terminal"].enabled then
		modApi:insertUIElements( include( scriptPath.."/screen_inserts" ).inserts_ai_term )
	end

	if options.MM_newday then --cribbed from GenOpts+
		rawset(simdefs,"NUM_MISSIONS_TO_SPAWN",options.MM_newday.value)
	else
		if options.newday then
			rawset(simdefs,"NUM_MISSIONS_TO_SPAWN",options.newday.value) --Generation Options+ value
		else
			rawset(simdefs,"NUM_MISSIONS_TO_SPAWN",4)
		end
	end

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
	local agentdefs = include( scriptPath .. "/agentdefs" )
	for name, agentDef in pairs(agentdefs) do
	modApi:addAgentDef( name, agentDef )
	end

	local commondefs = include( scriptPath .. "/commondefs" )
	modApi:addTooltipDef( commondefs )

	if options["MM_sidemissions"].enabled then
		modApi:addSideMissions(scriptPath, { "MM_w93_storageroom" } )
		modApi:addSideMissions(scriptPath, { "MM_w93_personelHijack" } )
		modApi:addSideMissions(scriptPath, { "MM_luxuryNanofab" } )
		-- for vanilla side missions
		include( scriptPath .. "/appended_functions/abilities/transformer_terminal")

		-- (easy debugging of sidemissions: uncomment to clear the list and add just the sidemission to be tested)
		--local worldgen = include( "sim/worldgen" )
		--util.tclear(worldgen.SIDEMISSIONS)
		--modApi:addSideMissions(scriptPath, { "???" } )
	end

	-- add all the custom NEW abilities (not appends to existing ones)
	modApi:addAbilityDef( "hostage_rescuable", scriptPath .."/abilities/hostage_rescuable_2" ) -- to dest... okay maybe don't needed, we'll see
	modApi:addAbilityDef( "MM_hack_personneldb", scriptPath .."/abilities/MM_hack_personneldb" )
	modApi:addAbilityDef( "MM_escape_guardelevator", scriptPath .."/abilities/MM_escape_guardelevator" )
	modApi:addAbilityDef( "MM_escape_guardelevator2", scriptPath .."/abilities/MM_escape_guardelevator2" )
	modApi:addAbilityDef( "MM_scrubcameradb", scriptPath .."/abilities/MM_scrubcameradb" )
	modApi:addAbilityDef( "MM_W93_incogRoom_unlock", scriptPath .."/abilities/MM_W93_incogRoom_unlock" )
	modApi:addAbilityDef( "MM_W93_incogRoom_upgrade", scriptPath .."/abilities/MM_W93_incogRoom_upgrade" )
	modApi:addAbilityDef( "MM_fakesteal", scriptPath .. "/abilities/MM_fakesteal" )
	modApi:addAbilityDef( "MM_W93_escape", scriptPath .. "/abilities/MM_W93_escape" )
	modApi:addAbilityDef( "MM_transformer_terminal_5PWR", scriptPath .. "/abilities/MM_transformer_terminal_5PWR" )
	modApi:addAbilityDef( "MM_transformer_terminal_10PWR", scriptPath .. "/abilities/MM_transformer_terminal_10PWR" )
	modApi:addAbilityDef( "MM_compileUSB", scriptPath .. "/abilities/MM_compileUSB" )
	modApi:addAbilityDef( "MM_installprogram", scriptPath .. "/abilities/MM_installprogram" )
	modApi:addAbilityDef( "MM_renameDrone", scriptPath .. "/abilities/MM_renameDrone" )
	modApi:addAbilityDef( "MM_activateLuxuryNanofab", scriptPath .. "/abilities/MM_activateLuxuryNanofab" )
	modApi:addAbilityDef( "MM_summonGuard", scriptPath .. "/abilities/MM_summonGuard" )
	modApi:addAbilityDef( "MM_surveyor", scriptPath .. "/abilities/MM_surveyor" )
	modApi:addAbilityDef( "MM_ce_ultrasonic_echolocation_passive", scriptPath .. "/abilities/MM_ce_ultrasonic_echolocation_passive" )

	include( scriptPath .. "/missions/distress_call" )
	include( scriptPath .. "/missions/weapons_expo" )
	include( scriptPath .. "/missions/assassination" )
	include( scriptPath .. "/missions/ea_hostage" )
	include( scriptPath .. "/missions/mole_insertion" )
	include( scriptPath .. "/missions/mission_util" ) --mainly support for AI Terminal dialogue from Interactive Events
	include( scriptPath .. "/missions/mission_executive_terminals" ) --override mission choice window

	local npc_abilities = include( scriptPath .. "/abilities/npc_abilities" )
	for name, ability in pairs(npc_abilities) do
		modApi:addDaemonAbility( name, ability )
	end

	-- local corpworldPrefabs = include( scriptPath .. "/prefabs/corpworld/prefabt" )
	-- modApi:addWorldPrefabt(scriptPath, "corpworld", corpworldPrefabs)

	local escape_mission = include( scriptPath .. "/escape_mission" )
	modApi:addEscapeScripts(escape_mission)

	-- custom SIMUNITS
	include(scriptPath.."/units/MM_simKOcloud")
	include(scriptPath.."/units/MM_simemppack_pulse")
	include(scriptPath.."/units/MM_simfraggrenade")

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
			-- log:write("removing mission tag: ".. serverdefs.ESCAPE_MISSION_TAGS[i])
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
			-- log:write("adding mission tag: ".. tag)
			table.insert(serverdefs.ESCAPE_MISSION_TAGS, tag)
			table.insert(simdefs.DEFAULT_MISSION_TAGS, tag)
		end
	end
	--The following fixes a crash where the exec terminal expects at least 4 possible mission types. -M
	while #serverdefs.ESCAPE_MISSION_TAGS < 4 do
		for i = 1, #serverdefs.ESCAPE_MISSION_TAGS, 1 do
			table.insert(serverdefs.ESCAPE_MISSION_TAGS, serverdefs.ESCAPE_MISSION_TAGS[i])
		end
	end
	while #simdefs.DEFAULT_MISSION_TAGS < 4 do
		for i = 1, #simdefs.DEFAULT_MISSION_TAGS, 1 do
			table.insert(simdefs.DEFAULT_MISSION_TAGS, simdefs.DEFAULT_MISSION_TAGS[i])
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
	local hostagePrefabs = include( scriptPath .. "/prefabs/EA_hostage/prefabt" )
	modApi:addPrefabt(hostagePrefabs)
	local assassinationPrefabs = include( scriptPath .. "/prefabs/assassination/prefabt" )
	modApi:addPrefabt(assassinationPrefabs)
	local distressPrefabs = include( scriptPath .. "/prefabs/distress_call/prefabt" )
    modApi:addPrefabt(distressPrefabs)
	local moleInsertionPrefabs = include( scriptPath .. "/prefabs/mole_insertion/prefabt" )
	modApi:addPrefabt(moleInsertionPrefabs)
	local cameraDB = include( scriptPath .. "/prefabs/mole_insertion/prefabt_cameradb" )
	modApi:addPrefabt(cameraDB)
	local weaponsExpoPrefabs = include( scriptPath .. "/prefabs/weaponsexpo/prefabt" )
    modApi:addPrefabt(weaponsExpoPrefabs)
	local aiTerminalPrefabs = include( scriptPath .. "/prefabs/ai_terminal/prefabt" )
    modApi:addPrefabt(aiTerminalPrefabs)
	local sidemissionPrefabs = include( scriptPath .. "/prefabs/sidemissions/prefabt" )
    modApi:addPrefabt(sidemissionPrefabs)

	--local koPrefabs = include( scriptPath .. "/prefabs/ko/prefabt" )
 	--modApi:addWorldPrefabt(scriptPath, "ko", koPrefabs)

	--local ftmPrefabs = include( scriptPath .. "/prefabs/ftm/prefabt" )
  	-- modApi:addWorldPrefabt(scriptPath, "ftm", ftmPrefabs)

	--local skPrefabs = include( scriptPath .. "/prefabs/sankaku/prefabt" )
  	--modApi:addWorldPrefabt(scriptPath, "sankaku", skPrefabs)

	--local plastechPrefabs = include( scriptPath .. "/prefabs/plastech/prefabt" )
    	--modApi:addWorldPrefabt(scriptPath, "plastech", plastechPrefabs)

	--and here comes the massive hacks! -M
	include( scriptPath .. "/appended_functions/abilities/escape" ) --This one has to be in load() because the item evac mod overrides the ability each load. (as of 20-2-2, -M)

	--Tech Expo hack0rz -Hek
	include( scriptPath .. "/appended_functions/abilities/stealCredits" )

	------ These four appends are necessary because vanilla weapons never have skill requirements or anything that checks for them before use
	include( scriptPath .. "/appended_functions/abilities/shootSingle" ) --unused
	include( scriptPath .. "/appended_functions/abilities/overwatch" ) --unused
	include( scriptPath .. "/appended_functions/abilities/overwatchMelee" ) --unused
	local melee_append = include( scriptPath .. "/appended_functions/abilities/melee" ) --used for Assassination
	melee_append.runAppend( modApi )

	--------
	-- MOLE INSERTION
	reinclude = include --necessary for tweaking mid_1
	local mid_1_append = include( scriptPath .. "/missions/mid_1" )
	mid_1_append.runAppend(  modApi )
	
	--Add the clusters to serverdefs
	serverdefs.CLUSTERS = serverdefs_mod.CLUSTERS
end

local function lateLoad( modApi, options, params, mod_options )
	local scriptPath = modApi:getScriptPath()
	local tech_expo_itemdefs = include( scriptPath .. "/tech_expo_itemdefs" )
	for name, itemDef in pairs(tech_expo_itemdefs.generateTechExpoGear()) do
		modApi:addItemDef( name, itemDef )
	end

	-- AI TERMINAL
	local modifyPrograms = include( scriptPath .. "/abilities/mainframe_abilities" )
	modifyPrograms()
	
	----- Distress Call mission hackz - Hek. They need to be in Load too. make that lateLoad because of Additional Banter
	include( scriptPath .. "/appended_functions/mission_util_lateLoad" )	
	
	--ASSASSINATION, COURIER RESCUE
	-- SimConstructor resets serverdefs with every load, hence this function wrap only applies once despite being in mod-load. If SimConstructor ever changes, this must too.
	local serverdefs_appends = include( scriptPath .. "/appended_functions/serverdefs" )
	serverdefs_appends.lateLoad( mod_options ) --RaXaH: I don't really see a reason to do these in lateLoad > load.
	
	--Add cluster to SITUATIONS
	local serverdefs_mod = include( scriptPath .. "/serverdefs" )
	for name, situation in pairs( serverdefs.SITUATIONS ) do
		util.extend( serverdefs_mod.SITUATION_CLUSTERING[name] or serverdefs_mod.SITUATION_CLUSTERING.default ) ( situation )
	end
end

local function unload( modApi, options )
	unloadCommon( modApi, options )
end

local function initStrings(modApi)
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()

-- to have separate mission strings
	local HOSTAGE = include(scriptPath .. "/mission_strings/hostage_strings" )
	modApi:addStrings( dataPath, "MOREMISSIONS_HOSTAGE", HOSTAGE)

	local MOD_STRINGS = include( scriptPath .. "/strings" )
	modApi:addStrings( dataPath, "MOREMISSIONS", MOD_STRINGS)

end

return {
    init = init,
    earlyInit = earlyInit,
    lateInit = lateInit,
    earlyLoad = earlyLoad,
    load = load,
    lateLoad = lateLoad,
    unload = unload,
    initStrings = initStrings,
}
