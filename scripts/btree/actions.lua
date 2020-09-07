local array = include("modules/array")
local util = include("modules/util")
local simdefs = include("sim/simdefs")
local Actions = include("sim/btree/actions")

function Actions.mmArmVip( sim, unit )
	sim:triggerEvent( "MM-VIP-ARMING", {unit=unit} )
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
	local targetCell = nil

	if cells then
		cells = util.tdupe( cells )
		array.removeIf( cells, function (c) return math.abs(c.x - x0) <= 2 and math.abs(c.y - y0) <= 2 end )

		targetCell = cells[sim:nextRand(1, #cells)]
	end

	if not targetCell then
		return simdefs.BSTATE_FAILED
	end

	unit:getBrain():getSenses():addInterest( targetCell.x, targetCell.y, simdefs.SENSE_RADIO, simdefs.REASON_HUNTING, unit )

	return simdefs.BSTATE_COMPLETE
end
