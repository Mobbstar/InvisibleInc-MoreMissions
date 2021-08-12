local util = include("modules/util")
local simdefs = include("sim/simdefs")

-- COPIED FROM INTERACTIVE EVENTS BY CYBERBOY2000

local i = 13

simdefs.SCREEN_CUSTOMS = util.extend(simdefs.SCREEN_CUSTOMS) {
	["modal-event.lua"] = {
		widgets = {
			[2] = {
				children = {
					[i] = {
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
					[i+1] = {
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
						},
					},
					[i+2] = {
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
					[i+3] = {
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
				}
			}
		}
	}
}

return simdefs