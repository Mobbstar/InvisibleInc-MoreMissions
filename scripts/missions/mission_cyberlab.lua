-- hard mode: cyberlabs have guaranteed daemons + 3 devices are also rebooted on the secondcyberlab use
---------------------------------------------------------------------------------------------------------------
local mission = include("sim/missions/mission_cyberlab")
local simdefs = include("sim/simdefs")
local mission_util = include("sim/missions/mission_util")
local util = include("modules/util")

local USE_AUGMENT = {
	trigger = simdefs.TRG_CLOSE_AUGMENT_MACHINE,
	fn = function(sim, triggerData)
		return triggerData.unit, triggerData.user
	end,
}

local function installCyberlabDaemons(script, sim)
	local PROGRAM_LIST = sim:getIcePrograms()
	for _, unit in util.pairsByKeys(sim:getAllUnits()) do
		if unit and unit:hasTag("cyberlab") then
			local daemon = PROGRAM_LIST:getChoice(sim:nextRand(PROGRAM_LIST:getTotalWeight()))
			if not unit:getTraits().mainframe_program then
				unit:getTraits().mainframe_program = daemon
			else
				-- if cyberlab already has daemon, install on random device instead
				local candidates = {}
				for _, otherUnit in util.pairsByKeys(sim:getAllUnits()) do
					if
						otherUnit
						and otherUnit:getTraits().mainframe_item
						and not otherUnit:isPC()
						and not otherUnit:getTraits().mainframe_program
						and not otherUnit:getTraits().mainframe_camera
						and otherUnit:getTraits().mainframe_status ~= "off"
					then
						table.insert(candidates, otherUnit)
					end
				end
				if #candidates > 0 then
					candidates[sim:nextRand(#candidates)]:getTraits().mainframe_program = daemon
				end
			end
		end
	end
end

------------------------------------------------------------------------------------------------

local init = mission.init
mission.init = function(self, scriptMgr, sim, ...)
	init(self, scriptMgr, sim, ...)
	if sim:getParams().difficultyOptions.MM_difficulty ~= "hard" then
		return
	end

	scriptMgr:addHook("MM_HARDMODE", function(script, sim)
		installCyberlabDaemons(script, sim)
		script:waitFor(mission_util.PC_SAW_UNIT("cyberlab"))
		script:waitFor(USE_AUGMENT)
		local _, usedCyberLab, agent = script:waitFor(USE_AUGMENT)
		-- removed 4th argument to not play central message on repeat
		mission_util.doRecapturePresentation(script, sim, usedCyberLab, nil, true, 3)
		sim:dispatchEvent(simdefs.EV_SCRIPT_EXIT_MAINFRAME)
		if agent then
			local x, y = agent:getLocation()
			script:queue({ type = "pan", x = x, y = y })
		end
	end)
end
