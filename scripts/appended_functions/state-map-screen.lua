local game = include( "modules/game" )
local util = include("client_util")
local array = include("modules/array")
local mui = include( "mui/mui" )
local mui_defs = include( "mui/mui_defs" )
local mathutil = include( "modules/mathutil" )
local serverdefs = include( "modules/serverdefs" )
local version = include( "modules/version" )
local agentdefs = include("sim/unitdefs/agentdefs")
local skilldefs = include( "sim/skilldefs" )
local simdefs = include( "sim/simdefs" )
local simactions = include( "sim/simactions" )
local modalDialog = include( "states/state-modal-dialog" )
local rig_util = include( "gameplay/rig_util" )
local metrics = include( "metrics" )
local cdefs = include("client_defs")
local scroll_text = include("hud/scroll_text")
local guiex = include( "client/guiex" )
local SCRIPTS = include('client/story_scripts')

local talkinghead = include('client/fe/talkinghead')
local locationPopup = include('client/fe/locationpopup')
local stars = include('client/fe/stars')

local ACTIVE_TXT = { 61/255,81/255,83/255,1 }
local INACTIVE_TXT = { 1,1,1,1 }

local LOGO_COLOR = { 144/255,1,1,1 }

local HIGHLIGHT_TIME = .333
local UNHIGHLIGHT_TIME = .333

local stateMapScreen = include( "states/state-map-screen" )
local OnClickLocation_old = stateMapScreen.OnClickLocation

local function getMaxBonus( intel )
	local duration = 0
	for i, bonus in pairs(intel) do
		if bonus.missions_left > duration then
			duration = bonus.missions_left
		end
	end
	return duration
end

stateMapScreen.OnClickLocation = function( self, situation, ... )
	OnClickLocation_old( self, situation, ... )
	if STRINGS.MOREMISSIONS then
		local screen
		for i, active_screen in pairs(mui.internals._activeScreens) do
			if active_screen:findWidget("MM_informantBonus") then
				screen = active_screen
				break
			end
		end	
		
		local corpData = serverdefs.getCorpData( situation )
		if self._campaign.agency.MM_informant_bonus and (#self._campaign.agency.MM_informant_bonus > 0) and not ((situation.corpName == "omni") or (situation.corpName == "omni2"))
		then
			-- log:write("LOG setting mole visible")
			screen:findWidget("MM_informantBonus"):setVisible( true )
			screen:findWidget("MM_informantInfo"):setVisible(true)
			local missionsLeft = getMaxBonus( self._campaign.agency.MM_informant_bonus )
			screen:findWidget("MM_informantBonus.moleIcon"):setTooltip( util.sformat(STRINGS.MOREMISSIONS.UI.MAP_SCREEN.MOLE_TOOLTIP, missionsLeft) )
			screen:findWidget("MM_informantInfo.moleDesc"):setText(STRINGS.MOREMISSIONS.UI.MAP_SCREEN.MOLE_DESC)
			screen:findWidget("MM_informantInfo.moleName"):setText(STRINGS.MOREMISSIONS.UI.MAP_SCREEN.MOLE_NAME)	
		else
			-- log:write("LOG setting invisible")
			screen:findWidget("MM_informantBonus"):setVisible( false )
			screen:findWidget("MM_informantInfo"):setVisible( false )
		end
	end
end



