local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )
local unitdefs = include( "sim/unitdefs" )

-------------------------------------------------------------------
--
--a near identical copy for teleporting when you're already on the guard tile somehow, for edge cases (like getting into an elevator through a door left open)

local function isKO( unit )
    return unit:isKO()
end

local function isNotKO( unit )
    return not unit:isKO()
end

local function canAbandon( unit )
    return not unit:getTraits().cant_abandon
end

local MM_escape_guardelevator =
	{
		name = STRINGS.ABILITIES.ESCAPE,
		onTooltip = function( self, hud, sim, abilityOwner, abilityUser )
			return abilityutil.hotkey_tooltip( self, sim, abilityOwner, STRINGS.MOREMISSIONS.ABILITIES.ESCAPE_GUARD_DESC )
		end,
		
		profile_icon = "gui/actions/escape1.png",
        canUseWhileDragging = false,

		getName = function( self, sim, unit )
			return self.name
		end,

		alwaysShow = true,
		
		acquireTargets = function( self, targets, game, sim, abilityOwner, unit )		

			local cell = sim:getCell( abilityOwner:getLocation() )
			local units = {}
			if sim:getQuery().cellHasTag(sim, cell, "guard_spawn") then
				table.insert( units, abilityOwner )	
			end

			return targets.unitTarget( game, units, self, abilityOwner, unit )
		end,

		-- confirmAbility = function( self, sim, ownerUnit )
			-- -- Check to see if escaping would leave anyone behind, and there is nobody remaining in the level.
            -- local fieldUnits, escapingUnits = simquery.countFieldAgents( sim )

            -- -- A partial escape means someone alive is left on the field.
            -- local isPartialEscape = array.findIf( fieldUnits, isNotKO ) ~= nil
			-- if isPartialEscape then
				-- return STRINGS.UI.HUD_CONFIRM_PARTIAL_ESCAPE			
			-- end

            -- -- Show what is being abandoned, if anything.
            -- local abandonedUnit = array.findIf( fieldUnits, isKO )
            -- local itemsInField = simquery.countDeployedUnits( sim )
			-- local txt = ""
			-- if abandonedUnit then
				-- txt =  string.format( STRINGS.UI.HUD_CONFIRM_ESCAPE, ownerUnit:getName(), abandonedUnit:getName() )			
			-- end
			-- if #itemsInField >0 then
				-- if abandonedUnit then
					-- txt = txt .."\n\n"
				-- end				
				-- txt = txt ..  STRINGS.UI.HUD_ITEMS_LEFT .. "\n"

				-- for i,item in ipairs(itemsInField) do
					-- txt = txt .. item:getName() .. "\n"
				-- end
			-- end
			-- if abandonedUnit or #itemsInField >0 then
				-- return txt
			-- end

            -- -- Defer to mission script warnings about escaping early.
			-- if type(sim.exit_warning) == "function" then
				-- return sim.exit_warning()
			-- end
				
			-- if type(sim.exit_warning) == "string" then
				-- return sim.exit_warning 
			-- end
		-- end,

		canUseAbility = function( self, sim, unit )
			local cell = sim:getCell( unit:getLocation() )
		
			if not sim:hasTag( "MM_DBhack_finished" ) then
				return false, STRINGS.UI.REASON.CANT_ESCAPE --"Hack Personnel Database first"
			end

			if unit:getTraits().MM_mole ~= true then 
				return false, STRINGS.ABILITIES.HACK_ONLY_MOLE --only mole
			end 	

			if not sim:getTags().MM_DBhack_finished then
				return false, STRINGS.MOREMISSIONS.UI.NO_GUARD_ESCAPE
			end
			
			if simquery.isUnitUnderOverwatch(unit) then
				return false, STRINGS.MOREMISSIONS.UI.NO_ESCAPE_OVERWATCHED
			end
			
			if sim:getTags().exit_reqiuired_item then --drop power cell before leaving...
				local hasItem = false
				for i,item in ipairs(unit:getChildren()) do
					if item:getUnitData().id == sim:getTags().exit_reqiuired_item then
						hasItem = true
					end
				end
				if hasItem then
					local name =  unitdefs.lookupTemplate( sim:getTags().exit_reqiuired_item ).name
					return false, util.sformat(STRINGS.MOREMISSIONS.ABILITIES.ESCAPE_GUARD_POWER_CELL,name)
				end
			end

			return true
		end,

		executeAbility = function( self, sim, abilityOwner )
			--manually move through the guard elevator door and teleports out
			local unit = abilityOwner
			local start_cell = sim:getCell(abilityOwner:getLocation())	
			
			if unit and unit:isValid() and unit:getLocation() and not unit:isDown() then
				sim:dispatchEvent( simdefs.EV_TELEPORT, { units={unit}, warpOut =true } )	
				sim:warpUnit( unit, nil)
				sim:despawnUnit(unit)			
				sim:triggerEvent( "mole_final_escape" )			
			end
		end,
	}
	
return MM_escape_guardelevator