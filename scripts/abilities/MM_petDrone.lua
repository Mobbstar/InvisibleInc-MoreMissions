local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )

local MM_renameDrone = 
	{
		name = STRINGS.MOREMISSIONS.ABILITIES.RENAME_DRONE,

		createToolTip = function( self, sim, unit )

			local title = STRINGS.MOREMISSIONS.ABILITIES.PET..util.toupper(unit:getTraits().customName or "Refit Drone")
			local body = STRINGS.MOREMISSIONS.ABILITIES.PET_DRONE_DESC

			if unit:getTraits().activate_txt_title then
				title = unit:getTraits().activate_txt_title
			end
			if unit:getTraits().activate_txt_body then
				body = unit:getTraits().activate_txt_body
			end			

			return abilityutil.formatToolTip( title,  body )
		end,
		
		proxy = true,
		ap_boost = 1,
		HUDpriority = 2,
		getName = function( self, sim, abilityOwner, abilityUser, targetUnitID )
			return self.name
		end,
		
		profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png", -- NEEDS TO BE CUSTOM!!!!!!!!

		-- Note that abilityOwner is the drone, unit is the agent!
		acquireTargets = function( self, targets, game, sim, abilityOwner, unit )
            if simquery.canUnitReach( sim, unit, abilityOwner:getLocation() ) and (unit ~= abilityOwner) then
			    return targets.unitTarget( game, { abilityOwner }, self, abilityOwner, unit )
            end
		end,
		
		-- Current acquireTargets allows diagonal petting, which crashes due to lack of diagonal animation.
		-- Needs to be adapted to only allow orthogonal petting. Below example code taken from melee.acquireTargets.
		
		-- acquireTargets = function( self, targets, game, sim, unit )
			-- -- Check adjacent tiles
			-- local targetUnits = {}
			-- local cell = sim:getCell( unit:getLocation() )
			-- --check for pinned guards
			-- for i,cellUnit in ipairs(cell.units) do
				-- if self:isValidTarget( sim, unit, unit, cellUnit ) then
					-- table.insert( targetUnits,cellUnit )
				-- end
			-- end
            -- for i = 1, #simdefs.OFFSET_NEIGHBOURS, 2 do
    			-- local dx, dy = simdefs.OFFSET_NEIGHBOURS[i], simdefs.OFFSET_NEIGHBOURS[i+1]
                -- local targetCell = sim:getCell( cell.x + dx, cell.y + dy )
                -- if simquery.isConnected( sim, cell, targetCell ) then
					-- for _,cellUnit in ipairs( targetCell.units ) do
						-- if self:isValidTarget( sim, unit, unit, cellUnit ) then
							-- table.insert( targetUnits,cellUnit )
						-- end
					-- end
				-- end
			-- end

			-- return targets.unitTarget( game, targetUnits, self, unit, unit )
		-- end,

		canUseAbility = function( self, sim, abilityOwner, unit )
			if abilityOwner == unit then
				return false
			end

			if unit:getTraits().hasAlreadyPetDrone then
				return false
			end
			
            return true
		end,

		executeAbility = function( self, sim, abilityOwner, unit )
			local x0,y0 = unit:getLocation()
			local x1, y1 = abilityOwner:getLocation()

			local facing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )
			
			local droneSounds = {abilityOwner:getSounds().getko, abilityOwner:getSounds().getko, abilityOwner:getSounds().reboot_end}
			local droneSound = droneSounds[sim:nextRand(1, #droneSounds)]			

			sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR, { unitID = unit:getID(), facing = facing, sound = nil, soundFrame = 1 } )
			
			sim:dispatchEvent( simdefs.EV_PLAY_SOUND, {sound=droneSound, x=x0,y=y0} )
			sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR_PST, { unitID = unit:getID(), facing = facing } )


			unit:getTraits().mp = unit:getTraits().mp + self.ap_boost

			sim:dispatchEvent( simdefs.EV_GAIN_AP, { unit = unit } )
			sim:dispatchEvent( simdefs.EV_UNIT_FLOAT_TXT, {txt=STRINGS.UI.FLY_TXT.MOVEMENT_BOOSTED,x=x0,y=y0,color={r=1,g=1,b=1,a=1}} )
			
			unit:getTraits().hasAlreadyPetDrone = true
			

		end,
	}
	
return MM_renameDrone
