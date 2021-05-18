local mathutil = include( "modules/mathutil" )
local array = include( "modules/array" )
local util = include( "modules/util" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local cdefs = include( "client_defs" )
local mainframe = include( "sim/mainframe" )
local modifiers = include( "sim/modifiers" )
local mission_util = include( "sim/missions/mission_util" )
local serverdefs = include("modules/serverdefs")
local mainframe_common = include("sim/abilities/mainframe_common")
local unitghost = include( "sim/unitghost" )
local simfactory = include( "sim/simfactory" )
local unitdefs = include( "sim/unitdefs" )

local existsWitnessOnMap = function(sim)
	--Guard or drone that has directly seen an agent.
	for unitID, unit in pairs(sim:getAllUnits()) do
		if unit:getTraits().witness and not unit:isDead() then
			return true
		end
	end
	return false
end

local checkAllWitnesses = function( self )
	return self.camera_witnesses + self.guard_witnesses + self.drone_witnesses + self.escaped_witnesses
end

local TRG_DATABASE_SCRUBBED = "MM_DB_scrubbed"

local npc_abilities = 
{

	MM_informant_intel = util.extend( mainframe_common.createReverseDaemon( STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON ) ) --this daemon is basically cosmetic/for UI convenience only
	{
		icon = "gui/icons/UI_icons/icon_program_moleBonus.png",--icon
		title = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_NAME,
		noDaemonReversal = true,
		bonus_type = "",
		missionsLeft = 0,

		onTooltip = function( self, hud, sim, player )
            local tooltip = util.tooltip( hud._screen )
			local section = tooltip:addSection()
			
			section:addLine( self.name )
			section:addAbility( STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.INTEL_TYPES[self.bonus_type], util.sformat(STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON.DESC, self.missionsLeft), "gui/icons/action_icons/Action_icon_Small/actionicon_talk.png" )		
			if self.dlcFooter then
				section:addFooter(self.dlcFooter[1],self.dlcFooter[2])
			end

            return tooltip
		end,
		
		onSpawnAbility = function( self, sim, player, agent )
			-- sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
		end,
		
		onDespawnAbility = function( self, sim )
		end,
	},

	MM_informant_witness = util.extend( mainframe_common.createDaemon( STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING ) ) --this daemon is basically cosmetic/for UI convenience only
	{
		icon = "gui/icons/UI_icons/icon_program_moleWitness.png",--icon
		title = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_NAME,
		
		onTooltip = function( self, hud, sim, player )
            local tooltip = util.tooltip( hud._screen )
			local section = tooltip:addSection()
			section:addLine( self.name )
			section:addAbility( STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.ACTIVE_DESC, STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.DESC, "gui/items/icon-action_peek.png" )
			-----
			section:addAbility( STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.GUARDS, util.sformat(STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.WITNESSES_LEFT_GUARDS, self.guard_witnesses), "gui/icons/action_icons/Action_icon_Small/icon-item_shoot_small.png" )
			
			section:addAbility( STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.CAMERAS, util.sformat(STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.WITNESSES_LEFT_CAMERAS, self.camera_witnesses), "gui/icons/action_icons/Action_icon_Small/icon-item_shoot_small.png" )
			
			-- if sim:getParams().difficultyOptions.enable_devices then -- check for Worldgen Extended's Drone Uplinks, need to also check if it is actually present
			-- too complex/inconsistent, leave this out for now
				-- section:addAbility( STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.DRONES, util.sformat(STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.WITNESSES_LEFT_DRONES_WE, self.drone_witnesses), "gui/icons/action_icons/Action_icon_Small/icon-item_shoot_small.png" )			
			-- else
				section:addAbility( STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.DRONES, util.sformat(STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.WITNESSES_LEFT_DRONES, self.drone_witnesses), "gui/icons/action_icons/Action_icon_Small/icon-item_shoot_small.png" )
			-- end
			------
			if self.escaped_witnesses > 0 then
				section:addAbility( STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.ESCAPED, util.sformat(STRINGS.MOREMISSIONS.DAEMONS.WITNESS_WARNING.WITNESSES_ESCAPED, self.escaped_witnesses), "gui/icons/thought_icons/status_run.png" )
			
			end
			
			if self.dlcFooter then
				section:addFooter(self.dlcFooter[1],self.dlcFooter[2])
			end

            return tooltip
        end,	
		
		noDaemonReversal = true,
		
		onSpawnAbility = function( self, sim, player, agent )
			sim:addTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:addTrigger( simdefs.TRG_UNIT_PARALYZED , self )
			sim:addTrigger( TRG_DATABASE_SCRUBBED , self )
			sim:addTrigger( simdefs.TRG_UNIT_APPEARED , self )
			sim:addTrigger( simdefs.TRG_START_TURN , self ) --just in case
			sim:addTrigger( "cameradb_scrubbed", self )
			sim:addTrigger( "mole_final_escape", self )
			sim:addTrigger( "vip_escaped", self )
			self.camera_witnesses = 0
			self.guard_witnesses = 0
			self.drone_witnesses = 0
			self.escaped_witnesses = 0
			-- sim:dispatchEvent( simdefs.EV_SHOW_REVERSE_DAEMON, { showMainframe=true, name=self.name, icon=self.icon, txt=self.activedesc, title=self.title } )
		end,
		
		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_UNIT_KILLED, self )
			sim:removeTrigger( simdefs.TRG_UNIT_PARALYZED, self )
			sim:removeTrigger( TRG_DATABASE_SCRUBBED, self )
			sim:removeTrigger( simdefs.TRG_UNIT_APPEARED , self )
			sim:removeTrigger( simdefs.TRG_START_TURN , self )
			sim:removeTrigger( "cameradb_scrubbed", self )
			sim:removeTrigger( "mole_final_escape", self )
			sim:removeTrigger( "vip_escaped", self )
		end,
		
		onTrigger = function( self, sim, evType, evData, userUnit )
			-- if (evType == simdefs.TRG.UNIT_KILLED) or (evType == simdefs.TRG_UNIT_PARALYZED) or (evType == TRG_DATABASE_SCRUBBED) or (evType == simdefs.TRG_UNIT_APPEARED) then --refresh after any event that could lead to witness number changing, this should be fairly infrequent
				local camera_witnesses = {}
				local guard_witnesses = {}
				local drone_witnesses = {}

				for unitID, unit in pairs(sim:getAllUnits()) do
					if unit:getTraits().witness and not unit:isDead() then
						if unit:getTraits().isGuard and not unit:getTraits().isDrone then
							table.insert(guard_witnesses, unit)
						end
						if unit:getTraits().isDrone then
							table.insert(drone_witnesses, unit)
						end
						if unit:getTraits().mainframe_camera then
							table.insert(camera_witnesses, unit)
						end
					end
				end	
				self.camera_witnesses = #camera_witnesses
				self.guard_witnesses = #guard_witnesses
				self.drone_witnesses = #drone_witnesses
			-- end
			if evType == "mole_final_escape" then
				if checkAllWitnesses(self) <= 0 then
					sim:getNPC():removeAbility(sim, "MM_informant_witness")  --despawn self if no witnesses left and mole has escaped
				end
			elseif evType == simdefs.TRG_UNIT_ESCAPED then
				local unit = evData
				if unit and unit:getTraits().MM_mole then
					if checkAllWitnesses(self) <= 0 then
						sim:getNPC():removeAbility(sim, 		"MM_informant_witness")  --despawn self if no witnesses left and mole has escaped
					end
				end
			elseif evType == "vip_escaped" then --for pacifists who can flee
				local unit = evData.unit
				if unit:getTraits().witness then --for agent elevator "escape"
					self.escaped_witnesses = self.escaped_witnesses + 1
					sim:getTags().MM_escapedWitness = true
				end
			end
			mainframe_common.DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )			
		end,
	},
	
}

-- sim:triggerEvent( simdefs.TRG_UNIT_PARALYZED )

return npc_abilities
