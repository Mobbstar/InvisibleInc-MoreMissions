local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )

local MM_transformer_terminal_sell_PWR_5 = 
	{
		name = STRINGS.DLC1.TRANSFORMER_TERMINAL_SELL_PWR,
		COST =  150,
		PWRneeded = 5,
		HUDpriority = 1,
		-- incriment = 2, -- PWRneeded needs to be divisible by this number.

		createToolTip = function( self, sim, unit )
			return abilityutil.formatToolTip(STRINGS.DLC1.TRANSFORMER_TERMINAL_SELL_PWR,util.sformat(STRINGS.DLC1.TRANSFORMER_TERMINAL_SELL_PWR_DESC,self.PWRneeded, simquery.scaleCredits( sim, self.COST ) ))
		end,

		proxy = true,
		

		getName = function( self, sim, abilityOwner, abilityUser, targetUnitID )
			return self.name
		end,
		
		profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small_5PWR.png",

		canUseAbility = function( self, sim, abilityOwner, unit, targetUnitID )

            if abilityOwner:getTraits().mainframe_status ~= "active" then
                return false
            end

			if abilityOwner:getPlayerOwner() ~= sim:getPC() then
				return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
			end

            if not simquery.canUnitReach( sim, unit, abilityOwner:getLocation() ) then
			    return false
            end			

            if abilityOwner:getTraits().power_transfered then
            	return false
            end

			local player = unit:getPlayerOwner()
			if player:getCpus() < self.PWRneeded then
				return false, util.sformat( STRINGS.DLC1.TRANSFORMER_TERMINAL_SELL_PWR_ERROR )
			end

            return true	
		end,

		executeAbility = function( self, sim, abilityOwner, unit, targetUnitID )
			local player = unit:getPlayerOwner()
			local x1,y1 = abilityOwner:getLocation()
			local x2,y2 = unit:getLocation()

			abilityOwner:getTraits().power_transfered = true
			local credits =  simquery.scaleCredits( sim, self.COST )
		

			sim._resultTable.credits_gained.selling = sim._resultTable.credits_gained.selling and sim._resultTable.credits_gained.selling + credits or credits

			player:addCPUs( -3, sim,x2,y2 )
			sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 20 )

			player:addCPUs( -2, sim,x2,y2 )
			sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 20 )

			sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 60 )
			player:addCredits( credits ,sim,x1,y1 )
		end,

	}

return MM_transformer_terminal_sell_PWR_5
