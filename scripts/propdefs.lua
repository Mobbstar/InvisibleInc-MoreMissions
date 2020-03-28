local util = include( "modules/util" )
local simdefs = include( "sim/simdefs" )
local commondefs = include("sim/unitdefs/commondefs")
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

}

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

-- Reassign key name to value table.
for id, template in pairs(prop_templates) do
	template.id = id
end

return prop_templates
