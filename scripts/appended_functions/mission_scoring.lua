local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local function runAppend( modApi )
	local scriptPath = modApi:getScriptPath()
	local mole_insertion = include( scriptPath .. "/missions/mole_insertion" ) -- included in init so function appends can already reference it

	local mission_scoring = include("mission_scoring")
	local DoFinishMission_old = mission_scoring.DoFinishMission
	mission_scoring.DoFinishMission = function( sim, campaign, ... )
		local agency = sim:getParams().agency

		--update existing informant bonuses
		-- bonus doesn't apply in Omni missions so don't tick down
		-- don't use up bonus if PC lost > might still Retry level
		if (sim:getWinner() and sim:getPlayers()[sim:getWinner()]:isPC()) and (not ((sim:getParams().world == "omni") or (sim:getParams().world == "omni2"))) then
			agency.MM_informant_bonus = agency.MM_informant_bonus or {}
			-- tick duration on existing mole bonuses
			for i=#agency.MM_informant_bonus, 1, -1 do --do not modify agency during serialisation, doFinishMission is fine because no more serialisable player actions are possible
				local mole_bonus = agency.MM_informant_bonus[i]
				log:write("LOG DoFinishMission mole bonus")
				log:write(util.stringize(mole_bonus,2))
				if mole_bonus.missions_left then
					if mole_bonus.missions_left then
						log:write("LOG ticking down missions_left")
						mole_bonus.missions_left = mole_bonus.missions_left - 1
					end
					if mole_bonus.missions_left <= 0 then
						log:write("LOG removing bonus")
						table.remove(agency.MM_informant_bonus, i)
					end
				end
			end
		end

		-- remove existing Distress Call missions, THEN run the old function that might add new ones.
		for i = #campaign.situations, 1, -1 do
			local situation = campaign.situations[i]
			if situation.name == "distress_call" then
				table.remove( campaign.situations, i )
			end
		end

		-- add new bonus from mission just completed, if relevant
		if sim:getTags().MM_informantMission and sim:getTags().MM_informant_success then
			local missions_left = sim.MM_mole_duration_full or 3	-- maybe make customisable?
			if mole_insertion.existsLivingWitness(sim) then
				missions_left = sim.MM_mole_duration_partial or 1
			end
			local id = sim:getParams().campaignHours
			local intel_bonus = {
				id = id,
				missions_left = missions_left,
			}
			-- add new mole bonus
			table.insert(agency.MM_informant_bonus, intel_bonus)
		end

		-- ASSASSINATION
		if (sim:getParams().situationName == "assassination") and sim:getTags().MM_assassination_success then -- or some other mission type check, as well as a mission success check

			-- this is for modifying the difficulty of newly-spawned ones, in case we also want this
			campaign.MM_assassination  = campaign.MM_assassination or {}
			local world = sim:getParams().world
			if campaign.MM_assassination[world] == nil then
				campaign.MM_assassination[world] = 0
			end

			campaign.MM_assassination[world] = campaign.MM_assassination[world] + 1

			-- this is for modifying the difficulty of existing ones
			local situations = campaign.situations

			for i, sitch in pairs(situations) do
				local corpData = serverdefs.getCorpData( sitch )
				if corpData.world == sim:getParams().world then
					-- if sitch.difficulty > 1 then
						sitch.difficulty = sitch.difficulty + 1
					-- end
				end
			end
		end

		local returnvalue = DoFinishMission_old( sim, campaign, ... )

		if sim._assassinationReward then
			-- if sim._resultTable.credits_gained.hostage then
				-- sim._resultTable.credits_gained.hostage = sim._resultTable.credits_gained.hostage - sim._assassinationReward
			-- end
			sim._resultTable.credits_gained.assassinationreward = sim._assassinationReward
		end

		return returnvalue
	end
	
end

return { runAppend = runAppend }