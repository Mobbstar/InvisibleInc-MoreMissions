local array = include( "modules/array" )
local binops = include( "modules/binary_ops" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local unitdefs = include( "sim/unitdefs" )
local inventory = include( "sim/inventory" )
local simfactory = include( "sim/simfactory" )
local simquery = include( "sim/simquery" )
local mission_util = include( "sim/missions/mission_util" )
local escape_mission = include( "sim/missions/escape_mission" )
local SCRIPTS = include("client/story_scripts")
local mathutil = include( "modules/mathutil" )
local propdefs = include("sim/unitdefs/propdefs")
local serverdefs = include("modules/serverdefs")

---------------------------------------------------------------------------------------------
-- Port of AI Terminal side mission from Worldgen Extended by wodzu93.
-- Design summary: Unlock AI terminal by opening four doors. Reward is either a new program slot for Incognita or upgrading an existing program!
-- Security measures: Knockout gas released into the objective starting with the terminal, guard investigates.
-- Functionality of adding new slot handled by Function Library.

-- Local helpers

local CARD_SAFE_LOOTED =
{
	trigger = simdefs.TRG_SAFE_LOOTED,
	fn = function( sim, triggerData )
		if triggerData.targetUnit and triggerData.targetUnit:getTraits().MM_hasAICard then
			-- log:write("LOg safe looted1")
			return triggerData.targetUnit
		end
	end,
}

local AI_CONSOLE_HIJACKED =
{
	trigger = simdefs.TRG_UNIT_HIJACKED,
	fn = function( sim, triggerData )
		if triggerData.unit and triggerData.unit:getTraits().MM_AIconsole then
			return triggerData.unit
		end
	end,
}

local 	PC_WON =
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
	
local function queueCentral(script, scripts) --really informative huh
	script:queue( { type="clearOperatorMessage" } )
	for k, v in pairs(scripts) do
		script:queue( { script=v, type="newOperatorMessage" } )
		script:queue(0.5*cdefs.SECONDS)
	end	
end

local function findCell( sim, tag )
	local cells = sim:getCells( tag )
	return cells and cells[1]
end

local function CONSOLE_USED()
	return
	{
		trigger = simdefs.TRG_UNIT_HIJACKED,
		fn = function( sim, eventData )
			if eventData.unit and eventData.unit:hasTag("W93_INCOG_LOCK") then
				eventData.unit:removeTag("W93_INCOG_LOCK")
				return true
			end 
		end
	}
end

local function LOCK_DEACTIVATED()
	return
	{
		trigger = simdefs.TRG_UI_ACTION,
		fn = function( sim, eventData )
			if eventData.W93_incogLock then
				return true
			end 
		end
	}
end

local INCOGNITA_UPGRADED = {
	trigger = "activated_incogRoom",
	fn = function( sim, eventData )
		return eventData
	end
	}

local FINISHED_USING_TERMINAL = {
	trigger = "finished_using_AI_terminal",
	fn = function( sim, eventData )
		return true
	end,
}
----

-- AI TERMINAL NEW SLOT/PROGRAM UPGRADE BLOCK

-- The idea is to have a branching dialog that lets you choose between upgrading Incognita's slots and a program. This currently has Interactive Events as a dependency. Need to figure out why that is and fix it. Porting mission_util from IE by itself is not enough.
local function populateProgramList( sim )
	local player = sim:getPC()
	local programs = player:getAbilities()
	local options_list = {}
	local traits = {}
	-- for i, ability in pairs(programs) do
		-- if not ability.MM_upgraded then
			-- local name = ability.name
			-- table.insert( options_list, name )
			-- traits[name] = {}
			-- traits[name].parasite_strength = ability.parasite_strength or nil
			-- traits[name].break_firewalls = ability.break_firewalls or nil
			-- traits[name].maxCooldown = ability.maxCooldown or nil
			-- traits[name].value = ability.value or nil
			-- traits[name].cpu_cost = ability.cpu_cost or nil
			-- traits[name].ID = ability._abilityID
		-- end
	-- end
	
	for i = 1, #programs do
		local ability = programs[#programs +1 -i] --reverse iteration so the dialog buttons appear in the same order as in the slots
		if not ability.MM_upgraded then
			local name = ability.name
			table.insert( options_list, name )
			traits[name] = {}
			traits[name].parasite_strength = ability.parasite_strength or nil
			traits[name].break_firewalls = ability.break_firewalls or nil
			traits[name].maxCooldown = ability.maxCooldown or nil
			traits[name].value = ability.value or nil
			traits[name].cpu_cost = ability.cpu_cost or nil
			traits[name].ID = ability._abilityID
		end
	end	
	
	return {options_list = options_list, traits = traits}

end

local function upgradeIcebreak( upgradedProgram, sim, boost )
	local validUpgrade = false
	local result = (upgradedProgram.break_firewalls or 0) + boost
	if result > 0 then
		if (upgradedProgram.break_firewalls or 0) > 0 then
			validUpgrade = true
			upgradedProgram.break_firewalls = upgradedProgram.break_firewalls + boost
			
			upgradedProgram.MM_modifiers = upgradedProgram.MM_modifiers or {}
			upgradedProgram.MM_modifiers.break_firewalls = upgradedProgram.MM_modifiers.break_firewalls or 0
			upgradedProgram.MM_modifiers.break_firewalls = upgradedProgram.MM_modifiers.break_firewalls + boost
		end
	end
	local result2 = (upgradedProgram.parasite_strength or 0) + boost
	if result2 > 0 then
		if upgradedProgram.parasite_strength then
			validUpgrade = true
			upgradedProgram.parasite_strength = upgradedProgram.parasite_strength + boost
			
			upgradedProgram.MM_modifiers = upgradedProgram.MM_modifiers  or {}
			upgradedProgram.MM_modifiers.parasite_strength = upgradedProgram.MM_modifiers.parasite_strength or 0
			upgradedProgram.MM_modifiers.parasite_strength = upgradedProgram.MM_modifiers.parasite_strength + boost			
		end	
	end
	if (upgradedProgram._abilityID == "dataBlast") and (boost > 0) then
		log:write("LOG completing data blast upgrade")
		validUpgrade = true
		upgradedProgram.dataBlastStrength = 1
		upgradedProgram.MM_modifiers = upgradedProgram.MM_modifiers or {}
		upgradedProgram.MM_modifiers.break_firewalls = upgradedProgram.MM_modifiers.break_firewalls or 0
		upgradedProgram.MM_modifiers.break_firewalls = upgradedProgram.MM_modifiers.break_firewalls + boost	
	end
	return validUpgrade
end

local function upgradePWRcost( upgradedProgram, sim, boost )
	local validUpgrade = false
	local pwrCost = upgradedProgram.cpu_cost
	if upgradedProgram.parasite_strength then
		pwrCost = upgradedProgram.base_cpu_cost
	end
	local result = (upgradedProgram.cpu_cost or 0) + boost
	if result > 0 then
		if upgradedProgram.cpu_cost and not (upgradedProgram.parasite_strength and upgradedProgram.parasite_strength == 1) then 
		-- we don't want Parasite 1.0 pwr cost to be upgradable for both balance and bug prevention reasons.
			validUpgrade = true
			upgradedProgram.cpu_cost = upgradedProgram.cpu_cost + boost
			if upgradedProgram.GOLEMCOST then
				upgradedProgram.GOLEMCOST = upgradedProgram.GOLEMCOST + boost
			end
			-- store changes for agency
			upgradedProgram.MM_modifiers = upgradedProgram.MM_modifiers  or {}
			upgradedProgram.MM_modifiers.cpu_cost = upgradedProgram.MM_modifiers.cpu_cost or 0
			upgradedProgram.MM_modifiers.cpu_cost = upgradedProgram.MM_modifiers.cpu_cost + boost
			
			if upgradedProgram.parasite_strength and upgradedProgram.base_cpu_cost then -- Parasite V.2.0
				upgradedProgram.MM_modifiers.base_cpu_cost = upgradedProgram.MM_modifiers.base_cpu_cost or 0
				upgradedProgram.base_cpu_cost = upgradedProgram.base_cpu_cost + boost
				upgradedProgram.MM_modifiers.base_cpu_cost = upgradedProgram.MM_modifiers.base_cpu_cost + boost
			end			
		end
	end
	return validUpgrade
end

local function upgradeCooldown( upgradedProgram, sim, boost )
	local validUpgrade = false
	local result = (upgradedProgram.maxCooldown or 0 ) + boost
	if result > 0 then
		if upgradedProgram.maxCooldown then
			validUpgrade = true
			upgradedProgram.maxCooldown = upgradedProgram.maxCooldown + boost
			upgradedProgram.MM_modifiers = upgradedProgram.MM_modifiers  or {}
			upgradedProgram.MM_modifiers.maxCooldown = boost		
		end
	end
	return validUpgrade
end

local function upgradeRange( upgradedProgram, sim, boost )
	local validUpgrade = false
	local result = (upgradedProgram.range or 0) + boost
	if result > 0 then
		if upgradedProgram.range then
			validUpgrade = true
			upgradedProgram.range = upgradedProgram.range + boost
			upgradedProgram.MM_modifiers = upgradedProgram.MM_modifiers  or {}
			upgradedProgram.MM_modifiers.range = boost		
		end
	end
	return validUpgrade
end

local function finishDialog( sim, triggerData )
	if triggerData then
		triggerData.abort = true
		sim:triggerEvent( "cancelled_using_AI_terminal" )
	else
		sim:triggerEvent( "finished_using_AI_terminal" )
	end
end

local function finishProgramUpgrade( upgradedProgram, sim )
	upgradedProgram.value = upgradedProgram.value or 0
	upgradedProgram.value = upgradedProgram.value * 1.3 --increase resale value of upgraded program
	upgradedProgram.oldName = upgradedProgram.name
	upgradedProgram.name = "UPGRADED "..upgradedProgram.name
	sim:getTags().used_AI_terminal = true
	sim:getTags().upgradedPrograms = true
	finishDialog( sim )
end

local function upgradeDialog( script, sim )
	while sim:getTags().used_AI_terminal == nil do

	local _, triggerData = script:waitFor( INCOGNITA_UPGRADED )
	
	local dialogPath = STRINGS.MOREMISSIONS.MISSIONS.AI_TERMINAL.DIALOG

	-- check available upgrade types for display purposes
	local pos1, pos2 = sim.MM_AI_terminal_parameters[1], sim.MM_AI_terminal_parameters[2]	
	local options3_temp = {}
	table.insert(options3_temp, dialogPath.OPTIONS3[pos1])
	table.insert(options3_temp, dialogPath.OPTIONS3[pos2])
				
	local txt = util.sformat(dialogPath.OPTIONS1_TXT, options3_temp[2],options3_temp[1])
	local title = dialogPath.OPTIONS1_TITLE
	local options = dialogPath.OPTIONS1 --choose between slot and program upgrade
	
	if (sim:getParams().difficultyOptions.W93_AI or 0) > 0 then
		--display alternate menu with option to disrupt hostile AI
		options = dialogPath.OPTIONS1_PE
		txt = util.sformat(dialogPath.OPTIONS1_TXT_PE, options3_temp[2],options3_temp[1])
	end
	
	local option = mission_util.showDialog( sim, title, txt, options )
	
	local cancel_opt = nil
	local slots_opt = nil
	local upgrade_opt = nil
	local counterAI_opt = nil
	
	for optnum = #options, 1, -1 do
		local opt_name = options[optnum]
		if opt_name == "CANCEL" then
			cancel_opt = optnum
		elseif opt_name == "UPGRADE PROGRAM" then
			upgrade_opt = optnum
		elseif opt_name == "NEW PROGRAM SLOT" then
			slots_opt = optnum
		elseif opt_name == "DISRUPT HOSTILE AI" then
			counterAI_opt = optnum
		end
	end
	
	if option == slots_opt then -- upgrade Incognita's slots
	
		local currentSlots = simquery.getMaxPrograms( sim )
		local doneUpgrades = sim:getParams().agency.W93_aiTerminals or 0 
		local remainingUpgrades = 2 - doneUpgrades
		local maxSlots = currentSlots + remainingUpgrades
		local isEndless = sim:getParams().difficultyOptions.maxHours == math.huge
		-- isEndless = true --this lifts the slot cap for non-endless campaigns as well
		
		if sim:getParams().agency.W93_aiTerminals and ((sim:getParams().agency.W93_aiTerminals) >= 2) and not isEndless then --max slots reached
			local slotsfull_txt = util.sformat(dialogPath.OPTIONS2_SLOTSFULL_TXT, currentSlots, maxSlots )
			mission_util.showBadResult( sim, dialogPath.OPTIONS2_SLOTSFULL_TITLE, slotsfull_txt )
			option = nil
			finishDialog( sim, triggerData )			
		else
			if isEndless then
				maxSlots = dialogPath.SLOTS_UNLIMITED
			end
			local slots_txt = util.sformat(dialogPath.OPTIONS2_SLOTS_TXT,currentSlots, maxSlots)
			local slots_title = dialogPath.OPTIONS2_SLOTS_TITLE
			local slots_options = dialogPath.OPTIONS2_CANCEL_CONFIRM
			local option_confirm = mission_util.showDialog( sim, slots_title, slots_txt, slots_options )
			--confirm screen
			if option_confirm == 1 then
				option_confirm = nil
				finishDialog( sim, triggerData )
			else
				mission_util.showGoodResult( sim, dialogPath.OPTIONS2_RESULT1_TITLE, dialogPath.OPTIONS2_RESULT1_TXT )
				sim:getTags().used_AI_terminal = true
				if not sim:getParams().agency.W93_aiTerminals or sim:getParams().agency.W93_aiTerminals < 2 then
					sim:getPC():getTraits().W93_incognitaUpgraded = 1
				end
				finishDialog( sim )
			end
		end
	elseif option == counterAI_opt then
		local corpName = serverdefs.CORP_DATA[ sim:getParams().world ].stringTable.SHORTNAME
		local option_pe_txt = util.sformat(dialogPath.OPTIONS2_PE_TXT, corpName )
		if sim:getParams().agency.MM_hostileAInerf and sim:getParams().agency.MM_hostileAInerf[sim:getParams().world] then --if we've already debuffed this corp's AI in the past, display this
			local debuff = sim:getParams().agency.MM_hostileAInerf[sim:getParams().world]
			option_pe_txt = util.sformat(dialogPath.OPTIONS2_PE_TXT_PREEXISTING, corpName, debuff )
		end
		local option_pe = mission_util.showDialog( sim, dialogPath.OPTIONS2_PE_TITLE, option_pe_txt, dialogPath.OPTIONS2_CANCEL_CONFIRM )
		if option_pe == 1 then
			option_confirm = nil
			finishDialog( sim, triggerData )
		else
			local options_pe_result_txt = util.sformat(dialogPath.OPTIONS2_PE_RESULT_TXT, corpName )
			mission_util.showGoodResult( sim, dialogPath.OPTIONS_PE_RESULT_TITLE, options_pe_result_txt )
			sim:getTags().used_AI_terminal = true
			sim:getTags().weakened_counterAI = true
			finishDialog( sim )
		end		
	elseif option == cancel_opt then
		option = nil
		finishDialog( sim, triggerData )
	elseif option == upgrade_opt then
		local txt2 = util.sformat(dialogPath.OPTIONS2_TXT,options3_temp[2],options3_temp[1])
		
		local options2 = populateProgramList( sim ).options_list
		if #options2 > 5 then
			txt2 = util.sformat(dialogPath.OPTIONS2_TXT_COMPACT,options3_temp[2],options3_temp[1])
		end
		if #options2 <= 0 then
			mission_util.showBadResult( sim, dialogPath.NO_PROGRAMS, dialogPath.NO_PROGRAMS_DESC )
			option = nil
			finishDialog( sim, triggerData )
		else
		local option2 = mission_util.showDialog( sim, dialogPath.OPTIONS2_TITLE, txt2, options2 ) -- choose program to upgrade
		
		local program_name = options2[option2]
		
		for i = #options2, 1, -1 do
			if option2 == i then
				local txt3 = dialogPath.OPTIONS3_TXT
				local options3 = util.tcopy(dialogPath.OPTIONS3)
				-- {
					-- "Firewalls broken",
					-- "PWR cost",
					-- "Cooldown",
					-- "Range"
				-- }
	
				local program_ID  = populateProgramList(sim).traits[program_name].ID
				local upgradedProgram = sim:getPC():hasMainframeAbility( program_ID )
				
				if upgradedProgram.parasite_strength ~= nil then
					options3 = util.tcopy(dialogPath.OPTIONS3_PARASITE)
				end
				
				-- NEW: only 2 out of 4 upgrades should be available in a given mission, at random, to force variety and more interesting choices.
				local upgrades_available = {
					[1] = true,
					[2] = true,
					[3] = true,
					[4] = true,
				}				
				
				local pos1, pos2 = sim.MM_AI_terminal_parameters[1], sim.MM_AI_terminal_parameters[2]
				local options3_random = {} --make a new options table, keeping only the two randomised entries
				table.insert(options3_random, dialogPath.OPTIONS3[pos1])
				table.insert(options3_random, dialogPath.OPTIONS3[pos2])
				table.insert(options3_random, 1, dialogPath.START_OVER )

				local firewall_opt = nil 
				local pwr_opt = nil
				local cd_opt = nil
				local range_opt = nil 
				local restart_opt = nil
				
				-- reassign now that two entries in options were randomly removed
				for num = #options3_random, 1, -1 do
					local pam = options3_random[num]
				-- for num, pam in pairs(options3_random) do
					if (pam == "Firewalls broken") or (pam == "Parasite strength") then
						firewall_opt = num
					end
					if pam == "PWR cost" then
						pwr_opt = num
					end
					if pam == "Cooldown" then
						cd_opt = num
					end
					if pam == "Range" then
						range_opt = num
					end
					if pam == "Start over" then
						restart_opt = num --should be 1
					end
				end

				local option3 = mission_util.showDialog( sim, dialogPath.OPTIONS3_TITLE, txt3, options3_random ) --choose between parameters to upgrade
				
				local txt_increment = dialogPath.OPTIONS4_TXT --"Choose a change. Parameter cannot be decreased below 1."
				
				local options_increment = dialogPath.OPTIONS4_INC --choose to increment or decrement
				-- {
					-- "Increase by 1",
					-- "Decrease by 1",
				-- }
				
				if option3 == restart_opt then 
					restart_opt = nil
					finishDialog( sim, triggerData )					
				elseif option3 == firewall_opt then
					--increase/decrease firewalls broken
					local txt_firewalls = util.sformat(dialogPath.FIREWALLS_TIP, upgradedProgram.name, (
					(((upgradedProgram.break_firewalls or 0) > 0) and upgradedProgram.break_firewalls )
					or (((upgradedProgram.parasite_strength or 0) > 0) and upgradedProgram.parasite_strength)
					or dialogPath.INVALID	))..txt_increment
					
					if upgradedProgram._abilityID == "dataBlast" then -- more special cases
						txt_firewalls = util.sformat(dialogPath.FIREWALLS_TIP, upgradedProgram.name, 1)..txt_increment
					end
					local option_firewalls = mission_util.showDialog( sim, dialogPath.OPTIONS_FIREWALLS_TITLE, txt_firewalls, options_increment )
					

					if option_firewalls == 3 then	
						local validUpgrade = upgradeIcebreak( upgradedProgram, sim, 1 )	
						if validUpgrade == true then
							mission_util.showGoodResult( sim, dialogPath.PROGRAM_UPGRADED_SUCCESS, dialogPath.OPTIONS_FIREWALLS_INCREASE )	
						
							finishProgramUpgrade(upgradedProgram, sim )
						else
							mission_util.showBadResult( sim, dialogPath.PROGRAM_UPGRADE_FAIL_TITLE, dialogPath.PROGRAM_UPGRADE_FAIL_TXT )
							option_firewalls = nil
							finishDialog( sim, triggerData )
						end
						
					elseif option_firewalls == 2 then
						local validUpgrade = upgradeIcebreak( upgradedProgram, sim, -1 )
						if validUpgrade == true then
							mission_util.showGoodResult( sim, dialogPath.PROGRAM_UPGRADED_SUCCESS, dialogPath.OPTIONS_FIREWALLS_DECREASE )
						
							finishProgramUpgrade(upgradedProgram, sim )
						else
							mission_util.showBadResult( sim, dialogPath.PROGRAM_UPGRADE_FAIL_TITLE, dialogPath.PROGRAM_UPGRADE_FAIL_TXT )
							option_firewalls = nil
							finishDialog( sim, triggerData )
						end
					else
						option_firewalls = nil
						finishDialog( sim, triggerData )
					end
					
				elseif option3 == pwr_opt then
					local txt_PWRcost = util.sformat(dialogPath.PWRCOST_TIP, upgradedProgram.name, (upgradedProgram.cpu_cost or dialogPath.INVALID))..txt_increment		

					if upgradedProgram.parasite_strength and (upgradedProgram.parasite_strength == 1) then --blargh, hardcoding
						txt_PWRcost = util.sformat(dialogPath.PWRCOST_TIP, upgradedProgram.name, (dialogPath.INVALID))..txt_increment
					end
					
					local option_PWR = mission_util.showDialog( sim, dialogPath.OPTIONS_PWRCOST_TITLE, txt_PWRcost, options_increment )
					if option_PWR == 3 then
						
						local validUpgrade = upgradePWRcost( upgradedProgram, sim, 1 )
						if validUpgrade == true then
							mission_util.showGoodResult( sim, dialogPath.PROGRAM_UPGRADED_SUCCESS, dialogPath.OPTIONS_PWRCOST_INCREASE )					
							finishProgramUpgrade(upgradedProgram, sim )
						else
							mission_util.showBadResult( sim, dialogPath.PROGRAM_UPGRADE_FAIL_TITLE, dialogPath.PROGRAM_UPGRADE_FAIL_TXT )
							option_PWR = nil
							finishDialog( sim, triggerData )
						end
						
					elseif option_PWR == 2 then
					
						local validUpgrade = upgradePWRcost( upgradedProgram, sim, -1 )
						if validUpgrade == true then
							mission_util.showGoodResult( sim, dialogPath.PROGRAM_UPGRADED_SUCCESS, dialogPath.OPTIONS_PWRCOST_DECREASE )		
							finishProgramUpgrade(upgradedProgram, sim )
						else
							mission_util.showBadResult( sim, dialogPath.PROGRAM_UPGRADE_FAIL_TITLE, dialogPath.PROGRAM_UPGRADE_FAIL_TXT )
							option_PWR = nil
							finishDialog( sim, triggerData )
						end
					else
						option_PWR = nil
						finishDialog( sim, triggerData )
					end
				elseif option3 == cd_opt then
				
					local txt_cooldown = util.sformat(dialogPath.COOLDOWN_TIP, upgradedProgram.name, (upgradedProgram.maxCooldown or dialogPath.INVALID))..txt_increment					
				
					local option_CD = mission_util.showDialog( sim, dialogPath.OPTIONS_COOLDOWN_TITLE, txt_cooldown, options_increment )
					if option_CD == 3 then
					
						local validUpgrade = upgradeCooldown( upgradedProgram, sim, 1 )
						if validUpgrade == true then
							mission_util.showGoodResult( sim, dialogPath.PROGRAM_UPGRADED_SUCCESS, dialogPath.OPTIONS_COOLDOWN_INCREASE )
							finishProgramUpgrade(upgradedProgram, sim )
						else
							mission_util.showBadResult( sim, dialogPath.PROGRAM_UPGRADE_FAIL_TITLE, dialogPath.PROGRAM_UPGRADE_FAIL_TXT )
							option_CD = nil
							finishDialog( sim, triggerData )
						end
						
					elseif option_CD == 2 then
					
						local validUpgrade = upgradeCooldown( upgradedProgram, sim, -1 )
						if validUpgrade == true then
							mission_util.showGoodResult( sim, dialogPath.PROGRAM_UPGRADED_SUCCESS, dialogPath.OPTIONS_COOLDOWN_DECREASE )	
							finishProgramUpgrade(upgradedProgram, sim )
						else
							mission_util.showBadResult( sim, dialogPath.PROGRAM_UPGRADE_FAIL_TITLE, dialogPath.PROGRAM_UPGRADE_FAIL_TXT )
							option_CD = nil
							finishDialog( sim, triggerData )
						end
					else
						option_CD = nil
						finishDialog( sim, triggerData )
					end
				elseif option3 == range_opt then
					local txt_range = util.sformat( dialogPath.RANGE_TIP, upgradedProgram.name, (upgradedProgram.range or dialogPath.INVALID))..txt_increment
					
					local option_RANGE = mission_util.showDialog( sim, dialogPath.OPTIONS_RANGE_TITLE, txt_range, options_increment )
					if option_RANGE == 3 then
						local validUpgrade = upgradeRange( upgradedProgram, sim, 1 )
						if validUpgrade == true then
							mission_util.showGoodResult( sim, dialogPath.PROGRAM_UPGRADED_SUCCESS, dialogPath.OPTIONS_RANGE_INCREASE )
							finishProgramUpgrade(upgradedProgram, sim )
						else
							mission_util.showBadResult( sim, dialogPath.PROGRAM_UPGRADE_FAIL_TITLE, dialogPath.PROGRAM_UPGRADE_FAIL_TXT )
							option_CD = nil
							finishDialog( sim, triggerData )
						end
					elseif option_RANGE == 2 then
						local validUpgrade = upgradeRange( upgradedProgram, sim, -1 )
						if validUpgrade == true then
							mission_util.showGoodResult( sim, dialogPath.PROGRAM_UPGRADED_SUCCESS, dialogPath.OPTIONS_RANGE_DECREASE )
							finishProgramUpgrade(upgradedProgram, sim )
						else
							mission_util.showBadResult( sim, dialogPath.PROGRAM_UPGRADE_FAIL_TITLE, dialogPath.PROGRAM_UPGRADE_FAIL_TXT )
							option_CD = nil
							finishDialog( sim, triggerData )
						end
					else
						option_CD = nil
						finishDialog( sim, triggerData )
					end
				end
			end
		end
			
		end
	end
	
	end
	
end

-- end of modal dialog stuff
----------------------------------------------------
-- Trigger Definitions

local function spottedDoor( script, sim )
	script:waitFor( mission_util.PC_SAW_CELL_WITH_TAG( script, "IncognitaLock2" ))
	
	local c = findCell( sim, "IncognitaLock2" )

	script:queue( 1*cdefs.SECONDS )
	script:queue( { type="pan", x=c.x, y=c.y } )
	script:queue( 0.1*cdefs.SECONDS )
	script:queue( { type="displayHUDInstruction", text=STRINGS.MOREMISSIONS.UI.INCOGROOM_TEXT1, x=c.x, y=c.y } )
	script:queue( { type="clearOperatorMessage" } )
	queueCentral( script, SCRIPTS.INGAME.AI_TERMINAL.CENTRAL_DOOR_SPOTTED ) 
	sim:removeObjective("find")
	sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.AI_TERMINAL.OBJECTIVE1, "upgrade_incognita1", 4 )
	script:waitFor( mission_util.PC_START_TURN )
	script:queue( { type="hideHUDInstruction" } )
end

local function incrementLocks( script, sim )
	local step = 0
	script:waitFor( LOCK_DEACTIVATED() )
	if sim:getPC():getTraits().W93_incogRoom_unlock and step ~= sim:getPC():getTraits().W93_incogRoom_unlock then
		sim:incrementTimedObjective( "upgrade_incognita1" )
		step = sim:getPC():getTraits().W93_incogRoom_unlock
	end
	if step >= 4 then
		for i, AIunit in pairs( sim:getAllUnits() ) do
			if AIunit:getName() == STRINGS.MOREMISSIONS.PROPS.INCOGROOM_AI_TERMINAL then
				AIunit:setPlayerOwner( sim:getPC() )
				sim:getCurrentPlayer():glimpseUnit( sim, AIunit:getID() )
				sim:dispatchEvent( simdefs.EV_UNIT_CAPTURE, { unit = AIunit, nosound = true } )	
			end
		end
		local c = findCell( sim, "IncognitaLock2" )
		for i, exit in pairs( c.exits ) do
			if exit.door and exit.locked and exit.keybits == simdefs.DOOR_KEYS.BLAST_DOOR then 
				sim:modifyExit( c, i, simdefs.EXITOP_UNLOCK )
				sim:modifyExit( c, i, simdefs.EXITOP_OPEN )
				sim:dispatchEvent( simdefs.EV_EXIT_MODIFIED, {cell=c, dir=i} )
				sim:getPC():glimpseExit( c.x, c.y, i )
			end
		end

		script:queue( 1*cdefs.SECONDS )
		script:queue( { type="pan", x=c.x, y=c.y } )
		script:queue( 0.1*cdefs.SECONDS )
		if sim:getTags().needPowerCells then
			queueCentral( script, SCRIPTS.INGAME.AI_TERMINAL.CENTRAL_UNLOCKED_MAINDOOR_OMNI_SEEN )
		else
			queueCentral( script, SCRIPTS.INGAME.AI_TERMINAL.CENTRAL_UNLOCKED_MAINDOOR_OMNI_UNSEEN )
		end
		script:queue( 5*cdefs.SECONDS )
		sim:removeObjective( "upgrade_incognita1" )
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.AI_TERMINAL.OBJECTIVE2, "upgrade_incognita2" )
	else
		script:addHook( incrementLocks )
	end
end

local function useConsole( script, sim )
	script:waitFor( CONSOLE_USED() )
	local c =  findCell( sim, "IncognitaLock1" )
	for i, exit in pairs( c.exits ) do
		if exit.door and exit.locked and exit.keybits == simdefs.DOOR_KEYS.BLAST_DOOR then 
			sim:modifyExit( c, i, simdefs.EXITOP_UNLOCK )
			sim:modifyExit( c, i, simdefs.EXITOP_OPEN )
			sim:dispatchEvent( simdefs.EV_EXIT_MODIFIED, {cell=c, dir=i} )
			sim:getPC():glimpseExit( c.x, c.y, i )

			script:queue( 1*cdefs.SECONDS )
			script:queue( { type="pan", x=c.x, y=c.y } )
			script:queue( 0.1*cdefs.SECONDS )
			queueCentral( script, SCRIPTS.INGAME.AI_TERMINAL.CENTRAL_UNLOCKED_SUBDOOR )
		end
	end

end

local function makeSmoke( script, sim ) 
	--IncogRoom fills with KO gas starting with main terminal, then the unlock terminals, then the doors. KO gas is harmless on first spawn then replaces itself with potent KO version, which replaces itself with harmless dispersal version (the last one is cosmetic only)
	local terminal
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().MM_incogRoom_main then
			terminal = unit
		end
	end
	local cell = sim:getCell(terminal:getLocation())
	local KOcloud = simfactory.createUnit( propdefs.MM_gas_cloud, sim )
	sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/Grenades/smokegrenade_explo" )
	sim:spawnUnit( KOcloud )
	sim:warpUnit( KOcloud, cell )
	script:queue( { type="pan", x=cell.x, y=cell.y, zoom=0.27 } )
	queueCentral( script, SCRIPTS.INGAME.AI_TERMINAL.SMOKE_WARNING )
	sim:getNPC():spawnInterest(cell.x, cell.y, simdefs.SENSE_RADIO, simdefs.REASON_ALARMEDSAFE, terminal) 
	
	script:waitFor( mission_util.PC_START_TURN )
	if sim:getParams().difficultyOptions.MM_difficulty and (sim:getParams().difficultyOptions.MM_difficulty == "easy") then
		script:waitFor( mission_util.PC_START_TURN )
	end
	
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().MM_incogRoom_unlock then
			local lock_cell = sim:getCell(unit:getLocation())
			local KOcloud = simfactory.createUnit( propdefs.MM_gas_cloud, sim )
			sim:spawnUnit( KOcloud )
			sim:warpUnit( KOcloud, lock_cell )
		end
	end
	
	script:waitFor( mission_util.PC_START_TURN )
	
	local obj_procGen = cell.procgenRoom
	local cells = {}
	sim:forEachCell(
	function( c )
		if c.procgenRoom == obj_procGen then
			for dir, exit in pairs( c.exits ) do
				if simquery.isDoorExit(exit) then
					table.insert( cells, c )
				end
			end
		end
	end )
	for i, doorcell in pairs( cells ) do
		local KOcloud = simfactory.createUnit( propdefs.MM_gas_cloud, sim )
		sim:spawnUnit( KOcloud )
		sim:warpUnit( KOcloud, doorcell )
	end	
end

local function upgradeIncognita( script, sim )
	-- local _, evData = script:waitFor( INCOGNITA_UPGRADED() )
	-- upgradeDialog( script, sim, agent )
	script:waitFor( FINISHED_USING_TERMINAL )
	script:queue( 1*cdefs.SECONDS )
	sim:removeObjective( "upgrade_incognita2" )
	if sim:getPC():getTraits().W93_incognitaUpgraded == 1 then
		queueCentral( script, SCRIPTS.INGAME.AI_TERMINAL.INCOGNITA_DATA_ACQUIRED )
	elseif sim:getTags().upgradedPrograms then
		queueCentral( script, SCRIPTS.INGAME.AI_TERMINAL.INCOGNITA_PROG_UPGRADED )
	-- else
		-- queueCentral( script, SCRIPTS.INGAME.AI_TERMINAL.INCOGNITA_TECH_ACQUIRED )	-- probably don't want this	
	end
	
	--now for the security measures
	script:queue( 1 * cdefs.SECONDS )
	script:addHook( makeSmoke )
	
	sim:setClimax(true)
	sim.exit_warning = nil
	sim.TA_mission_success = true

	script:waitFor( PC_WON ) -- to think I could have been doing agency changes like wodzu all this time instead of putting things in DoFinishMission
	local agency = sim:getParams().agency
	
	if sim:getPC():getTraits().W93_incognitaUpgraded == 1 then
		
		if not sim:getParams().agency.W93_aiTerminals then
			sim:getParams().agency.W93_aiTerminals = 0
		end
		sim:getParams().agency.W93_aiTerminals = sim:getParams().agency.W93_aiTerminals + 1
		
	elseif sim:getTags().upgradedPrograms then
	
		agency.MM_upgradedPrograms = agency.MM_upgradedPrograms or {}
		
		local programs = sim:getPC():getAbilities()
		for i, ability in pairs(programs) do	
			-- local ID = ability._abilityID --see rant in scriptPath mainframe_abilities
			if ability.MM_modifiers then
				local ID = ability.oldName
				agency.MM_upgradedPrograms[ID] = {}
				agency.MM_upgradedPrograms[ID] = util.tcopy( ability.MM_modifiers )
			end
		end	
	elseif sim:getTags().weakened_counterAI then
		local corp = sim:getParams().world
		agency.MM_hostileAInerf = agency.MM_hostileAInerf or {}
		agency.MM_hostileAInerf[corp] = agency.MM_hostileAInerf[corp] or 0
		agency.MM_hostileAInerf[corp] = agency.MM_hostileAInerf[corp] + 2	--FuncLib or PE should do the rest
	end
end

local function cardSafeReaction( script, sim  )

	local _, unit, seer = script:waitFor( mission_util.PC_SAW_UNIT_WITH_TRAIT("MM_hasAICard") )
	local text = util.toupper(STRINGS.MOREMISSIONS.UI.INCOGROOM_SAWSAFE)
	local x0, y0 = unit:getLocation()
	script:queue( { type="pan", x=x0, y=y0} )
	unit:createTab( text, "" )

	script:waitFor(CARD_SAFE_LOOTED)
	--log:write("LOG AI card safe looted!")

    unit:destroyTab()
end

local function consoleReaction( script, sim  )
	local _, unit, seer = script:waitFor( mission_util.PC_SAW_UNIT_WITH_TRAIT("MM_AIconsole") )
	local x, y = unit:getLocation()
	local text = util.toupper(STRINGS.MOREMISSIONS.UI.INCOGROOM_SAWCONSOLE)
	unit:createTab(text,"")
	script:queue( { type="pan", x=x, y=y } )
	script:waitFor(AI_CONSOLE_HIJACKED)
	unit:destroyTab()
end

local function addKeys( sim )

	local safeAdded = false
	local consoleAdded = false

	for i, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().safeUnit and not safeAdded then
			local item = simfactory.createUnit( propdefs.MM_W93_AiRoomPasscard, sim )
			sim:spawnUnit(item)
			unit:addChild(item)
			unit:getTraits().MM_hasAICard = true
			safeAdded = true
		end
		if unit:getTraits().mainframe_console and not consoleAdded then
			unit:addTag("W93_INCOG_LOCK")
			-- log:write("LOG console added!")
			consoleAdded = true
			unit:getTraits().MM_AIconsole = true
			unit:getTraits().sightable = true --required for triggering on unit appeared
			if not (unit:getPlayerOwner() == sim:getNPC()) then
				-- log:write("reowning console")
				-- this is necessary on the 0 consoles setting because consoles start out player-owned
				unit:setPlayerOwner(sim:getNPC())
				unit:getTraits().hijacked = nil
				unit:getTraits().cpus = 2 --sorry, AndrewKay, I cannot be bothered to look up the console PWR determining thing for this
			end
		end
		if consoleAdded and safeAdded then
			break
		end
	end

end

local function chooseUpgrades( sim )

	local pos1, pos2 = nil, nil
	pos1 = sim:nextRand(1,4) --pick two non-duplicate random parameters
	while pos2 == nil do
		local temp_pos2 = sim:nextRand(1,4)
		if pos1 ~= temp_pos2 then
			pos2 = temp_pos2
		end
	end
	sim.MM_AI_terminal_parameters = {}
	sim.MM_AI_terminal_parameters[1] = pos1
	sim.MM_AI_terminal_parameters[2] = pos2

end

local function spawnDaemons( sim )
	local PROGRAM_LIST = serverdefs.PROGRAM_LIST
	if sim:isVersion("0.17.5") then
		PROGRAM_LIST = sim:getIcePrograms()
	end		
	local locks = {}
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:hasAbility("MM_W93_incogRoom_unlock") then
			table.insert(locks, unit)
		end
	end
	local difficulty = sim:getParams().difficulty
	local num_daemons = difficulty
	if num_daemons > 4 then
		num_daemons = 4
	end
	local ice_boosted = false
	for i, unit in pairs(locks) do
		if not ice_boosted then
			unit:getTraits().mainframe_ice = unit:getTraits().mainframe_ice + 2
			ice_boosted = true
		end
		local daemon = PROGRAM_LIST:getChoice( sim:nextRand( 1, PROGRAM_LIST:getTotalWeight() ))
		unit:getTraits().mainframe_program = daemon
		num_daemons = num_daemons - 1
		if num_daemons <= 0 then
			break
		end
	end
end
---------------------------------------------------------------------------------------------
-- Begin!

local mission = class( escape_mission )

function mission:init( scriptMgr, sim )
	escape_mission.init( self, scriptMgr, sim )
	sim.TA_mission_success = false
	
	addKeys( sim )
	chooseUpgrades( sim ) --randomly choose 2 out of 4 possible parameters available for program upgrade in AI terminal
	spawnDaemons(sim) --spawn daemons on some of the lock devices
	sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.AI_TERMINAL.OBJ_FIND, "find" )

	scriptMgr:addHook( "spottedDoor", spottedDoor )
	scriptMgr:addHook( "useConsole", useConsole )
	scriptMgr:addHook( "incrementLocks", incrementLocks )
	scriptMgr:addHook( "upgradeIncognita", upgradeIncognita )
	scriptMgr:addHook( "upgradeDialog", upgradeDialog )
	scriptMgr:addHook( "cardSafeReaction", cardSafeReaction )
	scriptMgr:addHook( "consoleReaction", consoleReaction )
	
	sim.exit_warning = STRINGS.MOREMISSIONS.MISSIONS.AI_TERMINAL.EXIT_WARNING

	--This picks a reaction rant from Central on exit
    local scriptfn = function()

        local scripts = SCRIPTS.INGAME.AI_TERMINAL.CENTRAL_JUDGEMENT.GOT_NOTHING
		if sim:getTags().upgradedPrograms then
			scripts = SCRIPTS.INGAME.AI_TERMINAL.CENTRAL_JUDGEMENT.GOT_UPGRADE
		elseif sim:getPC():getTraits().W93_incognitaUpgraded then
			scripts = SCRIPTS.INGAME.AI_TERMINAL.CENTRAL_JUDGEMENT.GOT_SLOT
		elseif sim:getTags().weakened_counterAI then
			scripts = SCRIPTS.INGAME.AI_TERMINAL.CENTRAL_JUDGEMENT.WEAKENED_COUNTER_AI
		end
        local scr = scripts[sim:nextRand(1, #scripts)]
        return scr
    end	
	scriptMgr:addHook( "FINAL", mission_util.CreateCentralReaction(scriptfn))
end


function mission.pregeneratePrefabs( cxt, tagSet )
	escape_mission.pregeneratePrefabs( cxt, tagSet )
	table.insert( tagSet[1], "MM_incogRoom" )
end

function mission.generatePrefabs( cxt, candidates )
    local prefabs = include( "sim/prefabs" ) 
	escape_mission.generatePrefabs( cxt, candidates )
	
	if cxt.params.difficultyOptions.safesPerLevel == 0 then
		prefabs.generatePrefabs( cxt, candidates, "safe", 1 )
	end 
	if cxt.params.difficultyOptions.consolesPerLevel == 0 then
		prefabs.generatePrefabs( cxt, candidates, "console", 1 )
	end	
end	

return mission
