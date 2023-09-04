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
	
	local screen
	for i, active_screen in pairs(mui.internals._activeScreens) do
		if active_screen:findWidget("MM_informantBonus") then
			screen = active_screen
			break
		end
	end		
	
	if screen and STRINGS.MOREMISSIONS then
		
		local corpData = serverdefs.getCorpData( situation )
		if self._campaign.agency.MM_informant_bonus and (#self._campaign.agency.MM_informant_bonus > 0) and not ((situation.corpName == "omni") or (situation.corpName == "omni2"))
		then
			-- log:write("[MM] setting mole visible")
			screen:findWidget("MM_informantBonus"):setVisible( true )
			screen:findWidget("MM_informantInfo"):setVisible(true)
			local missionsLeft = getMaxBonus( self._campaign.agency.MM_informant_bonus )
			screen:findWidget("MM_informantBonus.moleIcon"):setTooltip( util.sformat(STRINGS.MOREMISSIONS.UI.MAP_SCREEN.MOLE_TOOLTIP, missionsLeft) )
			screen:findWidget("MM_informantInfo.moleDesc"):setText(STRINGS.MOREMISSIONS.UI.MAP_SCREEN.MOLE_DESC)
			screen:findWidget("MM_informantInfo.moleName"):setText(STRINGS.MOREMISSIONS.UI.MAP_SCREEN.MOLE_NAME)	
		else
			-- log:write("[MM] setting invisible")
			screen:findWidget("MM_informantBonus"):setVisible( false )
			screen:findWidget("MM_informantInfo"):setVisible( false )
		end
		
		local corpWorld = corpData.world
		
		if self._campaign.agency.MM_hostileAInerf and self._campaign.agency.MM_hostileAInerf[corpWorld] then
			screen:findWidget("MM_PE_hostileAI"):setVisible(true)
			
			local debuff = self._campaign.agency.MM_hostileAInerf[corpWorld]
			local situationDiff = situation.difficulty
			local hostileAIDiff = situationDiff - debuff
			if hostileAIDiff < 1 then hostileAIDiff = 1 end
			
			
			local pe_txt = STRINGS.MOREMISSIONS.UI.MAP_SCREEN.HOSTILE_AI_TEXT
			local pe_txt_formatted = util.sformat(pe_txt, situationDiff, debuff)
			screen:findWidget("MM_PE_hostileAI"):setTooltip(pe_txt_formatted)

			
			screen:findWidget("MM_PE_hostileAI.AIdifficultyShield"):setImage(string.format("gui/menu pages/map_screen/shield%d.png", hostileAIDiff))
				
			
			screen:findWidget("MM_PE_hostileAI_label"):setVisible(true)
			screen:findWidget("MM_PE_hostileAI_label.PE_AI_name"):setText(STRINGS.MOREMISSIONS.UI.MAP_SCREEN.HOSTILE_AI_NAME)
		else
			screen:findWidget("MM_PE_hostileAI"):setVisible(false)
			screen:findWidget("MM_PE_hostileAI_label"):setVisible(false)
		end
	end
end



