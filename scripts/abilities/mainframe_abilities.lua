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

--there is weird stuff going on in mission_scoring and other places with programs with an abilityOverride trait that's messing with the upgrade. To compensate, we'll just do the upgrade based on name instead of ID. Take that, game. That's what happens when you make the ID USELESS to me! I mean, can't even use the abilityID to keep track of the SAME program owned by the player between missions? What?!

for i, program in pairs(mainframe_abilities) do
	-- log:write("LOG appending mainframe ability")
	-- log:write(util.stringize(program.name,2))
	
	if not program.MM_modifier_applied then
		program.MM_modifier_applied = true
		local onSpawnAbility_old = program.onSpawnAbility
		program.onSpawnAbility = function( self, sim, ... )
			onSpawnAbility_old( self, sim, ... )
			--check if AI terminal upgrades should apply to this program and apply this on spawn
			if sim:getParams().agency.MM_upgradedPrograms and not self.MM_upgraded then
				local upgrades = sim:getParams().agency.MM_upgradedPrograms
				-- local abilityID = self:getID()
				-- log:write("LOG upgrades")
				-- log:write(util.stringize(upgrades, 2))
				-- log:write(util.stringize(self.name,2))
				local abilityID = self.name
				if upgrades[abilityID] then
					-- log:write("upgraded program")
					log:write(util.stringize(upgrades,2))
					if upgrades[abilityID].break_firewalls then
						self.break_firewalls = self.break_firewalls + upgrades[abilityID].break_firewalls
						self.MM_upgrade = {"firewalls", upgrades[abilityID].break_firewalls }
						if self.GOLEMCOST then --blargh, edge cases
							self.GOLEMCOST = self.GOLEMCOST + upgrades[abilityID].break_firewalls
						end
					end
					if upgrades[abilityID].parasite_strength then
						self.parasite_strength = self.parasite_strength + upgrades[abilityID].parasite_strength
						self.MM_upgrade = {"parasite", upgrades[abilityID].parasite_strength }
					end
					if upgrades[abilityID].cpu_cost then
						self.cpu_cost = self.cpu_cost + upgrades[abilityID].cpu_cost
						self.MM_upgrade = {"PWRcost", upgrades[abilityID].cpu_cost }
					end
					if upgrades[abilityID].maxCooldown then
						-- log:write("LOG modifying cooldown")
						self.maxCooldown = self.maxCooldown + upgrades[abilityID].maxCooldown
						self.MM_upgrade = {"cooldown", upgrades[abilityID].maxCooldown }
					end		
					if upgrades[abilityID].range then
						self.range = self.range + upgrades[abilityID].range
						self.MM_upgrade = {"range", upgrades[abilityID].range}
					end
					self.MM_upgraded = true
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
			if self.MM_upgrade then
				local desc = ""
				local path = STRINGS.MOREMISSIONS.UI.TOOLTIPS.PROGRAM_UPGRADE
				if self.MM_upgrade[2] == 1 then
					self.MM_upgrade[2] = "+1"
				end
				if self.MM_upgrade[1] == "parasite" then
					desc = util.sformat( path.PARASITE, self.MM_upgrade[2] )
				elseif self.MM_upgrade[1] == "firewalls" then
					desc = util.sformat( path.FIREWALLS, self.MM_upgrade[2] )
				elseif self.MM_upgrade[1] == "PWRcost" then
					desc = util.sformat( path.PWRCOST, self.MM_upgrade[2] )	
				elseif self.MM_upgrade[1] == "cooldown" then
					desc = util.sformat( path.COOLDOWN, self.MM_upgrade[2] )
				elseif self.MM_upgrade[1] == "range" then
					desc = util.sformat( path.RANGE, self.MM_upgrade[2] )
				end
				
				local section = tooltip:addSection()
				section:addLine( path.UPGRADED_LONG )
				section:addAbility( path.UPGRADED, desc, "gui/icons/item_icons/items_icon_small/icon-item_chargeweapon_small.png" )
			end
			return tooltip
		end
	end
end
