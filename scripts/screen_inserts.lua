-- EXECUTIVE TERMINAL: change window to display 6 infiltration targets
local inserts_exec = {
	{
		"modal-execterminals.lua",
		{ "widgets", 2, "children"},
		{
			name = [[location5]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = -85,
			xpx = true,
			y = -252,
			ypx = true,
			w = 0,
			h = 0,
			sx = 1,
			sy = 1,
			skin = [[Group]],				
		},	
	},
	{
		"modal-execterminals.lua",
		{ "widgets", 2, "children"},
		{
			name = [[location6]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 248,
			xpx = true,
			y = -252,
			ypx = true,
			w = 0,
			h = 0,
			sx = 1,
			sy = 1,
			skin = [[Group]],				
		},	
	},			
}

-- for AI Terminal dialog: -- copied from Interactive Events & expanded to support up to 8 buttons
local inserts_ai_term = {
	{
		"modal-event.lua",
		{ "widgets", 2, "children"},
		{
			name = [[optionBtn5]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 1,
			xpx = true,
			y = -96,
			ypx = true,
			w = 500,
			wpx = true,
			h = 38,
			hpx = true,
			sx = 1,
			sy = 1,
			ctor = [[button]],
			clickSound = [[SpySociety/HUD/menu/click]],
			hoverSound = [[SpySociety/HUD/menu/rollover]],
			hoverScale = 1,
			halign = MOAITextBox.CENTER_JUSTIFY,
			valign = MOAITextBox.CENTER_JUSTIFY,
			text_style = [[font1_16_r]],
			images =
			{
				{
					file = [[white.png]],
					name = [[inactive]],
					color =
					{
						0.219607844948769,
						0.376470595598221,
						0.376470595598221,
						1,
					},
				},
				{
					file = [[white.png]],
					name = [[hover]],
					color =
					{
						0.39215686917305,
						0.690196096897125,
						0.690196096897125,
						1,
					},
				},
				{
					file = [[white.png]],
					name = [[active]],
					color =
					{
						0.39215686917305,
						0.690196096897125,
						0.690196096897125,
						1,
					},
				},
			},
		},	
	},
	{
		"modal-event.lua",
		{ "widgets", 2, "children"},
		{
			name = [[optionBtn6]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 1,
			xpx = true,
			y = -48,
			ypx = true,
			w = 500,
			wpx = true,
			h = 38,
			hpx = true,
			sx = 1,
			sy = 1,
			ctor = [[button]],
			clickSound = [[SpySociety/HUD/menu/click]],
			hoverSound = [[SpySociety/HUD/menu/rollover]],
			hoverScale = 1,
			halign = MOAITextBox.CENTER_JUSTIFY,
			valign = MOAITextBox.CENTER_JUSTIFY,
			text_style = [[font1_16_r]],
			images =
			{
				{
					file = [[white.png]],
					name = [[inactive]],
					color =
					{
						0.219607844948769,
						0.376470595598221,
						0.376470595598221,
						1,
					},
				},
				{
					file = [[white.png]],
					name = [[hover]],
					color =
					{
						0.39215686917305,
						0.690196096897125,
						0.690196096897125,
						1,
					},
				},
				{
					file = [[white.png]],
					name = [[active]],
					color =
					{
						0.39215686917305,
						0.690196096897125,
						0.690196096897125,
						1,
					},
				},
			},			--
		},	
	},	
	{
		"modal-event.lua",
		{ "widgets", 2, "children"},
		{
			name = [[optionBtn7]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 1,
			xpx = true,
			y = 0,
			ypx = true,
			w = 500,
			wpx = true,
			h = 38,
			hpx = true,
			sx = 1,
			sy = 1,
			ctor = [[button]],
			clickSound = [[SpySociety/HUD/menu/click]],
			hoverSound = [[SpySociety/HUD/menu/rollover]],
			hoverScale = 1,
			halign = MOAITextBox.CENTER_JUSTIFY,
			valign = MOAITextBox.CENTER_JUSTIFY,
			text_style = [[font1_16_r]],
			images =
			{
				{
					file = [[white.png]],
					name = [[inactive]],
					color =
					{
						0.219607844948769,
						0.376470595598221,
						0.376470595598221,
						1,
					},
				},
				{
					file = [[white.png]],
					name = [[hover]],
					color =
					{
						0.39215686917305,
						0.690196096897125,
						0.690196096897125,
						1,
					},
				},
				{
					file = [[white.png]],
					name = [[active]],
					color =
					{
						0.39215686917305,
						0.690196096897125,
						0.690196096897125,
						1,
					},
				},
			},
		},	
	},	
	{
		"modal-event.lua",
		{ "widgets", 2, "children"},
		{
			name = [[optionBtn8]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 1,
			xpx = true,
			y = 48,
			ypx = true,
			w = 500,
			wpx = true,
			h = 38,
			hpx = true,
			sx = 1,
			sy = 1,
			ctor = [[button]],
			clickSound = [[SpySociety/HUD/menu/click]],
			hoverSound = [[SpySociety/HUD/menu/rollover]],
			hoverScale = 1,
			halign = MOAITextBox.CENTER_JUSTIFY,
			valign = MOAITextBox.CENTER_JUSTIFY,
			text_style = [[font1_16_r]],
			images =
			{
				{
					file = [[white.png]],
					name = [[inactive]],
					color =
					{
						0.219607844948769,
						0.376470595598221,
						0.376470595598221,
						1,
					},
				},
				{
					file = [[white.png]],
					name = [[hover]],
					color =
					{
						0.39215686917305,
						0.690196096897125,
						0.690196096897125,
						1,
					},
				},
				{
					file = [[white.png]],
					name = [[active]],
					color =
					{
						0.39215686917305,
						0.690196096897125,
						0.690196096897125,
						1,
					},
				},
			},
		},	
	},	
}

return 
{ 
inserts_exec = inserts_exec,
inserts_ai_term = inserts_ai_term 
}