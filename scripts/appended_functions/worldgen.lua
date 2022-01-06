local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local worldgen = include("sim/worldgen")
local generateThreats_old = worldgen.generateThreats
worldgen.generateThreats = function( cxt, spawnTable, spawnList, ... )
	local params = cxt.params
	local unitdefs = include("sim/unitdefs")
	if unitdefs.lookupTemplate("MM_prototype_droid") and unitdefs.lookupTemplate("MM_prototype_droid_spec") 
	and not ((params.world == "omni") or (params.world == "omni2")) 
	and params.difficulty >= (params.difficultyOptions.MM_spawnTable_droids or 99999) then
	-- and params.difficulty >= 1 then	 --TEST	
		local rand = rand_module.createGenerator( params.seed )
		local randSpawn_COMMON = spawnTable.COMMON[rand:nextInt(1,#spawnTable.COMMON)]
		local randSpawn_ELITE = spawnTable.ELITE[rand:nextInt(1,#spawnTable.ELITE)]
		
		if rand:nextInt(1,100) < 50 then
			randSpawn_COMMON[1] = "MM_specdroid"
		else
			randSpawn_ELITE[1] = "MM_prototype_droid_spec"
		end
	end
	-- log:write("LOG spawnTable")
	-- log:write(util.stringize(spawnTable,3))
	
	return generateThreats_old( cxt, spawnTable, spawnList, ... )
end	