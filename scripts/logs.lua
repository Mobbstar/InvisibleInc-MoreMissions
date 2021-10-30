----------------------------------------------------------------
local util = include("modules/util")
local simdefs = include("sim/simdefs")
-----------------------------------------------------

local logs = {
	{
		id="MoreMissionsLog01",
		file = STRINGS.MOREMISSIONS.LOGS.log_informant_filename,
		title= STRINGS.MOREMISSIONS.LOGS.log_informant_title,
		body= STRINGS.MOREMISSIONS.LOGS.log_informant,
		profileImg = nil,
		profileAnim = "portraits/dracul_build",
		profileBuild = "portraits/lady_mole_face_dark" or nil,
	},

	{
		id="MoreMissionsLog02",
		file = STRINGS.MOREMISSIONS.LOGS.log_techexpo_filename,
		title= STRINGS.MOREMISSIONS.LOGS.log_techexpo_title,
		body= STRINGS.MOREMISSIONS.LOGS.log_techexpo,
		profileImg = nil,
		profileAnim = "portraits/portrait_animation_template",
		profileBuild = "portraits/MM_bot_purple_face" or nil,
	},	
}


-------------------------------------------------------------
return logs

