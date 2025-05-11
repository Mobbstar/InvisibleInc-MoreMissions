local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local inventory = include("sim/inventory")
local abilityutil = include( "sim/abilities/abilityutil" )
local speechdefs = include("sim/speechdefs")
local mathutil = include( "modules/mathutil" )
local propdefs_vanilla = include( "sim/unitdefs/propdefs" )
local simfactory = include( "sim/simfactory" )

local function findCell( sim, tag )
	local cells = sim:getCells( tag )
	return cells and cells[1]
end

local MM_W93_incogRoom_unlock =
	{
		name = STRINGS.MOREMISSIONS.ABILITIES.INCOGROOM_UPGRADE,
        proxy = true,
		alwaysShow = true,
		ghostable = true,
		profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",
		used = false,

		getProfileIcon = function( self, sim, unit )
			return self.profile_icon
		end,

		getName = function( self, sim, unit )
			return unit:getName()
		end,

		onTooltip = function( self, hud, sim, abilityOwner, abilityUser, targetUnitID )
			local tooltip = util.tooltip( hud._screen )
			local section = tooltip:addSection()
			local canUse, reason = abilityUser:canUseAbility( sim, self, abilityOwner, targetUnitID )
			local targetUnit = sim:getUnit( targetUnitID )
	        	section:addLine( abilityOwner:getName( self, sim, abilityOwner ) )
			section:addAbility( self.name, STRINGS.MOREMISSIONS.ABILITIES.INCOGROOM_UPGRADE_DESC, "gui/items/icon-action_hack-console.png" )
			if reason then
				section:addRequirement( reason )
			end
			return tooltip
		end,

		canUseAbility = function( self, sim, unit, userUnit )
			if not simquery.canUnitReach( sim, userUnit, unit:getLocation() ) then
				return false
			end

			if unit:getPlayerOwner() ~= userUnit:getPlayerOwner() then
				return false, STRINGS.MOREMISSIONS.ABILITIES.DEACTIVATE_LOCKS
			end

			-- if self.used then
			if sim:getTags().used_AI_terminal then
				return false, STRINGS.UI.REASON.ALREADY_USED
			end

			return true
		end,

		executeAbility = function( self, sim, unit, userUnit )
			local x0,y0 = userUnit:getLocation()
			local x1,y1 = unit:getLocation()
			local facing = simquery.getDirectionFromDelta(x1-x0,y1-y0)
			sim:emitSpeech( userUnit, speechdefs.EVENT_HIJACK )
			-- sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = userUnit:getID(), unit:getID(), facing = facing, sound=simdefs.SOUNDPATH_USE_CONSOLE, soundFrame=10 } ) --remove animation event, as skipping it causes the modal dialog to break
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = userUnit } )

			-- moved to ai_terminal mission scripts
			-- if not sim:getParams().agency.W93_aiTerminals or sim:getParams().agency.W93_aiTerminals < 2 then
				-- sim:getPC():getTraits().W93_incognitaUpgraded = 1
			-- else
				-- local item = simfactory.createUnit( propdefs_vanilla.item_valuable_tech_3, sim )
				-- sim:spawnUnit(item)
				-- sim:warpUnit(item, sim:getCell(x0, y0))
				-- sim:getPC():getTraits().W93_incognitaUpgraded = -1
			-- end
			-- self.used = true
			-- sim:getTags().used_AI_terminal = true,
			-- sim:triggerEvent( simdefs.TRG_UNIT_WARP, { unit = unit, from_cell = sim:getCell(x1,y1), to_cell = sim:getCell(x1,y1) } )
			-- log:write("[MM] activated incogroom")
			sim:triggerEvent( "activated_incogRoom", { unit = unit, userUnit = userUnit } )

		end,
	}
return MM_W93_incogRoom_unlock