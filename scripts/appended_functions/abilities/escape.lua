local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

--and here comes the massive hacks! -M
do --This one has to be in load() because the item evac mod overrides the ability each load. (as of 20-2-2, -M)
	local escape_ability = abilitydefs.lookupAbility("escape")
	local executeAbility = escape_ability.executeAbility
	escape_ability.executeAbility = function( self, sim, abilityOwner, ... )
		local bounties = {}
		local cell = sim:getCell( abilityOwner:getLocation() )
		if cell.exitID then
			for _, unit in pairs( sim:getAllUnits() ) do
				local c = sim:getCell( unit:getLocation() )
				if c and c.exitID and unit:getTraits().bounty and not unit:getTraits().bountyCollected then
					table.insert(bounties,unit)
					unit:getTraits().bountyCollected = true --flag to prevent double-counting (because we have to wrap the function on every load in case Item Evac is installed)
					if unit:getTraits().isObjective and sim:getPC() then
						sim:getPC():setEscapedWithObjective(true)
					end
				end
			end
		end

		executeAbility( self, sim, abilityOwner, ... )

		for i,unit in ipairs(bounties) do
			unit:returnItemsToStash(sim)
			sim:addMissionReward(simquery.scaleCredits( sim, unit:getTraits().bounty or 0 ))
			sim:warpUnit( unit, nil )
			sim:despawnUnit( unit )
		end
	end
end