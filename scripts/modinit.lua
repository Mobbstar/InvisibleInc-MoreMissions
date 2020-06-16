local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
-- local itemdefs = include ("sim/unitdefs/itemdefs")

--for unloading
local default_missiontags = array.copy(serverdefs.ESCAPE_MISSION_TAGS)

local function earlyInit( modApi )
	modApi.requirements = { "Contingency Plan", "Sim Constructor", "Function Library", "Advanced Guard Protocol", "Items Evacuation", "New Items And Augments" }
end

local function init( modApi )
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
	modApi:addGenerationOption("holostudio",  STRINGS.MOREMISSIONS.OPTIONS.HOLOSTUDIO , STRINGS.MOREMISSIONS.OPTIONS.HOLOSTUDIO_TIP, {noUpdate=true} )
	modApi:addGenerationOption("assassination",  STRINGS.MOREMISSIONS.OPTIONS.ASSASSINATION , STRINGS.MOREMISSIONS.OPTIONS.ASSASSINATION_TIP, {noUpdate=true, enabled = false} )
	modApi:addGenerationOption("landfill",  STRINGS.MOREMISSIONS.OPTIONS.LANDFILL , STRINGS.MOREMISSIONS.OPTIONS.LANDFILL_TIP, {noUpdate=true, enabled = false} )

	modApi:addGenerationOption("ea_hostage",  STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.MISSION_TITLE , STRINGS.MOREMISSIONS.LOCATIONS.EA_HOSTAGE.DESCRIPTION, {noUpdate=true, enabled = true} )
	
	-- modApi:addGenerationOption("distress_call",  STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.MISSION_TITLE , STRINGS.MOREMISSIONS.LOCATIONS.EA_HOSTAGE.DESCRIPTION, {noUpdate=true, enabled = true} )	--placeholder

	--modApi:addGenerationOption("tech_expo",  STRINGS.MOREMISSIONS_HOSTAGE.MISSIONS.HOSTAGE.MISSION_TITLE , STRINGS.MOREMISSIONS.LOCATIONS.EA_HOSTAGE.DESCRIPTION, {noUpdate=true, enabled = true} ) --placeholder
	--forgot to make an option for Distress Call... will do later

	-- abilities, for now simple override (I'm not smart enough to...)
	modApi:addAbilityDef( "hostage_rescuable", scriptPath .."/abilities/hostage_rescuable_2" ) -- to dest... okay maybe don't needed, we'll see

	do -- patch automatic tracker
		local trackerBoost = 0
		local aiplayer = include( "sim/aiplayer" )
		local _onEndTurn = aiplayer.onEndTurn
		function aiplayer:onEndTurn(sim)
			trackerBoost = sim.missionTrackerBoost or 0
			_onEndTurn(self, sim)
			trackerBoost = 0
		end

		local simengine = include( "sim/engine" )
		local _trackerAdvance = simengine.trackerAdvance
		function simengine:trackerAdvance(delta, ...)
			delta = delta + trackerBoost
			return _trackerAdvance(self, delta, ...)
		end
	end
	
	include( scriptPath .. "/idle" )
	include( scriptPath .. "/unitrig" )

end

--The implementation of array.removeAllElements is not optimal for our purposes, and we also need something to remove dupes, so might as well combine it all. -M
local function removeAllElementsAndDupes(t0, t1)
	local t2 = {}
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

local function load( modApi, options, params )
	--before doing anything, clean up
	unloadCommon( modApi, options )

    local scriptPath = modApi:getScriptPath()

	-- itemdefs moved to lateLoad to allow other mods to populate itemdefs for Tech Expo automatic template generation
	--local itemdefs = include( scriptPath .. "/itemdefs" )
	--for name, itemDef in pairs(itemdefs) do
		--modApi:addItemDef( name, itemDef )
	--end
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
	
	include( scriptPath .. "/missions/distress_call" )
	include( scriptPath .. "/missions/weapons_expo" )
	include( scriptPath .. "/missions/assassination" )
	include( scriptPath .. "/missions/ea_hostage" )	

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

	local sharedPrefabs = include( scriptPath .. "/prefabs/shared/prefabt" )
	modApi:addPrefabt(sharedPrefabs)
	sharedPrefabs = include( scriptPath .. "/prefabs/shared_assassination/prefabt" )
	modApi:addPrefabt(sharedPrefabs)
	local distressPrefabs = include( scriptPath .. "/prefabs/distress_call/prefabt" )
    modApi:addPrefabt(distressPrefabs)
	local weaponsExpoPrefabs = include( scriptPath .. "/prefabs/weaponsexpo/prefabt" )
    modApi:addPrefabt(weaponsExpoPrefabs)	

	--local koPrefabs = include( scriptPath .. "/prefabs/ko/prefabt" )
 	--modApi:addWorldPrefabt(scriptPath, "ko", koPrefabs)

	--local ftmPrefabs = include( scriptPath .. "/prefabs/ftm/prefabt" )
  	-- modApi:addWorldPrefabt(scriptPath, "ftm", ftmPrefabs)

	--local skPrefabs = include( scriptPath .. "/prefabs/sankaku/prefabt" )
  	--modApi:addWorldPrefabt(scriptPath, "sankaku", skPrefabs)

	--local plastechPrefabs = include( scriptPath .. "/prefabs/plastech/prefabt" )
    	--modApi:addWorldPrefabt(scriptPath, "plastech", plastechPrefabs)

	--and here comes the massive hacks! -M
	do --This one has to be in load() because the item evac mod overrides the ability each load. (as of 20-2-2, -M)
		local escape_ability = abilitydefs.lookupAbility("escape")
		local executeAbility = escape_ability.executeAbility
		escape_ability.executeAbility = function( self, sim, abilityOwner, ... )
			local bounties = {}
			local cell = sim:getCell( abilityOwner:getLocation() )
			if cell.exitID then
				for _, unit in pairs( sim:getAllUnits() ) do
					local c = sim:getCell( unit:getLocation() )
					if c and c.exitID and unit:getTraits().bounty and not unit:getTraits().bountyCollected then
						table.insert(bounties,unit)
						unit:getTraits().bountyCollected = true --flag to prevent double-counting (because we have to wrap the function on every load in case Item Evac is installed)
						if unit:getTraits().isObjective and sim:getPC() then
							sim:getPC():setEscapedWithObjective(true)
						end
					end
				end
			end

			executeAbility( self, sim, abilityOwner, ... )

			for i,unit in ipairs(bounties) do
				unit:returnItemsToStash(sim)
				sim:addMissionReward(simquery.scaleCredits( sim, unit:getTraits().bounty or 0 ))
				sim:warpUnit( unit, nil )
				sim:despawnUnit( unit )
			end
		end
	end

	----- Distress Call mission hackz - Hek. They need to be in Load too
	local mission_util = include("sim/missions/mission_util") --for Distress Call
	local doAgentBanter_old = mission_util.doAgentBanter
	mission_util.doAgentBanter = function(script,sim,cross_script,odds,returnIfFailed, ...)
		if sim:getParams().situationName == "distress_call" then
			--log:write("skipping banter")
			return
		end
		doAgentBanter_old(script,sim,cross_script,odds,returnIfFailed, ...)
	end

	local old_mission_util_makeAgentConnection = mission_util.makeAgentConnection
	mission_util.makeAgentConnection = function( script, sim, ... )
			old_mission_util_makeAgentConnection( script, sim, ... )
			sim:triggerEvent(simdefs.TRG_UNIT_DROPPED, {item=nil, unit=nil})
	end
	-----
	--Tech Expo hack0rz -Hek
	local stealCreditsAbility = abilitydefs.lookupAbility("stealCredits")
	local stealCredits_canUse_old = stealCreditsAbility.canUseAbility	
	--need custom hack here because the vanilla emp_safe trait does nothing for vault boxes
	abilitydefs._abilities.stealCredits.canUseAbility = function(self, sim, unit, userUnit, ...)
		local result = stealCredits_canUse_old (self,sim,unit,userUnit,...)
		if unit:getTraits().MM_emp_safe and (unit:getTraits().mainframe_status ~= "active") then
			return false, STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_EMP_SAFE
		end
		return result
	end	

	------ These four appends are necessary because vanilla weapons never have skill requirements or anything that checks for them before use
	local shootSingle = abilitydefs.lookupAbility("shootSingle")
	local shootSingle_canUse_old = shootSingle.canUseAbility
	shootSingle.canUseAbility = function( self, sim, ownerUnit, unit, targetUnitID, ... )
		local result, reason = shootSingle_canUse_old( self, sim, ownerUnit, unit, targetUnitID, ... )
		local weaponUnit = simquery.getEquippedGun( unit )
		if weaponUnit and weaponUnit:getRequirements() and (result == true) then
			for skill,level in pairs( weaponUnit:getRequirements() ) do
				if not unit:hasSkill(skill, level) and not unit:getTraits().useAnyItem then 

					local skilldefs = include( "sim/skilldefs" )
					local skillDef = skilldefs.lookupSkill( skill )            	

					return false, string.format( STRINGS.UI.TOOLTIP_REQUIRES_SKILL_LVL, util.toupper(skillDef.name), level )
				end
			end
		end
		return result, reason
	end
			
	local overwatch = abilitydefs.lookupAbility("overwatch")
	local overwatch_canUse_old = overwatch.canUseAbility
	overwatch.canUseAbility = function(self, sim, unit, ... )
		local result, reason = overwatch_canUse_old(self, sim, unit, ... )
		local weaponUnit = simquery.getEquippedGun(unit)
		if (result == true) and weaponUnit and weaponUnit:getRequirements()then		
			for skill,level in pairs( weaponUnit:getRequirements() ) do
				if not unit:hasSkill(skill, level) and not unit:getTraits().useAnyItem then 

					local skilldefs = include( "sim/skilldefs" )
					local skillDef = skilldefs.lookupSkill( skill )            	

					return false, string.format( STRINGS.UI.TOOLTIP_REQUIRES_SKILL_LVL, util.toupper(skillDef.name), level )
				end
			end	
		end
		return result, reason
	end
	
	local overwatchMelee = abilitydefs.lookupAbility("overwatchMelee")
	local overwatchMelee_canUse_old = overwatchMelee.canUseAbility
	overwatchMelee.canUseAbility = function( self, sim, unit, ... )

		local result, reason = overwatchMelee_canUse_old(self, sim, unit, ... )
		local tazerUnit = simquery.getEquippedMelee( unit )
		if result == true then
			if not unit:getPlayerOwner():isNPC() and tazerUnit then
				if tazerUnit:getRequirements() then
					for skill,level in pairs( tazerUnit:getRequirements() ) do
						if not unit:hasSkill(skill, level) and not unit:getTraits().useAnyItem then 

							local skilldefs = include( "sim/skilldefs" )
							local skillDef = skilldefs.lookupSkill( skill )            	

							return false, string.format( STRINGS.UI.TOOLTIP_REQUIRES_SKILL_LVL, util.toupper(skillDef.name), level )
						end
					end
				end			
			
			end
		end
		return result, reason
	end

	local melee = abilitydefs.lookupAbility("melee")
	local melee_canUse_old = melee.canUseAbility
	melee.canUseAbility = function(self, sim, unit, userUnit, targetID, ...)
		local result, reason = melee_canUse_old(self, sim, unit, userUnit, targetID, ...)
		local tazerUnit = simquery.getEquippedMelee( unit )
		if (result == true) and targetID and tazerUnit then
			local targetUnit = sim:getUnit(targetID)

			if tazerUnit:getRequirements() then
				for skill,level in pairs( tazerUnit:getRequirements() ) do
					if not unit:hasSkill(skill, level) and not unit:getTraits().useAnyItem then 

						local skilldefs = include( "sim/skilldefs" )
						local skillDef = skilldefs.lookupSkill( skill )            	

						return false, string.format( STRINGS.UI.TOOLTIP_REQUIRES_SKILL_LVL, util.toupper(skillDef.name), level )
					end
				end
			end					
		end
		return result, reason
	end	
	--------	

end

local function lateLoad( modApi, options, params )
	local scriptPath = modApi:getScriptPath()
	local itemdefs = include( scriptPath .. "/itemdefs" )
	for name, itemDef in pairs(itemdefs) do
		modApi:addItemDef( name, itemDef )
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
    load = load,
    lateLoad = lateLoad,
    unload = unload,
    initStrings = initStrings,
}
