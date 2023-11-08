-- Brain for the assassination mission fake (unrevealed decoy).
-- Based on WimpBrain/PacifistBrain, but silently does nothing once alerted.
-- Once alerted, we're being invisibly replaced, so no noise, no side effects, please and thank you.
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
-- Brain definition

local BountyFakeBrain = class(Brain, function(self)
	Brain.init(self, "mmBountyFakeBrain",
		btree.Selector(
		{
			btree.Sequence("PanicMute",
			{
				btree.Condition(conditions.IsAlerted),
				-- If alerted, stop here.
			}),
			CommonBrain.Investigate(),
			CommonBrain.Patrol(),
		})
	)
end)

-----
-- Brain Registration

local function createBrain()
	return BountyFakeBrain()
end

simfactory.register(createBrain)

return BountyFakeBrain

