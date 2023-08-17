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
			inheritDef =
			{
				["btn"] = { -- Unique ID for Controller Bindings mod.
					ctrlProperties = { id = [[location5]] },
				}
			},
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
			inheritDef =
			{
				["btn"] = { -- Unique ID for Controller Bindings mod.
					ctrlProperties = { id = [[location6]] },
				}
			},
			skin = [[Group]],				
		},	
	},	
}
if SCRIPT_PATHS.qedctrl then -- Controller Bindings mod support.
	local sutil = include(SCRIPT_PATHS.qedctrl.."/screen_util")

	table.insert(inserts_exec,
	{
		"modal-execterminals.lua",
		{ "properties", "ctrlProperties", "layouts", 1, "children" },
		sutil.widget([[location5]], {1,3}),
	})
	table.insert(inserts_exec,
	{
		"modal-execterminals.lua",
		{ "properties", "ctrlProperties", "layouts", 1, "children" },
		sutil.widget([[location6]], {2,3}),
	})
end

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
			name = [[optionList]],
			isVisible = false,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = -10,
			xpx = true,
			y = -190,
			ypx = true,
			w = 500,
			wpx = true,
			h = 240,
			hpx = true,
			sx = 1,
			sy = 1,
			ctor = [[listbox]],
			item_template = [[optionListElement]],
			scrollbar_template = [[listbox_vscroll]],
			orientation = 2,
			item_spacing = 48,
			images =
			{
			{
				file = [[]],
				name = [[inactive]],
				},
				{
				file = [[]],
				name = [[active]],
				},
				{
				file = [[]],
				name = [[hover]],
				},
			},
		},
	},
	{
		"modal-event.lua",
		{ "skins" },
		{
			name = [[optionListElement]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 0,
			y = 0,
			w = 0,
			h = 0,
			sx = 1,
			sy = 1,
			ctor = [[group]],
			children =
			{
				{
					name = [[optionListBtn]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = 1,
					xpx = true,
					y = 0,
					ypx = true,
					w = 480,
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
		},
	},
	{
		"mission_preview_dialog.lua",
		{ "widgets", 2, "children"  },
		{
			name = [[MM_informantBonus]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 598,
			xpx = true,
			y = -902,
			ypx = true,
			w = 0,
			h = 0,
			sx = 2.23,
			sy = 2.23,
			ctor = [[group]],
			children =
			{
				{
					name = [[moleIconBG]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = -330,
					xpx = true,
					y = 312,
					ypx = true,
					w = 65,
					wpx = true,
					h = 65,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[image]],
					color =
					{
						1,
						1,
						1,
						1,
					},
					images =
					{
						{
							file = [[gui/menu pages/map_screen/missionbriefing_window_mole.png]],
							name = [[]],
						},
					},
				},
				{
					name = [[moleIcon]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = -330,
					xpx = true,
					y = 310,
					ypx = true,
					w = 65,
					wpx = true,
					h = 65,
					hpx = true,
					sx = 0.85,
					sy = 0.85,
					ctor = [[image]],
					-- color =
					-- {
						-- 1,
						-- 1,
						-- 1,
						-- 1,
					-- },
					{ --bluish
						0.278431385755539,
						0.498039215803146,
						0.498039215803146,
						0.7843137383461,
					},					
					images =
					{
						{
							file = [[gui/menu pages/map_screen/missionbriefing_window_mole_icon.png]],
							name = [[]],
						},
					},
				},					
			},
		},		
	},
	{
		"mission_preview_dialog.lua",
		{ "widgets", 2, "children" },
		{
			name = [[MM_informantInfo]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 284,
			xpx = true,
			y = -516,
			ypx = true,
			w = 0,
			h = 0,
			sx = 1,
			sy = 1,
			ctor = [[group]],
			children =
			{
				{
					name = [[moleDesc]], --"Informant intel available"
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = -96,
					xpx = true,
					y = 240,
					ypx = true,
					w = 360,
					wpx = true,
					h = 100,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[label]],
					halign = MOAITextBox.LEFT_JUSTIFY,
					valign = MOAITextBox.LEFT_JUSTIFY,
					text_style = [[font1_14_r]],
				},
				{
					name = [[moleName]], --"INFORMANT"
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = -319,
					xpx = true,
					y = 353,
					ypx = true,
					w = 300,
					wpx = true,
					h = 40,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[label]],
					halign = MOAITextBox.LEFT_JUSTIFY,
					valign = MOAITextBox.CENTER_JUSTIFY,
					text_style = [[font1_16_sb]],
					color =
					{ --bluish
						0.278431385755539,
						0.498039215803146,
						0.498039215803146,
						1, --0.7843137383461,
					},				
				},				
			},
		},
	},
	{
		"mission_preview_dialog.lua",
		{ "widgets", 2, "children"  },
		{
			name = [[MM_PE_hostileAI]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 1167,
			xpx = true,
			y = -902,
			ypx = true,
			w = 0,
			h = 0,
			sx = 2.23,
			sy = 2.23,
			ctor = [[group]],
			children =
			{
				{
					name = [[PEiconBG]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = -330,
					xpx = true,
					y = 312,
					ypx = true,
					w = 65,
					wpx = true,
					h = 65,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[image]],
					color =
					{
						1,
						1,
						1,
						1,
					},
					images =
					{
						{
							file = [[gui/menu pages/map_screen/missionbriefing_window_mole.png]],
							name = [[]],
						},
					},
				},
				{
					name = [[PE_icon]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = -330,
					xpx = true,
					-- y = 314, -- this is perfectly centered
					y = 312, --this is slightly lower to make space for header
					ypx = true,
					w = 65,
					wpx = true,
					h = 65,
					hpx = true,
					sx = 0.85,
					sy = 0.85,
					ctor = [[image]],
					{
						0.278431385755539,
						0.498039215803146,
						0.498039215803146,
						0.7843137383461,
					},					
					images =
					{
						{
							file = [[gui/menu pages/map_screen/mission_briefing_pe_ai.png]],
							name = [[]],
						},
					},
				},
                   {
                        name = [[AIdifficultyShield]],
                        isVisible = true,
                        noInput = false,
                        anchor = 1,
                        rotation = 0,
                        x = -317,
                        xpx = true,
                        y = 300,
                        ypx = true,
                        w = 65,
                        wpx = true,
                        h = 65,
                        hpx = true,
                        sx = 0.4,
                        sy = 0.4,
                        ctor = [[image]],
                        color =
                        {
                            1,
                            1,
                            1,
                            1,
                        },
                        images =
                        {
                            {
                                file = [[gui/menu pages/map_screen/shield1.png]],
                                name = [[]],
                            },
                        },
                    },				
			},
		},		
	},
	{
		"mission_preview_dialog.lua",
		{ "widgets", 2, "children" },
		{
			name = [[MM_PE_hostileAI_label]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 284,
			xpx = true,
			y = -516,
			ypx = true,
			w = 0,
			h = 0,
			sx = 1,
			sy = 1,
			ctor = [[group]],
			children =
			{
				{
					name = [[PE_AI_name]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = 255,
					xpx = true,
					y = 353,
					ypx = true,
					w = 300,
					wpx = true,
					h = 40,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[label]],
					halign = MOAITextBox.LEFT_JUSTIFY,
					valign = MOAITextBox.CENTER_JUSTIFY,
					text_style = [[font1_16_sb]],
					color =
					{ --yellow
						0.960784316062927,
						1,
						0.470588237047195,
						1,
					},					
					-- color =
					-- { --orange
						-- 244/255,
						-- 129/255,
						-- 52/255,
						-- 1, --0.7843137383461,
					-- },				
				},	
				{
                        name = [[hostileAIface]],
                        isVisible = false, --WIP
                        noInput = false,
                        anchor = 1,
                        rotation = 0,
                        x = 180,
                        xpx = true,
                        y = 355,
                        ypx = true,
                        w = 0,
                        h = 0,
                        sx = 1,
                        sy = 1,
                        ctor = [[group]],
                        children =
                        {
                            {
                                name = [[centralbg]],
                                isVisible = true,
                                noInput = false,
                                anchor = 1,
                                rotation = 0,
                                x = -34,
                                xpx = true,
                                y = -44,
                                ypx = true,
                                w = 104,
                                wpx = true,
                                h = 104,
                                hpx = true,
                                sx = 1,
                                sy = 1,
                                ctor = [[anim]],
                                animfile = [[gui/hud_portrait_bg_effect]],
                                symbol = [[effect]],
                                anim = [[idle]],
                                color =
                                {
                                    0.317647069692612,
                                    0.545098066329956,
                                    0.549019634723663,
                                    0.470588237047195,
                                },
                            },
                            {
                                name = [[hostileAIportrait]],
                                isVisible = true,
                                noInput = false,
                                anchor = 1,
                                rotation = 0,
                                x = -31,
                                xpx = true,
                                y = -41,
                                ypx = true,
                                w = 330,
                                wpx = true,
                                h = 315,
                                hpx = true,
                                sx = 0.25,
                                sy = 0.28,
                                -- scissor =
                                -- {
                                    -- -- -150,
                                    -- -- -200,
                                    -- -- 202,
                                    -- -- 300,
                                    -- -200,
                                    -- -200,
                                    -- 202,
                                    -- 300,									
                                -- },
                                ctor = [[anim]],
                                -- animfile = [[portraits/sankaku_ai]],
								animfile = [[portraits/central_face]],
                                symbol = [[character]],
                                anim = [[idle]],
                                color =
                                {
                                    1,
                                    1,
                                    1,
                                    1,
                                },
                            },
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
