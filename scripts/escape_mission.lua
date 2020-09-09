

function fixNoPatrolFacing( sim )
	for i,unit in pairs( sim:getAllUnits() ) do
		if unit:getTraits().mm_fixnopatrolfacing and unit:getTraits().nopatrol then
			unit:getTraits().patrolPath[1].facing = unit:getFacing()
		end
	end
end


function init( scriptMgr, sim )
	fixNoPatrolFacing( sim )
end

return {
	init = init,
}
