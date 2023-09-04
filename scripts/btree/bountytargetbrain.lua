-- Brain for the assassination mission target.
-- Based on WimpBrain, but with more complex behavior once alerted.
local Brain = include("sim/btree/brain")
local btree = include("sim/btree/btree")
local actions = include("sim/btree/actions")
local conditions = include("sim/btree/conditions")
local CommonBrain = include( "sim/btree/commonbrain" )
local simdefs = include("sim/simdefs")
local simfactory = include( "sim/simfactory" )
local simquery = include("sim/simquery")

require("class")

-----
-- Main behavior sequences for the brain.

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

		btree.Condition(conditions.mmIsArmed),
		btree.Condition(conditions.CanShootTarget),
		-- Otherwise, fall through to PanicFlee.
		btree.Action(actions.ShootAtTarget),
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
		btree.Action(actions.mmFaceInterest),
		btree.Selector("CanInvestigate",
		{
			btree.Condition(conditions.mmInterestIsSelfPanic),
			btree.Condition(conditions.mmIsArmedAndInterestInSaferoom),
			-- Otherwise, fall through to PanicFlee.
		}),
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
		actions.mmMoveToSafetyPoint(),
		btree.Action(actions.mmArmVip),
		btree.Action(actions.DoLookAround),
		btree.Action(actions.Cower), -- Also removes interests, if present.
		btree.Action(actions.mmRequestNewPanicTarget), -- Begin hunting around the room.
	})
end

-----
-- Brain definition

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

-----
-- Senses overrides for units with this brain

local function interestInSaferoom(sim, x, y)
	local cell = sim:getCell( x, y )
	return simquery.cellHasTag( sim, cell, "saferoom" )
end

local function overrideSensesAddInterest( senses )
	local oldAddInterest = senses.addInterest

	function senses:addInterest(x, y, sense, reason, sourceUnit, ...)
		if self.unit:getTraits().mmSearchedVipSafe and sense == simdefs.SENSE_RADIO then
			-- SENSE_RADIO is generally remote interests from other sources (camera, Authority daemon, etc).
			-- Ignore them except for the random hunting interests sent by this unit.
			-- Note: We'll still turn to join a shared overwatch combat. An interest only tries to be added if we can't immediately point our gun.
			if not (reason == simdefs.REASON_HUNTING and sourceUnit == self.unit) then
				simlog("[MM] Unit [%d] ignoring radio interest (%d,%d:%s:%s:%s)", self.unit:getID(), x, y, sense, reason, sourceUnit and tostring(sourceUnit:getID()) or "nil")
				return nil
			end
		end
		if self.unit:getTraits().MM_staySafe and not interestInSaferoom( self.unit:getSim(), x, y ) then
			-- Don't willingly leave the safe room if we started in there.
			local fallback = self.unit:getTraits().mmVipHidePoint
			local interest = oldAddInterest(self, fallback.x, fallback.y, sense, reason, sourceUnit, ... )
			interest.alwaysDraw = false
			return interest
		end

		return oldAddInterest(self, x, y, sense, reason, sourceUnit, ... )
	end
end

function BountyTargetBrain:onSpawned(sim, unit)
	Brain.onSpawned(self, sim, unit)

	overrideSensesAddInterest( self.senses )
end

-----
-- Brain Registration

local function createBrain()
	return BountyTargetBrain()
end

simfactory.register(createBrain)

return BountyTargetBrain
