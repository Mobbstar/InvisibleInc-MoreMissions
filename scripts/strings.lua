local _M =
{
-- agentIDs list:

-- 	NAME = agentID	-- just for convenience: agentID is a number or string, name is easier to use
--	DECK = 0, -- tutorial

	DECKER = 1,		-- Decker
	SHALEM = 2,		-- Shalem
	TONY = 3,		-- Xu
	BANKS = 4,		-- Banks
	INTERNATIONALE = 5,	-- Internationale
	NIKA = 6,		-- Nika
	SHARP = 7,		-- Sharp
	PRISM = 8,		-- Prism

	MONSTER = 100,		-- starting
	CENTRAL = 108,		-- starting

	OLIVIA = 1000,
	DEREK = 1001,
	RUSH = 1002,
	DRACO = 1003,

	AGENT009 = "agent009", --fake ID
}

return {
	OPTIONS =
	{
		EXEC_TERMINAL = "EXECUTIVE TERMINALS",
		EXEC_TERMINAL_TIP = "<c:FF8411>EXECUTIVE TERMINALS</c>\nThis kind of mission is available in the base game. Feel free to disable it.\nThe first mission will be unaffected.",
		CFO_OFFICE = "CHIEF FINANCIAL SUITE",
		CFO_OFFICE_TIP = "<c:FF8411>CHIEF FINANCIAL SUITE</c>\nThis kind of mission is available in the base game. Feel free to disable it.",
		CYBERLAB = "CYBERNETICS LAB",
		CYBERLAB_TIP = "<c:FF8411>CYBERNETICS LAB</c>\nThis kind of mission is available in the base game. Feel free to disable it.",
		DETENTION = "DETENTION CENTER",
		DETENTION_TIP = "<c:FF8411>DETENTION CENTER</c>\nThis kind of mission is available in the base game. Feel free to disable it.",
		NANOFAB = "NANOFAB VESTIBULE",
		NANOFAB_TIP = "<c:FF8411>NANOFAB VESTIBULE</c>\nThis kind of mission is available in the base game. Feel free to disable it.",
		SECURITY = "SECURITY DISPATCH",
		SECURITY_TIP = "<c:FF8411>SECURITY DISPATCH</c>\nThis kind of mission is available in the base game. Feel free to disable it.",
		SERVER_FARM = "SERVER FARM",
		SERVER_FARM_TIP = "<c:FF8411>SERVER FARM</c>\nThis kind of mission is available in the base game. Feel free to disable it.",
		VAULT = "VAULT",
		VAULT_TIP = "<c:FF8411>VAULT</c>\nThis kind of mission is available in the base game. Feel free to disable it.",

		ASSASSINATION = "ASSASSINATION",
		ASSASSINATION_TIP = "<c:FF8411>ASSASSINATION</c>\nProvides credits. Similiar to research experiments in Vaults, except the object is heavier, and bleeding.",
		HOLOSTUDIO = "HOLOSTUDIO",
		HOLOSTUDIO_TIP = "<c:FF8411>HOLOSTUDIO</c>\nProvides advanced Holo-Projectors. Similiar to Security Dispatch.",
		LANDFILL = "SALVAGING PLANT",
		LANDFILL_TIP = "<c:FF8411>SALVAGING PLANT</c>\nProvides disliked items at heavy discounts. Similiar to Nanofab Vestibule.",
		DISTRESSCALL = "DISTRESS CALL",
		DISTRESSCALL_TIP = "<c:FF8411>DISTRESS CALL</c>\nProvides a chance at an agent and their gear but the alarm rises quickly.",
		WEAPONSEXPO = "TECH EXPO",
		WEAPONSEXPO_TIP = "<c:FF8411>TECH EXPO</c>\nProvides powerful weapons protected by advanced security measures.",

		ITEMS_IN_STORE = "ITEMS IN STORES",
		ITEMS_IN_STORE_TIP = "<c:FF8411>ITEMS IN STORES</c>\nAllows the new exclusive items to spawn in nanofabs and such, making them not exclusive anymore.",
	},

	PROPS =
	{
		-- RECHARGE_STATION = "Phone Recharge Socket",
	},

	GUARDS =
	{
		BOUNTY_TARGET = "Bounty Target",
		PROTOTYPE_DROID = "Prototype Android",
		PROTOTYPE_DROID_SPEC = "Prototype SpecDroid",
	},


	AGENTS =
	{
		AGENT_009 =
		{
			NAME = "Agent-OO9",
			BANTER =
			{
				START = {
					"",
				},
				FINAL_WORDS =
				{
					"...",--need to come up with sth here
				},
			},
		},
		
		EA_HOSTAGE = 
		{
			NAME = "Johnny W.",
		},
	},

	ITEMS =
	{
		-- KEYCARD_BLUE = "Blue Keycard",
		-- KEYCARD_BLUE_TIP = "Unlocks blue doors.",
		-- KEYCARD_BLUE_FLAVOR = "Created using only state-of-the-art technology, this piece of plastic has a deep marine hue.",

		HOLOGRENADE_HD = "HD Projector",
		HOLOGRENADE_HD_TIP = "Throw to place a tall fake cover item. Activate in mainframe. Uses charge every turn. Can be recovered.",
		HOLOGRENADE_HD_FLAVOR = "Circus acts and theatre make up for the lack of postproduction by using convincing High-Density Holograms.",

		LAPTOP_HOLO = "VFX Laptop",
		LAPTOP_HOLO_TIP = "Deploy to place a fake cover item. Generates 1 PWR per turn while deployed. The projector can be heard 1 tile away.",
		LAPTOP_HOLO_FLAVOR = "The more complex scenes in Holowood are created using highly programmable hologram projectors to compute realtime interaction with actors. This one lacks scripts, but the processors are still useful.",

		DISGUISE_CHARGED = "Subsidiary Holo Mesh",
		DISGUISE_CHARGED_TIP = "Generates a disguise while active.\nSprinting and attacking disables the effect.\nDisguise will fail if an enemy observes from 1 tile away.\nUses charge every turn.",
		DISGUISE_CHARGED_FLAVOR = "An expensive piece of hardware commonly used in the Holovid industry. Often disdained like lip-syncing on a stage.",

		ITEM_TAZER_OLD = "Worn Neural Disrupter",
		-- ITEM_TAZER_OLD_TIP = "",
		ITEM_TAZER_OLD_FLAVOR = "This disrupter is worn out, but still finds use as a \"persuasion\" tool.",

		DISCARDED_MANACLES = "Discarded Manacles",
		DISCARDED_MANACLES_TOOLTIP = "Secured in place. Alerts the captain when seen.",
		DISCARDED_MANACLES_FLAVOR = "An empty space, where a prisoner is supposed to be restrained.",

	},

	-- ACTIONS =
	-- {
		-- UNLOCK_BLUE = "Hyper-Unlock",
		-- UNLOCK_BLUE_TIP = "Unlock this door so hard, it stays open forever.",
	-- },

	-- DAEMONS =
	-- {
		-- CHITON =
		-- {
			-- NAME = "CHITON",
			-- DESC = "All guards get +1 ARMOR.",
			-- SHORT_DESC = "Boost Guard ARMOR",
			-- ACTIVE_DESC = "Guards have +1 ARMOR",
		-- },
	-- },

	-- PROGRAMS =
	-- {
		-- MANHACK =
		-- {
			-- NAME = "MANHACK",
			-- DESC = "Breaks X FIREWALL for 2 PWR. X is how many consoles are currently being used.",
			-- SHORT_DESC = "Uses consoles to break Firewalls",
			-- HUD_DESC = "BREAKS ONE FIREWALL FOR EVERY CONSOLE USED",
			-- TIP_DESC = "BREAKS <c:FF8411>{1} FIREWALLS</c>, COSTS 2 PWR",
		-- },
		-- CYCLE =
		-- {
			-- NAME = "CYCLE",
			-- DESC = "All PWR is cleared at the beginning of each turn, then Gain 3 PWR.\nPASSIVE",
			-- SHORT_DESC = "All PWR is cleared each turn. Auto generate large PWR.",
			-- HUD_DESC = "ALL PWR IS CLEARED AT THE BEGINNING OF EACH TURN.\nTHEN GAIN 3 PWR PER TURN.",
			-- TIP_DESC = "All PWR is cleared at the beginning of each turn, then gain 3 PWR.",
			-- WARNING = "POWER CYCLED\n3 PWR",
		-- },
	-- },


	MISSIONS = {
		ASSASSINATION = {
			OBJ_FIND = "Locate the target",
			OBJ_KILL = "Eliminate the target",
			OBJ_UNLOCK = "Unlock the secure door",
			SECUREDOOR_TIP = "UNLOCK USING AUTHORIZED BODY",
		},
		MOLE = {
		    OBJ_KILL_WITNESS = "Kill any eyewitnesses",
			WITNESS_DETECTED = "WITNESS DETECTED"
		}
	},

	LOCATIONS = {
		--used by serverdefs.lua
		HOLOSTUDIO = {
			NAME= "Holostudio",
			MORE_INFO = "This site features its own dedicated holographic design laboratory. Our agents can steal and use some of the advanced tech here to deceive and evade.\n\nSome of these items are not available at any nanofabs.", --This can be quite lengthy.
			INSET_TITLE = "MARKETING AGENCY", --unused
			INSET_TXT = "I'm not going to lie, operator. There's an awful lot of unused flavour text in these files.", --unused
			INSET_VO = {"SpySociety_DLC001/VoiceOver/Central/DLC_Central_6_midmission_briefing_imnotgoing"},
			DESCRIPTION = "Locate and acquire state-of-the-art hologram technology.",
			REWARD = "A powerful disguise or stealth tool.",
			-- LOADING_TIP = "",
		},
		ASSASSINATION = {
			NAME= "Assassination",
			MORE_INFO = "A person at this location has a high bounty on their head.\n\nThe target is reportedly paranoid, with personal security on-site. Be wary.", --This can be quite lengthy.
			INSET_TITLE = "MARKED FOR DEATH", --unused
			INSET_TXT = "I'm not going to lie, operator. There's an awful lot of unused flavour text in these files.", --unused
			INSET_VO = {"SpySociety_DLC001/VoiceOver/Central/DLC_Central_6_midmission_briefing_imnotgoing"},
			DESCRIPTION = "Locate and kill the VIP.",
			REWARD = "1200 Credits.",
		},
		LANDFILL = {
			--This one is supposed to hold only items the operator doesn't normally have, but there's no way to lore-ify that information, is there? -M
			NAME= "Salvaging plant",
			MORE_INFO = "Tons of various objects get dumped on this landfill and ground up for whatever materials can be recovered. Some of the items can probably be repaired inexpensively.\n\nDon't expect the goods to be very likable, many of them have been here for weeks without getting any love.", --This can be quite lengthy.
			INSET_TITLE = "LANDFILL", --unused
			INSET_TXT = "I'm not going to lie, operator. There's an awful lot of unused flavour text in these files.", --unused
			INSET_VO = {"SpySociety_DLC001/VoiceOver/Central/DLC_Central_6_midmission_briefing_imnotgoing"},
			DESCRIPTION = "Find and access the repair workstation.",
			REWARD = "A range of heavily discounted items.",
		},
		EA_HOSTAGE = STRINGS.MOREMISSIONS_HOSTAGE.EA_HOSTAGE,

		DISTRESS_CALL = {
			NAME= "Distress Call",
			MORE_INFO = "We've intercepted a signal suggesting an operative in need of extraction at this facility. It may be one of our missing agents, and if not, we can still negotiate a suitable compensation from them once we get them out safely. \n\nBe careful, Operator - our telemetry suggests the facility is already on high alert, and the alarm level will advance more quickly as a result.", --This can be quite lengthy.
			INSET_TITLE = "OPERATIVE EXTRACTION", --unused
			INSET_TXT = "I'm not going to lie, operator. There's an awful lot of unused flavour text in these files.", --unused
			INSET_VO = {""}, --{"SpySociety_DLC001/VoiceOver/Central/DLC_Central_6_midmission_briefing_imnotgoing"},			
			DESCRIPTION = "Get the escaped operative safely to extraction and grab their confiscated gear on the way out. Alarm level will increase more quickly here.",
			REWARD = "Agent or prisoner rescue with valuable items.",
		},

		WEAPONS_EXPO = {
			NAME= "Tech Expo",
			MORE_INFO = "This facility is hosting a world class tier tech exposition. The corporations and their industry finest will be showing off their newest weapon prototypes. We should be able to nab us some prize gear, provided we visit after hours.\n\nKeep your guard up - word has it their security system is as experimental as the tech they're showcasing.", --This can be quite lengthy.
			INSET_TITLE = "WEAPONS EXPO", --unused
			INSET_TXT = "I'm not going to lie, operator. There's an awful lot of unused flavour text in these files.", --unused unless we actually get these voiced somehow
			INSET_VO = {"SpySociety_DLC001/VoiceOver/Central/DLC_Central_6_midmission_briefing_imnotgoing"},
			DESCRIPTION = "Locate the main exhibition center and steal at least one prototype.",
			REWARD = "Advanced melee or ranged weapons you can sell or use as equipment.",
		},

	},

	UI = {
		HUD_WARN_EXIT_MISSION_HOLOSTUDIO = "Are you sure you want to leave? You don't have the holographic tool yet.",
		HUD_WARN_EXIT_MISSION_ASSASSINATION = "Are you sure you want to leave? You don't have the target body.",
		-- REASON = {
			-- HYPERUNLOCKED = "Busted open by a blue keycard",
		-- },
		DISTRESS_OBJECTIVE = "Rescue the operative",
		DISTRESS_OBJECTIVE_SECONDARY = "Find the operative's gear",
		DISTRESS_AGENT_GEAR_CONTAINER = "SIGNAL DETECTED",
		DISTRESS_AGENT_GEAR_CONTAINER_DESC = "VALUABLE EQUIPMENT", --should probably go under MISSIONS above but we can tidy things later...
		WEAPONS_EXPO_OBJECTIVE = "Locate and steal weapon prototypes",
		WEAPONS_EXPO_EMP_SAFE = "Cannot loot while device is disabled",
		WEAPONS_EXPO_WARN_EXIT = "Are you sure you want to leave? You haven't stolen any of the weapon prototypes yet.",
		WEAPONS_EXPO_FIREWALLS = "SECURITY FAILSAFE: FIREWALL BOOST",
		WEAPONS_EXPO_DROIDS_WARNING = "NEW THREAT",
		WEAPONS_EXPO_DROIDS_WARNING_SUB = "BOOTING...",
		WEAPONS_EXPO_SWITCHES_OBJECTIVE = "Activate relay switches to disable the firewall boost",
		WEAPONS_EXPO_FIND_SWITCHES = "Find a way to disable the firewall boost",
		
		TOOLTIPS = {
			WEAPONS_EXPO_RESALE = "HARD TO FENCE",
			WEAPONS_EXPO_RESALE_DESC = "This prototype is not market-ready and can only be sold at half price.",
			EA_HOSTAGE_FRAIL = "FRAIL",
			EA_HOSTAGE_FRAIL_DESC = "KO damage is lethal.",
			EA_HOSTAGE_VITAL_STATUS = "VITAL STATUS",
			EA_HOSTAGE_VITAL_STATUS_DESC = "Will expire if not extracted in {1} {1:turn|turns}.",
		},	
		
	},

	AGENT_LINES =
	{
		DISTRESS_CALL =
		{
			[_M.AGENT009] = "The name's Lien. Jimmy Lien. \n\nI reckon we can help each other.",
			[_M.DECKER] = "Could use a lift.",
			[_M.INTERNATIONALE] = "Let's get out of here.",
			[_M.BANKS] = "You're a sight for sore eyes. Or ears, anyway.",
			[_M.NIKA] = "...\n\nHello again.",
			[_M.SHARP] = "I have things under control.\n\n...But you may assist me anyway.",
			[_M.SHALEM] = "Saves me the trouble of an exfiltration plan.",
			[_M.TONY] = "Excellent timing, Operator. I was just leaving.",
			[_M.PRISM] = "Good. It's about time we got things under control.",
			[_M.MONSTER] = "Have I mentioned I hate getting my hands dirty? Well, here I am, mentioning it again.",
			[_M.RUSH] = "Oh, good. I'm sick of sitting around, anyway.",
			[_M.DRACO] = "Your assistance is superfluous, but not unwelcome.",
			[_M.DEREK] = "I had a feeling you'd be here, nick of time and everything.",
			[_M.CENTRAL] = "There you are. Good timing. Now get me out of here.",
			[_M.OLIVIA] = "Good. I cannot spend another second in this place.",
		},
	},

	BANTER = {
		--automatically compiled by story_scripts.lua
		INGAME = {
			--Central's one-liners are technically speaking scripts with only one line, thus the nesting.
			HOLOSTUDIO = {
				OBJECTIVE_SIGHTED = {
					--stole some generic Security Dispatch line
					{{"You've found the secure lock-box. Time to open it up.",
						"SpySociety/VoiceOver/Missions/GenericLines/ObjectiveSighted_Dispatch_2",
						"Central"}},
					{{"There's the secure safe. You're almost done.",
						"SpySociety/VoiceOver/Missions/GenericLines/ObjectiveSighted_Dispatch_4",
						"Central"}},
				},
				AFTERMATH = {
					{{"The item was resting on a pressure plate. Except a gamma blast to briefly disrupt all our holograms soon.",
						"moremissions/VoiceOver/Central/holostudio/aftermath0",
						"Central"}},
				},
				CENTRAL_JUDGEMENT = {
					HASLOOT = {
						{{"Well done. Use this new toy to prevent dangerous situations from forming in the first place.",
							"moremissions/VoiceOver/Central/holostudio/judge/hasloot0",
							"Central"}},
						--also stole a generic Security Dispatch line
						{{"The more equipment we recover, the more tactical options we have in the field. Nice work.",
							"SpySociety/VoiceOver/Missions/PostMission/MissionComplete_Dispatch_GetThing_2",
							"Central"}},
					},
					NOLOOT = {
						{{"Did you let the holograms fool you? Search properly next time.",
							"moremissions/VoiceOver/Central/holostudio/judge/noloot0",
							"Central"}},
						--also stole all the generic Security Dispatch lines
						{{"You were supposed to find high-tech gear in that facility. Don't disappoint me again.",
							"SpySociety/VoiceOver/Missions/PostMission/MissionComplete_Dispatch_DidntGetThing_1",
							"Central"}},
						{{"The gear that you skipped over back there could mean the difference between life and death for our agents. That's on your head.",
							"SpySociety/VoiceOver/Missions/PostMission/MissionComplete_Dispatch_DidntGetThing_2",
							"Central"}},
					},
				},
			},

			ASSASSINATION = {
				OBJECTIVE_SIGHTED = {
					{{"That's the target. Get them.",
						"moremissions/VoiceOver/Central/assassination/seen0",
						"Central"}},
					{{"You found him. Don't let him get away.",
						"moremissions/VoiceOver/Central/assassination/seen1",
						"Central"}},
				},
				DOOR_SIGHTED = {
					{
						{"Interesting. Our target has prepared a secure room. Both the target and his bodyguard should have the codes to this door.",
							nil,
							"Central"},
						{"We don't have time to extract the codes, so you'll need to drag one of them up to the door. Their bodies should also deactivate the lasers as you pass.",
							nil,
							"Central"},
					},
				},
				DOOR_UNLOCKED = {
					{{"Good work, now let's see what he has in here.",
						nil,
						"Central"}},
				},
				KO = {
					{{"We don't earn partial credit here, operator. Find a way to finish the job.",
						nil,
						"Central"}},
				},
				AFTERMATH = {
					-- "Now make sure not to bump into any rival assassins on your way out."
					{{"So far, so good. Get our agents out of there and we can collect from the client.",
						"moremissions/VoiceOver/Central/assassination/aftermath0",
						"Central"}},
				},
				CENTRAL_JUDGEMENT = {
					GOTBODY = {
						-- "Tonight, we drink on X, who kindly pays in blood.",
						{{"This bounty will make for a crucial donation to our cause. Excellent!",
							"moremissions/VoiceOver/Central/assassination/judge/gotloot0",
							"Central"}},
						{{"We'll need to scrub the jet floor after this, but it is worthwile.",
							"moremissions/VoiceOver/Central/assassination/judge/gotloot1",
							"Central"}},
					},
					NOTDEAD = {
						{{"Target seems alive, but we can fix that. Good job.",
							"moremissions/VoiceOver/Central/assassination/judge/gotalive0",
							"Central"}},
					},
					-- GOTLOOT = {
						-- "No body, no bounty. At least we got a nice souvenir.",
						-- "Make good use of that equipment, it's the only thing we got from all this.",
					-- },
					GOTNOTHING = {
						{{"You didn't get what we came for. Perhaps you would like to offer your own head to our client?",
							"moremissions/VoiceOver/Central/assassination/judge/noloot0",
							"Central"}},
						{{"Now somebody else is going to get the bounty. Quit wasting precious time, operator!",
							"moremissions/VoiceOver/Central/assassination/judge/noloot1",
							"Central"}},
					},
				},
			},
			-- LANDFILL = {
				-- BOUGHT ={
					-- --stole all the generic Nanofab lines
					-- "Nice haul, Operator. Everything is useful, if you're resourceful enough.",
					--MissionComplete_Nanofab_Bought_1
					-- "I'm sure you considered your purchases carefully. Wouldn't want you wasting the company dime on useless dreck.",
				-- },
				-- SAW ={
					-- --stole a generic Serverfarm line
					-- "Didn't see anything to your liking, eh? I hope that doesn't come back to bite us.",
					--MissionComplete_ServerFarm_NoBuy_1
				-- },
				-- MISSED ={
					-- "Operator, get your head on straight. You didn't even check the workstation. We don't have the luxury of time to waste!",
					-- "We can make do with nanofabs, but the cheap items you missed at this facility would have saved much money for other improvements.",
				-- },
			-- },
			EA_HOSTAGE = STRINGS.MOREMISSIONS_HOSTAGE.INGAME,

			DISTRESS_CALL = {
				SAW_AGENT = {
				{{"There's our missing asset. Your objective is simple, Operator: Get that agent to the extraction point.",	nil,"Central"}},
				{{"But be careful - that little stunt won't have gone unnoticed. Their security level should start rising rapidly now.",nil,		"Central"}},
				},
				SAW_OTHER = {
				{{"We've made contact with the operative. He's not one of ours, but that doesn't mean he can't be useful. See if you can get him out; we can talk shop back on the jet.",
						nil,
						"Central"}},
				{{"But be careful - that little stunt won't have gone unnoticed. Their security level should start rising rapidly now.",nil,		"Central"}},
				},
				SAW_GEAR_CONTAINER = {
				{{"Incognita's heuristic model suggests they might have stashed our rescuee's equipment here. Let's have a look.",	nil,"Central"}},
				},
				CENTRAL_JUDGEMENT = {
					GOT_AGENT = {
					{{"That's one more pair of hands on the team. Excellent work, Operator.", nil, "Central"}},
					{{"We've shown them they can't keep our people locked up. Prepare that agent for the next mission, Operator. You've earned your keep today.", nil, "Central"}},
					{{"It's a good thing we were there to provide extraction. Now there's one more pair of hands on our side, and we're stronger for it.", nil, "Central"}},
					{{"That agent certainly made the rescue easy for us. I suppose a moment of professional pride is in order. Good work, everyone.",nil,"Central"}},
					},
					LOST_AGENT = {
					{{"Damn it, Operator! That agent had already sprung themselves free, all you had to do was walk in there and get them!", nil, "Central"}},
					{{"One day you'll find yourself in the same shoes as the agent you just abandoned. You should hope that day doesn't come soon.", nil, "Central"}},
					{{"This one is going on your permanent record.", nil, "Central"}}
					},
					GOT_OTHER = {
					{{"Extraction complete. We can find out on the jet who he works for and just how much he's worth to his employer.",nil, "Central"}},
					{{"Our mystery man is out. With any luck, we can negotiate a reward for the rescue.",nil,"Central"}},
					{{"A pity the operative wasn't one of ours, but we'll keep looking. Good work, Operator.",nil,"Central"}},
					},
					LOST_OTHER = {
					{{"Another opportunity squandered. You had better step up your game, Operator. You're lucky that wasn't one of our people you just abandoned.",nil,"Central"}},
					{{"We went in there for nothing. You better have a good explanation for this in debriefing.",nil,"Central"}},
					{{"A fruitless endeavour. That operative could have been of use to us in some manner. Too late for that now.",nil,"Central"}},
					},
				},
			},
			WEAPONS_EXPO = {
				FOUND_EXPO = {{{"Not so fast, Operator. Our scans show this room has advanced security failsafes.",nil,"Central"}},
				{{"The system will boost nearby firewalls if even one exhibit is compromised. See if you can find a way to disable it.",nil,"Central"}}},
				FOUND_EXPO_DISABLED_SEC = {{{"There's the exhibit. Their main failsafe should be offline now. Let's get to work.",nil,"Central"}}},				
				SAW_SWITCH = {{{"This security switch controls the failsafes protecting the exhibit. Find the other switch and activate both at the same time.",nil,"Central"}}},
				DISABLED_SWITCH = {{{"You've deactivated the firewall boost, but don't let your guard down. There may still be failsafes in place we don't know about.", nil, "Central"}}},
				LOOTED_CASE_DROIDS_BOOTING = {
				{{"Heads up, Operator. Those droid prototypes are coming online.",nil,"Central"}},
				{{"Looks like the expo is providing its own security. Get out while you still can.",nil,"Central"}},				
				},
				CENTRAL_JUDGEMENT = {
					NO_LOOT = {{{"This was a waste of time, Operator. If you cannot pull off a simple museum heist, then what good are you?",nil,"Central"}},
					{{"I expected better results from you, Operator. We've lost our previous firepower, and opportunities like this don't come knocking every day.",nil,"Central"}},
					{{"Outstanding work, Operator. I trust you'll remember this moment the next time our agents enter the field armed with toothpicks and nerf guns.",nil,"Central"}}},
					GOT_PARTIAL = {{{"I trust you've made the right call, Operator. Pity we couldn't clean them out completely, but the reward is not always worth the risk.",nil,"Central"}},
					{{"Acceptable work. You didn't get the entire arsenal, but this should tide us over for now.",nil,"Central"}},
					{{"This should give our people an edge in the field. Let's just hope the enemy won't be armed with those prototypes you chose to leave behind.",nil,"Central"}}},
					GOT_FULL = {{{"I hope you dusted the shelves on your way out. We wouldn't want their cleaners to think we've missed a spot. Excellent work.",nil,"Central"}},
					{{"That should do quite nicely. It won't put us on par with the corps, but we're no longer as catastrophically outgunned as we were before.",nil,"Central"}},
					{{"Commendable work, Operator. We've expanded our arsenal and put a dent in their research all at once.",nil,"Central"}}},
				},
			},
		},
		-- CAMPAIGN_MAP = {
			-- MISSIONS = {
			-- },
		-- },
	},

}
