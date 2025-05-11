local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

--for Distress Call
local mission_util = include("sim/missions/mission_util")
local doAgentBanter_old = mission_util.doAgentBanter
mission_util.doAgentBanter = function(script,sim,cross_script,odds,returnIfFailed, ...)
	--if sim:getParams().situationName == "distress_call" then
	if sim:getTags().skipBanter then
		-- log:write("[MM] skipping banter")
		return
	end
	doAgentBanter_old(script,sim,cross_script,odds,returnIfFailed, ...)
end
