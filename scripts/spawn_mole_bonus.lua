local util = include( "modules/util" )
local simdefs = include( "sim/simdefs" )
local simquery = include ( "sim/simquery" )
local cdefs = include( "client_defs" )


local PATROLS_REVEALED = 0.75
local bonus_types = {
	[1] = "patrols",
	[2] = "safes_consoles",
	[3] = "cameras_turrets",
	[4] = "daemons_layout",
	[5] = "doors",
}

local function isTurretGenerator( sim, u )
	if not u:getTraits().powerGrid then
		return false
	else
		local powerGrid = u:getTraits().powerGrid
		for unitID, unit in pairs( sim:getAllUnits() ) do
			if unit ~= u and unit:getTraits().mainframe_turret and unit:getTraits().powerGrid == powerGrid and unit:getLocation() then
				return true
			end
		end
	end

	return false
end

local revealMoleBonus = function(sim, bonusType) --need to call on this from modinit
	local unitlist = {} --collect units to be revealed for relevant bonuses
	local randomAgent = sim:getPC():getUnits()[sim:nextRand(1,#sim:getPC():getUnits())] --it's turn 1 so just pick any agent so we have somewhere to display the float text
	local x0, y0 = randomAgent:getLocation()
	local currentPlayer = sim:getPC()
	local script = sim:getLevelScript()

	if bonusType == "patrols" then
		local total_guards = 0
		for _, unit in pairs(sim:getAllUnits() ) do
			if (unit:getPlayerOwner() ~= currentPlayer) and unit:getTraits().isGuard then
				total_guards = total_guards + 1
			end
		end
		local to_tag = math.floor(PATROLS_REVEALED * total_guards)
		local tagged_guards = 0
		for _, unit in pairs( sim:getAllUnits() ) do
			-- if sim:nextRand() <= (PATROLS_REVEALED or 0.75) then --don't tag all the guards, just most of them
			if tagged_guards < to_tag then
				if unit:getPlayerOwner() ~= currentPlayer and unit:getTraits().isGuard and not unit:getTraits().tagged then
					unit:setTagged() -- need to consider PE's hostile AI interaction..
					sim:dispatchEvent( simdefs.EV_UNIT_TAGGED, {unit = unit} )
					sim:getPC():glimpseUnit(sim, unit:getID())
					tagged_guards = tagged_guards + 1
					-- tag + glimpse may be OP... maybe just tag... keep uncertainty about which guards are on the level...
				end
			end
		end
		sim.MM_mole_bonus_tag = tagged_guards
	elseif bonusType == "safes_consoles" then
		sim:forEachUnit(
			function ( u )
				if u:getTraits().mainframe_console ~= nil then
					table.insert(unitlist,u:getID())
					currentPlayer:glimpseUnit( sim, u:getID() )
				end
				if u:getTraits().safeUnit ~= nil then
					table.insert(unitlist,u:getID())
					currentPlayer:glimpseUnit( sim, u:getID() )
				end --reveal one, then the other
			end )
	elseif bonusType == "cameras_turrets" then --also turrets
		sim:forEachUnit(
			function ( u )
				if (u:getTraits().mainframe_camera ~= nil) or (u:getTraits().mainframe_turret ~= nil) or isTurretGenerator(sim, u) then
					table.insert(unitlist,u:getID())
					currentPlayer:glimpseUnit( sim, u:getID() )
				end
			end )
	elseif bonusType == "daemons_layout" then
		sim:forEachUnit(
			function ( u )
				if u:getTraits().mainframe_program ~= nil then
					u:getTraits().daemon_sniffed = true
				end
			end )
		sim._showOutline = true
		sim:dispatchEvent( simdefs.EV_WALL_REFRESH )
		if x0 and y0 then
			local color = {r=1,g=1,b=41/255,a=1}
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.UI.FLY_TXT.FACILITY_REVEALED,x=x0,y=y0,color=color,alwaysShow=true} )
		end
	elseif bonusType == "doors" then
		sim:forEachCell(
			function ( cell )
				for dir, exit in pairs( cell.exits ) do
					if (simquery.isDoorExit(exit)) then
						sim:getPC():glimpseCell(sim, cell)
					end
				end
			end )
		if x0 and y0 then
			local color = {r=1,g=1,b=41/255,a=1}
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.MOREMISSIONS.UI.DOORS_REVEALED,x=x0,y=y0,color=color,alwaysShow=true} )
		end
		sim:dispatchEvent( simdefs.EV_WALL_REFRESH )
	elseif bonusType == "armor" then
		sim:getNPC():getTraits().boostArmor = (sim:getNPC():getTraits().boostArmor or 0) - 1
	end
	if #unitlist > 0 then --for any bonuses that reveal units
		sim:dispatchEvent( simdefs.EV_UNIT_MAINFRAME_UPDATE, {units=unitlist,reveal = true} )
	end
end

local function spawnBonusFromSelection(sim, possible_bonuses, agency_bonus)
	sim:getLevelScript():queue( 1.5*cdefs.SECONDS )
	-- log:write("[MM] possible bonus")
	-- log:write(util.stringize(possible_bonuses,2))

	local missionsLeft = agency_bonus.missions_left - 1 --this tickdown is only for UI event purposes; for seed preservation reasons, wait until end of mission to actually update the ticker
	local randBonus = sim:nextRand(1,#possible_bonuses)
	-- log:write("[MM] randBonus is"..tostring(randBonus))
	local bonus_type = possible_bonuses[randBonus]
	if not agency_bonus.bonus then
		table.remove(possible_bonuses, randBonus) --don't spawn the same one
	else
		bonus_type = agency_bonus.bonus
	end
	revealMoleBonus(sim, bonus_type) -- dispatch bonus
	--handle UI event
	local mole_head = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.MOLE_DAEMON_HEAD
	local mole_title = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.MOLE_DAEMON_TITLE
	local mole_text = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.MOLE_DAEMON_TXT .. STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.INTEL_TYPES[bonus_type]
	local mole_icon_path = "gui/icons/UI_icons/icon_moleBonus.png"

	if bonus_type == "armor" then
		mole_head = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.ARMOR_DAEMON_HEAD
		mole_title = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.ARMOR_DAEMON_TITLE
		mole_text = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.ARMOR_DAEMON_TXT
		mole_icon_path = "gui/icons/UI_icons/icon_armorDebuff_v2.png"
	end

	local dialogParams =
	{
		mole_head,
		mole_title,
		mole_text,
		mole_icon_path,
		color = {r=0,g=0,b=1,a=1}
	}

	sim:dispatchEvent( simdefs.EV_SHOW_DIALOG, { dialog = "programDialog", dialogParams = dialogParams } )
	sim:getNPC():addMainframeAbility( sim, "MM_informant_intel", nil, 0 )
	-- now modify the newly-spawned daemon with customised text info
	for i,ability in pairs( sim:getNPC():getAbilities() ) do
		if (ability._abilityID == "MM_informant_intel") and not ability.MM_mole_checked then
			-- log:write("[MM] editing bonus desc")
			ability.MM_mole_checked = true
			ability.missionsLeft = missionsLeft
			ability.bonus_type = bonus_type
			if agency_bonus.bonus and agency_bonus.bonus == "armor" then
				ability.icon = "gui/icons/UI_icons/icon_armorDebuff_daemon.png"
				ability.name = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON.NAME_ARMOR
			end
		end
	end
end

local function spawnMoleBonus( sim, mole_insertion )
	-- log:write(util.stringize(sim:getParams().agency.MM_informant_bonus,2))
	local MM_informant_bonus = sim:getParams().agency.MM_informant_bonus
	if not MM_informant_bonus or (#MM_informant_bonus <= 0) then
		return
	end
	local possible_bonuses = util.tcopy(bonus_types)
	for k,v in pairs(MM_informant_bonus) do
		if #possible_bonuses > 0 then
			spawnBonusFromSelection(sim, possible_bonuses, v)
		end
	end
end

return spawnMoleBonus
