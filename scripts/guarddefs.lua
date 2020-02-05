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


local npc_templates =
{

	npc_bounty_target =
	{
		type = "simunit",
		name = STRINGS.MOREMISSIONS.GUARDS.BOUNTY_TARGET,
		profile_anim = "portraits/portrait_animation_template",
		profile_build = "portraits/lab_tech_build",	
		profile_image = "lab_tech.png",
    	onWorldTooltip = onGuardTooltip,
		kanim = "kanim_scientist",
		traits = util.extend( commondefs.basic_guard_traits )   
		{
			walk=true,
			heartMonitor = "enabled",
			enforcer = false,
			dashSoundRange = 8,
			-- cashOnHand = 0, 
			ko_trigger = "intimidate_guard",
			kill_trigger = "guard_dead",
			vip = true, --This flag is important for the panic behaviour
            pacifist = true,
            recap_icon = "lab_tech",
			bounty = 1200,
			corpseTemplate = { --reward for dead currently needs to be set explicitly -M
				traits = {
					bounty = 1200,
				},
			}
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
		abilities = {"consciousness_monitor_passive"},
		children = {},
		idles = DEFAULT_IDLES,
		sounds = SOUNDS.GUARD,
		brain = "WimpBrain",		
	},

}

return npc_templates
