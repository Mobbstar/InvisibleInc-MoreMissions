local util = include("modules/util")
local simdefs = include("sim/simdefs")

local function overrideExecDialog()
--Replace exec terminal mission selection window with one that allows 6 missions
simdefs.SCREEN_CUSTOMS = util.extend(simdefs.SCREEN_CUSTOMS) {
	["modal-execterminals.lua"] =
	{
		widgets = 
		{
			[2] = 
			{
				children = 
				{
					[1] = --bg
					{
						images =
						{
							[1] = 
							{
								file = [[gui/menu pages/shop/execterminals_MM.png]]
							}
						}
					},
					[2] = --objTxt
					{
						y = 195, --124 > moved up 71 px
					},
					[3] = --titleTxt
					{
						y = 289,
					},
					[4] = --portrait
					{
						y = 176,
					},
					[5] = --location 1, etc.
					{
						y = 44,
						x = -85, --PATCH! -6
					},
					[6] = 
					{
						y = 44,
						x = 247,--PATCH! -2
					},
					[7] =
					{
						y = - 100,
						x = -85,
					},
					[8] = --location 4
					{
						y = - 100,
						x = 247,
					},
					[9] = --target title
					{
						y = 119,
					},		
					[10] = --NEW: location 5
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
					[11] = --NEW:location 6
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
				}
			}
		}
	}
}
end

local function resetExecDialog()
simdefs.SCREEN_CUSTOMS = util.extend(simdefs.SCREEN_CUSTOMS) {
	["modal-execterminals.lua"] =
	{
		widgets = 
		{
			[2] = 
			{
				children = 
				{
					[1] = --bg
					{
						images =
						{
							[1] = 
							{
								file = [[gui/menu pages/shop/execterminals.png]]
							}
						}
					},
					[2] = --objTxt
					{
						y = 124,
					},
					[3] = --titleTxt
					{
						y = 218,
					},
					[4] = --portrait
					{
						y = 105,
					},
					[5] = --location 1
					{
						y = -27,
						x = -85, --PATCH! -7
					},
					[6] = 
					{
						y = -27, --location 2
						x = 247,--PATCH! -2
					},
					[7] =	 --location 3
					{
						y = - 171,
						x = -85,
					},
					[8] = --location 4
					{
						y = - 171,
						x = 247,
					},
					[9] = --target title
					{
						y = 48,
					},		
					[10] = --NEW: location 5: can't remove these entries via util.extend so just set them to invisible and non-interactable
					{	
						name = [[location4]],
						isVisible = false,
						noInput = true,
						anchor = 1,
						rotation = 0,
						x = 250,
						xpx = true,
						y = -171,
						ypx = true,
						w = 0,
						h = 0,
						sx = 1,
						sy = 1,
						skin = [[Group]],					
					},
					[11] = --NEW:location 6
					{
						name = [[location4]],
						isVisible = false,
						noInput = true,
						anchor = 1,
						rotation = 0,
						x = 250,
						xpx = true,
						y = -171,
						ypx = true,
						w = 0,
						h = 0,
						sx = 1,
						sy = 1,
						skin = [[Group]],					
					},
				}
			}
		}
	}
}
end

return
{
	overrideExecDialog = overrideExecDialog,
	resetExecDialog = resetExecDialog,
}