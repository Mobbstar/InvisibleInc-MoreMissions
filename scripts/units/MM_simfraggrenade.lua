local util = include( "modules/util" )
local array = include( "modules/array" )
local unitdefs = include( "sim/unitdefs" )
local simunit = include( "sim/simunit" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local simfactory = include( "sim/simfactory" )

-----------------------------------------------------

local frag_grenade = { ClassType = "MM_simfraggrenade" }
--but also an HD hologrenade so \o/

function frag_grenade:throw(throwingUnit, targetCell)
	local sim = self:getSim()
	local player = throwingUnit:getPlayerOwner()
	local x0, y0 = throwingUnit:getLocation()

    assert( player )
	self:setPlayerOwner(player)
	
	sim:dispatchEvent( simdefs.EV_UNIT_THROWN, { unit = self, x=targetCell.x, y=targetCell.y } )

	if x0 ~= targetCell.x or y0 ~= targetCell.y then
		sim:warpUnit(self, targetCell)
	end

    self:getTraits().throwingUnit = throwingUnit:getID()
    self:getTraits().cooldown = self:getTraits().cooldownMax

    self:activate()

    if self:getTraits().keepPathing == false and throwingUnit:getBrain() then
    	throwingUnit:useMP(throwingUnit:getMP(), sim)
    end
    
	sim:processReactions()
end

function frag_grenade:explode()
    assert( self:getTraits().deployed )

    -- A deployed grenade can explode. This will deactivate AND despawn it.
    local sim = self:getSim()
    local x, y = self:getLocation()
    local cells = self:getExplodeCells()
	sim:dispatchEvent(simdefs.EV_GRENADE_EXPLODE, { unit = self, cells = cells } )
	if self.onExplode then
        self:onExplode(cells )
    end

    self:deactivate()
    local unitID = self:getID()
 	sim:warpUnit(self, nil)
	sim:despawnUnit( self )
	--make sure all players glimpse to remove the ghosts
	for i,player in ipairs(sim:getPlayers()) do			
		player:glimpseUnit(sim, unitID)
	end
end

function frag_grenade:getExplodeCells()
    local x0, y0 = self:getLocation()
	local currentCell = self:getSim():getCell( x0, y0 )
	local cells = {currentCell}
	if self:getTraits().range then
		-- local fillCells = simquery.fillCircle( self._sim, x0, y0, self:getTraits().range, 0)
		
		local fillCells = simquery.rasterCircle( self._sim, x0, y0, self:getTraits().range ) --redefine cells based on range, so the effect goes through walls
		for i, x, y in util.xypairs( fillCells ) do
			local cell = self._sim:getCell( x, y )
			if cell and (cell ~= currentCell) then
				local raycastX, raycastY = self._sim:getLOS():raycast(x0, y0, cell.x, cell.y)
				if raycastX == cell.x and raycastY == cell.y then
					table.insert(cells, cell)
				end
			end
		end
	end
    return cells
end

function frag_grenade:createTallCover()
	local sim = self:getSim()
	local cell = sim:getCell(self:getLocation())
	local segments = {}
	local cells = { cell }
	for _, dir in ipairs( simdefs.DIR_SIDES ) do
		local dx, dy = simquery.getDeltaFromDirection( dir )
		local tocell = sim:getCell( cell.x + dx, cell.y + dy )
		if tocell and array.find( cells, tocell ) == nil then
			table.insert( segments, tocell )
			table.insert( segments, simquery.getReverseDirection( dir ) )
		end
		table.insert( segments, cell )
		table.insert( segments, dir )
	end
	sim:getLOS():insertSegments( unpack( segments ))
	self._segments = segments
	self._cells = cells
    for i, unit in pairs(sim:getAllUnits()) do
        sim:refreshUnitLOS( unit )
    end
    sim:dispatchEvent( simdefs.EV_EXIT_MODIFIED )
end

function frag_grenade:activate()
    assert( not self:getTraits().deployed )

    local sim = self:getSim()

	if self:getTraits().usesLeft then
		self:getTraits().usesLeft = self:getTraits().usesLeft - 1
	end

	if self:getTraits().usesLeft and (self:getTraits().usesLeft <= 0) and self:hasAbility("carryable") then
		self:removeAbility(sim, "carryable")
		self:getTraits().MM_destroyedNotCarryable = true
	end
		
	if self:getTraits().camera then
		self:getTraits().hasSight = true
		sim:getLOS():registerSeer(self:getID() )
		sim:refreshUnitLOS(self)
	end

	if self:getTraits().holoProjector then
		local cell = sim:getCell(self:getLocation())
		if self:getTraits().deploy_cover then
			sim:warpUnit( self )
			self:getTraits().cover = true			
			sim:warpUnit( self, cell)
			if self:getTraits().deploySightblock then
				self:createTallCover()
			end	
		end		
		self:getTraits().hologram=true
		self:getSounds().spot = self:getSounds().activeSpot
		sim:dispatchEvent( simdefs.EV_UNIT_UPDATE_SPOTSOUND, { unit = self,  stop = false } )										 
	end

	if self:getTraits().cryBaby or self:getTraits().transporterBeacon then
		self:getTraits().mainframe_item = true
		self:getTraits().mainframe_status = "on"
	end

    self:getTraits().deployed = true
    local cells = self:getExplodeCells()
	sim:dispatchEvent( simdefs.EV_UNIT_ACTIVATE, { unit = self, cells=cells } )

    if self:getTraits().explodes == 0 then
        self:explode()
    else
        if self:getTraits().explodes then
            self:getTraits().timer = self:getTraits().explodes
        	sim:addTrigger( simdefs.TRG_START_TURN, self ) -- Explodes later
        end
		sim:addTrigger( simdefs.TRG_UNIT_PICKEDUP, self )
        sim:triggerEvent( simdefs.TRG_UNIT_DEPLOYED, { unit = self })
    end
end

function frag_grenade:onTrigger( sim, evType, evData )
	if evType == simdefs.TRG_UNIT_PICKEDUP and evData.item == self then
		self:deactivate()

	elseif evType == simdefs.TRG_UNIT_WARP and evData.unit ~= self then
		local x0,y0 = self:getLocation()

		if evData.to_cell == sim:getCell(self:getLocation()) or evData.from_cell == sim:getCell(self:getLocation()) then
			if evData.unit:getTraits().isAgent then
				sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self } )
			end
		end
	elseif evType == simdefs.TRG_START_TURN then
		if evData:isNPC() then
            self:getTraits().timer = self:getTraits().timer - 1
            if self:getTraits().timer <= 0 then
                self:explode()
            end
		end
	end
end

function frag_grenade:deactivate()
    assert( self:getTraits().deployed )

    -- This defuses (deactivates) a deployed grenade.
	local sim = self:getSim()
	local x0,y0 = self:getLocation()

	if self:getTraits().camera then
		self:getTraits().hasSight = false	
		sim:refreshUnitLOS(self)
		sim:getLOS():unregisterSeer(self:getID() )
	end

	if self:getTraits().cryBaby or self:getTraits().transporterBeacon then
		self:getTraits().mainframe_item = nil
		self:getTraits().mainframe_status = nil
	end

	if self:getTraits().holoProjector then
		if self:getTraits().deploy_cover then
			local cell = sim:getCell(self:getLocation())	
			sim:warpUnit( self )
			self:getTraits().cover = false
			sim:warpUnit( self, cell)
		end			
		sim:dispatchEvent( simdefs.EV_UNIT_UPDATE_SPOTSOUND, { unit = self, stop = true } )
		self:getSounds().spot = nil
		self:getTraits().hologram=false
		if self._segments then --remove sightblock from HD hologram
			sim:getLOS():removeSegments( unpack( self._segments ))
			sim:dispatchEvent( simdefs.EV_EXIT_MODIFIED ) -- Update shadow map.
			-- sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self } )
			-- sim:dispatchEvent( sim:getDefs().EV_LOS_REFRESH, { player = sim:getPC(), cells = self._cells } )
			-- sim:dispatchEvent( sim:getDefs().EV_LOS_REFRESH, { player = sim:getNPC(), cells = self._cells } )
			self._segments, self._cells = nil, nil
		end			
	end

    self:getTraits().deployed = nil

    if self:getTraits().explodes == nil then
        sim:removeTrigger( simdefs.TRG_UNIT_PICKEDUP, self )
    elseif self:getTraits().explodes > 0 then
        sim:removeTrigger( simdefs.TRG_START_TURN, self )
        sim:removeTrigger( simdefs.TRG_UNIT_PICKEDUP, self )
    end

	sim:dispatchEvent( simdefs.EV_UNIT_DEACTIVATE, { unit = self } )
end

-- function frag_grenade:onWarp( sim, oldcell, cell)
	-- if not oldcell and cell then
		-- sim:addTrigger( simdefs.TRG_UNIT_WARP, self )
	-- elseif not cell and oldcell then
		-- sim:removeTrigger( simdefs.TRG_UNIT_WARP, self )
	-- end
-- end

function frag_grenade:onWarp(sim, oldcell, cell)
    if self._segments then
        sim:getLOS():removeSegments( unpack( self._segments ))
        self._segments, self._cells = nil, nil
        for i, unit in pairs(sim:getAllUnits()) do
            sim:refreshUnitLOS( unit )
        end
        sim:dispatchEvent( simdefs.EV_EXIT_MODIFIED ) -- Update shadow map.
    end
    -- if cell then
        -- self._cells, self._segments, self._interestUnits = occludeSight( sim, cell, self:getTraits().radius )
        -- for i, cell in ipairs(self._cells) do
            -- for i, unit in ipairs(cell.units) do
                -- if unit:getBrain() and unit:getTraits().hasSight then
                    -- unit:getBrain():getSenses():addInterest(cell.x, cell.y, simdefs.SENSE_SIGHT, simdefs.REASON_SMOKE)
                -- end
            -- end
        -- end
        -- sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self } )     
    -- end
end

function frag_grenade:onExplode( cells )
    local sim, player = self:getSim(), self:getPlayerOwner()

	-- log:write("LOG on explode")
	
	if self:getTraits().createsSmoke then
		assert( self:getTraits().on_spawn )
		local sim = self:getSim()
		local newUnit = simfactory.createUnit( unitdefs.lookupTemplate( self:getTraits().on_spawn ), sim )
		sim:spawnUnit( newUnit )
		sim:warpUnit( newUnit, sim:getCell( self:getLocation() ) )	
	end	
	
	sim:startTrackerQueue(true)				
	sim:startDaemonQueue()			
    sim:dispatchEvent( simdefs.EV_KO_GROUP, true )

	local killedUnits = {}
	
	for i, cell in ipairs(cells) do
		-- log:write("LOG cell")
		for i, cellUnit in ipairs( cell.units ) do
			-- log:write("LOG cell unit")
			-- log:write(util.stringize(cellUnit:getUnitData().name,2))
			if self:getTraits().baseDamage 
			and (self:getTraits().friendlyDamage
			or ( self:getTraits().friendlyDamage == nil and simquery.isEnemyAgent( player, cellUnit)))
			-- and not cellUnit:getTraits().isDrone
			then
				-- log:write("LOG grenade explosion")
				-- for FX reasons, KO first, then kill: EV_KO_GROUP doesn't apply to death events
				local damage = self:getTraits().baseDamage

				if sim:isVersion("0.17.5") then
					damage = cellUnit:processKOresist( damage )
				end		

				-- cellUnit:setKO(sim, damage)
				table.insert(killedUnits, cellUnit)
			end
		end
	end
	
	sim:dispatchEvent( simdefs.EV_KO_GROUP, false )
	for i, cellUnit in pairs(killedUnits) do
		-- log:write("LOG damaging unit")
		if cellUnit:getTraits().woundsMax or cellUnit:getTraits().canBeShot then
			sim:damageUnit(cellUnit, self:getTraits().baseDamage)
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = cellUnit } )
		end
	end

	sim:startTrackerQueue(false)				
	sim:processDaemonQueue()		
end

local function createFragGrenade( unitData, sim )
	return simunit.createUnit( unitData, sim, frag_grenade )
end

simfactory.register( createFragGrenade )

return frag_grenade
