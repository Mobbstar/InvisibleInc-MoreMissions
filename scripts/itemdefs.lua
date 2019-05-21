local util = include( "modules/util" )
local commondefs = include( "sim/unitdefs/commondefs" )
-- local simdefs = include( "sim/simdefs" )

local tool_templates =
{
	item_laptop_holo = util.extend(commondefs.item_template)
	{
		name = STRINGS.MOREMISSIONS.ITEMS.LAPTOP_HOLO,
		desc = STRINGS.MOREMISSIONS.ITEMS.LAPTOP_HOLO_TIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.LAPTOP_HOLO_FLAVOR,
		icon = "console.png",
		--profile_icon = "gui/items/icon-laptop.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_laptop_small.png",	
		profile_icon_100 = "gui/icons/item_icons/icon-item_laptop.png",
		kanim = "kanim_laptop",
		sounds = {
			spot="SpySociety/Objects/computer_types",
			deploy="SpySociety/Objects/SuitcaseComputer_open",
			pickUp="SpySociety/Objects/SuitcaseComputer_close",
			activate="SpySociety/Actions/holocover_activate",
			deactivate="SpySociety/Actions/holocover_deactivate",
			activeSpot="SpySociety/Actions/holocover_run_LP",
			bounce="SpySociety/Grenades/bounce",
		},
		rig = "consolerig", --???
		requirements = { hacking = 3 },
		abilities = {"deployable", "generateCPU", "carryable"},
		traits = {
			laptop=true,
			mainframe_icon_on_deploy=true,
			mainframe_status = "active",
			sightable = true,
			cpus = 1,
			maxcpus = 1,
			cpuTurn = 1,
			cpuTurnMax = 1,
			hidesInCover = true,
			cooldown = 0,
			cooldownMax = 2,
		},
		value = 1000,
		-- floorWeight = 2,
		locator = true,
	},
	
	item_hologrenade_hd = util.extend( commondefs.grenade_template )
	{
		name = STRINGS.MOREMISSIONS.ITEMS.HOLOGRENADE_HD,
		desc = STRINGS.MOREMISSIONS.ITEMS.HOLOGRENADE_HD_TIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.HOLOGRENADE_HD_FLAVOR,
		--icon = "itemrigs/FloorProp_Bandages.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_holo_grenade_small.png",	
		profile_icon_100 = "gui/icons/item_icons/icon-item_holo_grenade.png",	
		kanim = "kanim_hologrenade",
		sounds = {
			activate="SpySociety/Actions/holocover_activate",
			deactivate="SpySociety/Actions/holocover_deactivate",
			activeSpot="SpySociety/Actions/holocover_run_LP",
			bounce="SpySociety/Grenades/bounce",
		},
		abilities = { "recharge","carryable", "throw" },
		traits = {
			cooldown = 0,
			cooldownMax = 1,
			cover=false,
			holoProjector=true,
			disposable = false,
			agent_filter=true,
			deploy_cover=true,
		},	
		value = 800,
		-- floorWeight = 2, 		
		locator=true,
	},
	
	item_disguise_charged = util.extend(commondefs.item_template)
	{
		type = "item_disguise",
		name = STRINGS.MOREMISSIONS.ITEMS.DISGUISE_CHARGED,
		desc = STRINGS.MOREMISSIONS.ITEMS.DISGUISE_CHARGED_TIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.DISGUISE_CHARGED_FLAVOR,
		icon = "itemrigs/disk.png",		
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_holomesh_Prism.png",
    	profile_icon_100 = "gui/icons/item_icons/icon-item_holomesh_Prism.png",		
    	abilities = { "carryable" , "disguise" },
    	traits = {
			scan_vulnerable=true,
			drop_dropdisguise=true,
		},	
    	value = 1000,
	},	
}

return tool_templates