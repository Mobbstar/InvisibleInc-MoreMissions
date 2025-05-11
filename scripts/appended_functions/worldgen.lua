local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local rand_module = include( "modules/rand" )


local function runAppend()

local worldgen = include("sim/worldgen")
local generateThreats_old = worldgen.generateThreats

worldgen.generateThreats = function( cxt, spawnTable, spawnList, ... )
    local unitCount = #cxt.units

    generateThreats_old( cxt, spawnTable, spawnList, ... )

    spawnList = spawnList or simdefs.SPAWN_TABLE[cxt.params.difficultyOptions.spawnTable][ cxt.params.difficulty ]

    local params = cxt.params
    local unitdefs = include("sim/unitdefs")

    if params.difficulty >= (params.difficultyOptions.MM_spawnTable_droids or 99999) then
        local rand = rand_module.createGenerator( params.seed )

		if rand:nextInt(1,100) < 70 then

			if unitdefs.lookupTemplate("MM_prototype_droid") and unitdefs.lookupTemplate("MM_prototype_droid_spec")
			and not ((params.world == "omni") or (params.world == "omni2")) then
				if rand:nextInt(1,100) < 70 then
					-- log:write("[MM] spawning droid")
					local listIndex = array.find( spawnList, "COMMON" )

					if listIndex then
						cxt.units[unitCount + listIndex].template = "MM_prototype_droid"
					end
				else
					-- log:write("[MM] spawning elite droid")
					local listIndex = array.find( spawnList, "ELITE" )

					if listIndex then
						cxt.units[unitCount + listIndex].template = "MM_prototype_droid_spec"
					end
				end
			end
			if unitdefs.lookupTemplate("MM_spider_drone") and params.world == "sankaku" then
				if rand:nextInt(1,100) < 70 then
					-- log:write("[MM] spawning drone")
					local listIndex = array.find( spawnList, "ELITE" )

					if listIndex then
						cxt.units[unitCount + listIndex].template = "MM_spider_drone"
					end
				end
			end
		end
    end
end

------ OLD
-- local generateThreats_old = worldgen.generateThreats
-- worldgen.generateThreats = function( cxt, spawnTable, spawnList, ... )
	-- local params = cxt.params
	-- log:write(util.stringize(params.difficultyOptions.MM_spawnTable_droids,2))
	-- log:write(util.stringize(params.difficulty,2))
	-- if params.difficulty >= (params.difficultyOptions.MM_spawnTable_droids or 99999) then
		-- local unitdefs = include("sim/unitdefs")
		-- local rand = rand_module.createGenerator( params.seed )
		-- log:write("[MM] adding new threats")
		-- if unitdefs.lookupTemplate("MM_prototype_droid") and unitdefs.lookupTemplate("MM_prototype_droid_spec")

		-- and not ((params.world == "omni") or (params.world == "omni2")) then
			-- local randSpawn_COMMON = spawnTable.COMMON[rand:nextInt(1,#spawnTable.COMMON)]
			-- local randSpawn_ELITE = spawnTable.ELITE[rand:nextInt(1,#spawnTable.ELITE)]

			-- if rand:nextInt(1,100) < 70 then --note that passing this check still doesn't guarantee placement, it only adds it to the *possible* spawn pool.
				-- randSpawn_COMMON[1] = "MM_prototype_droid"
				-- -- table.insert(spawnTable.ELITE, {[1] = "MM_prototype_droid", [2] = 25}) -- this is the other way to do it but it would need to be done once per mod load... something to keep in mind
			-- else
				-- randSpawn_ELITE[1] = "MM_prototype_droid_spec"
			-- end
		-- end
		-- if unitdefs.lookupTemplate("MM_spider_drone") and params.world == "sankaku" then
			-- -- log:write("[MM] adding drone")
			-- local randSpawn_ELITE = spawnTable.ELITE[rand:nextInt(1,#spawnTable.ELITE)]
			-- if rand:nextInt(1,100) < 70 then
				-- randSpawn_ELITE[1] = "MM_spider_drone"
			-- end
		-- end
	-- end

	-- -- log:write("[MM] spawnTable")
	-- -- log:write(util.stringize(spawnTable,3))

	-- return generateThreats_old( cxt, spawnTable, spawnList, ... )
-- end

end

return { runAppend = runAppend }
