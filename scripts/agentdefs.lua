local util = include( "modules/util" )
local commondefs = include( "sim/unitdefs/commondefs" )
local simdefs = include("sim/simdefs")
local speechdefs = include("sim/speechdefs")
local SCRIPTS = include('client/story_scripts')
local DEFAULT_DRONE = commondefs.DEFAULT_DRONE
local SOUNDS = commondefs.SOUNDS


local INTERNATIONALE_SOUNDS =
{
    bio = "SpySociety/VoiceOver/Missions/Bios/Internationale",
    escapeVo = "SpySociety/VoiceOver/Missions/Escape/Operator_Escape_Agent_Internationale",
	speech="SpySociety/Agents/dialogue_player",  
	step = simdefs.SOUNDPATH_FOOTSTEP_FEMALE_HARDWOOD_NORMAL, 
	stealthStep = simdefs.SOUNDPATH_FOOTSTEP_FEMALE_HARDWOOD_SOFT,

	wallcover = "SpySociety/Movement/foley_suit/wallcover", 
	crouchcover = "SpySociety/Movement/foley_suit/crouchcover",
	fall = "SpySociety/Movement/foley_suit/fall",
	land = "SpySociety/Movement/deathfall_agent_hardwood",
	land_frame = 16,						
	getup = "SpySociety/Movement/foley_suit/getup",
	grab = "SpySociety/Movement/foley_suit/grab_guard",
	pin = "SpySociety/Movement/foley_suit/pin_guard",
	pinned = "SpySociety/Movement/foley_suit/pinned",
	peek_fwd = "SpySociety/Movement/foley_suit/peek_forward",	
	peek_bwd = "SpySociety/Movement/foley_suit/peek_back",
	move = "SpySociety/Movement/foley_suit/move",		
	hit = "SpySociety/HitResponse/hitby_ballistic_flesh",		
}

local INFORMANT_ABILITIES = 
{
"jackin", "peek", "escape", "disarmtrap" , "observePath", "moveBody", "lastWords","sprint","MM_escape_guardelevator","MM_escape_guardelevator2",
}

local agent_templates =
{
	--NPCs
	MM_agent_009 =
	{
		type = "simunit",
		name = STRINGS.MOREMISSIONS.AGENTS.AGENT_009.NAME,
		fullname = STRINGS.MOREMISSIONS.AGENTS.AGENT_009.NAME,
		yearsOfService = STRINGS.AGENTS.PRISONER.YEARS_OF_SERVICE,
		age = STRINGS.AGENTS.PRISONER.AGE,
		hometown = STRINGS.AGENTS.PRISONER.HOMETOWN,
		toolTip = STRINGS.MOREMISSIONS.AGENTS.AGENT_009.TOOLTIP,
		onWorldTooltip = commondefs.onAgentTooltip,
		profile_icon_36x36= "gui/icons/agent_icons/MM_agent009_36.png",
		splash_image = "gui/agents/agentDeckard_768.png",
		profile_anim = "portraits/portrait_animation_template",
		profile_build = "portraits/MM_agent009_face", --PLACEHOLDER		
		kanim = "kanim_MM_agent009",
		gender = "male",
		traits = util.extend( commondefs.DEFAULT_AGENT_TRAITS ) { cant_abandon = true, mp=9, mpMax=9, rescued=true, leavesAtEndOfMission= true},	
		children = {}, -- Dont add items here, add them to the upgrades table in createDefaultAgency()
		abilities = util.tconcat( {  "sprint",  }, commondefs.DEFAULT_AGENT_ABILITIES ),-- "stealth"
		skills = util.extend( commondefs.DEFAULT_AGENT_SKILLS ) {}, 
		startingSkills = { stealth = 2 },
		sounds = { 	
					speech="SpySociety/Agents/dialogue_player",  
					step = simdefs.SOUNDPATH_FOOTSTEP_MALE_HARDWOOD_NORMAL, 
					stealthStep = simdefs.SOUNDPATH_FOOTSTEP_MALE_HARDWOOD_SOFT,
					
					wallcover = "SpySociety/Movement/foley_suit/wallcover",
					crouchcover = "SpySociety/Movement/foley_suit/crouchcover",
					fall = "SpySociety/Movement/foley_suit/fall",	
					land = "SpySociety/Movement/deathfall_agent_hardwood",
					land_frame = 35,						
					getup = "SpySociety/Movement/foley_suit/getup",
					grab = "SpySociety/Movement/foley_suit/grab_guard",
					pin = "SpySociety/Movement/foley_suit/pin_guard",
					pinned = "SpySociety/Movement/foley_suit/pinned",	
					peek_fwd = "SpySociety/Movement/foley_suit/peek_forward",	
					peek_bwd = "SpySociety/Movement/foley_suit/peek_back",				
					move = "SpySociety/Movement/foley_suit/move",
				},--
		speech = STRINGS.MOREMISSIONS.AGENTS.AGENT_009.BANTER,
		blurb = "",
	},
	
	MM_hostage =
	{
		type = "simunit",
		name = STRINGS.MOREMISSIONS.AGENTS.EA_HOSTAGE.NAME,
		fullname = STRINGS.AGENTS.HOSTAGE.ALT_1.FULLNAME,
		yearsOfService = STRINGS.AGENTS.HOSTAGE.YEARS_OF_SERVICE,
		age = STRINGS.AGENTS.HOSTAGE.AGE,
		homeTown = STRINGS.AGENTS.HOSTAGE.HOMETOWN,
		toolTip = STRINGS.AGENTS.HOSTAGE.ALT_1.TOOLTIP,
		onWorldTooltip = commondefs.onAgentTooltip,
		profile_icon_36x36= "gui/profile_icons/courrier_36.png",
		splash_image = "gui/agents/agentDeckard_768.png",
		profile_anim = "portraits/courier_face",
		kanim = "kanim_courier_male",
		gender = "male",
		tags = {"MM_hostage"},
		traits = util.extend( commondefs.DEFAULT_AGENT_TRAITS ) { inventoryMaxSize = 1, mp=5, mpMax =5, noUpgrade = true, MM_hostage = true, kill_trigger = "hostage_dead", vitalSigns=10, rescued=true, canBeCritical=false,leavesAtEndOfMission=true },	
		children = {}, -- Dont add items here, add them to the upgrades table in createDefaultAgency()
		abilities =  commondefs.DEFAULT_AGENT_ABILITIES ,
		sounds = { 
					speech="SpySociety/Agents/dialogue_player",  
					step = simdefs.SOUNDPATH_FOOTSTEP_MALE_HARDWOOD_NORMAL, 
					stealthStep = simdefs.SOUNDPATH_FOOTSTEP_MALE_HARDWOOD_SOFT,
					
					wallcover = "SpySociety/Movement/foley_suit/wallcover",
					crouchcover = "SpySociety/Movement/foleyfoley_suit_trench/crouchcover",
					fall = "SpySociety/Movement/foley_suit/fall",	
					land = "SpySociety/Movement/deathfall_agent_hardwood",
					land_frame = 35,						
					getup = "SpySociety/Movement/foley_suit/getup",
					grab = "SpySociety/Movement/foley_suit/grab_guard",
					pin = "SpySociety/Movement/foley_suit/pin_guard",
					pinned = "SpySociety/Movement/foley_suit/pinned",	
					peek_fwd = "SpySociety/Movement/foley_suit/peek_forward",	
					peek_bwd = "SpySociety/Movement/foley_suit/peek_back",				
					move = "SpySociety/Movement/foley_suit/move",
				},--
		speech = STRINGS.MOREMISSIONS_HOSTAGE.EA_HOSTAGE.BANTER,
		blurb = "",
	},	

	--NPCs
	MM_mole =		
	{
		type = "simunit",
		agentID = "MM_mole", --for item's restrictedUse
		name = STRINGS.MOREMISSIONS.AGENTS.MOLE.NAME,
		fullname = STRINGS.MOREMISSIONS.AGENTS.MOLE.FULLNAME,
		yearsOfService = STRINGS.AGENTS.PRISONER.YEARS_OF_SERVICE,
		age = STRINGS.AGENTS.PRISONER.AGE,
		hometown = STRINGS.AGENTS.PRISONER.HOMETOWN,
		toolTip = STRINGS.MOREMISSIONS.AGENTS.MOLE.TOOLTIP,
		onWorldTooltip = commondefs.onAgentTooltip,
		profile_icon_36x36= "gui/icons/agent_icons/MM_mole_dark_36.png",
		profile_icon_64x64= "gui/profile_icons/engineer2_64x64.png",
		splash_image = "gui/agents/central_1024.png",
		profile_build = "portraits/lady_mole_face_dark",
		profile_anim = "portraits/dracul_build",
		gender = "female",
		team_select_img = {
			"gui/agents/team_select_1_central.png",
		},
		kanim = "kanim_MM_mole_dark",
		traits = util.extend( commondefs.DEFAULT_AGENT_TRAITS ) { MM_mole = true, cant_abandon = true, mp=7,  mpMax = 7, leavesAtEndOfMission= true, augmentMaxSize = 0, canBeCritical = false, inventoryMaxSize = 2, },	
		tags = {"MM_mole","Informant"},
		children = { "MM_mole_cloak", "MM_paralyzer_amnesiac"},
		startingSkills = {},
		abilities = INFORMANT_ABILITIES,
		sounds = INTERNATIONALE_SOUNDS,
		speech = STRINGS.MOREMISSIONS.AGENTS.MOLE.BANTER,
		blurb = "",
		upgrades = { },
	},	

	MM_mole2 =		-- different kanim/portrait
	{
		type = "simunit",
		agentID = "MM_mole", --for item's restrictedUse
		name = STRINGS.MOREMISSIONS.AGENTS.MOLE.NAME,
		fullname = STRINGS.MOREMISSIONS.AGENTS.MOLE.FULLNAME,
		yearsOfService = STRINGS.AGENTS.PRISONER.YEARS_OF_SERVICE,
		age = STRINGS.AGENTS.PRISONER.AGE,
		hometown = STRINGS.AGENTS.PRISONER.HOMETOWN,
		toolTip = STRINGS.MOREMISSIONS.AGENTS.MOLE.TOOLTIP,
		onWorldTooltip = commondefs.onAgentTooltip,
		profile_icon_36x36= "gui/icons/agent_icons/MM_mole_light_36.png",
		profile_icon_64x64= "gui/profile_icons/engineer2_64x64.png",
		splash_image = "gui/agents/central_1024.png",
		profile_build = "portraits/lady_mole_face_light",
		profile_anim = "portraits/dracul_build",
		gender = "female",
		team_select_img = {
			"gui/agents/team_select_1_central.png",
		},
		kanim = "kanim_MM_mole_light",
		traits = util.extend( commondefs.DEFAULT_AGENT_TRAITS ) { MM_mole = true, cant_abandon = true, mp=7,  mpMax = 7, leavesAtEndOfMission= true, augmentMaxSize = 0, canBeCritical = false, inventoryMaxSize = 2, },	
		tags = {"MM_mole","Informant"},
		children = { "MM_mole_cloak", "MM_paralyzer_amnesiac"},
		startingSkills = {},
		abilities = INFORMANT_ABILITIES,
		sounds = INTERNATIONALE_SOUNDS,
		speech = STRINGS.MOREMISSIONS.AGENTS.MOLE.BANTER,
		blurb = "",
		upgrades = { },
	},		
	
}

return agent_templates
