local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )
local simdefs = include( "sim/simdefs" )

local transformer_terminal = abilitydefs.lookupAbility("transformer_terminal")
transformer_terminal.HUDpriority = 3		
transformer_terminal.profile_icon = "gui/icons/action_icons/Action_icon_Small/icon-item_hijack_small_15PWR.png"