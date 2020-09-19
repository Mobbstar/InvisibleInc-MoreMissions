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

	-- for Distress Call
	MM_item_tazer_old = util.extend(commondefs.melee_template)
	{
		name =  STRINGS.MOREMISSIONS.ITEMS.ITEM_TAZER_OLD,
		desc = STRINGS.ITEMS.TAZER_1_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.ITEM_TAZER_OLD_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_tazer_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_tazer.png",		
		--profile_icon = "gui/items/icon-tazer-ftm.png",
		requirements = {  },
		traits = { damage = 1,  cooldown = 0, cooldownMax = 4, melee = true, level = 1 },
		value = 100,
		floorWeight = 1,
	},	
	
	MM_item_tazer_old_armour = util.extend(commondefs.melee_template)
	{
		name =  STRINGS.MOREMISSIONS.ITEMS.ITEM_TAZER_OLD,
		desc = STRINGS.ITEMS.TAZER_1_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.ITEM_TAZER_OLD_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_tazer_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_tazer.png",		
		--profile_icon = "gui/items/icon-tazer-ftm.png",
		requirements = {  },
		traits = { damage = 1,  cooldown = 0, cooldownMax = 4, armorPiercing = 1, melee = true, level = 1 },
		value = 150,
		floorWeight = 1,
	},		

	-- for EA Hostage
	MM_item_discarded_manacles = util.extend(commondefs.item_template)
	{
		name = STRINGS.MOREMISSIONS.ITEMS.DISCARDED_MANACLES,
		desc = STRINGS.MOREMISSIONS.ITEMS.DISCARDED_MANACLES_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.DISCARDED_MANACLES_FLAVOR,
		icon = "itemrigs/FloorProp_Mag_braces.png",
		profile_icon = "gui/items/item_quest.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_exit_key.png",
		traits = { sightable = true }
	},	
	
}

-- TECH EXPO block which autogenerates items from existing templates
local tech_expo_templates = {}

function generateTechExpoGear()

	util.tclear(tech_expo_templates)
	
	local itemdefs = include("sim/unitdefs/itemdefs")
	local itemList = util.tcopy(itemdefs)
	for k,v in pairs(itemList) do
		-- if ((v.floorWeight or 0) > 1 )
		-- and ((v.value or 0) > 800) -- tier 3 weapons and up
		if ((v.floorWeight or 0) > 1 )
		and ((v.value or 0) >= 700)		 --will include tier 2 weapons and up
		and (v.traits.damage or v.traits.baseDamage) and (v.traits.weaponType or v.traits.melee) then
			tech_expo_templates["MM_"..k.."_techexpo"] = v			
		end
	end
	
	-- log:write("LOG tech expo templates")
	-- log:write(util.stringize(tech_expo_templates,3))
	
	for i,itemdef in pairs(tech_expo_templates) do --upgrade traits
		local traits = itemdef.traits
		if traits.damage and not traits.lethalMelee then --NIAA compatibility
			traits.damage = traits.damage + 1
		end
		if traits.baseDamage and not traits.lethalMelee then --NIAA compatibility
			traits.baseDamage = traits.baseDamage + 1
		end
		if traits.pwrCost and (traits.pwrCost > 1) then
			traits.pwrCost = traits.pwrCost - 1
		end
		if traits.ammo and traits.maxAmmo then
			traits.ammo = traits.ammo + 1
			traits.maxAmmo = traits.maxAmmo + 1
		end
		if traits.charges and traits.chargesMax then
			traits.charges = traits.charges + 1
			traits.chargesMax = traits.chargesMax + 1
		end
		if traits.armorPiercing and not traits.canSleep then
			traits.armorPiercing = traits.armorPiercing + 1 --may be too powerful? restrict to lethal weapons for now, since the 'basedamage' increase does nothing for them anyway when all guards have 1 hitpoint
		end
		if traits.cooldownMax and ((traits.cooldownMax or 0) > 1) then
			traits.cooldownMax = traits.cooldownMax - 1
		end
		
		itemdef.requirements = itemdef.requirements or {}
		local strength_req = 2
		if traits.value and (traits.value > 800) then --higher STR req for items based off stuff tier 3 and up
			strength_req = 3
		end
		itemdef.requirements.inventory = strength_req
		
		if itemdef.value then
			itemdef.value = itemdef.value/2
		end
		
		itemdef.notSoldAfter = 0
		if itemdef.floorWeight then
			itemdef.floorWeight = nil
		end

		traits.MM_tech_expo_item = true
		
		-- Fix Biogenic Dart's hardcoded cooldown cooltip
		if itemdef.desc == STRINGS.ITEMS.DART_GUN_BIO_TOOLTIP then
			local desc = "Recharges every {1} turns."
			local new_desc = util.sformat(desc,traits.cooldownMax)
			itemdef.desc = new_desc			
		end
		
		itemdef.name = "Improved " .. itemdef.name
		itemdef.flavor = itemdef.flavor .. "\n\nThis model is an advanced prototype."
	end

end

local final_templates = {}
function ResetItemdefs()
	util.tclear(final_templates)
	util.tmerge(final_templates, tool_templates)
	util.tmerge(final_templates, tech_expo_templates)
end

generateTechExpoGear()
ResetItemdefs()

-- log:write("LOG final templates")
-- log:write(util.stringize(final_templates,3))

return final_templates

