local mainframe_abilities = include("sim/abilities/mainframe_abilities")

for i, program in pairs(mainframe_abilities) do
	local onSpawnAbility_old = program.onSpawnAbility
	program.onSpawnAbility = function( self, sim, ... )
		onSpawnAbility_old( self, sim, ... )
		--check if AI terminal upgrades should apply to this program and apply this on spawn
		if sim:getParams().agency.MM_upgradedPrograms and not self.MM_upgraded then
			local upgrades = sim:getParams().agency.MM_upgradedPrograms
			local abilityID = self:getID()
			if upgrades[abilityID] then
				if upgrades[abilityID].break_firewalls then
					self.break_firewalls = self.break_firewalls + upgrades[abilityID].break_firewalls
				end
				if upgrades[abilityID].parasite_strength then
					self.parasite_strength = self.parasite_strength + upgrades[abilityID].parasite_strength
				end
				if upgrades[abilityID].cpu_cost then
					self.cpu_cost = self.cpu_cost + upgrades[abilityID].cpu_cost
				end
				if upgrades[abilityID].maxCooldown then
					self.maxCooldown = self.maxCooldown + upgrades[abilityID].maxCooldown
				end					
				self.MM_upgraded = true
			end
		end
	end
end