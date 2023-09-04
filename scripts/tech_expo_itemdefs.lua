local util = include( "modules/util" )
local commondefs = include( "sim/unitdefs/commondefs" )

-- TECH EXPO block which autogenerates items from existing templates
function generateTechExpoGear()
	local tech_expo_templates = {}

	local itemdefs = include("sim/unitdefs/itemdefs")
	local itemList = util.tcopy(itemdefs)
	for k,v in pairs(itemList) do
		if ((v.floorWeight or 0) > 1 )
		and ((v.value or 0) >= 700)		 --will include tier 2 weapons and up
		and (v.traits.damage or v.traits.baseDamage) and (v.traits.weaponType or v.traits.melee) then
			tech_expo_templates["MM_techexpo_"..k] = v
		end
	end

	for i,itemdef in pairs(tech_expo_templates) do --upgrade traits
		local traits = itemdef.traits
		
		traits.usesLeft = 3--5		
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
			local newAmmo = math.min( traits.usesLeft, (traits.maxAmmo + 1) )
			traits.ammo = newAmmo
			traits.maxAmmo = newAmmo
		end
		if traits.charges and traits.chargesMax then
			local newCharges = math.min( traits.usesLeft, (traits.chargesMax + 1 ))
			traits.charges = newCharges
			traits.chargesMax = newCharges
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
		-- itemdef.requirements.inventory = strength_req -- scrap this for now in favour of limited uses for each item

		if itemdef.value then
			itemdef.value = itemdef.value/2
		end

		itemdef.notSoldAfter = 0
		if itemdef.floorWeight then
			itemdef.floorWeight = nil
		end

		if itemdef.createUpgradeParams == nil then
			itemdef.createUpgradeParams = function( self, unit )
				return { traits = { usesLeft = unit:getTraits().usesLeft } }
			end
		else
			local createUpgradeParams_old = itemdef.createUpgradeParams
			itemdef.createUpgradeParams = function( self, unit )
				local old_params = createUpgradeParams_old( self, unit )
				old_params.traits = old_params.traits or {}
				old_params.traits.usesLeft = unit:getTraits().usesLeft
				return old_params
			end
		end
		
		traits.MM_tech_expo_item = true
		traits.MM_tech_expo_weapon = true

		-- Fix Biogenic Dart's hardcoded cooldown cooltip
		if itemdef.desc == STRINGS.ITEMS.DART_GUN_BIO_TOOLTIP then
			local desc = "Recharges every {1} turns."
			local new_desc = util.sformat(desc,traits.cooldownMax)
			itemdef.desc = new_desc
		end

		itemdef.name = "Experimental " .. itemdef.name
		itemdef.flavor = itemdef.flavor .. STRINGS.MOREMISSIONS.ITEMS.TECHEXPO_FLAVOR
	end
		
	simlog("[MM] tech expo templates")
	simlog(util.stringize(tech_expo_templates,3))

	return tech_expo_templates
end

return { generateTechExpoGear = generateTechExpoGear }
