local shop_panel = include( "hud/shop_panel" ).shop

local oldInit = shop_panel.init
function shop_panel:init( hud, shopperUnit, shopUnit, ... )
	oldInit( self, hud, shopperUnit, shopUnit, ... )

	if shopUnit:getTraits().luxuryNanofab and type(shopUnit:getTraits().luxuryNanofab) == "string" then
		local label = shopUnit:getTraits().luxuryNanofab
		self._screen.binder.shop.binder.augments.binder.titleLbl:setText(label)
		self._screen.binder.shop.binder.weapons.binder.titleLbl:setText(label)
		self._screen.binder.shop.binder.items.binder.titleLbl:setText(label)
	end
end
