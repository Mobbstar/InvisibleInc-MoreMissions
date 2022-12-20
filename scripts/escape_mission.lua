local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local mission_util = include( "sim/missions/mission_util" )
local unitdefs = include( "sim/unitdefs" )
local simfactory = include( "sim/simfactory" )
local itemdefs = include( "sim/unitdefs/itemdefs" )
local propdefs = include( "sim/unitdefs/propdefs" )
local serverdefs = include( "modules/serverdefs" )
local SCRIPTS = include('client/story_scripts')
local modifiers = include( "sim/modifiers" )
local abilitydefs = include( "sim/abilitydefs" )
local simability = include( "sim/simability" )
local strings_screens = include( "strings_screens" )
local escape_mission = include("sim/missions/escape_mission")
---------------------------------------------------------------------------
local DRONE_BANTER_CHANCE = 0.3

--local helpers
local 	PC_WON = --now unused
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
	
--VANILLA REBALANCES
local REFIT_DRONE_SPAWNED = 
{
	trigger = simdefs.TRG_UNIT_WARP,
	fn = function( sim, triggerData )
		if triggerData.unit:getTraits().refit_drone and (triggerData.from_cell == nil) then
			return triggerData.unit
		end
	end
}

local REFIT_DRONE_ESCAPED =
{
	trigger = simdefs.TRG_UNIT_ESCAPED,
	fn = function( sim, triggerUnit )
		if triggerUnit:getTraits().refit_drone then
			return triggerUnit
		end
	end
}

local DRONE_BOOTED =
{
	trigger = simdefs.TRG_UNIT_KO,
	fn = function( sim, triggerData )
		if triggerData.unit:getTraits().refit_drone and (triggerData.ticks == nil) then
			return triggerData.unit
		end
	end
}

local function doDroneBanter( script, sim, unit )
	local drone_lines = STRINGS.MOREMISSIONS.AGENT_LINES.SIDE_MISSIONS.REFIT_DRONE
	local drone_txt = drone_lines[sim:nextRand(1,#drone_lines)]
	script:queue( { type="clearEnemyMessage" } )	
	script:queue( {
		body=drone_txt,
		header = unit:getName(),
		type = "enemyMessage",
		profileAnim = unit:getUnitData().profile_anim,
		profileBuild = unit:getUnitData().profile_build or unit:getUnitData().profile_anim,
		} )
	script:queue( 5 * cdefs.SECONDS )
	script:queue( { type="clearEnemyMessage" } )	
end

local function updateRefitDrone( script, sim )
	local _, drone = script:waitFor( REFIT_DRONE_SPAWNED )
	local refit_drone_names = STRINGS.MOREMISSIONS.UI.REFIT_DRONE_NAMES
	drone:getTraits().mpMax = drone:getTraits().mpMax + 2
	local name = util.toupper(refit_drone_names[sim:nextRand(1,#refit_drone_names)])
	drone:getTraits().customName = name
	drone:getTraits().MM_refitDroneRescue = true
end

-- Callback to be applied in mission_scoring
local function updateAgencyForRefitDrone( sim, agency )
	local name = sim:getTags().MM_rescuedRefitDroneName
	local campaignHours = sim:getParams().campaignHours

	local droneData = {name = name, campaignHours = campaignHours}

	agency.MM_rescuedRefitDrone = agency.MM_rescuedRefitDrone or {}
	table.insert( agency.MM_rescuedRefitDrone, droneData )
end

local function waitForDroneEscape( script, sim )
	local _, drone = script:waitFor( REFIT_DRONE_ESCAPED )
	sim:getTags().MM_rescuedRefitDroneName = drone:getTraits().customName

	-- Updates will be applied in mission_scoring
	sim.MM_agencyUpdates = sim.MM_agencyUpdates or {}
	table.insert( sim.MM_agencyUpdates, updateAgencyForRefitDrone )
end

local function droneSpeech( script, sim )
	local _, drone = script:waitFor( DRONE_BOOTED )
	if drone then
		doDroneBanter( script, sim, drone )
		script:waitFor( mission_util.PC_START_TURN )
	end
	-- DRONE_BANTER_CHANCE = 1 --for testing
	local drone_alive = true
	while drone_alive do
		script:waitFor( mission_util.PC_START_TURN )
		if not drone or not drone:getLocation() then
			drone_alive = false
		elseif not drone:isKO() and drone:getPlayerOwner() and (drone:getPlayerOwner() == sim:getPC()) and (sim:nextRand() <= DRONE_BANTER_CHANCE) then
			doDroneBanter( script, sim, drone )
		end
	end	
end

local function updatePWRTerminal( sim )
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:hasAbility("transformer_terminal") then
			unit:giveAbility("MM_transformer_terminal_10PWR")
			unit:giveAbility("MM_transformer_terminal_5PWR")
			break
		end
	end
end

local function updateCompileTerminal( sim )
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().research_program then
			unit:giveAbility("MM_compileUSB")
		end
	end
end
---------------------------------------------------------

local safeUnit = nil
	
local function PC_SAW_UNIT_WITH_MARKER2( script, tag, marker )
	return
	{
		trigger = simdefs.TRG_UNIT_APPEARED,
		fn = function( sim, evData )
			local seer = sim:getUnit( evData.seerID )
			if not seer or not seer:isPC() then
				return false
			end

			if not tag or evData.unit:hasTag(tag) and sim:getCurrentPlayer():isPC() then
				local x, y = evData.unit:getLocation()
				safeUnit = evData.unit
				script:queue( { type="displayHUDInstruction", text=marker, x=x, y=y } )
				return true 
			else
				return false
			end
		end,
	}
end
-------------------------------------------------------------------
-- Storage Lockers Sidequest
local function PC_LOOTED_STORAGE_SAFE()
	return
	{
		trigger = simdefs.TRG_SAFE_LOOTED,
		fn = function( sim, triggerData )
			if triggerData.targetUnit:hasTag("w93_storage_1") and not triggerData.targetUnit:getTraits().MM_W93_daemons_installed then
				safeUnit = triggerData.targetUnit
				return triggerData 
			end
		end,
	}
end

local function spottedStorage( script, sim )
	if not sim:getPC():getTraits().W93_spottedStorage or sim:getPC():getTraits().W93_spottedStorage <= 0 then
		script:waitFor( PC_SAW_UNIT_WITH_MARKER2( script, "w93_storage_1", STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.STEAL_STORAGE.TEXT1 ))
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.STEAL_STORAGE.OBJECTIVE1, "steal_storage1", 3 )
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.STEAL_STORAGE.OBJECTIVE2, "steal_storage2" )
		sim:incrementTimedObjective( "steal_storage1" )
		sim:getPC():getTraits().W93_spottedStorage = 1
		safeUnit:getTraits().W93_safe_spotted = true
		script:queue( { type="clearOperatorMessage" } )
		script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.STEAL_STORAGE.STORAGE_SPOTTED_1, type="newOperatorMessage" } )
		script:addHook( spottedStorage )
		script:waitFor( mission_util.PC_START_TURN )
		script:queue( { type="hideHUDInstruction" } )
	elseif sim:getPC():getTraits().W93_spottedStorage == 1 then
		script:waitFor( PC_SAW_UNIT_WITH_MARKER2( script, "w93_storage_1", STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.STEAL_STORAGE.TEXT1 ))
		if not safeUnit:getTraits().W93_safe_spotted then
			safeUnit:getTraits().W93_safe_spotted = true
			sim:getPC():getTraits().W93_spottedStorage = 2
			sim:incrementTimedObjective( "steal_storage1" )
			script:queue( { type="clearOperatorMessage" } )
			script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.STEAL_STORAGE.STORAGE_SPOTTED_2, type="newOperatorMessage" } )
			script:addHook( spottedStorage )
			script:waitFor( mission_util.PC_START_TURN )
			script:queue( { type="hideHUDInstruction" } )
		else
			script:addHook( spottedStorage )
			script:queue( { type="hideHUDInstruction" } )
		end
		script:addHook( spottedStorage )
	elseif sim:getPC():getTraits().W93_spottedStorage == 2 then
		script:waitFor( PC_SAW_UNIT_WITH_MARKER2( script, "w93_storage_1", STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.STEAL_STORAGE.TEXT1 ))
		if not safeUnit:getTraits().W93_safe_spotted then
			safeUnit:getTraits().W93_safe_spotted = true
			sim:getPC():getTraits().W93_spottedStorage = sim:getPC():getTraits().W93_spottedStorage + 1
			sim:incrementTimedObjective( "steal_storage1" )
			sim:removeObjective( "steal_storage1" )
			script:queue( { type="clearOperatorMessage" } )
			script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.STEAL_STORAGE.STORAGE_SPOTTED_3, type="newOperatorMessage" } )
			script:waitFor( mission_util.PC_START_TURN )
			script:queue( { type="hideHUDInstruction" } )
		else
			script:queue( { type="hideHUDInstruction" } )
			script:addHook( spottedStorage )
		end
	end
end

local function lootedStorage( script, sim )
	evData = script:waitFor( PC_LOOTED_STORAGE_SAFE() )
	script:waitFor( mission_util.UI_LOOT_CLOSED )
	script:waitFrames( .5*cdefs.SECONDS )

	if not safeUnit:getTraits().W93_daemons_installed and safeUnit:getName() == STRINGS.PROPS.GUARD_LOCKER and safeUnit:hasTag("w93_storage_1") then
		for k=1, 1, 1 do
			local daemon
			if sim:isVersion("0.17.7") then
				local programList = sim:handleOverrideAbility(serverdefs.OMNI_PROGRAM_LIST)
				if sim and sim:getParams().difficultyOptions.daemonQuantity == "LESS" then
					programList = sim:handleOverrideAbility(serverdefs.OMNI_PROGRAM_LIST_EASY)
				end
				daemon = programList[sim:nextRand(1, #programList)]
			else
				local programList = serverdefs.OMNI_PROGRAM_LIST
				if sim and sim:getParams().difficultyOptions.daemonQuantity == "LESS" then
					programList = serverdefs.OMNI_PROGRAM_LIST_EASY
				end
				daemon = programList[sim:nextRand(1, #programList)]
			end
			sim:getNPC():addMainframeAbility( sim, daemon, nil )
		end
	end
	safeUnit:getTraits().W93_daemons_installed = true
	if not sim:getPC():getTraits().W93_locker_daemons_triggered then
		script:queue( { type="clearOperatorMessage" } )
		script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.STEAL_STORAGE.CENTRAL_LOCKER_ROBBED, type="newOperatorMessage" } )
		sim:getPC():getTraits().W93_locker_daemons_triggered = true
	end
	script:addHook( lootedStorage )
end

local function briefcasifyStorageUnits( sim )
	local safes = {}
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:hasTag("w93_storage_1") then
			table.insert( safes, unit )
		end
	end
	for i, safe in pairs(safes) do
		for j=1, 4, 1 do
			local item = simfactory.createUnit( propdefs.MM_W93_crate , sim )
			sim:spawnUnit(item)
			safe:addChild(item)
		end
		safe:getTraits().credits = nil
	end
end
-------------------------------------------------------------------
--- Personnel Hijack sideobjective
local PC_KNOCKOUT_BOSS =
{
    trigger = simdefs.TRG_UNIT_KO,
    fn = function( sim, triggerData )
	if triggerData and (triggerData.ticks or 0) > 0 then
		if (not sim:isVersion("0.17.12") and triggerData.unit:getTraits().ko_trigger == "intimidate_guard") or triggerData.unit:getTraits().bossUnit then 
            		return triggerData.unit
            	end
        end
    end
}

local PC_KILL_BOSS =
{
    trigger = simdefs.TRG_UNIT_KILLED,
    fn = function( sim, triggerData )
	if triggerData then
		if triggerData.unit:getTraits().bossUnit then 
            		return triggerData.unit
            	end
        end
    end
}

local BOSS_ESCAPED = 
{
    trigger = "hostage_escaped",
    fn = function( sim, triggerData )
        if triggerData.unit:getTraits().bossUnit then
            return triggerData.unit
        end
    end,     
}

local function spottedBoss( script, sim )
	local bossUnit
	for _, unit in pairs(sim:getNPC():getUnits()) do
		if unit:hasTrait("bossUnit") then
			bossUnit = unit
			break
		end
	end
	script:waitFor( mission_util.PC_SAW_UNIT("bossUnit") )

	local cx, cy = bossUnit:getLocation()
	bossUnit:createTab( STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.PERSONNEL_HIJACK.TAB, STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.PERSONNEL_HIJACK.TAB_SUB )
	sim:addObjective( (string.format(STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.PERSONNEL_HIJACK.OBJECTIVE1,bossUnit:getUnitData().name)), "KO_Boss" )

	script:queue( { type="pan", x=cx, y=cy } )
	script:queue( { type="clearOperatorMessage" } )
	script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.PERSONNEL_HIJACK.SPOTTED_BOSS, type="newOperatorMessage" } )
end

local function KoBoss( script, sim )
	script:waitFor( PC_KNOCKOUT_BOSS )
	script:queue(1*cdefs.SECONDS)
	script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.PERSONNEL_HIJACK.KO_BOSS, type="newOperatorMessage" } )
end

local function KillBoss( script, sim )
	script:waitFor( PC_KILL_BOSS )

	sim:removeObjective( "KO_Boss" )
	script:queue(1*cdefs.SECONDS)
	script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.PERSONNEL_HIJACK.BOSS_KILLED, type="newOperatorMessage" } )

	-- script:waitFor( PC_WON ) --I don't think this delay is even needed...
	sim:setMissionReward( simquery.scaleCredits( sim, 200 ))
end

local function escapeBoss( script, sim )
	script:waitFor( BOSS_ESCAPED )

	sim:removeObjective( "KO_Boss" )
	script:queue(1*cdefs.SECONDS)
	script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.PERSONNEL_HIJACK.BOSS_TAKEN, type="newOperatorMessage" } )
	sim:setMissionReward( simquery.scaleCredits( sim, 300 ))
	sim:getPC():getTraits().W93_BossUnitHijacked = true
end

local function createBossUnit( sim )
	for _, guardUnit in pairs(sim:getNPC():getUnits()) do
		if guardUnit:getTraits().isGuard and not guardUnit:getTraits().isDrone and not guardUnit:getTraits().pacifist then
			guardUnit:getTraits().bossUnit = true
			guardUnit:getTraits().hostage = true
			guardUnit:getTraits().rescued = true
			guardUnit:getTraits().cant_abandon = true
			guardUnit:addTag("bossUnit")
			if not guardUnit:getTraits().armor then
				guardUnit:getTraits().armor = 0
			end
			guardUnit:getTraits().armor = guardUnit:getTraits().armor + 1
			if guardUnit:getTraits().LOSarc then
				guardUnit:getTraits().LOSarc = guardUnit:getTraits().LOSarc + math.pi/6
			end
			if guardUnit:getTraits().LOSperipheralArc then
				guardUnit:getTraits().LOSperipheralArc = guardUnit:getTraits().LOSperipheralArc + math.pi/4
			end
			if not guardUnit:getTraits().resistKO then
				guardUnit:getTraits().resistKO = 0
			end
			guardUnit:getTraits().resistKO = guardUnit:getTraits().resistKO + 1
			guardUnit:giveAbility("escape")
			if #guardUnit:getChildren() > 0 then
				guardUnit._children[1]:getTraits().newLocations = {[1] = {sim:getParams().world, "detention_centre"}}
			end
			break
		end
	end
end
-------------------------------------------------------------------
-- LUXURY  NANOFAB
local BOUGHT_ITEM =
{       
    trigger = simdefs.TRG_BUY_ITEM,
    fn = function( sim, triggerData )
        if triggerData.shopUnit:getTraits().storeType and (triggerData.shopUnit:getTraits().storeType == "large") and triggerData.shopUnit:getTraits().luxuryNanofab and triggerData.shopUnit:hasAbility("showItemStore") then
            return triggerData.shopUnit
        end
    end,
}

local CLOSED_NANOFAB = 
{
	trigger = simdefs.TRG_CLOSE_NANOFAB,
	fn = function( sim, triggerData )
		if triggerData.unit and triggerData.unit:getTraits().storeType and (triggerData.unit:getTraits().storeType == "large") and triggerData.unit:hasAbility("showItemStore") and triggerData.unit:getTraits().luxuryNanofab then
			return triggerData.unit
		end
	end,
}

local SUMMONED_GUARD =
{
	trigger = "MM_nanofab_summonedGuard",
	fn = function( sim, triggerData )
		if triggerData.unit and triggerData.consoleUnit then
			return triggerData.unit and triggerData.consoleUnit
		end
	end	
}

local PC_LOOTED_ITEM_NANOFAB_KEY =
{
    trigger = "agentGotItem",
    fn = function( sim, triggerData )
        -- print("CHECK THE ITEM",triggerData.item:getName())
        if triggerData.item:hasTrait("luxuryNanofabKey") then
            return triggerData.item
        end
    end,
}

local UNLOCKED_NANOFAB =
{
    trigger = "MM_unlockedLuxuryNanoab",
    fn = function( sim, triggerData )
        if triggerData.unit and triggerData.targetUnit then
            return triggerData.unit and triggerData.targetUnit
        end
    end,
}

local function findGuardWithKey( sim )
	local guard = nil
	for i, unit in pairs(sim:getNPC():getUnits()) do
		if unit:getTraits().hasLuxuryNanofabKey and unit:getBrain() and not (unit:isKO() or unit:isDead() )then
			guard = unit
			break
		end
	end
	return guard
end

local function PC_lootedKey( script, sim )
	local _, item = script:waitFor( PC_LOOTED_ITEM_NANOFAB_KEY )
	sim:getTags().haveNanofabKey = true
	local agent = item:getUnitOwner()
	script:queue(1*cdefs.SECONDS)
	local x0, y0 = agent:getLocation()
	if x0 and y0 then
		script:queue( { type="pan", x=x0, y=y0 } )
	end
	sim:removeObjective( "findNanofabKey" )
	if sim:getTags().sawLuxuryNanofab then
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.LUXURY_NANOFAB.UNLOCK_NANOFAB, "unlockLuxuryNanofab" )
		script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.LUXURY_NANOFAB.LOOTED_KEY_SAWNANOFAB, type="newOperatorMessage" } )
	else
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.LUXURY_NANOFAB.FIND_NANOFAB, "findLuxuryNanofab" )
		script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.LUXURY_NANOFAB.LOOTED_KEY, type="newOperatorMessage" } )
	end
end

local function sawConsole( script, sim )
	local _, console = script:waitFor( mission_util.SAW_SPECIAL_TAG(script, "MM_luxuryNanofab_console", STRINGS.MOREMISSIONS.UI.FANCYFAB_CONSOLE, STRINGS.MOREMISSIONS.UI.FANCYFAB_CONSOLE_DESC ) )
	script:queue(1*cdefs.SECONDS)
	local x0, y0 = console:getLocation()
	if x0 and y0 then
		script:queue( { type="pan", x=x0, y=y0 } )
	end
	if sim:getTags().haveNanofabKey then
		script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.LUXURY_NANOFAB.SAW_CONSOLE_HAVE_KEY, type="newOperatorMessage" } )
	else
		script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.LUXURY_NANOFAB.SAW_CONSOLE, type="newOperatorMessage" } )
	end
end

local function sawNanofab( script, sim )
	local _, nanofab = script:waitFor( mission_util.SAW_SPECIAL_TAG(script, "MM_luxuryNanofab", STRINGS.MOREMISSIONS.UI.FANCYFAB, STRINGS.MOREMISSIONS.UI.FANCYFAB_DESC ) )
	sim:getTags().sawLuxuryNanofab = true
	local x0, y0 = nanofab:getLocation()
	script:queue( { type="pan", x=x0, y=y0 } )
	script:queue(1*cdefs.SECONDS)
	
	if sim:getTags().haveNanofabKey then
		sim:removeObjective( "findLuxuryNanofab" )
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.LUXURY_NANOFAB.UNLOCK_NANOFAB, "unlockLuxuryNanofab" )
		script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.LUXURY_NANOFAB.SAW_NANOFAB_HAVE_KEY, type="newOperatorMessage" } )
	else
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.LUXURY_NANOFAB.FIND_KEY, "findNanofabKey" )
		script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.LUXURY_NANOFAB.SAW_NANOFAB, type="newOperatorMessage" } )
	end
	
	script:waitFor( UNLOCKED_NANOFAB )
	nanofab:destroyTab()
	sim:removeObjective( "unlockLuxuryNanofab" )
	script:queue(1*cdefs.SECONDS)
	script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.LUXURY_NANOFAB.UNLOCKED_NANOFAB, type="newOperatorMessage" } )
	
	local _, shop = script:waitFor( BOUGHT_ITEM )
	shop.items = {} -- this empties the nanofab stock and forces the shop dialogue to close
	shop.weapons = {}
	shop.augments = {}
	
	strings_screens.STR_346165218 = sim.old_augmenttip
	strings_screens.STR_2618909495 = sim.old_weapontip
	strings_screens.STR_590530336 = sim.old_itemtip

	shop:getTraits().mainframe_status = "off"
	sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_object_off" )
	sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = shop } )
	
	script:queue(1*cdefs.SECONDS)
	script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.LUXURY_NANOFAB.BOUGHT_ITEM, type="newOperatorMessage" } )	
	
end

local function summonedGuard( script, sim )
	local _, console = script:waitFor( SUMMONED_GUARD )
	console:destroyTab()
	
	local guard = findGuardWithKey(sim)
	script:queue( { type="clearOperatorMessage" } )
	if guard then
		local x1,y1 = console:getLocation()
		local interest = guard:getBrain():getSenses():addInterest( x1,  y1, simdefs.SENSE_HEARING, simdefs.REASON_ALARMEDSAFE, console)
		interest.alwaysDraw = true
		sim:processReactions()
		
		if not sim:getTags().haveNanofabKey then
			script:queue(1*cdefs.SECONDS)
			script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.LUXURY_NANOFAB.SUMMONED_GUARD, type="newOperatorMessage" } )
		end
	elseif not sim:getTags().haveNanofabKey then
		script:queue(1*cdefs.SECONDS)
		script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.LUXURY_NANOFAB.SUMMONED_GUARD_KO, type="newOperatorMessage" } )
	end
end

local function createKeyCarrier( sim )
	local keyAdded = false
	for i, guardUnit in pairs(sim:getNPC():getUnits()) do
		if guardUnit:getTraits().isGuard and not guardUnit:getTraits().isDrone and not guardUnit:getTraits().pacifist and not guardUnit:getTraits().mm_nopatrolchange and not guardUnit:getTraits().MM_bodyguard  and not guardUnit:getTraits().MM_bounty_target and not keyAdded then
			log:write("LOG MM giving nanofab key to" .. guardUnit:getUnitData().name )
			local item = simfactory.createUnit( propdefs.MM_luxuryNanofab_key, sim )
			sim:spawnUnit( item )
			guardUnit:addChild( item )
			guardUnit:getTraits().hasLuxuryNanofabKey = true
			keyAdded = true
		end
	end
end

local function closedFancyFab( script, sim)
	local _, shop = script:waitFor(CLOSED_NANOFAB)
	
	strings_screens.STR_346165218 = sim.old_augmenttip
	strings_screens.STR_2618909495 = sim.old_weapontip
	strings_screens.STR_590530336 = sim.old_itemtip
	script:addHook(closedFancyFab)
end

local function populateFancyFab(sim)
    local simstore = include( "sim/units/store" )
    local computer = nil
    for i, unit in pairs(sim:getAllUnits())do
        if unit:getTraits().luxuryNanofab then
            computer = unit
        end
    end   

    if computer then 

		--Use simstore.createStoreItems to generate a long list of item candidates for each category. This will contain duplicates
		local possible_merch = {
		[1] = {}, --items
		[2] = {}, --augments
		[3] = {}, --weapons
		}
		
		for i = 40, 1, -1 do --40 iterations should be enough to get 16 unique items
			local items, weapons, augments = simstore.createStoreItems( simstore.STORE_ITEM, computer, sim )
			util.tmerge(possible_merch[1], items)
			util.tmerge(possible_merch[2], augments)
			util.tmerge(possible_merch[3], weapons)
		end
		
		local itemType = sim:nextRand(1,3) --randomly choose either items, augments or weapons to populate the shop
		sim.luxuryNanofabItemType = itemType
		local merch_candidates = possible_merch[itemType]
		
		--remove_duplicates
		local hash = {}
		local unique_merch = {}

		for _,v in ipairs(merch_candidates) do
		   if (not hash[v._unitData.id ]) then
			   table.insert(unique_merch,v)
			   hash[v._unitData.id] = true
		   end
		end	
		
		-- distribute the possible merch randomly to fill up the three nanofab categories
		local total_items = {
			[1] = {},	--8 slots
			[2] = {},	-- 4 slots
			[3] = {},	-- 4 slots
		}
		if #unique_merch > 0 then
			
			for i = #unique_merch, 1, -1 do -- will run until merch list potential is empty or all nanofab categories are full, whichever comes first
				local item = sim:nextRand(1, #unique_merch)
				local group_choice = sim:nextRand(1,#total_items) --pick one of three categories to populate
				local item_group = total_items[group_choice]
				local limit = 4 -- 4 slots
				if group_choice == 1 then 
					limit = 8 --8 slots
				end
				if #item_group < limit then 
					table.insert(item_group, unique_merch[i])
					table.remove(unique_merch, i)
				end
			end
			
			computer.items, computer.weapons, computer.augments = total_items[1], total_items[2], total_items[3]
			
			computer:getTraits().mainframe_status = "off"
			local itemTypeName
			if itemType == 1 then
				itemTypeName = "ITEMS"
			elseif itemType == 2 then
				itemTypeName = "AUGMENTS"
			elseif itemType == 3 then
				itemTypeName = "WEAPONS"
			end
			computer:getTraits().luxuryNanofab = itemTypeName -- doubly used for tooltip and scripts
		end
	end
end

-------------------------------------------------------------------------
function fixNoPatrolFacing( sim )
	for i,unit in pairs( sim:getAllUnits() ) do
		if unit:getTraits().mm_fixnopatrolfacing and unit:getTraits().nopatrol then
			unit:getTraits().patrolPath[1].facing = unit:getFacing()
		end
	end
end

function pregeneratePrefabs( cxt, tagSet )
	cxt.params.side_mission = "MM_workshop" -- DEBUG
	if cxt.params.side_mission then
		if cxt.params.side_mission == "MM_w93_storageroom" then
			table.insert( tagSet, { "storageRoom2" } )
			table.insert( tagSet, { "storageRoom1" } )
			table.insert( tagSet, { "storageRoom3" } )
		elseif cxt.params.side_mission == "MM_luxuryNanofab" then
			table.insert( tagSet, { "luxuryNanofab" } )
		elseif cxt.params.side_mission == "MM_workshop" then
			table.insert( tagSet, {"workshopRoom"} )
		end
	end
end

function init( scriptMgr, sim )
	fixNoPatrolFacing( sim )
	--sidemission stuff
    local params = sim:getParams()
	if params.side_mission then
		log:write("LOG side mission")
		log:write(util.stringize(params.side_mission,2))
		-- CUSTOM MM SIDEMISSIONS
        if params.side_mission == "MM_luxuryNanofab" then
			createKeyCarrier(sim)
			populateFancyFab(sim)
			scriptMgr:addHook( "sawNanofab", sawNanofab )
			scriptMgr:addHook( "CLOSED_FANCYFAB", closedFancyFab, nil )
			scriptMgr:addHook( "summonedGuard", summonedGuard ) 
			scriptMgr:addHook( "PC_lootedKey", PC_lootedKey )
			scriptMgr:addHook( "sawConsole" , sawConsole )
		elseif params.side_mission == "MM_w93_storageroom" then
			briefcasifyStorageUnits(sim)
			scriptMgr:addHook( "spottedStorage", spottedStorage )
			scriptMgr:addHook( "lootedStorage", lootedStorage )
		elseif params.side_mission == "MM_w93_personelHijack" then
			createBossUnit(sim)
			scriptMgr:addHook( "spottedBoss", spottedBoss )
			scriptMgr:addHook( "KoBoss", KoBoss )
			scriptMgr:addHook( "KillBoss", KillBoss )
			scriptMgr:addHook( "escapeBoss", escapeBoss )
		elseif params.side_mission == "MM_workshop" then
			-- stuff
		end
		-- VANILLA SIDE MISSION REBALANCES
		if params.difficultyOptions.MM_sidemission_rebalance then
			if params.side_mission == "transformer" then
				updatePWRTerminal(sim)
			elseif params.side_mission == "drone_lab" then
				scriptMgr:addHook("updateRefitDrone", updateRefitDrone )
				scriptMgr:addHook("waitForDroneEscape", waitForDroneEscape )
				scriptMgr:addHook("droneSpeech", droneSpeech)
			elseif params.side_mission == "compile" then
				updateCompileTerminal( sim )
			end
		end
	end	
end

return {
	init = init,
	pregeneratePrefabs = pregeneratePrefabs,
	-- generatePrefabs = generatePrefabs,
}
