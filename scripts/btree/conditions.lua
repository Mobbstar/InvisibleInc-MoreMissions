local Conditions = include("sim/btree/conditions")

function Conditions.mmIsArmed( sim, unit )
	return not unit:getTraits().pacifist
end
