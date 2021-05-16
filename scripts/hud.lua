local mui = include( "mui/mui" )
local modalDialog = include( "states/state-modal-dialog" )
local util = include( "modules/util" )

-- FROM INTERACTIVE EVENTS BY CYBERBOY2000

local function showChoiceDialog( hud, headerTxt, bodyTxt, options, dType, tooltips, playerCredits, enemyProfile )
	assert( hud._choice_dialog == nil )

	local screen

	screen = mui.createScreen( "modal-event.lua" )
	
	hud._choice_dialog = screen
	mui.activateScreen( screen )

	screen.binder.pnl.binder.headerTxt:setText( headerTxt )
	screen.binder.pnl.binder.bodyTxt:setText("<c:8CFFFF>".. bodyTxt.."</>" )

	--selected agent
	local unit = hud:getSelectedUnit()
	if unit ~= nil and unit.getUnitData then
		screen.binder.pnl.binder.yourface.binder.portrait:bindBuild( unit:getUnitData().profile_build or unit:getUnitData().profile_anim )
		screen.binder.pnl.binder.yourface.binder.portrait:bindAnim( unit:getUnitData().profile_anim )
		screen.binder.pnl.binder.yourface:setVisible(true)
	else
		screen.binder.pnl.binder.yourface:setVisible(false)
	end
	
	screen.binder.pnl.binder.Item:setVisible(false)

	if enemyProfile == true then
		screen.binder.pnl.binder.theirface.binder.portrait:bindBuild( "portraits/portrait_security_build" )
		screen.binder.pnl.binder.theirface.binder.portrait:bindAnim( "portraits/portrait_animation_template" )
		screen.binder.pnl.binder.theirface.binder.portrait:setColor(0,0,0,1)
		screen.binder.pnl.binder.theirface:setVisible(true)
	elseif enemyProfile then
		screen.binder.pnl.binder.theirface.binder.portrait:bindBuild( enemyProfile.build )
		screen.binder.pnl.binder.theirface.binder.portrait:bindAnim( enemyProfile.anim )
		screen.binder.pnl.binder.theirface:setVisible(true)
		if enemyProfile.color then
			screen.binder.pnl.binder.theirface.binder.portrait:setColor(enemyProfile.color.r,enemyProfile.color.g,enemyProfile.color.b,1)
		end
	else
		screen.binder.pnl.binder.theirface:setVisible(false)
	end

	-- Fill out the dialog options.
	local result = nil
	local x = 1
	for i, btn in screen.binder.pnl.binder:forEach( "optionBtn" ) do
		if options[i] == nil then
			btn:setVisible( false )
		else
			btn:setVisible( true )
			btn:setText("<c:8CFFFF>"..  options[i] .."</>")
			btn.onClick = util.makeDelegate( nil, function() result = i end )
			x = x + 1
		end
	end

	if (dType == "level" or dType == "augment") and tooltips ~= nil then
		for i, btn in screen.binder.pnl.binder:forEach( "optionBtn" ) do
			btn:setTooltip(tooltips[i])
		end
	end

	-- We are running in the vizThread coroutine.  Yield until a response is chosen by the UI.
	-- Note that the click handler will be triggered by the main coroutine, but we use a closure
	-- to inform us what the chosen result is.
	while result == nil do
		coroutine.yield()
	end

	mui.deactivateScreen( screen )
	hud._choice_dialog = nil

	hud._game.simCore:setChoice( result )

	return result
end

local hud = include( "hud/hud" )
local oldCreateHud = hud.createHud

hud.createHud = function( ... )
    local hudObject = oldCreateHud( ... )

    local oldOnSimEvent = hudObject.onSimEvent

    function hudObject:onSimEvent( ev )
        if ev.eventType == "INC_EV_CHOICE_DIALOG" then
			return showChoiceDialog( self, ev.eventData.headerTxt, ev.eventData.bodyTxt, ev.eventData.options, ev.eventData.type, ev.eventData.tooltips, ev.eventData.playerCredits, ev.eventData.enemyProfile )
		elseif ev.eventType == "INC_EV_CREDITS_ACQUIRED" then
			if not self._game.debugStep then
				modalDialog.show( string.format("%s acquired %d credits!", ev.eventData.unit:getName(), ev.eventData.credits ), "Loot" )
			end
		else
			oldOnSimEvent( self, ev )
		end
    end

    return hudObject
end