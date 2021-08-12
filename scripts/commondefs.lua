local util = include( "modules/util" )

local function onMainframeTooltip( tooltip, unit )
	if unit:getTraits().MM_emp_safe then
		tooltip:addAbility( STRINGS.ITEMS.TOOLTIPS.EMP_SAFE, STRINGS.ITEMS.TOOLTIPS.EMP_SAFE_DESC, "gui/items/icon-action_open-safe.png" )
	end
	if unit:getTraits().witness and unit:getTraits().mainframe_camera and not unit:isDead() then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.WITNESS, STRINGS.MOREMISSIONS.UI.TOOLTIPS.WITNESS_DESC_MAINFRAME, "gui/items/icon-action_peek.png" )
	end
	if unit:getTraits().MM_tech_expo_contents then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.WEAPONS_EXPO_LOOT_CONTENT, "\""..tostring(unit:getTraits().MM_tech_expo_contents).."\"",
		"gui/icons/item_icons/items_icon_small/icon_plaque.png" )
	end
	if unit:hasTag("MM_topGear") and unit:getSim() and not unit:getSim().MM_security_disabled then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.WEAPONS_EXPO_FAILSAFE, STRINGS.MOREMISSIONS.UI.TOOLTIPS.WEAPONS_EXPO_FAILSAFE_DESC, "gui/icons/item_icons/items_icon_small/icon-item_personal_shield_small.png")
	end
end

local function onItemTooltip(tooltip, unit)
	if unit:getTraits().MM_tech_expo_item then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.WEAPONS_EXPO_RESALE, STRINGS.MOREMISSIONS.UI.TOOLTIPS.WEAPONS_EXPO_RESALE_DESC, "gui/icons/arrow_small.png" )
	end
end

local function onAgentTooltip(tooltip, unit)
	if unit:getTraits().MM_hostage and unit:getTraits().vitalSigns then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.EA_HOSTAGE_FRAIL, STRINGS.MOREMISSIONS.UI.TOOLTIPS.EA_HOSTAGE_FRAIL_DESC, "gui/icons/item_icons/items_icon_small/icon-item_heart_monitor_small.png" )
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.EA_HOSTAGE_VITAL_STATUS, util.sformat(STRINGS.MOREMISSIONS.UI.TOOLTIPS.EA_HOSTAGE_VITAL_STATUS_DESC, unit:getTraits().vitalSigns), "gui/icons/item_icons/items_icon_small/icon-item_heart_monitor_small.png" )
	end
	local cell = unit:getSim():getCell( unit:getLocation() )
	if cell and cell.KOgas then
		if unit:isKO() then
			tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.KO_GAS_PINNED, STRINGS.MOREMISSIONS.UI.TOOLTIPS.KO_GAS_PINNED_DESC, "gui/icons/item_icons/items_icon_small/icon-item_toxic_smokel.png" )
		else
			tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.KO_GAS, STRINGS.MOREMISSIONS.UI.TOOLTIPS.KO_GAS_DESC, "gui/icons/item_icons/items_icon_small/icon-item_toxic_smokel.png" )
		end
	end
	if unit:getTraits().MM_mole then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.MOLE_CIVILIAN, STRINGS.MOREMISSIONS.UI.TOOLTIPS.MOLE_CIVILIAN_DESC, "gui/icons/thought_icons/status_run_lrg.png" )	
	end
end

local function onGuardTooltip(tooltip, unit)
	if unit:getTraits().witness then
		if unit:getTraits().isDrone then
			tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.WITNESS, STRINGS.MOREMISSIONS.UI.TOOLTIPS.WITNESS_DESC_DRONE, "gui/items/icon-action_peek.png" )
		else
			tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.WITNESS, STRINGS.MOREMISSIONS.UI.TOOLTIPS.WITNESS_DESC_HUMAN, "gui/items/icon-action_peek.png" )
		end
	end
	if unit:getTraits().mm_nopatrolchange then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.NO_PATROL_CHANGE, STRINGS.MOREMISSIONS.UI.TOOLTIPS.NO_PATROL_CHANGE_DESC, "gui/icons/arrow_small.png" )
	end
	if unit:getTraits().MM_amnesiac then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.NO_ALERT, STRINGS.MOREMISSIONS.UI.TOOLTIPS.NO_ALERT_DESC, "gui/icons/arrow_small.png" )	
	end
	if unit:getTraits().MM_bodyguard and not unit:getTraits().MM_alertlink then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.BODYGUARD_KEEPCLOSE, STRINGS.MOREMISSIONS.UI.TOOLTIPS.BODYGUARD_KEEPCLOSE_DESC, "gui/icons/skills_icons/skills_icon_small/icon-item_reflex_small.png" )
	end	
	if unit:getTraits().MM_bounty_target and not unit:getTraits().MM_ceo_armed then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.TARGET_PARANOID, STRINGS.MOREMISSIONS.UI.TOOLTIPS.TARGET_PARANOID_DESC, "gui/icons/action_icons/Action_icon_Small/icon-item_hide_small.png" )
	end
	if unit:getTraits().MM_alertlink then
		if unit:getTraits().MM_bodyguard then
			tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.BODYGUARD_ALERT, STRINGS.MOREMISSIONS.UI.TOOLTIPS.BODYGUARD_ALERT_DESC, "gui/icons/action_icons/Action_icon_Small/icon-action_augment.png" )
		end
		if unit:getTraits().MM_bounty_target then
			tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.TARGET_ALERT, STRINGS.MOREMISSIONS.UI.TOOLTIPS.TARGET_ALERT_DESC, "gui/icons/action_icons/Action_icon_Small/icon-action_augment.png" )
		end
	end
	if unit:getTraits().MM_bodyguard or unit:getTraits().MM_bounty_target or unit:getTraits().MM_decoy or unit:hasTag("MM_decoy_droid") then
		local desc = STRINGS.MOREMISSIONS.UI.TOOLTIPS.AUTHORIZED_BODY_DESC
		if unit:hasTag("MM_decoy_droid") then
			desc = STRINGS.MOREMISSIONS.UI.TOOLTIPS.AUTHORIZED_BODY_DESC2
		end
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.AUTHORIZED_BODY, desc, "gui/items/icon-action_open-safe.png" )
		-- icon-action_door-open
	end
	if unit:getTraits().MM_impairedVision then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.IMPAIRED_VISION, STRINGS.MOREMISSIONS.UI.TOOLTIPS.IMPAIRED_VISION_DESC, "gui/items/icon-action_peek.png" )
	end
	--sidemission
	if unit:getTraits().bossUnit then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.BOSSUNIT, STRINGS.MOREMISSIONS.UI.TOOLTIPS.BOSSUNIT_DESC,  "gui/icons/skills_icons/skills_icon_small/icon-item_accuracy_small.png" )
	end
end

return 
{
	onMainframeTooltip = onMainframeTooltip,
	onItemTooltip = onItemTooltip,
	onAgentTooltip = onAgentTooltip,
	onGuardTooltip = onGuardTooltip,
}
