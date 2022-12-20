local util = include( "modules/util" )
local commondefs = include( "sim/unitdefs/commondefs" )
-- local simdefs = include( "sim/simdefs" )
local NEVER_SOLD = 10000

local function onCloakTooltip( tooltip, unit, userUnit )
    local cdefs = include( "client_defs" )
    local simquery = include( "sim/simquery" )
    commondefs.item_template.onTooltip( tooltip, unit, userUnit )
    if userUnit and unit:getSim() then
        local x0, y0 = userUnit:getLocation()
        tooltip:addRange( unit:getTraits().range, x0, y0, cdefs.HILITE_TARGET_COLOR )

        local hiliteUnits = {}
		local cells = simquery.fillCircle( unit:getSim(), x0, y0, unit:getTraits().range, 0)
		for i, cell in ipairs(cells) do
			for i, cellUnit in ipairs( cell.units ) do
				if cellUnit:getTraits().isAgent and cellUnit:getPlayerOwner() and (cellUnit:getPlayerOwner() == userUnit:getPlayerOwner()) then
                    table.insert( hiliteUnits, cellUnit:getID() )
				end
			end
		end
        tooltip:addUnitHilites( hiliteUnits )
    end
end

local tool_templates =
{
	-- item_laptop_holo = util.extend(commondefs.item_template)
	-- {
		-- name = STRINGS.MOREMISSIONS.ITEMS.LAPTOP_HOLO,
		-- desc = STRINGS.MOREMISSIONS.ITEMS.LAPTOP_HOLO_TIP,
		-- flavor = STRINGS.MOREMISSIONS.ITEMS.LAPTOP_HOLO_FLAVOR,
		-- icon = "console.png",
		-- --profile_icon = "gui/items/icon-laptop.png",
		-- profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_laptop_small.png",
		-- profile_icon_100 = "gui/icons/item_icons/icon-item_laptop.png",
		-- kanim = "kanim_laptop",
		-- sounds = {
			-- spot="SpySociety/Objects/computer_types",
			-- deploy="SpySociety/Objects/SuitcaseComputer_open",
			-- pickUp="SpySociety/Objects/SuitcaseComputer_close",
			-- activate="SpySociety/Actions/holocover_activate",
			-- deactivate="SpySociety/Actions/holocover_deactivate",
			-- activeSpot="SpySociety/Actions/holocover_run_LP",
			-- bounce="SpySociety/Grenades/bounce",
		-- },
		-- rig = "consolerig", --???
		-- requirements = { hacking = 3 },
		-- abilities = {"deployable", "generateCPU", "carryable"},
		-- traits = {
			-- laptop=true,
			-- mainframe_icon_on_deploy=true,
			-- mainframe_status = "active",
			-- sightable = true,
			-- cpus = 1,
			-- maxcpus = 1,
			-- cpuTurn = 1,
			-- cpuTurnMax = 1,
			-- hidesInCover = true,
			-- cooldown = 0,
			-- cooldownMax = 2,
		-- },
		-- value = 1000,
		-- -- floorWeight = 2,
		-- locator = true,
	-- },

	-- item_hologrenade_hd = util.extend( commondefs.grenade_template )
	-- {
		-- name = STRINGS.MOREMISSIONS.ITEMS.HOLOGRENADE_HD,
		-- desc = STRINGS.MOREMISSIONS.ITEMS.HOLOGRENADE_HD_TIP,
		-- flavor = STRINGS.MOREMISSIONS.ITEMS.HOLOGRENADE_HD_FLAVOR,
		-- --icon = "itemrigs/FloorProp_Bandages.png",
		-- profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_holo_grenade_small.png",
		-- profile_icon_100 = "gui/icons/item_icons/icon-item_holo_grenade.png",
		-- kanim = "kanim_hologrenade",
		-- sounds = {
			-- activate="SpySociety/Actions/holocover_activate",
			-- deactivate="SpySociety/Actions/holocover_deactivate",
			-- activeSpot="SpySociety/Actions/holocover_run_LP",
			-- bounce="SpySociety/Grenades/bounce",
		-- },
		-- abilities = { "recharge","carryable", "throw" },
		-- traits = {
			-- cooldown = 0,
			-- cooldownMax = 1,
			-- cover=false,
			-- holoProjector=true,
			-- disposable = false,
			-- agent_filter=true,
			-- deploy_cover=true,
			-- usesLeft = 5,
		-- },
		-- value = 800,
		-- -- floorWeight = 2,
		-- locator=true,
		-- createUpgradeParams = function( self, unit )
			-- return { traits = { usesLeft = unit:getTraits().usesLeft } }
		-- end
	-- },

	-- item_disguise_charged = util.extend(commondefs.item_template)
	-- {
		-- type = "item_disguise",
		-- name = STRINGS.MOREMISSIONS.ITEMS.DISGUISE_CHARGED,
		-- desc = STRINGS.MOREMISSIONS.ITEMS.DISGUISE_CHARGED_TIP,
		-- flavor = STRINGS.MOREMISSIONS.ITEMS.DISGUISE_CHARGED_FLAVOR,
		-- icon = "itemrigs/disk.png",
		-- profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_holomesh_Prism.png",
    	-- profile_icon_100 = "gui/icons/item_icons/icon-item_holomesh_Prism.png",
    	-- abilities = { "carryable" , "disguise" },
    	-- traits = {
			-- scan_vulnerable=true,
			-- drop_dropdisguise=true,
		-- },
    	-- value = 1000,
	-- },
	
	-- copy of item_npc_smg_drone with fixed shoot sound
	MM_item_npc_smg_android = util.extend( commondefs.npc_weapon_template )
	{
		name = STRINGS.ITEMS.SMG,
		desc = STRINGS.ITEMS.SMG_TOOLTIP,
		flavor = STRINGS.ITEMS.SMG_FLAVOR,
		icon = "itemrigs/FloorProp_SMG.png",		
		--profile_icon = "gui/items/item_smg-56.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_gun_SMG_small.png",	
		profile_icon_100 = "gui/icons/item_icons/icon-item_gun_SMG.png",	
		equipped_icon = "gui/items/equipped_smg.png",
		traits = { weaponType="smg", baseDamage = 4,  armorPiercing = 2},
		sounds = { reload="SpySociety/Weapons/LowBore/reload_smg", use="SpySociety/Actions/item_pickup", shoot="SpySociety/Weapons/LowBore/shoot_handgun"},
		weapon_anim = "kanim_light_smg",
		agent_anim = "anims_2h",
	},
	-- for Distress Call
	MM_item_tazer_old = util.extend(commondefs.melee_template)
	{
		name =  STRINGS.MOREMISSIONS.ITEMS.ITEM_TAZER_OLD,
		desc = STRINGS.ITEMS.TAZER_1_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.ITEM_TAZER_OLD_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_tazer_old_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_tazer_old.png",
		--profile_icon = "gui/items/icon-tazer-ftm.png",
		requirements = {  },
		traits = { damage = 1,  cooldown = 0, cooldownMax = 4, melee = true, level = 1, usesLeft = 5, },
		value = 100,
		floorWeight = 1,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end,
	},

	MM_item_tazer_old_armour = util.extend(commondefs.melee_template)
	{
		name =  STRINGS.MOREMISSIONS.ITEMS.ITEM_TAZER_OLD,
		desc = STRINGS.ITEMS.TAZER_1_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.ITEM_TAZER_OLD_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_tazer_old_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_tazer_old.png",
		--profile_icon = "gui/items/icon-tazer-ftm.png",
		requirements = {  },
		traits = { damage = 1,  cooldown = 0, cooldownMax = 4, armorPiercing = 1, melee = true, level = 1, usesLeft = 5, },
		value = 150,
		floorWeight = 1,
        createUpgradeParams = function( self, unit )
            return { traits = { usesLeft = unit:getTraits().usesLeft } }
        end,
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

	-- for Mole Insertion
    MM_paralyzer_amnesiac = util.extend(commondefs.item_template)
	{
		name = STRINGS.MOREMISSIONS.ITEMS.AMNESIAC,
		desc = STRINGS.MOREMISSIONS.ITEMS.AMNESIAC_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.AMNESIAC_FLAVOR,
		icon = "itemrigs/FloorProp_Bandages.png",
		--profile_icon = "gui/items/icon-paralyzer.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_paralyzerdose_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_paralyzer_dose.png",
		abilities = { "carryable","recharge","paralyze" },
		requirements = { },
		traits = { cooldown = 0, cooldownMax = 6, koTime = 0, impare_sight = 2, amnesiac = true, usesLeft = 5, }, --impare_sight is used by Function Library
		value = 300,
		floorWeight = 1,
        createUpgradeParams = function( self, unit )
            return { traits = { usesLeft = unit:getTraits().usesLeft } }
        end,
		soldAfter = NEVER_SOLD,
	},

	-- MM_mole_cloak = util.extend(commondefs.item_template) --MOVED TO PROPS
	-- {
	-- },

	-- for rebalanced Compile Room sidemission
	MM_compiler_USB = util.extend(commondefs.item_template)
	{
		name = STRINGS.MOREMISSIONS.ITEMS.USB_DRIVE,
		desc = STRINGS.MOREMISSIONS.ITEMS.USB_DRIVE_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.USB_DRIVE_FLAVOR,
		icon = "itemrigs/FloorProp_DataDisc.png",		
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_compile_key_USB_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_compile_key_USB.png",
		abilities = { "carryable","MM_installprogram" },
		traits = {MM_installedProgram = "lockpick_1", disposable = true,}, 
		value = 500,
       createUpgradeParams = function( self, unit )
            return { traits = { MM_installedProgram = unit:getTraits().MM_installedProgram } }
        end,		
	},
	
	-- TECH EXPO NON-WEAPONS: manually-created rather than procedurally
	-- Powerful, limited-use items!
	--MM_tech_expo_item trait added in tech_expo_itemdefs.lua

	MM_techexpo_fraggrenade = util.extend( commondefs.grenade_template)
	{
        type = "MM_simfraggrenade",
		name = STRINGS.MOREMISSIONS.ITEMS.GRENADE_FRAG,
		desc = STRINGS.MOREMISSIONS.ITEMS.GRENADE_FRAG_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.GRENADE_FRAG_FLAVOR,
		icon = "itemrigs/Crybaby.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_frag_grenade_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_frag_grenade.png",
		kanim = "kanim_flashgrenade",
		sounds = {explode="SpySociety/Grenades/flashbang_explo", bounce="SpySociety/Grenades/bounce"},
		traits = { baseDamage = 2, range=2, explodes = 0, MM_tech_expo_nonweapon = true, friendlyDamage = true, destroysDevices = true, MM_tech_expo_item = true, disposable = true,}, --lethal damage
		abilities = { "carryable", "throw", },
		value = 600,
		locator=true,	
	},

	MM_techexpo_frag_smoke_grenade = util.extend( commondefs.grenade_template)
	{
        type = "MM_simfraggrenade",
		name = STRINGS.MOREMISSIONS.ITEMS.SMOKE_FRAG_GRENADE,
		desc = STRINGS.MOREMISSIONS.ITEMS.SMOKE_FRAG_GRENADE_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.SMOKE_FRAG_GRENADE_FLAVOR,
		icon = "itemrigs/Crybaby.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_frag_grenade_smoke_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_frag_grenade_smoke.png",
		kanim = "kanim_flashgrenade",
		sounds = {explode="SpySociety/Grenades/flashbang_explo", bounce="SpySociety/Grenades/bounce"},
		traits = { baseDamage = 2, range=2, explodes = 0, disposable = true, MM_tech_expo_nonweapon = true, friendlyDamage = true, destroysDevices = true, MM_tech_expo_item = true, createsSmoke = true, on_spawn = "MM_smoke_cloud_frag", }, --lethal damage
		value = 600,
		locator=true,
		abilities = { "carryable", "throw", },
	},

	MM_techexpo_smokegrenade = util.extend( commondefs.grenade_template )
	{
        type = "smoke_grenade",
		name = STRINGS.MOREMISSIONS.ITEMS.SMOKE_GRENADE_CLASSIC,
		desc = STRINGS.MOREMISSIONS.ITEMS.SMOKE_GRENADE_CLASSIC_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.SMOKE_GRENADE_CLASSIC_FLAVOR,
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_smoke_grenade_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_smoke_grenade.png",
		kanim = "kanim_stickycam",
		sounds = {explode="SpySociety/Grenades/smokegrenade_explo", bounce="SpySociety/Grenades/bounce_smokegrenade"},
		traits = { on_spawn = "MM_smoke_cloud" , range=6, noghost = true, explodes = 0, usesLeft = 5, disposable = false, MM_tech_expo_nonweapon = true, MM_tech_expo_item = true, throwUnit = "MM_techexpo_smokegrenade", noReload = true, ammo = 3, maxAmmo = 3,},
		value = 300,
		locator=true,
		abilities = { "carryable", "throw","recharge" },
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},

	MM_techexpo_cloakingrig = util.extend(commondefs.item_template)
	{ --"Fragile Cloaking Zone Rig"
		name = STRINGS.MOREMISSIONS.ITEMS.CLOAK_1,
		desc = STRINGS.MOREMISSIONS.ITEMS.CLOAK_1_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.CLOAK_1_FLAVOR,
		onTooltip = onCloakTooltip,
		icon = "itemrigs/FloorProp_InvisiCloakTimed.png",
		--profile_icon = "gui/items/icon-cloak.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_invisicloak_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_invisi_cloak.png",
		-- traits = { usesLeft = 5, duration = 2, cloakDistanceMax=1, cloakInVision = true, range = 2, MM_tech_expo_nonweapon = true, MM_tech_expo_item = true, cooldown = 0, cooldownMax = 6, },
		traits = { usesLeft = 5, duration = 2, cloakDistanceMax=1, cloakInVision = true, range = 2, cooldown = 0, cooldownMax = 6, }, --retire this item by removing it from tech expo spawn pool
		requirements = { stealth = 3 },
		abilities = { "carryable","useInvisiCloak","recharge", },
		value = 400,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},

	MM_techexpo_cloakingrig2 = util.extend(commondefs.item_template)
	{ --"Extended Cloaking Rig"
		name = STRINGS.MOREMISSIONS.ITEMS.CLOAK_2,
		desc = STRINGS.MOREMISSIONS.ITEMS.CLOAK_2_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.CLOAK_2_FLAVOR,
		icon = "itemrigs/FloorProp_InvisiCloakTimed.png",
		--profile_icon = "gui/items/icon-cloak.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_invisicloak_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_invisi_cloak.png",
		traits = { usesLeft = 5, duration = 3, cloakInVision = false, MM_tech_expo_nonweapon = true, pwrCost = 5, MM_tech_expo_item = true, cooldown = 0, cooldownMax = 6,},
		requirements = { stealth = 3 },
		abilities = { "carryable","useInvisiCloak","recharge" },
		value = 400,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},
	
	MM_techexpo_cloakingrig3 = util.extend(commondefs.item_template)
	{ --"Fortified Cloaking Rig"
		name = STRINGS.MOREMISSIONS.ITEMS.CLOAK_3,
		desc = STRINGS.MOREMISSIONS.ITEMS.CLOAK_3_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.CLOAK_3_FLAVOR,
		icon = "itemrigs/FloorProp_InvisiCloakTimed.png",
		--profile_icon = "gui/items/icon-cloak.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_invisicloak_strong_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_invisi_cloak_strong.png",
		traits = { usesLeft = 5, duration = 1, MM_tech_expo_nonweapon = true, MM_tech_expo_item = true, cooldown = 0, cooldownMax = 6, MM_attackproof_cloak = true, cloakInVision = true,},
		requirements = { stealth = 3 },
		abilities = { "carryable","useInvisiCloak","recharge" },
		value = 400,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},	

	MM_techexpo_icebreaker = util.extend(commondefs.item_template)
	{
		name = STRINGS.MOREMISSIONS.ITEMS.BUSTER,
		desc = STRINGS.MOREMISSIONS.ITEMS.BUSTER_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.BUSTER_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		--profile_icon = "gui/items/icon-action_crack-safe.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_chip_hyper_buster_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_chip_ice_breaker.png",
		traits = { icebreak = 8, usesLeft = 5, MM_tech_expo_nonweapon = true, killDaemon = true, MM_tech_expo_item = true, cooldown = 0, cooldownMax = 4, },
		requirements = { anarchy = 3, },
		abilities = { "icebreak","carryable","recharge" },
		value = 600,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},

	MM_techexpo_econchip = util.extend(commondefs.item_template)
	{
		name = STRINGS.MOREMISSIONS.ITEMS.ECON_CHIP,
		desc = STRINGS.MOREMISSIONS.ITEMS.ECON_CHIP_TOOLTIP,
		flavor = STRINGS.ITEMS.ECON_CHIP_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		--profile_icon = "gui/items/icon-action_crack-safe.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_chip_econ_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_chip_econ.png",
		traits = { PWR_conversion = 100, usesLeft = 5, MM_tech_expo_nonweapon = true, MM_tech_expo_item = true, cooldown = 0, cooldownMax = 3, },
		requirements = { stealth = 3, },
		abilities = { "carryable","jackin","recharge" },
		value = 800,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},

	MM_techexpo_stim = util.extend(commondefs.item_template)
	{
		name = STRINGS.MOREMISSIONS.ITEMS.STIM,
		desc = STRINGS.MOREMISSIONS.ITEMS.STIM_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.STIM_FLAVOR,
		icon = "itemrigs/FloorProp_Bandages.png",
		--profile_icon = "gui/items/icon-stims.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_stim_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_stim.png",
		traits = { mpRestored = 12, impair_agent_AP = 3, unlimitedAttacks = true, usesLeft = 5, MM_tech_expo_nonweapon = true, MM_tech_expo_item = true, cooldown = 0, cooldownMax = 4, armorPiercingBuff = 1, },
		requirements = { stealth = 3 },
		abilities = { "carryable","use_stim","recharge" },
		value = 1000,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},

	MM_techexpo_shocktrap = util.extend(commondefs.item_template)
	{
		name = STRINGS.MOREMISSIONS.ITEMS.SHOCK_TRAP,
		desc = STRINGS.MOREMISSIONS.ITEMS.SHOCK_TRAP_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.SHOCK_TRAP_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		--profile_icon = "gui/items/icon-shocktrap-.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_shocktrap_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_shock trap.png",
		traits = { damage = 5, stun = 5, range = 7, applyFn = "isClosedDoor", doorDevice = "simtrap", pwrCost = 3, usesLeft = 5, MM_tech_expo_nonweapon = true, MM_tech_expo_item = true, cooldown = 0, cooldownMax = 5, },
		requirements = { anarchy = 3 },
		abilities = { "doorMechanism","carryable","recharge" },
		value = 1000,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},

	MM_techexpo_shocktrap2 = util.extend(commondefs.item_template)
	{
		name = STRINGS.MOREMISSIONS.ITEMS.SHOCK_TRAP2,
		desc = STRINGS.MOREMISSIONS.ITEMS.SHOCK_TRAP2_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.SHOCK_TRAP2_FLAVOR,
		icon = "itemrigs/FloorProp_AmmoClip.png",
		--profile_icon = "gui/items/icon-shocktrap-.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_shocktrap_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_shock trap.png",
		traits = { damage = 3, stun = 3, range = 3, applyFn = "isClosedDoor", doorDevice = "simtrap", pwrCost = 2, usesLeft = 5, ignoreMagReinf = true, MM_tech_expo_nonweapon = true, MM_tech_expo_item = true, cooldown = 0, cooldownMax = 5, },
		requirements = { anarchy = 3 },
		abilities = { "doorMechanism","carryable","recharge" },
		value = 1000,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},

	MM_techexpo_emp_pack = util.extend(commondefs.item_template)
	{
		type = "MM_simemppack_pulse",
		name = STRINGS.MOREMISSIONS.ITEMS.EMP,
		desc = STRINGS.MOREMISSIONS.ITEMS.EMP_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.EMP_FLAVOR,
		icon = "itemrigs/FloorProp_emp.png",
		--profile_icon = "gui/items/icon-emp.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_emp_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_emp.png",
		abilities = { "carryable","prime_emp","recharge"},
		requirements = { hacking = 3 },
		traits = { range = 7, emp_duration = 4, usesLeft = 5, multiPulse = 3, MM_tech_expo_nonweapon = true, MM_tech_expo_item = true, cooldown = 0, cooldownMax = 6, },
		value = 1200,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},

	MM_techexpo_emp_pack2 = util.extend(commondefs.item_template)
	{
		type = "simemppack",
		name = STRINGS.MOREMISSIONS.ITEMS.EMP2,
		desc = STRINGS.MOREMISSIONS.ITEMS.EMP2_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.EMP2_FLAVOR,
		icon = "itemrigs/FloorProp_emp.png",
		--profile_icon = "gui/items/icon-emp.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_emp_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_emp.png",
		abilities = { "carryable","prime_emp","recharge" },
		requirements = { hacking = 3 },
		traits = { range = 3, emp_duration = 8, usesLeft = 5, ignoreMagReinf = true, MM_tech_expo_nonweapon = true, MM_tech_expo_item = true, cooldown = 0, cooldownMax = 6, },
		value = 1200,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},

	MM_techexpo_crybaby = util.extend( commondefs.grenade_template)
	{
		name = STRINGS.MOREMISSIONS.ITEMS.GRENADE_CRY_BABY,
		desc = STRINGS.MOREMISSIONS.ITEMS.GRENADE_CRY_BABY_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.GRENADE_CRY_BABY_FLAVOR,

		profile_icon = "gui/icons/item_icons/items_icon_small/icon-crybaby_small.png",
		profile_icon_100 = "gui/icons/item_icons/crybaby.png",
		kanim = "kanim_stickycam",
		abilities ={"carryable" , "throw","recharge"},
		sounds = {activate="SpySociety/Grenades/stickycam_deploy", bounce="SpySociety/Grenades/bounce", cry_baby="SpySociety_DLC001/Actions/crybaby_activate"},
		traits = { MM_tech_expo_nonweapon = true, MM_tech_expo_item = true, throwUnit = "MM_techexpo_crybaby_throwUnit", usesLeft = 5,range = 15,  disposable = false, targeting_ignoreLOS=true, removeAfter=true},
		value = 300,
		locator=true,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},

	MM_techexpo_crybaby_throwUnit = util.extend( commondefs.grenade_template)
	{
		name = STRINGS.MOREMISSIONS.ITEMS.GRENADE_CRY_BABY_DEAD,
		desc = STRINGS.MOREMISSIONS.ITEMS.GRENADE_CRY_BABY_DEAD_TOOLTIP,
		flavor = "",

		profile_icon = "gui/icons/item_icons/items_icon_small/icon-crybaby_small.png",
		profile_icon_100 = "gui/icons/item_icons/crybaby.png",
		kanim = "kanim_stickycam",
		uses_mainframe =
		{
			toggle =
			{
				name = STRINGS.MOREMISSIONS.ITEMS.GRENADE_CRY_BABY_USE,
				tooltip = STRINGS.MOREMISSIONS.ITEMS.GRENADE_CRY_BABY_USE_TIP,
				fn = "toggle" -- global script function
			}
		},
		abilities = {"throw"},
		sounds = {activate="SpySociety/Grenades/stickycam_deploy", bounce="SpySociety/Grenades/bounce", cry_baby="SpySociety_DLC001/Actions/crybaby_activate"},
		traits = { cryBaby=true, range=15, agent_filter=true, targeting_ignoreLOS = true, removeAfter=true},
		value = 300,
		locator=true,
	},

	MM_techexpo_flash_pack = util.extend(commondefs.item_template)
	{
		type = "simemppack",
		name = STRINGS.MOREMISSIONS.ITEMS.FLASH_PACK,
		desc = STRINGS.MOREMISSIONS.ITEMS.FLASH_PACK_TOOLTIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.FLASH_PACK_FLAVOR,

		icon = "itemrigs/FlashPack.png",
		--profile_icon = "gui/items/icon-emp.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_flashpack_small.png",
		profile_icon_100 = "gui/icons/item_icons/icon-item_flashpack.png",
		abilities = { "carryable","prime_emp","recharge" },
		requirements = { anarchy = 2 },
		uses_mainframe =
		{
			toggle =
			{
				name = STRINGS.MOREMISSIONS.ITEMS.FLASH_PACK_USE,
				tooltip = STRINGS.MOREMISSIONS.ITEMS.FLASH_PACK_USE_TIP,
				fn = "toggle", -- global script function
				canToggle = function(unit)
					if unit:getSim():getPC():getCpus() < 3 then
						return false, STRINGS.UI.REASON.NOT_ENOUGH_PWR
					end
					return true
				end
			}
		},
		traits = { range = 5, attackNeedsLOS=true, canSleep = true, baseDamage = 4, flash_pack = true, trigger_mainframe=true, MM_tech_expo_nonweapon = true, usesLeft = 5, MM_tech_expo_item = true, cooldown = 0, cooldownMax = 8,},
		value = 900,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},
	
	MM_techexpo_hologrenadeHD = util.extend( commondefs.grenade_template )
	{
		type = "MM_simfraggrenade", --this works, but need some kind of proximity disruption mechanic by guards who run up to it but can't pick it up because an agent is inside
		name = STRINGS.MOREMISSIONS.ITEMS.HOLOGRENADE_HD,
		desc = STRINGS.MOREMISSIONS.ITEMS.HOLOGRENADE_HD_TIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.HOLOGRENADE_HD_FLAVOR,
		--icon = "itemrigs/FloorProp_Bandages.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_holo_grenade_HD_small.png",	
		profile_icon_100 = "gui/icons/item_icons/icon-item_holo_grenade_HD.png",	
		kanim = "kanim_MM_hologrenade_tall",
		sounds = {activate="SpySociety/Actions/holocover_activate", deactivate="SpySociety/Actions/holocover_deactivate", activeSpot="SpySociety/Actions/holocover_run_LP", bounce="SpySociety/Grenades/bounce"},
		traits = { cooldown = 0, cooldownMax = 2, cover=false, holoProjector=true, disposable = false, agent_filter=true, deploy_cover=true, deploySightblock = true, MM_tech_expo_item = true, MM_tech_expo_nonweapon = true, usesLeft = 5,},	
		abilities = { "recharge","carryable", "throw" },
		value = 600,	
		locator=true,
		createUpgradeParams = function( self, unit )
			return { traits = { usesLeft = unit:getTraits().usesLeft } }
		end		
	},
	
	-- special scientist loot
	MM_augment_skill_chip_speed = util.extend( commondefs.augment_template )
	{
		name = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_SPEED,
		desc = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_SPEED_TIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_SPEED_FLAVOR,

		value = 400,
		traits = util.extend( commondefs.DEFAULT_AUGMENT_TRAITS ){
			modSkill = 1,
			modSkillStat = 4,
			modSkillLock = {1},
		},
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_generic_head_small2.png",
    	profile_icon_100 = "gui/icons/item_icons/icon-item_generic_head2.png",
	},

	MM_augment_skill_chip_hacking = util.extend( commondefs.augment_template )
	{
		name = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_HACKING,
		desc = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_HACKING_TIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_HACKING_FLAVOR,

		value = 400,
		traits = util.extend( commondefs.DEFAULT_AUGMENT_TRAITS ){
			modSkill = 2,
			modSkillStat = 4,
			modSkillLock = {2},
		},
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_generic_head_small2.png",
    	profile_icon_100 = "gui/icons/item_icons/icon-item_generic_head2.png",
	},

	MM_augment_skill_chip_strength = util.extend( commondefs.augment_template )
	{
		name = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_STRENGTH,
		desc = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_STRENGTH_TIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_STRENGTH_FLAVOR,

		value = 400,
		traits = util.extend( commondefs.DEFAULT_AUGMENT_TRAITS ){
			modSkill = 3,
			modSkillStat = 4,
			modSkillLock = {3},
		},
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_generic_head_small2.png",
    	profile_icon_100 = "gui/icons/item_icons/icon-item_generic_head2.png",
	},

	MM_augment_skill_chip_anarchy = util.extend( commondefs.augment_template )
	{
		name = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_ANARCHY,
		desc = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_ANARCHY_TIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.SKILL_CHIP_ANARCHY_FLAVOR,


		value = 400,
		traits = util.extend( commondefs.DEFAULT_AUGMENT_TRAITS ){
			modSkill = 4,
			modSkillStat = 4,
			modSkillLock = {4},
		},
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_generic_head_small2.png",
    	profile_icon_100 = "gui/icons/item_icons/icon-item_generic_head2.png",
	},

	MM_augment_titanium_rods = util.extend( commondefs.augment_template )
	{
		name = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.TITANIUM_RODS,
		desc = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.TITANIUM_RODS_TIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.TITANIUM_RODS_FLAVOR,
		traits = util.extend( commondefs.DEFAULT_AUGMENT_TRAITS ){
			modTrait = {{"meleeDamage",2}},
			stackable = true,
		},
		value = 400,
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_generic_arm_small.png",
    	profile_icon_100 = "gui/icons/item_icons/icon-item_generic_arm.png",
	},

	MM_augment_piercing_scanner = util.extend( commondefs.augment_template )
	{
		name = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.PIERCING_SCANNER,
		desc = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.PIERCING_SCANNER_TIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.PIERCING_SCANNER_FLAVOR,
		traits = util.extend( commondefs.DEFAULT_AUGMENT_TRAITS ){
			addArmorPiercingRanged = 2,
			stackable = true,
		},
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_generic_head_small.png",
    	profile_icon_100 = "gui/icons/item_icons/icon-item_generic_head.png",
	},

	MM_augment_penetration_scanner = util.extend( commondefs.augment_template )
	{
		name = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.PENETRATION_SCANNER,
		desc = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.PENETRATION_SCANNER_TIP,
		flavor = STRINGS.MOREMISSIONS.ITEMS.AUGMENTS.PENETRATION_SCANNER_FLAVOR,
		traits = util.extend( commondefs.DEFAULT_AUGMENT_TRAITS ){
			addArmorPiercingMelee = 2,
			stackable = true,
		},
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_generic_arm_small.png",
    	profile_icon_100 = "gui/icons/item_icons/icon-item_generic_arm.png",
	},
	
	--------NPC
	item_spiderdrone_zapgun = util.extend( commondefs.npc_weapon_template )
	{
		name = STRINGS.ITEMS.DRONE_TURRET,
		desc = STRINGS.ITEMS.DRONE_TURRET_TOOLTIP,
		flavor = STRINGS.ITEMS.DRONE_TURRET_FLAVOR,
		icon = "itemrigs/FloorProp_Pistol.png",		
		--profile_icon = "gui/items/item_pistol_56.png",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_gun_pistol_small.png",	
		profile_icon_100 = "gui/icons/item_icons/icon-item_gun_pistol.png",	
		equipped_icon = "gui/items/equipped_pistol.png",
		traits = { weaponType="pistol", baseDamage = 2, canSleep = true, },
		-- sounds = {shoot="SpySociety/Weapons/LowBore/shoot_handgun", reload="SpySociety/Weapons/LowBore/reload_handgun", use="SpySociety/Actions/item_pickup"},
		sounds = {shoot="SpySociety/HitResponse/hitby_tazer_flesh", reload="SpySociety/Weapons/LowBore/reload_handgun", use="SpySociety/Actions/item_pickup"},
		weapon_anim = "kanim_light_revolver",
		agent_anim = "anims_1h",
	},	
}

return tool_templates

