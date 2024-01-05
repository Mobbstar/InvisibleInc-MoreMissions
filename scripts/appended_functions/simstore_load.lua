
local function addMoreMissionsStores()
	local simstore = include( "sim/units/store" )

	local storeTypes = simstore.STORE_ITEM.storeType
	simstore.STORE_ITEM.storeType.MM_luxuryItem = {
		itemAmount = 16,
		progAmount = 0,
		weaponAmount = 0,
		augmentAmount = 0,
	}
	simstore.STORE_ITEM.storeType.MM_luxuryWpn = {
		itemAmount = 0,
		progAmount = 0,
		weaponAmount = 16,
		augmentAmount = 0,
	}
	simstore.STORE_ITEM.storeType.MM_luxuryAug = {
		itemAmount = 0,
		progAmount = 0,
		weaponAmount = 0,
		augmentAmount = 16,
	}
end

return { addMoreMissionsStores = addMoreMissionsStores }
