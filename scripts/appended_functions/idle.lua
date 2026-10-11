local IdleSituation = include("sim/btree/situations/idle")

-- make bodyguard patrol never leave the room with the vip
-- this is complicated a bit by AGP having a helper with the same name
-- (I wanted it to work with AGP so he can get the 3 point patrols)
local wrappedCanPatrolRooms = {}
while true do
	local oldCanPatrolRoom, idx, subFn = upvalueUtil.find(IdleSituation.generatePatrolPath, function(name, value)
		return name == "canPatrolRoom" and type(value) == "function" and not wrappedCanPatrolRooms[value]
	end, 10)
	if not idx then
		break
	end
	local function canPatrolRoom(sim, startRoom, room, unit, ...)
		if type(unit) == "table" and startRoom and unit.getTraits and unit:getTraits().MM_bodyguard then
			if startRoom == room then
				return true
			else
				return false
			end
		end
		return oldCanPatrolRoom(sim, startRoom, room, unit, ...)
	end
	wrappedCanPatrolRooms[canPatrolRoom] = true
	debug.setupvalue(subFn, idx, canPatrolRoom)
end

local oldGeneratePatrolPath = IdleSituation.generatePatrolPath

function IdleSituation:generatePatrolPath( unit, x0, y0, noPatrolCheck )
	assert( unit:getBrain():getSituation() == self )

	-- With nopatrolchange, reject attempts to replace an existing patrol route with a newly generated one.
	if unit:getTraits().mm_nopatrolchange and unit:getTraits().patrolPath then
		return
	end

	oldGeneratePatrolPath( self, unit, x0, y0, noPatrolCheck )
end
