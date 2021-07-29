local util = include( "modules/util" )
local simdefs = include("sim/simdefs")
local commondefs = include("sim/unitdefs/commondefs")
local itemdefs = include("sim/unitdefs/itemdefs")
local speechdefs = include( "sim/speechdefs" )

---------------------------------------------------------------------------------------------------------
-- NPC templates

local SOUNDS = commondefs.SOUNDS

local DEFAULT_IDLES = commondefs.DEFAULT_IDLES

local DEFAULT_ABILITIES = commondefs.DEFAULT_ABILITIES

local onGuardTooltip = commondefs.onGuardTooltip

local DEFAULT_DRONE = commondefs.DEFAULT_DRONE

local SHARP_SOUNDS =
{
    bio = "SpySociety/VoiceOver/Missions/Bios/Sharp",
    escapeVo = "SpySociety/VoiceOver/Missions/Escape/Operator_Escape_Agent_Sharp",
	speech="SpySociety/Agents/dialogue_player",  
	step = simdefs.SOUNDPATH_FOOTSTEP_MALE_HARDWOOD_NORMAL, 
	stealthStep = simdefs.SOUNDPATH_FOOTSTEP_MALE_HARDWOOD_SOFT,

	wallcover = "SpySociety/Movement/foley_cyborg/wallcover", 
	crouchcover = "SpySociety/Movement/foley_cyborg/crouchcover",
	fall = "SpySociety/Movement/foley_cyborg/fall",	
	land = "SpySociety/Movement/deathfall_agent_hardwood",
	land_frame = 35,	
	getup = "SpySociety/Movement/foley_cyborg/getup",
	grab = "SpySociety/Movement/foley_cyborg/grab_guard",
	pin = "SpySociety/Movement/foley_cyborg/pin_guard",
	pinned = "SpySociety/Movement/foley_cyborg/pinned",
	peek_fwd = "SpySociety/Movement/foley_cyborg/peek_forward",	
	peek_bwd = "SpySociety/Movement/foley_cyborg/peek_back",
	move = "SpySociety/Movement/foley_cyborg/move",						
	hit = "SpySociety/HitResponse/hitby_ballistic_cyborg",
}

local android_traits = util.extend( commondefs.basic_agent_traits )
{
	canBeCritical = false,
	woundsMax = 1, 
	isGuard = true,
    cleanup = true, 	
	-- cashOnHand = 80,
	LOSrange = 8,
	LOSarc = math.pi / 4,
	LOSperipheralRange = 10,
	LOSperipheralArc = math.pi / 2,
	closedoors = true,

	patrolObserved = nil, 
	observablePatrol = true,
	noLoopOverwatch = true,
}

local npc_templates =
{

	-- ASSASSINATION
	npc_bounty_target =
	{
		type = "simunit",
		name = STRINGS.MOREMISSIONS.GUARDS.BOUNTY_TARGET,
		profile_anim = "portraits/portrait_animation_template",
		profile_build = "portraits/mm_ceotarget_face",
		profile_image = "executive.png",
		onWorldTooltip = onGuardTooltip,
		kanim = "kanim_mm_ceotarget",
		traits = util.extend( commondefs.basic_guard_traits )   
		{
			walk=true,
			heartMonitor = "enabled",
			enforcer = false,
			dashSoundRange = 8,
			cashOnHand = 200,
			ko_trigger = "intimidate_guard",
			kill_trigger = "guard_dead",
			vip = true, --This flag is important for the panic behaviour
			pacifist = true,
			recap_icon = "executive",
			MM_bounty_target = true,
			MM_alertlink = true,
		},
		dropTable =
		{
			{ "item_adrenaline", 10},
			{nil,100}
		},
		anarchyDropTable =
		{
			{ "item_laptop", 5},
		    { "item_stim", 5},
			{nil,100}
		},		
		speech = speechdefs.NPC,
		voices = {"Executive"},
		skills = {},
		abilities = {"shootOverwatch", "overwatch", "consciousness_monitor_passive"},
		children = {},
		idles = DEFAULT_IDLES,
		sounds = SOUNDS.GUARD,
		brain = "mmBountyTargetBrain",
	},
	
	npc_bounty_target_fake = --DECOY! when attacked, stolen from, EMP'd or alerted, will be replaced with MM_bounty_target_android
	{
		type = "simunit",
		name = STRINGS.MOREMISSIONS.GUARDS.BOUNTY_TARGET,
		profile_anim = "portraits/portrait_animation_template",
		profile_build = "portraits/mm_ceotarget_face",
		profile_image = "executive.png",
		onWorldTooltip = onGuardTooltip,
		kanim = "kanim_mm_ceotarget",
		traits = util.extend( commondefs.basic_guard_traits )   
		{
			walk=true,
			heartMonitor = "enabled",
			enforcer = false,
			dashSoundRange = 8,
			cashOnHand = 0,
			-- PWROnHand = 2,
			ko_trigger = "intimidate_guard",
			kill_trigger = "guard_dead",
			vip = true, --This flag is important for the panic behaviour
			pacifist = true,
			recap_icon = "executive",
			MM_bounty_target = true,
			MM_alertlink = true,
			mm_fixnopatrolfacing = true,
			mm_nopatrolchange = true,
		},
		dropTable = 
		{
			{nil, 100}
		},		
		speech = speechdefs.NPC,
		voices = {"Executive"},
		skills = {},
		abilities = {"shootOverwatch", "overwatch", "consciousness_monitor_passive"},
		children = {},
		idles = DEFAULT_IDLES,
		sounds = SOUNDS.GUARD,
		brain = "mmBountyTargetBrain",
	},	
	
	MM_bounty_target_android =
	{
		type = "simdrone",
		name = STRINGS.MOREMISSIONS.GUARDS.HOLOGRAM_DROID or "Hologram Android",
		profile_anim = "portraits/portrait_animation_template",
		profile_build = "portraits/MM_bot_pink_face",	
		profile_image = "enforcer_2.png",
		profile_icon_36x36= "gui/profile_icons/security_36.png",
    	onWorldTooltip = onGuardTooltip,
		kanim = "kanim_MM_android",
		traits = util.extend( android_traits )   
		{
			-- walk=true,
			heartMonitor="disabled",
			kill_trigger = "guard_dead",
			enforcer = false,
			dashSoundRange = 8, 
			sightable = true,
			empKO = 2,
			empDeath = true,
			-- cashOnHand = 0,
			PWROnHand = 2,
			controlTimer = 0, 
			controlTimerMax = 1, 
			hits = "spark",
			isMetal = true,
			LOSrange = 8,
			LOSarc = math.pi / 4,
			LOSperipheralRange = 10,
			LOSperipheralArc = math.pi / 2,
			mainframe_item = true,
			mainframe_ice = 2,
			mainframe_iceMax = 4,
			mainframe_status = "active",
			mainframe_no_recapture = true,
			canKO = false,
			isDrone = true,
			closedoors = false,
			pacifist = true,

			
		},
		speech = speechdefs.NPC,
		voices = {"Drone"},
		skills = {},
		abilities = util.extend(DEFAULT_ABILITIES){},
		children = { },
		sounds = SHARP_SOUNDS, --sneaky clue
		brain = "PacifistBrain",
		dropTable = 
		{
			{ "item_hologrenade", 15 },
			{ "item_icebreaker_2", 13 },
			{ "item_icebreaker_3", 5 },
			{nil, 67}
		},			
	},		
	
	MM_bodyguard =
	{
		type = "simunit",
		name = STRINGS.MOREMISSIONS.GUARDS.BODYGUARD,
		profile_anim = "portraits/portrait_animation_template",
		profile_build = "portraits/mm_bodyguard_face",	
		profile_image = "enforcer_2.png",
		profile_icon_36x36= "gui/profile_icons/security_36.png",
    	onWorldTooltip = onGuardTooltip,
		kanim = "kanim_mm_bodyguard",
		traits = util.extend( commondefs.basic_guard_traits )   
		{
			walk=true,
			heartMonitor="enabled",
			kill_trigger = "guard_dead",
			enforcer = false,
			dashSoundRange = 8, 
			sightable = true,
			woundsMax = 2,
			MM_bodyguard = true,
			MM_alertlink = true,
		},
		speech = speechdefs.NPC,
		voices = {"KO_Heavy"},
		skills = {},
		abilities = util.extend(DEFAULT_ABILITIES){"consciousness_monitor_passive"}, --minimise differences between bodyguard and target for the sake of the disguise mechanic
		children = { itemdefs.item_npc_pistol },
		sounds = SOUNDS.GUARD,
		brain = "GuardBrain",		
	},
	
	-- for TECH EXPO
	MM_prototype_droid =
	{
		type = "simdrone",--"simunit", --simdrone, surprisingly, works well
		name = STRINGS.MOREMISSIONS.GUARDS.PROTOTYPE_DROID or "Prototype Android",
		profile_anim = "portraits/portrait_animation_template",
		profile_build = "portraits/MM_bot_pink_face",	
		profile_image = "enforcer_2.png",
		profile_icon_36x36= "gui/profile_icons/security_36.png",
    	onWorldTooltip = onGuardTooltip,
		kanim = "kanim_MM_android",
		traits = util.extend( android_traits )   
		{
			-- walk=true,
			heartMonitor="disabled",
			kill_trigger = "guard_dead",
			enforcer = false,
			dashSoundRange = 8, 
			sightable = true,
			scanSweeps = true,
			empKO = 4, -- 4 ticks KO when EMP'd.
			--empDeath = true,
			-- cashOnHand = 0,
			PWROnHand = 3, --you'd expect PWR to be lootable but it leads to a weird issue where you have to click on it twice to lookt it \o/
			controlTimer = 0, 
			controlTimerMax = 1, 
			hits = "spark",
			isMetal = true,
			LOSarc = 3*math.pi/4,
			LOSrange = 6,
			LOSperipheralRange = 6,
			LOSperipheralArc = 3*math.pi/4, --if this is 0 then yellow cover tiles aren't displayed properly
			lookaroundArc = 3*math.pi/4,
			mainframe_item = true,
			mainframe_ice = 2,
			mainframe_iceMax = 4,
			mainframe_status = "active",
			mainframe_no_recapture = true,
			canKO = false,
			isDrone = true,
			closedoors = false,

			
		},
		speech = speechdefs.NPC,
		voices = {"Drone"},--nil, --{"KO_Heavy"},
		skills = {},
		abilities = util.extend(DEFAULT_ABILITIES){},
		children = { itemdefs.item_npc_smg },
		sounds = SHARP_SOUNDS, --SOUNDS.GUARD,
		brain = "GuardBrain",
		dropTable = 
		{
			{ "item_icebreaker", 25 },
			{ "item_icebreaker_2", 5 },
			{ "item_icebreaker_3", 3 },
			{nil, 67}
		},			
	},		
	
	MM_prototype_droid_spec =
	{
		type = "simdrone",--"simunit", 
		rig = "dronerig",
		name = STRINGS.MOREMISSIONS.GUARDS.PROTOTYPE_DROID_SPEC or "Prototype Android",
		profile_anim = "portraits/portrait_animation_template",
		profile_build = "portraits/MM_bot_purple_face",
		profile_image = "enforcer_2.png",
		profile_icon_36x36= "gui/profile_icons/security_36.png",
    	onWorldTooltip = onGuardTooltip,
		kanim = "kanim_MM_android_elite", 
		traits = util.extend( android_traits )   
		{
			-- walk=true,
			MM_nullFX = true, --for unitrig
			heartMonitor="disabled",
			kill_trigger = "guard_dead",
			enforcer = false,
			dashSoundRange = 8, 
			sightable = true,
			scanSweeps = true,
			empKO = 4, -- 4 ticks KO when EMP'd.
			empDeath = true,
			PWROnHand = 4,
			-- cashOnHand = 0,		
			controlTimer = 0, 
			controlTimerMax = 1, 
			hits = "spark",
			isMetal = true,
			mainframe_item = true,
			mainframe_ice = 4,
			mainframe_iceMax = 4,
			mainframe_status = "active",
			canKO = false,	
			LOSrange = 2.5,
			LOSarc = 2 * math.pi,
			LOSperipheralArc =  2 * math.pi,
			LOSperipheralRange = 3,
            lookaroundArc = 2 * math.pi,
            lookaroundOffset = math.pi / 8,		
			mainframe_no_daemon_spawn = false,
			mainframe_always_daemon_spawn = true,
			mainframe_no_recapture = true,	
			magnetic_reinforcement = true,			
			pulseScan = true,
			range =5,
			lookaroundRange = 1,
			armor = 1,
			isDrone = true,
			pulse_sound = "SpySociety_DLC001/Actions/scandrone_scan",
			-- relayInterest = true,
			-- recap_icon = "sankaku_drone_null2",	
			closedoors = false,			
		},
		speech = speechdefs.NPC,
		voices = {"Drone"},--nil, --{"KO_Heavy"},
		skills = {},
		abilities = util.extend(DEFAULT_ABILITIES){},
		children = { itemdefs.item_npc_smg },
		sounds = SHARP_SOUNDS, --SOUNDS.GUARD,
		brain = "GuardBrain",
		dropTable = 
		{
			{ "item_icebreaker", 25 },
			{ "item_icebreaker_2", 5 },
			{ "item_icebreaker_3", 3 },
			{nil, 67}
		},		
	},	

	MM_scientist = -- scientist dupe for Tech Expo, in case player has DLC installed but not enabled
	{
		type = "simunit",
		name = STRINGS.MOREMISSIONS.GUARDS.SCIENTIST,
		profile_anim = "portraits/portrait_animation_template",
		profile_build = "portraits/lab_tech_build",	
		profile_image = "lab_tech.png",
    	onWorldTooltip = onGuardTooltip,
		kanim = "kanim_scientist",
		traits = util.extend( commondefs.basic_guard_traits )   
		{
			walk=true,
			heartMonitor="enabled",
			enforcer = false,
			dashSoundRange = 8,
			cashOnHand = 0, 
			ko_trigger = "intimidate_guard",
			kill_trigger = "guard_dead",
			vip=true,
            pacifist = true,
            scientist = true,
            recap_icon = "lab_tech",	
		},
		dropTable =
		{	-- and since we're here, might as well add some special loot?
			{ "MM_augment_skill_chip_speed", 5},
			{ "MM_augment_skill_chip_hacking", 5},
			{ "MM_augment_skill_chip_strength", 5},
			{ "MM_augment_skill_chip_anarchy", 5},
			{ "MM_augment_titanium_rods", 5},
			{ "MM_augment_piercing_scanner", 5},
			{ "MM_augment_penetration_scanner", 5},
			{nil,100}
		},
		anarchyDropTable =
		{
			{ "item_laptop",5},
		    { "item_stim",5},
			{nil,150}
		},		
		speech = speechdefs.NPC,
		voices = {"Executive"},
		skills = {},
		abilities = { },
		children = { },
		idles = DEFAULT_IDLES,
		sounds = SOUNDS.GUARD,
		brain = "WimpBrain",		
	},
	
	
}

return npc_templates
