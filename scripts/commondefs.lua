local util = include( "modules/util" )

local function onMainframeTooltip( tooltip, unit )
	if unit:getTraits().MM_emp_safe then
		tooltip:addAbility( STRINGS.ITEMS.TOOLTIPS.EMP_SAFE, STRINGS.ITEMS.TOOLTIPS.EMP_SAFE_DESC, "gui/items/icon-action_open-safe.png" )
	end
	if unit:getTraits().witness and unit:getTraits().mainframe_camera then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.WITNESS, STRINGS.MOREMISSIONS.UI.TOOLTIPS.WITNESS_DESC_MAINFRAME, "gui/items/icon-action_peek.png" )
	end
	if unit:getTraits().MM_tech_expo_contents then
		--you're gonna have to pick one, guys
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.WEAPONS_EXPO_LOOT_CONTENT, "\""..tostring(unit:getTraits().MM_tech_expo_contents).."\"",
		"gui/icons/item_icons/items_icon_small/icon_plaque.png" )
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.WEAPONS_EXPO_LOOT_CONTENT, "\""..tostring(unit:getTraits().MM_tech_expo_contents).."\"",
		"gui/icons/item_icons/items_icon_small/icon_plaque_v2.png" )		
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.WEAPONS_EXPO_LOOT_CONTENT, "\""..tostring(unit:getTraits().MM_tech_expo_contents).."\"",
		"gui/icons/item_icons/items_icon_small/icon_plaque_v3.png" )			
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
end

return 
{
	onMainframeTooltip = onMainframeTooltip,
	onItemTooltip = onItemTooltip,
	onAgentTooltip = onAgentTooltip,
	onGuardTooltip = onGuardTooltip,
}
