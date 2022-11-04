local mainframe_abilities = include("sim/abilities/mainframe_abilities")
local mathutil = include( "modules/mathutil" )
local array = include( "modules/array" )
local util = include( "client_util" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local cdefs = include( "client_defs" )
local mainframe = include( "sim/mainframe" )
local modifiers = include( "sim/modifiers" )
local mission_util = include( "sim/missions/mission_util" )
local serverdefs = include("modules/serverdefs")
local mainframe_common = include("sim/abilities/mainframe_common")

--there is weird stuff going on in mission_scoring and other places with programs with an abilityOverride trait that's messing with the upgrade. To compensate, we'll just do the upgrade based on name instead of ID. Take that, game. That's what happens when you make the ID USELESS to me! I mean, can't even use the abilityID to keep track of the SAME program owned by the player between missions? What?!

-- for program modification: self.MM_upgrade[1] contains type of upgrade as string, self.MM_upgrade[2] has intensity of upgrade as integer
local DEFAULT_ABILITY = mainframe_common.DEFAULT_ABILITY
local programModifier = function()

for i, program in pairs(mainframe_abilities) do
	if not program.MM_modifier_applied then
		program.MM_modifier_applied = true
		local onSpawnAbility_old = program.onSpawnAbility
		program.onSpawnAbility = function( self, sim, ... )
			onSpawnAbility_old( self, sim, ... )
			--check if AI terminal upgrades should apply to this program and apply this on spawn
			if sim:getParams().agency.MM_upgradedPrograms and not self.MM_upgraded then
				local upgrades = sim:getParams().agency.MM_upgradedPrograms
				-- local abilityID = self:getID()
				log:write("LOG upgrades")
				log:write(util.stringize(upgrades, 2))
				log:write("LOG name")
				log:write(util.stringize(self.name,2))
				local abilityID = self.name
				if upgrades[abilityID] then
					if upgrades[abilityID].break_firewalls then
						if (self.break_firewalls or 0) > 0 then
							self.break_firewalls = self.break_firewalls + upgrades[abilityID].break_firewalls
						end --could be nil but we still potentially want the change for later (e.g. Datablast)
						self.MM_upgrade = {"firewalls", upgrades[abilityID].break_firewalls }
					end
					if upgrades[abilityID].parasite_strength then
						self.parasite_strength = self.parasite_strength + upgrades[abilityID].parasite_strength
						self.MM_upgrade = {"parasite", upgrades[abilityID].parasite_strength }
					end
					if upgrades[abilityID].cpu_cost then
						self.cpu_cost = self.cpu_cost + upgrades[abilityID].cpu_cost
						self.MM_upgrade = {"PWRcost", upgrades[abilityID].cpu_cost }
						if self.GOLEMCOST then --blargh, edge cases
							self.GOLEMCOST = self.GOLEMCOST + upgrades[abilityID].cpu_cost
						end
						if upgrades[abilityID].base_cpu_cost then
							self.base_cpu_cost = self.base_cpu_cost + upgrades[abilityID].base_cpu_cost 
						end
					end
					if upgrades[abilityID].maxCooldown then
						self.maxCooldown = self.maxCooldown + upgrades[abilityID].maxCooldown
						self.MM_upgrade = {"cooldown", upgrades[abilityID].maxCooldown }
					end		
					if upgrades[abilityID].range then
						self.range = self.range + upgrades[abilityID].range
						self.MM_upgrade = {"range", upgrades[abilityID].range}
					end
					self.MM_upgraded = true
					self.value = self.value * 1.3
					self.name = "UPGRADED ".. self.name
				end
			end
		end
		
		local onTooltip_old = program.onTooltip
		program.onTooltip = function( self, hud, sim, player, ... )
			local tooltip = onTooltip_old( self, hud, sim, player, ... )
			if tooltip == nil then
				tooltip = util.tooltip( hud._screen )
			end
			-- MM_upgrade applied from agency, MM_modifiers from sim/during upgrade mission itself
			if (self.MM_upgrade == nil) and self.MM_modifiers then
				if self.MM_modifiers.break_firewalls then
					self.MM_upgrade = {"firewalls", self.MM_modifiers.break_firewalls }
				elseif self.MM_modifiers.parasite_strength then
					self.MM_upgrade = {"parasite", self.MM_modifiers.parasite_strength}
				elseif self.MM_modifiers.cpu_cost then
					self.MM_upgrade = {"PWRcost", self.MM_modifiers.cpu_cost}
				elseif self.MM_modifiers.maxCooldown then
					self.MM_upgrade = {"cooldown", self.MM_modifiers.maxCooldown }
				elseif self.MM_modifiers.range then
					self.MM_upgrade = {"range", self.MM_modifiers.range }
				end
			end
			if self.MM_upgrade then --FOR UI ONLY!
				local desc = ""
				local path = STRINGS.MOREMISSIONS.UI.TOOLTIPS.PROGRAM_UPGRADE
				local upgradeStrength = self.MM_upgrade[2] 
				if self.MM_upgrade[2] == 1 then
					upgradeStrength = "+1"
				end
				if self.MM_upgrade[1] == "parasite" then
					desc = util.sformat( path.PARASITE, upgradeStrength )
				elseif self.MM_upgrade[1] == "firewalls" then
					desc = util.sformat( path.FIREWALLS, upgradeStrength )
				elseif self.MM_upgrade[1] == "PWRcost" then
					desc = util.sformat( path.PWRCOST, upgradeStrength )	
				elseif self.MM_upgrade[1] == "cooldown" then
					desc = util.sformat( path.COOLDOWN, upgradeStrength )
				elseif self.MM_upgrade[1] == "range" then
					desc = util.sformat( path.RANGE, upgradeStrength )
				end
				
				-- special tooltip for rapier
				if (i == "rapier") and (self.MM_upgrade[1] == "PWRcost")and (self.MM_upgrade[2] == -1) then
					desc = util.sformat( path.PWRCOST_Rapier, upgradeStrength )
				end
				
				local section = tooltip:addSection()
				section:addLine( path.UPGRADED_LONG )
				section:addAbility( path.UPGRADED, desc, "gui/icons/item_icons/items_icon_small/icon-item_chargeweapon_small.png" )
			end
			return tooltip
		end
		
		--add in a special block to make Rapier PWR upgrades functional
		if i == "rapier" then
			local rapier_getCost_old = program.getCpuCost
			program.getCpuCost = function( self, ... )
				local oldcost = rapier_getCost_old(self, ...) --returns PWR cost based on alarm level, a minimum of 1
				if self.MM_upgrade and self.MM_upgrade[1] == "PWRcost" then
					local change = self.MM_upgrade[2]
					if oldcost + change > 0 then
						oldcost = oldcost + change
					end	
				end
				return oldcost
			end
		end
		if i == "parasite_2" then
			-- overwrite getCpuCost entirely to make it compatible with PWRcost upgrades
			program.base_cpu_cost = mainframe_abilities.parasite_2.cpu_cost
			program.getCpuCost = function( self )
				self.cpu_cost = #self.parasite_hosts + self.base_cpu_cost
				return DEFAULT_ABILITY.getCpuCost( self )
			end
		end
	end
end

end

return programModifier
