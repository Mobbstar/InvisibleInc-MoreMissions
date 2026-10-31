-- hard mode: captain has improved heart monitor, notices when the doors open and locates the escapee every turn
local mission = include("sim/missions/mission_detention_centre")
local simdefs = include("sim/simdefs")
local mission_util = include("sim/missions/mission_util")

-- modified PC_USED_ABILITY from mission_util to return the unit using the ability and go after the ability
local CELLS_OPENED = {
	action = "abilityAction",
	priority = -10,
	fn = function(sim, ownerID, userID, abilityIdx, ...)
		local unit, ownerUnit = sim:getUnit(userID), sim:getUnit(ownerID)

		if not unit or not unit:isPC() or not ownerUnit then
			return nil
		end

		return ownerUnit:getAbilities()[abilityIdx]:getID() == "open_detention_cells", unit
	end,
}

local function findCaptain(sim)
	for _, unit in ipairs(sim:getNPC():getUnits()) do
		if unit:isValid() and unit:getUnitData().id == "important_guard" then
			local cell = sim:getCell(unit:getLocation())
			if cell and cell.procgenRoom.tags.detention then
				return unit
			end
		end
	end
end

local function findPrisoner(sim)
	for _, unit in ipairs(sim:getPC():getUnits()) do
		if unit:isValid() and unit:getTraits().rescued then
			return unit
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
		local captain = findCaptain(sim)
		if not captain then
			return
		end
		captain:getTraits().MM_huntsPrisoners = true
		captain:giveAbility("improved_heart_monitor_passive")
		captain:giveAbility("consciousness_monitor_passive")

		local _, _, target = script:waitFor(CELLS_OPENED)
		if captain:canAct() and captain:getLocation() and captain:isNPC() and captain:getBrain() then
			if captain:setAlerted(true) then
				captain:getTraits().trackerAlert = {
					1,
					STRINGS.MOREMISSIONS.MISSIONS.VANILLA_HARDMODE.DETENTION_CAPTAIN_ALARMED_FLYTXT,
					captain:getLocation(),
				}
			end
			local x, y = target:getLocation()
			if not x then
				x, y = captain:getLocation()
			end
			captain:getBrain():getSenses():addInterest(x, y, simdefs.SENSE_RADIO, simdefs.REASON_ALARMEDSAFE, target)
			sim:getNPC():processReactions(captain)
		end

		local prisoner = findPrisoner(sim)
		if prisoner then
			while true do
				script:waitFor(mission_util.PC_START_TURN)
				if
					captain:canAct()
					and captain:getBrain()
					and captain:getLocation()
					and captain:isNPC()
					and prisoner:isValid()
					and prisoner:getLocation()
					and prisoner:isPC()
					and not (prisoner:isDown() and prisoner:hasBeenInvestigated(captain))
				then
					--[[ sim:dispatchEvent(
						simdefs.EV_SHOW_DIALOG,
						{ dialog = "locationDetectedDialog", dialogParams = { prisoner } }
					) ]]
					local x, y = prisoner:getLocation()
					captain
						:getBrain()
						:getSenses()
						:addInterest(x, y, simdefs.SENSE_RADIO, simdefs.REASON_SCANNED, prisoner)
					sim:getNPC():processReactions(captain)
				end
			end
		end
	end)
end
