return {
	EA_HOSTAGE = {			
			NAME= "Secure Holding Facility",
			MORE_INFO = "The corp has intercepted a courier of one of our former clients. He's got important site intel stored in a cerebral implant, intel we could use. Your task is to break in, locate the courier, and recover the information.\n\nOne final note - the implant is set to explode if the courier loses consciousness, so we have to work fast.",
			INSET_TITLE = "CODE NAME: INSOMNIAC", --unused
			INSET_TXT = "I'm not going to lie, operator. There's an awful lot of unused flavour text in these files.", --unused
			INSET_VO = {""}, 
			DESCRIPTION = "Rescue missing courier and escape with him in time limited from the moment you free him.\nTelepad locked, courier has the key.",
			REWARD = "Two new infiltration targets at the same corporation as this facility.",
			BANTER = {
				START = {
				"",
				},
				FINAL_WORDS = {
					"I knew I shouldn't have taken that job...",
					"I can't go back in there. I can't.",
					"I just want to lie down...",
					"Don't shoot! I don't even know these people!",
				},			
			},
		},

	INGAME = {
		OPERATOR_OPEN = {--unused
			{{"Alright, you're in. Their automated system is beginning to track you, so time is not on your side.\nFind the courier, and get out.",
				nil, 
				"Central" }},
		},
		HOSTAGE_SIGHTED = {
			{{"There's the courier. It looks like they've been thorough. He won't last much longer.",
				"moremissions/VoiceOver/Central/courierrescue/sighted/courier", 
				"Central" }},
		},
	--	HOSTAGE_CONVO1 = "You. You're not one of them. Who are you?",
		OPERATOR_CONVO1 = {
			{{"We're here to help. Keep quiet and keep your head down, and you might get out alive.",
				nil, 
				"Central" }},
		},
	--	HOSTAGE_CONVO2 = "We better hurry... I can't hold up much longer",
		OPERATOR_CONVO2 = {
			{{"He's free, but it seems his cerebral drive was damaged. If we're going to get him out in one piece we had best do it quickly. Make your way to the telepad, it should be open now. ",
				"moremissions/VoiceOver/Central/courierrescue/free", 
				"Central" }},
		},
		OPERATOR_ESCAPE = {
			{{"Good job, team. We should be able to stabilize him in the jet. I'm sure his contractor will be rather thankful.", -- here was helicopter originally
				"SpySociety/VoiceOver/Missions/Hostage/Operator_GoodJob", 
				"Central"}},
		},
		CENTRAL_PASSOUT_WARNING = {
			{{"We are running out of time, Operator. If you don't get the courier out soon, we'll have one very displeased client on our hands, and no hopes of scavenging the data.",
				"moremissions/VoiceOver/Central/courierrescue/urgent", 
				"Central"}},
		},
		CENTRAL_HOSTAGE_PASSEDOUT = {
			{{"What part of 'quickly' did you misunderstand? Get the team to the extraction point. What a waste.",
				"moremissions/VoiceOver/Central/courierrescue/timeout", 
				"Central" }},
		},
		DEATH_SHOT = {
			{{"Were you planning to scrape his brain off the wall to get the intel we came here for? Just get your team out of there. Not much we can do for him now.",
				"moremissions/VoiceOver/Central/courierrescue/shot", 
				"Central"}},
		},
		CENTRAL_HOSTAGE_DEATH = {
			{{"Blast! There goes our bonus. Proceed to the extraction point.",
				nil, 
				"Central" }},
		},
		CENTRAL_HOSTAGE_LONE_DEATH = {
			{{"Blast! There goes our bonus. You shouldn't have left him alone.",
				nil, 
				"Central" }},
		},
		CENTRAL_COMPLETE_MISSION_NO_COURIER = {
			{{"At least you survived. We will discuss this further in debriefing.",
				nil, 
				"Central" }},
		},

		CENTRAL_JUDGEMENT = {
			COURIER_MIA = {
				{{"Your mission was to bring back that cerebral implant and the asset who carries it, not let them fall back into enemy hands. You had better improve your performance, and fast.",
					"moremissions/VoiceOver/Central/courierrescue/judge/fail1", 
					"Central"}},
				{{"You are trying my patience, Operator. It's not every day we get the chance to pick the brain of a data courier. Would you like to be the one to explain this failure to our client?",
					"moremissions/VoiceOver/Central/courierrescue/judge/fail2", 
					"Central"}},
			},
			COURIER_ESCAPED = {
				{{"This mission needed a delicate touch, and you delivered. If all goes well, we'll have our pick of nearby targets at this corporation. Excellent work.",
					"moremissions/VoiceOver/Central/courierrescue/judge/out1", 
					"Central"}},
				{{"I know first hand just how dificult escort missions can be, Operator. Protecting a live asset is not an easy job, but you've shown me you are up to the task. Well done.",
					"moremissions/VoiceOver/Central/courierrescue/judge/out2", 
					"Central"}},
				{{"The courier is on board, and receiving medical attention as we speak. I knew I could count on you, Operator. Keep up this level of competence, and we may yet get the agency back on its feet.",
					"moremissions/VoiceOver/Central/courierrescue/judge/out3", 
					"Central"}},
			},
		},
	},	

	MISSIONS = {
	HOSTAGE = {
		MISSION_TITLE = "HOSTAGE EXTRACTION",
		MISSION_DESCRIPTION = "<Corporation> has intercepted one of our client's couriers. He's got important intel stored in a cerebral implant.",
		MISSION_GOAL = "Your task is to break in, locate the courier, and recover the information. ",
		MISSION_ENDER = "One final note - the implant is set to explode if the courier loses consciousness, so we have to work fast.",
		MISSION_PERSON_OF_INTEREST = "GORDON, JONATHAN F.",
		MISSION_POI_TYPE = "DATA COURIER",
		
		OBJECTIVE_FIND_HOSTAGE = "Find the Courier",
		OBJECTIVE_RESCUE_HOSTAGE = "Rescue the Courier",
		OBJECTIVE_ESCAPE = "Escape with the Courier",
	
	--	OPERATOR_OPEN = "Alright, you're in. Their automated system is beginning to track you, so time is not on your side.\nFind the courier, and get out.",
	--	HOSTAGE_SIGHTED = "There's the courier. It looks like they've been thorough. He won't last much longer.",
		HOSTAGE_CONVO1 = "You. You're not one of them. Who are you?",
	--	OPERATOR_CONVO1 = "We're here to help. Keep quiet and keep your head down, and you might get out alive.",
		HOSTAGE_CONVO2 = "We better hurry... I can't hold up much longer...",
	--	OPERATOR_CONVO2 = "Hmmmm. It looks like the drive was damaged. If we're going to get him out in one piece we had best do it quickly.",
	--	OPERATOR_ESCAPE = "Good job, team. We should be able to stabilize him in the helicopter.",
	
		HOSTAGE_VITALS = "VITAL STATUS",
		HOSTAGE_VITALS_SUBTEXT = "%d TURN(S) REMAINING",
		HOSTAGE_VITALS_SUBTEXT_DEATH = "EXPIRED",
		HOSTAGE_NAME = "THE COURIER",
	
		GUARD_INTERROGATE1 = "I'm getting tired of asking you. Tell me the unlock sequence, or I'll rip it out of your head with my bare hands.",
		COURIER_INTERROGATE1 = "I don't know, man! I just carry the thing. I can't see inside!",
	
		HOSTAGE_BANTER = 
		{
			"The task. Stay on the task. Get the data to the customer.",
			"I have to stay awake! My head...",
			"You'll get me out of here, right?",
			"Everything is moving so slowly!",
			"They can see your thoughts when you close your eyes.",
			"They caught me in the washroom. It's not fair!",
			"The probes! They can see your dreams.",
			"My head hurts. Like, really hurts.",
			"Do you smell that?",
			"", --lazy fix
		},
	
		HOSTAGE_PASS_OUT = "Something's wrong. Oh God, something's wrong!",
	--	CENTRAL_PASS_OUT = "What part of 'quickly' did you misunderstand? Get to the elevator.",
	
	--	CENTRAL_HOSTAGE_DEATH = "Blast! There goes our bonus. Proceed to the extraction point.",
	
	--	CENTRAL_COMPLETE_MISSION_NO_COURIER = "At least you survived. We will discuss this further in debriefing.",
	}
	}
}

