local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

-- start of mission: spawn intel bonuses if player has completed a mole mission

local function runAppend( modApi )
	local scriptPath = modApi:getScriptPath()
	local spawn_mole_bonus = include( scriptPath .. "/spawn_mole_bonus" )
	local spawn_refit_drone = include( scriptPath .. "/spawn_refit_drone" )
	local mission_util = include("sim/missions/mission_util")
	local makeAgentConnection_old = mission_util.makeAgentConnection

	mission_util.makeAgentConnection = function( script, sim, ... )
		-- spawn bonus
		-- log:write("[MM] makeAgentConnection append")
		spawn_refit_drone( script, sim )
		makeAgentConnection_old(script, sim, ...)
		spawn_mole_bonus( sim )
		sim:triggerEvent( "agentConnectionDone" ) --used by Distress Call to start doing the scripted intro
	end

	local showAugmentInstallDialog_old = mission_util.showAugmentInstallDialog
	mission_util.showAugmentInstallDialog = function( sim, item, unit )
		if not item:getTraits().augment then
			return
		end
		return showAugmentInstallDialog_old(sim, item, unit)
	end
end

return { runAppend = runAppend }
