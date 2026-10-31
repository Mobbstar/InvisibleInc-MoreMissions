-- hard mode:
-- Instead of 1 guard distraction: reboot power supply of the laser in front of the locker room, alert the next 2 guards to the position of the locker,
-- +1 Alarm (I think alerting guards should always increase alarm like in vanilla)
---------------------------------------------------------------------------------------------------------------
local mission = include("sim/missions/mission_security")
local simdefs = include("sim/simdefs")
local mission_util = include("sim/missions/mission_util")
local cdefs = include("client_defs")
local mainframe = include("sim/mainframe")
local util = include("client_util")
local simquery = include("sim/simquery")
local array = include("modules/array")

-- fetch grid ids for the laser grids that spawned in the security dispatch prefab
local function getLockerGridIDs(sim)
	local gridIDs = {}
	for _, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().mainframe_laser then
			local cell = sim:getCell(unit:getLocation())
			if cell and cell.procgenRoom.tags.guard_office then
				local gridID = unit:getTraits().powerGrid
				if gridID then
					gridIDs[gridID] = true
				end
			end
		end
	end
	return gridIDs
end

-- custom mission_util.doRecapturePresentation
local function doLaserRecapturePresentation(script, sim, agent)
	local possibleRebootUnits = {}

	local gridIDs = getLockerGridIDs(sim)
	for _, unit in ipairs(sim:getPC():getUnits()) do
		if unit:getTraits().laser_gen and gridIDs[unit:getTraits().powerGrid] and mainframe.canRevertIce(sim, unit) then
			table.insert(possibleRebootUnits, unit)
		end
	end

	if #possibleRebootUnits == 0 then
		return
	end

	for _, unit in ipairs(possibleRebootUnits) do
		local x, y = unit:getLocation()
		sim:dispatchEvent(simdefs.EV_CAM_PAN, { x, y })
		mainframe.revertIce(sim, unit)
		script:waitFrames(0.5 * cdefs.SECONDS)
	end
	sim:dispatchEvent(simdefs.EV_SCRIPT_EXIT_MAINFRAME)
	if agent then
		local x, y = agent:getLocation()
		script:queue({ type = "pan", x = x, y = y })
		script:waitFrames(1 * cdefs.SECONDS)
	end
end

local function angryGuards(script, sim, agent)
	if not agent or not agent:getLocation() then
		return
	end
	local x, y = agent:getLocation()

	local candidates = {}
	for _, unit in ipairs(sim:getNPC():getUnits()) do
		if unit:canAct() and unit:getBrain() and not unit:getTraits().pacifist then
			table.insert(candidates, unit)
		end
	end
	local alertedGuards = {}
	while #candidates > 0 and #alertedGuards < 2 do
		local unit = simquery.findClosestUnit(candidates, x, y)
		if not unit then
			break
		end
		array.removeElement(candidates, unit)
		local interest =
			unit:getBrain():getSenses():addInterest(x, y, simdefs.SENSE_RADIO, simdefs.REASON_ALARMEDSAFE, agent)
		if interest then
			interest.alerts = true
			interest.remember = true
			table.insert(alertedGuards, unit)
		end
	end
	for _, unit in ipairs(alertedGuards) do
		if unit:isValid() then
			sim:getPC():glimpseUnit(sim, unit:getID())
		end
		sim:getNPC():processReactions(unit)
	end
end

---------------------------------------------------------------------------------------------------------------

local init = mission.init
mission.init = function(self, scriptMgr, sim, ...)
	init(self, scriptMgr, sim, ...)
	if sim:getParams().difficultyOptions.MM_difficulty ~= "hard" then
		return
	end

	scriptMgr:addHook("MM_HARDMODE", function(script, sim)
		local _, _, agent = script:waitFor(mission_util.PC_TOOK_UNIT_WITH_TAG("topGearItem"))
		script:waitFor(util.extend(mission_util.UI_LOOT_CLOSED)({ priority = 10 }))
		script:waitFrames(0.5 * cdefs.SECONDS)
		doLaserRecapturePresentation(script, sim, agent)
		angryGuards(script, sim, agent)
		sim:trackerAdvance(1, STRINGS.MOREMISSIONS.MISSIONS.VANILLA_HARDMODE.SECURITY.PRESSURE_PLATE)
	end)
end
