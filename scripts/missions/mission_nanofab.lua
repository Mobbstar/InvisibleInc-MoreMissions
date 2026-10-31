-- hard mode: increase rebooted devices from 3 to 5 and install rubiks after
---------------------------------------------------------------------------------------------------------------
local mission = include("sim/missions/mission_nanofab")
local simdefs = include("sim/simdefs")
local mission_util = include("sim/missions/mission_util")
local cdefs = include("client_defs")
local SCRIPTS = include("client/story_scripts")

local OBJECTIVE_ID = "nanofab"

local USE_NANOFAB = {
	trigger = simdefs.TRG_CLOSE_NANOFAB,
	fn = function(sim, triggerData)
		if triggerData.unit:getTraits().storeType == "large" then
			return triggerData.unit, triggerData.sourceUnit
		end
	end,
}

local function checkNanofab(script, sim, mission)
	local _, nano, agent = script:waitFor(USE_NANOFAB)
	mission.used_nano = true
	sim:removeObjective(OBJECTIVE_ID)
	sim.exit_warning = nil
	script:waitFor(mission_util.UI_SHOP_CLOSED)
	---------------------------------------------------------------------------------------------------------------
	-- calling mission_util.doRecapturePresentation without agent to do the rest manually
	-- it just looked super ugly to exit mainframe and then immediately enter again for the daemon, the voiceline was also overlapping
	local reboots = sim:getParams().difficultyOptions.MM_difficulty == "hard" and 5 or 3
	mission_util.doRecapturePresentation(script, sim, nano, nil, true, reboots) -- climax to true, unlike vanilla which never sets climax :(
	if sim:getParams().difficultyOptions.MM_difficulty == "hard" then
		sim:getNPC():addMainframeAbility(sim, "fortify", nil, 0)
		script:waitFrames(1 * cdefs.SECONDS)
	end
	sim:dispatchEvent(simdefs.EV_SCRIPT_EXIT_MAINFRAME)
	if agent then
		local x, y = agent:getLocation()
		script:queue({ type = "pan", x = x, y = y })
	end
	script:queue(0.5 * cdefs.SECONDS)
	script:queue({
		script = SCRIPTS.INGAME.AFTERMATH.CYBERNANO[sim:nextRand(#SCRIPTS.INGAME.AFTERMATH.CYBERNANO)],
		type = "newOperatorMessage",
	})
	---------------------------------------------------------------------------------------------------------------
end

-- replacing it here so we can fix the missing climax and have more control over the presentation
upvalueUtil.findAndReplace(mission.init, "checkNanofab", checkNanofab, 10)
