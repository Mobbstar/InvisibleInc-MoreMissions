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
--SIDE MISSIONS
-- Local helpers
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
		script:waitFor( PC_SAW_UNIT_WITH_MARKER2( script, "w93_storage_1", STRINGS.WORLDEXTEND.SIDEOBJECTIVES.STEAL_STORAGE.TEXT1 ))
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
	sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.SIDEMISSIONS.PERSONNEL_HIJACK.OBJECTIVE1, "KO_Boss" )

	script:queue( { type="pan", x=cx, y=cy } )
	script:queue( { type="clearOperatorMessage" } )
	script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.PERSONNEL_HIJACK.SPOTTED_BOSS, type="newOperatorMessage" } )
end

local function KoBoss( script, sim )
	script:waitFor( PC_KNOCKOUT_BOSS )
	script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.PERSONNEL_HIJACK.KO_BOSS, type="newOperatorMessage" } )
end

local function KillBoss( script, sim )
	script:waitFor( PC_KILL_BOSS )

	sim:removeObjective( "KO_Boss" )
	script:queue( { type="hideHUDInstruction" } )
	script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.PERSONNEL_HIJACK.BOSS_KILLED, type="newOperatorMessage" } )

	script:waitFor( mission_util.PC_WON )
	sim:setMissionReward( simquery.scaleCredits( sim, 200 ))
end

local function escapeBoss( script, sim )
	script:waitFor( BOSS_ESCAPED )

	sim:removeObjective( "KO_Boss" )
	script:queue( { type="hideHUDInstruction" } )
	script:queue( { script=SCRIPTS.INGAME.MM_SIDEMISSIONS.PERSONNEL_HIJACK.BOSS_TAKEN, type="newOperatorMessage" } )

	script:waitFor( mission_util.PC_WON )
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

local function boughtItemAtFancyFab( script, sim )
    local _, shop = script:waitFor( BOUGHT_ITEM )
	shop.items = {}
	shop.weapons = {}
	shop.augments = {}
	
	strings_screens.STR_346165218 = sim.old_augmenttip
	strings_screens.STR_2618909495 = sim.old_weapontip
	strings_screens.STR_590530336 = sim.old_itemtip
end

local function closedFancyFab( script, sim)
	local _, shop = script:waitFor(CLOSED_NANOFAB)
	
	strings_screens.STR_346165218 = sim.old_augmenttip
	strings_screens.STR_2618909495 = sim.old_weapontip
	strings_screens.STR_590530336 = sim.old_itemtip
	script:addHook(closedFancyFab)
	if shop:getTraits().luxuryNanofab then
		--power down sound effect
		shop:getTraits().mainframe_status = "off"
	end
end

local function populateFancyFab(sim)
    local simstore = include( "sim/units/store" )
    local computer = nil
    for i,testUnit in pairs(sim:getAllUnits())do
        if testUnit:getTraits().storeType and (testUnit:getTraits().storeType == "large") and testUnit:getTraits().luxuryNanofab and testUnit:hasAbility("showItemStore") and testUnit:getUnitData().id == "item_store" then
			log:write("LOG found luxury nanofab")
            computer = testUnit
        end
    end   

    if computer then 

		--Use simstore.createStoreItems to generate a long list of item candidates for each category. This will contain duplicates
		local possible_merch = {
		[1] = {}, --items
		[2] = {}, --augments
		[3] = {}, --weapons
		}
		
		for i = 20, 1, -1 do --10 iterations should be enough to get 16 unique items
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
	if cxt.params.side_mission then
		if cxt.params.side_mission == "MM_w93_storageroom" then
			table.insert( tagSet, { "storageRoom2" } )
			table.insert( tagSet, { "storageRoom1" } )
			table.insert( tagSet, { "storageRoom3" } )
		end
	end
end

-- function generatePrefabs( cxt, candidates )
    -- local prefabs = include( "sim/prefabs" ) 
	-- prefabs.generatePrefabs( cxt, candidates, "store", 1)
-- end	

-- local function testNanofab(sim) --TEMPORARY
	-- for i, unit in pairs(sim:getAllUnits()) do
		-- if unit:getTraits().storeType and unit:hasAbility("showItemStore") and unit:getUnitData().id == "item_store" then
			-- unit:getTraits().storeType = "large"
			-- unit:getTraits().luxuryNanofab = true
			-- unit:getTraits().largenano = true
			-- break
		-- end
	-- end
-- end

function init( scriptMgr, sim )
	fixNoPatrolFacing( sim )
	--sidemission stuff
    local params = sim:getParams()
	-- if params.side_mission then
	-- params.side_mission = "MM_luxuryNanofab"
		-- log:write("LOG side mission")
		-- log:write(util.stringize(params.side_mission,2))
        -- if params.side_mission == "MM_luxuryNanofab" then
		    -- scriptMgr:addHook( "FANCYFAB", boughtItemAtFancyFab, nil  )
			-- scriptMgr:addHook( "CLOSED_FANCYFAB", closedFancyFab, nil )
			-- -- testNanofab(sim)
			-- populateFancyFab(sim)
		-- elseif params.side_mission == "MM_w93_storageroom" then
			-- briefcasifyStorageUnits(sim)
			-- scriptMgr:addHook( "spottedStorage", spottedStorage )
			-- scriptMgr:addHook( "lootedStorage", lootedStorage )
		-- elseif params.side_mission == "MM_w93_personelHijack" then
			-- createBossUnit(sim)
			-- scriptMgr:addHook( "spottedBoss", spottedBoss )
			-- scriptMgr:addHook( "KoBoss", KoBoss )
			-- scriptMgr:addHook( "KillBoss", KillBoss )
			-- scriptMgr:addHook( "escapeBoss", escapeBoss )
		-- end
	-- end	
end

return {
	init = init,
	pregeneratePrefabs = pregeneratePrefabs,
	generatePrefabs = generatePrefabs,
}
