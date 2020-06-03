local util = include( "modules/util" )

local function onMainframeTooltip( tooltip, unit )
	if unit:getTraits().MM_emp_safe then
		tooltip:addAbility( STRINGS.ITEMS.TOOLTIPS.EMP_SAFE, STRINGS.ITEMS.TOOLTIPS.EMP_SAFE_DESC, "gui/items/icon-action_open-safe.png" )
	end
end

local function onItemTooltip(tooltip, unit)
	if unit:getTraits().MM_tech_expo_item then
		tooltip:addAbility( STRINGS.MOREMISSIONS.UI.TOOLTIPS.WEAPONS_EXPO_RESALE, STRINGS.MOREMISSIONS.UI.TOOLTIPS.WEAPONS_EXPO_RESALE_DESC, "gui/icons/arrow_small.png" )
	end
end

return 
{
	onMainframeTooltip = onMainframeTooltip,
	onItemTooltip = onItemTooltip,
}