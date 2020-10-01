local array = include("modules/array")
local util = include("modules/util")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local Actions = include("sim/btree/actions")

local function interestOutsideOfSaferoom( sim, interest )
	local cell = sim:getCell( interest.x, interest.y )
	return not simquery.cellHasTag( sim, cell, "saferoom" )
end

function Actions.mmArmVip( sim, unit )
	if unit:getTraits().mmSearchedVipSafe then
		-- Already done. Skip.
		return simdefs.BSTATE_COMPLETE
	end

	-- Let mission script handle the weapon transfer
	sim:triggerEvent( "MM-VIP-ARMING", {unit=unit} )

	-- Remove current interest and UI indicator, if outside the saferoom
	local currentInterest = unit:getBrain():getInterest()
	if currentInterest and interestOutsideOfSaferoom( sim, currentInterest ) then
		sim:dispatchEvent( simdefs.EV_UNIT_DEL_INTEREST, {unit = unit, interest = currentInterest} )
		sim:triggerEvent( simdefs.TRG_DEL_INTEREST, {unit = unit, interest = currentInterest} )
	end
	-- Remove other interests outside the saferoom
	array.removeIf( unit:getBrain():getSenses().interests, function( interest ) return interestOutsideOfSaferoom( sim, interest ) end )

	-- Update traits
	unit:getTraits().mmSearchedVipSafe = true
	unit:getTraits().vip = false

	sim:processReactions( unit )

	return simdefs.BSTATE_COMPLETE
end

function Actions.mmRequestNewPanicTarget( sim, unit )

	local rememberedInterest = unit:getBrain():getSenses():getRememberedInterest()
	if rememberedInterest then
		unit:getBrain():getSenses():addInterest( rememberedInterest.x, rememberedInterest.y, rememberedInterest.sense, rememberedInterest.reason, rememberedInterest.sourceUnit )
		return simdefs.BSTATE_COMPLETE
	end

	local x0,y0 = unit:getLocation()
	local cells = sim:getCells( "saferoom" )
	local doorCell = sim:getCells( "saferoom_door" ) and sim:getCells( "saferoom_door" )[1]
	local targetCell = nil

	if cells then
		cells = util.tdupe( cells )
		local function isInvalidHuntCell(c)
			return (
				-- open cells
				c.impass > 0
				-- not near the CEO's current position
				or (math.abs(c.x - x0) <= 2 and math.abs(c.y - y0) <= 2)
				-- not at the door (don't accidentally open the door to peek)
				or (doorCell and c.x == doorCell.x and c.y == doorCell.y)
			)
		end
		array.removeIf( cells, isInvalidHuntCell )

		targetCell = cells[sim:nextRand(1, #cells)]
	end

	if not targetCell then
		return simdefs.BSTATE_FAILED
	end

	unit:getBrain():getSenses():addInterest( targetCell.x, targetCell.y, simdefs.SENSE_RADIO, simdefs.REASON_HUNTING, unit )

	return simdefs.BSTATE_COMPLETE
end
