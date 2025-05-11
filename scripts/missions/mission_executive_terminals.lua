local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local mission_util = include( "sim/missions/mission_util" )
local escape_mission = include( "sim/missions/escape_mission" )
local unitdefs = include( "sim/unitdefs" )
local simfactory = include( "sim/simfactory" )
local itemdefs = include( "sim/unitdefs/itemdefs" )
local serverdefs = include( "modules/serverdefs" )
local cdefs = include( "client_defs" )

local SCRIPTS = include('client/story_scripts')
local mission_executive_terminals = include( "sim/missions/mission_executive_terminals" )
local init_old = mission_executive_terminals.init

---------------------------------------------------------------------------------------------
-- Local helpers

local SITE_PLANS_TAG = "corp_map"
local OBJECTIVE_ID = "terminals"

local LOOT_TERMINAL =
{
	action = "abilityAction",
	pre = true,
	fn = function( sim, ownerID, userID, abilityIdx, ... )
		local unit, ownerUnit = sim:getUnit( userID ), sim:getUnit( ownerID )
		if not unit or not unit:isPC() or not ownerUnit or not ownerUnit:getTraits().public_term then
			return nil
		end

		if ownerUnit:getAbilities()[ abilityIdx ]:getID() == "stealCredits" then
            return ownerUnit
        end
	end,
}


local function doAftermath(script, sim)

    script:queue( 1*cdefs.SECONDS )
    script:queue( { script=SCRIPTS.INGAME.AFTERMATH.TERMS[sim:nextRand(1, #SCRIPTS.INGAME.AFTERMATH.TERMS)], type="newOperatorMessage" } )

    --shift guard patrols
    local idle = sim:getNPC():getIdleSituation()
    local guards = sim:getNPC():getUnits()


    for i,guard in ipairs(guards) do
       if guard:getBrain() and guard:getBrain():getSituation().ClassType == simdefs.SITUATION_IDLE then
            idle:generatePatrolPath( guard )
            if guard:getTraits().patrolPath and #guard:getTraits().patrolPath > 1 then
                local firstPoint = guard:getTraits().patrolPath[1]
                guard:getBrain():getSenses():addInterest(firstPoint.x, firstPoint.y, simdefs.SENSE_RADIO, simdefs.REASON_PATROLCHANGED, guard)
            end
        end
    end
    sim:processReactions()
end

local function chooseRandomLocations( count, sim )
    local tags = {}
    -- newLocation data is used in mission_complete, passing through to servers.createCampaignSituations
    local missionTags = util.tcopy( serverdefs.ESCAPE_MISSION_TAGS )

	if array.find( missionTags, "distress_call" ) then
		array.removeIf( missionTags, function(v) return v == "distress_call" end )
	end

	if count > #missionTags then
		repeat
			local missionTags2 = util.tcopy( serverdefs.ESCAPE_MISSION_TAGS )
			if array.find( missionTags2, "distress_call" ) then
				array.removeIf( missionTags2, function(v) return v == "distress_call" end )
			end
			util.tmerge(missionTags, missionTags2)
		until not (count > #missionTags)
	end

    for i = 1, count do
        local corpName = serverdefs.CORP_NAMES[ sim:nextRand( 1, #serverdefs.CORP_NAMES )]
        local missionTag = table.remove( missionTags, sim:nextRand( 1, #missionTags ))
        table.insert( tags, corpName )
        table.insert( tags, missionTag )
    end
    return tags
end

local function checkNewLocationItem_MM( script, sim ) --NEW VERSION OF HOOK FN
	local _, terminal = script:waitFor( LOOT_TERMINAL )
    terminal:destroyTab()

    local newLocations = nil
    if sim:getParams().missionCount > 0 then
        -- select ONE from a random choice of 4, and add TWO more random missions.
        -- local tags = chooseRandomLocations( 4, sim ) --THIS IS CHANGED
        local tags = chooseRandomLocations( 6, sim )
		local options = {}
        local corps = {}
        local names = {}
        for i = 1, #tags, 2 do
            local corpString = serverdefs.CORP_DATA[ tags[i] ].stringTable.SHORTNAME
            local missionString = serverdefs.SITUATIONS[ tags[i+1] ].ui.locationName
            table.insert( options, corpString .. " " .. missionString )
            table.insert( corps, tags[i] )
            table.insert( names, tags[i+1] )
        end
        local choice = mission_util.showExecDialog( sim, STRINGS.MISSIONS.ESCAPE.SITE_PLANS_HEADER, STRINGS.MISSIONS.ESCAPE.SITE_PLANS_BODY, options, corps, names )
        if choice == simdefs.CHOICE_ABORT then
            choice = sim:nextRand( 1, #options )
        end
        local newLocation = { mission_tags = { "escape", tags[2 * choice - 1], tags[ 2 * choice ] } }
        newLocations = { newLocation, {}, {} }
    else
        -- Just add FOUR random missions
        newLocations = { {}, {}, {}, {} }
    end

    for i, childUnit in ipairs( terminal:getChildren() ) do
        if childUnit:hasTag( SITE_PLANS_TAG ) then
            childUnit:getTraits().newLocations = newLocations
            break
        end
    end

	sim:setClimax(true)

    script:waitFor( mission_util.UI_LOOT_CLOSED )
    doAftermath(script, sim)
end

function mission_executive_terminals:init( scriptMgr, sim )
	init_old( self, scriptMgr, sim )
	if sim:getParams().difficultyOptions.MM_exec_terminals and (sim:getParams().difficultyOptions.MM_exec_terminals == true) then
		for i, hook in ipairs(scriptMgr.hooks) do
			if hook.name == "TERMINAL" then
				scriptMgr:removeHook( hook )
			end
		end
		scriptMgr:addHook( "TERMINAL", checkNewLocationItem_MM )
	end
end
