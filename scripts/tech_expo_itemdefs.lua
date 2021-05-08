local util = include( "modules/util" )
local commondefs = include( "sim/unitdefs/commondefs" )

-- TECH EXPO block which autogenerates items from existing templates
function generateTechExpoGear()
	local tech_expo_templates = {}

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

	for i,itemdef in pairs(tech_expo_templates) do --upgrade traits
		local traits = itemdef.traits
		if traits.damage and (traits.damage > 0) and not traits.lethalMelee then --NIAA compatibility --if a trait is present, but 0, there's probably a good reason for it, keep it
			traits.damage = traits.damage + 1
		end
		if traits.baseDamage and (traits.baseDamage > 0) and not traits.lethalMelee then --NIAA compatibility
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

	simlog("LOG_MM", "LOG tech expo templates")
	simlog("LOG_MM", util.stringize(tech_expo_templates,3))

	return tech_expo_templates
end

return { generateTechExpoGear = generateTechExpoGear }
