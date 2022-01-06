local mui = include( "mui/mui" )
local util = include( "client_util" )
local util2 = include( "modules/util" )
local cdefs = include("client_defs")

----------------------------------------------------------------
-- Local functions
-- MUCH THANKS TO WODZU FOR THIS CODE
local function onClickOption1( dialog, screen )
	dialog.result = {
		txt = screen.binder.pnl.binder.inputBox:getText(),
	}
	dialog._game.simCore:setChoice( dialog.result )
	dialog:hide()
end

----------------------------------------------------------------
-- Interface functions

local name_dialog = class()

function name_dialog:init(game)
	local screen = mui.createScreen( "name_dialog_screen.lua" )
	self._game = game
	self._screen = screen

	screen.binder.pnl.binder.option1Btn.onClick = util.makeDelegate( nil, onClickOption1, self, screen )

	screen.binder.pnl.binder.header:setText(STRINGS.MOREMISSIONS.ABILITIES.RENAME_DRONE)
	screen.binder.pnl.binder.inputBox:setText(">")
	screen.binder.pnl.binder.option1Btn:setText(STRINGS.MOREMISSIONS.ABILITIES.RENAME_DRONE_CONFIRM)
end

function name_dialog:show()
	mui.activateScreen( self._screen )
	FMODMixer:pushMix( "quiet" )
	MOAIFmodDesigner.playSound( cdefs.SOUND_HUD_GAME_POPUP )

	self.result = nil

	while self.result == nil do
		coroutine.yield()
	end

	return self.result
end

function name_dialog:hide()
	if self._screen:isActive() then
		mui.deactivateScreen( self._screen )
		FMODMixer:popMix( "quiet" )
	end
end

return name_dialog
