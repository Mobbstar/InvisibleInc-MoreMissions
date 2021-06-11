local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local assassination_mission = {}
--for unloading
local default_missiontags = array.copy(serverdefs.ESCAPE_MISSION_TAGS)

local function earlyInit( modApi )
	modApi.requirements = { "Contingency Plan", "Sim Constructor", "Function Library", "Advanced Guard Protocol", "Items Evacuation", "New Items And Augments","Advanced Cyberwarfare","Programs Extended","Offbrand Programs","Switch Content Mod", "Interactive Events" }
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
	-- modApi:addGenerationOption("holostudio",  STRINGS.MOREMISSIONS.OPTIONS.HOLOSTUDIO , STRINGS.MOREMISSIONS.OPTIONS.HOLOSTUDIO_TIP, {noUpdate=true, enabled = false} )
	modApi:addGenerationOption("assassination",  STRINGS.MOREMISSIONS.OPTIONS.ASSASSINATION , STRINGS.MOREMISSIONS.OPTIONS.ASSASSINATION_TIP, {noUpdate=true} )
	-- modApi:addGenerationOption("landfill",  STRINGS.MOREMISSIONS.OPTIONS.LANDFILL , STRINGS.MOREMISSIONS.OPTIONS.LANDFILL_TIP, {noUpdate=true, enabled = false} )
	modApi:addGenerationOption("ea_hostage",  STRINGS.MOREMISSIONS.OPTIONS.EA_HOSTAGE , STRINGS.MOREMISSIONS.OPTIONS.EA_HOSTAGE_TIP, {noUpdate=true, enabled = true} )
	modApi:addGenerationOption("distress_call",  STRINGS.MOREMISSIONS.OPTIONS.DISTRESSCALL, STRINGS.MOREMISSIONS.OPTIONS.DISTRESSCALL_TIP, {noUpdate=true, enabled = true} )
	modApi:addGenerationOption("weapons_expo",  STRINGS.MOREMISSIONS.OPTIONS.WEAPONSEXPO, STRINGS.MOREMISSIONS.OPTIONS.WEAPONSEXPO_TIP, {noUpdate=true, enabled = true} )
	modApi:addGenerationOption("mole_insertion",  STRINGS.MOREMISSIONS.OPTIONS.MOLE_INSERTION, STRINGS.MOREMISSIONS.OPTIONS.MOLE_INSERTION_TIP, {noUpdate=true, enabled = true} )
	modApi:addGenerationOption("ai_terminal",  STRINGS.MOREMISSIONS.OPTIONS.AI_TERMINAL, STRINGS.MOREMISSIONS.OPTIONS.AI_TERMINAL_TIP, {noUpdate=true, enabled = true} )	
	
	modApi:addGenerationOption("MM_easy_mode",  STRINGS.MOREMISSIONS.OPTIONS.EASY_MODE , STRINGS.MOREMISSIONS.OPTIONS.EASY_MODE_TIP, {enabled = false, noUpdate=true} )
	
	modApi:addGenerationOption("MM_sidemissions",  STRINGS.MOREMISSIONS.OPTIONS.SIDEMISSIONS , STRINGS.MOREMISSIONS.OPTIONS.SIDEMISSIONS_TIP, {noUpdate=true} ) --doesn't do anything yet
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

	
	-- for Assassination mission: ensure lethal laser grids in saferoom prefab
	local simengine = include("sim/engine")
	local oldInit = simengine.init
	
	function simengine.init( self, params, levelData, ... )
		self._levelOutput = levelData:parseBoard( params.seed, params )	
		if params.situationName == "assassination" then
			for i, unit in pairs(self._levelOutput.units) do
				if unit.template and unit.unitData and unit.unitData.traits and unit.unitData.traits.lethal_laser then
					unit.template = "security_laser_emitter_1x1"
				end
			end
		end
		oldInit( self, params, levelData, ... )	
	end	

	--cannot set display string... local variable only -M
	table.insert(modApi.mod_manager.credit_sources, "assassinationreward")
  
	-- SIDE MISSIONS
	local showItemStore = abilitydefs.lookupAbility( "showItemStore")
	local showItemStore_executeOld = showItemStore.executeAbility
	
	showItemStore.executeAbility = function( self, sim, unit, userUnit, ... )
	-- note: unit is nanofab, userUnit is agent
		if unit:getTraits().storeType and (unit:getTraits().storeType == "large") and unit:getTraits().luxuryNanofab and sim.luxuryNanofabItemType then
			
			local strings_screens = include( "strings_screens" )
			sim.old_augmenttip, sim.old_weapontip, sim.old_itemtip = strings_screens.STR_346165218, strings_screens.STR_2618909495, strings_screens.STR_590530336
			local itemType = sim.luxuryNanofabItemType
			local new_tooltip = [[]]
			if itemType == 1 then
				new_tooltip = [[ITEMS]]
			elseif itemType ==2 then
				new_tooltip = [[AUGMENTS]]
			elseif itemType == 3 then
				new_tooltip = [[WEAPONS]]
			end
			
			strings_screens.STR_346165218 = new_tooltip
			strings_screens.STR_2618909495 = new_tooltip
			strings_screens.STR_590530336 = new_tooltip		
		
		end
		
		showItemStore_executeOld(self, sim, unit, userUnit, ...)
	end	
				
	-- inverted spawn fitness check allows existing generatePrefabs worldgen functions to maximise distance to a prefab tag specified in mission.
	local prefabs = include("sim/prefabs")
	local generatePrefabs_old = prefabs.generatePrefabs
	prefabs.generatePrefabs = function( cxt, candidates, tag, maxCount, fitnessFn, fitnessSelect, ... )
		if not fitnessFn and cxt.defaultFitnessFn and cxt.defaultFitnessSelect and cxt.defaultFitnessFn[tag] and cxt.defaultFitnessSelect[tag] then
			fitnessFn = cxt.defaultFitnessFn[tag]
			fitnessSelect = cxt.defaultFitnessSelect[tag]
			if cxt.maxCountOverride[tag] then
				maxCount = cxt.maxCountOverride[tag]
			end
			-- local oldMaxCount = maxCount
			-- maxCount = 1
			-- for i = (oldMaxCount - 1), 1, -1 do
				-- generatePrefabs_old( cxt, candidates, tag, maxCount, fitnessFn, fitnessSelect, ... ) --needed so BOTH guard exits spawn far from mole prefab. Re-run function as many times as original maxCount
			-- end
		end

		generatePrefabs_old( cxt, candidates, tag, maxCount, fitnessFn, fitnessSelect, ... )
	end

	-- END OF MOLE INSERTION	
	
	include( scriptPath .. "/simquery" )
	include( scriptPath .. "/engine" )
	include( scriptPath .. "/idle" )
	include( scriptPath .. "/laser" )
	include( scriptPath .. "/pcplayer" )
	include( scriptPath .. "/unitrig" )

	include( scriptPath .. "/btree/actions" )
	include( scriptPath .. "/btree/conditions" )
	include( scriptPath .. "/btree/bountytargetbrain" )
	
	include( scriptPath.."/simdefs" ) -- copied from Interactive Events & expanded to support up to 8 buttons
	include( scriptPath.."/hud" )--from Interactive Events, required for modal dialog choice menu to work properly
	
	-- AI TERMINAL
	local modifyPrograms = include( scriptPath .. "/abilities/mainframe_abilities" )
	modifyPrograms()	
	-- double-included here in init and in lateLoad to catch both vanilla overrides and mod additions. Upgraded programs with abilityOverride such as Fusion DO NOT WORK without this line!
end


local function lateInit( modApi )
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()
	-- MOLE_INSERTION
	-- custom intelligence benefit
	-- DoFinishMission: tick and despawn existing intel bonuses if needed
	local mole_insertion = include( scriptPath .. "/missions/mole_insertion" ) -- included in init so function appends can already reference it
	local mission_scoring = include("mission_scoring")
	local DoFinishMission_old = mission_scoring.DoFinishMission
	mission_scoring.DoFinishMission = function( sim, campaign, ... )
		local agency = sim:getParams().agency
	
		--update existing informant bonuses
		-- bonus doesn't apply in Omni missions so don't tick down
		if not ((sim:getParams().world == "omni") or (sim:getParams().world == "omni2")) then
			agency.MM_informant_bonus = agency.MM_informant_bonus or {}
			-- tick duration on existing mole bonuses
			for i=#agency.MM_informant_bonus, 1, -1 do --do not modify agency during serialisation, doFinishMission is fine because no more serialisable player actions are possible
				local mole_bonus = agency.MM_informant_bonus[i]
				log:write("LOG DoFinishMission mole bonus")
				log:write(util.stringize(mole_bonus,2))
				if mole_bonus.missions_left then
					if mole_bonus.missions_left then
						log:write("LOG ticking down missions_left")
						mole_bonus.missions_left = mole_bonus.missions_left - 1
					end
					if mole_bonus.missions_left <= 0 then
						log:write("LOG removing bonus")
						table.remove(agency.MM_informant_bonus, i)
					end
				end
			end
		end
		
		-- remove existing Distress Call missions, THEN run the old function that might add new ones.
		for i = #campaign.situations, 1, -1 do
			local situation = campaign.situations[i]
			if situation.name == "distress_call" then
				table.remove( campaign.situations, i )
			end
		end

		-- add new bonus from mission just completed, if relevant
		if sim:getTags().MM_informantMission and sim:getTags().MM_informant_success then
			local missions_left = sim.MM_mole_duration_full or 3	-- maybe make customisable?
			if mole_insertion.existsLivingWitness(sim) then
				missions_left = sim.MM_mole_duration_partial or 1
			end
			local id = sim:getParams().campaignHours
			local intel_bonus = {
				id = id,
				missions_left = missions_left,
			}
			-- add new mole bonus
			table.insert(agency.MM_informant_bonus, intel_bonus)
		end
		
		-- ASSASSINATION
		if (sim:getParams().situationName == "assassination") and sim:getTags().MM_assassination_success then -- or some other mission type check, as well as a mission success check
		
			-- this is for modifying the difficulty of newly-spawned ones, in case we also want this
			campaign.MM_assassination  = campaign.MM_assassination or {}
			local world = sim:getParams().world
			if campaign.MM_assassination[world] == nil then
				campaign.MM_assassination[world] = 0
			end
			
			campaign.MM_assassination[world] = campaign.MM_assassination[world] + 1
			
			-- this is for modifying the difficulty of existing ones
			local situations = campaign.situations

			for i, sitch in pairs(situations) do
				local corpData = serverdefs.getCorpData( sitch )
				if corpData.world == sim:getParams().world then
					-- if sitch.difficulty > 1 then
						sitch.difficulty = sitch.difficulty + 1
					-- end
				end
			end
		end
		
		local returnvalue = DoFinishMission_old( sim, campaign, ... )

		if sim._assassinationReward then
			-- if sim._resultTable.credits_gained.hostage then
				-- sim._resultTable.credits_gained.hostage = sim._resultTable.credits_gained.hostage - sim._assassinationReward
			-- end
			sim._resultTable.credits_gained.assassinationreward = sim._assassinationReward
		end

		return returnvalue
	end
	
	--other part in load

	local spawn_mole_bonus = include( scriptPath .. "/spawn_mole_bonus" )
	-- start of mission: spawn intel bonuses if player has completed a mole mission
	--needs to run after FuncLib inits
	local mission_util = include("sim/missions/mission_util")
	local makeAgentConnection_old = mission_util.makeAgentConnection
	mission_util.makeAgentConnection = function( script, sim, ... )
		-- spawn bonus
		log:write("LOG makeAgentConnection append")
		makeAgentConnection_old(script, sim, ...)
		spawn_mole_bonus( sim, mole_insertion )
	end
	-- Similar edit is done in Load to mid_1!
	
	-- setAlerted edit to allow un-alerting for Amnesiac function
	local simunit = include("sim/simunit")	
	local simunit_setAlerted_old = simunit.setAlerted
	simunit.setAlerted = function( self, alerted, ... )
		if self and self:getTraits().MM_amnesiac and self._sim then
			self:getTraits().alerted = nil
			self:getTraits().MM_amnesiac = nil --clear the trait after it's used
		else
			return simunit_setAlerted_old( self, alerted, ... )
		end
	end	
	
	-- for clearing mainframe witnesses
	local processEMP_old = simunit.processEMP
	simunit.processEMP = function( self, bootTime, noEmpFX, ... )
		processEMP_old( self, bootTime, noEmpFX, ... )
		if self:getTraits().witness then
			self:getTraits().witness = nil
			local x0, y0 = self:getLocation()
			if x0 and y0 then
				self._sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(STRINGS.MOREMISSIONS.UI.WITNESS_CLEARED),x=x0,y=y0,color={r=1,g=1,b=1,a=1}} )
			end
		end
	end
	
	local simdrone = include("sim/units/simdrone")
	local simdrone_processEMP_old = simdrone.processEMP
	simdrone.processEMP = function(self, empTime, noEmpFx, noAttack)
		log:write("LOG custom process EMP drone")
		simdrone_processEMP_old(self, empTime, noEmpFx, noAttack)
		if self:getTraits().witness then
			self:getTraits().witness = nil
			local x0, y0 = self:getLocation()
			if x0 and y0 then
				self._sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(STRINGS.MOREMISSIONS.UI.WITNESS_CLEARED),x=x0,y=y0,color={r=1,g=1,b=1,a=1}} )
			end
		end		
	end	

	-- update stopHacking to refresh database hacking state
	local stopHacking_old = simunit.stopHacking
	simunit.stopHacking = function(self, sim, ... ) --refreshes the hacking anim state for the mole's database hack. we don't care about legit uses of monster_hacking because that's handled by ending_1
		stopHacking_old( self, sim, ... )
		if self:getTraits().monster_hacking then 
			local target = sim:getUnit(self:getTraits().monster_hacking)
			if target:getTraits().MM_personneldb or target:getTraits().MM_camera_core then
				self:getTraits().data_hacking = nil
				self:getSounds().spot = nil
				sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self })
			end
		end	
	end
	
	-- this keeps the personnel DB hack from erroneously triggering actual data bank hacking scripts
	local simunit_progressHack_old = simunit.progressHack
	simunit.progressHack = function( self, ... )
		if self:getTraits().MM_personneldb then
			return
		end
		return simunit_progressHack_old( self, ... )
	end	

	-- Amnesiac function as append of paralyze
	local paralyze = abilitydefs.lookupAbility("paralyze")
	local paralyze_executeAbility_old = paralyze.executeAbility
	local paralyze_createToolTip_old = paralyze.createToolTip
	paralyze.createToolTip = function( self, sim, abilityOwner, ...)
		if abilityOwner:getTraits().amnesiac then
			return abilityutil.formatToolTip(STRINGS.MOREMISSIONS.UI.TOOLTIPS.PARALYZE_AMNESIAC, util.sformat(STRINGS.MOREMISSIONS.UI.TOOLTIPS.PARALYZE_AMNESIAC_DESC,abilityOwner:getTraits().impare_sight), simdefs.DEFAULT_COST) --impare_AP 2 [sic] in itemdef traits
		end
		return paralyze_createToolTip_old( self, sim, abilityOwner, ... )
	end

	paralyze.executeAbility = function( self, sim, unit, userUnit, target, ... )
		paralyze_executeAbility_old( self, sim, unit, userUnit, target, ... )
		local targetUnit = sim:getUnit(target)
		local x0, y0 = targetUnit:getLocation()
		if x0 and y0 and targetUnit:getTraits().witness then
			targetUnit:getTraits().MM_amnesiac = true
			targetUnit:getTraits().witness = nil
			sim:triggerEvent( "used_amnesiac", { userUnit = userUnit, targetUnit = targetUnit } )
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=util.sformat(STRINGS.MOREMISSIONS.UI.WITNESS_CLEARED),x=x0,y=y0,color={r=1,g=1,b=0,a=1}} )
		end		
		--Funky Library takes care of impair AP stuff
	end
	
	-- ASSASSINATION bodyguard
	local simunit_onDamage_old = simunit.onDamage
	simunit.onDamage = function( self, damage, ... )
		simunit_onDamage_old( self, damage, ... )
		if self and self:isValid() and self:getLocation() and not self:getTraits().isDead and (self:getTraits().MM_bodyguard or self:getTraits().MM_bounty_target) then
			if not self:isKO() then
				self:getSim():dispatchEvent( simdefs.EV_UNIT_HIT, {unit = self, result = 0} ) --stagger FX
			end
		end
	end
	
	local simengine = include("sim/engine")
	local simengine_tryShootAt_old = simengine.tryShootAt
	simengine.tryShootAt = function( self, sourceUnit, targetUnit, dmgt0, equipped, ... )
		if targetUnit:getTraits().MM_bounty_disguise 
		-- and not equipped:getTraits().canTag 
		then
			local newTarget = assassination_mission.getOpposite( self, targetUnit )
			if newTarget then
				assassination_mission.bodyguardSwap( self ) --this clears MM_bounty_disguise trait on both!
				log:write("LOG swapping")
				targetUnit = newTarget
			-- we want the swap to happen no matter who is attacked or what kind of attack it is
			end
		end
		simengine_tryShootAt_old( self, sourceUnit, targetUnit, dmgt0, equipped, ... )
	end	
	
	local simengine_hitUnit_old = simengine.hitUnit
	simengine.hitUnit = function( self, sourceUnit, targetUnit, dmgt, ... )
		--hitUnit is called as part of tryShootAt but it's also called in other cases so we need to cover those as well
		if targetUnit:getTraits().MM_bounty_disguise then
			local newTarget = assassination_mission.getOpposite( self, targetUnit )
			if newTarget then
				assassination_mission.bodyguardSwap( self )
				targetUnit = newTarget
			-- we want the swap to happen no matter who is attacked or what kind of attack it is
			end			
		end
		simengine_hitUnit_old( self, sourceUnit, targetUnit, dmgt, ... )			
	end
	

	local simunit_setKO_old = simunit.setKO --for flash grenade
	simunit.setKO = function( self, sim, ticks, fx, ... )
		if self:getTraits().MM_bounty_disguise then
			local newTarget = assassination_mission.getOpposite( sim, self )
			if newTarget then
				assassination_mission.bodyguardSwap( sim )
				self = newTarget
			end
		end
		return simunit_setKO_old( self, sim, ticks, fx, ... )
	end	
		
	-- FOR TECH EXPO CUSTOM ITEM
	local icebreak = abilitydefs.lookupAbility("icebreak")
	local icebreak_executeAbility_old = icebreak.executeAbility
	icebreak.executeAbility = function( self, sim, unit, userUnit, target, ... ) --this might be worth moving to FuncLib...
		if unit:getTraits().killDaemon then
			local targetUnit = sim:getUnit(target)	
			targetUnit:getTraits().mainframe_program = nil
			sim:dispatchEvent( simdefs.EV_KILL_DAEMON, {unit = targetUnit})	
			if targetUnit:getTraits().daemonHost then
				sim:getUnit(targetUnit:getTraits().daemonHost):killUnit(sim)
				targetUnit:getTraits().daemonHost =nil
			end
		end	
		icebreak_executeAbility_old( self, sim, unit, userUnit, target, ... )
	end
	
	local use_stim = abilitydefs.lookupAbility( "use_stim" )
	local use_stim_executeAbitlity_old = use_stim.executeAbility
	use_stim.executeAbility = function( self, sim, unit, userUnit, target )
		use_stim_executeAbitlity_old( self, sim, unit, userUnit, target )
		local targetUnit = sim:getUnit(target)
		if unit:getTraits().impair_agent_AP and targetUnit:getTraits().mpMax then
			targetUnit:getTraits().mpMax = math.max(targetUnit:getTraits().mpMax - unit:getTraits().impair_agent_AP, 4)
		end	
	end
	
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

	if params then
		params.mm_enabled = true
		if options["MM_easy_mode"] and options["MM_easy_mode"].enabled then
			params.MM_difficulty = "easy"
		elseif options["MM_easy_mode"] and not options["MM_easy_mode"].enabled then
			params.MM_difficulty = "hard"
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
	
	local side_missions = include( scriptPath .. "/side_missions" )
	if options["MM_sidemissions"].enabled then
		modApi:addEscapeScripts(side_missions.escape_scripts)
		modApi:addSideMissions(scriptPath, side_missions.SIDEMISSIONS )	
	end	
	
	modApi:addAbilityDef( "MM_hack_personneldb", scriptPath .."/abilities/MM_hack_personneldb" )
	modApi:addAbilityDef( "MM_escape_guardelevator", scriptPath .."/abilities/MM_escape_guardelevator" )
	modApi:addAbilityDef( "MM_scrubcameradb", scriptPath .."/abilities/MM_scrubcameradb" )	
	modApi:addAbilityDef( "MM_W93_incogRoom_unlock", scriptPath .."/abilities/MM_W93_incogRoom_unlock" )
	modApi:addAbilityDef( "MM_W93_incogRoom_upgrade", scriptPath .."/abilities/MM_W93_incogRoom_upgrade" )
	
	include( scriptPath .. "/missions/distress_call" )
	include( scriptPath .. "/missions/weapons_expo" )
	local assassination = include( scriptPath .. "/missions/assassination" )
	include( scriptPath .. "/missions/ea_hostage" )	
	-- include( scriptPath .. "/missions/mole_insertion" ) -- mole_insertion included in init instead
	include( scriptPath .. "/missions/mission_util" )
	
	assassination_mission.bodyguardSwap = assassination.bodyguardSwap
	assassination_mission.getOpposite = assassination.getOpposite

	-- local mainframe_abilities = include( scriptPath .. "/mainframe_abilities" )
	-- for name, ability in pairs(mainframe_abilities) do
		-- modApi:addMainframeAbility( name, ability )
	-- end
	local npc_abilities = include( scriptPath .. "/abilities/npc_abilities" )
	for name, ability in pairs(npc_abilities) do
		modApi:addDaemonAbility( name, ability )
	end

	-- modApi:addAbilityDef( "inject_lethal", scriptPath .."/abilities/inject_lethal" )

	-- include( scriptPath .. "/simunits" )

	-- local corpworldPrefabs = include( scriptPath .. "/prefabs/corpworld/prefabt" )
	-- modApi:addWorldPrefabt(scriptPath, "corpworld", corpworldPrefabs)

	local escape_mission = include( scriptPath .. "/escape_mission" )
	modApi:addEscapeScripts(escape_mission)

	-- custom SIMUNITS
	include(scriptPath.."/simKOcloud")
	include(scriptPath.."/MM_simemppack_pulse")
	include(scriptPath.."/MM_simfraggrenade")
	
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
		--if sim:getParams().situationName == "distress_call" then
		if sim:hasTag("skipBanter") then
			--log:write("skipping banter")
			return
		end
		doAgentBanter_old(script,sim,cross_script,odds,returnIfFailed, ...)
	end

	local old_mission_util_makeAgentConnection = mission_util.makeAgentConnection
	mission_util.makeAgentConnection = function( script, sim, ... )
			-- for Distress Call
			old_mission_util_makeAgentConnection( script, sim, ... )
			-- sim:triggerEvent(simdefs.TRG_UNIT_DROPPED, {item=nil, unit=nil})
			sim:triggerEvent( "agentConnectionDone" )
			--...
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
		local result, reason1, reason2, reason3 = shootSingle_canUse_old( self, sim, ownerUnit, unit, targetUnitID, ... )
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
		return result, reason1, reason2, reason3
	end
			
	local overwatch = abilitydefs.lookupAbility("overwatch")
	local overwatch_canUse_old = overwatch.canUseAbility
	overwatch.canUseAbility = function(self, sim, unit, ... )
		local result, reason1, reason2, reason3 = overwatch_canUse_old(self, sim, unit, ... )
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
		return result, reason1, reason2, reason3
	end
	
	local overwatchMelee = abilitydefs.lookupAbility("overwatchMelee")
	local overwatchMelee_canUse_old = overwatchMelee.canUseAbility
	overwatchMelee.canUseAbility = function( self, sim, unit, ... )

		local result, reason1, reason2, reason3 = overwatchMelee_canUse_old(self, sim, unit, ... )
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
		return result, reason1, reason2, reason3
	end

	local melee = abilitydefs.lookupAbility("melee")
	local melee_canUse_old = melee.canUseAbility
	melee.canUseAbility = function(self, sim, unit, userUnit, targetID, ...)
		local result, reason1, reason2, reason3 = melee_canUse_old(self, sim, unit, userUnit, targetID, ...)
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
		return result, reason1, reason2, reason3
	end	
	-- Assassination
	local melee_executeOld = melee.executeAbility
	melee.executeAbility = function( self, sim, unit, userUnit, target, ... )
		local targetUnit = sim:getUnit(target)
		if targetUnit:getTraits().MM_bounty_disguise then
			local newTarget = assassination_mission.getOpposite( sim, targetUnit )
			if newTarget then
				sim:dispatchEvent( simdefs.EV_UNIT_STOP_WALKING, { unit = targetUnit  } ) --interrupt old target, without this old target glides to new target's location during swap XD
				assassination_mission.bodyguardSwap( sim )
				target = newTarget:getID()
			end
		end
		return melee_executeOld( self, sim, unit, userUnit, target, ... )
	end
		
	--------
	-- MOLE INSERTION
	local mole_insertion = include( scriptPath .. "/missions/mole_insertion" )
	local spawn_mole_bonus = include( scriptPath .. "/spawn_mole_bonus" )
	reinclude = include --necessary for tweaking mid_1
	if serverdefs.SITUATIONS["mid_2"] then
		local mid_1 = include(serverdefs.SITUATIONS["mid_2"].scriptPath.."mid_1")
		local mid_1_initOld = mid_1.init
		if not mid_1.MM_append then --lazy way to prevent double-appending in load
			mid_1.MM_append = true
			mid_1.init = function( self, scriptMgr, sim )
				mid_1_initOld( self, scriptMgr, sim )
				-- log:write("LOG new mid_1 init")
				local startPhase_old = nil
				for i, hook in ipairs(scriptMgr.hooks) do
					if hook.name == "MID_1" then
						-- log:write("LOG found MID_1 hook")
						-- log:write(util.stringize(hook,3))
						startPhase_old = hook
					end
				end
				if startPhase_old then
					-- log:write("LOG adding new hook")
					local newStartPhase = function( scriptMgr, sim )
						startPhase_old.hookFn( scriptMgr, sim )
						-- scriptMgr:queue( 5*cdefs.SECONDS ) --this does nothing...
						spawn_mole_bonus( sim, mole_insertion )
						-- log:write("LOG new mid1 start phase running")
					end
					scriptMgr:removeHook( startPhase_old )
					scriptMgr:addHook( "MID_1", newStartPhase )--append hookFn by removing and readding the hook

				end
			end	
		end
	end	
	
	-- default weight for missions with no weight is 1, but the function doesn't accept weight less than 1. Set it to 100 instead so we can make missions both less frequent and more frequent than the vanilla unweighted ones without overriding the rest of the function. 
	local serverdefs_chooseSituation_old = serverdefs.chooseSituation
	serverdefs.chooseSituation = function( campaign, tags, gen, ... )
		for name, situationData in pairs( serverdefs.SITUATIONS ) do
			if situationData.weight == nil then
				situationData.weight = 100
			end
		end 
		return serverdefs_chooseSituation_old( campaign, tags, gen, ... )
	end
	
	--ASSASSINATION
	local serverdefs_createNewSituation_old = serverdefs.createNewSituation
	serverdefs.createNewSituation = function( campaign, gen, tags, difficulty )
		local newSituation =  serverdefs_createNewSituation_old(campaign, gen, tags, difficulty )

		if newSituation then
			local corp = serverdefs.MAP_LOCATIONS[newSituation.mapLocation].corpName
			if campaign.MM_assassination and campaign.MM_assassination[corp] then
				-- SimConstructor resets serverdefs with every load, hence this function wrap only applies once despite being in mod-load. If SimConstructor ever changes, this must too.
				newSituation.difficulty = newSituation.difficulty + campaign.MM_assassination[corp]
				
				-- for Secure Holding Facility: check if there is a viable location. If not, lift the requirement for proximity.
				if array.find(tags, "close_by") then
					local availableLocationsTemp = {}
					for i, location in ipairs( serverdefs.MAP_LOCATIONS) do
						assert( location.name )
						if serverdefs.defaultMapSelector( campaign, tags, location ) then
							table.insert( availableLocationsTemp, i )
						end
					end		
					if not (#availableLocationsTemp > 0) then
						table.insert(tags, "close_by_nevermind")
					end
				end
			end
		end
		
		return newSituation
	end	
	
	--SECURE HOLDING FACILITY	
	local serverdefs_defaultMapSelector_old = serverdefs.defaultMapSelector
	serverdefs.defaultMapSelector = function( campaign, tags, tempLocation )
		if array.find(tags, "close_by") and not array.find(tags, "close_by_nevermind") then
			local MAX_DIST = 6 -- 6 hour distance
			local dist = serverdefs.trueCalculateTravelTime( serverdefs.MAP_LOCATIONS[ campaign.location ], tempLocation, campaign )
			--log:write(tostring(dist))
			if dist > MAX_DIST then
				return false
			end		
		end

		return serverdefs_defaultMapSelector_old( campaign, tags, tempLocation)
	
	end		

end

local function lateLoad( modApi, options, params )
	local scriptPath = modApi:getScriptPath()
	local tech_expo_itemdefs = include( scriptPath .. "/tech_expo_itemdefs" )
	for name, itemDef in pairs(tech_expo_itemdefs.generateTechExpoGear()) do
		modApi:addItemDef( name, itemDef )
	end

	-- AI TERMINAL
	local modifyPrograms = include( scriptPath .. "/abilities/mainframe_abilities" )
	modifyPrograms()
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
    load = load,
    lateLoad = lateLoad,
    unload = unload,
    initStrings = initStrings,
}
