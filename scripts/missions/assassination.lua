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

local CHANCE_OF_DECOY = 0.75 --0.5
local DECLOAK_RANGE = 1.5
local bodyguard_unit --file-wide variable for ease of checking
local bounty_target_unit
----
-- Trigger Definitions

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
local CEO_ESCAPED =
{
	trigger = "vip_escaped",
	fn = function( sim, evData )
		if evData.unit:hasTag("assassination") then
			return true
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
	trigger = simdefs.TRG_UNIT_SHOT,
	fn = function( sim, evData )
		if evData.targetUnit:getTraits().MM_bodyguard then
			return evData.targetUnit, evData.sourceUnit
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

local function isSaferoomKey( unit )
	return (unit:isDown() or unit:getTraits().iscorpse) and (unit:hasTag("assassination") or unit:hasTag("bodyguard"))
end
local function playerCanUnlockSaferoom( sim )
	-- Any player non-drone unit is at the door and standing over an authorized body.
	for _,unit in ipairs( sim:getPC():getUnits() ) do
		local cell = sim:getCell( unit:getLocation() )
		if not unit:isDown() and not unit:getTraits().isDrone and simquery.cellHasTag( sim, cell, "saferoom_unlock" ) then
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
	local ceo = mission_util.findUnitByTag( sim, "assassination" )

	-- CEO is allowed to walk in and out of the saferoom
	if ceo:getTraits().npcPassiveKeybits then
		ceo:getTraits().npcPassiveKeybits = binops.b_or( ceo:getTraits().npcPassiveKeybits, simdefs.DOOR_KEYS.BLAST_DOOR )
	else
		ceo:getTraits().npcPassiveKeybits = simdefs.DOOR_KEYS.BLAST_DOOR
	end

	-- No penalty for killing this one.
	ceo:getTraits().cleanup = nil
end

-- Alert the CEO
local function doAlertCeo( sim, fromBodyguard )
	ceo = safeFindUnitByTag( sim, "assassination" )
	if ceo and ceo:isValid() and not ceo:isDown() and not ceo:getTraits().iscorpse and not ceo:isAlerted() then
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

-- Alert the bodyguard and send him to the CEO's location
-- If the bodyguard is indisposed, the nearest other guard responses to the call.
local function doAlertBodyguard( sim, ceo )
	local x,y = ceo:getLocation()
	local bodyguard = safeFindUnitByTag( sim, "bodyguard" )
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

--full circle to the CFO mission followHeatSig
local function followHeatSig( script, sim )
	sim:forEachUnit(
	function(unit)
		if unit:getTraits().MM_bounty_target then 
			local x, y = unit:getLocation()
			script:queue( { type="displayHUDInstruction", text=STRINGS.MISSIONS.UTIL.HEAT_SIGNATURE_DETECTED, x=x, y=y } )
			script:queue( { type="pan", x=x, y=y } )
		end
	end)

	while true do 
		local ev, triggerData = script:waitFor( mission_util.UNIT_WARP )
		if triggerData.unit:getTraits().MM_bounty_target then
			script:queue( { type="hideHUDInstruction" } ) 
			local x, y = triggerData.unit:getLocation()
            if x and y then
			    script:queue( { type="displayHUDInstruction", text=STRINGS.MISSIONS.UTIL.HEAT_SIGNATURE_DETECTED, x=x, y=y } )
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
	script:queue( .25*cdefs.SECONDS )
	script:queue( { script=selectStoryScript( sim, report ), type="newOperatorMessage" } )
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
		doAlertBodyguard( sim, ceo )

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
	local labelCarrier = simfactory.createUnit( unitdefs.prop_templates.door_decoder, sim )
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

	script:queue( { type="pan", x=doorCell.x, y=doorCell.y } )
	script:queue( .25*cdefs.SECONDS )
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
	script:queue( { script=selectStoryScript( sim, SCRIPTS.INGAME.ASSASSINATION.DOOR_UNLOCKED ), type="newOperatorMessage" } )
end

local function trackBodyguardDead( script, sim )
	local _, bodyguard = script:waitFor( BODYGUARD_DEAD )
	-- The trigger ensures the corpse has the original tag
end

local function bodyguardAlertsCeo( script, sim )
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
	end

	local bodyguardIsAwake = not bodyguard:isDown() and not bodyguard:getTraits().iscorpse
	doAlertCeo( sim, bodyguardIsAwake )
end

-- Behavior once the CEO becomes alerted
-- Stage 1: Run to the safe.
-- Stage 2: Randomly search the room.
-- Stage 2b: If spooked run to a corner of the room.
-- In both 1 & 2b, the destination is set as a stationary patrol point.
local function ceoAlerted(script, sim)
	local _, ceo = script:waitFor( CEO_ALERTED )
	local safe = mission_util.findUnitByTag( sim, "saferoom_safe" )

	-- Send the CEO to the safe
	local xSafe,ySafe = safe:getLocation()
	local finalCell = findCell( sim, "saferoom_flee" )
	assert( finalCell )
	local finalFacing = simquery.getDirectionFromDelta(xSafe - finalCell.x, ySafe - finalCell.y)
	ceo:getTraits().patrolPath = { { x = finalCell.x, y = finalCell.y, facing = finalFacing } }

	-- Alert the bodyguard, unless we have already sent an alert
	-- (No double interest for KO and first wakeup)
	if not ceo:getTraits().hasSentAlert then
		doAlertBodyguard(sim, ceo)
	end

	-- Tell the player (using the vanilla CFO running line)
	if not ceo:isDown() then
		script:queue( { script=SCRIPTS.INGAME.CENTRAL_CFO_RUNNING, type="newOperatorMessage" } )
		sim:getPC():glimpseUnit(sim, ceo:getID() )
	end

	-- Wait for the CEO to reach the safe
	_, ceo = script:waitFor( CEO_ARMING )

	-- New "patrol" destination: corner of the room, hidden from the door by tall cover.
	-- This is the CEO's fallback when spooked.
	local hidingCell = findCell( sim, "saferoom_hide" )
	ceo:getTraits().patrolPath = { { x = hidingCell.x, y = hidingCell.y, facing = calculateBestFacing( sim, hidingCell, ceo ) } }

	-- Fully armed and operational.
	local weapon = safeFindUnitByTag( sim, "saferoom_weapon" )
	if weapon and weapon:isValid() and safe and safe:isValid() and safe:hasChild( weapon:getID() ) then
		local sound = simdefs.SOUNDPATH_SAFE_OPEN
		--sound = "SpySociety/Objects/securitysafe_open" --is there a difference?
		safe:getTraits().open = true --this is a flag for anim, not sure if setting it to open and then closed again before/after the event will look good but worth a try -Hek
		sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR, { unitID = ceo:getID(), facing = finalFacing, sound = sound, soundFrame = 1 } )
		safe:getTraits().open = false		
		inventory.giveItem( safe, ceo, weapon )
		sim:emitSound( { path = weapon:getUnitData().sounds.reload, range = simdefs.SOUND_RANGE_0 }, finalCell.x, finalCell.y, ceo )
		ceo:getTraits().pacifist = false
	end
end

local function exitWarning(mission)
	if not mission.killedTarget then
		return STRINGS.MOREMISSIONS.UI.HUD_WARN_EXIT_MISSION_ASSASSINATION
	end
end

local function judgement(sim, mission)
	local scripts =
		mission.killedTarget and SCRIPTS.INGAME.ASSASSINATION.CENTRAL_JUDGEMENT.GOTBODY or
		SCRIPTS.INGAME.ASSASSINATION.CENTRAL_JUDGEMENT.NOTHING
	return scripts[sim:nextRand(1, #scripts)]
end

local function centralReactionDecloak( sim )
	local script = sim:getLevelScript()
	script:queue( 2 * cdefs.SECONDS )
	-- blah blah
end

local function disguiseRange( script, sim, mission ) --UNUSED
	while sim.MM_bounty_disguise_active and bodyguard_unit and bounty_target_unit do
		script:waitFor( UNIT_WARP )	
		for i, enemy in pairs(sim:getNPC():getUnits()) do
			if enemy:getTraits().MM_bounty_disguise then
				for k, agent in pairs(sim:getPC():getUnits()) do
					local x0, y0 = enemy:getLocation()
					local x1, y1 = agent:getLocation()
					local distance = mathutil.dist2d( x0, y0, x1, y1)
					if sim:canUnitSeeUnit( agent, enemy ) and (distance <= DECLOAK_RANGE ) then
						-- log:write("LOG decloaking")
						mission.bodyguardSwap( sim )
					end
				end
			end
		end
	end
end

local function disguiseRangeDoor( script, sim, mission ) --UNUSED
	while sim.MM_bounty_disguise_active and bodyguard_unit and bounty_target_unit do
		script:waitFor( UNIT_USE_DOOR )
		for i, enemy in pairs(sim:getNPC():getUnits()) do
			if enemy:getTraits().MM_bounty_disguise then
				for k, agent in pairs(sim:getPC():getUnits()) do
					local x0, y0 = enemy:getLocation()
					local x1, y1 = agent:getLocation()
					local distance = mathutil.dist2d( x0, y0, x1, y1)
					if sim:canUnitSeeUnit( agent, enemy ) and (distance <= DECLOAK_RANGE ) then
						log:write("LOG decloaking")
						mission.bodyguardSwap( sim )
					end
				end
			end
		end
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
	if guard:isValid() and guard:getLocation() then
		if simquery.couldUnitSee( sim, guard, agent, true, nil ) then
			guard:turnToFace( agent:getLocation() )
		end
	end
end

local function dropDisguises( sim, ceo, guard )

	local x0, y0 = ceo:getLocation()
	local x1, y1 = guard:getLocation()
	
	sim:dispatchEvent( simdefs.EV_PLAY_SOUND, {sound="SpySociety/Actions/holocover_deactivate", x=x1,y=y1} )
	sim:dispatchEvent( simdefs.EV_PLAY_SOUND, {sound="SpySociety/Actions/holocover_deactivate", x=x0,y=y0} )
	
	sim:dispatchEvent( simdefs.EV_UNIT_ADD_FX, { unit = ceo, kanim = "fx/agent_cloak_fx", symbol = "effect", anim="out", above=true, params={} } )		
	sim:dispatchEvent( simdefs.EV_UNIT_ADD_FX, { unit = guard, kanim = "fx/agent_cloak_fx", symbol = "effect", anim="out", above=true, params={} } )		

	local ceo_kanim = ceo:getUnitData().kanim
	local guard_kanim = guard:getUnitData().kanim
	
	ceo:changeKanim(  nil , 0.05 )
	guard:changeKanim(  nil , 0.05 )
	
	ceo:changeKanim(  guard_kanim , 0.1 )
	guard:changeKanim(  ceo_kanim , 0.1 )
	
	ceo:changeKanim(  nil , 0.05 )
	guard:changeKanim(  nil , 0.05 )
	
	ceo:changeKanim(  guard_kanim , 0.05 )
	guard:changeKanim(  ceo_kanim , 0.05 )
	
	ceo:changeKanim(  nil , 0.1 )
	guard:changeKanim(  nil , 0.1 )
	
	ceo:changeKanim(  guard_kanim , 0.05 )
	guard:changeKanim(  ceo_kanim , 0.05 )
	
	ceo:changeKanim(  nil )
	guard:changeKanim(  nil )		
	
end

local function checkBodyguardAlert( script, sim, mission )
	local _, guard = script:waitFor( BODYGUARD_ALERTED )
	if guard:getTraits().MM_bounty_disguise then
		mission.bodyguardSwap( sim )
	end
end

local function checkBountyAlert( script, sim, mission )
	local _, ceo = script:waitFor( CEO_ALERTED )
	
	if ceo:getTraits().MM_bounty_disguise then
		mission.bodyguardSwap( sim )
	end
end
---------------------------------------------------------------------------------------------
-- Begin!

local mission = class( escape_mission )

mission.getOpposite = function( sim, unit )
	-- outputs ceo if you input bodyguard and vice versa
	local opposite = nil
	for i, u in pairs(sim:getAllUnits()) do
		if u:getTraits().MM_bounty_disguise and not (u == unit) then
			opposite = u
		end
	end
	return opposite
end

mission.bodyguardSwap = function( sim )
	local bodyguard
	local ceo 
	for i, unit in pairs(sim:getNPC():getUnits()) do
		if unit:getTraits().MM_bodyguard then
			bodyguard = unit
		end
		if unit:getTraits().MM_bounty_target then
			ceo = unit
		end
	end	

	if bodyguard and ceo then
		local bodyguard_cell = sim:getCell(bodyguard:getLocation())	local bodyguard_facing = bodyguard:getFacing()	
		local bodyguard_patrol = bodyguard:getTraits().patrolPath
		local bodyguard_tagged = bodyguard:getTraits().tagged or nil
		local bodyguard_observed = bodyguard:getTraits().patrolObserved or nil		
		local bodyguard_heart = bodyguard:getTraits().heartMonitor -- <3 <3 <3
		
		local ceo_patrol = ceo:getTraits().patrolPath
		local ceo_facing = ceo:getFacing()
		local ceo_cell = sim:getCell(ceo:getLocation())
		local ceo_tagged = ceo:getTraits().tagged or nil
		local ceo_observed = ceo:getTraits().patrolObserved or nil
		local ceo_heart = ceo:getTraits().heartMonitor -- <3 <3 <3
		
		-- synchronise inventories?
		
		bodyguard:setFacing(ceo_facing)		
		ceo:setFacing( bodyguard_facing )	

		sim:warpUnit( bodyguard, ceo_cell )
		
		sim:warpUnit( ceo, bodyguard_cell )	
		dropDisguises( sim, ceo, bodyguard )

		-- can't predict all possible alterations to the 'pre-decloak' unit, but this should cover most of them
		bodyguard:getTraits().MM_bounty_disguise = nil
		bodyguard:getTraits().tagged = ceo_tagged
		bodyguard:getTraits().patrolObserved = ceo_observed
		bodyguard:getTraits().heartMonitor = ceo_heart
		
		ceo:getTraits().MM_bounty_disguise = nil
		ceo:getTraits().tagged = bodyguard_tagged
		ceo:getTraits().patrolObserved = bodyguard_observed
		ceo:getTraits().heartMonitor = bodyguard_heart
		
		sim.MM_bounty_disguise_active = nil
		sim:processReactions()
		if bounty_target_unit then --have central comment on the disguise if target is still alive
			centralReactionDecloak( sim )
		end

	end		
end

local function tryDecoy( sim )
	bodyguard_unit = nil
	bounty_target_unit = nil -- resetting for save file edge cases
	if sim:nextRand() < CHANCE_OF_DECOY then --0.5 -- memo: comment back in after testing
		-- this determines whether decoy/disguise mechanic will be in place this mission.
		for i, unit in pairs(sim:getNPC():getUnits()) do
			if unit:getTraits().MM_bounty_target then
				bounty_target_unit = unit
				unit:getTraits().MM_bounty_disguise = true
			elseif unit:getTraits().MM_bodyguard then
				bodyguard_unit = unit
				unit:getTraits().MM_bounty_disguise = true --gets applied to both target and bodyguard
			end
		end
		sim.MM_bounty_disguise_active = true
	end
end

function mission:init( scriptMgr, sim )
	escape_mission.init( self, scriptMgr, sim )
	sim.TA_mission_success = false
	despawnRedundantCameraDB( sim )
	tryDecoy( sim )
	-- Base credit value for a successful kill
	self.BOUNTY_VALUE = 1000

	sim:addObjective( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.OBJ_FIND, "find" )
	spawnCeoWeapon( sim )
	initCeoTraits( sim )

	sim.exit_warning = function() return exitWarning(self) end

	scriptMgr:addHook( "SEE", playerSeesCeo, nil, self )
	scriptMgr:addHook( "KILL", ceoDown, nil, self )
	scriptMgr:addHook( "SEEDOOR", playerSeesSaferoom, nil, self )
	scriptMgr:addHook( "UNLOCK", playerUnlocksSaferoom, nil, self )

	scriptMgr:addHook( "BODYGUARD", bodyguardAlertsCeo, nil, self )
	scriptMgr:addHook( "CEO", ceoAlerted, nil, self )
	scriptMgr:addHook( "bodyguardShotAt", bodyguardShotAt )
	
	scriptMgr:addHook( "checkBodyguardAlert", checkBodyguardAlert, nil, self )
	scriptMgr:addHook( "checkBountyAlert", checkBountyAlert, nil, self )	
	-- scriptMgr:addHook( "disguiseRange", disguiseRange, nil, self )
	-- scriptMgr:addHook( "disguiseRangeDoor", disguiseRangeDoor, nil, self ) --currently disabling the auto-decloak when at close range

	--This picks a reaction rant from Central on exit based upon whether or not the target is dead yet.
	scriptMgr:addHook( "FINAL", mission_util.CreateCentralReaction(function() judgement(sim, self) end))
end


function mission.pregeneratePrefabs( cxt, tagSet )
	escape_mission.pregeneratePrefabs( cxt, tagSet )
	table.insert( tagSet[1], "assassination" )


	-- local prefabs = include( "sim/prefabs" )

	-- table.insert( tagSet, { "entry_hotel_ground", makeTags( "struct", cxt.params.difficultyOptions.roomCount ) })
	-- -- table.insert( tagSet, { "entry", makeTags( "struct", cxt.params.difficultyOptions.roomCount ) })
	-- tagSet[1].fitnessSelect = prefabs.SELECT_HIGHEST

	-- --table.insert( tagSet, { "research_lab" })

	-- table.insert( tagSet, { "struct_small", "struct_small" })
	-- table.insert( tagSet, { { "exit", exitFitnessFn } })
end

function mission.generatePrefabs( cxt, candidates )
    local prefabs = include( "sim/prefabs" ) 
	escape_mission.generatePrefabs( cxt, candidates )
	prefabs.generatePrefabs( cxt, candidates, "MM_cameradb", 1 ) 
end	


return mission
