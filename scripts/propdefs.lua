local util = include( "modules/util" )
local simdefs = include( "sim/simdefs" )
local commondefs = include("sim/unitdefs/commondefs")
local itemdefs = include("sim/unitdefs/itemdefs")
local tool_templates = include("sim/unitdefs/itemdefs")

-------------------------------------------------------------
--

local MAINFRAME_TRAITS = commondefs.MAINFRAME_TRAITS
local SAFE_TRAITS = commondefs.SAFE_TRAITS

local onMainframeTooltip = commondefs.onMainframeTooltip
local onSoundBugTooltip = commondefs.onSoundBugTooltip
local onBeamTooltip = commondefs.onBeamTooltip
local onConsoleTooltip = commondefs.onConsoleTooltip
local onStoreTooltip = commondefs.onStoreTooltip
local onDeviceTooltip = commondefs.onDeviceTooltip
local onSafeTooltip = commondefs.onSafeTooltip

-- local onSampleTooltip = function( tooltip, unit )
	-- tooltip:addLine( unit:getName() )
	-- tooltip:addAbility( STRINGS.ABILITIES.RESCUE, STRINGS.ABILITIES.RESCUE_HOSTAGE_DESC, "gui/items/icon-action_open-safe.png",nil,true )
-- end,

local prop_templates =
{
	-----------------------------------------------------
	-- Level Props
	
	-- upgradestudio_speed = 
	-- {
		-- type = "simunit", 
		-- name = STRINGS.ISTANBUL4.PROPS.UPGRADESTUDIO_SPEED,
		-- onWorldTooltip = onDeviceTooltip,
		-- rig ="corerig",
		-- kanim = "kanim_switch", 
		-- abilities = { "useUpgradeMachine" }, 
		-- -- children = {  },
		-- -- tags = {  }, --for Central flavourtext and instructions
		-- traits = util.extend( MAINFRAME_TRAITS ){
			-- moveToDevice = true,
			-- cover = true,
			-- impass = {0,0},
			-- sightable = true,
			-- skill = "speed",
			-- -- isObjective = true,
			-- -- multiLockSwitch = true,
			-- -- noOpenAnim = true,
			-- -- canKO = false,
			-- -- mainframe_status = "inactive", -- So that it activates on spawn.
			-- -- startOn = true,
			-- -- mainframe_autodeactivate = true, 
			-- -- spotSoundPowerDown = true,
			-- -- agent_filter = true,
			-- -- activate_txt_title=STRINGS.DLC1.OPEN_SECURITY_DOOR,
			-- -- activate_txt_body=STRINGS.DLC1.OPEN_SECURITY_DOOR_DESC
			-- -- cell_door = true
			-- recap_icon = "access_switch",
		-- },
		-- sounds = {
			-- appeared="SpySociety/HUD/gameplay/peek_positive", --peek_negative
			-- spot="SpySociety_DLC001/Objects/router",
			-- use="SpySociety/Actions/console_use",	
			-- reboot_start="SpySociety/Actions/reboot_initiated_generator",
			-- reboot_end="SpySociety/Actions/reboot_complete_generator",
			-- switch_reset="SpySociety_DLC001/Actions/DLCswitch_reset",
			-- computer_reset="SpySociety_DLC001/Actions/DLCswitch_computerreset",
		-- }
	-- },
	
	--custom one so no overlap
	MM_hostage_capture_ea = 
	{ 
		type = "simunit", 
		name = STRINGS.PROPS.HOSTAGE,
		rig = "hostagerig",	
		onWorldTooltip = function( tooltip, unit )
			tooltip:addLine( unit:getName() )
			tooltip:addAbility( STRINGS.ABILITIES.RESCUE, STRINGS.ABILITIES.RESCUE_HOSTAGE_DESC, "gui/items/icon-action_open-safe.png",nil,true )
		end,
		tags = { "MM_hostage" },
		kanim = "kanim_hostage", --this will be custom

		traits = { impass = {0,0}, rescue_incident = "hostage_rescued", template="MM_hostage",  mp=5, mpMax =5, sightable = true, MM_hostage = true, untie_anim = true,  vitalSigns = 2, agent_filter= true }, 
		abilities = { "hostage_rescuable" },
		sounds = {appeared="SpySociety/HUD/gameplay/peek_positive", }
	},	
	
	-- WEAPONS EXPO

	-- in mission script, pick kanim at random from the 3 available on spawn
	MM_prototype_droid_prop = 
	{ 
		type = "simunit", 
		name = STRINGS.MOREMISSIONS.GUARDS.PROTOTYPE_DROID, --"Android Prototype"
		rig = "unitrig",
		tooltip = nil,
		tags = {"MM_droid_dummy"},
		kanim = "mm_kanim_guard_male_dummy1", 
		traits = { impass = {0,0}, sightable = true, cover = true, staticAnim  = true, MM_droid_dummy = true},
		sounds = {appeared="SpySociety/HUD/gameplay/peek_positive", },
	},
	
	MM_prototype_specdroid_prop = 
	{ 
		type = "simunit", 
		name = STRINGS.MOREMISSIONS.GUARDS.PROTOTYPE_DROID, --"Android Prototype"
		rig = "unitrig",
		tooltip = nil,
		tags = {"MM_droid_dummy"},
		kanim = "mm_kanim_guard_male_dummy2", 
		traits = { impass = {0,0}, sightable = true, cover = true, staticAnim  = true, MM_droid_dummy = true, spec_droid = true},
		sounds = {appeared="SpySociety/HUD/gameplay/peek_positive", },
	},	
	
	MM_portal_turret =
	{
		type = "simunit",
		name = STRINGS.PROPS.TURRET,
		tooltip = nil,
		nolocator = true,
		profile_anim = "portraits/turret_portrait",
		kanim = "kanim_MM_portal_turret", --give custom, pick random in mission
		rig = "turretrig",
		-- facing = simdefs.DIR_E,		
		traits = {sightable = true, impass = {0,0}, cover = true,},
		abilities = {},
		children = { },
	},
	
	--this looks like a custom turret but can't be activated
	MM_turret_prop =
	{
		type = "simunit",
		name = STRINGS.PROPS.TURRET,
		tooltip = nil,
		nolocator = true,
		profile_anim = "portraits/turret_portrait",
		kanim = "kanim_MM_prototype_turret", --give custom, pick random in mission
		rig = "turretrig",
		-- facing = simdefs.DIR_E,		
		traits = {sightable = true, impass = {0,0}, cover = true,},
		abilities = {},
		children = { },
	},

	MM_drone_prop = 
	{ 
		type = "simunit", 
		name = STRINGS.PROPS.CAPTURED_AGENT, --"Drone"
		rig = "unitrig",
		tooltip = nil,
		kanim = "kanim_MM_prototype_drone", --give custom!
		traits = { impass = {0,0}, sightable = true, cover = true,},
	},
	
	--need custom one that looks distinct from side mission switch
	MM_lock_switch = 
	{
		type = "simunit", 
		name = STRINGS.DLC1.PROPS.LOCK_SWITCH,
		rig ="corerig",
		onWorldTooltip = onDeviceTooltip,
		kanim = "kanim_switch", 
		abilities = { "multiUnlock"  }, 
		traits = util.extend( MAINFRAME_TRAITS ){ 
			moveToDevice=true, 
			cover = true, 
			impass = {0,0}, 
			sightable=true,
			multiLockSwitch = true, 
			recap_icon = "access_switch",
			mainframe_no_daemon_spawn = false,
			mainframe_always_daemon_spawn = true, --we don't want it to be too easy :^)	
			},
			--multilockswitch is used in unitrig for FX
			--MM_multilock trait is used in script and set in prefab file, NOT here in propdef
		sounds = {appeared="SpySociety/HUD/gameplay/peek_positive", reboot_start="SpySociety/Actions/reboot_initiated_generator",reboot_end="SpySociety/Actions/reboot_complete_generator", switch_reset="SpySociety_DLC001/Actions/DLCswitch_reset", computer_reset="SpySociety_DLC001/Actions/DLCswitch_computerreset" }
	},	

	
	MM_vault_safe_1 = 
	{ 
		type = "simunit", 
		name = STRINGS.PROPS.SECURE_CASE,
		onWorldTooltip = onSafeTooltip,
		kanim = "kanim_MM_gunsafe_1", 
		rig ="corerig",
		tags = {"MM_topGear"},
		traits = util.extend( SAFE_TRAITS, MAINFRAME_TRAITS ) {moveToDevice=true, MM_emp_safe = true, mainframe_ice = 2, mainframe_iceMax = 2,},
		abilities = { "stealCredits" },
		sounds = {appeared="SpySociety/HUD/gameplay/peek_positive",reboot_start="SpySociety/Actions/reboot_initiated_safe",reboot_end="SpySociety/Actions/reboot_complete_safe" },
		-- children = {"item_valuable_tech"},
	},	

	MM_vault_safe_2 = 
	{ 
		type = "simunit", 
		name = STRINGS.PROPS.SECURE_CASE,
		onWorldTooltip = onSafeTooltip,
		kanim = "kanim_MM_gunsafe_2", 
		rig ="corerig",
		tags = {"MM_topGear"},
		traits = util.extend( SAFE_TRAITS, MAINFRAME_TRAITS ) {moveToDevice=true, MM_emp_safe = true, mainframe_ice = 2, mainframe_iceMax = 2,},
		abilities = { "stealCredits" },
		sounds = {appeared="SpySociety/HUD/gameplay/peek_positive",reboot_start="SpySociety/Actions/reboot_initiated_safe",reboot_end="SpySociety/Actions/reboot_complete_safe" },
		-- children = {"item_valuable_tech"},
	},		
	
	MM_vault_safe_3 = 
	{ 
		type = "simunit", 
		name = STRINGS.PROPS.SECURE_CASE,
		onWorldTooltip = onSafeTooltip,
		kanim = "kanim_MM_gunsafe_3", 
		rig ="corerig",
		tags = {"MM_topGear"},
		traits = util.extend( SAFE_TRAITS, MAINFRAME_TRAITS ) {moveToDevice=true, MM_emp_safe = true, mainframe_ice = 2, mainframe_iceMax = 2,},
		abilities = { "stealCredits" },
		sounds = {appeared="SpySociety/HUD/gameplay/peek_positive",reboot_start="SpySociety/Actions/reboot_initiated_safe",reboot_end="SpySociety/Actions/reboot_complete_safe" },
		-- children = {"item_valuable_tech"},
	},		
	
	MM_cell_door = 
	{
		type = "simunit", 
		name =  "Exhibit Case",--STRINGS.PROPS.CELL_DOOR,
		rig ="corerig",
		onWorldTooltip = function( tooltip, unit )
			tooltip:addLine( unit:getName() )
		end,
		kanim = "kanim_celldoor1", 
		traits = {  impass = {0,0}, sightable=true, cell_door=true },
		sounds = { }
	},		
		
}


-- Reassign key name to value table.
for id, template in pairs(prop_templates) do
	template.id = id
end

return prop_templates
