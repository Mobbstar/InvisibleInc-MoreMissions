local unitdefs = include( "sim/unitdefs" )

local baseCreateUnitData = unitdefs.createUnitData
function unitdefs.createUnitData( agentDef )
	local unitData = baseCreateUnitData( agentDef )

	for _, child in ipairs(unitData.children) do
		if child.traits then
			if child.traits.MM_mod_cooldownMax and child.traits.cooldownMax then
		  		child.traits.cooldownMax = child.traits.cooldownMax + child.traits.MM_mod_cooldownMax
		  	end
		  	if child.traits.MM_mod_chargesMax and child.traits.chargesMax then
		  		child.traits.chargesMax = child.traits.chargesMax + child.traits.MM_mod_chargesMax
				child.traits.charges = child.traits.charges + child.traits.MM_mod_chargesMax
		  	end
		  	if child.traits.MM_mod_maxAmmo and child.traits.maxAmmo then
		  		child.traits.maxAmmo = child.traits.maxAmmo + child.traits.MM_mod_maxAmmo
		  	end
		  	if child.traits.MM_mod_pwrCost and child.traits.pwrCost then
		  		child.traits.pwrCost = child.traits.pwrCost + child.traits.MM_mod_pwrCost
		  	end
		  	if child.traits.MM_mod_requirements then
		  		child.requirements = nil
		  	end
		  	if child.traits.MM_mod_armorPiercing then
		  		child.traits.armorPiercing = (child.traits.armorPiercing or 0) + child.traits.MM_mod_armorPiercing
		  	end
			if child.traits.MM_mod_damage then
				if child.traits.damage and child.traits.stun then
					child.traits.stun = child.traits.stun + child.traits.MM_mod_damage
				end
				if child.traits.damage then
					child.traits.damage = child.traits.damage + child.traits.MM_mod_damage
				end
				if child.traits.baseDamage then
					child.traits.baseDamage = child.traits.baseDamage + child.traits.MM_mod_damage
				end
			end
		end
	end

	return unitData
end
