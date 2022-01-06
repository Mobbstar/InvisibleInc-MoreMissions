local laser = include( "sim/units/laser" )

local function extractUpvalue( fn, name )
	local i = 1
	while true do
		local n, v = debug.getupvalue(fn, i)
		assert(n, string.format( "Could not find upvalue: %s", name ) )
		if n == name then
			return v
		end
		i = i + 1
	end
end

-- sim/units/laser doesn't export the class, unlike most unit class files, and the exported function was registered as a local, so can't be appended.
-- Use debug.getupvalue to extract the class table
local laser_emitter = extractUpvalue( laser.createLaserEmitter, "laser_emitter" )

local oldActivate = laser_emitter.activate

function laser_emitter:activate( sim, ... )
	local cleanupQueue = false
	if sim:getParams().difficultyOptions.mm_enabled then
		sim:startDaemonQueue()
		cleanupQueue = true
	end

	oldActivate( self, sim, ... )

	if cleanupQueue then
		sim:processDaemonQueue()
	end
end
