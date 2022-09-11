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

---------------------------------------------------------------------------------------------
-- Local helpers

local CHANCE_OF_DECOY = 0.3
local bodyguard_unit --file-wide variable for ease of checking
local bounty_target_unit

local function queueCentral(script, scripts)
	for k, v in pairs(scripts) do
		script:queue( { script=v, type="newOperatorMessage" } )
		script:queue(0.5*cdefs.SECONDS)
	end	
end

----
-- Trigger Definitions

-- Like mission_util.PC_ANY, but after the action completes instead of before.
-- Allows triggering before returning to player control.
local PC_AFTER_ANY =
{
	action = "", -- Any action
}

--interest triggers so bodyguard can investigate instead VIP
local DECOY_REVEALED = 
{
	trigger = "MM_decoy_revealed",
	fn = function( sim, evData )
		if evData.unit and evData.unit:getTraits().MM_decoy then
			return evData.unit, evData.newDecoy
		end
	end,
}

local NEW_INTEREST = 
{
	trigger = simdefs.TRG_NEW_INTEREST,
	fn = function( sim, evData )
		if evData.interest.sourceUnit and evData.interest.sourceUnit:getTraits().MM_bounty_target and not evData.interest.sourceUnit:getTraits().MM_realtarget then
			if evData.interest.reason == nil or (evData.interest.reason and not (evData.interest.reason == "REASON_MM_ASSASSINATION") ) then
				return evData.interest
			end
		end
	end,
}

local NEW_UNIT_INTEREST = 
{
	trigger = simdefs.TRG_UNIT_NEWINTEREST,
	fn = function( sim, evData )
		if evData.unit and evData.unit:getTraits().MM_bounty_target and not evData.unit:getTraits().MM_realtarget then
			if evData.interest.reason == nil or (evData.interest.reason and not (evData.interest.reason == "REASON_MM_ASSASSINATION")) then
				local interest = { sourceUnit = evData.unit, x = evData.interest.x, y = evData.interest.y }
				-- log:write("LOG interest")
				-- log:write(util.stringize(evData.unit:getUnitData().name,2))
				return interest
			end
		end
	end,
}

local TRIED_TO_STEAL_FROM_DECOY = 
{
	trigger = "MM_usedFakeSteal",
	fn = function( sim, evData )
		if evData.targetUnit:getTraits().MM_decoy then
			return evData.targetUnit
		end
	end
}

local CEO_DEAD =
{
	trigger = simdefs.TRG_UNIT_KILLED,
	fn = function( sim, evData )
		if evData.unit:hasTag("assassination") then
			evData.corpse:addTag("assassination") --track the body; no rest for the dead -M
			return evData.corpse
		end
	end,
}
local CEO_KO =
{
	trigger = simdefs.TRG_UNIT_KO,
	fn = function( sim, evData )
		if evData.unit:hasTag("assassination") and evData.ticks then
			return evData.unit
		end
	end,
}
local CEO_ALERTED =
{
	trigger = simdefs.TRG_UNIT_ALERTED,
	fn = function( sim, evData )
		if evData.unit:hasTag("assassination") then
			return evData.unit
		end
	end,
}
local CEO_ARMING =
{
	trigger = "MM-VIP-ARMING",
	fn = function( sim, evData )
		if evData.unit:hasTag("assassination") then
			return evData.unit
		end
	end,
}

local BODYGUARD_ALERTED =
{
	trigger = simdefs.TRG_UNIT_ALERTED,
	fn = function( sim, evData )
		if evData.unit:hasTag("bodyguard") then
			return evData.unit
		end
	end,
}
local BODYGUARD_DEAD =
{
	trigger = simdefs.TRG_UNIT_KILLED,
	fn = function( sim, evData )
		if evData.unit:hasTag("bodyguard") then
			evData.corpse:addTag("bodyguard")
			return evData.corpse
		end
	end,
}

local DROID_DEAD =
{
	trigger = simdefs.TRG_UNIT_KILLED,
	fn = function( sim, evData )
		if evData.unit:hasTag("MM_decoy_droid") then
			evData.corpse:addTag("MM_decoy_droid")
			return evData.corpse
		end
	end,
}

local BODYGUARD_KO =
{
	trigger = simdefs.TRG_UNIT_KO,
	fn = function( sim, evData )
		if evData.unit:hasTag("bodyguard") and evData.ticks then
			return evData.unit
		end
	end,
}

local BODYGUARD_SHOT_AT =
{
	trigger = "MM_shotAtBodyguard",
	fn = function( sim, evData )
		if evData.targetUnit:getTraits().MM_bodyguard then
			local equipped = evData.equipped
			if equipped and not (equipped:getTraits().canSleep or equipped:getTraits().targetNotAlerted or equipped:getTraits().noTargetAlert) then
				-- log:write("LOG trigger MM_shotAtBodyguard")
				return evData.targetUnit, evData.sourceUnit
			end
		end
	end,
}

local UNIT_WARP = 
{
	trigger = simdefs.TRG_UNIT_WARP,
	fn = function( sim, evData )
		return evData.unit
	end
}

local UNIT_USE_DOOR = 
{
	trigger = simdefs.TRG_UNIT_USEDOOR,
	fn = function( sim, evData )
		return evData.unit
	end
}

-- this is a mishmash of PC_SAW_UNIT and PC_SAW_CELL_WITH_TAG, as the former doesn't work when a player-captured camera spots the VIP.
PC_SAW_UNIT_FIXED = function( tag )
	return
	{
		trigger = simdefs.TRG_LOS_REFRESH,
		fn = function( sim, evData )
			local seer =  evData.seer 
			if not seer or not seer:isPC() then
				return false
			end
			
			for i = 1, #evData.cells, 2 do
				local cell = sim:getCell(evData.cells[i],evData.cells[i+1])		
				if cell.units then
					for i, seenUnit in pairs(cell.units) do
						if seenUnit:hasTag(tag) then
							return seenUnit, seer
						end
					end
				end		
			end

			return false
		end,
	}
end

-- bodyguard behaviour: keeping within vision range of VIP, investigating in his stead
local function keepClose( script, sim )
	while true do
		local bodyguard = nil
		local vip = nil
		script:waitFor( mission_util.PC_START_TURN )
		for i, unit in pairs(sim:getNPC():getUnits()) do
			if unit:getTraits().MM_bodyguard then
				bodyguard = unit
			end
			if sim.MM_bounty_disguise_active then
				if unit:getTraits().MM_decoy then
					vip = unit
				end
			else
				if unit:getTraits().MM_bounty_target then
					vip = unit
				end
			end
		end
		if bodyguard and vip and bodyguard:getBrain() and not bodyguard:isKO() then
			if not simquery.couldUnitSeeCell( sim, bodyguard, sim:getCell(vip:getLocation()) ) and not (bodyguard:getTraits().lostVIP or bodyguard:getTraits().previouslyLostVIP) then
				bodyguard:getTraits().previouslyLostVIP = nil
				local x1,y1 = vip:getLocation()
				bodyguard:getBrain():spawnInterest(x1, y1, simdefs.SENSE_RADIO, simdefs.REASON_NOTICED, vip) -- give persistent interest point to VIP's location
				bodyguard:getTraits().lostVIP = true
			elseif simquery.couldUnitSeeCell( sim, bodyguard, sim:getCell(vip:getLocation()) ) and bodyguard:getTraits().lostVIP then
				bodyguard:getTraits().lostVIP = nil
				bodyguard:getTraits().previouslyLostVIP = true
				local x1,y1 = vip:getLocation()
				bodyguard:getBrain():spawnInterest(x1, y1, simdefs.SENSE_RADIO, simdefs.REASON_NOTICED, vip) 		
			end
		end
	end
end

-- when VIP is distracted, bodyguard investigates distraction instead if in sight, while VIP investigates on the spot
local function transferInterest( sim, interest )
	local bodyguard = nil
	local vip = interest.sourceUnit
	for i, unit in pairs(sim:getNPC():getUnits()) do
		if unit:getTraits().MM_bodyguard and unit:getBrain() and not unit:isKO() then
			bodyguard = unit
		end
	end
	if bodyguard and vip and not vip:getTraits().MM_ceo_armed and (simquery.couldUnitSeeCell( sim, bodyguard, sim:getCell(vip:getLocation()) ) or sim.MM_bounty_disguise_active ) then
		local x0, y0 = vip:getLocation()
		local x1, y1 = interest.x, interest.y
		vip:getBrain():spawnInterest(x0,y0, sim:getDefs().SENSE_DEBUG, "REASON_MM_ASSASSINATION") --vip stays put and investigates in place	
		if simquery.couldUnitSeeCell( sim, bodyguard, sim:getCell(vip:getLocation()) ) then
			bodyguard:getBrain():spawnInterest(x1,y1, simdefs.SENSE_RADIO, "REASON_MM_ASSASSINATION") --bodyguard investigates distraction
		end
	end
end

local function waitForInterest( script, sim )
	while true do
		local _, interest = script:waitFor( NEW_INTEREST )
		transferInterest( sim, interest)	
	end
end

local function waitForUnitInterest( script, sim )
	while true do
		local _, interest = script:waitFor( NEW_UNIT_INTEREST )
		transferInterest( sim, interest)		
	end
end

local function playerHasLethalWeapons( sim )
	for i, unit in pairs( sim:getPC():getUnits() ) do
		for k, item in pairs(unit:getChildren()) do
			if ((item:getTraits().baseDamage or 0 > 0) and not item:getTraits().canSleep) or item:getTraits().lethal or item:getTraits().lethalMelee then
				return true
			end
		end
	end
	return false
end

local function isSaferoomKey( unit )
	return ((unit:isDown() or unit:getTraits().iscorpse) and (unit:hasTag("assassination") or unit:hasTag("bodyguard") or unit:hasTag("MM_decoy_droid"))) or unit:hasTag("MM_decoy_droid")
end
local function playerCanUnlockSaferoom( sim )
	-- Any player non-drone unit is at the door and standing over an authorized body.
	for _,unit in ipairs( sim:getPC():getUnits() ) do
		local cell = sim:getCell( unit:getLocation() )
		if not unit:isDown() and (not unit:getTraits().isDrone or unit:hasTag("MM_decoy_droid")) and simquery.cellHasTag( sim, cell, "saferoom_unlock" ) then
			for _,cellUnit in ipairs( cell.units ) do
				if cellUnit and isSaferoomKey( cellUnit ) then
					return unit, cellUnit
				end
			end
		end
	end
end
local PC_UNLOCK_SAFEROOM_AFTER_ACTION =
{
	-- After any player action
	action = "",
	fn = playerCanUnlockSaferoom,
}
local PC_UNLOCK_SAFEROOM_START_TURN =
{
	-- At the start of the player turn (action=endTurnAction fires between PC and NPC turns)
	trigger = simdefs.TRG_START_TURN,
	fn = function( sim, evData )
		return evData:isPC() and playerCanUnlockSaferoom( sim )
	end,
}
local ESCAPE_WITH_BODY =
{
	trigger = simdefs.TRG_UNIT_ESCAPED,
	fn = function( sim, triggerData )
		for unitID, unit in pairs(sim:getAllUnits()) do
			if unit:hasTag("assassination") then
				local cell = sim:getCell( unit:getLocation() )
				if cell and cell.exitID == simdefs.DEFAULT_EXITID then
					return unit
				end
			end
		end
	end,
}
----
-- Utility Functions

local function findCell(sim, tag)
	local cells = sim:getCells( tag )
	return cells and cells[1]
end

-- Like mission_util.findUnitByTag, but returns nil if the unit isn't found
local function safeFindUnitByTag(sim, tag)
	for _, unit in pairs( sim:getAllUnits() ) do
		if unit:hasTag( tag ) then
			return unit
		end
	end
end

-- Copied from IdleSituation:generateStationaryPath
local function calculateBestFacing( sim, cell, unit )
    -- Look for stationary patrollers and face them in a direction that allows maximal visibility.
    local maxFacing, maxCells = nil, 0
    for facing = 0, simdefs.DIR_MAX do
        local cells = sim:getLOS():calculateLOS( cell, simquery.getFacingRads( facing ), simquery.getLOSArc( unit ) / 2, unit:getTraits().LOSrange )
        local cellCount = util.tcount( cells )
        if cellCount > maxCells then
            maxCells = cellCount
            maxFacing = facing
        end
    end
    return maxFacing
end

local function selectStoryScript(sim, report)
	return report[sim:nextRand(1, #report)]
end


----
-- Actions

local function spawnCeoWeapon( sim )
	local safe = mission_util.findUnitByTag( sim, "saferoom_safe" )
	local newWeapon = simfactory.createUnit( unitdefs.lookupTemplate( "item_light_pistol" ), sim )
	newWeapon:addTag("saferoom_weapon")
	sim:spawnUnit( newWeapon )
	safe:addChild( newWeapon )
end

local function initCeoTraits( sim )
	local ceo_real_tag = "assassination"
	local fake_ceo = safeFindUnitByTag( sim, "assassination_fake" )
	if fake_ceo then
		ceo_real_tag = "assassination_real"
	end
	local ceo = mission_util.findUnitByTag( sim, ceo_real_tag )

	-- CEO is allowed to walk in and out of the saferoom
	if ceo:getTraits().npcPassiveKeybits then
		ceo:getTraits().npcPassiveKeybits = binops.b_or( ceo:getTraits().npcPassiveKeybits, simdefs.DOOR_KEYS.BLAST_DOOR )
	else
		ceo:getTraits().npcPassiveKeybits = simdefs.DOOR_KEYS.BLAST_DOOR
	end

	-- No penalty for killing this one.
	ceo:getTraits().cleanup = nil
	
	if sim:getParams().difficultyOptions.MM_difficulty and (sim:getParams().difficultyOptions.MM_difficulty == "easy") then
		local bodyguard = mission_util.findUnitByTag( sim, "bodyguard" )
		bodyguard:getTraits().woundsMax = 1
		bodyguard:getTraits().MM_alertlink = nil
		
		ceo:getTraits().hasSentAlert = true
		ceo:getTraits().MM_alertlink = nil
	end
end

-- Alert the CEO
local function doAlertCeo( sim, fromBodyguard, mission )
	local ceofake = safeFindUnitByTag( sim, "assassination_fake" )
	local ceoreal = safeFindUnitByTag( sim, "assassination_real" )
	local ceos = { ceofake, ceoreal }
	for i, ceo in pairs(ceos) do
		if ceo and ceo:isValid() and not ceo:isDown() and not ceo:getTraits().iscorpse and not ceo:isAlerted() and not ceo:getTraits().hasSentAlert then
			ceo:getTraits().MM_alertlink = nil --for tooltip
			if fromBodyguard then
				-- Don't send alerts back and forth
				ceo:getTraits().hasSentAlert = true
			end
			-- Senses:addInterest: Create an ephemeral interest to be forgotten later
			local x,y = ceo:getLocation()
			ceo:getBrain():getSenses():addInterest( x, y, simdefs.SENSE_RADIO, simdefs.REASON_SHARED )  -- REASON_SHARED is alerting
			sim:processReactions( ceo )
		end
	end
	mission.revealDecoy( sim, ceofake )
end

-- Alert the bodyguard and send him to the CEO's location
-- If the bodyguard is indisposed, the nearest other guard responses to the call.
local function doAlertBodyguard( sim, ceo, mission )
	local x,y = ceo:getLocation()
	-- if ceo:getTraits().MM_decoy then
		-- ceo:removeTag("assassination")
	-- end
	local bodyguard = safeFindUnitByTag( sim, "bodyguard" )
	if bodyguard then
		bodyguard:getTraits().MM_alertlink = nil
	end
	if x and y and ceo and not ceo:getTraits().hasSentAlert then
		if bodyguard and bodyguard:isValid() and bodyguard:getBrain() and not bodyguard:isDown() then
			-- Send the bodyguard to the CEO
			-- Brain:spawnInterest: Create a remembered interest
			bodyguard:getBrain():spawnInterest( x, y, simdefs.SENSE_RADIO, simdefs.REASON_SHARED )  -- REASON_SHARED is alerting
		else
			-- Bodyguard unavailable. Send the nearest other guard to the CEO.
			sim:getNPC():spawnInterestWithReturn( x, y, simdefs.SENSE_RADIO, simdefs.REASON_SHARED, nil, { ceo:getID() } )
		end
		ceo:getTraits().hasSentAlert = true
	end
	
	-- if the alerted unit was a decoy, reveal the decoy
	if ceo:getTraits().MM_decoy then
		mission.revealDecoy( sim, ceo )
	end
end

local function doUnlockSaferoom( sim, agent )
	local c = findCell( sim, "saferoom_door" )
	assert( c )
	for i, exit in pairs( c.exits ) do
		if exit.door and exit.keybits == simdefs.DOOR_KEYS.BLAST_DOOR then
			if exit.locked and exit.closed then
				-- Unlock, but don't open. Just in case the CEO is pointing a gun this way and the player stood in front of the door.
				sim:modifyExit( c, i, simdefs.EXITOP_UNLOCK)
			elseif not exit.locked and exit.temporaryLockEndTurn then
				-- Temporarily unlocked. Don't let it re-lock.
				local reverseExit = exit.cell.exits[simquery.getReverseDirection( dir )]
				exit.temporaryCloseEndTurn, reverseExit.temporaryCloseEndTurn = nil, nil
				exit.temporaryLockEndTurn, reverseExit.temporaryLockEndTurn = nil, nil
			end
			-- Make the UI sound at the player's location. The tagged cell may be the wrong side of the door from the player.
			local x0,y0 = agent:getLocation()
			sim:emitSound( simdefs.SOUND_DOOR_UNLOCK, x0, y0 )
		end
	end
end

local function isHeatSigTarget( sim, unit )
	if unit:getTraits().MM_bounty_target then
	-- log:write("LOG 1")
		if not sim.MM_bounty_disguise_active then
			return true
		else
			if ((sim:getTags().MM_decoyrevealed or sim:getTags().MM_sawRealCEO) and unit:hasTag("assassination_real")) or (not sim:getTags().MM_decoyrevealed and unit:hasTag("assassination_fake")) then
				return true
			end
		end
	end
	return false
end

--full circle to the CFO mission followHeatSig
local function followHeatSig( script, sim )
	sim:forEachUnit(
	function(unit)
		if isHeatSigTarget( sim, unit ) then 
			local x, y = unit:getLocation()
			-- log:write("LOG spawning heatsig")
			-- script:queue( { type="displayHUDInstruction", text=STRINGS.MISSIONS.UTIL.HEAT_SIGNATURE_DETECTED, x=x, y=y } )
			script:queue( { type="pan", x=x, y=y } )
		end
	end)

	while true do 
		local ev, triggerData = script:waitFor( mission_util.UNIT_WARP )
		if isHeatSigTarget( sim, triggerData.unit ) then
			-- script:queue( { type="hideHUDInstruction" } ) 
			local x, y = triggerData.unit:getLocation()
            if x and y then
				-- log:write("LOG warp updating heatsig")
			    -- script:queue( { type="displayHUDInstruction", text=STRINGS.MISSIONS.UTIL.HEAT_SIGNATURE_DETECTED, x=x, y=y } )
			    script:queue( { type="pan", x=x, y=y } )
            end
		end 
	end
end

----
-- Script hooks

-- Handle UI scripts and objectives when the target is first seen
-- Based on mission_util.DoReportObject, but determines the report script based on the target's state. And tracks which scripts are played onto the mission.
local function playerSeesCeo( script, sim, mission )
	local _, ceo, agent = script:waitFor( mission_util.PC_SAW_UNIT("assassination") )

	-- Report on "objective sighted" by default. If the target was KOed/killed outside LOS, then play that script instead.
	local report = SCRIPTS.INGAME.ASSASSINATION.OBJECTIVE_SIGHTED
	if not playerHasLethalWeapons( sim ) then
		report = SCRIPTS.INGAME.ASSASSINATION.OBJECTIVE_SIGHTED_NO_WEAPONS
	end

	sim:removeObjective( "find" )
	if ceo:getTraits().iscorpse then
		report = SCRIPTS.INGAME.ASSASSINATION.AFTERMATH
		mission.reportedCeoKilled = true
		if mission.reportedCeoSeen == true then
			script:removeHook( followHeatSig )
		end
		mission.reportedCeoSeen = true
	elseif ceo:isKO() then
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.OBJ_KILL, "kill" )
		report = SCRIPTS.INGAME.ASSASSINATION.KO
		mission.reportedCeoKOed = true
		mission.reportedCeoSeen = true
	else
		sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.OBJ_KILL, "kill" )
		mission.reportedCeoSeen = true

		--create that big white arrow pointing to the target
		script:addHook( followHeatSig )
	end

	local x,y = ceo:getLocation()
	script:queue( { type="pan", x=x, y=y } )
	if not sim:getTags().MM_sawRealCEO then
		script:queue( 1*cdefs.SECONDS )
		script:queue( { script=selectStoryScript( sim, report ), type="newOperatorMessage" } )
	end
end

local function playerSeesRealCEO( script, sim, mission ) --only in use if decoy is in place)
	-- local _, ceo, agent = script:waitFor(  mission_util.PC_SAW_UNIT("assassination_real")  ) -- no longer used. see new function desc for explanation
	local _, ceo, agent = script:waitFor( PC_SAW_UNIT_FIXED("assassination_real") )
	
	-- local hidingCell = findCell( sim, "saferoom_hide" )
	local hidingCell = sim:getCell( ceo:getLocation() )
	if sim.MM_bounty_disguise_active then
		local x,y = hidingCell.x, hidingCell.y
		script:queue( { type="pan", x=x, y=y } )
		script:queue( 1*cdefs.SECONDS )
		local report = SCRIPTS.INGAME.ASSASSINATION.FOUND_REAL_TARGET
		if sim:getTags().MM_decoyrevealed then
			report = SCRIPTS.INGAME.ASSASSINATION.FOUND_REAL_TARGET_LATE
		end	
		script:queue( 1*cdefs.SECONDS )
		script:queue( { script=selectStoryScript( sim, report ), type="newOperatorMessage" } )	
		sim:getTags().MM_sawRealCEO = true
		script:queue( { type="hideHUDInstruction" } )
		local fakeCEO = safeFindUnitByTag( sim, "assassination_fake")
		if fakeCEO then
			fakeCEO:getTraits().customName = STRINGS.MOREMISSIONS.GUARDS.BOUNTY_TARGET_DECOY
		end
	end
end

-- Update the player when the CEO is KOed/killed after seen
-- and Direct the bodyguard to the CEO everytime he goes down
local function ceoDown( script, sim, mission )
	local _, ceo
	repeat
		_, ceo = script:waitFor( CEO_KO, CEO_DEAD )

		if ceo:getTraits().iscorpse then
			mission.killedTarget = true
			sim._assassinationReward = simquery.scaleCredits( sim, mission.BOUNTY_VALUE )
			sim:addMissionReward( sim._assassinationReward )
			sim:getTags().MM_assassination_success = true
			sim.TA_mission_success = true -- flag for Talkative Agents

			sim:removeObjective( "kill" )
		end

		sim:setClimax(true)

		if sim:hasDaemonQueue() then
			-- Wait for simultaneous KOs/Kills to finish resolving before looking for bodyguard or nearest guard to alert.
			script:waitFor( { trigger = 'MM-KOGROUP-END' } )
		end

		sim:dispatchEvent( simdefs.EV_SCRIPT_EXIT_MAINFRAME ) -- In case the kill was via laser grid.
		script:waitFrames( .5*cdefs.SECONDS )
		doAlertBodyguard( sim, ceo, mission )

		if not ceo:getTraits().iscorpse and mission.reportedCeoSeen and not mission.reportedCeoKOed then
			mission.reportedCeoKOed = true
			script:waitFrames( 1.5*cdefs.SECONDS )
			script:queue( { script=selectStoryScript( sim, SCRIPTS.INGAME.ASSASSINATION.KO ), type="newOperatorMessage" } )
		end
	until ceo:getTraits().iscorpse

	if mission.reportedCeoSeen and not mission.reportedCeoKilled then
		mission.reportedCeoKilled = true
		script:waitFrames( 1.5*cdefs.SECONDS )
		script:queue( { script=selectStoryScript( sim, SCRIPTS.INGAME.ASSASSINATION.AFTERMATH ), type="newOperatorMessage" } )
	end
end

local function playerSeesSaferoom(script, sim)
	script:waitFor( mission_util.PC_SAW_CELL_WITH_TAG( script, "saferoom_door" ) )

	sim:dispatchEvent( simdefs.EV_SCRIPT_EXIT_MAINFRAME ) -- In case the kill was via laser grid.
	sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.OBJ_UNLOCK, "unlock" )
	local doorCell = findCell( sim, "saferoom_doorouter" )
	assert( doorCell )

	-- spawn a label-carrying decoder on the door
	local labelCarrier = simfactory.createUnit( unitdefs.prop_templates.MM_door_decoder_prop, sim )
	labelCarrier:getTraits().LOSarc = 0
	labelCarrier:getTraits().MM_label_carrier = true
	for dir, exit in pairs(doorCell.exits) do
		if exit.door and exit.closed then
			labelCarrier:setFacing( dir )
		end
	end
	sim:spawnUnit( labelCarrier )
	sim:warpUnit( labelCarrier, doorCell )
	labelCarrier:createTab( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.SECUREDOOR_TIP, "" )
	
	sim:getPC():glimpseUnit( sim, labelCarrier:getID() ) --this reveals the 'door decoder' and label if the player saw the inside of the door first

	script:queue( { type="pan", x=doorCell.x, y=doorCell.y } )
	script:queue( 1*cdefs.SECONDS )
	script:queue( { script=selectStoryScript( sim, SCRIPTS.INGAME.ASSASSINATION.DOOR_SIGHTED ), type="newOperatorMessage" } )
end

local function playerUnlocksSaferoom( script, sim )
	-- Trigger when the player could otherwise act: after an action has completed or at the start of the player turn.
	local _, agent, body = script:waitFor( PC_UNLOCK_SAFEROOM_AFTER_ACTION, PC_UNLOCK_SAFEROOM_START_TURN )

	script:removeHook( playerSeesSaferoom )

	doUnlockSaferoom( sim, agent )

	sim:removeObjective( "unlock" )

	--despawn the label-carrying decoder
	for _, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().MM_label_carrier == true then
			log:write("TAB DESTROYED.")
			unit:destroyTab()
			sim:warpUnit( unit, nil )
			sim:despawnUnit( unit )
		end
	end

	-- Cannot waitFrames in response to a TRG_UNIT_WARP. The walking animation ends up looping in place
	-- script:queue( { script=selectStoryScript( sim, SCRIPTS.INGAME.ASSASSINATION.DOOR_UNLOCKED ), type="newOperatorMessage" } )
end

local function trackBodyguardDead( script, sim )
	local _, bodyguard = script:waitFor( BODYGUARD_DEAD )
	-- The trigger ensures the corpse has the original tag
end

local function trackDroidDead( script, sim )
	local _, droid = script:waitFor( DROID_DEAD )
	-- The trigger ensures the corpse has the original tag
end

local function bodyguardAlertsCeo( script, sim, mission )
	local _, bodyguard = script:waitFor( BODYGUARD_DEAD, BODYGUARD_KO, BODYGUARD_ALERTED )

	if not bodyguard:getTraits().iscorpse then
		-- Keep this trigger active
		script:addHook( trackBodyguardDead )
	end

	local ceo = safeFindUnitByTag( sim, "assassination" )
	if ceo:isAlerted() then  -- Done
		return
	end

	if bodyguard:isDown() or bodyguard:getTraits().iscorpse then
		-- delay 1 full CORP turn before the CEO notices, unless the bodyguard wakes up first.
		local ev, _ = script:waitFor( mission_util.PC_END_TURN, BODYGUARD_ALERTED )
		if ev == mission_util.PC_END_TURN then
			script:waitFor( mission_util.PC_START_TURN, BODYGUARD_ALERTED )
		end
	else
		bodyguard:getTraits().MM_alertlink = nil --for tooltip
	end

	local bodyguardIsAwake = not bodyguard:isDown() and not bodyguard:getTraits().iscorpse
	doAlertCeo( sim, bodyguardIsAwake, mission )
end

-- Behavior once the CEO becomes alerted
-- Stage 1: Run to the safe.
-- Stage 2: Randomly search the room.
-- Stage 2b: If spooked run to a corner of the room.
-- In both 1 & 2b, the destination is set as a stationary patrol point.
local function ceoAlerted(script, sim, mission)
	local _, ceo = script:waitFor( CEO_ALERTED )
	local safe = mission_util.findUnitByTag( sim, "saferoom_safe" )
	ceo:getTraits().MM_alertlink = nil
	-- Send the CEO to the safes
	local xSafe,ySafe = safe:getLocation()
	local finalCell = findCell( sim, "saferoom_flee" )
	assert( finalCell )
	local finalFacing = simquery.getDirectionFromDelta(xSafe - finalCell.x, ySafe - finalCell.y)
	ceo:getTraits().patrolPath = { { x = finalCell.x, y = finalCell.y, facing = finalFacing } }

	-- remove these hooks, as we don't want the bodyguard trying to do these things while the CEO is in the panic room
	script:removeHook(keepClose)
	script:removeHook(waitForInterest)
	script:removeHook(waitForUnitInterest)
	
	-- Alert the bodyguard, unless we have already sent an alert
	-- (No double interest for KO and first wakeup)
	if not ceo:getTraits().hasSentAlert then
		doAlertBodyguard(sim, ceo, mission)
	end
	if sim.MM_bounty_disguise_active then
		ceo = safeFindUnitByTag(sim, "assassination_real")
		doAlertCeo( sim, nil, mission )
	end
	
	-- Tell the player (using the vanilla CFO running line)
	if ceo and not ceo:isDown() then
		-- script:queue( { script=SCRIPTS.INGAME.CENTRAL_CFO_RUNNING, type="newOperatorMessage" } ) --we don't need this anymore
		sim:getPC():glimpseUnit(sim, ceo:getID() )
	end

	-- Wait for the CEO to reach the safe
	_, ceo = script:waitFor( CEO_ARMING )
	
	-- New "patrol" destination: corner of the room, hidden from the door by tall cover.
	-- This is the CEO's fallback when spooked.
	local hidingCell = findCell( sim, "saferoom_hide" )
	
	--hotfix for bug that causes CEO to leave the room after getting gun: give him a new investigation point immediately after he arms himself
	ceo:getBrain():spawnInterest(hidingCell.x, hidingCell.y, sim:getDefs().SENSE_DEBUG, "REASON_MM_ASSASSINATION") --vip stays put and investigates in place	
	
	ceo:getTraits().patrolPath = { { x = hidingCell.x, y = hidingCell.y, facing = calculateBestFacing( sim, hidingCell, ceo ) } }

	-- Fully armed and operational.
	local weapon = safeFindUnitByTag( sim, "saferoom_weapon" )
	if weapon and weapon:isValid() and safe and safe:isValid() and safe:hasChild( weapon:getID() ) then
		local sound = simdefs.SOUNDPATH_SAFE_OPEN
		--sound = "SpySociety/Objects/securitysafe_open" --is there a difference?
		safe:getTraits().open = true --this is a flag for anim, not sure if setting it to open and then closed again before/after the event will look good but worth a try -Hek
		sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR, { unitID = ceo:getID(), facing = finalFacing, sound = sound, soundFrame = 1 } )
		sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR_PST, { unitID = ceo:getID(), facing = finalFacing } )
		safe:getTraits().open = false		
		inventory.giveItem( safe, ceo, weapon )
		sim:emitSound( { path = weapon:getUnitData().sounds.reload, range = simdefs.SOUND_RANGE_0 }, finalCell.x, finalCell.y, ceo )
		ceo:getTraits().pacifist = false
		ceo:getTraits().MM_ceo_armed = true
	end
end

local function exitWarning(mission)
	if not mission.killedTarget then
		return STRINGS.MOREMISSIONS.UI.HUD_WARN_EXIT_MISSION_ASSASSINATION
	end
end

local function despawnRedundantCameraDB(sim)
	local cameraDBs = {}
	for i,unit in pairs(sim:getAllUnits()) do
		if unit:getUnitData().id == "camera_core" then
			table.insert(cameraDBs, unit)
			local daemonList = sim:getIcePrograms()
			-- if daemonList:getCount() > 0 then
				-- unit:getTraits().mainframe_program = daemonList:getChoice( sim:nextRand( 1, daemonList:getTotalWeight() )) --make it fun y'know?
			-- end
		end
	end
	if #cameraDBs > 1 then
		sim:warpUnit( cameraDBs[2], nil )
		sim:despawnUnit( cameraDBs[2] )
	end
end

local function bodyguardShotAt( script, sim )
	local _, guard, agent = script:waitFor( BODYGUARD_SHOT_AT )
	if guard:isValid() and guard:getLocation() and not guard:isKO() then
		if simquery.couldUnitSee( sim, guard, agent, true, nil ) then
			guard:turnToFace( agent:getLocation() )
		end
	end
end

local function waitForSteal( script, sim, mission )
	local _, decoy = script:waitFor( TRIED_TO_STEAL_FROM_DECOY )
	mission.revealDecoy( sim, decoy )
end

local function despawnDecoy( script, sim )
	local _, decoyUnit,newDecoy = script:waitFor( DECOY_REVEALED )
	local x, y = decoyUnit:getLocation()

	if newDecoy:getTraits().wounds > newDecoy:getTraits().woundsMax then
		newDecoy:killUnit( sim ) --now kill decoy droid if it was damaged.
	end
	
	script:queue( { type="hideHUDInstruction" } ) 
	script:waitFor( mission_util.PC_ANY, PC_AFTER_ANY )
	sim:warpUnit( decoyUnit, nil ) -- remove the original
	sim:despawnUnit( decoyUnit ) 
	
	if x and y then
		script:queue( { type="pan", x=x, y=y } )
	end
	script:queue( 1*cdefs.SECONDS )
	local report = SCRIPTS.INGAME.ASSASSINATION.DECOY_REVEALED
	script:queue( { script=selectStoryScript( sim, report ), type="newOperatorMessage" } )	
end

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

-- local function updateAgency( script, sim, mission ) --UNUSED
	-- script:waitFor( PC_WON )
		-- if mission.killedTarget then
		-- sim:getParams().agency.MM_assassinations = sim:getParams().agency.MM_assassinations or 0
		-- sim:getParams().agency.MM_assassinations = sim:getParams().agency.MM_assassinations + 1
	-- end
-- end
---------------------------------------------------------------------------------------------
-- Begin!

local mission = class( escape_mission )

-- "reveal" decoy, but actually despawn it and replace it with an android
mission.revealDecoy = function( sim, decoyUnit, stagger, EMP )
	log:write("LOG reveal decoy1")
	if sim:getTags().MM_decoyrevealed or (sim.MM_bounty_disguise_active == nil) or (not decoyUnit) then
		return
	end
	sim:getTags().MM_decoyrevealed = true
	local x0, y0 = decoyUnit:getLocation()
	local cell = sim:getCell(x0, y0)
	local facing = decoyUnit:getFacing()
	local newDecoyTemplate = unitdefs.lookupTemplate( "MM_bounty_target_android" )
	local newDecoy = simfactory.createUnit( newDecoyTemplate, sim )
	newDecoy:setPlayerOwner(sim:getNPC())
	sim:spawnUnit( newDecoy )
	newDecoy:setFacing( facing )
	local oldKanim = decoyUnit:getUnitData().kanim
	newDecoy:getTraits().canBeCritical = true --delay killing of unit until later, due to laser nonsense
	sim:warpUnit( newDecoy, cell ) --warping straight into lethal laser beams and dying = error!!
	newDecoy:getTraits().canBeCritical = false
	newDecoy:changeKanim( oldKanim )
	newDecoy:setPather(sim:getNPC().pather)
	newDecoy:getBrain():setSituation(sim:getNPC():getIdleSituation() )
	sim:getNPC():getIdleSituation():generatePatrolPath( newDecoy, newDecoy:getLocation() )
	newDecoy:getTraits().patrolPath = { { x = cell.x, y = cell.y, facing = facing } }
	if decoyUnit:getTraits().tagged then
		newDecoy:getTraits().tagged = true
	end	
	-- removing original now is a problem because aiplayer may still be processing reactions for this unit. So we'll delay the despawn until later and just make the original disappear
	decoyUnit:changeKanim( "kanim_transparent" )
	decoyUnit:getTraits().canBeCritical = true
	decoyUnit:getTraits().sightable = nil
	decoyUnit:getTraits().MM_invisible_to_PC = true
	
	-- cosmetic stuff
	sim:dispatchEvent( simdefs.EV_PLAY_SOUND, {sound="SpySociety/Actions/holocover_deactivate", x=x0,y=y0} )
	sim:dispatchEvent( simdefs.EV_UNIT_ADD_FX, { unit = newDecoy, kanim = "fx/agent_cloak_fx", symbol = "effect", anim="out", above=true, params={} } )	
	-- hologram drops, revealing decoy to be a robot!
	newDecoy:changeKanim(  nil , 0.05 )
	newDecoy:changeKanim(  oldKanim , 0.1 )
	newDecoy:changeKanim(  nil , 0.05 )
	newDecoy:changeKanim(  oldKanim , 0.05 )
	newDecoy:changeKanim(  nil , 0.1 )
	newDecoy:changeKanim(  oldKanim , 0.05 )
	newDecoy:changeKanim(  nil )
	
	-- implement effect of player actions on despawned original
	newDecoy:getBrain():getSenses():addInterest( cell.x, cell.y, simdefs.SENSE_RADIO, simdefs.REASON_SHARED )  -- REASON_SHARED is alerting
	doAlertBodyguard( sim, newDecoy, mission )
	sim:processReactions( newDecoy )
	if newDecoy and stagger then
		sim:dispatchEvent( simdefs.EV_UNIT_HIT, {unit = newDecoy, result = 0} ) --stagger FX
	end
	if EMP and newDecoy then
		local bootTime = EMP.bootTime or 1
		local noEmpFX = EMP.noEmpFX or nil
		newDecoy:processEMP( bootTime, noEmpFX )
	end
	
	sim:triggerEvent("MM_decoy_revealed", { unit = decoyUnit, newDecoy = newDecoy })
	return newDecoy
end

--spawns dupe of CEO with empty inventory and custom traits
local function spawnDecoy( sim, cell, facing )
	local decoyTemplate = unitdefs.lookupTemplate( "MM_bounty_target_fake" )
	local decoyUnit = simfactory.createUnit( decoyTemplate, sim )
	decoyUnit:setPlayerOwner(sim:getNPC())
	sim:spawnUnit( decoyUnit )
	decoyUnit:setFacing( facing )
	sim:refreshUnitLOS( decoyUnit )
	sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = decoyUnit } )
	sim:warpUnit( decoyUnit, cell )	
	decoyUnit:setPather(sim:getNPC().pather)
	decoyUnit:getBrain():setSituation(sim:getNPC():getIdleSituation() )
	sim:getNPC():getIdleSituation():generatePatrolPath( decoyUnit, decoyUnit:getLocation() )
	decoyUnit:getTraits().patrolPath = { { x = cell.x, y = cell.y, facing = facing } }
	decoyUnit:getTraits().MM_decoy = true
	decoyUnit:getTraits().MM_unsearchable = true
	decoyUnit:addTag("assassination")
	decoyUnit:addTag("assassination_fake")
	if sim:getParams().difficultyOptions.MM_difficulty and (sim:getParams().difficultyOptions.MM_difficulty == "easy") then
		decoyUnit:getTraits().MM_alertlink = nil
		decoyUnit:getTraits().hasSentAlert = true
	end
end

--NEW decoy mechanic: real VIP in saferoom, replaced with disguised android
local function tryDecoy( sim )
	-- log:write("LOG trying decoy")
	local vip = nil -- resetting for save file edge cases
	local no_decoy = nil
	-- if sim:getParams().agency.MM_assassinations == nil then
		-- no_decoy = true -- guarantee no decoy on first campaign assassination
	-- end
	local security_level = sim:getParams().difficulty
	local decoy_chance_bonus = 0.1 * security_level
	local FINAL_CHANCE_OF_DECOY = CHANCE_OF_DECOY + decoy_chance_bonus
	if FINAL_CHANCE_OF_DECOY > 1 then
		FINAL_CHANCE_OF_DECOY = 0.9
	end
	if (sim:nextRand() < FINAL_CHANCE_OF_DECOY) then
		log:write("LOG implementing decoy")	
		for i, unit in pairs(sim:getNPC():getUnits()) do 
			if unit:getTraits().MM_bounty_target then
				vip = unit 		--locate VIP	
				unit:getTraits().MM_bounty_disguise = true
			end
		end
		local hidingCell = findCell( sim, "saferoom_hide" )
		local safeCell = findCell( sim, "saferoom_flee" )
		if vip and hidingCell then
			local oldCell = sim:getCell(vip:getLocation())
			sim:warpUnit( vip, hidingCell ) 
			local oldFacing = vip:getFacing()
			vip:setFacing( calculateBestFacing( sim, hidingCell, vip ) )
			vip:getTraits().MM_realtarget = true
			vip:getTraits().patrolPath = { { x = safeCell.x, y = safeCell.y }, { x = hidingCell.x, y = hidingCell.y } }
			vip:addTag("assassination_real")
			sim:refreshUnitLOS( vip )
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = vip } )
			spawnDecoy( sim, oldCell, oldFacing )
			sim.MM_bounty_disguise_active = true
		end
		
		--now give all agents the ability to "steal" from the decoy
		for i, agent in pairs(sim:getPC():getUnits()) do --edge cases? do we need to worry about agents being added mid-mission?
			agent:giveAbility("MM_fakesteal")
		end
	end
end

local function activateCam( sim )
	for i, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().MM_camera and (unit:getTraits().mainframe_status ~= "active") then
			unit:getTraits().mainframe_status = "active"
			unit:getTraits().hasSight = true
			sim:refreshUnitLOS( unit )
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = unit } )	
			sim:addTrigger( simdefs.TRG_OVERWATCH, unit )	
		end
	end
end

function mission:init( scriptMgr, sim )
	escape_mission.init( self, scriptMgr, sim )
	sim.TA_mission_success = false
	despawnRedundantCameraDB( sim )
	tryDecoy( sim )
	activateCam( sim )
	-- Base credit value for a successful kill
	self.BOUNTY_VALUE = 1500

	sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.OBJ_FIND, "find" )
	spawnCeoWeapon( sim )
	initCeoTraits( sim ) --includes Easy Mode nerfing

	sim.exit_warning = function() return exitWarning(self) end

	scriptMgr:addHook( "SEE", playerSeesCeo, nil, self )
	scriptMgr:addHook( "KILL", ceoDown, nil, self )
	scriptMgr:addHook( "SEEDOOR", playerSeesSaferoom, nil, self )
	scriptMgr:addHook( "UNLOCK", playerUnlocksSaferoom, nil, self )
	scriptMgr:addHook( "BODYGUARD", bodyguardAlertsCeo, nil, self )
	scriptMgr:addHook( "CEO", ceoAlerted, nil, self )
	scriptMgr:addHook( "bodyguardShotAt", bodyguardShotAt )
	scriptMgr:addHook( "bodyguardShotAt", bodyguardShotAt )
	scriptMgr:addHook( "waitForInterest", waitForInterest )
	scriptMgr:addHook( "waitForUnitInterest", waitForUnitInterest )
	scriptMgr:addHook( "keepClose", keepClose )
	scriptMgr:addHook( "SEE_REAL", playerSeesRealCEO, nil, self )
	scriptMgr:addHook( "waitForSteal", waitForSteal, nil, self )
	scriptMgr:addHook( "despawnDecoy", despawnDecoy )
	scriptMgr:addHook( "trackDroidDead", trackDroidDead )
	-- scriptMgr:addHook( "updateAgency", updateAgency, nil, self )
	--This picks a reaction rant from Central on exit based upon whether or not the target is dead yet.
	local scriptfn = function()

        local scripts = SCRIPTS.INGAME.ASSASSINATION.CENTRAL_JUDGEMENT.GOTNOTHING
		if self.killedTarget then
			scripts = SCRIPTS.INGAME.ASSASSINATION.CENTRAL_JUDGEMENT.GOTBODY
		end
        local scr = scripts[sim:nextRand(1, #scripts)]
        return scr
    end	
	scriptMgr:addHook( "FINAL", mission_util.CreateCentralReaction(scriptfn))	
end


function mission.pregeneratePrefabs( cxt, tagSet )
	escape_mission.pregeneratePrefabs( cxt, tagSet )
	table.insert( tagSet[1], "assassination" )
end

function mission.generatePrefabs( cxt, candidates )
    local prefabs = include( "sim/prefabs" ) 
	escape_mission.generatePrefabs( cxt, candidates )
	prefabs.generatePrefabs( cxt, candidates, "MM_cameradb", 1 ) 
end	


return mission
