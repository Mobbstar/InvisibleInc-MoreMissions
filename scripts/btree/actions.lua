local array = include("modules/array")
local util = include("modules/util")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local btree = include("sim/btree/btree")
local Actions = include("sim/btree/actions")
local Conditions = include("sim/btree/conditions")

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

-- Normally Actions.ReactToInterest handles facing things seen in peripheral vision, except that
-- (1) the interests are already 'noticed' by Actions.Panic.
-- (2) Actions.ReactToInterest only changes facing if the interest is noticed while this is the active guard.
-- Explicitly turn to face interests noticed while active
function Actions.mmFaceInterest( sim, unit )
	local interest = unit:getBrain():getInterest()
	if interest and not interest.mmFaced and unit:canReact() then
		-- Skip turning if unarmed and losttarget. Otherwise we keep turning back while trying to flee.
		if (not interest.reason == simdefs.REASON_LOSTTARGET) or Conditions.mmIsArmed( sim, unit ) then
			unit:turnToFace(interest.x, interest.y)
		end
		interest.mmFaced = true
	end

	return simdefs.BSTATE_COMPLETE
end

-- MoveToNextPatrolPoint, except the mission script has replaced the patrol path with the current safe destination.
-- Also, turn to face interests if we can see the cell. This lets the guard try to overwatch someone standing outside the room before fleeing in the other direction.
Actions.mmMoveToSafetyPoint = class(Actions.MoveTo, function(self, name)
	btree.BaseAction.init(self, name or "mmMoveToSafetyPoint")
end)

function Actions.mmMoveToSafetyPoint:getDestination()
	return self.unit:getBrain():getPatrolPoint()
end

function Actions.mmMoveToSafetyPoint:executePath(unit, ...)
	local interest = unit:getBrain():getInterest()
	if interest and not interest.mmFaced then
		local x0, y0 = unit:getLocation()
		local raycastX, raycastY = unit:getSim():getLOS():raycast(x0, y0, interest.x, interest.y)
		if raycastX == interest.x and raycastY == interest.y then
			unit:turnToFace(interest.x, interest.y)
		end
		interest.mmFaced = true
	end

	return Actions.MoveTo.executePath(self, unit, ...)
end
