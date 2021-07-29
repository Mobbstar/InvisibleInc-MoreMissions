local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )
local speechdefs = include("sim/speechdefs")
local mathutil = include( "modules/mathutil" )
local inventory = include("sim/inventory")
local simquer = include("sim/simquery")	

-- Cosmetic ability version of the steal action that only serves as a trap and to deliver a script trigger. Makes decoy lootable despite having empty inventory.

local decoyCanLoot = function( sim, unit, targetUnit ) --copy from simquery with one change
	if unit:getTraits().isDrone then
		return false
	end

	if targetUnit == nil or targetUnit:isGhost() then
		return false
	end

	if not unit:canAct() then
		return false
	end

	if unit:getTraits().movingBody == targetUnit then
		return false
	end

	if not targetUnit:getTraits().iscorpse then
		if simquery.isEnemyTarget( unit:getPlayerOwner(), targetUnit ) then
			if not targetUnit:isKO() and not unit:hasSkill("anarchy", 2) then 
				return false
			end

			if not targetUnit:isKO() and sim:canUnitSeeUnit(targetUnit, unit) then
				return false
			end
		else
			if not targetUnit:isKO() then
				return false
			end
		end
	end

	local inventoryCount = targetUnit:getInventoryCount()
	if not unit:getTraits().anarchyItemBonus then
		for i,child in ipairs(targetUnit:getChildren()) do
			if child:getTraits().anarchySpecialItem and child:hasAbility( "carryable" ) then
				inventoryCount = inventoryCount -1
			end
		end
	end

	
	if not unit:getTraits().largeSafeMapIntel then
		for i,child in ipairs(targetUnit:getChildren()) do
			if child:getTraits().largeSafeMapIntel and child:hasAbility( "carryable" ) then
				inventoryCount = inventoryCount -1
			end
		end
	end	
	
	-- if simquery.calculateCashOnHand( sim, targetUnit ) <= 0 and simquery.calculatePWROnHand( sim, targetUnit ) <=0 and inventoryCount == 0 then 
		-- return false
	-- end

	local cell = sim:getCell( unit:getLocation() )
	local found = (cell == sim:getCell( targetUnit:getLocation() ))
	for simdir, exit in pairs( cell.exits ) do
		if simquery.isOpenExit( exit ) then
			found = found or array.find( exit.cell.units, targetUnit ) ~= nil
		end
	end
	if not found then
		return false, STRINGS.UI.REASON.CANT_REACH
	end

	return true

end

local MM_fakeSteal = 
	{
		name = STRINGS.UI.ACTIONS.LOOT_BODY.NAME,
		profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_loot_small.png",
		alwaysShow = true,
		getName = function( self, sim, unit )
			return self.name
		end,

		onTooltip = function( self, hud, sim, abilityOwner, abilityUser, targetUnitID )
			return string.format( "<ttheader>%s\n<ttbody>%s</>", STRINGS.UI.ACTIONS.LOOT_BODY.NAME, STRINGS.UI.ACTIONS.LOOT_BODY.TOOLTIP )
		end,

		acquireTargets = function( self, targets, game, sim, unit )
			-- Check adjacent tiles
			local targetUnits = {}
			local cell = sim:getCell( unit:getLocation() )
			--check for pinned guards
			for i,cellUnit in ipairs(cell.units) do
				if decoyCanLoot( sim, unit, cellUnit ) and cellUnit:getTraits().MM_decoy then
					table.insert( targetUnits,cellUnit )
				end
			end
            for i = 1, #simdefs.OFFSET_NEIGHBOURS, 2 do
    			local dx, dy = simdefs.OFFSET_NEIGHBOURS[i], simdefs.OFFSET_NEIGHBOURS[i+1]
                local targetCell = sim:getCell( cell.x + dx, cell.y + dy )
                if simquery.isConnected( sim, cell, targetCell ) then
					for _,cellUnit in ipairs( targetCell.units ) do
						if decoyCanLoot( sim, unit, cellUnit ) and cellUnit:getTraits().MM_decoy then
							table.insert( targetUnits,cellUnit )
						end
					end
				end
			end

			return targets.unitTarget( game, targetUnits, self, unit, unit )
		end,

		isValidTarget = function( self, sim, unit, userUnit, targetUnit )
			if targetUnit == nil or targetUnit:isGhost() then
				return false
			end

			if not simquery.isEnemyTarget( userUnit:getPlayerOwner(), targetUnit ) then
				return false
			end

			return true
		end,

		canUseAbility = function( self, sim, unit, userUnit, targetID )	

			return true
		end,

		executeAbility = function( self, sim, unit, userUnit, target )
			local targetUnit = sim:getUnit(target)
			sim:triggerEvent("MM_usedFakeSteal", {sourceUnit = unit, targetUnit = targetUnit} )
		end,
	}
return MM_fakeSteal