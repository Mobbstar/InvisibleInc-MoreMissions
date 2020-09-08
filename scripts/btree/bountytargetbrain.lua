-- Brain for the assassination mission target.
-- Based on WimpBrain, but with more complex behavior once alerted.
local Brain = include("sim/btree/brain")
local btree = include("sim/btree/btree")
local actions = include("sim/btree/actions")
local conditions = include("sim/btree/conditions")
local CommonBrain = include( "sim/btree/commonbrain" )
local simdefs = include("sim/simdefs")
local simfactory = include( "sim/simfactory" )

require("class")

-- CommonBrain.RangedCombat, but screaming.
-- Falls back to behavior like CommonBrain.NoCombat if unarmed.
local function PanicCombat()
	return btree.Sequence("PanicCombat",
	{
		btree.Condition(conditions.IsAlerted),
		btree.Action(actions.Panic),  -- This Panic action is effectively shared through all Panic sequences.
		btree.Condition(conditions.mmHasSearchedVipSafe),
		btree.Condition(conditions.HasTarget),
		btree.Action(actions.ReactToTarget),
		btree.Selector("Engage",
		{
			btree.Sequence("WithWeapon",
			{
				btree.Condition(conditions.mmIsArmed),
				btree.Condition(conditions.CanShootTarget),
				btree.Action(actions.ShootAtTarget),
			}),
			-- If the target's weapon has been stolen, just point and shout.
			btree.Action(actions.WatchTarget),
		}),
	})
end

-- Hunt around the safe room in a panic. (Based on CommonBrain.Investigate)
local function PanicHunt()
	return btree.Sequence("PanicHunt",
	{
		btree.Condition(conditions.IsAlerted),
		btree.Condition(conditions.mmHasSearchedVipSafe),
		btree.Condition(conditions.HasInterest),
		btree.Action(actions.ReactToInterest),
		actions.MoveToInterest(),
		btree.Action(actions.MarkInterestInvestigated),
		btree.Action(actions.DoLookAround),
		btree.Selector("Finish",
		{
			btree.Condition(conditions.IsUnitPinning),  -- If pinning, just stop here.
			btree.Sequence("MoveOn",
			{
				btree.Action(actions.RemoveInterest),
				btree.Action(actions.mmRequestNewPanicTarget),
			}),
		}),
	})
end

-- Flee to the safe room, or run to the safe as a fallback.
local function PanicFlee()
	return btree.Sequence("PanicFlee",
	{
		btree.Condition(conditions.IsAlerted),
		actions.MoveToNextPatrolPoint(),
		btree.Action(actions.DoLookAround),
		btree.Action(actions.mmArmVip),
		btree.Action(actions.mmRequestNewPanicTarget),
	})
end

local BountyTargetBrain = class(Brain, function(self)
	Brain.init(self, "mmBountyTargetBrain",
		btree.Selector(
		{
			PanicCombat(),
			PanicHunt(),
			PanicFlee(),
			btree.Sequence("PanicFallback",
			{
				btree.Condition(conditions.IsAlerted),
				-- If the other panic sequences all failed, just stop here.
			}),
			CommonBrain.Investigate(),
			CommonBrain.Patrol(),
		})
	)
end)

function BountyTargetBrain:getPatrolFacing()
	local facings = self.unit:getTraits().patrolFacing
	local nextFacing = self.unit:getTraits().nextFacing

	if facings and nextFacing then
		return facings[nextFacing]
	else
		return self:getNextPatrolFacing()
	end
end

function BountyTargetBrain:getNextPatrolFacing()
	local facings = self.unit:getTraits().patrolFacing
	if not facings then
		return self.unit:getFacing()
	end

	local nextFacing = self.unit:getTraits().nextFacing
	if not nextFacing then
		nextFacing = 1
	else
		local maxFacing = #facings
		nextFacing = (nextFacing % maxFacing) + 1
	end
	self.unit:getTraits().nextFacing = nextFacing
	return facings[nextFacing]
end

local function createBrain()
	return BountyTargetBrain()
end

simfactory.register(createBrain)

return BountyTargetBrain
