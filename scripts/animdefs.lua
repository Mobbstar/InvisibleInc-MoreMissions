local cdefs = include( "client_defs" )
local util = include( "client_util" )
local commondefs = include( "sim/unitdefs/commondefs" )
local commonanims = include("common_anims")


local AGENT_ANIMS = commondefs.AGENT_ANIMS
local GUARD_ANIMS = commondefs.GUARD_ANIMS
local HOSTAGE_ANIMS = commondefs.HOSTAGE_ANIMS
local DRONE_ANIMS = commondefs.DRONE_ANIMS
local FLOAT_DRONE_ANIMS = commondefs.FLOAT_DRONE_ANIMS
local FLOAT_DRONE_TANK_ANIMS = commondefs.FLOAT_DRONE_TANK_ANIMS
local Layer = commondefs.Layer
local BoundType = commondefs.BoundType


local animdefs =
{
	-- kanim_scientist =
	-- {
		-- wireframe =
		-- {
			-- "data/anims/characters/corp_FTM/ftm_med_overlay.abld",
		-- },
		-- build = 
		-- { 
			-- "data/anims/characters/agents/lab_tech.abld",
			-- "data/anims/characters/anims_male/shared_hits_01.abld",	
			-- "data/anims/characters/anims_male/shared_attacks_a_01.abld",	 	 
		-- },
		-- grp_build = 
		-- {
			-- "data/anims/characters/agents/grp_lab_tech.abld",
		-- },		
		-- grp_anims = commonanims.male.grp_anims,

		-- anims = commonanims.male.default_anims_unarmed,
		-- anims_1h = commonanims.male.default_anims_1h,
		-- anims_2h = commonanims.male.default_anims_2h,
		-- anims_panic = commonanims.male.default_anims_panic,
		-- animMap = GUARD_ANIMS,

		-- symbol = "character",
		-- anim = "idle",
		-- shouldFlip = true,
		-- shouldFlipOverrides = {
			-- {anim="peek_fwrd", shouldFlip=false},
			-- {anim="peek_pst_fwrd", shouldFlip=false},
		-- },
		-- scale = 0.25,
		-- layer = Layer.Unit,
		-- boundType = BoundType.Character,
		-- boundTypeOverrides = {			
			-- {anim="idle_ko" ,boundType= BoundType.CharacterFloor},
			-- {anim="dead" ,boundType= BoundType.CharacterFloor},
		-- },		
	-- },
	
	-- kanim_switch =
	-- {              
		-- build = "data/anims/props/access_switch.abld",
		-- anims = { "data/anims/props/access_switch.adef" },
		-- symbol = "character",		
		-- scale = 0.25,
		-- layer = Layer.Decor,
		-- boundType = BoundType.bound_1x1_med_big,
		-- filterSymbols = {{symbol="glow",filter="default"},{symbol="Highlight",filter="default"},{symbol="red",filter="default"},{symbol="teal",filter="default"}},
	-- },

	-- kanim_switch_fx =
	-- {
		-- build = { "data/anims/props/access_switch_fx.abld" },
		-- anims = { "data/anims/props/access_switch_fx.adef" },
		-- --symbol = "APMeter",
		-- anim = "idle_in",
		-- scale = 0.25,
		-- layer = Layer.Unit,
		-- boundType = BoundType.Character, -- this doesn't really apply to HUD stuff...
	-- },
}

return animdefs