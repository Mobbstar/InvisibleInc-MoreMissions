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
	
	kanim_mm_bodyguard =
	{
		wireframe =
		{
			"data/anims/characters/corp_FTM/ftm_med_overlay.abld",--"data/anims/characters/corp_neutral/enforcer.abld",
		},
		build = 
		{ 
			"data/anims/characters/corp_neutral/mm_bodyguard.abld",
			"data/anims/characters/anims_male/shared_hits_01.abld",	
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",	 	 
		},
		grp_build = 
		{
			"data/anims/characters/corp_neutral/grp_mm_bodyguard.abld",
		},		
		grp_anims = commonanims.male.grp_anims,

		anims = commonanims.male.default_anims_2h,
		anims_1h = commonanims.male.default_anims_1h,
		anims_2h = commonanims.male.default_anims_2h,
		animMap = GUARD_ANIMS,

		symbol = "character",
		anim = "idle",
		shouldFlip = true,
		shouldFlipOverrides = {
			{anim="peek_fwrd", shouldFlip=false},
			{anim="peek_pst_fwrd", shouldFlip=false},
		},
		scale = 0.25,
		layer = Layer.Unit,
		boundType = BoundType.Character,
		boundTypeOverrides = {			
			{anim="idle_ko" ,boundType= BoundType.CharacterFloor},
			{anim="dead" ,boundType= BoundType.CharacterFloor},
		},		
	},	

	-- TECH EXPO kanims
	MM_gun_tester =
	{
		build = { "data/anims/props/gun_tester_2x1.abld", "data/anims/general/mf_coverpieces_1x2.abld" },
		anims = { "data/anims/Seikaku_robobay/seikaku_robobay_object_2x1cannontester1.adef", "data/anims/general/mf_coverpieces_1x2.adef" },
		anim = "idle",
		scale = 0.25,
		boundType = BoundType.bound_2x1_med_med,
	},

	MM_portalgun_tester =
	{
		build = { "data/anims/props/portalgun_tester_2x1.abld", "data/anims/general/mf_coverpieces_1x2.abld" },
		anims = { "data/anims/Seikaku_robobay/seikaku_robobay_object_2x1cannontester1.adef", "data/anims/general/mf_coverpieces_1x2.adef" },
		anim = "idle",
		scale = 0.25,
		boundType = BoundType.bound_2x1_med_med,
	},	

	kanim_MM_portal_turret =
	{
		build = "data/anims/props/portal_turret.abld",
		anims = { "data/anims/mainframe/office_security_1x1turret_new.adef" },
		symbol = "character",
		shouldFlip = true,
		scale = 0.25,
		layer = Layer.Object,
		boundType = BoundType.bound_1x1_tall_med,
		filterSymbols = {{symbol="fire",filter="default"},{symbol="red",filter="default"},{symbol="teal",filter="default"}},
	},	
	
	
	kanim_MM_gunsafe_1 =
	{
		build = "data/anims/props/MM_gunsafe1.abld",
		anims = { "data/anims/Unique_Vault/vault_1x1_podium1.adef" },
		symbol = "character",		
		scale = 0.25,
		layer = Layer.Decor,
		boundType = BoundType.bound_1x1_tall_med,
		filterSymbols = {{symbol="glow",filter="default"},{symbol="Highlight",filter="default"},{symbol="red",filter="default"},{symbol="teal",filter="default"}},		
	},
	kanim_MM_gunsafe_2 =
	{
		build = "data/anims/props/MM_gunsafe2.abld",
		anims = { "data/anims/Unique_Vault/vault_1x1_podium1.adef" },
		symbol = "character",		
		scale = 0.25,
		layer = Layer.Decor,
		boundType = BoundType.bound_1x1_tall_med,
		filterSymbols = {{symbol="glow",filter="default"},{symbol="Highlight",filter="default"},{symbol="red",filter="default"},{symbol="teal",filter="default"}},		
	},
	kanim_MM_gunsafe_3 =
	{
		build = "data/anims/props/MM_gunsafe3.abld",
		anims = { "data/anims/Unique_Vault/vault_1x1_podium1.adef" },
		symbol = "character",		
		scale = 0.25,
		layer = Layer.Decor,
		boundType = BoundType.bound_1x1_tall_med,
		filterSymbols = {{symbol="glow",filter="default"},{symbol="Highlight",filter="default"},{symbol="red",filter="default"},{symbol="teal",filter="default"}},		
	},	

	kanim_MM_prototype_drone =
	{
		build = 
		{ 
			"data/anims/props/prototype_drone.abld",	 
		},
		anims =
		{		
			"data/anims/characters/corp_SK/sankaku_droid.adef",
		},
		anims_1h =
		{
			"data/anims/characters/corp_SK/sankaku_droid.adef",
		},
		anims_2h =
		{	
			"data/anims/characters/corp_SK/sankaku_droid.adef",
		},


		symbol = "character",
		anim = "idle",
		shouldFlip = true,
		scale = 0.25,
		layer = Layer.Unit,
		boundType = BoundType.Character,
		boundTypeOverrides = {			
			{anim="idle_closed" ,boundType= BoundType.CharacterFloor},
			{anim="dead" ,boundType= BoundType.CharacterFloor},
		},		
		animMap = DRONE_ANIMS,
	},	

	kanim_MM_prototype_turret =
	{
		build = "data/anims/props/prototype_turret.abld",
		anims = { "data/anims/mainframe/office_security_1x1turret_new.adef" },
		symbol = "character",
		shouldFlip = true,
		scale = 0.2,--0.25,
		layer = Layer.Object,
		boundType = BoundType.bound_1x1_tall_med,
		filterSymbols = {{symbol="fire",filter="default"},{symbol="red",filter="default"},{symbol="teal",filter="default"}},
	},	

	kanim_MM_prototype_turret_alpha =
	{
		build = "data/anims/props/turret_alpha.abld",
		anims = { "data/anims/mainframe/office_security_1x1turret_new.adef" },
		symbol = "character",
		shouldFlip = true,
		scale = 0.25,
		layer = Layer.Object,
		boundType = BoundType.bound_1x1_tall_med,
		filterSymbols = {{symbol="fire",filter="default"},{symbol="red",filter="default"},{symbol="teal",filter="default"}},
	},		

	mm_kanim_guard_male_dummy =
	{
		wireframe =
		{
			"data/anims/characters/corp_FTM/ftm_med_overlay.abld",--"data/anims/characters/corp_neutral/bot_male.abld",
		},
		build = 
		{ 
			"data/anims/characters/corp_neutral/bot_male.abld",
			"data/anims/characters/anims_male/shared_male_robot_hits_01.abld",	
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",	 	 
		},
		grp_build = 
		{
			"data/anims/characters/corp_neutral/grp_bot_male.abld",
		},		
		grp_anims = commonanims.male.grp_anims,
		
		anims = commonanims.male.default_anims_1h,
		anims_1h = commonanims.male.default_anims_1h,
		anims_2h = commonanims.male.default_anims_2h,
		animMap = GUARD_ANIMS,

		symbol = "character",
		anim = "idle",
		shouldFlip = true,
		shouldFlipOverrides = {
			{anim="peek_fwrd", shouldFlip=false},
			{anim="peek_pst_fwrd", shouldFlip=false},
		},
		scale = 0.25,
		layer = Layer.Unit,
		boundType = BoundType.Character,
		boundTypeOverrides = {			
			{anim="idle_ko" ,boundType= BoundType.CharacterFloor},
			{anim="dead" ,boundType= BoundType.CharacterFloor},
		},		
	},	
	-- will need second version for specdroid variant
	
	--these two are used for the two droid variant PROPS, not guards
	mm_kanim_guard_male_dummy1 =
	{
		wireframe =
		{
			"data/anims/characters/corp_FTM/ftm_med_overlay.abld",--"data/anims/characters/corp_neutral/bot_male.abld",
		},
		build = 
		{ 
			"data/anims/characters/corp_neutral/bot_male.abld",
			"data/anims/characters/anims_male/shared_hits_01.abld",	
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",	 	 
		},
		grp_build = 
		{
			"data/anims/characters/corp_neutral/grp_bot_male.abld",
		},		
		grp_anims = commonanims.male.grp_anims,
		
		anims = commonanims.male.default_anims_2h,
		anims_1h = commonanims.male.default_anims_1h,
		anims_2h = commonanims.male.default_anims_2h,
		animMap = GUARD_ANIMS,

		symbol = "character",
		anim = "overwatch_melee", --"idle",-- "pin_stand",--"walk",--"shoot_pre",
		shouldFlip = true,
		scale = 0.25,
		layer = Layer.Unit,
		boundType = BoundType.Character,		
	},	
	
	mm_kanim_guard_male_dummy2 =
	{
		wireframe =
		{
			"data/anims/characters/corp_FTM/ftm_med_overlay.abld",--"data/anims/characters/corp_neutral/bot_male.abld",
		},
		build = 
		{ 
			"data/anims/characters/corp_neutral/bot_male.abld",
			"data/anims/characters/anims_male/shared_hits_01.abld",	
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",	 	 
		},
		grp_build = 
		{
			"data/anims/characters/corp_neutral/grp_bot_male.abld",
		},		
		grp_anims = commonanims.male.grp_anims,
		
		anims = commonanims.male.default_anims_2h,
		anims_1h = commonanims.male.default_anims_1h,
		anims_2h = commonanims.male.default_anims_2h,
		animMap = GUARD_ANIMS,

		symbol = "character",
		anim = "overwatch_melee",
		shouldFlip = true,
		scale = 0.25,
		layer = Layer.Unit,
		boundType = BoundType.Character,		
	},	
	
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
