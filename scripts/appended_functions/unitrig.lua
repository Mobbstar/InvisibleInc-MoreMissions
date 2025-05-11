local animmgr = include( "anim-manager" )
local util = include( "client_util" )
local cdefs = include( "client_defs" )
local mathutil = include( "modules/mathutil" )
local rig_util = include( "gameplay/rig_util" )
local rand = include( "modules/rand" )
local binops = include( "modules/binary_ops" )
local unitrig = include( "gameplay/unitrig" )
local coverrig = include( "gameplay/coverrig" )
local world_hud = include( "hud/hud-inworld" )
local flagui = include( "hud/flag_ui" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local modalDialog = include( "states/state-modal-dialog" )
local animdefs = include( "animdefs" )

local oldrefreshProp = unitrig.rig.refreshProp
local olddestroy = unitrig.rig.destroy

unitrig.rig.refreshProp = function( self, refreshLoc )
	local unit = self:getUnit()
	local ret = oldrefreshProp( self, refreshLoc )
	if unit:getTraits().staticAnim then
		self:setPlayMode( KLEIAnim.STOP )
	end

	if not self._droidFX then
		self._droidFX = self:createHUDProp("kanim_null_fx", "effect", "idle", self._boardRig:getLayer("floor"), self._prop )
		self._droidFX:setSymbolModulate("innercicrle",1,1,1,0.75)
		self._droidFX:setSymbolModulate("innerring",1,1,1,0.75)
		self._droidFX:setVisible(false)
	end
	if unit:getTraits().MM_nullFX and unit:getTraits().mainframe_status == "active" then
		self._droidFX:setVisible(true)
	else
		self._droidFX:setVisible(false)
	end

	return ret
end

unitrig.rig.destroy = function( self )
	olddestroy( self )
	if self._droidFX then
		self._boardRig:getLayer("floor"):removeProp( self._droidFX  )
	end
end
