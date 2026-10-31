local simdefs = include("sim/simdefs")
local prefabs = include("sim/prefabs")

local generatePrefabs = prefabs.generatePrefabs
prefabs.generatePrefabs = function(cxt, candidates, tag, maxCount, fitnessFn, fitnessSelect, ...)
	if tag == "entry_guard" and cxt.MM_spawnedGuardEntries then
		maxCount = maxCount - cxt.MM_spawnedGuardEntries
		if maxCount <= 0 then
			if maxCount == 0 then
				cxt.MM_spawnedGuardEntries = nil
			else
				cxt.MM_spawnedGuardEntries = -maxCount
			end
			return 0
		else
			cxt.MM_spawnedGuardEntries = nil
		end
	end
	if
		not fitnessFn
		or fitnessSelect ~= prefabs.SELECT_HIGHEST
		or not cxt.MM_checkAllPieces
		or not cxt.MM_checkAllPieces[tag]
	then
		return generatePrefabs(cxt, candidates, tag, maxCount, fitnessFn, fitnessSelect, ...)
	end

	-- reject all possible placements once to force game to calculate fitness for all of them
	-- then do up to spawnQuota or maxCount single‐placements, using only the best fitness
	local placed = 0
	maxCount = maxCount or 1000
	-- reject all possible placements once to force engine to calculate fitness for all of them
	-- then do up to spawnQuota or maxCount single‐placements, using only the best fitness
	while placed < maxCount do
		-- first pass: gather every viable candidate’s score
		local allScores = {}
		local ins = 0
		local function gatherFitness(...)
			local score = fitnessFn(...)
			if score and score > 0 then
				ins = ins + 1
				table.insert(allScores, {
					args = { ... },
					score = score,
					ins = ins,
				})
			end
			return 0
		end

		-- gather fitness, place nothing
		local dryPass = generatePrefabs(cxt, candidates, tag, 1, gatherFitness, fitnessSelect, ...)
		assert(dryPass == 0, string.format("Expected 0 prefabs placed in dry pass for '%s', got %d", tag, dryPass))

		-- sort by descending fitness
		table.sort(allScores, function(a, b)
			if a.score ~= b.score then
				return a.score > b.score
			end
			return a.ins > b.ins
		end)

		-- real pass: try each candidate in turn until one fits
		local gotOne = false
		for _, entry in ipairs(allScores) do
			-- build a fitnessFn that only accepts this exact placement
			local function pickThis(...)
				local args = { ... }
				for i = 1, #args do
					if args[i] ~= entry.args[i] then
						return 0
					end
				end
				return entry.ins
			end
			local success = generatePrefabs(cxt, candidates, tag, 1, pickThis, fitnessSelect, ...)
			if success >= 1 then
				gotOne = true
				placed = placed + success
				simlog("PROCGEN - [MM] Placed %d '%s' at fitness=%.2d", success, tag, entry.score)
				break
			else
				simlog(simdefs.LOG_PROCGEN, "[MM] '%s' fitness=%.2d failed fit, retrying next best", tag, entry.score)
			end
		end

		-- if none of the scored candidates could actually place, bail out
		if not gotOne then
			simlog(simdefs.LOG_PROCGEN, "[MM] No viable placements for '%s', tried %d candidates", tag, #allScores)
			break
		end
	end
	return placed
end
