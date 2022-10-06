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

	-- local inventoryCount = targetUnit:getInventoryCount()
	-- if not unit:getTraits().anarchyItemBonus then
	-- 	for i,child in ipairs(targetUnit:getChildren()) do
	-- 		if child:getTraits().anarchySpecialItem and child:hasAbility( "carryable" ) then
	-- 			inventoryCount = inventoryCount -1
	-- 		end
	-- 	end
	-- end
	--
	--
	-- if not unit:getTraits().largeSafeMapIntel then
	-- 	for i,child in ipairs(targetUnit:getChildren()) do
	-- 		if child:getTraits().largeSafeMapIntel and child:hasAbility( "carryable" ) then
	-- 			inventoryCount = inventoryCount -1
	-- 		end
	-- 	end
	-- end
	--
	-- if simquery.calculateCashOnHand( sim, targetUnit ) <= 0 and simquery.calculatePWROnHand( sim, targetUnit ) <=0 and inventoryCount == 0 then
	-- 	return false
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
		proxy = true, -- Proxy Ability: This ability is displayed to nearby units with the owning unit as the target.
		noUITR = true, -- Normal loot action isn't an ability, so don't risk UITR leaking that with tooltip modifications.

		getName = function( self, sim, unit )
			return self.name
		end,

		onTooltip = function( self, hud, sim, abilityOwner, abilityUser, targetUnitID )
			return string.format( "<ttheader>%s\n<ttbody>%s</>", STRINGS.UI.ACTIONS.LOOT_BODY.NAME, STRINGS.UI.ACTIONS.LOOT_BODY.TOOLTIP )
		end,

		canUseAbility = function( self, sim, unit, userUnit )
			if unit:getTraits().MM_decoy and decoyCanLoot( sim, userUnit, unit ) then
				return true
			end
		end,

		executeAbility = function( self, sim, unit, userUnit )
			sim:triggerEvent("MM_usedFakeSteal", {sourceUnit = userUnit, targetUnit = unit} )
		end,
	}
return MM_fakeSteal
