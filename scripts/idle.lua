local IdleSituation = include("sim/btree/situations/idle")

local oldGeneratePatrolPath = IdleSituation.generatePatrolPath

function IdleSituation:generatePatrolPath( unit, x0, y0, noPatrolCheck )
	assert( unit:getBrain():getSituation() == self )

	-- With nopatrolchange, reject attempts to replace an existing patrol route with a newly generated one.
	if unit:getTraits().mm_nopatrolchange and unit:getTraits().patrolPath then
		return
	end

	oldGeneratePatrolPath( self, unit, x0, y0, noPatrolCheck )
end
