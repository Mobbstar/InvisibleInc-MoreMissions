local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local simplayer = include( "sim/simplayer" )
local pcplayer = include( "sim/pcplayer" )

local oldOnUnitAdded = pcplayer.onUnitAdded or simplayer.onUnitAdded

function pcplayer:onUnitAdded( unit, ... )
	oldOnUnitAdded( self, unit, ... )

	local sim = self._sim
	if sim:getParams().difficultyOptions.mm_enabled then
		local x0, y0 = unit:getLocation()
		if x0 and simquery.couldUnitSee( sim, unit ) then
			-- Send TRG_LOS_REFRESH for all cells seen by the unit.
			-- sim:refreshUnitLOS only triggers with cells that the unit couldn't see before, but all visible cells might be "new" to the updated player.
			local cells = sim._los:calculateUnitLOS( sim:getCell( x0, y0 ), unit )
			coords = {}
			for _,cell in pairs( cells ) do
				table.insert( coords, cell.x )
				table.insert( coords, cell.y )
			end
			sim:triggerEvent( simdefs.TRG_LOS_REFRESH, { seer = unit, cells = coords } )
		end
	end
end
