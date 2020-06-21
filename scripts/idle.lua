local IdleSituation = include("sim/btree/situations/idle")

local oldGeneratePatrolPath = IdleSituation.generatePatrolPath

function IdleSituation:generatePatrolPath( unit, x0, y0, noPatrolCheck )
	assert( unit:getBrain():getSituation() == self )

	if not unit:getTraits().mm_nopatrolchange then
		oldGeneratePatrolPath( self, unit, x0, y0, noPatrolCheck )
	end
end
