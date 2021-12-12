local hud = include( "hud/hud" )
-- MUCH THANKS TO WODZU FOR THIS CODE
local oldCreateHud = hud.createHud

hud.createHud = function( ... )
	local hudObject = oldCreateHud( ... )
	local oldOnSimEvent = hudObject.onSimEvent

	hudObject._name_dialog = SCRIPT_PATHS.name_dialog( hudObject._game )

	function hudObject:onSimEvent( ev )
		oldOnSimEvent( self, ev )

		if ev.eventType == "NameDialog" then
			return self._name_dialog:show()
		end
	end

    	return hudObject
end