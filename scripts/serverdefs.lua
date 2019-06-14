local serverdefs = include( "modules/serverdefs" )

local function createGeneralMissionObj( txt, txt2 )
	return string.format("> %s\n> %s", txt, txt2 or STRINGS.MISSIONS.ESCAPE.OBJECTIVE)
end

local ESCAPE_MISSION_TAGS = {}

local SITUATIONS =
{
	holostudio =
	{
        ui = {
			insetImg = "gui/mission_debrief/unknown.png",
			icon = "gui/mission_previews/unknown.png",
			objectives = createGeneralMissionObj( STRINGS.MISSIONS.ESCAPE.OBJ_SECURITY ),
		},
	},
	assassination =
	{
        ui = {
			insetImg = "gui/mission_debrief/unknown.png",
			icon = "gui/mission_previews/unknown.png",
			objectives = createGeneralMissionObj( STRINGS.MOREMISSIONS.MISSIONS.ASSASSINATION.OBJECTIVE_1 ),
		},
	},
	landfill =
	{
        ui = {
			insetImg = "gui/mission_debrief/unknown.png",
			icon = "gui/mission_previews/unknown.png",
			objectives = createGeneralMissionObj( STRINGS.MISSIONS.ESCAPE.OBJ_NANO_FAB ),
		},
	},
	ea_hostage =
	{
        ui = {
			insetImg = "gui/menu pages/corp_select/New_mission_icons/10005.png",
			icon = "gui/mission_previews/ea_hostage.png",
			objectives = createGeneralMissionObj( STRINGS.MISSIONS.ESCAPE.OBJ_RESCUE_HOSTAGE ),
		},
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
