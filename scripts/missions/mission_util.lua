local cdefs = include( "client_defs" )
local util = include("modules/util")
local simdefs = include("sim/simdefs")

local mission_util = include("sim/missions/mission_util")

local OK_OPTIONS = { "OK" }

-- this is copypasted from Interactive Events

local PC_LOOTED_SAFE_PRE = function( safeID )
    return
    {
	    trigger = "TRG_SAFE_LOOTED_PRE",
	    fn = function( sim, triggerData )
            if triggerData.targetUnit:getID() == safeID then
                return triggerData
            end
	    end,
    }
end

local PC_TALKED_TO = function( agentID )
    return
    {
	    trigger = "TRG_UNIT_TALKTO",
	    fn = function( sim, triggerData )
            if triggerData.unit:getID() == agentID then
                return triggerData
            end
	    end,
    }
end

local function showDialog( sim, headerTxt, bodyTxt, options, t, result )
	sim._choiceCount = sim._choiceCount + 1
	local choice = sim._choices[ sim._choiceCount ]
	options = options or OK_OPTIONS

	if not choice then
		-- Choice has not yet been made.
		sim:dispatchChoiceEvent( "INC_EV_CHOICE_DIALOG", util.extend( { headerTxt = headerTxt, bodyTxt = bodyTxt, options = options }) ( t ), true )
		choice = sim._choices[ sim._choiceCount ]
	else
		--simlog( "STORED CHOICE %d/%d: %d", sim._choiceCount, #sim._choices, choice )
	end

	--simlog("FINAL CHOICE: %s", tostring(choice))

	--assert( options[ choice ] ~= nil, tostring(choice) .. ": " ..util.tostringl(options) )
	return choice
end

local function showGoodResult( sim, headerTxt, bodyTxt )
	sim:dispatchEvent( simdefs.EV_PLAY_SOUND, simdefs.SOUND_HUD_INCIDENT_POSITIVE.path )
	sim:dispatchChoiceEvent( "INC_EV_CHOICE_DIALOG", { headerTxt = headerTxt, bodyTxt = bodyTxt, options = OK_OPTIONS }, true )
end

local function showBadResult( sim, headerTxt, bodyTxt )
	sim:dispatchEvent( simdefs.EV_PLAY_SOUND, simdefs.SOUND_HUD_INCIDENT_NEGATIVE.path )
	sim:dispatchChoiceEvent( "INC_EV_CHOICE_DIALOG", { headerTxt = headerTxt, bodyTxt = bodyTxt, options = OK_OPTIONS }, true )
end

local function showNeutralResult( sim, headerTxt, bodyTxt )
	sim:dispatchChoiceEvent( "INC_EV_CHOICE_DIALOG", { headerTxt = headerTxt, bodyTxt = bodyTxt, options = OK_OPTIONS }, true )
end

local function giftItem(sim,unit,templateName)
	local x,y = unit:getLocation()

	local simfactory = include( "sim/simfactory" )
    local unitdefs = include( "sim/unitdefs" )
    local unitData = unitdefs.lookupTemplate( templateName )
	local newItem = simfactory.createUnit( unitData, sim )
    local cell = sim:getCell( x, y )
    if cell then
	    sim:spawnUnit( newItem )
	    sim:warpUnit( newItem, cell )
    end

	sim:dispatchEvent( simdefs.EV_ITEMS_PANEL, { unit = unit, x = x, y = y } )
end


-- Choose and play 1 of a selection of possible voice scripts.
-- Based on the relevant part of vanilla mission_util.DoReportObject()
DEV_PLAY_ALL = false
local function reportScriptMsg(script, report)
	-- Input is either an immediate {txt,vo} table or an array of choices.
	if type(report) == "table" and not report.txt and not report.vo and report[1] then
		if DEV_PLAY_ALL then
			script:queue( .25*cdefs.SECONDS )
			for _, s in ipairs(report) do
				script:queue( { script=report, type="newOperatorMessage" } )
				script:queue( .5*cdefs.SECONDS )
			end
		end

		local sim = script.sim or script.script.sim
		report = report[sim:nextRand(1, #report)]
	end
	script:queue( { script=report, type="newOperatorMessage" } )
	script:queue( .25*cdefs.SECONDS )
end

mission_util.PC_LOOTED_SAFE_PRE = PC_LOOTED_SAFE_PRE
mission_util.PC_TALKED_TO = PC_TALKED_TO
mission_util.giftItem = giftItem
mission_util.showDialog = showDialog
mission_util.showGoodResult = showGoodResult
mission_util.showBadResult = showBadResult
mission_util.showNeutralResult = showNeutralResult
mission_util.reportScriptMsg = reportScriptMsg

base_campaign_mission_init = mission_util.campaign_mission.init
function mission_util.campaign_mission:init( scriptMgr, sim, finalMission )
  base_campaign_mission_init( self, scriptMgr, sim, finalMission )

  if sim:getParams().agency.W93_aiTerminals then
    sim:getTags().extraPrograms = (sim:getTags().extraPrograms or 0) + sim:getParams().agency.W93_aiTerminals
  end
end

return mission_util
