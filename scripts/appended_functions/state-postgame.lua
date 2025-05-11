local util = include( "modules/util" )
local resources = include( "resources")
local modalDialog = include("states/state-modal-dialog")
local stateLoading = include( "states/state-loading" )
local mui = include( "mui/mui" )
local cdefs = include( "client_defs" )
local mui_defs = include( "mui/mui_defs" )
local mission_scoring = include("mission_scoring")
local mission_recap_screen = include ("hud/mission_recap_screen")
local metrics = include( "metrics" )
local ENDGAMEFLOW = mission_scoring.ENDGAMEFLOW
local death_dialog = include( "hud/death_dialog" )
local movieScreen = include('client/fe/moviescreen')
local serverdefs = include( "modules/serverdefs" )
local version = include( "modules/version" )
local simdefs = include( "sim/simdefs" )
local stateMapScreen = include( "states/state-map-screen" )
local stateTeamPreview = include( "states/state-team-preview" )
local SCRIPTS = include('client/story_scripts')
local agentdefs = include("sim/unitdefs/agentdefs")

-- This is incredibly invasive overkill for the sole purpose of making sure a mission easter egg can't randomly occur before the player has experienced the mission normally.

local postGame = include( "states/state-postgame" )
local postGame_onLoad_old = postGame.onLoad

postGame.onLoad = function( self, sim, params, num_actions )

	local mission_type = params.situationName
	-- log:write("[MM] situation " .. mission_type )

	local user = savefiles.getCurrentGame()
	if params.agency and params.agency.MM_techexpo_done then
		user.data.stat_tracker = user.data.stat_tracker or {}
		user.data.stat_tracker.played_missions = user.data.stat_tracker.played_missions or {}
		user.data.stat_tracker.played_missions[mission_type] = (user.data.stat_tracker.played_missions[mission_type] or 0) + 1
		user:save()
	end

	if user.data.stat_tracker and user.data.stat_tracker.played_missions["weapons_expo"] then
		params.agency.MM_techexpo_done_savefile = true
	end

	postGame_onLoad_old( self, sim, params, num_actions )

end