local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

-- === earlyLoad ===
local function earlyLoad()

	-- If Distress Call doesn't contain an agent, the loot is a vault passcard and one of these, instead.
	-- * 300-600cr, other than the non-purchaseable prototype drive
	-- * mean=420
	local MM_DISTRESS_CALL_ITEMS_DEFAULT = {
		                          -- (floor weight, purchase value)
		"item_light_pistol",      -- 0, 300
		"item_crybaby",           -- 2, 300
		"item_stickycam",         -- 2, 300
		"item_smokegrenade",      -- 2, 300
		"item_tag_pistol",        -- 0, 300 (higher perceived value)
		"MM_item_corpIntel",      -- reward = 300*scaling
		"item_shocktrap",         -- 1, 400
		"item_stim",              -- 1, 400
		"item_cloakingrig_1",     -- 1, 400
		"item_lockdecoder",       -- 1, 400
		"item_icebreaker_2",      -- 2, 400
		"item_emp_pack",          -- 1, 500
		"item_paralyzer_2",       -- 2, 500
		"item_portabledrive_2",   -- 2, 500
		"item_hologrenade_17_9",  -- 2, 600
		"item_wireless_scanner_1",-- 3, 600 (not purchaseable)
		"item_prototype_drive",   -- 3, 700 (not purchaseable)
	}

	serverdefs.MM_DISTRESS_CALL_ITEMS = {}

	local function ResetMMDistressCallItems()
		log:write("ResetMMDistressCallItems()")
		util.tclear(serverdefs.MM_DISTRESS_CALL_ITEMS)
		util.tmerge(serverdefs.MM_DISTRESS_CALL_ITEMS, MM_DISTRESS_CALL_ITEMS_DEFAULT)
	end

	ResetMMDistressCallItems()
end
-- === END earlyLoad ===


-- === lateLoad ===
local function lateLoad( mod_options )

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

--DISTRESS CALL
-- Check for item mods that add items in the right value range for non-agent Distress Call loot.
local niaa = mod_manager.findModByName and mod_manager:findModByName( "New Items And Augments" )
if niaa and mod_options[niaa.id] and mod_options[niaa.id].enabled then
	local niaaOptions = mod_options[niaa.id].options
	if niaaOptions["enable_items"] and niaaOptions["enable_items"].enabled then
		table.insert(serverdefs.MM_DISTRESS_CALL_ITEMS, "W93_item_door_controller") -- 2, 400
	end
	if niaaOptions["enable_weapons"] and niaaOptions["enable_weapons"].enabled then
		table.insert(serverdefs.MM_DISTRESS_CALL_ITEMS, "W93_weapon_emp_pistol") -- 0, 450
	end
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
-- === END lateLoad ===

return {
	earlyLoad = earlyLoad,
	lateLoad = lateLoad,
}
