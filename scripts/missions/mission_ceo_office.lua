-- hard mode:
-- 1 Guard elevator and the Enforcer spawn in the closest possible position to the CFO
-- Enforcer has +1 Armor
-- Removed fixed CFO KO duration
--------------------------------------------------------------------------------------------
local mission = include("sim/missions/mission_ceo_office")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local cdefs = include("client_defs")
local mission_util = include("sim/missions/mission_util")
local util = include("modules/util")
local mazegen = include("sim/mazegen")
local prefabs = include("sim/prefabs")
local unitdefs = include("sim/unitdefs")
local astar = include("modules/astar")
local astar_handlers = include("sim/astar_handlers")

local PC_KNOCKOUT_CEO = {
	trigger = simdefs.TRG_UNIT_KO,
	fn = function(sim, triggerData)
		if triggerData and (triggerData.ticks or 0) > 0 then
			if
				(not sim:isVersion("0.17.12") and triggerData.unit:getTraits().ko_trigger == "intimidate_guard")
				or triggerData.unit:getTraits().cfo
			then
				return triggerData.unit
			end
		end
	end,
}

------------------------------------------------------------------------------------------------

local oldcallReinforcement, idx, subFn = upvalueUtil.find(mission.init, "callReinforcement", 10)
if oldcallReinforcement then
	local function callReinforcement(script, sim, ...)
		if sim:getParams().difficultyOptions.MM_difficulty ~= "hard" then
			return oldcallReinforcement(script, sim, ...)
		end
		local target = simquery.findUnit(sim:getAllUnits(), function(u)
			return u:getTraits().cfo
		end)
		if not target or not target:getLocation() then
			return oldcallReinforcement(script, sim, ...)
		end
		local targetCell = sim:getCell(target:getLocation())

		local difficulty = sim:getParams().difficulty
		local template
		if difficulty >= 6 and unitdefs.lookupTemplate("ce_guard_enforcer_reinforcement_3") then
			template = "ce_guard_enforcer_reinforcement_3"
		elseif difficulty >= 3 then
			template = "npc_guard_enforcer_reinforcement_2"
		else
			template = "npc_guard_enforcer_reinforcement"
		end
		local unit = sim:getNPC():createGuard(sim, template)

		-- use default astar handler
		-- the aihandler uses canSoftPath which doesn't work with FL/CBF's version when the unit has no location
		local pather = astar.AStar:new(astar_handlers.handler:new(sim, unit, nil, nil, true, true))
		local closestCell, lowestCost
		for _, cell in ipairs(sim:getCells("guard_spawn")) do
			local cost = pather:findNodeCost(targetCell, cell, cell)
			if not closestCell or cost < lowestCost then
				closestCell, lowestCost = cell, cost
			end
		end
		local cell = assert(closestCell)

		sim:warpUnit(unit, cell)
		sim:getNPC():returnToIdleSituation(unit)
		sim:dispatchEvent(simdefs.EV_SHOW_DIALOG, { dialog = "threatDialog", dialogParams = { unit } })
		sim:dispatchEvent(simdefs.EV_UNIT_APPEARED, { unitID = unit:getID() })
		sim:dispatchEvent(simdefs.EV_TELEPORT, { units = { unit }, warpOut = false })
		sim:getPC():glimpseUnit(sim, unit:getID())
		-- add armor
		-- enforcer:buffArmor(sim, 1) -- no sound effect or flytxt :(
		script:waitFrames(0.25 * cdefs.SECONDS)
		sim:dispatchEvent(
			simdefs.EV_PLAY_SOUND,
			{ sound = "SpySociety_DLC001/Actions/Flackguard_ArmourIncrease", x = cell.x, y = cell.y }
		)
		unit:getTraits().armor = (unit:getTraits().armor or 0) + 1
		sim:dispatchEvent(simdefs.EV_UNIT_FLOAT_TXT, {
			txt = util.sformat(STRINGS.UI.FLY_TXT.ARMOR_UP, 1),
			x = cell.x,
			y = cell.y,
			color = { r = 1, g = 1, b = 41 / 255, a = 1 },
			alwaysShow = true,
		})
		sim:dispatchEvent(simdefs.EV_UNIT_ADD_FX, {
			unit = unit,
			kanim = "fx/firewall_buff_fx_2",
			symbol = "character",
			anim = "in",
			above = true,
			params = { color = { { symbol = "wall", r = 1, g = 1, b = 41 / 255, a = 1 } } },
		})
		-- glimpse again to update armor
		sim:getPC():glimpseUnit(sim, unit:getID())
		local tx, ty = target:getLocation()
		unit:getBrain():spawnInterest(tx, ty, simdefs.SENSE_RADIO, simdefs.REASON_REINFORCEMENTS, target)

		return true
	end
	debug.setupvalue(subFn, idx, callReinforcement)
end

local init = mission.init
mission.init = function(self, scriptMgr, sim, ...)
	init(self, scriptMgr, sim, ...)
	if sim:getParams().difficultyOptions.MM_difficulty ~= "hard" then
		return
	end

	-- the vanilla function also simply overrides the koTimer trait with the same triggers, so this shouldn't be any different

	-- add 2 hooks with the exact same triggers but with priorities so one goes before and the other after: we save koTimer first,
	-- then mission script sets it to 6, then we set it back to the saved koTimer right after
	scriptMgr:addHook("MM_HARDMODE_RESET_KO_PRE", function(script, sim)
		local _, ceo = script:waitFor(util.extend(mission_util.PC_SAW_UNIT("interrogate"))({ priority = 10 }))
		if not ceo:isKO() then
			script:waitFor(util.extend(PC_KNOCKOUT_CEO)({ priority = 10 }))
		end

		ceo:getTraits().MM_oldCeoKoTimer = ceo:getTraits().koTimer
	end)

	scriptMgr:addHook("MM_HARDMODE_RESET_KO_POST", function(script, sim)
		local _, ceo = script:waitFor(util.extend(mission_util.PC_SAW_UNIT("interrogate"))({ priority = -10 }))
		if not ceo:isKO() then
			script:waitFor(util.extend(PC_KNOCKOUT_CEO)({ priority = -10 }))
		end

		if ceo:getTraits().koTimer and ceo:getTraits().MM_oldCeoKoTimer then
			ceo:getTraits().koTimer = ceo:getTraits().MM_oldCeoKoTimer
			ceo:getTraits().MM_oldCeoKoTimer = nil
		end
	end)
end

local generatePrefabs = mission.generatePrefabs
mission.generatePrefabs = function(cxt, candidates, ...)
	if cxt.params.difficultyOptions.MM_difficulty ~= "hard" then
		return generatePrefabs(cxt, candidates, ...)
	end

	local objRoom
	for _, room in ipairs(cxt.rooms) do
		if room.tags.ceo_office then
			objRoom = room
			break
		end
	end
	if not objRoom then
		return generatePrefabs(cxt, candidates, ...)
	end

	local depths = {}
	mazegen.breadthFirstSearch(cxt, objRoom, function(room)
		depths[room.roomIndex] = room.depth
	end)

	local function guardEntranceFitness(cxt, prefab, x, y)
		local adjX, adjY = x + 1, y + 1 -- need to adjust for the prefab anchor of the guard entry being outside of it

		local startRoom = cxt:roomContaining(adjX, adjY)
		if not startRoom or not depths[startRoom.roomIndex] then
			return 0
		end

		-- weighted_list expects integers
		local fitness = math.floor(1 / (1 + depths[startRoom.roomIndex]) * 1000 + 0.5)
		--[[ simlog(
			"LOG_MM",
			"guardEntranceFitness (BFS): at (%d,%d): minDepth=%d, fitness=%.3f",
			adjX,
			adjY,
			depths[startRoom.roomIndex],
			fitness
		) ]]
		return fitness
	end

	cxt.MM_checkAllPieces = cxt.MM_checkAllPieces or {}
	cxt.MM_checkAllPieces.entry_guard = true
	cxt.MM_spawnedGuardEntries = (cxt.MM_spawnedGuardEntries or 0)
		+ prefabs.generatePrefabs(cxt, candidates, "entry_guard", 1, guardEntranceFitness, prefabs.SELECT_HIGHEST)
	cxt.MM_checkAllPieces.entry_guard = nil
	generatePrefabs(cxt, candidates, ...)
end
