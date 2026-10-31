-- hard mode: additional enforcer on using vault keycard, nearest enforcers will investigate when a container is looted
local mission = include("sim/missions/mission_vault")
local simdefs = include("sim/simdefs")
local cdefs = include("client_defs")
local mathutil = include("modules/mathutil")

local LOOT_SAFE = {
	action = "abilityAction",
	fn = function(sim, ownerID, userID, abilityIdx, ...)
		local unit, ownerUnit = sim:getUnit(userID), sim:getUnit(ownerID)

		if not unit or not unit:isPC() or not ownerUnit then
			return nil
		end
		if ownerUnit:getAbilities()[abilityIdx]:getID() == "stealCredits" then
			if ownerUnit:hasTag("vault") then
				return ownerUnit, unit
			end
		end
	end,
}

local PC_UNLOCK_DOOR = function()
	return {
		trigger = simdefs.TRG_UNLOCK_DOOR, -- it's only triggered for vault doors, despite the name
		fn = function(sim, evData)
			return evData.cell, evData.tocell, evData.unit
		end,
	}
end

---------------------------------------------------------------------------------------------------------------

local init = mission.init
mission.init = function(self, scriptMgr, sim, ...)
	init(self, scriptMgr, sim, ...)
	if sim:getParams().difficultyOptions.MM_difficulty ~= "hard" then
		return
	end

	-- nearest enforcer investigates for every looted vault container
	scriptMgr:addHook("MM_VAULT-LOOT", function(script, sim)
		while true do
			local _, _, unit = script:waitFor(LOOT_SAFE)
			if unit and unit:getLocation() then
				local ux, uy = unit:getLocation()
				local closestGuard, shortestDist
				for _, guard in ipairs(sim:getNPC():getUnits()) do
					if guard:getTraits().enforcer and guard:canAct() and guard:getLocation() and guard:getBrain() then
						local dist = mathutil.distSqr2d(ux, uy, guard:getLocation())
						if not shortestDist or dist < shortestDist then
							closestGuard, shortestDist = guard, dist
						end
					end
				end
				if closestGuard then
					-- I don't want to use brain:spawnInterest to avoid setting interest.remember which can cause him
					-- to keep two of these interests at once
					closestGuard
						:getBrain()
						:getSenses()
						:addInterest(ux, uy, simdefs.SENSE_RADIO, simdefs.REASON_ALARMEDSAFE, unit)
					sim:processReactions(closestGuard)
				end
			end
		end
	end)

	-- second enforcer spawns on opening the vault (NIAA lock decoder bypasses this - bug or feature?)
	scriptMgr:addHook("MM_VAULT-UNLOCK", function(script, sim)
		while true do
			local _, cell, toCell, unit = script:waitFor(PC_UNLOCK_DOOR())
			if cell.procgenRoom.tags.vault and toCell.procgenRoom.tags.vault then
				local newGuard = sim:getNPC():spawnGuards(sim, simdefs.TRACKER_SPAWN_UNIT_ENFORCER, 1)[1]
				if newGuard then
					local x, y
					if unit and unit:getLocation() then
						x, y = unit:getLocation()
					else
						x, y = cell.x, cell.y
					end
					script:queue({ type = "pan", x = x, y = y })
					script:waitFrames(0.25 * cdefs.SECONDS)
					sim:dispatchEvent(
						simdefs.EV_SHOW_DIALOG,
						{ dialog = "locationDetectedDialog", dialogParams = { unit } }
					)
					newGuard:getBrain():spawnInterest(x, y, simdefs.SENSE_RADIO, simdefs.REASON_ALARMEDSAFE, unit)
				end
				break
			end
		end
	end)
end
