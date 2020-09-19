local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local mission_util = include( "sim/missions/mission_util" )
local unitdefs = include( "sim/unitdefs" )
local simfactory = include( "sim/simfactory" )
local itemdefs = include( "sim/unitdefs/itemdefs" )
local propdefs = include( "sim/unitdefs/propdefs" )
local serverdefs = include( "modules/serverdefs" )
local SCRIPTS = include('client/story_scripts')
local modifiers = include( "sim/modifiers" )
local abilitydefs = include( "sim/abilitydefs" )
local simability = include( "sim/simability" )
---------------------------------------------------------------------------------------------
-- Local helpers
local strings_screens = include( "strings_screens" )
-- local old_augmenttip, old_weapontip, old_itemtip

local SIDEMISSIONS = {"fancyfab"} --random guard should have access key
-- terminal where Shopcat contacts you for a mice delivery job: as reward, upgrade a program of your choice? --hide it in the vents
-- special augment station that increases agent's max augment limit at the cost of KO for the rest of the  mission


local BOUGHT_ITEM =
{       
    trigger = simdefs.TRG_BUY_ITEM,
    fn = function( sim, triggerData )
        if triggerData.shopUnit:getTraits().storeType and (triggerData.shopUnit:getTraits().storeType == "large") and triggerData.shopUnit:getTraits().luxuryNanofab then
			-- log:write("LOG bought item")
            return triggerData.shopUnit
        end
    end,
}

local CLOSED_NANOFAB = 
{
	trigger = simdefs.TRG_CLOSE_NANOFAB,
	fn = function( sim, triggerData )
		if triggerData.unit and triggerData.unit:getTraits().storeType and (triggerData.unit:getTraits().storeType == "large") and triggerData.shopUnit:getTraits().luxuryNanofab then
			return triggerData.unit
		end
	end,
}

local function boughtItemAtFancyFab( script, sim )
    local _, shop = script:waitFor( BOUGHT_ITEM )
	-- log:write("LOG emptying nanofab")
	shop.items = {}
	shop.weapons = {}
	shop.augments = {}
	
	strings_screens.STR_346165218 = sim.old_augmenttip
	strings_screens.STR_2618909495 = sim.old_weapontip
	strings_screens.STR_590530336 = sim.old_itemtip
end

local function closedFancyFab( script, sim)
	local _, shop = script:waitFor(CLOSED_NANOFAB)
	
	strings_screens.STR_346165218 = sim.old_augmenttip
	strings_screens.STR_2618909495 = sim.old_weapontip
	strings_screens.STR_590530336 = sim.old_itemtip
	script:addHook(closedFancyFab)
end

local function populateFancyFab(sim)

    local simstore = include( "sim/units/store" )
    local computer = nil
    for i,testUnit in pairs(sim:getAllUnits())do
        if testUnit:getTraits().storeType and (testUnit:getTraits().storeType == "large") and testUnit:getTraits().luxuryNanofab then --add custom trait here
            computer = testUnit
        end
    end   

    if computer then 

		--Use simstore.createStoreItems to generate a long list of item candidates for each category. This will contain duplicates
		local possible_merch = {
		[1] = {}, --items
		[2] = {}, --augments
		[3] = {}, --weapons
		}
		
		for i = 20, 1, -1 do --10 iterations should be enough to get 16 unique items
			local items, weapons, augments = simstore.createStoreItems( simstore.STORE_ITEM, computer, sim )
			util.tmerge(possible_merch[1], items)
			util.tmerge(possible_merch[2], augments)
			util.tmerge(possible_merch[3], weapons)
		end

		local itemType = sim:nextRand(1,3) --randomly choose either items, augments or weapons to populate the shop
		sim.luxuryNanofabItemType = itemType
		local merch_candidates = possible_merch[itemType]
		
		--remove_duplicates
		local hash = {}
		local unique_merch = {}

		for _,v in ipairs(merch_candidates) do
		   if (not hash[v._unitData.id ]) then
			   table.insert(unique_merch,v)
			   hash[v._unitData.id] = true
		   end
		end	
		
		-- distribute the possible merch randomly to fill up the three nanofab categories
		local total_items = {
			[1] = {},	--8 slots
			[2] = {},	-- 4 slots
			[3] = {},	-- 4 slots
		}
		if #unique_merch > 0 then
			
			for i = #unique_merch, 1, -1 do -- will run until merch list potential is empty or all nanofab categories are full, whichever comes first
				local item = sim:nextRand(1, #unique_merch)
				local group_choice = sim:nextRand(1,#total_items) --pick one of three categories to populate
				local item_group = total_items[group_choice]
				local limit = 4
				if group_choice == 1 then 
					limit = 8
				end
				if #item_group < limit then 
					table.insert(item_group, unique_merch[i])
					table.remove(unique_merch, i)
				end
			end
			
			computer.items, computer.weapons, computer.augments = total_items[1], total_items[2], total_items[3]
		end
	end
end


function init( scriptMgr, sim )

    local params = sim:getParams()
    if params.side_mission then
        if params.side_mission == "fancyfab" then
		    scriptMgr:addHook( "FANCYFAB", boughtItemAtFancyFab, nil  )
			scriptMgr:addHook( "CLOSED_FANCYFAB", closedFancyFab, nil )
			populateFancyFab(sim)
		end
	end
		
end

local function pregeneratePrefabs( cxt, tagSet )

   -- WIP: no custom prefabs made yet

    -- if cxt.params.side_mission then
        -- if cxt.params.side_mission == "data scrub" then
end

local function generatePrefabs( cxt, candidates )
   
   -- WIP: no custom prefabs made yet
   

    -- local prefabs = include( "sim/prefabs" )
    -- -- prefabs.generatePrefabs( cxt, candidates, "powerCell", 1 )
    -- if cxt.params.side_mission then
        -- if cxt.params.side_mission == "data scrub" then
            -- prefabs.generatePrefabs( cxt, candidates, "data_node", 3 )
        -- elseif cxt.params.side_mission == "transformer" then
            -- prefabs.generatePrefabs( cxt, candidates, "switch", 2 )
        -- end
    -- end
end


local escape_scripts = {
	init,
	--pregeneratePrefabs,
	--generatePrefabs,
	}

return
{
	SIDEMISSIONS = SIDEMISSIONS,
	escape_scripts = escape_scripts,
}
