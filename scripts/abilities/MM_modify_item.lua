local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local speechdefs = include("sim/speechdefs")
local abilityutil = include( "sim/abilities/abilityutil" )
local simfactory = include( "sim/simfactory" )
local inventory = include("sim/inventory")
local unitdefs = include( "sim/unitdefs" )
local mission_util = include( "sim/missions/mission_util" )

local UPGRADE_OPTIONS =
{
	CANCEL = STRINGS.MOREMISSIONS.ABILITIES.UPGRADE_OPTIONS.CANCEL,
	COOLDOWN = STRINGS.MOREMISSIONS.ABILITIES.UPGRADE_OPTIONS.COOLDOWN,
	CHARGE = STRINGS.MOREMISSIONS.ABILITIES.UPGRADE_OPTIONS.CHARGE,
	AMMO = STRINGS.MOREMISSIONS.ABILITIES.UPGRADE_OPTIONS.AMMO,
	POWER = STRINGS.MOREMISSIONS.ABILITIES.UPGRADE_OPTIONS.POWER,
	SKILL_REQ = STRINGS.MOREMISSIONS.ABILITIES.UPGRADE_OPTIONS.SKILL_REQ,
	ARMOR_PIERCE = STRINGS.MOREMISSIONS.ABILITIES.UPGRADE_OPTIONS.ARMOR_PIERCE,
	DAMAGE = STRINGS.MOREMISSIONS.ABILITIES.UPGRADE_OPTIONS.DAMAGE,
}

local function showDialog( sim, headerTxt, bodyTxt, options, t, result )
	sim._choiceCount = sim._choiceCount + 1
	local choice = sim._choices[ sim._choiceCount ]
	options = options or { "OK" }

	if not choice then
		-- Choice has not yet been made.
		sim:dispatchChoiceEvent( "INC_EV_CHOICE_DIALOG", util.extend( { headerTxt = headerTxt, bodyTxt = bodyTxt, options = options }) ( t ), true )
		choice = sim._choices[ sim._choiceCount ]
	end

	return choice
end

local MM_modify_item =
{
	name = STRINGS.MOREMISSIONS.ABILITIES.MODIFY_ITEM,

	getName = function( self, sim, unit, userUnit )
		return self.name
	end,

	onTooltip = abilityutil.onAbilityTooltip,

	profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-action_augment.png",
	proxy = true,
	alwaysShow = true,
	ghostable = true,

	canUseAbility = function( self, sim, unit, userUnit )
			   
		if not simquery.canUnitReach( sim, userUnit, unit:getLocation() ) then
			return false
		end

		if userUnit:getTraits().isDrone then
			return false -- Drones have no hands to loot with
		end

		--check if an item was placed to modify
		if #unit:getChildren() <= 0 then
			return false
		end

		if unit:getTraits().mainframe_status == "off" then
			return false, STRINGS.UI.REASON.MACHINE_INACTIVE

		end

		if unit:getPlayerOwner() ~= userUnit:getPlayerOwner() and unit:getTraits().mainframe_status == "active" then 
			return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
		end

		if unit:getTraits().used then 
			return false, STRINGS.UI.REASON.MACHINE_USED
		end

		return true
	end,

	executeAbility = function ( self, sim, unit, userUnit)
		local itemUnit = unit:getChildren()[1]
		if itemUnit then
			local upgrade_option = {}
			table.insert(upgrade_option, UPGRADE_OPTIONS.CANCEL)
			local dialog_txt = util.sformat( STRINGS.MOREMISSIONS.ABILITIES.MOD_ITEM_DIALOG_TXT, itemUnit:getName() )
			
			local itemValue = itemUnit:getUnitData().value
			if not itemValue or itemUnit:getTraits().is_modified then
				--item not modifiable
				dialog_txt = dialog_txt .. STRINGS.MOREMISSIONS.ABILITIES.MOD_ITEM_DIALOG_UNMODABLE
			elseif math.floor(itemValue / 100) > (sim.MM_workshop_pwr or 0) then
				--not enough power
				dialog_txt = dialog_txt .. util.sformat( STRINGS.MOREMISSIONS.ABILITIES.MOD_ITEM_DIALOG_PWR, math.floor(itemValue / 100) )
			else
				if itemUnit:getTraits().cooldownMax and itemUnit:getTraits().cooldownMax > 1 then
					table.insert(upgrade_option, UPGRADE_OPTIONS.COOLDOWN)
				end
				if itemUnit:getTraits().chargesMax then
					table.insert(upgrade_option, UPGRADE_OPTIONS.CHARGE)
				end
				if itemUnit:getTraits().maxAmmo then
					table.insert(upgrade_option, UPGRADE_OPTIONS.AMMO)
				end
				if itemUnit:getTraits().pwrCost then
					table.insert(upgrade_option, UPGRADE_OPTIONS.POWER)
				end
				if itemUnit:getRequirements() then
					for _, _ in pairs( itemUnit:getRequirements() ) do
						table.insert(upgrade_option, UPGRADE_OPTIONS.SKILL_REQ)
						break
					end
				end
				if itemUnit:getTraits().armorPiercing or (itemUnit:getTraits().damage and itemUnit:getTraits().damage > 0) or (itemUnit:getTraits().baseDamage and itemUnit:getTraits().baseDamage > 0) then
					table.insert(upgrade_option, UPGRADE_OPTIONS.ARMOR_PIERCE)
				end
				if (itemUnit:getTraits().damage and itemUnit:getTraits().damage > 0) or (itemUnit:getTraits().baseDamage and itemUnit:getTraits().baseDamage > 0) then
					table.insert(upgrade_option, UPGRADE_OPTIONS.DAMAGE)
				end
			end
			
			if #upgrade_option > 0 then
				local option = showDialog( sim, STRINGS.MOREMISSIONS.ABILITIES.MOD_ITEM_DIALOG_TITLE, dialog_txt, upgrade_option )
				local modification_done = false
				if upgrade_option[option] == UPGRADE_OPTIONS.CANCEL then
					--do nothing
				elseif upgrade_option[option] == UPGRADE_OPTIONS.COOLDOWN then
					itemUnit:getTraits().MM_mod_cooldownMax = (itemUnit:getTraits().maa_mod_cooldownMax or 0) - 1
					itemUnit:getTraits().cooldownMax = itemUnit:getTraits().cooldownMax - 1
					itemUnit:getTraits().MM_modded_item_trait = UPGRADE_OPTIONS.COOLDOWN
					itemUnit:getTraits().is_modified = true
					modification_done = true
				elseif upgrade_option[option] == UPGRADE_OPTIONS.CHARGE then
					itemUnit:getTraits().MM_mod_chargesMax = (itemUnit:getTraits().maa_mod_chargesMax or 0) + 1
					itemUnit:getTraits().chargesMax = itemUnit:getTraits().chargesMax + 1
					itemUnit:getTraits().MM_modded_item_trait = UPGRADE_OPTIONS.CHARGE
					itemUnit:getTraits().is_modified = true
					modification_done = true
				elseif upgrade_option[option] == UPGRADE_OPTIONS.AMMO then
					itemUnit:getTraits().MM_mod_maxAmmo = (itemUnit:getTraits().maa_mod_maxAmmo or 0) + 1
					itemUnit:getTraits().maxAmmo = itemUnit:getTraits().maxAmmo + 1
					itemUnit:getTraits().ammo = (itemUnit:getTraits().ammo or 0) + 1
					itemUnit:getTraits().MM_modded_item_trait = UPGRADE_OPTIONS.AMMO
					itemUnit:getTraits().is_modified = true
					modification_done = true
				elseif upgrade_option[option] == UPGRADE_OPTIONS.POWER then
					itemUnit:getTraits().MM_mod_pwrCost = (itemUnit:getTraits().maa_mod_pwrCost or 0) - 1
					itemUnit:getTraits().pwrCost = itemUnit:getTraits().pwrCost - 1
					itemUnit:getTraits().MM_modded_item_trait = UPGRADE_OPTIONS.POWER
					itemUnit:getTraits().is_modified = true
					modification_done = true
				elseif upgrade_option[option] == UPGRADE_OPTIONS.SKILL_REQ then
					itemUnit:getTraits().MM_mod_requirements = true
					itemUnit._unitData.requirements = nil
					itemUnit:getTraits().MM_modded_item_trait = UPGRADE_OPTIONS.SKILL_REQ
					itemUnit:getTraits().is_modified = true
					modification_done = true
				elseif upgrade_option[option] == UPGRADE_OPTIONS.ARMOR_PIERCE then
					itemUnit:getTraits().MM_mod_armorPiercing = (itemUnit:getTraits().maa_mod_armorPiercing or 0) + 1
					itemUnit:getTraits().armorPiercing = (itemUnit:getTraits().armorPiercing or 0) + 1
					itemUnit:getTraits().MM_modded_item_trait = UPGRADE_OPTIONS.ARMOR_PIERCE
					itemUnit:getTraits().is_modified = true
					modification_done = true
				elseif upgrade_option[option] == UPGRADE_OPTIONS.DAMAGE then
					itemUnit:getTraits().MM_mod_damage = (itemUnit:getTraits().maa_mod_damage or 0) + 1
					if itemUnit:getTraits().damage and itemUnit:getTraits().stun then
						itemUnit:getTraits().stun = itemUnit:getTraits().stun + 1
					end
					if itemUnit:getTraits().damage then
						itemUnit:getTraits().damage = itemUnit:getTraits().damage + 1
					end
					if itemUnit:getTraits().baseDamage then
						itemUnit:getTraits().baseDamage = itemUnit:getTraits().baseDamage + 1
					end
					itemUnit:getTraits().MM_modded_item_trait = UPGRADE_OPTIONS.DAMAGE
					itemUnit:getTraits().is_modified = true
					modification_done = true
				end
				
				if modification_done then
					unit:getTraits().used = true
					sim:triggerEvent( "MM_workshop_used", {unit=unit, userUnit=userUnit} )
				end
			end
		end
	end,
}

return MM_modify_item
