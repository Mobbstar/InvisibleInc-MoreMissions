local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )
local inventory = include("sim/inventory")
local abilitydefs = include( "sim/abilitydefs" )
-------------------------------------------------------------

local MM_installprogram =
	{
		name = STRINGS.MOREMISSIONS.ABILITIES.USB_PROGRAM_INSTALL,
		createToolTip = function( self, sim, unit )
			local mainframeDef = abilitydefs.lookupAbility(unit:getTraits().MM_installedProgram)
			local progName = 
			util.toupper(mainframeDef.name)
			local tooltip = STRINGS.MOREMISSIONS.ABILITIES.USB_PROGRAM_INSTALL_SHORT..progName
			return abilityutil.formatToolTip( self.name, util.sformat(STRINGS.MOREMISSIONS.ABILITIES.USB_PROGRAM_INSTALL_DESC,progName))
		end,

		profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small.png",
		alwaysShow = true,
		getName = function( self, sim )
			return self.name
		end,		

		canUseAbility = function( self, sim, unit )
			-- Must have a user owner.
			local userUnit = unit:getUnitOwner()
			if not userUnit then
				return false
			end
			
			local maxPrograms = simquery.getMaxPrograms( sim )
			if #sim:getPC():getAbilities() >= maxPrograms then
				return false, STRINGS.UI.TOOLTIP_PROGRAMS_FULL
			end
			
			local progID = unit:getTraits().MM_installedProgram
			
			if unit:getPlayerOwner():hasMainframeAbility(progID) then
				return false, STRINGS.UI.TOOLTIP_ALREADY_OWN
			end			
					
			return abilityutil.checkRequirements( unit, userUnit )
		end,

		executeAbility = function( self, sim, unit )
			local userUnit = unit:getUnitOwner()
			local player = unit:getPlayerOwner()
				
			sim:getStats():incStat( "programs_earned" )
			
			sim:dispatchEvent( simdefs.EV_PLAY_SOUND, "SpySociety/VoiceOver/Incognita/Pickups/NewProgram" )

			player:addMainframeAbility( sim, unit:getTraits().MM_installedProgram )
			local mainframeDef = abilitydefs.lookupAbility(unit:getTraits().MM_installedProgram)
			local dialogParams =
			{
				STRINGS.PROGRAMS.INSTALLED,
				mainframeDef.name,
				string.format( STRINGS.PROGRAMS.INSTALLED_DESC, mainframeDef.desc),
				mainframeDef.icon_100,
				color = {r=1,g=0,b=0,a=1}
			}
			sim:dispatchEvent( simdefs.EV_SHOW_DIALOG, { dialog = "programDialog", dialogParams = dialogParams } )
			
			inventory.useItem( sim, userUnit, unit )
		end,
	}
return MM_installprogram
