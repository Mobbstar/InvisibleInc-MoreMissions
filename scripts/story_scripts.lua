-- local SCRIPTS = include('client/story_scripts')
local util = include( "modules/util" )

local MakeLine = {
	Central = function(t, text, voice)
		t.text = text
        t.anim = "portraits/central_face"
        t.name = STRINGS.UI.CENTRAL_TITLE
        t.voice = voice
        -- t.timing = timing --only used for the two-part cyberlab judgement
        t.delay = 0.25
	end,
	Monster = function(t, text, voice)
		t.text = text
        t.anim = "portraits/monst3r_face"
        t.name = STRINGS.UI.MONST3R_TITLE
		t.voice = voice
	end,
	Incognita = function(t, text, voice)
		t.text = text
		t.anim = "portraits/incognita_face"
		t.name = STRINGS.UI.INCOGNITA_TITLE
		t.voice = voice
	end,
}

local function GenerateScript(strings, scripts)
	if strings[1] and type(strings[1]) == "string" then
		-- currently in the data table for a specific line
		if not MakeLine[strings[3]] then
			log:write("Warning: The following Story Script had no valid actor (" .. util.stringize(strings[3], 1) .. "):\n" .. strings[1])
		end
		MakeLine[strings[3]](scripts, strings[1], strings[2])
	else
		for i, data in pairs(strings) do
			if type(data) == "table" then
				scripts[i] = {}
				GenerateScript(data, scripts[i])
			else
				log:write("Warning: The following Story Script is not valid: " .. util.stringize(data, 1))
				scripts[i] = data
			end
		end
	end
end

local story_scripts = {}
GenerateScript(STRINGS.MOREMISSIONS.BANTER, story_scripts)

return story_scripts