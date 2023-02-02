local loot_panel = include( "hud/items_panel" ).loot

local baseRefreshItem = loot_panel.refreshItem

function loot_panel:refreshItem( widget, i )
	state = baseRefreshItem(self, widget, i)
	if not state and not self._panelOpened then
		if self._targetUnit:getTraits().stashable then
			state = true
		end
	end
	self._panelOpened = true
	return state
end
