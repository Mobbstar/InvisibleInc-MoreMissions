local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )
local simfactory = include( "sim/simfactory" )
local unitdefs = include( "sim/unitdefs" )

local MM_compileUSB =
	{
		name = STRINGS.MOREMISSIONS.ABILITIES.COMPILE_ROOM_USB,

		getName = function( self, sim )
			return self.name
		end,

		createToolTip = function( self, sim )
			return abilityutil.formatToolTip( self.name, STRINGS.MOREMISSIONS.ABILITIES.COMPILE_ROOM_USB_DESC)
		end,

		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_compile_key_small.png",
		proxy = true,

		canUseAbility = function ( self, sim, unit, userUnit )
			if unit:getTraits().transferred_program then
				return false
			end

            if unit:getTraits().mainframe_status ~= "active" then
                return false
            end

			if unit:getTraits().cooldown and unit:getTraits().cooldown > 0 then
				return false, util.sformat(STRINGS.UI.REASON.COOLDOWN,unit:getTraits().cooldown)
			end

			if (unit:getTraits().mainframe_status == "active") and not (userUnit:getPlayerOwner() == unit:getPlayerOwner() ) then
				return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
			end

			if userUnit:getPlayerOwner() == nil or userUnit:getTraits().isDrone then
				return false
			end

			if unit:getTraits().storeType == "blank" then
				return false, STRINGS.MOREMISSIONS.ABILITIES.COMPILE_ROOM_USB_UNCOMPILED
			end

			if unit.items and not (#unit.items > 0) then
				return false
			end

			return simquery.canUnitReach( sim, userUnit, unit:getLocation() )
		end,

		executeAbility = function ( self, sim, unit, userUnit )
			unit:getTraits().transferred_program = true

			local x0,y0 = userUnit:getLocation()
			local x1,y1 = unit:getLocation()
			local tempfacing = simquery.getDirectionFromDelta( x1 - x0, y1 - y0 )

			userUnit:setFacing(tempfacing)
			sim:dispatchEvent( simdefs.EV_UNIT_USECOMP, { unitID = userUnit:getID(), useTinker=true, facing = tempfacing, sound = "SpySociety/Actions/monst3r_jackin" , soundFrame = 16 } )

			local cell = sim:getCell( userUnit:getLocation() )
			local unitData = unitdefs.lookupTemplate( "MM_compiler_USB" )

			local newUnit = simfactory.createUnit( unitData, sim )
			sim:spawnUnit( newUnit )
			sim:warpUnit( newUnit, cell )
			sim:emitSound( simdefs.SOUND_ITEM_PUTDOWN, cell.x, cell.y)

			local program = unit.items[1]
			local progName = tostring(program._traits.mainframe_program)
			newUnit:getTraits().MM_installedProgram = progName
			unit:getTraits().mainframe_status = "inactive"
			unit:getTraits().storeType = "blank"
			unit.items = {}

			sim:removeObjective( "getProgram" )

		end,
	}
return MM_compileUSB