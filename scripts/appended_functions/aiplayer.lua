local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local aiplayer = include( "sim/aiplayer" )
local _onEndTurn = aiplayer.onEndTurn
function aiplayer:onEndTurn(sim)
	local trackerBoost = sim.missionTrackerBoost or 0
	_onEndTurn(self, sim)
	trackerBoost = 0
end

-- this bit was moved to engine_init append
-- local simengine = include( "sim/engine" )
-- local _trackerAdvance = simengine.trackerAdvance
-- function simengine:trackerAdvance(delta, ...)
	-- delta = delta + trackerBoost
	-- return _trackerAdvance(self, delta, ...)
-- end
