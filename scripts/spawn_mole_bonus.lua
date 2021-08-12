local util = include( "modules/util" )
local serverdefs = include( "modules/serverdefs" )
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )
local abilitydefs = include( "sim/abilitydefs" )
local simquery = include ( "sim/simquery" )
-- local itemdefs = include ("sim/unitdefs/itemdefs")
local abilityutil = include( "sim/abilities/abilityutil" )
local cdefs = include( "client_defs" )


local function spawnMoleBonus( sim, mole_insertion )
	-- log:write(util.stringize(sim:getParams().agency.MM_informant_bonus,2))
	local MM_informant_bonus = sim:getParams().agency.MM_informant_bonus
	if MM_informant_bonus and (#MM_informant_bonus > 0) then
		local possible_bonuses = util.tcopy(mole_insertion.bonus_types)
		for k,v in pairs(MM_informant_bonus) do	
		
			if #possible_bonuses > 0 then
				sim:getLevelScript():queue( 1.5*cdefs.SECONDS )
				-- log:write("LOG possible bonus")
				-- log:write(util.stringize(possible_bonuses,2))
								
				local missionsLeft = v.missions_left - 1 --this tickdown is only for UI event purposes; for seed preservation reasons, wait until end of mission to actually update the ticker
				local randBonus = sim:nextRand(1,#possible_bonuses)
				-- log:write("LOG randBonus is"..tostring(randBonus))
				local bonus_type = possible_bonuses[randBonus]
				table.remove(possible_bonuses, randBonus) --don't spawn the same one
				mole_insertion.revealMoleBonus(sim, bonus_type) -- dispatch bonus
				--handle UI event
				local mole_head = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.MOLE_DAEMON_HEAD
				local mole_title = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.MOLE_DAEMON_TITLE
				local mole_text = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.MOLE_DAEMON_TXT .. STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.INTEL_TYPES[bonus_type]
				
				local dialogParams = 
				{
					mole_head,
					mole_title,
					mole_text,
					"gui/icons/UI_icons/icon_moleBonus.png",
					color = {r=0,g=0,b=1,a=1}				
				}
				
				sim:dispatchEvent( simdefs.EV_SHOW_DIALOG, { dialog = "programDialog", dialogParams = dialogParams } )
				sim:getNPC():addMainframeAbility( sim, "MM_informant_intel", nil, 0 )
				-- now modify the newly-spawned daemon with customised text info
				for i,ability in pairs( sim:getNPC():getAbilities() ) do
					if (ability._abilityID == "MM_informant_intel") and not ability.MM_mole_checked then
						-- log:write("LOG editing bonus desc")
						ability.MM_mole_checked = true
						-- ability.desc = util.sformat(ability.desc, missionsLeft)
						-- ability.shortdesc = STRINGS.MOREMISSIONS.DAEMONS.MOLE_DAEMON_EVENT.INTEL_TYPES[bonus_type]
						ability.missionsLeft = missionsLeft
						ability.bonus_type = bonus_type
					end
				end
			end
			
		end
	end
end

return spawnMoleBonus