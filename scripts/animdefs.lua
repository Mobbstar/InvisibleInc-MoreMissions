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

-- unarmed anim fix from Cyberboy
local anims_sysadmin_panic = util.tconcat( {
        "data/anims/characters/anims_male/shared_basic_a_01.adef",
        "data/anims/characters/anims_male/shared_basic_c_01.adef",
        "data/anims/characters/anims_male/shared_basic_c_02.adef",
        "data/anims/characters/anims_male/shared_basic_c_03.adef",
        "data/anims/characters/anims_male/shared_basic_c_04.adef",
        "data/anims/characters/anims_male/shared_basic_c_05.adef",
        "data/anims/characters/anims_male/shared_basic_c_06.adef",
        "data/anims/characters/anims_male/shared_basic_c_07.adef",
        --"data/anims/characters/anims_male/unarmed_basic_a_01.adef",
        "data/anims/characters/anims_male/unarmed_basic_a_02.adef",
        "data/anims/characters/anims_male/unarmed_basic_a_03.adef",
        "data/anims/characters/anims_male/unarmed_basic_a_04.adef",
    },

    commonanims.male.anims,
    commonanims.male.anims_panic
)

util.tclear(commonanims.male.default_anims_panic)
util.tmerge(commonanims.male.default_anims_panic, anims_sysadmin_panic)

local animdefs =
{
	kanim_mm_ceotarget =
	{
		wireframe =
		{
			"data/anims/characters/agents/executive.abld", --"data/anims/characters/corp_FTM/ftm_med_overlay.abld",
		},
		build =
		{
			"data/anims/characters/corp_neutral/mm_ceotarget.abld",
			"data/anims/characters/anims_male/shared_hits_01.abld",
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",
		},
		grp_build =
		{
			"data/anims/characters/corp_neutral/grp_mm_ceotarget.abld",
		},
		grp_anims = commonanims.male.grp_anims,
		anims = commonanims.male.default_anims_unarmed,
		anims_1h = commonanims.male.default_anims_1h,
		anims_2h = commonanims.male.default_anims_2h,
		anims_panic = commonanims.male.default_anims_panic,
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

	kanim_MM_techsafe_1 =
	{
		build = "data/anims/props/MM_techsafe1.abld",
		anims = { "data/anims/Unique_Vault/vault_1x1_podium1.adef" },
		symbol = "character",
		scale = 0.25,
		layer = Layer.Decor,
		boundType = BoundType.bound_1x1_tall_med,
		filterSymbols = {{symbol="glow",filter="default"},{symbol="Highlight",filter="default"},{symbol="red",filter="default"},{symbol="teal",filter="default"}},
	},

	kanim_MM_techsafe_2 =
	{
		build = "data/anims/props/MM_techsafe2.abld",
		anims = { "data/anims/Unique_Vault/vault_1x1_podium1.adef" },
		symbol = "character",
		scale = 0.25,
		layer = Layer.Decor,
		boundType = BoundType.bound_1x1_tall_med,
		filterSymbols = {{symbol="glow",filter="default"},{symbol="Highlight",filter="default"},{symbol="red",filter="default"},{symbol="teal",filter="default"}},
	},

	kanim_MM_techsafe_3 =
	{
		build = "data/anims/props/MM_techsafe3.abld",
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

	kanim_MM_android =
	{
		wireframe =
		{
			"data/anims/characters/corp_FTM/ftm_med_overlay.abld",--"data/anims/characters/corp_neutral/bot_male.abld",
		},
		build =
		{
			"data/anims/characters/corp_neutral/MM_bot_male_pink.abld",
			"data/anims/characters/anims_male/shared_male_robot_hits_01.abld",
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",
		},
		grp_build =
		{
			"data/anims/characters/corp_neutral/grp_MM_bot_male_pink.abld",
		},
		grp_anims = commonanims.male.grp_anims,

		anims = commonanims.male.default_anims_unarmed,
		-- anims = commonanims.male.default_anims_1h,
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

	kanim_MM_android_elite =
	{
		wireframe =
		{
			"data/anims/characters/corp_FTM/ftm_med_overlay.abld",--"data/anims/characters/corp_neutral/bot_male.abld",
		},
		build =
		{
			"data/anims/characters/corp_neutral/MM_bot_male_purple_v4.abld",
			"data/anims/characters/anims_male/shared_male_robot_hits_01.abld",
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",
		},
		grp_build =
		{
			"data/anims/characters/corp_neutral/grp_MM_bot_male_purple_v4.abld",
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

	kanim_MM_android_decoy =
	{
		wireframe =
		{
			"data/anims/characters/corp_FTM/ftm_med_overlay.abld",--"data/anims/characters/corp_neutral/bot_male.abld",
		},
		build =
		{
			"data/anims/characters/corp_neutral/MM_bot_male_pink_decoy.abld",
			"data/anims/characters/anims_male/shared_male_robot_hits_01.abld",
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",
		},
		grp_build =
		{
			"data/anims/characters/corp_neutral/grp_MM_bot_male_pink_decoy.abld",
		},
		grp_anims = commonanims.male.grp_anims,

		anims = commonanims.male.default_anims_unarmed,
		-- anims = commonanims.male.default_anims_1h,
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

	kanim_MM_spec_goose =
	{
		wireframe =
		{
			"data/anims/characters/agents/agent_male_empty.abld",
		},
		build =
		{
			"data/anims/characters/anims_male/shared_hits_01.abld",
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",
			"data/anims/characters/corp_neutral/MM_spec_goose.abld",
		},
		grp_build =
		{
			"data/anims/characters/corp_neutral/grp_MM_spec_goose.abld",
		},

		grp_anims = commonanims.male.grp_anims,

		anims = commonanims.male.default_anims_unarmed,
		anims_1h = commonanims.male.default_anims_1h,
		anims_2h = commonanims.male.default_anims_2h,
		animMap = util.extend( GUARD_ANIMS )
		{
			pin = "idle",
			overwatch_pre = "pin_pre",
			lean_overwatch_pre = "pin_pre",
			overwatch = "pin",
			overwatch_pst = "pin_pre",
			lean_overwatch_pst = "pin",
			shoot_pst = "pin",
		},

		symbol = "character",
		anim = "idle",
		shouldFlip = true,
		scale = 0.13,
		layer = Layer.Unit,
		boundType = BoundType.Character,
		boundTypeOverrides = {
			{anim="idle_ko" ,boundType= BoundType.CharacterFloor},
			{anim="dead" ,boundType= BoundType.CharacterFloor},
		},
		peekBranchSet = 1,
	},

	--these two are used for the two droid variant PROPS, not guards
	mm_kanim_guard_male_dummy1 =
	{
		wireframe =
		{
			"data/anims/characters/corp_FTM/ftm_med_overlay.abld",--"data/anims/characters/corp_neutral/bot_male.abld",
		},
		build =
		{
			"data/anims/characters/corp_neutral/MM_bot_male_pink.abld",
			"data/anims/characters/anims_male/shared_hits_01.abld",
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",
		},
		grp_build =
		{
			"data/anims/characters/corp_neutral/grp_MM_bot_male_pink.abld",
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
			"data/anims/characters/corp_neutral/MM_bot_male_purple_v2.abld",
			"data/anims/characters/anims_male/shared_hits_01.abld",
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",
		},
		grp_build =
		{
			"data/anims/characters/corp_neutral/grp_MM_bot_male_purple_v2.abld",
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

	kanim_MM_spec_goose_dummy =
	{
		wireframe =
		{
			"data/anims/characters/agents/agent_male_empty.abld",
		},
		build =
		{
			"data/anims/characters/anims_male/shared_hits_01.abld",
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",
			"data/anims/characters/corp_neutral/MM_spec_goose.abld",
		},
		grp_build =
		{
			"data/anims/characters/corp_neutral/grp_MM_spec_goose.abld",
		},

		grp_anims = commonanims.male.grp_anims,

		anims = commonanims.male.default_anims_unarmed,
		anims_1h = commonanims.male.default_anims_1h,
		anims_2h = commonanims.male.default_anims_2h,
		animMap = {
			pin = "idle",
			overwatch_pre = "pin_pre",
			lean_overwatch_pre = "pin_pre",
			overwatch = "pin",
			overwatch_pst = "pin_post",
			lean_overwatch_pst = "pin_post",
			shoot_pst = "pin_post",
		},
		symbol = "character",
		-- anim = "idle",
		shouldFlip = true,
		scale = 0.13,
		anim = "overwatch_melee",
		layer = Layer.Unit,
		boundType = BoundType.Character,
		boundTypeOverrides = {
			{anim="idle_ko" ,boundType= BoundType.CharacterFloor},
			{anim="dead" ,boundType= BoundType.CharacterFloor},
		},
		peekBranchSet = 1,
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

	kanim_MM_agent009 =
	{
		wireframe =
		{
			"data/anims/characters/agents/agent_male_empty.abld",
		},
		build =
		{
			"data/anims/characters/agents/MM_agent009.abld",
			"data/anims/characters/anims_male/shared_hits_01.abld",
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",
		},
		grp_build =
		{
			"data/anims/characters/agents/grp_MM_agent009.abld",
		},
		grp_anims = commonanims.male.grp_anims,

		anims = commonanims.male.default_anims_unarmed,
		anims_1h = commonanims.male.default_anims_1h,
		anims_2h = commonanims.male.default_anims_2h,
		animMap = AGENT_ANIMS,

		symbol = "character",
		anim = "idle",
		shouldFlip = true,
		scale = 0.25,
		layer = Layer.Unit,
		boundType = BoundType.Character,
		boundTypeOverrides = {
			{anim="idle_ko" ,boundType= BoundType.CharacterFloor},
			{anim="dead" ,boundType= BoundType.CharacterFloor},
		},
		peekBranchSet = 1,
	},

	kanim_MM_mole_light =
	{
		wireframe =
		{
			"data/anims/characters/agents/agent_male_empty.abld",
		},
		build =
		{
			"data/anims/characters/anims_female/shared_female_hits_01.abld",
			"data/anims/characters/anims_female/shared_female_attacks_a_01.abld",
			"data/anims/characters/agents/lady_mole_light.abld",
		},
		grp_build =
		{
			"data/anims/characters/agents/grp_lady_mole_light.abld",
		},
		grp_anims = commonanims.female.grp_anims,

		anims = commonanims.female.default_anims_unarmed,
		anims_1h = commonanims.female.default_anims_1h,
		anims_2h = commonanims.female.default_anims_2h,

		animMap = AGENT_ANIMS,

		symbol = "character",
		anim = "idle",
		shouldFlip = true,
		scale = 0.25,
		layer = Layer.Unit,
		boundType = BoundType.Character,
		boundTypeOverrides = {
			{anim="idle_ko" ,boundType= BoundType.CharacterFloor},
			{anim="dead" ,boundType= BoundType.CharacterFloor},
		},
		peekBranchSet =  2,
	},

	kanim_MM_mole_dark =
	{
		wireframe =
		{
			"data/anims/characters/agents/agent_male_empty.abld",
		},
		build =
		{
			"data/anims/characters/anims_female/shared_female_hits_01.abld",
			"data/anims/characters/anims_female/shared_female_attacks_a_01.abld",
			"data/anims/characters/agents/lady_mole_dark.abld",
		},
		grp_build =
		{
			"data/anims/characters/agents/grp_lady_mole_dark.abld",
		},
		grp_anims = commonanims.female.grp_anims,

		anims = commonanims.female.default_anims_unarmed,
		anims_1h = commonanims.female.default_anims_1h,
		anims_2h = commonanims.female.default_anims_2h,

		animMap = AGENT_ANIMS,

		symbol = "character",
		anim = "idle",
		shouldFlip = true,
		scale = 0.25,
		layer = Layer.Unit,
		boundType = BoundType.Character,
		boundTypeOverrides = {
			{anim="idle_ko" ,boundType= BoundType.CharacterFloor},
			{anim="dead" ,boundType= BoundType.CharacterFloor},
		},
		peekBranchSet =  2,
	},

	kanim_transparent =
	{
		wireframe =
		{
			"data/anims/characters/agents/agent_male_empty.abld",
		},
		build =
		{
			"data/anims/characters/agents/agent_male_empty.abld",
			"data/anims/characters/anims_male/shared_hits_01.abld",
			"data/anims/characters/anims_male/shared_attacks_a_01.abld",
		},
		grp_build =
		{
			"data/anims/characters/agents/grp_MM_agent009.abld",
		},
		grp_anims = commonanims.male.grp_anims,

		anims = commonanims.male.default_anims_unarmed,
		anims_1h = commonanims.male.default_anims_1h,
		anims_2h = commonanims.male.default_anims_2h,
		animMap = AGENT_ANIMS,

		symbol = "character",
		anim = "idle",
		shouldFlip = true,
		scale = 0.25,
		layer = Layer.Unit,
		boundType = BoundType.Character,
		boundTypeOverrides = {
			{anim="idle_ko" ,boundType= BoundType.CharacterFloor},
			{anim="dead" ,boundType= BoundType.CharacterFloor},
		},
		peekBranchSet = 1,
	},

	kanim_MM_hologrenade_tall =
	{
		build = "data/anims/fx/MM_hologrenade_tall.abld",
		anims = { "data/anims/fx/hologrenade_cart.adef" },
		symbol = "character",
		shouldFlip = true,
		scale = 0.3,
		layer = Layer.Object,
		boundType = BoundType.bound_1x1_med_med,
		filterSymbols = {{symbol="outline",filter="default"},{symbol="tile_outline",filter="default"},{symbol="teal",filter="default"},{symbol="red",filter="default"},{symbol="Highlight",filter="default"}},
	},

	kanim_MM_drone_refit =
	{
		build =
		{
			-- "data/anims/characters/enemy/sankaku_droid_proto.abld",
			"data/anims/characters/agents/MM_refit_drone_friend.abld",
		},
		anims =
		{
			"data/anims/characters/corp_SK/sankaku_droid_camera.adef",
		},
		anims_1h =
		{
			"data/anims/characters/corp_SK/sankaku_droid_camera.adef",
		},
		anims_2h =
		{
			"data/anims/characters/corp_SK/sankaku_droid_camera.adef",
		},
		symbol = "character",
		anim = "idle",
		shouldFlip = true,
		scale = 0.20,
		layer = Layer.Unit,
		boundType = BoundType.Character,
		boundTypeOverrides = {
			{anim="idle_closed" ,boundType= BoundType.CharacterFloor},
			{anim="dead" ,boundType= BoundType.CharacterFloor},
		},
		-- animMap = FLOAT_DRONE_ANIMS,
		filterSymbols = {{symbol="scan",filter="default"},{symbol="camera_ol_line",filter="default"}},
		animMap = util.extend( FLOAT_DRONE_ANIMS )
		{
			-- idle_ko = "idle_closed",
			cover = "idle",
			-- pin = "idle",

			-- walk_pre = "move_pre",
			-- cover_run = "move_pre",
			-- walk = "move",
			-- walk180 = "move",
			-- snk = "move",
			-- run = "move",
			-- walk_pst = "move_pst",
			-- run_pst = "move_pst",
			-- snk_pst = "move_pst",
			-- pin_pre = "idle",

			-- shoot1 = "idle",
			-- shoot2 = "idle",
			-- shoot3 = "idle",
			-- overwatch_pre = "idle",
			-- overwatch = "idle",
			-- pinshoot_pre = "idle",
			-- pinshoot = "idle",
			-- pinshoot_pst = "idle",
			-- pin_stand = "idle",
			-- tinker = "idle",
			-- tinker_loop = "idle",
			-- tinker_pst = "idle",
			-- hitfrt = "hit",
			-- hitbck = "hit",
			-- hitfrt_pst = "hit",
			-- hitbck_pst = "hit",
			cover_pre = "idle",
			lean_pre = "idle",
			lean = "idle",
			lean_pst = "idle",
			hide_pre = "idle",
			hide = "idle",
			hide_pst = "idle",

			use_comp = "idle",

			hide_peek_pre_L = "idle",
			hide_peek_pre_R = "idle",
			hide_peek = "idle",
			peek_L = "idle",
			peek_R = "idle",
			hide_peek_pst_L = "idle",
			hide_peek_pst_R = "idle",

			door_peek_pre = "idle",
			door_peek_pst = "idle",
			peek_fwrd = "idle",
			peek_bwrd = "idle",
			peek_pst_fwrd = "idle",
			peek_pst_bwrd = "idle",
			lean_peek_pre_R = "idle",
			lean_peek_pre_L = "idle",
			lean_peek_R = "idle",
			lean_peek_L = "idle",
			lean_peek_pst_R = "idle",
			lean_peek_pst_L = "idle",

			overwatchcrouch_melee_idle = "idle",
			overwatch_melee_pre = "idle",
			overwatch_melee = "idle",

			-- hide_throw_L = "idle",
			-- hide_throw_R = "idle",
			-- hide_throw_pst_L = "idle",
			-- hide_throw_pst_R = "idle",

			-- throw = "idle",
			-- throw_pst = "idle",

			-- lean_throw_L = "idle",
			-- lean_throw_R = "idle",
			-- lean_throw_pst_L = "idle",
			-- lean_throw_pst_R = "idle",

			-- pick_up = "idle",
			use_door = "idle",
			use_door_pst = "idle",

			-- hide_reload = "idle",
			-- lean_reload = "idle",
			-- reload = "idle",

			-- revive = "idle",

			-- shrug = "idle",
		},

	},

	kanim_MM_workshop_grafter =
	{
		build = "data/anims/props/MM_workshop_augmenter.abld",
		anims = { "data/anims/Unique_cybernetics/cybernetics_1x1_augmenter.adef" },
		symbol = "character",
		scale = 0.25,
		layer = Layer.Decor,
		boundType = BoundType.bound_1x1_med_big,
		filterSymbols = {{symbol="glow",filter="default"},{symbol="Highlight",filter="default"},{symbol="red",filter="default"},{symbol="teal",filter="default"}},
	},
}

return animdefs
