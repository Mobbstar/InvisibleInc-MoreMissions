local modifications = {
	-- TEMPLATE
	-- {
		-- "generation-options.lua",
		-- { "skins", 4, "children" },
		-- {
			-- [2] = {
				-- x = -20,
				-- w = 461,
			-- },
			-- [3] = {
				-- x = 221,
			-- },
		-- }
	-- },

	{
		"modal-execterminals.lua",
		{ "widgets", 2, "children"},
		{
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
		}
	},
	
	{
		"modal-execterminals.lua",
		{ "widgets", 2, "children", 1, "images" },
		{
			[1] = 
			{
				file = [[gui/menu pages/shop/execterminals_MM.png]]
			}
		}
	},
}


return modifications