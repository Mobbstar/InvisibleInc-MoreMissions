-- hard mode: spread 2.0 daemons instead
---------------------------------------------------------------------------------------------------------------
local mission = include("sim/missions/mission_server_farm")
local simdefs = include("sim/simdefs")
local mission_util = include("sim/missions/mission_util")
local SCRIPTS = include("client/story_scripts")
local serverdefs = include("modules/serverdefs")
local cdefs = include("client_defs")
local util = include("modules/util")

-- copied
local USE_TERM = {
	action = "abilityAction",
	fn = function(sim, ownerID, userID, abilityIdx, ...)
		local unit, ownerUnit = sim:getUnit(userID), sim:getUnit(ownerID)

		if not unit or not unit:isPC() or not ownerUnit or not ownerUnit:getTraits().bigshopcat then
			return nil
		end

		if ownerUnit:getAbilities()[abilityIdx]:getID() == "showItemStore" then
			return ownerUnit
		end
	end,
}

local oldUseServerTerminal, idx, subFn = upvalueUtil.find(mission.init, "useServerTerminal", 5)
if idx then
	local function useServerTerminal(script, sim, mission, ...)
		if sim:getParams().difficultyOptions.MM_difficulty ~= "hard" or #serverdefs.ENDLESS_DAEMONS == 0 then
			return oldUseServerTerminal(script, sim, mission, ...)
		end

		local _, terminal = script:waitFor(USE_TERM)
		mission.used_terminal = true
		script:waitFor(mission_util.UI_SHOP_CLOSED)

		terminal:destroyTab()
		local possibleUnits = {}
		for _, unit in util.pairsByKeys(sim:getAllUnits()) do
			if
				unit:getTraits().mainframe_item
				and unit:getPlayerOwner() ~= sim:getPC()
				and not unit:getTraits().mainframe_program
				and unit:getTraits().mainframe_status ~= "off"
			then
				table.insert(possibleUnits, unit)
			end
		end
		if #possibleUnits > 0 then
			script:waitFrames(0.75 * cdefs.SECONDS)
			script:queue({
				type = "showIncognitaWarning",
				txt = STRINGS.UI.WARNING_NEW_DAEMON,
				vo = "SpySociety/VoiceOver/Incognita/Pickups/Warning_New_Daemon",
			})
			script:waitFrames(0.75 * cdefs.SECONDS)

			for k = 1, 3 do
				if #possibleUnits > 0 then
					local index = sim:nextRand(1, #possibleUnits)
					local unit = possibleUnits[index]
					table.remove(possibleUnits, index)

					-- new
					unit:getTraits().mainframe_program =
						serverdefs.ENDLESS_DAEMONS[sim:nextRand(#serverdefs.ENDLESS_DAEMONS)]
					unit:getTraits().daemon_sniffed = true

					local x, y = unit:getLocation()
					script:queue({ type = "pan", x = x, y = y })

					sim:getPC():glimpseUnit(sim, unit:getID())
					sim:dispatchEvent(simdefs.EV_UNIT_MAINFRAME_UPDATE, { units = { unit.unitID }, reveal = true })
					sim:dispatchEvent(
						simdefs.EV_UNIT_UPDATE_ICE,
						{ unit = unit, ice = unit:getTraits().mainframe_ice, delta = 0, refreshAll = true }
					)
					sim:dispatchEvent(simdefs.EV_MAINFRAME_INSTALL_NEW_DAEMON, { target = unit })
					sim:dispatchEvent(simdefs.EV_PLAY_SOUND, "SpySociety/Actions/mainframe_daemonmove")
					script:waitFrames(1.25 * cdefs.SECONDS)
				end
			end

			local x, y = terminal:getLocation()
			sim:dispatchEvent(simdefs.EV_SCRIPT_EXIT_MAINFRAME)
			script:queue({ type = "pan", x = x, y = y })
			script:waitFrames(1 * cdefs.SECONDS)
			script:queue({
				script = SCRIPTS.INGAME.AFTERMATH.SERVERFARM[sim:nextRand(1, #SCRIPTS.INGAME.AFTERMATH.SERVERFARM)],
				type = "newOperatorMessage",
			})

			script:queue(1 * cdefs.SECONDS)
			script:queue({
				script = SCRIPTS.INGAME.MONSTERCAT_POST[sim:nextRand(1, #SCRIPTS.INGAME.MONSTERCAT_POST)],
				type = "newOperatorMessage",
			})
		end
	end

	debug.setupvalue(subFn, idx, useServerTerminal)
end