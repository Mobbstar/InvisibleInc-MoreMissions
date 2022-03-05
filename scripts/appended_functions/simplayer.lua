local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

-- For Distress Call alarm increase.

-- OLD
-- local aiplayer = include( "sim/aiplayer" )
-- local _onEndTurn = aiplayer.onEndTurn
-- function aiplayer:onEndTurn(sim)
	-- local trackerBoost = sim.missionTrackerBoost or 0
	-- _onEndTurn(self, sim)
	-- trackerBoost = 0
-- end

-- this bit was moved to engine_init append
-- local simengine = include( "sim/engine" )
-- local _trackerAdvance = simengine.trackerAdvance
-- function simengine:trackerAdvance(delta, ...)
	-- delta = delta + trackerBoost
	-- return _trackerAdvance(self, delta, ...)
-- end

local simplayer = include("sim/simplayer")
local simplayer_onEndTurn_old = simplayer.onEndTurn
simplayer.onEndTurn = function( self, sim, ... )
	simplayer_onEndTurn_old( self, sim, ... )
	if (sim:getCurrentPlayer() == self) and self:isNPC() then
		local trackerBoost = sim.missionTrackerBoost or 0
		if trackerBoost > 0 then
			sim:trackerAdvance(trackerBoost, STRINGS.UI.ALARM_INCREASE )
		end
	end
end
