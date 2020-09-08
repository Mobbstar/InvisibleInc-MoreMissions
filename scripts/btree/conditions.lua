local Conditions = include("sim/btree/conditions")

function Conditions.mmHasSearchedVipSafe( sim, unit )
	return unit:getTraits().mmSearchedVipSafe
end

function Conditions.mmIsArmed( sim, unit )
	return unit:ownsAbility( "shootSingle" )
end
