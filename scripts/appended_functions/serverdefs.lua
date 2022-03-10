local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local function runAppend()
-- default weight for missions with no weight is 1, but the function doesn't accept weight less than 1. Set it to 100 instead so we can make missions both less frequent and more frequent than the vanilla unweighted ones without overriding the rest of the function.

local serverdefs_chooseSituation_old = serverdefs.chooseSituation
serverdefs.chooseSituation = function( campaign, tags, gen, ... )
	for name, situationData in pairs( serverdefs.SITUATIONS ) do
		if situationData.weight == nil then
			situationData.weight = 1
		end
		situationData.weight = situationData.weight * 100
	end
	return serverdefs_chooseSituation_old( campaign, tags, gen, ... )
end

--ASSASSINATION
-- SimConstructor resets serverdefs with every load, hence this function wrap only applies once despite being in mod-load. If SimConstructor ever changes, this must too.
local serverdefs_createNewSituation_old = serverdefs.createNewSituation
serverdefs.createNewSituation = function( campaign, gen, tags, difficulty )
	local newSituation =  serverdefs_createNewSituation_old(campaign, gen, tags, difficulty )

	if not newSituation and array.find(tags, "close_by") then
		-- Secure Holding Facility/Courier Rescue: if there was no viable location, lift the requirement for proximity.
		if not array.find(tags, "close_by_nevermind") then
			table.insert(tags, "close_by_nevermind")
			newSituation = serverdefs_createNewSituation_old( campaign, gen, tags, difficulty )
		end
		if not newSituation and not array.find(tags, "corp_nevermind") then
			-- Still no viable location. Allow any corp.
			-- (Presence of corp in the tags list is sufficient, no need to remove any existing corp tag)
			table.insert(tags, "corp_nevermind")
			array.concat(tags, serverdefs.CORP_NAMES)
			newSituation = serverdefs_createNewSituation_old( campaign, gen, tags, difficulty )
		end
		-- If there's still no new situation, then there are no valid spawns (possibly from 2x of all mission types in endless). Give up.
	end

	if newSituation then
		local corp = serverdefs.MAP_LOCATIONS[newSituation.mapLocation].corpName
		if campaign.MM_assassination and campaign.MM_assassination[corp] then
			-- Assassination: apply difficulty spike
			newSituation.difficulty = newSituation.difficulty + campaign.MM_assassination[corp]
		end
	end

	return newSituation
end

--SECURE HOLDING FACILITY/COURIER RESCUE
local serverdefs_defaultMapSelector_old = serverdefs.defaultMapSelector
serverdefs.defaultMapSelector = function( campaign, tags, tempLocation )
	if array.find(tags, "close_by") and not array.find(tags, "close_by_nevermind") then
		local MAX_DIST = 6 -- 6 hour distance
		local dist = serverdefs.trueCalculateTravelTime( serverdefs.MAP_LOCATIONS[ campaign.location ], tempLocation, campaign )
		-- log:write(tostring(dist))
		if dist > MAX_DIST then
			return false
		end
	end

	return serverdefs_defaultMapSelector_old( campaign, tags, tempLocation)

end

end

return { runAppend = runAppend }
