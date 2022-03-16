local array = include( "modules/array" )
local serverdefs = include( "modules/serverdefs" )
local mathutil = include( "modules/mathutil" )
local array = include( "modules/array" )
local util = include( "modules/util" )
local modifiers = include( "sim/modifiers" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local simplayer = include("sim/simplayer")
local unitdefs = include( "sim/unitdefs" )
local worldgen = include( "sim/worldgen" )
local simfactory = include( "sim/simfactory" )

-- LIFTED WHOLESALE OUT OF ADVANCED GUARD PROTOC
-------------------------------------------------------------------------------
-- These are passive abilities (no executeAbility function)

local function formatToolTip( header, body )
	return string.format( "<ttheader>%s\n<ttbody>%s</>", util.toupper(header), body )
end

local DEFAULT_BUFF =
{
	-- buffAbility = true, 

	getName = function( self, sim, unit )
		return self.name
	end,
		
	createToolTip = function( self,sim,unit,targetUnit)
		return formatToolTip( self.name, string.format("BUFF\n%s", self.desc ) )
	end,

	canUseAbility = function( self, sim, unit )
		return false -- Passives are never 'used'
	end,
	
	ghostable = true,

	executeAbility = nil, -- Passives by definition have no execute.
}

local MM_ce_ultrasonic_echolocation_passive = util.extend( DEFAULT_BUFF )
{
	name = STRINGS.RESEARCH.ULTRASONIC_ECHOLOCATION.NAME, 
	-- buffDesc = STRINGS.RESEARCH.ULTRASONIC_ECHOLOCATION.UNIT_DESC, 
	onSpawnAbility = function( self, sim, unit )
		-- unit:getTraits().ultrasonic_echolocation = true
		unit:getTraits().MM_noticesHidden = true
		sim:addTrigger( simdefs.TRG_UNIT_WARP, self, unit )
	end,

	onDespawnAbility = function( self, sim, unit )
		sim:removeTrigger( simdefs.TRG_UNIT_WARP, self, unit )
	end,

	onTrigger = function( self, sim, evType, evData, userUnit )
		if evType == simdefs.TRG_UNIT_WARP and simquery.isEnemyAgent(userUnit:getPlayerOwner(), evData.unit) and userUnit:getBrain() then
			local to_cell = evData.to_cell or evData.from_cell
			userUnit:getTraits().seesHidden = true
			local canSee, canSense = sim:canUnitSeeUnit(userUnit, evData.unit)
			local targetX, targetY
			if not canSee and canSense then
				targetX, targetY = to_cell.x, to_cell.y
			elseif not canSee and not canSense and evData.from_cell then
					-- Did unit warp OUT of peripheral vision? (NOTE: warping to nil still counts as leaving peripheral)
					-- NOTE: we really want to query here whether evData.unit *was* visible in peripheral (at evData.from_cell),
					-- based on invisibility, cover, etc. but there exists no such query, since evData.unit has already moved
					-- to a new cell by this time.  The closest we can do is call simquery.couldUnitSee, but it will base cover
					-- visibility on evData.unit's current cell -- leaving this as a small quirk, since the complete fix is quite complicated.
				if simquery.couldUnitSee(sim, userUnit, evData.unit, false, evData.from_cell ) then
					canSee, canSense = sim:canUnitSee(userUnit, evData.from_cell.x, evData.from_cell.y)
					if not canSee and canSense then
						log:write("LOG 4")
						targetX, targetY = evData.from_cell.x, evData.from_cell.y
					end
				end
			end
			userUnit:getTraits().seesHidden = false

			if targetX and targetY then 
			-- Unit either IS, or WAS in peripheral vision.  Either is noticeable.
				if userUnit:getBrain():getSenses():hasLostTarget(evData.unit) then
					userUnit:turnToFace( targetX, targetY , STRINGS.UI.TRACKED )
				else
					if evData.unit:isKO() or evData.unit:isDead() then
						if not evData.unit:hasBeenInvestigated() then
							userUnit:getBrain():getSenses():addInterest( targetX, targetY, simdefs.SENSE_PERIPHERAL, simdefs.REASON_FOUNDCORPSE, evData.unit)
						end
					else
						userUnit:getBrain():getSenses():addInterest( targetX, targetY, simdefs.SENSE_PERIPHERAL, simdefs.REASON_SENSEDTARGET, evData.unit)
					end
				end
			end		
		end
	end, 
}
return MM_ce_ultrasonic_echolocation_passive