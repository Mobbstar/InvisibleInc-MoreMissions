return {
	EA_HOSTAGE = {			
			NAME= "安全拘留设施",
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
					"我就不该接下这个任务...",
					"我回不去了.我不能--",
					"啊,我只是想躺一会...",
					"别杀我啊!我甚至都不认识这些人!",
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
			{{"看到信使了.\n看来他们毒手下的很彻底.\n他撑不了多久了.",
				"moremissions/VoiceOver/Central/courierrescue/sighted/courier", 
				"Central" }},
		},
	--	HOSTAGE_CONVO1 = "你...你不是他们中的一员.你究竟是谁?",
		OPERATOR_CONVO1 = {
			{{"我们是来帮忙的。\n保持安静，低下头，\n你就有可能活着出去.",
				nil, 
				"Central" }},
		},
	--	HOSTAGE_CONVO2 = "我们最好快点... 我快撑不住了",
		OPERATOR_CONVO2 = {
			{{"他现在可以行动了，但似乎大脑植入物严重受损。\n如果我们要把他完整地救出来，\n最好快一点。\n让他去传送电梯，现在应该已经打开了. ",
				"moremissions/VoiceOver/Central/courierrescue/free", 
				"Central" }},
		},
		OPERATOR_ESCAPE = {
			{{"干得好，队员们。\n我们应该能让他在飞机上稳定情绪，\n我相信他的金主会非常感激的.", -- here was helicopter originally
				"SpySociety/VoiceOver/Missions/Hostage/Operator_GoodJob", 
				"Central"}},
		},
		CENTRAL_PASSOUT_WARNING = {
			{{"我们要没时间了！ \n执行官， 如果你不尽快把信使送出去，\n不仅我们的客户会*非常*不高兴，\n我们也没有希望再找回数据了.",
				"moremissions/VoiceOver/Central/courierrescue/urgent", 
				"Central"}},
		},
		CENTRAL_HOSTAGE_PASSEDOUT = {
			{{"到底是'快'的哪个部分你没听清楚？\n把队伍撤出来。\n机会就这么浪费了.",
				"moremissions/VoiceOver/Central/courierrescue/timeout", 
				"Central" }},
		},
		DEATH_SHOT = {
			{{"你打算从墙上刮下他的脑袋来获取\n我们来此所找的情报吗？快带你的人离开那里，\n我们现在什么都做不了了.",
				"moremissions/VoiceOver/Central/courierrescue/shot", 
				"Central"}},
		},
		CENTRAL_HOSTAGE_DEATH = {
			{{"不！ 我们的奖金没了。\n前往撤离点.",
				nil, 
				"Central" }},
		},
		CENTRAL_HOSTAGE_LONE_DEATH = {
			{{"不！我们的奖金没了。\n你不该丢下他一个人的.",
				nil, 
				"Central" }},
		},
		CENTRAL_COMPLETE_MISSION_NO_COURIER = {
			{{"至少你活下来了。\n我们将在汇报时进一步讨论这个问题.",
				nil, 
				"Central" }},
		},

		CENTRAL_JUDGEMENT = {
			COURIER_MIA = {
				{{"你的任务是带回大脑植入物和携带它的那个人，\n而不是让它们重新落入敌人手中。\n你最好提高你的表现，而且要快.",
					"moremissions/VoiceOver/Central/courierrescue/judge/fail1", 
					"Central"}},
				{{"你在考验我的耐心,行动官.\n我们可不是每天都有机会 \n去获取信使的情报的. \n你愿意向我们的客户解释这次失败吗？",
					"moremissions/VoiceOver/Central/courierrescue/judge/fail2", 
					"Central"}},
			},
			COURIER_ESCAPED = {
				{{"这个任务需要细致的行动，而你做到了。 \n如果一切顺利，\n我们就能在这家公司附近找到目标。\n干得漂亮.",
					"moremissions/VoiceOver/Central/courierrescue/judge/out1", 
					"Central"}},
				{{"我亲身经历过护送任务的艰辛，行动官。\n保护信使不是一件容易的事，\n但你已经向我证明了你能胜任这项任务。\n干得好.",
					"moremissions/VoiceOver/Central/courierrescue/judge/out2", 
					"Central"}},
				{{"信使已经上机，正在接受治疗。\n我就知道你能行，行动官！\n保持这样的能力水平，我们也许很快就能\n重新站起来.",
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
		
		OBJECTIVE_FIND_HOSTAGE = "找到信使",
		OBJECTIVE_RESCUE_HOSTAGE = "救援信使",
		OBJECTIVE_ESCAPE = "让信使逃出",
	
	--	OPERATOR_OPEN = "Alright, you're in. Their automated system is beginning to track you, so time is not on your side.\nFind the courier, and get out.",
	--	HOSTAGE_SIGHTED = "There's the courier. It looks like they've been thorough. He won't last much longer.",
		HOSTAGE_CONVO1 = "你...你不是他们中的一员.你究竟是谁?",
	--	OPERATOR_CONVO1 = "We're here to help. Keep quiet and keep your head down, and you might get out alive.",
		HOSTAGE_CONVO2 = "我们最好快点... 我快撑不住了...",
	--	OPERATOR_CONVO2 = "Hmmmm. It looks like the drive was damaged. If we're going to get him out in one piece we had best do it quickly.",
	--	OPERATOR_ESCAPE = "Good job, team. We should be able to stabilize him in the helicopter.",
	
		HOSTAGE_VITALS = "生命垂危",
		HOSTAGE_VITALS_SUBTEXT = "{1} {1:TURN|TURNS} REMAINING",
		HOSTAGE_VITALS_SUBTEXT_DEATH = "EXPIRED",
		HOSTAGE_NAME = "信使",
	
		GUARD_INTERROGATE1 = "我都已经问烦了 -- \n赶紧告诉我解锁顺序，\n否则别逼我把它从你脑袋里扯出来.",
		COURIER_INTERROGATE1 = "我真的什么都不知道啊,先生!\n我只是运送它,看不到里面的东西!",
	
		HOSTAGE_BANTER = 
		{
			"任务。坚持完成任务。向客户提供数据.",
			"我必须保持清醒！我的头好痛...",
			"你会带我离开这里，对吧?",
			"一切都变得好慢!",
			"当你闭上眼睛时，他们就能看到你在想什么.",
			"他们居然在洗手间抓我！这不公平！",
			"那些探测器！它们能看到你的梦.",
			"我的头好痛...真的很疼.",
			"你闻到...什么东西了吗？\n（注：信使身上炸弹的引线被点燃的气味）",
			"", --lazy fix
		},
	
		HOSTAGE_PASS_OUT = "不！哦，天哪，不！！！",
	--	CENTRAL_PASS_OUT = "What part of 'quickly' did you misunderstand? Get to the elevator.",
	
	--	CENTRAL_HOSTAGE_DEATH = "Blast! There goes our bonus. Proceed to the extraction point.",
	
	--	CENTRAL_COMPLETE_MISSION_NO_COURIER = "At least you survived. We will discuss this further in debriefing.",
	}
	}
}

