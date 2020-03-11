local util = include( "modules/util" )
local commondefs = include( "sim/unitdefs/commondefs" )
local simdefs = include("sim/simdefs")
local speechdefs = include("sim/speechdefs")
local SCRIPTS = include('client/story_scripts')
local DEFAULT_DRONE = commondefs.DEFAULT_DRONE
local SOUNDS = commondefs.SOUNDS

local agent_templates =
{
	--NPCs
	agent_009 =
	{
		type = "simunit",
		name = STRINGS.MOREMISSIONS.AGENTS.AGENT_009.NAME,
		fullname = STRINGS.MOREMISSIONS.AGENTS.AGENT_009.NAME,
		yearsOfService = STRINGS.AGENTS.PRISONER.YEARS_OF_SERVICE,
		age = STRINGS.AGENTS.PRISONER.AGE,
		hometown = STRINGS.AGENTS.PRISONER.HOMETOWN,
		toolTip = STRINGS.AGENTS.PRISONER.ALT_1.TOOLTIP, --placeholder
		onWorldTooltip = commondefs.onAgentTooltip,
		profile_icon_36x36= "gui/profile_icons/prisoner_64.png",
		splash_image = "gui/agents/agentDeckard_768.png",
		profile_anim = "portraits/portrait_animation_template",
		profile_build = "portraits/executive_build", --PLACEHOLDER		
		kanim = "kanim_sharpshooter_male_a", --PLACEHOLDER
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
}

return agent_templates