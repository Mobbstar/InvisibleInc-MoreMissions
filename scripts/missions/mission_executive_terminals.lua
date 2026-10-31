-- hard mode: aftermath: install labyrinth and longer patrol paths
local array = include("modules/array")
local util = include("modules/util")
local simdefs = include("sim/simdefs")
local mission_util = include("sim/missions/mission_util")
local serverdefs = include("modules/serverdefs")
local cdefs = include("client_defs")

local SCRIPTS = include("client/story_scripts")
local mission = include("sim/missions/mission_executive_terminals")

---------------------------------------------------------------------------------------------
-- Local helpers

local SITE_PLANS_TAG = "corp_map"

local LOOT_TERMINAL = {
	action = "abilityAction",
	pre = true,
	fn = function(sim, ownerID, userID, abilityIdx, ...)
		local unit, ownerUnit = sim:getUnit(userID), sim:getUnit(ownerID)
		if not unit or not unit:isPC() or not ownerUnit or not ownerUnit:getTraits().public_term then
			return nil
		end

		if ownerUnit:getAbilities()[abilityIdx]:getID() == "stealCredits" then
			return ownerUnit
		end
	end,
}

local function doAftermath(script, sim)
	if sim:getParams().difficultyOptions.MM_difficulty == "hard" then
		script:waitFrames(0.25 * cdefs.SECONDS)
		sim:getNPC():addMainframeAbility(sim, "agent_sapper", nil, 0)
	end
	script:queue(1 * cdefs.SECONDS)
	script:queue({
		script = SCRIPTS.INGAME.AFTERMATH.TERMS[sim:nextRand(1, #SCRIPTS.INGAME.AFTERMATH.TERMS)],
		type = "newOperatorMessage",
	})

	--shift guard patrols
	local idle = sim:getNPC():getIdleSituation()
	local guards = sim:getNPC():getUnits()

	for i, guard in ipairs(guards) do
		if guard:getBrain() and guard:getBrain():getSituation().ClassType == simdefs.SITUATION_IDLE then
			local oldMP
			if sim:getParams().difficultyOptions.MM_difficulty == "hard" then
				-- comment below is copied from vanilla, don't blame me
				
				-- つ ◕_◕ ༽つ give patrol path つ ◕_◕ ༽つ
				-- Hacky, but increase guard AP to make the path longer and then remove the extra AP.
				oldMP = guard:getTraits().mpMax
				if oldMP then
					guard:getTraits().mpMax = math.floor(guard:getTraits().mpMax * 1.9)
				end
			end
			idle:generatePatrolPath(guard)
			if oldMP then
				guard:getTraits().mpMax = oldMP
			end
			if guard:getTraits().patrolPath and #guard:getTraits().patrolPath > 1 then
				local firstPoint = guard:getTraits().patrolPath[1]
				guard
					:getBrain()
					:getSenses()
					:addInterest(firstPoint.x, firstPoint.y, simdefs.SENSE_RADIO, simdefs.REASON_PATROLCHANGED, guard)
			end
		end
	end
	sim:processReactions()
end

local function chooseRandomLocations(count, sim)
	local tags = {}
	-- newLocation data is used in mission_complete, passing through to servers.createCampaignSituations
	local missionTags = util.tcopy(serverdefs.ESCAPE_MISSION_TAGS)

	if array.find(missionTags, "distress_call") then
		array.removeIf(missionTags, function(v)
			return v == "distress_call"
		end)
	end

	if count > #missionTags then
		repeat
			local missionTags2 = util.tcopy(serverdefs.ESCAPE_MISSION_TAGS)
			if array.find(missionTags2, "distress_call") then
				array.removeIf(missionTags2, function(v)
					return v == "distress_call"
				end)
			end
			util.tmerge(missionTags, missionTags2)
		until not (count > #missionTags)
	end

	for i = 1, count do
		local corpName = serverdefs.CORP_NAMES[sim:nextRand(1, #serverdefs.CORP_NAMES)]
		local missionTag = table.remove(missionTags, sim:nextRand(1, #missionTags))
		table.insert(tags, corpName)
		table.insert(tags, missionTag)
	end
	return tags
end

local function checkNewLocationItem(script, sim) --NEW VERSION OF HOOK FN
	local _, terminal = script:waitFor(LOOT_TERMINAL)
	terminal:destroyTab()

	local newLocations = nil
	if sim:getParams().missionCount > 0 then
		-- select ONE from a random choice of 4, and add TWO more random missions.
		-- local tags = chooseRandomLocations( 4, sim ) --THIS IS CHANGED
		local count = sim:getParams().difficultyOptions.MM_exec_terminals == true and 6 or 4
		local tags = chooseRandomLocations(count, sim)
		local options = {}
		local corps = {}
		local names = {}
		for i = 1, #tags, 2 do
			local corpString = serverdefs.CORP_DATA[tags[i]].stringTable.SHORTNAME
			local missionString = serverdefs.SITUATIONS[tags[i + 1]].ui.locationName
			table.insert(options, corpString .. " " .. missionString)
			table.insert(corps, tags[i])
			table.insert(names, tags[i + 1])
		end
		local choice = mission_util.showExecDialog(
			sim,
			STRINGS.MISSIONS.ESCAPE.SITE_PLANS_HEADER,
			STRINGS.MISSIONS.ESCAPE.SITE_PLANS_BODY,
			options,
			corps,
			names
		)
		if choice == simdefs.CHOICE_ABORT then
			choice = sim:nextRand(1, #options)
		end
		local newLocation = { mission_tags = { "escape", tags[2 * choice - 1], tags[2 * choice] } }
		newLocations = { newLocation, {}, {} }
	else
		-- Just add FOUR random missions
		newLocations = { {}, {}, {}, {} }
	end

	for i, childUnit in ipairs(terminal:getChildren()) do
		if childUnit:hasTag(SITE_PLANS_TAG) then
			childUnit:getTraits().newLocations = newLocations
			break
		end
	end

	sim:setClimax(true)

	script:waitFor(mission_util.UI_LOOT_CLOSED)
	doAftermath(script, sim)
end

upvalueUtil.findAndReplace(mission.init, "checkNewLocationItem", checkNewLocationItem, 10)
