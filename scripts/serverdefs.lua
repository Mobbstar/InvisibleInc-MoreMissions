local serverdefs = include( "modules/serverdefs" )

local function createGeneralMissionObj( txt, txt2 )
	return string.format("> %s\n> %s", txt, txt2 or STRINGS.MISSIONS.ESCAPE.OBJECTIVE)
end

local function createGeneralSecondaryMissionObj()
	return string.format("<c:777777>> %s</>", STRINGS.MISSIONS.ESCAPE.SECONDARY_OBJECTIVE)
end

local ESCAPE_MISSION_TAGS = {}

local SITUATIONS =
{
--	holostudio =
--	{
--        ui = {
--			insetImg = "gui/mission_debrief/unknown.png",
--			icon = "gui/mission_previews/unknown.png",
--			objectives = createGeneralMissionObj( STRINGS.MISSIONS.ESCAPE.OBJ_SECURITY ),
--		},
--	},

-- Note: see modinit, default weight for all missions including vanilla ones is 100! so we can set custom missions to have more or less weight than that.
	assassination =
	{
        ui = {
			insetImg = "gui/icons/mission_icons/mission_assassination.png",
			icon = "gui/icons/mission_icons/mission_assassination_small.png",
			objectives = createGeneralMissionObj( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.OBJ_KILL ),
		},
		-- weight = 100,
	},
--	landfill =
--	{
--        ui = {
--			insetImg = "gui/mission_debrief/unknown.png",
--			icon = "gui/mission_previews/unknown.png",
--			objectives = createGeneralMissionObj( STRINGS.MISSIONS.ESCAPE.OBJ_NANO_FAB ),
--		},
--	},
	ea_hostage =
	{
        ui = {
			insetImg = "gui/icons/mission_icons/mission_EA_hostage.png",
			icon = "gui/icons/mission_icons/mission_EA_hostage_small.png",
			objectives = createGeneralMissionObj( STRINGS.MISSIONS.ESCAPE.OBJ_RESCUE_HOSTAGE ),
		},
	},
	weapons_expo =
	{
        ui = {
			insetImg = "gui/icons/mission_icons/mission_tech_expo.png",
			icon = "gui/icons/mission_icons/mission_weapons_expo_small.png",
			objectives = createGeneralMissionObj( STRINGS.MOREMISSIONS.UI.WEAPONS_EXPO_OBJECTIVE ),
		},
	},	
	
	distress_call =
	{
        ui = {
			insetImg = "gui/icons/mission_icons/mission_distress_call_v5.png",
			icon = "gui/icons/mission_icons/mission_distress_call_small.png",
			objectives = createGeneralMissionObj( STRINGS.MOREMISSIONS.UI.DISTRESS_OBJECTIVE ),
			secondary_objectives = createGeneralSecondaryMissionObj(STRINGS.MOREMISSIONS.UI.DISTRESS_OBJECTIVE_SECONDARY),
		},
		weight = 70, 
	},
	
	mole_insertion =
	{
        ui = {
			insetImg = "gui/icons/mission_icons/mission_mole_insertion.png",
			icon = "gui/icons/mission_icons/mission_mole_insertion_small.png",
			objectives = createGeneralMissionObj( STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.MOLE_OBJECTIVE ),
			secondary_objectives = createGeneralSecondaryMissionObj(STRINGS.MOREMISSIONS.MISSIONS.MOLE_INSERTION.MOLE_OBJECTIVE_SECONDARY),
		},
	},	

	ai_terminal = -- ported from Worldgen Extended by wodzu! with some extra features
	{
        ui = {
			insetImg = "gui/icons/mission_icons/mission_ai_terminal.png",
			icon = "gui/icons/mission_icons/mission_ai_terminal_small.png",
			objectives = createGeneralMissionObj( STRINGS.MOREMISSIONS.MISSIONS.AI_TERMINAL.AI_OBJECTIVE ),
			secondary_objectives = createGeneralSecondaryMissionObj(STRINGS.MOREMISSIONS.MISSIONS.AI_TERMINAL.AI_OBJECTIVE_SECONDARY),
		},
		weight = 50, -- 30% as common as default
	},			
}

--automated processing
for k, v in pairs(SITUATIONS) do
	--assume mission ID as tag for mission picker
	if not v.tags then
		table.insert(ESCAPE_MISSION_TAGS, k)
		v.tags = {k}
	end
	--scripts
	-- v.scripts = v.scripts or { "mission_".. k }
	v.scripts = v.scripts or {k}
	v.levelFile = v.levelFile or "lvl_procgen"
	--strings
	local location_str = STRINGS.MOREMISSIONS.LOCATIONS[string.upper(k)]
	v.ui.moreInfo = v.ui.moreInfo or location_str.MORE_INFO
	v.ui.insetTitle = v.ui.insetTitle or location_str.INSET_TITLE
	v.ui.insetTxt = v.ui.insetTxt or location_str.INSET_TXT
	v.ui.locationName = v.ui.locationName or location_str.NAME
	v.ui.playerdescription = v.ui.playerdescription or location_str.DESCRIPTION
	v.ui.reward = v.ui.reward or location_str.REWARD
	v.ui.insetVoice = v.ui.insetVoice or location_str.INSET_VO
	v.ui.secondary_objectives = v.ui.secondary_objectives or serverdefs.createGeneralSecondaryMissionObj()
	v.ui.tip = v.ui.tip or location_str.LOADING_TIP
	v.strings = v.strings or STRINGS.MISSIONS.ESCAPE --unused, except for the MISSION_TITLE on the scoring screen
end

return {
	SITUATIONS = SITUATIONS,
	ESCAPE_MISSION_TAGS = ESCAPE_MISSION_TAGS,
}
