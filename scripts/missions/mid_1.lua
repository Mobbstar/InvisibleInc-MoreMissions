local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local function runAppend( modApi )
	local scriptPath = modApi:getScriptPath()
	local mole_insertion = include( scriptPath .. "/missions/mole_insertion" )
	local spawn_mole_bonus = include( scriptPath .. "/spawn_mole_bonus" )
	local spawn_refit_drone = include( scriptPath .. "/spawn_refit_drone" )
	if serverdefs.SITUATIONS["mid_1"] then
		local mid_1 = include(serverdefs.SITUATIONS["mid_1"].scriptPath.."mid_1")
		local mid_1_initOld = mid_1.init
		if not mid_1.MM_append then --lazy way to prevent double-appending in load
			mid_1.MM_append = true
			mid_1.init = function( self, scriptMgr, sim )
				mid_1_initOld( self, scriptMgr, sim )
				-- log:write("LOG new mid_1 init")
				local startPhase_old = nil
				for i, hook in ipairs(scriptMgr.hooks) do
					if hook.name == "MID_1" then
						-- log:write("LOG found MID_1 hook")
						-- log:write(util.stringize(hook,3))
						startPhase_old = hook
					end
				end
				if startPhase_old then
					-- log:write("LOG adding new hook")
					local newStartPhase = function( scriptMgr, sim )
						startPhase_old.hookFn( scriptMgr, sim )
						-- scriptMgr:queue( 5*cdefs.SECONDS ) --this does nothing...
						spawn_mole_bonus( sim, mole_insertion )
						-- log:write("LOG new mid1 start phase running")
						spawn_refit_drone( scriptMgr, sim )
					end
					scriptMgr:removeHook( startPhase_old )
					scriptMgr:addHook( "MID_1", newStartPhase )--append hookFn by removing and readding the hook

				end
			end
		end
	end
	
end

return { runAppend = runAppend }
