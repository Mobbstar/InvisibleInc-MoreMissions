local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local Conditions = include("sim/btree/conditions")

function Conditions.mmHasSearchedVipSafe( sim, unit )
	return unit:getTraits().mmSearchedVipSafe
end

function Conditions.mmIsArmed( sim, unit )
	return unit:ownsAbility( "shootSingle" )
end

function Conditions.mmInterestInSaferoom( sim, unit )
	local interest = unit:getBrain():getInterest()
	if interest then
		local cell = sim:getCell( interest.x, interest.y )
		return simquery.cellHasTag( sim, cell, "saferoom" )
	end
	return false
end

function Conditions.mmIsArmedAndInterestInSaferoom( sim, unit )
	return Conditions.mmIsArmed( sim, unit ) and Conditions.mmInterestInSaferoom( sim, unit )
end

function Conditions.mmInterestIsSelfPanic( sim, unit )
	local interest = unit:getBrain():getInterest()
	return interest and (interest.sourceUnit == unit) and (interest.reason == simdefs.REASON_HUNTING)
end
