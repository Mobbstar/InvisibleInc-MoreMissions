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
local itemdefs = include("sim/unitdefs/itemdefs")--------------------------------------------------------------------------------
-- Mole Insertion
--
-- Escort a mole to the personnel database.
-- Until the mole has assumed his identity (custom disguise), don't let him be seen. Then, mole must be escorted to a special exit
-- Witnesses (guards, drones, cameras) get WITNESS tooltip/tag
-- Guard and drone witnesses need their HUD wiped manually or killed.
-- Cameras and sighted drone witnesses need to be wiped at the Camera Database or destroyed
-- Guard witnesses can be killed or KO'd and injected with an AMNESIAC that scrambles their memory  (slow and confused when wake up)
-- Mission reward: intel bonuses for future  missions

-- Various todos:
-- Custom disguise unit -- scrapped?
-- Guarantee camera database spawns DONE
-- setAlerted hack DONE
-- code amnesiac (append of doInjection) DONE
-- make amnesiac itemdef DONE
-- code mission rewards (persistent daemon, possibly WE daemon server-like notification when it becomes active? DONE
--------------------------------------------------------------------------------
-- Local helpers
local MOLE_BONUS_FULL = 3		--how many missions you get the bonus if no witnesses
local MOLE_BONUS_PARTIAL = 1	--how many missions you get the bonus if witnesses
local PATROLS_REVEALED = 0.75	--which % of guards is revealed by that bonus

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

		if evData.unit:hasTag("mole") then
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
	-- TODO: Compile side-mission scientist, AGP sysadmin
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

		if evData.unit:hasTag("mole") then
			return evData.unit, seer
		else
			return false
		end
	end,
}

mole_insertion.existsLivingWitness = function(sim)
	--Guard or drone that has directly seen an agent.
	for unitID, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().witness and not unit:isDead() then
			return true
		end
	end
	return false
end

local function guardWitnessesAgent(script, sim)
	while true do
		_, agent, seer = script:waitFor( GUARD_SAW_MOLE )
		seer:getTraits().witness = true
		--TODO: Tabs get cleared too often on guards.
		seer:createTab( STRINGS.MOREMISSIONS.MISSIONS.MOLE.WITNESS_DETECTED, "" )

		if not sim:hasObjective( "kill_witness" ) then
			sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.MOLE.OBJ_KILL_WITNESS, "kill_witness" )
		end
	end
end

local function witnessDied(script, sim, mission)
	while true do
		_, witness = script:waitFor( WITNESS_DEAD )

		if not mission.existsLivingWitness(sim) then
			sim:removeObjective( "kill_witness" )
			sim:getNPC():removeAbility(sim, "MM_informant_witness") --despawn the UI "daemon"
		end
	end
end


-- spawn custom benefit
local agency = sim:getParams().agency

	
	--for mission_scoring.DoFinishMission in modinit
-- add bonus
local mole_insertion = include( scriptPath .. "/missions/mole_insertion" )
	
local mission_scoring = include("mission_scoring")
local DoFinishMission_old = mission_scoring.DoFinishMission
mission_scoring.DoFinishMission = function( sim, campaign, ... )
		local agency = sim:getParams().agency
	if sim:getTags().MM_informantMission then
		local bonus_duration = sim.MM_mole_duration_full or 3	-- maybe make customisable?
		if mole_insertion.existsLivingWitness(sim) then
			bonus_duration = sim.MM_mole_duration_partial or 1
		end
		local id = sim:getParams().campaignHours
		local intel_bonus = {
			id = id,
			-- durationMax = bonus_duration,
			duration = bonus_duration,
		}
		agency.MM_informant_bonus = agency.MM_informant_bonus or {}
		-- tick duration on existing mole bonuses
		for i=#agency.MM_informant_bonus, 1, -1 do --do not modify agency during serialisation, doFinishMission is fine because no more serialisable player actions are possible
			local mole_bonus = agency.MM_informant_bonus[i]
			if mole_bonus.duration then
				mole_bonus.duration = mole_bonus.duration - 1
			end
			if mole_bonus.duration <= 0 then
				table.remove(agency.MM_informant_bonus, i)
			end
		end
		-- add new mole bonus
		table.insert(agency.MM_informant_bonus, intel_bonus)
	end
	DoFinishMission_old( sim, campaign, ... )
end
	--------------------------------
	
local bonus_types = {
	[1] = "layout",
	[2] = "patrols",
	[3] = "consoles",
	[4] = "safes",
	[5] = "cameras",
	[6] = "daemons",	
}

mission.revealMoleBonus = function(sim, bonusType) --need to call on this from modinit
	local unitlist = {}
	local randomAgent = sim:nextRand(#sim:getPC():getUnits()) --it's turn 1 so just pick any agent so we have somewhere to display the float text
	local x0, y0 = randomAgent:getLocation()
	if bonusType == "layout" then
		sim._showOutline = true
		sim:dispatchEvent( simdefs.EV_WALL_REFRESH )
		if x0 and y0 then
			local color = {r=1,g=1,b=41/255,a=1}
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.UI.FLY_TXT.FACILITY_REVEALED,x=x0,y=y0,color=color,alwaysShow=true} )		
		end
	elseif bonusType == "patrols" then
		for _, unit in pairs( sim:getAllUnits() ) do 
			if sim:nextRand() <= (PATROLS_REVEALED or 0.75) then --don't tag all the guards, just most of them
				if unit:getPlayerOwner() ~= player and unit:getTraits().isGuard and not unit:getTraits().tagged then 										
					unit:setTagged() -- need to consider PE's hostile AI interaction..
					sim:dispatchEvent( simdefs.EV_UNIT_TAGGED, {unit = unit} )
					sim:getPC():glimpseUnit(unit:getID())
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
	end
	if #unitlist > 0 then
		sim:dispatchEvent( simdefs.EV_UNIT_MAINFRAME_UPDATE, {units=unitlist,reveal = true} )
	end
end
	
	local mission_util = include("sim/missions/mission_util")
	local makeAgentConnection_old = mission_util.makeAgentConnection
	mission_util.makeAgentConnection = function( script, sim, ... )
		-- spawn bonus
		makeAgentConnection_old(script, sim, ...)
		local MM_informant_bonus = sim:getParams().agency.MM_informant_bonus
		if MM_informant_bonus then
			for k,v in pairs(MM_informant_bonus) do
				local missionsLeft = v.bonus_duration - 1 --this is only for UI event purposes, for seed preservation reasons, wait until end of mission to actually update the ticker
				local randBonus = sim:nextRand(1,6)
				local bonus_type = bonus_types[randBonus]
				mole_insertion.revealMoleBonus(sim, bonus_type) -- dispatch bonus
				--handle UI event
				local mole_head = STRINGS.MOREMISSIONS.UI.MOLE_DAEMON_EVENT.MOLE_DAEMON_HEAD
				local mole_title = STRINGS.MOREMISSIONS.UI.MOLE_DAEMON_EVENT.MOLE_DAEMON_TITLE
				local mole_text = STRINGS.MOREMISSIONS.UI.MOLE_DAEMON_EVENT.MOLE_DAEMON_TXT .. STRINGS.MOREMISSIONS.UI.MOLE_DAEMON_EVENT.INTEL_TYPES[randBonus]
				
				local dialogParams = 
				{
					mole_head,
					mole_title,
					mole_text,
					"gui/icons/item_icons/icon-item_FTM_scanner.png",
					color = {r=0,g=0,b=1,a=1}				
				}
				
				sim:dispatchEvent( simdefs.EV_SHOW_DIALOG, { dialog = "programDialog", dialogParams = dialogParams } )
				sim:getNPC():addMainframeAbility( sim, "MM_informant_intel", nil, 0 )
				-- now modify the newly-spawned daemon with customised text info
				for i,ability in ipairs( sim:getNPC():getAbilities() ) do
					if (i == "MM_informant_intel") and not ability.MM_mole_checked then
						ability.MM_mole_checked = true
						ability.desc = util.sformat(ability.desc, missionsLeft)
						ability.shortdesc = ability.shortdesc .. STRINGS.MOREMISSIONS.UI.MOLE_DAEMON_EVENT.INTEL_TYPES[randBonus]
					end
				end
				
			end
		end
	end
	
-- for modinit
local simunit = include("sim/simunit")
local setAlerted_old = simunit.setAlerted
simunit.setAlerted = function( self, alerted, ... )
	if alerted == false then
		self:getTraits().alerted = alerted
		return false --override assertion error that disallows un-alerting already alert units
	end
	return setAlerted_old( self, alerted, ... )	
end

-- too much effort to make a new ability for the amnesiac so just append paralyze instead
local paralyze = abilitydefs.lookupAbility("paralyze")
local paralyze_executeAbility_old = paralyze.executeAbility
local paralyze_createToolTip_old = paralyze.createToolTip
paralyze.createToolTip = function( self, sim, abilityOwner, ...)
	if abilityOwner:getTraits().amnesiac then
		return abilityutil.formatToolTip(STRINGS.MOREMISSIONS.UI.TOOLTIPS.PARALYZE_AMNESIAC, util.sformat(STRINGS.MOREMISSIONS.UI.TOOLTIPS.PARALYZE_AMNESIAC_DESC,abilityOwner:getTraits().impare_AP), simdefs.DEFAULT_COST) --impare_AP 2 in itemdef traits
	end
	return paralyze_createToolTip_old( self, sim, abilityOwner, ... )
end

paralyze.executeAbility = function( self, sim, unit, userUnit, target, ... )
	paralyze_executeAbility_old( self, sim, unit, userUnit, target, ... )
	local targetUnit = sim:getUnit(target)
	targetUnit:setAlerted(false)
	targetUnit:getTraits().witness = nil
	--Funky Library takes care of impair AP stuff
end

-- degradable items
local inventory = include("sim/inventory")
local useItem_old = inventory.useItem
inventory.useItem = function( sim, unit, item, ... )
	if item:getTraits().usesLeft and (item:getTraits().usesLeft <= 1) then
		item:getTraits().disposable = true
	end
	useItem_old(sim, unit, item, ...)
	if item and item:getUnitOwner() then --in case already trashed
		if item:getTraits().usesLeft then
			item:getTraits().usesLeft = item:getTraits().usesLeft - 1
		end
	end
end

-- for itemdef:
createUpgradeParams = function( self, unit )
	return { traits = { usesLeft = unit:getTraits().usesLeft } }
end,

-- for commondefs
local function onItemTooltip(tooltip, unit)
	if unit:getTraits().usesLeft then
		tooltip:addAbility( "FRAGILE", util.sformat("This item will degrade after {1} {1:more use|more uses}.", unit:getTraits().usesLeft), "gui/icons/skills_icons/skills_icon_small/icon-item_safecracker_small.png", )
	end
end


----------------
local function despawnRedundantCameraDB(sim)
	local cameraDBs = {}
	for i,unit in pairs(sim:getAllUnits()) do
		if unit:getUnitData().id == "camera_core" then
			table.insert(cameraDBs, unit)
		end
	end
	if #cameraDBs > 1 then
		sim:warpUnit( cameraDBs[2], nil )
		sim:despawnUnit( cameraDBs[2] )
	end
end
--------------------------------------------------------------------------------
-- Mission definition

local mission = class( escape_mission )

function mission:init( scriptMgr, sim )
	despawnRedundantCameraDB(sim)
	escape_mission.init( self, scriptMgr, sim )
	sim:getTags().MM_informantMission = true -- for DoFinishMission
	sim.MM_mole_duration_full = MOLE_BONUS_FULL
	sim.MM_mole_duration_partial = MOLE_BONUS_PARTIAL
	--Eyewitnesses that directly see agents
	scriptMgr:addHook( "new_witness", guardWitnessesAgent)
	scriptMgr:addHook( "dead_witness", witnessDied)
	sim:getNPC():addMainframeAbility( sim, "MM_informant_witness", nil, 0 )
end

function mission.pregeneratePrefabs( cxt, tagSet )
    local prefabs = include( "sim/prefabs" )
    escape_mission.pregeneratePrefabs( cxt, tagSet )
    tagSet[1].fitnessSelect = prefabs.SELECT_HIGHEST
    table.insert( tagSet, { { "MM_distresscall_interrogation", detentionFitness }, fitnessSelect = prefabs.SELECT_HIGHEST })
end

function mission.generatePrefabs( cxt, candidates )
    local prefabs = include( "sim/prefabs" )   
	if cxt.params.side_mission and (cxt.params.side_mission == "transformer") then
		-- log:write("LOG params transformer2")
		cxt.params.side_mission = "data scrub"--nil
	end
	escape_mission.generatePrefabs( cxt, candidates )
	prefabs.generatePrefabs( cxt, candidates, "MM_cameradb", 1 ) --force-spawn a camera db, then later despawn any redundant one
end

table.insert( tagSet, { "exit_vault" } )
--


return mission
