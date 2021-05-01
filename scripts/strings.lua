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
		MOLE_INSERTION = "INFORMANT RENDEZVOUS",
		MOLE_INSERTION_TIP = "<c:FF8411>INFORMANT RENDEZVOUS</c>\nPlant an informant who will feed you intel for the next few missions.",	
		AI_TERMINAL = "AI TERMINAL",
		AI_TERMINAL_TIP = "<c:FF8411>AI TERMINAL</c>\nUpgrade a program or gain a new program slot for Incognita.",
		EA_HOSTAGE = "SECURE HOLDING FACILITY",
		EA_HOSTAGE_TIP = "<c:FF8411>SECURE HOLDING FACILITY</c>\nRescue the Courier in the limited time before he dies, to gain access to more infiltration sites.",
		
		SIDEMISSIONS = "SIDE MISSIONS",
		SIDEMISSIONS_TIP = "Enable new side missions",		

		ITEMS_IN_STORE = "ITEMS IN STORES",
		ITEMS_IN_STORE_TIP = "<c:FF8411>ITEMS IN STORES</c>\nAllows the new exclusive items to spawn in nanofabs and such, making them not exclusive anymore.",
	},

	PROPS =
	{
		-- RECHARGE_STATION = "Phone Recharge Socket",
		PERSONNEL_DB = "Personnel Database",
		AI_CARD = "AI Vault Keycard",
		AI_CARD_DESC = "Unlocks an AI Lock Vault Door. Cannot be taken out of the facility.",
		AI_CARD_FLAVOR = "A local passkey, required for any personnel to access top-security terminals with AI prototypes and databanks.",
		INCOGROOM_TERMINAL = "AI Terminal Lock",
		INCOGROOM_AI_TERMINAL = "AI Development Terminal",
	},

	GUARDS =
	{
		BOUNTY_TARGET = "Bounty Target",
		BODYGUARD = "Bodyguard",
		PROTOTYPE_DROID = "Prototype Android",
		PROTOTYPE_DROID_SPEC = "Prototype SpecDroid",
	},


	AGENTS =
	{
		AGENT_009 =
		{
			NAME = "Agent-OO9",
			TOOLTIP = "Covert Operative",
			BANTER =
			{
				START = {
					"",
				},
				FINAL_WORDS =
				{
					"End of the line.",
					"Good evening to you, gentlemen.",
				},
			},
		},
		
		EA_HOSTAGE = 
		{
			NAME = "Johnny W.",
		},
		MOLE = 
		{
			NAME = "INFORMANT",
			FULLNAME = "Natalie Formaunte",
			TOOLTIP = "Undercover Specialist",
			BANTER =
			{
				START = {
					"",
				},
				FINAL_WORDS = 
				{
					"Well, this was a wild ride.",
					"This is all a huge mistake. Come on, I'll show you my ID...",
					"I've got friends in high places. You sure you want to take that shot?",
				},
			},		
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
		DISCARDED_MANACLES_TOOLTIP = "Secured in place. Alerts the Captain when seen.",
		DISCARDED_MANACLES_FLAVOR = "An empty space, where a prisoner is supposed to be restrained.",
		
		AMNESIAC = "Amnesiac",
		AMNESIAC_TOOLTIP = "Use on pinned targets. Removes alert status and WITNESS tag. Reduces max AP by 2.",
		AMNESIAC_FLAVOR = "A mind-scrambling mix of chemicals straight off the seedy underbelly of the black market. The target wakes up sluggish, disoriented, and unable to recall certain pertinent details, such as any faces they might have recently seen.",

		MOLE_CLOAK = "Custom Cloaking Rig I",
		MOLE_CLOAK_FLAVOR = "Some cloaking rig models have increased efficiency, but are custom-fitted to the recipient's profile during manufacture and are virtually useless for anyone else. Don't bother trying to steal this off the Informant, she's quite attached to it - literally.",		

	},

	ABILITIES = {
		HACK_PERSONNELDB = "Hack Database",
		HACK_PERSONNELDB_DESC = "Fabricate cover identity",
		HACK_ONLY_MOLE = "Only the Informant can do this",

		SCRUB_CAMERADB = "Scrub Database",
		SCRUB_CAMERADB_DESC = "Removes WITNESS status from all cameras and drones",

		-- ESCAPE_GUARD = "Escape",
		ESCAPE_GUARD_DESC = "Undercover Informant teleports out",
		ESCAPE_GUARD_POWER_CELL = "Informant must drop the {1} before leaving!",
		
		INCOGROOM_UNLOCK = "REMOVE LOCK",
		INCOGROOM_UNLOCK_DESC = "Unlocks 1 of 4 locks to the AI Development Terminal.",

		INCOGROOM_UPGRADE = "UPGRADE INCOGNITA",
		INCOGROOM_UPGRADE_DESC = "Use this terminal to add 1 program slot to Incognita.",	

		DEACTIVATE_LOCKS = "DEACTIVATE LOCKS",

	},

	-- ACTIONS =
	-- {
		-- UNLOCK_BLUE = "Hyper-Unlock",
		-- UNLOCK_BLUE_TIP = "Unlock this door so hard, it stays open forever.",
	-- },

	DAEMONS =
	{
		MOLE_DAEMON = {
			NAME = "INFORMANT INTEL",
			DESC = "Receive random intel at mission start. Valid for {1} more {1:mission|missions}. Not active in Omni facilities.",
			SHORT_DESC = "",
			ACTIVE_DESC = "INTEL PROVIDED BY INFORMANT",
		},

		MOLE_DAEMON_EVENT = {
			INTEL_TYPES = {
			["layout"] = "Facility layout revealed",
			["patrols"] = "Some guard patrols revealed",
			["consoles"] = "Consoles revealed",
			["safes"] = "Safes revealed",
			["cameras"] = "Cameras & turrets revealed",
			["daemons"] = "Daemons revealed",
			["doors"] = "Doors revealed",
			["exit"] = "Exit revealed",
			},

			-- for event notification
			MOLE_DAEMON_HEAD = "E S P I O N A G E   B O N U S",
			MOLE_DAEMON_TITLE = "INFORMANT INTEL",
			MOLE_DAEMON_TXT = "Your informant has provided you with the following intel on this facility:\n\n",
		},	

		WITNESS_WARNING = {
			NAME = "",--"WITNESS WARNING", --looks less cluttered when this string is empty
			DESC = "Remove witnesses who have seen the INFORMANT",
			SHORT_DESC = "Remove witnesses",
			ACTIVE_DESC = "WITNESS TRACKING",
			GUARDS = "GUARDS",
			CAMERAS = "CAMERAS",
			DRONES = "DRONES",
			ESCAPED = "ESCAPED",
			WITNESSES_LEFT_GUARDS = "{1} {1:witness|witnesses} remaining. Remove by killing or injecting KO'd target with Amnesiac.",
			WITNESSES_LEFT_CAMERAS = "{1} {1:witness|witnesses} remaining. Remove by destroying unit, EMPing unit, or Scrubbing a Camera Database.",
			WITNESSES_LEFT_DRONES = "{1} {1:witness|witnesses} remaining. Remove by destroying or EMPing unit.",
			WITNESSES_LEFT_DRONES_WE = "{1} {1:witness|witnesses} remaining. Remove by destroying or Data Scrubbing a Drone Uplink.", --Worldgen Extended
			WITNESSES_ESCAPED = "{1} {1:witness has|witnesses have} escaped the level and can no longer be removed.",

		},	
	},

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
		MOLE_INSERTION = {
			MOLE_OBJECTIVE = "Secure informant's cover and escort them to guard exit",
			MOLE_OBJECTIVE_SECONDARY = "",
			OBJ_KILL_WITNESS = "Remove any witnesses",
			OBJ_KILL_WITNESS_FAILED = "Remove any witnesses (FAILED)",
			WITNESS_DETECTED = "WITNESS DETECTED",
			PERSONNEL_DB = "PERSONNEL DATABASE",
			HACK_WITH_MOLE = "Hack with informant",
			FIND_DB = "Find personnel database",
			HACK_DB = "Hack personnel database with informant",
			ESCAPE = "Informant must escape through guard elevator",
			NOT_SEEN = "Informant must not be seen",
			NOT_SEEN_FAILED = "Informant must not be seen (FAILED)",
			CAMERADB = "CAMERA DATABASE",
			CAMERADB_TIP = "Scrub to clear mainframe witnesses",
		},
		AI_TERMINAL = {
			AI_OBJECTIVE = "Access the AI Terminal",
			AI_OBJECTIVE_SECONDARY = "Unlock the doors to the terminal",
			OBJECTIVE1 = "Deactivate Locks",
			OBJECTIVE2 = "Activate AI Development Terminal",
			OBJ_FIND = "Locate the AI Development Terminal",
			EXIT_WARNING = "Are you sure you want to leave? You haven't accessed the AI Dev Terminal yet.",
			
			DIALOG = { --this needs to be rewritten to be nicer and fluffier
				OPTIONS1 = {
				"CANCEL",
				"UPGRADE PROGRAM",
				"NEW PROGRAM SLOT",
				},
				
				OPTIONS1_MAXSLOTS = {
					"CANCEL",
					"UPGRADE PROGRAM"
				},
				
				OPTIONS1_TXT = "Choose between new slot and upgraded program",
				OPTIONS1_TXT_MAXSLOTS = "Choose between new slot and upgraded program.\n\nProgram slots full. New slot unavailable.",
				OPTIONS1_TITLE = "AI TERMINAL ACCESS",
				OPTIONS1_RESULT1_TITLE = "NEW SLOT ACQUIRED",
				OPTIONS1_RESULT1_TXT = "New program slot acquired. Will be available after this mission.",
				
				OPTIONS2_TXT = "Select a program to upgrade. \n\n<c:FC5603>Cannot upgrade the same program twice.</c>",
				OPTIONS2_TITLE = "SELECT PROGRAM",
				
				OPTIONS3_TXT = "Choose a parameter to upgrade.",
				OPTIONS3_TITLE = "CHOOSE PARAMETER",
				OPTIONS3 = {
					"Firewalls broken",
					"PWR cost",
					"Cooldown",
					"Range",
				},
				OPTIONS3_PARASITE = {
					"Parasite strength",
					"PWR cost",
					"Cooldown",	
					"Range",
				},
				
				OPTIONS4_INC = {
					"Start over",
					"Decrease by 1",
					"Increase by 1",
				},
				OPTIONS4_TXT = "How do you want to modify this parameter?\n\n<c:FC5603>Warning: Cannot decrease a parameter below 1.</c>\nCannot upgrade if parameter is 0 or NOT APPLICABLE.",
				
				OPTIONS_FIREWALLS_TITLE = "FIREWALLS BROKEN",
				OPTIONS_FIREWALLS_INCREASE = "Icebreaking power increased by 1.",
				OPTIONS_FIREWALLS_DECREASE = "Icebreaking power decreased by 1.",
				
				INVALID = "NOT APPLICABLE",
				FIREWALLS_TIP = "{1} currently has a firewall-breaking strength of {2}.\n\n",
				PWRCOST_TIP = "{1} currently has a PWR cost of {2}.\n\n",
				COOLDOWN_TIP = "{1} currently has a cooldown of {2}.\n\n",
				RANGE_TIP = "{1} currently has a range of {2}.\n\n",
				
				OPTIONS_PWRCOST_TITLE = "PWR COST",
				OPTIONS_PWRCOST_INCREASE = "PWR cost increased by 1",
				OPTIONS_PWRCOST_DECREASE = "PWR cost decreased by 1",
				
				OPTIONS_COOLDOWN_TITLE = "COOLDOWN",
				OPTIONS_COOLDOWN_INCREASE = "Cooldown increased by 1",
				OPTIONS_COOLDOWN_DECREASE = "Cooldown decreased by 1",
				
				OPTIONS_RANGE_TITLE = "RANGE",
				OPTIONS_RANGE_INCREASE = "Range increased by 1 tile",
				OPTIONS_RANGE_DECREASE = "Range decreased by 1 tile",
				
				PROGRAM_UPGRADED_SUCCESS = "PROGRAM UPGRADED",
				PROGRAM_UPGRADE_FAIL_TXT = "Could not upgrade this parameter. Returning to root.", --needs to be implemented
				PROGRAM_UPGRADE_FAIL_TITLE = "INVALID UPGRADE",
				
				
			},
		},
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
			MORE_INFO = "A high-ranked executive at this location has an impressive bounty on their head, but such a high-profile hit will not go unanswered by the corp.\n\nThe target is reportedly paranoid, with personal security on-site. Be wary.", --This can be quite lengthy.
			INSET_TITLE = "MARKED FOR DEATH", --unused
			INSET_TXT = "I'm not going to lie, operator. There's an awful lot of unused flavour text in these files.", --unused
			INSET_VO = {"SpySociety_DLC001/VoiceOver/Central/DLC_Central_6_midmission_briefing_imnotgoing"},
			DESCRIPTION = "Kill or knock out the VIP, then extract him.",
			REWARD = "A hefty cash reward, at the cost of a permanent security increase at this corporation.",
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
			REWARD = "Agent or prisoner rescue with valuable items.\n<c:FC5603>URGENT:</c> This mission will disappear unless visited immediately.",
		},

		WEAPONS_EXPO = {
			NAME= "Tech Expo",
			MORE_INFO = "This facility is hosting a world class tier tech exposition. The corporations and the industry finest will be showing off their newest weapon prototypes. We should be able to nab us some prize gear, provided we visit after hours.\n\nKeep your guard up - word has it their security system is as experimental as the tech they're showcasing.", --This can be quite lengthy.
			INSET_TITLE = "WEAPONS EXPO", --unused
			INSET_TXT = "I'm not going to lie, operator. There's an awful lot of unused flavour text in these files.", --unused unless we actually get these voiced somehow
			INSET_VO = {"SpySociety_DLC001/VoiceOver/Central/DLC_Central_6_midmission_briefing_imnotgoing"},
			DESCRIPTION = "Locate the main exhibition center and steal at least one prototype.",
			REWARD = "Advanced melee or ranged weapons you can sell or use as equipment.",
		},

		MOLE_INSERTION = {
			NAME = "Informant Rendezvous", -- thanks to jlaub for name idea
			MORE_INFO = "We've been flying blind for too long. Our old network is gone, but Monst3r has put us in touch with a reliable freelancer who can help us build it back up again. \n\nFirst, we'll need to get them on site and secure their cover. Make sure they remain unseen, or things will get complicated. Take measures to remove any witnesses to maximise the benefit from this mission.",
			INSET_TITLE = "",
			INSET_TXT = "",
			INSET_VO = {"SpySociety_DLC001/VoiceOver/Central/DLC_Central_6_midmission_briefing_imnotgoing"},
			DESCRIPTION = "Plant an informant and secure their cover identity. For best results, informant must remain unseen.",
			REWARD = "Gain intel bonuses for the next few missions, such as facility layout, guard TAGs or exit location.",

		},	

		AI_TERMINAL = {
			NAME = "AI Terminal",
			MORE_INFO = "We've located an AI Development Terminal with unusually high security clearance. We should be able to integrate some of this research to increase Incognita's processing efficiency.\n\nThe terminal has multiple redundant locks, so be prepared to be thorough.",
			INSET_TITLE = "",
			INSET_TXT = "",
			INSET_VO = {"SpySociety_DLC001/VoiceOver/Central/DLC_Central_6_midmission_briefing_imnotgoing"},
			DESCRIPTION = "Unlock and access the AI Development Terminal using keycards and devices found on-site.",
			-- REWARD = "An additional program slot for Incognita, or valuable tech if at upgrade cap (2 additional slots).",
			REWARD = "An additional program slot for Incognita, or a program upgrade.",

		},			

	},

	UI = {
		HUD_WARN_EXIT_MISSION_HOLOSTUDIO = "Are you sure you want to leave? You don't have the holographic tool yet.",
		HUD_WARN_EXIT_MISSION_ASSASSINATION = "Are you sure you want to leave? You don't have the target body.",
		-- REASON = {
			-- HYPERUNLOCKED = "Busted open by a blue keycard",
		-- },
		DISTRESS_OBJECTIVE = "Rescue the operative",
		DISTRESS_OBJECTIVE_SECONDARY = "Find the confiscated gear",
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
		DOORS_REVEALED = "DOORS REVEALED",
		EXIT_REVEALED = "EXIT REVEALED",
		NO_GUARD_ESCAPE = "Must access Personnel Database first",
		CAMERADB_SCRUBBED = "MAINFRAME WITNESSES CLEARED",
		WITNESS_CLEARED = "WITNESS REMOVED",
		MOLE_EXIT_WARNING = "Are you sure you want to leave? You haven't located the Personnel Database yet.",
		MOLE_EXIT_WARNING2 = "Are you sure you want to leave? The Informant needs to escape through the GUARD elevator.",
		INCOGROOM_TEXT1 = "High-Security Door Detected",
		
		TOOLTIPS = {
			WEAPONS_EXPO_RESALE = "HARD TO FENCE",
			WEAPONS_EXPO_RESALE_DESC = "This prototype is not market-ready and can only be sold at half price.",
			EA_HOSTAGE_FRAIL = "FRAIL",
			EA_HOSTAGE_FRAIL_DESC = "KO damage is lethal.",
			EA_HOSTAGE_VITAL_STATUS = "VITAL STATUS",
			EA_HOSTAGE_VITAL_STATUS_DESC = "Will expire if not extracted in {1} {1:turn|turns}.",
			PARALYZE_AMNESIAC = "Amnesiac dose",
			PARALYZE_AMNESIAC_DESC = "Inject pinned victim with amnesiac. Removes WITNESS tag and reduces max AP by {1}.",
			WITNESS = "WITNESS",
			WITNESS_DESC_HUMAN = "Kill this unit or KO and apply Amnesiac.",
			WITNESS_DESC_MAINFRAME = "Destroy this unit or scrub Camera Database.",
			NO_CAMERADB_WITNESSES = "No camera or drone witnesses",
			KO_GAS = "KNOCKOUT GAS",
			KO_GAS_DESC = "This agent is surrounded by knockout gas and will be KO'd if they end their turn here.",
			KO_GAS_PINNED = "GASSED",
			KO_GAS_PINNED_DESC = "This agent's KO timer will not decrease until they leave the knockout gas.",
			
			PROGRAM_UPGRADE = {
				UPGRADED = "UPGRADED",
				UPGRADED_LONG = "AI TERMINAL UPGRADE",
				PARASITE = "{1} parasite strength",
				FIREWALLS = "{1} firewalls broken",
				PWRCOST = "{1} PWR cost",
				COOLDOWN = "{1} cooldown",
				RANGE = "{1} range",
			},
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
		MOLE_INSERTION = {
			MOLE_MISSION_START = "I'm in. Two things to remember: Nobody sees me, and don't get me killed. Stick to that, and we'll be the best of friends.",
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
					{{"We don't earn partial credit here, Operator. Find a way to finish the job.",
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
						{{"Now somebody else is going to get the bounty. Quit wasting precious time, Operator!",
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
	
			MOLE_INSERTION = {
				MOLE_ESCAPED_NOWITNESSES = {
					{{"The informant is out, and their cover identity is secure. Extract the rest of the team, Operator. We're done here.", nil, "Central"}},
				},
				MOLE_ESCAPED_WITNESSES = {
					{{"The informant is out, but they won't last long unless we secure their cover. If anyone saw them before they were out, be sure to take care of it before you leave.", nil, "Central"}},
				},
				MOLE_ESCAPED_TO_JET = {
					{{"You were supposed to get that informant into the enemy camp, not back on board, Operator. I trust you had good reason to abort the mission.", nil, "Central"}},
					{{"We should be able to find a new target for her somewhere nearby, so it's not entirely a loss. The important thing is nobody got hurt.", nil, "Monster"}},
				},
				MOLE_DIED = {
					{
						{{"What a sorry waste of a live asset. We'll be lucky if we get this opportunity again.",nil,"Central"}},
						{{"Yes, lucky is indeed the word. I suppose I ought to think twice about throwing any more \"live assets\" your way.",nil,"Monster"}},
					},
					{
						{{"That's the mission gone down the drain. Make sure the team is extracted safely, and we'll discuss this in debriefing.",nil,"Central"}},
						{{"And there goes one of my favourite contacts. Was this really necessary?",nil,"Monster"}},
					},
					{
						{{"Damn it, Operator! Do you have any idea how much having that contact in place would have helped our odds?",nil,"Central"}},
						{{"I suppose this particular death is on me. I put them in touch with you, after all.",nil,"Monster"}},
					},
				},
				MOLE_SEEN_BY_GUARD = {
					{{"Operator, our mole is as good as dead unless we secure their cover. If anyone sees them before they leave, make sure to clean up those loose ends.",nil,"Central"}},
					{{"And by \"clean up\", she means...",nil,"Monster"}},
					{{"Not necessarily. If you can find a nonlethal solution, use it. The mole should have something on them for that.",nil,"Central"}},
					},
				MOLE_SEEN_BY_CAMERA = {
					{{"You'll want to keep an eye out for any cameras that caught a glimpse of our informant. Their visual feeds are synched to the nearest Camera Database. See if you can find one on this level.",nil,"Monster"}},
					{{"Scrub the database to clear all cameras at once. A bullet or an EMP should do the trick, too.",nil,"Monster"}},
					{{"They really don't use the most robust tech, I'm afraid. Now, if they had purchased those from me-",nil,"Monster"}},
					{{"Derek, this is not the time.",nil,"Central"}},
					{{"Right, yes, of course. Carry on.",nil,"Monster"}},
					},
				MOLE_SEEN_BY_DRONE = {
					{{"You'll want to take care of any drones that saw the informant. Unlike cameras, they're not linked to a central feed.",nil,"Monster"}},
					{{"You'll have to scramble each one with an EMP, or destroy it entirely. I'm sure you're up to the task.",nil,"Monster"}},
				},
				SEE_CAMERADB = {
					{{"A camera database. Keep that in mind, that may come in handy if our informant gets spotted by any pesky cameras.",nil,"Monster"}},
				},
				SEE_OBJECTIVE_DOOR = {
					{{"Heads up, Operator. We're in the right place. The Personnel Database should be behind that door.",nil,"Central"}},
				},
				SEE_OBJECTIVE_DB = {
					{{"There's the Personnel Database. The informant can use it to fabricate their cover identity before they infiltrate deeper into the facility. Make sure it goes smoothly.",nil,"Central"}},
				},
				FINISHED_DB_HACK = {
					{{"The hack is done, but the informant got tagged as they were plugging out. Their location will keep pinging nearby security each alarm level.",nil,"Central"}},
					{{"Get them to a guard elevator and off this floor, and stay out of sight. Our work is almost done.",nil,"Central"}},
					-- {{"The informant is ready to go undercover now. Get them to a guard elevator and stay out of sight.",nil,"Central"}},
				},
				SEE_GUARD_EXIT = {
					{{"There's a guard exit. Be careful, Operator. Make sure the informant doesn't run into any inbound reinforcements on the way.",nil,"Central"}},
				},				
				CENTRAL_JUDGEMENT = {
					MOLE_JET_ESCAPE = {
					{{"We cannot afford to keep wasting our time like this, Operator. Luckily, we may just have a second shot at this. Make it count.", nil,"Central"}},
					{{"We're no better off than we started. There should be another infiltration target like this nearby. Don't make me give you a third chance, Operator.",nil,"Central"}},
					},
					MOLE_DIED = {
					{{"This was a sorry waste of an opportunity. We don't have much in the way of friends anymore, Operator. This could have been a step forward.",nil, "Central"}},
					{{"Your job was to get them inside, not to get them killed. It's a damn shame to see a fine operative go down like that.",nil,"Central"}},
					{{"A complete and utter disappointment. We need people on the inside, Operator. That kind of intel would be invaluable for our survival.",nil,"Central"}},
					{{"Don't let this kind of failure become a pattern, Operator. It would not be in your best interest.",nil,"Central"}},
					},
					WIN_WITH_WITNESSES = {
					{{"You weren't supposed to leave witnesses. Our mole on the inside won't be able to feed us intel for long before their cover is blown. Still, it's better than nothing.",nil,"Central"}},
					{{"Next time, try to make sure the mole is unseen. They'll be useful to us for that much longer if their cover is secure.",nil,"Central"}},
					{{"A job half done. We won't be able to use their intel for long, not with the witnesses you left behind. Be more careful next time.",nil,"Central"}},
					},
					WIN_NO_WITNESSES = {
					{{"An informant in the right place is worth their weight in gold, and you kept things clean. Well done, Operator.",nil,"Central"}},
					{{"We'll have advance intel on the next few infiltrations now. A shadow of our former prep work, but invaluable in these dire times. Excellent work.",nil,"Central"}},
					{{"A difficult task well performed. The informant is in, and you made sure there were no witnesses. Nice work.",nil,"Central"}},
					{{"Well done, Operator. With that informant in place, our job will be that much easier. Pity we won't have access to that intel for long.",nil,"Central"}},
					},					

				},
			},
			
			AI_TERMINAL = {
				CENTRAL_DOOR_SPOTTED = {
					-- {{"A scan of that door shows unusually high security measures. Whatever is behind it, must be very valuable. Shall we take a look, Operator?", nil, "Central"}}, --old WE version
					{{"A scan of that door shows unusually high security measures. This must be the AI research center we've been looking for. Shall we take a look, Operator?", nil, "Central"}},
					{{"You need to disable a lock behind each of those four doors. You should be able to find measures to unlock them on site. Take a look around.", nil, "Central"}},
				},
				CENTRAL_UNLOCKED_SUBDOOR = 
				{
					{{"That Console sent a signal to another part of the facility. One of the previously locked doors should be open now.", nil, "Central"}},
				},

				CENTRAL_UNLOCKED_MAINDOOR_OMNI_UNSEEN =
				{
					-- {{"Aha! Looks like we stumbled upon an AI development site. Get data from the terminal inside, and it should provide some useful information for Incognita.", nil, "Central"}},-- old WE version 
					{{"That's the main AI development terminal. Finally. Let's access the data and see if there is anything worthwhile for Incognita.", nil, "Central"}},
					{{"Something strange is going on here. The equipment at this research site is like nothing I've seen before. Certainly not at this corporation.", nil, "Monster"}},
					{{"Something to puzzle over later. For now, we need to finish the job and get out of here.", nil, "Central"}},
				},
				
				CENTRAL_UNLOCKED_MAINDOOR_OMNI_SEEN =
				{
					{{"That's the main AI development terminal. Finally. Let's access the data and see if there is anything worthwhile for Incognita.", nil, "Central"}},
					{{"This must be one of Omni Corp's covert research sites - only they have tech quite this advanced. The decor is a bit of a giveaway, too.", nil, "Monster"}},
					{{"There must be hundreds of such facilities scattered across the globe. How on Earth did we not run into one of these before?", nil, "Central"}},
					{{"I confess I have my suspicions, but you may not like hearing them...",nil,"Monster"}}, --it's because you're a bad mom, Central
				},				
				
				INCOGNITA_DATA_ACQUIRED = {
					{{"Acquired new data. High probability of increasing efficiency in coroutine execution. Processing... Estimated finish time is 1 hour, 21 minutes and 48 seconds.", nil, "Incognita"}},
					-- {{"Excelent job, Operator. Incognita will be able to install one additional program after we're finished here.",nil,"Central"}},
				},
				
				INCOGNITA_PROG_UPGRADED = {
					{{"Acquired new data. High probability of increasing effectiveness in coroutine execution. Processing... Integration complete.", nil, "Incognita"}},
				},
				
				INCOGNITA_TECH_ACQUIRED = { --unused?
					{{"Excelent job, Operator. Monst3r will certainly be interested in selling this data. Get it back to the jet.", nil, "Central"}},
					{{"Quite so, I already have half a dozen buyers in mind for something like this. We should do this more often.", nil, "Monster"}},
				},
				
				SMOKE_WARNING = {
					{{"We've tripped a failsafe. The room is rapidly filling with knockout gas. Get your agent out of there, now.",nil, "Central"}},
					{{"It could be worse. At least they're not flooding the research center with deadly neurotoxin.", nil, "Monster"}},
				},
				
				CENTRAL_JUDGEMENT = {
					GOT_SLOT = {
						{{"Excellent job, Operator. Incognita will be able to install one additional program soon.",nil,"Central"}},
						-- {{"",nil,"Central"}},
					},
					GOT_UPGRADE = {
						{{"Have a cookie, Operator.", nil, "Central"}},
					},
					GOT_NOTHING = {
						{{"I should have left you at the orphanage.", nil, "Central"}}, --will rewrite when feeling more creative
					},
				},		
			},
				
		},
		-- CAMPAIGN_MAP = {
			-- MISSIONS = {
			-- },
		-- },
	},

}
