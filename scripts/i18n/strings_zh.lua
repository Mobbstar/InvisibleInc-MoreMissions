local SIDE_MISSION_EXPLANATION = "\n<c:ffeb7c>支线任务：</c> 这不是一个完整的任务，而是在其他任务中随机出现。"
local _M =
{
	-- agentIDs list:

	-- 	NAME = agentID	-- just for convenience: agentID is a number or string, name is easier to use
	--	DECK = 0, -- tutorial

	DECKER = 1,      -- Decker
	SHALEM = 2,      -- Shalem
	TONY = 3,        -- Xu
	BANKS = 4,       -- Banks
	INTERNATIONALE = 5, -- Internationale
	NIKA = 6,        -- Nika
	SHARP = 7,       -- Sharp
	PRISM = 8,       -- Prism

	MONSTER = 100,   -- starting
	CENTRAL = 108,   -- starting

	OLIVIA = 1000,
	DEREK = 1001,
	RUSH = 1002,
	DRACO = 1003,

	AGENT009 = "agent009", --fake ID
}

return {
	OPTIONS =
	{
		EXEC_TERMINAL = "执行官终端",
		EXEC_TERMINAL_TIP = "<c:FF8411>执行官终端</c>\n这个任务在原版游戏中就存在。请根据需求禁用.\n但对第一个任务无效.",
		CFO_OFFICE = "首席财务官套间",
		CFO_OFFICE_TIP = "<c:FF8411>首席财务官套间</c>\n这个任务在原版游戏中就存在。请根据需求禁用.",
		CYBERLAB = "植入装置实验室",
		CYBERLAB_TIP = "<c:FF8411>植入装置实验室</c>\n这个任务在原版游戏中就存在。请根据需求禁用.",
		DETENTION = "拘留中心",
		DETENTION_TIP = "<c:FF8411>拘留中心</c>\n这个任务在原版游戏中就存在。请根据需求禁用.",
		NANOFAB = "纳米打印厅",
		NANOFAB_TIP = "<c:FF8411>纳米打印厅</c>\n这个任务在原版游戏中就存在。请根据需求禁用.",
		SECURITY = "安全调度中心",
		SECURITY_TIP = "<c:FF8411>安全调度中心</c>\n这个任务在原版游戏中就存在。请根据需求禁用.",
		SERVER_FARM = "服务器农场",
		SERVER_FARM_TIP = "<c:FF8411>服务器农场</c>\n这个任务在原版游戏中就存在。请根据需求禁用.",
		VAULT = "金库",
		VAULT_TIP = "<c:FF8411>金库</c>\n这个任务在原版游戏中就存在。请根据需求禁用.",

		ASSASSINATION = "刺杀行动",
		ASSASSINATION_TIP = "<c:FF8411>刺杀行动</c>\n提供大量CR，代价是提高整个公司的安全等级，以及你的良心.",
		HOLOSTUDIO = "工作室",
		HOLOSTUDIO_TIP = "<c:FF8411>工作室</c>\n提供先进的Holo工作室系列设备（升级版的物品）。\n类似于安全调度中心（疑似废案？）.",
		LANDFILL = "SALVAGING PLANT",
		LANDFILL_TIP = "<c:FF8411>SALVAGING PLANT</c>\n以大幅折扣提供不喜欢的物品。\n与纳米打印厅相似（疑似废案？）.",
		DISTRESSCALL = "求救信号",
		DISTRESSCALL_TIP = "<c:FF8411>求救信号</c>\n提供了一个既要特工又要装备的机会，\n但警报迅速升高.",
		WEAPONSEXPO = "原型窃取",
		WEAPONSEXPO_TIP = "<c:FF8411>原型窃取</c>\n提供受先进安全措施保护的强大实验性物品.",
		MOLE_INSERTION = "线人接头",
		MOLE_INSERTION_TIP = "<c:FF8411>线人接头</c>\n安插一名线人，在接下来的几个任务中为你提供\n情报.",
		AI_TERMINAL = "AI终端",
		AI_TERMINAL_TIP = "<c:FF8411>AI终端</c>\n为 Incognita 升级一个程序或获得一个新的程序插槽.",
		EA_HOSTAGE = "找回信使",
		EA_HOSTAGE_TIP = "<c:FF8411>找回信使</c>\n在信使死亡前的有限时间内营救他，\n以获取更多渗透地点.",


		SIDEMISSIONS_ABDUCTION = "支线任务 - 人员劫持",
		SIDEMISSIONS_ABDUCTION_TIP = "<c:FF8411>人员劫持</c>\n将特定的警卫绑架到飞机上，以暂时降低敌人的护甲。" .. SIDE_MISSION_EXPLANATION,
		SIDEMISSIONS_BRIEFCASES = "支线任务 - 集团仓库",
		SIDEMISSIONS_BRIEFCASES_TIP = "<c:FF8411>集团仓库</c>\n尽可能多地偷走公文包，甚至更多。" .. SIDE_MISSION_EXPLANATION,
		SIDEMISSIONS_LUXURYNANOFAB = "支线任务 - 豪华纳米制造",
		SIDEMISSIONS_LUXURYNANOFAB_TIP = "<c:FF8411>豪华纳米制造</c>\n进入一个只提供一种物品类型（武器、植入物、工具）的商店。" .. SIDE_MISSION_EXPLANATION,
		SIDEMISSIONS_WORKSHOP = "支线任务 - 车间",
		SIDEMISSIONS_WORKSHOP_TIP = "<c:FF8411>车间</c>\n改进你的装备。" .. SIDE_MISSION_EXPLANATION,
		SIDEMISSIONS_REBALANCE = "DLC支线调整",
		SIDEMISSIONS_REBALANCE_TIP =
		"<c:FF8411>增强版原版支线任务</c>\n<c:ffeb7c>PWR中继：</c> 选择出售5、10或15 PWR。\n<c:ffeb7c>改装无人机：</c> 无人机有+2行动点并在下一个任务中作为盟友加入你。\n<c:ffeb7c>编译室：</c> 程序可以作为物品获取，以便稍后安装或出售。",


		ITEMS_IN_STORE = "商店刷新特殊物品",
		ITEMS_IN_STORE_TIP = "<c:FF8411>商店刷新特殊物品</c>\n允许新的专属物品在纳米打印机等设备中生成，使它们不再是专属物品.",

		NEWDAY = "每天新任务数",
		NEWDAY_DESC = "<c:FF8411>每天新任务数</c>\n新的一天出现的任务数量. \n会覆盖“Generation Options+” 这个mod的设置.默认为4.",

		EXEC_TERMINALS = "更多执行终端目标选项",
		EXEC_TERMINALS_DESC = "<c:FF8411>更多执行终端目标选项</c>\n行政终端将允许您从六个任务（而不是原版的四\n个）中进行选择.",

		SPAWNTABLE_DROIDS = "添加新敌人 (从所选难度开始出现)",
		SPAWNTABLE_DROIDS_DESC = "<c:FF8411>添加新敌人 (从所选难度开始出现)</c>\n从本任务难度开始，其他任务中可能会出现只\n在科技窃取任务上出现的独特敌人.",
		SPAWNTABLE_DROIDS_VALUES = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "NEVER", },

		HARD_MODE = "困难模式",
		HARD_MODE_TIP = "<c:FF8411>困难模式</c>\n各个任务的安全措施更具挑战性。适合熟悉专家\n加强版的资深玩家.\n（警告：尚未进行过测试。请谨慎选择）",
	},

	LOADING_TIPS = {
		"MORE MISSIONS: 求救信号任务只会在地图上短暂出现。首席财务官每天都工作到很晚，但现在只有一队特工在执行任务.",
		"MORE MISSIONS: 仔细阅读物品的提示，了解与新目标相关的敌人和装置.",
		"MORE MISSIONS: 如果你在执行暗杀任务时没有致命武器，也不要担心。该设施提供了多种完成任务的方法.",
		"MORE MISSIONS: 暗杀悬赏目标不会产生清理费用，不过目标以外的击杀的仍然会扣你的钱。",
		"MORE MISSIONS: 如果将敌人拖在敌方控制的激光中间，它就会自动关闭。这在不止一种任务类型中非常有用.",
		"MORE MISSIONS: 求救信号任务中有一个特殊保险箱，里面有特工的装备。如果是第一次营救该特工，这意味着他们的起始装备.",
		"MORE MISSIONS: 在 \"求救信号 \"任务中，警报级别会以两倍的速度提升。您必须快速行动，救出被拘留者.",
		"MORE MISSIONS: 科技窃取任务在提供丰厚回报的同时，风险也在增加。尽量控制你的贪欲，否则你的游戏可能会提前结束.",
		"MORE MISSIONS: 科技窃取任务中，展品的提示会告诉你里面有什么。建议只入侵和打开装有你真正想要的物品的箱子.",
		"MORE MISSIONS: 科技窃取任务上的两个中继开关一旦被同时启动，就会使展柜无法增强彼此的防火墙。但同时，\n它们也能阻止防火墙因任何原因而增强。但如果你只打算偷一两件物品，那么可以无视这个功能.",
		"MORE MISSIONS: 与安全调度中心不同，科技博览馆中最多有五件物品，其中大部分是武器。它们功能强大，但使用时间不长.",
		"MORE MISSIONS: AI终端可让你增加 Incognita 的插槽数量，或升级你拥有的程序.",
		"MORE MISSIONS: 如果你安装了 Programs Extended（程序扩展）这个mod, AI终端将让你永久性地解决掉Counterintelligence AI（OMNI的反间谍AI）.",
		"MORE MISSIONS: 在完成目标时，最好在特工身上留有剩余的 AP。在某些意外的安全措施生效后，您可能会需要使用它们.",
		"MORE MISSIONS: 您可以启用 MOD 的 \"困难模式\"（HARD MODE），体验高级安全措施带来的全面挑战.",
		"MORE MISSIONS: 执行官终端任务现在可以从六个可能的地点中进行选择.",
		"MORE MISSIONS: 暗杀目标被标记为偏执狂，但如果真的有人要杀你，雇人杀你的这个人算不算也是偏执狂呢？",
		"MORE MISSIONS: 衷心感谢为mod配音众筹的捐款者: <c:F47932>Cyberboy2000, jlaub, TornadoFive, Zorlock Darksoul, Dwarlen, amalloy,	Datsdabeat,	Mobbstar, Waldenburger,	alpacalypse, magnificentophat, Zaman, Alexander S., Datapuncher, Jeysie, Linenpixel, WMGreywind, Puppetsquid, qoala, kalec.gos, Erpy, Andrew Kay</>",
	},

	PROPS =
	{
		-- RECHARGE_STATION = "Phone Recharge Socket",
		PERSONNEL_DB = "人事数据库",
		AI_CARD = "AI 金库钥匙卡",
		AI_CARD_DESC = "打开AI金库门。无法售卖或带出设施.",
		AI_CARD_FLAVOR = "本设施通行钥匙，任何人员要进入装有\nAI原型和数据库的最高安全级别终端，\n都需要使用该钥匙.",
		INCOGROOM_TERMINAL = "AI 终端锁",
		INCOGROOM_AI_TERMINAL = "AI 终端",
		ITEMLOCKER = "安全科技保险箱",
		WEAPONSLOCKER = "安全武器保险箱",
		CRATE = "物品存储箱",
		CRATE_DESC = "Monst3r 总是对这些货物感兴趣。\n\n使用 \"DELIVER \"（运送）按钮将电梯内的所有储物箱\n传送到飞机上.",
		STORE_LARGE = "豪华纳米打印机",
		NANOFAB_PROCESSOR = "纳米打印机处理器",
		NANOFAB_KEY = "纳米打印机钥匙",
		NANOFAB_KEY_DESC = "使用以解锁豪华纳米打印机。只能在该\n设施中使用。",
		NANOFAB_KEY_FLAVOR = "Luxury Pass豪华通行证会员可享受\n数千种商品的独家优惠。享受免费两日\n送达服务，最高可节省80%.\n您的唯一优惠代码: SINGLEORIGINCOFFEE74",
		DOOR_DEVICE = "生物门",
		DOOR_DEVICE_DESC = "仅能被VIP和其保镖解锁.",
		WORKSHOP_GRAFTER = "工坊",
	},

	GUARDS =
	{
		BOUNTY_TARGET = "VIP",
		BOUNTY_TARGET_DECOY = "假 VIP",
		BODYGUARD = "贴身护卫",
		PROTOTYPE_DROID = "仿生人原型机",
		PROTOTYPE_DROID_SPEC = "特种型仿生人原型机",
		PROTOTYPE_GOOSE_SPEC = "仿生鹅原型机",
		SCIENTIST = "科学家",
		HOLOGRAM_DROID = "Holo特制版仿生人诱饵",
		SPIDER_DRONE = "”水云“无人机",
	},


	AGENTS =
	{
		AGENT_009 =
		{
			NAME = "Agent-OO9",
			TOOLTIP = "秘密特工",
			BANTER =
			{
				START = {
					"",
				},
				FINAL_WORDS =
				{
					"琴弦绷断了.",
					"晚安，先生们.",
				},
			},
		},

		REFIT_DRONE =
		{
			NAME = "REFIT DRONE",
			TOOLTIP = "拆解的无人机",
			BANTER =
			{
				START = {
					"",
				},
				FINAL_WORDS =
				{
					" < Beep-boop... > ",
					" < Bzz-beeep!!! > ",
					" < Beep? Bzz-boop?? Bz-beep!!! > ",
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
			TOOLTIP = "情报专家",
			BANTER =
			{
				START = {
					"",
				},
				FINAL_WORDS =
				{
					"这真是一次疯狂的旅程.",
					"啊哈哈，这是个天大的误会。\n来吧，孩子们，\n我给你们出示一下我的身....",
					"我认识公司高层的人。\n你确定要开枪吗?",
					"唉，我想我的好运到此为止了.",
				},
			},
		},
	},

	ITEMS =
	{
		-- KEYCARD_BLUE = "Blue Keycard",
		-- KEYCARD_BLUE_TIP = "Unlocks blue doors.",
		-- KEYCARD_BLUE_FLAVOR = "Created using only state-of-the-art technology, this piece of plastic has a deep marine hue.",

		HOLOGRENADE_HD = "HD超高清全息投影仪",
		-- HOLOGRENADE_HD_TIP = "Throw to place a tall fake cover item. Activate in mainframe. Uses charge every turn. Can be recovered.",
		-- HOLOGRENADE_HD_FLAVOR = "Circus acts and theatre make up for the lack of postproduction by using convincing High-Density Holograms.",
		HOLOGRENADE_HD_TIP = "投掷使用，放置超高的假掩体。阻挡\n视线。可回收。会在 1 格内被听到.",
		HOLOGRENADE_HD_FLAVOR = "这台不起眼的 Fus Holo 投影仪\n是影院装饰的轻便替代品.",

		LAPTOP_HOLO = "VFX 笔记本",
		LAPTOP_HOLO_TIP = "部署来放置假掩体。启用时每回合产生\n1 PWR。可回收。会在 1 格内被听到.",
		LAPTOP_HOLO_FLAVOR = "Holowood 中较为复杂的场景使用了高度\n可编程的全息投影仪来计算与演员的实\n时互动。这个设备缺少破解脚本，但强\n大的处理器仍然很有用.",

		DISGUISE_CHARGED = "附属版全息投影贴图",
		DISGUISE_CHARGED_TIP = "激活时会产生伪装效果。冲刺和攻击会\n使效果失效。如果位于敌人正面 1 \n格视野范围内，伪装会被识破。每回合\n开始时消耗充能。伪装时不受掩体保护.",
		DISGUISE_CHARGED_FLAVOR = "相当昂贵的硬件，常用在全息片\n(Holovid)产业中。就像在舞台上\n对口型一样,经常被人唾弃。",

		ITEM_TAZER_OLD = "战痕累累雷雷的神经干扰器",
		-- ITEM_TAZER_OLD_TIP = "",
		ITEM_TAZER_OLD_FLAVOR = "这个干扰器磨损的很严重了, 但仍然能作为 \"说服他人\" 的工具.",

		DISCARDED_MANACLES = "解开的手靠铐",
		DISCARDED_MANACLES_TOOLTIP = "被固定在位置上。队长看到时会警觉.",
		DISCARDED_MANACLES_FLAVOR = "一个空无一人的椅子，囚犯本应该被限\n制在那里.",

		AMNESIAC = "\"失忆症\"麻痹剂",
		AMNESIAC_TOOLTIP = "在压制住的目标上使用。解除wit-\nness（目击者）状态。最大视野范\n围缩小 2 格。目标醒来时不会进入\n警戒状态.",
		AMNESIAC_FLAVOR =
		"这是一种来自黑市的用来扰乱大脑的混\n合化学物质。目标人物醒来后会变得迟\n钝、迷失方向，并且无法回忆起某些相\n关细节，比如说他们最近看见的面孔.\n(这个倒是可以随便顺走，能卖150CR)",

		MOLE_CLOAK = "定制版隐身衣I",
		MOLE_CLOAK_FLAVOR =
		"有些型号的隐形装备可以提高效率，但\n在制造过程中会根据客户的外形进行定\n制，让它对其他人几乎毫无用处。所以\n你就别费心从线人那里偷走这个了，她\n对它可是情有独钟--真的.\n(但你可以先害死她再拿了卖，这样就\n不算\"偷\"了，别问我怎么发现的)",

		MOLE_DISGUISE = "定制版全息投影网",
		MOLE_DISGUISE_TIP = "在 1 回合内产生伪装效果.冲刺和\n攻击会使伪装失效。会被警卫在正面\n1格视野内发现.",
		MOLE_DISGUISE_FLAVOR =
		"一些Holo伪装衣的型号已经摆脱了\n对 PWR 的依赖，但在制造过程中\n会根据客户的外形进行定制，让它对其\n他人几乎毫无用处。所以你就别费心从\n线人那里偷走这个了，她对它可是情有\n独钟--真的.（有bug，部分情况\n可以一直伪装下去，但是伪装状态下无\n法黑入人事数据库）",

		-- TECH EXPO CUSTOM ITEMS
		SMOKE_GRENADE_CLASSIC = "实验性烟雾弹",
		SMOKE_GRENADE_CLASSIC_TOOLTIP = "投掷时产生一团烟雾，遮住一个\n区域的视线。持续2回合。\n可用次数有限.",
		SMOKE_GRENADE_CLASSIC_FLAVOR = "与标准烟雾弹相比，它是一种可在更大\n范围内扩散的混合气雾剂，在空气中悬\n浮的时间更长。尽量不要吸进鼻子.",

		GRENADE_FRAG = "破片手榴弹",
		GRENADE_FRAG_TOOLTIP = "在某一区域引爆。\n对人类和设备造成致命伤害。\n无视护甲，谨防友军伤害.",
		GRENADE_FRAG_FLAVOR = "实际上是军事技术的活化石。这种震荡\n式简易爆裂装置可追溯到 20 世纪初，\n造成了极大的财产损失，因此已在2058\n年被《物理植入体完整性法案》取缔.",

		SMOKE_FRAG_GRENADE = "烟雾破片手榴弹",
		SMOKE_FRAG_GRENADE_TOOLTIP = "在某一区域引爆，用烟雾遮挡视线.\n对人类和脆弱的设备造成致命伤害。\n无视护甲，谨防友军伤害.",
		SMOKE_FRAG_GRENADE_FLAVOR = "手榴弹中的瑞锐士军刀。当你在无法从致\n命武力和诡计之间做出选择，而又想两\n者兼顾时，扔出它吧.",

		CLOAK_1 = "脆弱的隐身衣",
		CLOAK_1_TOOLTIP = "让使用者和范围内的任何人隐身 2 个\n回合，只要他们不移动或攻击。可用次\n数有限.",
		CLOAK_1_FLAVOR = "隐身衣使用全息投影仪阵列来折射小范\n围内的光线，使其几乎隐形。这个装置\n能产生一个巨大但容易被破坏的全息场,\n其范围远远超过它的使用者.",

		CLOAK_2 = "扩展版隐身衣",
		CLOAK_2_TOOLTIP = "让使用者隐身 3 个回合，或直到他\n们攻击。无法在被发现时使用。 可用\n次数有限.",
		CLOAK_2_FLAVOR = "这件隐身衣具有最先进的效率和易用性，\n但启动时需要大量的初始 PWR.",

		CLOAK_3 = "强化版隐身衣",
		CLOAK_3_TOOLTIP = "允许使用者隐身 1 个回合。攻击不\n会取消隐身。可用次数有限.",
		CLOAK_3_FLAVOR = "这件强化版隐身衣可以抵御足以让普通\n隐身衣失效的能量波动，甚至包括来自\n枪械或神经干扰器的能量波动.\n(这件装备未经完全测试,不确定战斗\n员的扫描手雷能否抵御)",
		CLOAK_4 = "电容隐形装置",
		CLOAK_4_TOOLTIP = "使使用者隐形直到玩家回合结束，或直到被关闭。每当使用者在隐形状态下移动一格，冷却时间增加1。",
		CLOAK_4_FLAVOR = "最初由一个有偷窃癖的企业外交官委托制作，用于从级别越来越高的高管的冰箱里偷三明治，这个隐形装置可以暂时高效地隐藏使用者。过度移动会增加电容器的负担。",

		BUSTER = "实验性的 小鬼头芯片",
		BUSTER_TOOLTIP = "使用以手动破解 8 层防火墙，并摧\n毁当前设备已安装的守护进程. 可用\n次数有限.",
		BUSTER_FLAVOR = "最先进的 Buster 芯片型号，\n专为轻松破解高安全性、高优先级目标\n而设计.",

		ECON_CHIP = "实验性的 采集芯片",
		ECON_CHIP_TOOLTIP = "从控制台收集 CR 而非 PWR 。\n每 PWR 等效 100 CR. \n可用次数有限.",

		STIM = "实验性的 兴奋剂",
		STIM_TOOLTIP = "在一回合内提供无限攻击和 +1 穿\n甲。恢复 12 AP，但在本任务结\n束前最大 AP 减少 3. \n可用次数有限.",
		STIM_FLAVOR = "实验证明，这种化学鸡尾酒对*大多数*\n老鼠的致死率\"较低\".\n\n你*大概*会没事的...",

		SHOCK_TRAP = "实验性的 电击陷阱",
		SHOCK_TRAP_TOOLTIP = "放置在门上。开门时触发。具有范围效\n果。无视护甲. 可用次数有限.\n(注：是否友军伤害未经测试)",
		SHOCK_TRAP_FLAVOR = "这款试验性电击陷阱的范围特别大，按\n钮也特别大，便于使用者操作.",

		SHOCK_TRAP2 = "穿透式电击陷阱",
		SHOCK_TRAP2_TOOLTIP = "放置在门上。开门时触发。具有范围效\n果。无视护甲。无视磁性强化.\n可用次数有限.",
		SHOCK_TRAP2_FLAVOR = "这是一种由三角重工开发的更本地化、\n更有效的电击陷阱模型，可绕过磁性加\n固装置，被作为一种安全对策。\n毕竟，装有紧急小鬼头芯片的隐藏隔间\n有时并不能完全解决无人机的问题。",

		EMP = "多脉冲 EMP 包",
		EMP_TOOLTIP = "放置后在回合结束时爆炸。在 4 个回\n合内关闭所有主机设备和无人机。发射\n 3 个EMP脉冲. 可用次数有限.",
		EMP_FLAVOR = "高端 EMP 包能耦合多个连续脉冲，\n甚至能有效地使大多数带磁性增强装置\n的设备失效.",

		EMP2 = "穿透式 EMP 包",
		EMP2_TOOLTIP = "放置后在回合结束时爆炸。在 8 个回\n合内关闭所有主机设备和无人机。无视\n磁性强化. 可用次数有限.",
		EMP2_FLAVOR = "一个高端 EMP 包，可完全绕过磁\n性加固装置，但有效范围相当小.",

		GRENADE_CRY_BABY = "实验性的 爱哭鬼",
		GRENADE_CRY_BABY_TOOLTIP = "投掷使用，通过主机激活以产生噪音.\n即使在守卫视野范围内也不会被忽视.\n可用次数有限.",
		GRENADE_CRY_BABY_FLAVOR = "一个*超*大声、*超*恼人版本的\n爱哭鬼技术的实验品，肯定会吸引来自\n四面八方的安保人员.",
		GRENADE_CRY_BABY_USE = "激活爱哭鬼",
		GRENADE_CRY_BABY_USE_TIP = "设备将发出巨大声响.",

		GRENADE_CRY_BABY_DEAD = "部署型爱哭鬼",
		GRENADE_CRY_BABY_DEAD_TOOLTIP = "部署后不能被再次拾取（包括守卫），\n只能激活.",

		FLASH_PACK = "实验性的 闪光包",
		FLASH_PACK_TOOLTIP = "放置在地上，通过主机启动。需要\n 3 PWR。在5格内KO所有守卫\n4回合。可用次数有限.",
		FLASH_PACK_FLAVOR = "闪光弹的威力与主机无线技术的魔力相\n得益彰.",
		FLASH_PACK_USE = "引爆闪光包",
		FLASH_PACK_USE_TIP = "在5格内KO所有守卫4回合.对无人\n机无效.",

		TECHEXPO_FLAVOR = "\n\n该物品是一个实验性的原型机.",

		USB_DRIVE = "闪存盘",
		USB_DRIVE_TOOLTIP = "存储主机程序。任务中可点击图标安装,\n或在商店中出售它获利.",
		USB_DRIVE_FLAVOR = "这些看起来不起眼的闪存盘被广泛用于\n贩卖黑市软件，而不可篡改的水印标记\n确保了同一程序无法被出售两次.",

		AUGMENTS = {

			TITANIUM_RODS = "实验性的 钛合金骨骼",
			TITANIUM_RODS_TIP = "近战击倒伤害 +2 .",
			TITANIUM_RODS_FLAVOR = "有时，最简单的东西却最有效。钛合金\n骨骼让你更疼的殴打你的目标.\n\n该物品是一个实验性的原型机.",


			PIERCING_SCANNER = "实验性的 防弹扫描仪",
			PIERCING_SCANNER_TIP = "使远程武器的穿甲 +2 .",
			PIERCING_SCANNER_FLAVOR = "一系列的传感器和人工智能程序，可分\n析防弹装甲的弱点.\n\n该物品是一个实验性的原型机.",

			PENETRATION_SCANNER = "实验性的 穿刺扫描仪",
			PENETRATION_SCANNER_TIP = "使近战武器的穿甲 +2 .",
			PENETRATION_SCANNER_FLAVOR = "一系列的传感器和人工智能程序，可分\n析防刺装甲的弱点.\n\n该物品是一个实验性的原型机.",

			SKILL_CHIP_SPEED = "实验性的 运动学脑芯片",
			SKILL_CHIP_SPEED_TIP = "将特工的 \"速度 \"技能设置为4.\n除非通过植入钻头移除，否则该技能不可\n升级.",
			SKILL_CHIP_SPEED_FLAVOR = '\"芯片 \"一词其实是一种委婉的说法。事实上，这些设备是用来完全取代大脑突触区域的卷须的生长过程的.\n\n该物品是一个实验性的原型机.',

			SKILL_CHIP_HACKING = "实验性的 密码学脑芯片",
			SKILL_CHIP_HACKING_TIP = "将特工的 \"黑客 \"技能设置为4.\n除非通过植入钻头移除，否则该技能不可\n升级.",
			SKILL_CHIP_HACKING_FLAVOR = '\"芯片 \"一词其实是一种委婉的说法。事实上，这些设备是用来完全取代大脑突触区域的卷须的生长过程的.\n\n该物品是一个实验性的原型机.',

			SKILL_CHIP_STRENGTH = "实验性的 生理学脑芯片",
			SKILL_CHIP_STRENGTH_TIP = "将特工的 \"力量 \"技能设置为4.\n除非通过植入钻头移除，否则该技能不可\n升级.",
			SKILL_CHIP_STRENGTH_FLAVOR = '\"芯片 \"一词其实是一种委婉的说法。事实上，这些设备是用来完全取代大脑突触区域的卷须的生长过程的.\n\n该物品是一个实验性的原型机.',

			SKILL_CHIP_ANARCHY = "实验性的 智力学脑芯片",
			SKILL_CHIP_ANARCHY_TIP = "将特工的 \"不法者 \"技能设置为4.\n除非通过植入钻头移除，否则该技能不可\n升级.",
			SKILL_CHIP_ANARCHY_FLAVOR = '\"芯片 \"一词其实是一种委婉的说法。事实上，这些设备是用来完全取代大脑突触区域的卷须的生长过程的.\n\n该物品是一个实验性的原型机.',

		},

	},

	ABILITIES = {
		HACK_PERSONNELDB = "骇入数据库",
		HACK_PERSONNELDB_DESC = "制作伪装身份",
		HACK_ONLY_MOLE = "只有线人可以操作",

		SCRUB_CAMERADB = "擦洗数据库",
		SCRUB_CAMERADB_DESC = "删除所有摄像机和无人机的目击者状态",

		-- ESCAPE_GUARD = "Escape",
		ESCAPE_GUARD_DESC = "离开此关卡（警卫出口）",
		ESCAPE_GUARD_POWER_CELL = "线人必须先丢弃 {1} 才能离开!",

		INCOGROOM_UNLOCK = "移除锁",
		INCOGROOM_UNLOCK_DESC = "打开人工智能终端 4 把锁中的 1 个.",

		INCOGROOM_UPGRADE = "升级 INCOGNITA",
		INCOGROOM_UPGRADE_DESC = "使用此终端添加 1 个程序插槽或升级程序.",

		DEACTIVATE_LOCKS = "解锁",

		-- side missions
		W93_ESCAPE = "运送",
		W93_ESCAPE_DESC = "将电梯和物品栏内的所有箱子送到飞机上.",

		COMPILE_ROOM_USB = "带走程序",
		COMPILE_ROOM_USB_DESC = "把程序装到闪存盘上",
		COMPILE_ROOM_USB_UNCOMPILED = "程序尚未编译完成",

		USB_PROGRAM_INSTALL = "安装程序",
		USB_PROGRAM_INSTALL_SHORT = "安装 ",
		USB_PROGRAM_INSTALL_DESC = "通过闪存盘安装了 {1} 程序",

		RENAME = "改名 ",
		RENAME_DRONE = "对无人机改名",
		RENAME_DRONE_DESC = "对拆解无人机进行改名",
		RENAME_DRONE_CONFIRM = "确定",

		PET = "宠物 ",
		PET_DRONE = "宠物无人机",
		PET_DRONE_DESC = "抚摸无人机光滑的小脑袋",

		ACTIVATE_NANOFAB_CONSOLE = "呼叫技术支持",
		ACTIVATE_NANOFAB_CONSOLE_DESC = "呼叫受托保管纳米打印机钥匙的警卫.",

		UNLOCK_LUXURY_NANOFAB = "解锁纳米打印机",

		REROUTE_PWR = "重路由 PWR ({1} PWR)",
		REROUTE_PWR_DESC = "将 PWR 改道至工坊，而不是将其\n添加到 Incognita 中.",

		MODIFY_ITEM = "改装物品",
		MODIFY_ITEM_DESC = "通过工坊升级你的物品.",
		MOD_ITEM_DIALOG_TITLE = "物品升级工坊",
		MOD_ITEM_DIALOG_TXT = "升级以下的一个属性: {1}",
		MOD_ITEM_DIALOG_UNMODABLE = "\n\n无法改装此项目.",
		MOD_ITEM_DIALOG_PWR = "\n\n工坊内没有足够的 PWR 来改装此物品. {1} PWR 需要.",

		UPGRADE_OPTIONS =
		{
			CANCEL = "取消",
			COOLDOWN = "-1 物品冷却",
			CHARGE = "+1 最大充能数",
			AMMO = "+1 弹夹容量",
			POWER = "-1 PWR 消耗",
			SKILL_REQ = "移除技能需求",
			ARMOR_PIERCE = "+1 穿甲",
			DAMAGE = "+1 击倒伤害",
			USES = "More Uses",
		},

		CAPACITOR_CLOAK_INACTIVATE = "关闭隐形",
	},

	-- ACTIONS =
	-- {
	-- UNLOCK_BLUE = "Hyper-Unlock",
	-- UNLOCK_BLUE_TIP = "Unlock this door so hard, it stays open forever.",
	-- },

	DAEMONS =
	{
		MOLE_DAEMON = {
			NAME = "线人情报",
			NAME_ARMOR = "审讯情报",
			DESC = "任务开始时获取随机情报. 还能在 {1} 个额外 {1:mission|missions} 中使用.",
			DESC_ARMOR = "-1 对所有敌人的护甲. 还能在 {1} 个额外 {1:mission|missions} 中使用.",
			NOT_OMNI = "仅普通任务有效",
			NOT_OMNI_DESC = "OMNI 设施内不可用.",
			SHORT_DESC = "",
			ACTIVE_DESC = "线人提供的情报",
		},

		DISTRESS_CALL_INFO = {
			NAME = "设施警报",
			DESC = "发现囚犯试图逃跑。警报每回合以 2 倍速度推进.",
			SHORT_DESC = "快速警报推进",
		},

		MOLE_DAEMON_EVENT = {
			INTEL_TYPES = {
				["patrols"] = "部分保安被标记，巡逻路线将持续显示",
				["safes_consoles"] = "保险箱和控制台位置暴露",
				["cameras_turrets"] = "摄像头和炮台的位置暴露",
				["daemons_layout"] = "设施地图暴露，守护程序提前明示",
				["doors"] = "所有门的位置暴露",
				["armor"] = "安保护甲削弱",
			},

			-- for event notification
			MOLE_DAEMON_HEAD = "E S P I O N A G E   B O N U S",
			MOLE_DAEMON_TITLE = "线人情报",
			MOLE_DAEMON_TXT = "你的线人向你提供了有关该设施的以下情报:\n\n",

			ARMOR_DAEMON_HEAD = "I N T E R R O G A T I O N  B O N U S",
			ARMOR_DAEMON_TITLE = "保安审讯情报",
			ARMOR_DAEMON_TXT = "你对特殊安保的审问暴露了该设施装甲的弱点.\n\n-1 对所有敌人的护甲",
		},

		WITNESS_WARNING = {
			NAME = "{1} 个{1:WITNESS|WITNESSES} （目击者）剩余", --"WITNESS WARNING", --looks less cluttered when this string is empty
			DESC = "处理掉所有看到过线人的目击者",
			SHORT_DESC = "移除目击者",
			ACTIVE_DESC = "目击者追踪",
			GUARDS = "守卫",
			CAMERAS = "摄像机",
			DRONES = "无人机",
			ESCAPED = "目击者逃离数",
			WITNESSES_LEFT_GUARDS = "{1}目击者剩余.杀死或向KO的目标注射线\n人的麻痹剂来清除.",
			WITNESSES_LEFT_MAINFRAME = "剩余{1}名{1:证人|证人}。通过摧毁单位、EMP单位或清理摄像头数据库来移除。",
			-- WITNESSES_LEFT_DRONES = "剩余{1}名{1:证人|证人}。通过摧毁单位、EMP单位或清理摄像头数据库来移除。",
			-- WITNESSES_LEFT_DRONES_WE = "剩余{1}名{1:证人|证人}。通过摧毁单位或清理无人机连接来移除。", --Worldgen Extended
			WITNESSES_ESCAPED = "{1}个目击者逃出了关卡，无法再移除.",
			ITNESS_COUNT_NAME = "{1}x {2}",

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
			OBJ_FIND = "找到目标",
			OBJ_KILL = "杀死目标",
			OBJ_UNLOCK = "解锁生物安全门",
			SECUREDOOR_TIP = "使用VIP或者保镖的躯体解锁",
		},
		MOLE_INSERTION = {
			MOLE_OBJECTIVE = "保护线人的生命和身份安全，护送他们到\n警卫出口.",
			--MOLE_OBJECTIVE_SECONDARY = "",(可能有废案，这个二级目标是空的)
			OBJ_KILL_WITNESS = "解决所有线人目击者",
			OBJ_KILL_WITNESS_FAILED = "解决所有线人目击者（失败）",
			WITNESS_DETECTED = "检测到目击者",
			PERSONNEL_DB = "人事数据库",
			HACK_WITH_MOLE = "让线人进行骇入",
			FIND_DB = "找到人事数据库",
			HACK_DB = "协助线人黑入人事数据库",
			ESCAPE = "线人必须通过警卫电梯离开",
			NOT_SEEN = "不能让线人被看到",
			NOT_SEEN_FAILED = "不能让线人被看到（失败）",
			CAMERADB = "摄像头数据库",
			CAMERADB_TIP = "清理以移除摄像头/无人机发现",
		},
		AI_TERMINAL = {
			AI_OBJECTIVE = "访问 AI 终端",
			AI_OBJECTIVE_SECONDARY = "打开终端大门",
			OBJECTIVE1 = "解锁各个大门",
			OBJECTIVE2 = "使用人工智能终端",
			OBJ_FIND = "找到人工智能终端",
			EXIT_WARNING = "确定撤离吗？\n 您还没有访问人工智能开发终端.",

			DIALOG = { --this needs to be rewritten to be nicer and fluffier
				OPTIONS1 = { --do not edit these strings! --> ai_terminal.lua
					"CANCEL",
					"UPGRADE PROGRAM",
					"NEW PROGRAM SLOT",
				},

				OPTIONS1_PE = { --do not edit these strings! --> ai_terminal.lua
					"CANCEL",
					"DISRUPT HOSTILE AI",
					"UPGRADE PROGRAM",
					"NEW PROGRAM SLOT",
				},
				SLOTS_UNLIMITED = "无限制",

				OPTIONS1_TXT =
				"这台终端上有数月的人工智能研究数据，但由于失效开关的保护，你一\n次只能访问其中的一个子集。你可以增加 Incognita 的程序容量或升\n级现有程序。\n\n（注：选项分别是：获取新程序槽、升级程序、取消。未能翻译是因为\n修改这些内容会导致未知恶性Bug.）\n\n<c:FC5603>可用的升级:\n{1}\n{2}</c>",
				OPTIONS1_TXT_PE =
				"这台终端上有数月的人工智能研究数据，但由于失效开关的保护，你一\n次只能访问其中的一个子集。你可以增加 Incognita 的程序容量，升\n级现有程序，或者破坏研究，削弱这家公司的反间谍人工智能\n(Counterintelligence AI).\n\n（注：选项分别是：获取新程序槽、升级程序、破坏研究、取消。未\n能翻译是因为修改这些内容会导致未知恶性Bug.）\n\n<c:FC5603>可用的升级:\n{1}\n{2}</c>",
				-- OPTIONS1_TXT = "Choose between new slot and upgraded program",
				OPTIONS1_TITLE = "访问 AI 终端",

				OPTIONS2_SLOTS_TITLE = "新程序槽",
				OPTIONS2_SLOTS_TXT =
				"你可以利用这项终端为 Incognita 添加一个空的程序插槽，\n以便安装更多程序。但必须等到下一个任务中，该插槽才将可用.\n\n当前插槽数量: {1}\n最大插槽数量: {2}",

				OPTIONS2_SLOTSFULL_TITLE = "程序槽已满",
				OPTIONS2_SLOTSFULL_TXT =
				"你可以利用这项终端为 Incognita 添加一个空的程序插槽，以\n便安装更多程序。但必须等到下一个任务中，该插槽才将可用.\n\n当前插槽数量: {1}\n最大插槽数量: {2}\n\n最大程序槽数量已达到.\n返回开始页面.",

				OPTIONS2_RESULT1_TITLE = "新程序槽已获取",
				OPTIONS2_RESULT1_TXT = "获得新程序插槽。任务结束后即可使用.",

				OPTIONS2_CANCEL_CONFIRM = {
					"取消",
					"确定"
				},

				OPTIONS2_PE_TXT_ONE_CORP =
				"您可以利用该终端上的数据，\n破坏以下集团的人工智能研究: <c:FC5603>当前集团</c>, 降低反情报人工智能(Counterintelligence AI)\n的威胁等级.\n\n这将使 <c:FC5603>{1}</c> AI 开局时使用的子程序数量减少 2 个(最少为1), \n并减少选择池的数量.",
				OPTIONS2_PE_TXT_ALL_CORPS =
				"你可以使用此终端上的数据来破坏<c:FC5603>所有公司</c>的AI研究，降低它们反情报AI的威胁等级。\n\n这将使每个{1} AI启动时的子程序数量减少2个（最少为1），并减少选择池。\n\n不影响OMNI公司。",
				OPTIONS2_PE_TXT_CORPORATE = "集团",
				OPTIONS2_PE_ALREADY_WEAKENED = "\n\n你已经削弱了 {1} AI 以下层数: {2} {2:level|levels}.",
				OPTIONS2_PE_TITLE = "瓦解集团 AI",

				OPTIONS_PE_RESULT_TITLE = "破坏成功",
				OPTIONS2_PE_RESULT_TXT = "在适当的地方植入一两个令人讨厌的病毒，\n就能造成巨大的破坏。\n从下一个任务开始， \n{1} AI 现在应该会变得更弱.",

				OPTIONS2_TXT = "选择要升级的程序. \n\n<c:FC5603>警告：同一程序不能升级两次.\n\n可提供的升级:\n{1}\n{2}</c>",
				OPTIONS2_TXT_COMPACT = "选择要升级的程序. \n<c:FC5603>警告：同一程序不能升级两次.\n可提供的升级: {1}, {2}.</c>", --more compact, for full program slots/many buttons
				-- OPTIONS2_TXT = "Select a program to upgrade. <c:FC5603>Cannot upgrade the same program twice. AVAILABLE UPGRADES:{1}, {2}</c>",
				OPTIONS2_TITLE = "选择程序",

				OPTIONS3_TXT = "选择一个变量进行升级.",
				OPTIONS3_TITLE = "选择变量",
				OPTIONS3 = { --do not edit these strings! --> ai_terminal.lua
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
				OPTIONS4_TXT = "您想如何修改该变量?\n\n<c:FC5603>警告: 变量不能低于 1.\n如果变量为 0 或不可用，则无法升级.</c>",

				OPTIONS_FIREWALLS_TITLE = "防火墙破译强度",
				OPTIONS_FIREWALLS_INCREASE = "破译强度提高 1.",
				OPTIONS_FIREWALLS_DECREASE = "破译强度降低 1.",

				INVALID = "不可用",
				FIREWALLS_TIP = "{1} 目前的防火墙破译强度为 {2}.\n\n",
				PWRCOST_TIP = "{1} 目前的 PWR 费用为 {2}.\n\n",
				COOLDOWN_TIP = "{1} 目前的冷却时间为 {2}.\n\n",
				RANGE_TIP = "{1} 目前的范围是 {2}.\n\n",

				OPTIONS_PWRCOST_TITLE = "PWR 消耗",
				OPTIONS_PWRCOST_INCREASE = "PWR 消耗增加 1",
				OPTIONS_PWRCOST_DECREASE = "PWR 消耗减少 1",

				OPTIONS_COOLDOWN_TITLE = "冷却",
				OPTIONS_COOLDOWN_INCREASE = "冷却时间 增加 1",
				OPTIONS_COOLDOWN_DECREASE = "冷却时间 减少 1",

				OPTIONS_RANGE_TITLE = "范围",
				OPTIONS_RANGE_INCREASE = "有效范围 增加 1 格",
				OPTIONS_RANGE_DECREASE = "有效范围 减少 1 格\"",

				PROGRAM_UPGRADED_SUCCESS = "程序已升级",
				PROGRAM_UPGRADE_FAIL_TXT = "无法升级该变量。返回目录.", --needs to be implemented
				PROGRAM_UPGRADE_FAIL_TITLE = "无效的升级",

				START_OVER = "返回",

				NO_PROGRAMS = "无可用程序",
				NO_PROGRAMS_DESC = "没有可用程序。退出目录.", --不会有人真的把所有程序都卖了吧，流汗黄豆.jpg


			},
		},

		SIDEMISSIONS = {
			STEAL_STORAGE =
			{
				OBJECTIVE1 = "找到所有储藏室",
				OBJECTIVE2 = "偷走尽可能多的箱子",
				TEXT1 = "检测到高价值物品",
			},
			PERSONNEL_HIJACK = -- I can finally fix this typo!!!!
			{
				OBJECTIVE1 = "把 %s 拖到飞机上",
				TAB = "机遇目标已确认",
				TAB_SUB = "可能的情报",
			},
			LUXURY_NANOFAB =
			{
				FIND_KEY = "找到豪华打印机钥匙",
				FIND_NANOFAB = "找到豪华打印机",
				UNLOCK_NANOFAB = "用钥匙解锁豪华打印机",
			},
			WORKSHOP =
			{
				OBJECTIVE_1 = "将控制台的 PWR 重路由: {1} PWR",
				OBJECTIVE_2 = "使用工坊升级物品",
			},
		},
	},

	LOCATIONS = {
		--used by serverdefs.lua
		HOLOSTUDIO = {
			NAME = "Holostudio",
			MORE_INFO =
			"This site features its own dedicated holographic design laboratory. Our agents can steal and use some of the advanced tech here to deceive and evade.\n\nSome of these items are not available at any nanofabs.", --This can be quite lengthy.
			INSET_TITLE = "MARKETING AGENCY",                                                                                                                                                                         --unused
			INSET_TXT = "I'm not going to lie, operator. There's an awful lot of unused flavour text in these files.",                                                                                                --unused
			INSET_VO = { "moremissions/VoiceOver/Central/holostudio/mapscreen" },
			DESCRIPTION = "Locate and acquire state-of-the-art hologram technology.",
			REWARD = "A powerful disguise or stealth tool.",
			-- LOADING_TIP = "",
		},
		ASSASSINATION = {
			NAME = "刺杀行动",
			MORE_INFO =
			"这个地方的一个高级主管的赏金很高，\n但如此高调的袭击不会让公司无动于衷。 \n要小心--据说目标很偏执，有私人保安在现场。\n但如果你没致命武器也别担心，\n公司的一些东西也能被用来对付他。", --This can be quite lengthy.
			INSET_TITLE = "MARKED FOR DEATH", --unused
			INSET_TXT =
			"I wouldn't normally stoop to assassination contracts, but the payday on this one is too tempting to ignore. The target is highly placed, so we can expect heightened security at this corporation if you complete the job. Ready to get your hands dirty, Operator?", --unused
			INSET_VO = { "moremissions/VoiceOver/Central/assassination/mapscreen" },
			DESCRIPTION = "解决 VIP.",
			REWARD = "高额的现金奖励.\n代价是该公司的安全级别永久性提高1级.",
		},
		LANDFILL = {
			--This one is supposed to hold only items the operator doesn't normally have, but there's no way to lore-ify that information, is there? -M
			NAME = "Salvaging plant",
			MORE_INFO =
			"Tons of various objects get dumped on this landfill and ground up for whatever materials can be recovered. Some of the items can probably be repaired inexpensively.\n\nDon't expect the goods to be very likable, many of them have been here for weeks without getting any love.", --This can be quite lengthy.
			INSET_TITLE = "LANDFILL",                                                                                                                                                                                                                                                    --unused
			INSET_TXT = "I'm not going to lie, operator. There's an awful lot of unused flavour text in these files.",                                                                                                                                                                   --unused
			INSET_VO = { "moremissions/VoiceOver/Central/assassination/mapscreen" },
			DESCRIPTION = "Find and access the repair workstation.",
			REWARD = "A range of heavily discounted items.",
		},
		-- EA_HOSTAGE = STRINGS.MOREMISSIONS_HOSTAGE.EA_HOSTAGE,
		EA_HOSTAGE = {
			NAME = "找回信使",
			MORE_INFO = "数据信使为他们的客户传输有价值的信息，但如果被公司抓到，他们很容易成为目标。这个信使对公司的设施有详细了解，可以为我们提供附近的更多目标。",
			INSET_TITLE = "CODE NAME: INSOMNIAC",                                                                                                                                                                                                                                                                                                                                     --unused
			INSET_TXT =
			"This corp has intercepted a data courier of one of our former clients. He has important site intel stored in a cerebral implant, intel we can persuade his employer to share with us. Your task is to break in and recover the courier, safe and sound. One last thing, Operator - the implant is set to explode if the courier loses consciousness, so time is of the essence.", --unused
			INSET_VO = { "moremissions/VoiceOver/Central/courierrescue/mapscreen" },
			DESCRIPTION = "营救失踪的信使,并与他一起在有限的时间内逃生.",
			REWARD = "三个本公司的其他目标地点, 近距离优先.",
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

		DISTRESS_CALL = {
			NAME = "求救信号",
			MORE_INFO =
			"我们截获了一名特工需要撤离的信号。\n这可能是我们失踪的特工之一，\n但就算不是，一旦我们安全救出他们，\n也能索要一笔报酬。 \n\n小心，执行官 - \n我们的遥测显示，该设施已发出警报，\n警报级别将因此更快地提升.", --This can be quite lengthy.
			INSET_TITLE = "OPERATIVE EXTRACTION", --unused
			INSET_TXT =
			"We've detected an urgent distress call at this facility. It may be one of our agents attempting an escape, or some other operative who's stumbled onto our signal network. There's no time to waste, Operator. If you mean to extract them, do it now. We will not get a second chance if we delay.", --unused
			INSET_VO = { "moremissions/VoiceOver/Central/distresscall/mapscreen" }, --{"SpySociety_DLC001/VoiceOver/Central/DLC_Central_6_midmission_briefing_imnotgoing"},
			DESCRIPTION = "将逃脱的特工安全送到撤离地点，\n并在离开时拿回他们被没收的装备。\n这里的警报级别会提高得更快。",
			REWARD = "特工或囚犯，以及他们的装备.\n<c:FC5603>紧急: 如果不马上前往，任务将消失.</c>",
		},

		WEAPONS_EXPO = {
			NAME = "原型窃取",
			MORE_INFO =
			"在一个著名的科技展览会上，\n你有机会在一些功能强大的原型进入市场之前偷走它们。\n你可以在这里找到先进的武器和功能强大的限用物品，\n但是安全系统也不会让你掉以轻心--\n偷得越多，风险越大。", --This can be quite lengthy.
			INSET_TITLE = "TECH EXPO", --unused
			INSET_TXT =
			"This facility is hosting a world class tech exposition. The corporations and the industry's finest will be showing off their newest prototypes. We should be able to nab us some prize gear, provided we visit after hours. But keep your guard up - rumour has it their security system is every bit as experimental as the tech they're showcasing.", --unused unless we actually get these voiced somehow --CRAZY, RIGHT?
			INSET_VO = { "moremissions/VoiceOver/Central/techexpo/mapscreen" },
			DESCRIPTION = "找到科技展览室，\n然后偷走至少一个原型.",
			REWARD = "先进武器和强大的限用物品，\n您可以出售或自己装备.",
		},

		MOLE_INSERTION = {
			NAME = "线人接头", -- thanks to jlaub for name idea
			MORE_INFO =
			"我们有机会在这个设施中安插一名线人，\n他将从内部为我们提供情报。\n这项任务不会立即给你带来奖励，\n但你会在今后的任务中提前获取渗透目标的信息。 \n\n确保线人不被发现，\n以最大限度地延长奖励时间（5个任务）.",
			INSET_TITLE = "",
			INSET_TXT =
			"We've been flying blind for too long. Our old network is gone, but Monst3r has put us in touch with a reliable freelancer who can help us build it back up again. First, we'll need to get them on site and secure their cover. Make sure the enemy doesn't spot them, or the job will get complicated.",
			INSET_VO = { "moremissions/VoiceOver/Central/informant/mapscreen" },
			DESCRIPTION = "安插一名线人并保护其身份隐蔽。\n为达到最佳效果，\n线人必须不被发现.",
			REWARD = "在接下来的几个任务中获得情报奖励，\n例如设施布局、守卫标记或摄像头位置.",

		},

		AI_TERMINAL = {
			NAME = "AI 终端",
			MORE_INFO = "我们找到了一个AI终端。\n它的安全等级非常高，\n但我们应该可以整合其中的一些研究成果 \n来提高Incognita的计算效率。\n这个终端需要多把钥匙才能打开，\n所以最好准备周全.",
			INSET_TITLE = "",
			INSET_TXT =
			"We've unearthed an off-the-books AI research facility. We may be able to use it to upgrade Incognita, but tread lightly, Operator. We can only assume there's a good reason they've kept this place so well-hidden.",
			INSET_VO = { "moremissions/VoiceOver/Central/aiterminal/mapscreen" },
			DESCRIPTION = "使用现场的钥匙卡和设备，\n解锁和访问人工智能开发终端.",
			-- REWARD = "An additional program slot for Incognita, or valuable tech if at upgrade cap (2 additional slots).",
			REWARD = "为 Incognita 增加一个程序格子，\n或对现有程序进行升级。\n注：剧情模式一般最多升级2个格子,但无尽没有限制",

		},

	},

	UI = {

		MAP_SCREEN = {
			MOLE_NAME = " 线人情报",
			MOLE_DESC = "线人情报可用.",
			MOLE_TOOLTIP = "情报在接下来 {1} 个{1:mission|missions}中有效 ",
			HOSTILE_AI_TEXT = "<c:f5ff78>COUNTERINTELLIGENCE AI</c>\n威胁等级: {1}\nAI 终端破坏: -{2}",
			HOSTILE_AI_NAME = "HOSTILE AI",
		},

		HUD_WARN_EXIT_MISSION_HOLOSTUDIO = "确定撤离吗？\n You don't have the holographic tool yet.",
		HUD_WARN_EXIT_MISSION_ASSASSINATION = "确定撤离吗？\n你还没有解决任务目标.",
		-- REASON = {
		-- HYPERUNLOCKED = "Busted open by a blue keycard",
		-- },
		DISTRESS_OBJECTIVE = "救出特工",
		DISTRESS_OBJECTIVE_SECONDARY = "找到 {1} 的装备",
		DISTRESS_OBJECTIVE_SECONDARY_OPERATIVE = "the Operative",
		DISTRESS_AGENT_GEAR_CONTAINER = "热能信号",
		DISTRESS_AGENT_GEAR_CONTAINER_DESC = "检测到高价值物品", --should probably go under MISSIONS above but we can tidy things later...
		WEAPONS_EXPO_OBJECTIVE = "偷走至少一件原型",
		WEAPONS_EXPO_EMP_SAFE = "该装置需要一种特殊的电信号激活。EMP对此并不起作用。",
		WEAPONS_EXPO_WARN_EXIT = "确定撤离吗？\n你还没有偷走任何原型机.",
		WEAPONS_EXPO_FIREWALLS = "失效开关触发： 防火墙升级",
		WEAPONS_EXPO_DROIDS_WARNING = "检测到新威胁",
		WEAPONS_EXPO_DROIDS_WARNING_SUB = "启动中...",
		WEAPONS_EXPO_SWITCHES_OBJECTIVE = "找到并偷走技术原型",
		WEAPONS_EXPO_FIND_SWITCHES = "找到禁用防火墙脉冲的方法",
		DOORS_REVEALED = "门位置暴露",
		EXIT_REVEALED = "出口位置暴露",
		NO_GUARD_ESCAPE = "必须先访问人事数据库",
		NO_ESCAPE_OVERWATCHED = "无法在被发现时离开",
		CAMERADB_SCRUBBED = "所有设备已清理",
		WITNESS_CLEARED = "目击者已移除",
		MOLE_EXIT_WARNING = "确定撤离吗？\n您还没有找到人事数据库.",
		MOLE_EXIT_WARNING2 = "确定撤离吗？\n 线人需要从保，安，电，梯逃走！\n点击确定，任务将被视为失败.",
		INCOGROOM_TEXT1 = "检测到高级安全门",
		INCOGROOM_SAWSAFE = "检测到AI金库卡",
		INCOGROOM_SAWCONSOLE = "检测到高级安全门密钥",
		FANCYFAB_CONSOLE = "技术支持控制台",
		FANCYFAB_CONSOLE_DESC = "激活以呼叫带钥匙的警卫",
		FANCYFAB = "豪华纳米打印机",
		FANCYFAB_DESC = "用纳米打印机钥匙解锁",

		TOOLTIPS = {
			NO_PATROL_CHANGE = "固定巡逻路线",
			NO_PATROL_CHANGE_DESC = "不会对巡逻路线变化做出反应.",
			NO_ALERT = "无苏醒警报",
			NO_ALERT_DESC = "当他们醒来时，该目标不会发出警报.",

			-- Courier Rescue
			EA_HOSTAGE_FRAIL = "脆弱",
			EA_HOSTAGE_FRAIL_DESC = "KO伤害等效致命伤害，不可复苏.",
			EA_HOSTAGE_VITAL_STATUS = "生命垂危",
			EA_HOSTAGE_VITAL_STATUS_DESC = "目标死亡前最多能坚持回合数： {1} {1:turn|turns}.",

			-- Informant Rendezvous
			PARALYZE_AMNESIAC = "使用麻痹剂",
			PARALYZE_AMNESIAC_DESC = "向目标注射失忆麻痹剂。解除witness（目击者）状态。\n目标最大视野范围缩小{1}格。守卫醒来时不会进入警戒.",
			WITNESS = "WITNESS",
			WITNESS_DESC_HUMAN = "杀死该单位或KO并使用\"失忆\"麻痹剂.",
			WITNESS_DESC_MAINFRAME = "使用EMP，或用致命武器销毁该设备，或\n擦除摄像机数据库.",
			-- WITNESS_DESC_DRONE = "销毁该单位或使用EMP.",
			NO_CAMERADB_WITNESSES = "没有摄像机或无人机目击者",
			MOLE_CIVILIAN = "脆弱", --"CIVILIAN",
			MOLE_CIVILIAN_DESC = "中弹后无法复活.", --"Cannot use weapons or be revived.",
			MOLE_JET_ESCAPE = "灵活撤离选项",
			MOLE_JET_ESCAPE_DESC = "线人从友方电梯逃离会导致任务失败，\n但会增加另一个线人会合任务.",

			-- tech expo
			WEAPONS_EXPO_RESALE = "难以销售",
			WEAPONS_EXPO_RESALE_DESC = "该原型机尚未投放市场，只能半价销售.",

			WEAPONS_EXPO_LOOT_CONTENT = "展示牌",
			WEAPONS_EXPO_FAILSAFE = "失效开关",
			WEAPONS_EXPO_FAILSAFE_DESC = "捕获后，增强其余展品的防火墙.\n会防止其他展示目标被同时破解.",

			WEAPONS_EXPO_FAILSAFE_OFF = "失效开关已禁用",
			WEAPONS_EXPO_FAILSAFE_OFF_DESC = "已禁用失效开关。不受任何防火墙增强的影响.",

			WEAPONS_EXPO_SWITCH = "失效开关控制器",
			WEAPONS_EXPO_SWITCH_DESC = "同时激活两个控制器，将防止展品的防\n火墙进一步增强.",

			--assassination
			TARGET_ALERT = "与保镖连接",
			TARGET_ALERT_DESC = "该单位首次处于警戒或受到攻击时，保\n镖或最近的有意识的卫兵会进入警戒状\n态.",
			BODYGUARD_ALERT = "与VIP连接",
			BODYGUARD_ALERT_DESC = "该单位首次处于警戒或受到攻击时，\nVIP将在下一回合进入警戒状态.",
			BODYGUARD_KEEPCLOSE = "保镖",
			BODYGUARD_KEEPCLOSE_DESC = "在没有处于警戒状态的情况下，这个单\n位不会远离VIP，并会代替VIP调查.",
			TARGET_PARANOID = "偏执",
			TARGET_PARANOID_DESC = "如果兴趣点在视线范围内，将委托保镖\n进行调查.",
			AUTHORIZED_BODY = "生物门权限",
			AUTHORIZED_BODY_DESC = "如果拖动到门口，该单位的躯体将解锁\n避险室.",
			AUTHORIZED_BODY_DESC2 = "如果被拖动或控制，该单位的躯体可以\n解锁避险室.",
			IMPAIRED_VISION = "视野受限",
			IMPAIRED_VISION_DESC = "该单位的视野范围缩小.",
			DECOY = "诱饵",
			DECOY_DESC = "这不是真正的目标。安全屋里的那个人\n才是真正的目标.",

			-- ai terminal
			KO_GAS = "有毒气体",
			KO_GAS_DESC = "该特工周围都是有毒气体，如果他们在\n这里结束回合，就会被 KO .",
			KO_GAS_PINNED = "中毒",
			KO_GAS_PINNED_DESC = "该特工的击倒计时器不会减少，直到他\n们离开击倒气体为止.",
			DOOR_LOCK_ACCESS = "特殊门锁许可",
			LOCK_ACCESS_CONSOLE_DESC = "黑入该控制台将打开人工智能终端的一\n扇门.",
			LOCK_ACCESS_SAFE_DESC = "该保险箱中装有人工智能终端其中一扇\n门的门禁卡.",

			PROGRAM_UPGRADE = {
				UPGRADED = "升级版",
				UPGRADED_LONG = "AI 终端升级",
				PARASITE = "{1} 寄生虫破解强度",
				FIREWALLS = "{1} 防火墙破解数",
				PWRCOST = "{1} PWR 消耗",
				COOLDOWN = "{1} 冷却",
				RANGE = "{1} 范围",
				PWRCOST_Rapier = "{1} PWR 消耗. 细剑将在一个额外的\n警报级别中（一般是1级），保持 1 \n的 PWR 消耗.", --special case for -1 PWR cost on Rapier
			},

			HOSTILE_AI_WEAKEN = "AI 终端破坏",
			HOSTILE_AI_WEAKEN_DESC = "该人工智能已被破坏，其子程序比正常\n情况下少 {1} 个.",

			-- misc + side missions

			BOSSUNIT = "机遇目标",
			BOSSUNIT_DESC = "将这个单位带到飞机以进行审讯。在接\n下来的 2 次任务中降低守卫装甲.",

			NOT_CARRYABLE = "不可拾取",
			NOT_CARRYABLE_DESC = "此物品已损坏，无法再次拾取.",

			NO_HIDING = "不在掩体中",
			NO_HIDING_DESC = "不受掩体保护.",

			USB_PROGRAM_STORED = "储存的程序: {1}",

			REPROGRAMMED = "已重新编译",
			REPROGRAMMED_DESC = "这架拆解无人机由机构控制.",

			LEAVES_AT_END = "易碎外壳",
			LEAVES_AT_END_DESC = "任务结束后将在飞机上报废.",

			OPPORTUNITY_ALLY = "机遇盟友",
			OPPORTUNITY_ALLY_DESC = "将这架无人机带到喷气机上，获得现金\n奖励，并重新编程供自己临时使用.",

			CAN_JACKIN = "蓝牙虹吸",
			CAN_JACKIN_DESC = "可以从控制台获取PWR.",

			FANCYFAB_WARNING = "重新校准协议",
			FANCYFAB_WARNING_DESC = "会在打印一件 (1) 物品后关闭.",

			NANOFAB_TYPE = "广域物品可选",
			NANOFAB_TYPE_DESC = "类型:",

			NANOFAB_CONSOLE = "技术支持热线",
			NANOFAB_CONSOLE_DESC = "启动以呼叫纳米打印机钥匙携带者.",

			IDLE_SCAN = "静止扫描",
			IDLE_SCAN_DESC = "如果未发现目标，会在每个敌人回合开\n始时扫描周围.",

			STATUS_SURVEYING = "调查中",
			SURVEYOR = "调查者",
			SURVEYOR_DESC = "如果未发现目标，会在每个敌人回合结\n束时逆时针旋转 90 度.",

			ZAP_ATTACK = "电击枪",
			ZAP_ATTACK_DESC = "用非致命电击枪击倒目标.",

			INFRARED_SENSORS = "红外传感器",
			INFRARED_SENSORS_DESC = "即使在掩体后面，也能注意到特工的行动.",

			ITEM_MODDED = "已改装",
			ITEM_MODDED_DESC = "这件物品已被改装: {1}",
		},

		REFIT_DRONE_NAMES = {
			"Cyberbot3000",
			"Floaty1337",
			"The Zwebster",
			"Android Kay",
			"Droni",
			"Beeps",
			"Wodzu",
			"The Wod Bot",
			"Chip",
			"Qoalabot",
			"R30hedrone",
			"Tiny Tim",
			"iLaub",
			"Cheeto-So-Robo",
			"Autonahton",
			"Hal",
			"Kirbii",
			"Pipp",
			"MechBirb",
			"Shiny",
			"Plinky",
			"Greywind",
			"Datapincher",
		},

	},

	AGENT_LINES =
	{
		DISTRESS_CALL =
		{
			[_M.AGENT009] = "我叫 Lien. Jimmy Lien. \n\n我觉得我们能互相帮助.",
			[_M.DECKER] = "仿佛现在就能看到出口了.",
			[_M.INTERNATIONALE] = "让我们逃出去.",
			[_M.BANKS] = "你让我眼前一亮。或者耳朵.",
			[_M.NIKA] = "...\n\n想不到又见面了.",
			[_M.SHARP] = "事情都在我的掌控之中...\n不过还是谢谢你可以拉我一把.",
			[_M.SHALEM] = "省去了制定逃跑计划的麻烦.",
			[_M.TONY] = "来得正是时候，行动官。我正要离开.",
			[_M.PRISM] = "好。是时候把事情解决了.",
			[_M.MONSTER] = "我说过我讨厌弄脏手吗？\n好吧，看样子我又说了一遍.",
			[_M.RUSH] = "哦，很好。\n反正我也坐烦了.",
			[_M.DRACO] = "你的协助是多余的 \n-- 但不是不受欢迎.",
			[_M.DEREK] = "我有预感你会来这里，在关键时刻和一切机会.",
			[_M.CENTRAL] = "呼，你终于来了。\n来得正好，现在带我离开这里.",
			[_M.OLIVIA] = "很好。我不想在这个鬼地方多待一秒.",
		},
		MOLE_INSERTION = {
			MOLE_MISSION_START = "我进来了。记住两件事：没有安保看见我，还有\n别害死我。遵守这两点，我们就是最好的朋友.",
		},

		SIDE_MISSIONS = {
			REFIT_DRONE = {
				"Bzzzzt.",
				" < Beepity-boop > ",
				" < Bzz-beep? > ",
				" < Boop-boop-boop > ",
				" < Bzzzz-beep > ",
				" < Boop-bzeep. > ",
			},
		},
	},

	-- STORY SCRIPTS BEGIN HERE
	BANTER = {
		--automatically compiled by story_scripts.lua
		INGAME = {
			--Central's one-liners are technically speaking scripts with only one line, thus the nesting.

			ASSASSINATION = {
				OBJECTIVE_SIGHTED = {
					{ { "你找到目标了。\n最好小心接近，行动官。\n这不是第一次有人要杀他，\n所以他肯定准备的很充分.",
						"moremissions/VoiceOver/Central/assassination/sighted/regular",
						"Central" } },
				},
				OBJECTIVE_SIGHTED_NO_WEAPONS = {
					{ { "你找到目标了。\n但由于你没带致命武器，\n所以只能随机应变了.",
						"moremissions/VoiceOver/Central/assassination/sighted/unprep_1p",
						"Central"
					},
						{ "根据我们客户的情报，\n目标最近安装了新的 K&O 安防系统。\n我们或许可以利用这一点。\n发挥点创意，行动官.",
							"moremissions/VoiceOver/Central/assassination/sighted/unprep_2p",
							"Central" }, },
				},
				DOOR_SIGHTED = {
					{
						{ "有意思，我们的目标准备了一间避难室。\n\n目标和他的保镖应该都有这扇门的密码.",
							"moremissions/VoiceOver/Central/assassination/sighted/room_1p",
							"Central" },
						{ "我们没有时间解开密码，\n所以你需要把他们之中的一个拖到门口。\n当你通过时，\n他们的躯体也会使激光失效.",
							"moremissions/VoiceOver/Central/assassination/sighted/room_2p",
							"Central" },
					},
				},
				KO = {
					{ { "我们做事不能只做一半，行动官。\n用*任何*你能想到的方法，\n完成你的任务.",
						"moremissions/VoiceOver/Central/assassination/nonlethal",
						"Central" } },
				},
				DECOY_REVEALED = { --discovered decoy the hard way
					{ { "该死，我们上当了！\n行动官,诱饵仿生人的全息技术很先进，\n以至于连Incognita的扫描都能骗过。\n真正的目标一定就在附近.",
						"moremissions/VoiceOver/Central/assassination/decoy_1p",
						"Central" },
						{ "看看你能不能找到他，\n否则我们就只能铩羽而归了.",
							"moremissions/VoiceOver/Central/assassination/decoy_2p",
							"Central" } },
				},
				FOUND_REAL_TARGET_LATE = { --found real target after bumping into decoy
					{ { "找到真正的目标了，终于啊。 \n赶紧动手吧，行动官，\n这活已经比我预想的麻烦太多了.",
						"moremissions/VoiceOver/Central/assassination/sighted/postdecoy",
						"Central" } },
				},
				FOUND_REAL_TARGET = { --found real target before decoy was busted
					{ { "你看到了吗, 行动官？ \n那看起来才是我们真正的目标，\n而他已经躲在他的保险箱里了.",
						"moremissions/VoiceOver/Central/assassination/sighted/predecoy_1p",
						"Central" },
						{ "可惜我们需要他死；\n要不是他的偏执挡了我们的财路的话，\n我几乎要佩服他这种程度的偏执了.",
							"moremissions/VoiceOver/Central/assassination/sighted/predecoy_2p",
							"Central" } },
				},
				AFTERMATH = {
					{ { "到目前为止，一切顺利。\n让我们的特工离开那里，\n我们就可以找客户领钱了.",
						"moremissions/VoiceOver/Central/assassination/killed1",
						"Central" } },
					{ { "这也是增加他的社会净值的一种方式，\n同时对我们也一样。\n干得好，行动官。\n撤离整支队伍。",
						"moremissions/VoiceOver/Central/assassination/killed2",
						"Central" } },
					{ { "精准的时机，行动官。\n我都要听腻了他那痛苦的哀嚎声。\n你让我们俩都摆脱了痛苦.",
						"moremissions/VoiceOver/Central/assassination/killed3",
						"Central" } },
				},
				CENTRAL_JUDGEMENT = {
					GOTBODY = {
						{ { "这将花费我们一笔不小的清理费用，\n但我们的客户应该很乐意为此付出代价。\n把宣泄当作额外奖励吧，行动官.",
							"moremissions/VoiceOver/Central/assassination/judge/kill1",
							"Central" } },
						{ { "虽然比我预想的麻烦一点，\n但我们不能挑三拣四，\n尤其是在如此丰厚的赏金面前。\n干得好.",
							"moremissions/VoiceOver/Central/assassination/judge/kill2",
							"Central" } },
					},
					GOTNOTHING = {
						{ { "你没有得到我们想要的东西. \n也许你想把自己的头献给我们的客户？",
							"moremissions/VoiceOver/Central/assassination/judge/nokill1",
							"Central" } },
						-- {{"You didn't eliminate the target. I hope you weren't being squeamish, Operator. Wetwork is a necessity in our profession, and our circumstances don't allow us the luxury of keeping our hands clean.", --this is too long to fit :(
						{ { "你没有消灭目标。 \n我希望你没有胆怯，行动官 -- \n我们的情况不允许我们保持双手干净.",
							"moremissions/VoiceOver/Central/assassination/judge/nokill2",
							"Central" } },
						{ { "我不认为我总是需要提醒你\"你的目\n标是什么\"。 \n与我们刚刚损失的钱相比，\n你从这个设施里偷到的东西实在是微不足道。\n我希望你好好解释一下刚刚的偷懒.",
							"moremissions/VoiceOver/Central/assassination/judge/nokill3",
							"Central" } },
					},
				},
			},

			EA_HOSTAGE = STRINGS.MOREMISSIONS_HOSTAGE.INGAME,

			DISTRESS_CALL = {
				SAW_AGENT = {
					{ { "那是我们的人，行动官。\n你的任务很简单：\n把那个特工带到撤离点.",
						"moremissions/VoiceOver/Central/distresscall/sighted/agent_1p",
						"Central" } },
					{ { "但是千万小心 -- 这些动静不可能被无视。\n他们的安全级别现在应该开始迅速提高了.",
						"moremissions/VoiceOver/Central/distresscall/sighted/agent_2p",
						"Central" } },
				},
				SAW_OTHER = {
					{ { "我们已经联系上了他。\n这不是我们的人，但这并不意味着他没有价值。\n看看能不能把他弄出来，\n我可以在飞机上跟他好好谈谈报酬.",
						"moremissions/VoiceOver/Central/distresscall/sighted/prisoner",
						"Central" } },
					{ { "但是千万小心 -- 这些动静不可能被无视。\n他们的安全级别现在应该开始迅速提高了.",
						"moremissions/VoiceOver/Central/distresscall/sighted/agent_2p",
						"Central" } },
				},
				SAW_GEAR_CONTAINER = {
					{ { "注意，行动官。\n根据Incognita的信息，他们可能把囚犯的装备放\n在这里了，让我们打开看看.",
						"moremissions/VoiceOver/Central/distresscall/sighted/stash",
						"Central" } },
				},
				CENTRAL_JUDGEMENT = {
					GOT_AGENT = {
						{ { "我们已经让他们知道，\n我们的人是关不住的。\n让那个特工准备下一个行动，行动官。\n干得漂亮.",
							"moremissions/VoiceOver/Central/distresscall/judge/agent_out1",
							"Central" } },
						{ { "好在我们及时提供了救援。\n现在我们这边又多了一双手，\n我们也因此变得更强大了.",
							"moremissions/VoiceOver/Central/distresscall/judge/agent_out2",
							"Central" } },
						{ { "那名特工无疑让我们以后的营救工作变得更加轻松。\n我想，大家应该都为自己的工作感到自豪。\n各位辛苦了.",
							"moremissions/VoiceOver/Central/distresscall/judge/agent_out3",
							"Central" } },
					},
					LOST_AGENT = {
						{ { "你在搞什么鬼啊，行动官！\n那个特工都已经要脱身了，你要做的仅仅是进去接走他们!\n这么简单的活都做不到吗？",
							"moremissions/VoiceOver/Central/distresscall/judge/agent_fail1",
							"Central" } },
						{ { "终有一天，\n你会落得刚刚被你抛弃的特工的一样的下场。\n你最好希望这一天不会很快到来.",
							"moremissions/VoiceOver/Central/distresscall/judge/agent_fail2",
							"Central" } },
						{ { "这笔帐将永远算在你头上.",
							"moremissions/VoiceOver/Central/distresscall/judge/agent_fail3",
							"Central" } }
					},
					GOT_OTHER = {
						{ { "撤离成功。\n现在我们可以知道他为谁工作，\n以及他对雇主来说值多少钱了.",
							"moremissions/VoiceOver/Central/distresscall/judge/prisoner_out1",
							"Central" } },
						{ { "这位神秘特工总算是救出来了。\n如果运气好的话，\n我们可以通过谈判获得一笔营救奖金.",
							"moremissions/VoiceOver/Central/distresscall/judge/prisoner_out2",
							"Central" } },
						{ { "真可惜他不是我们的人，\n但我们会继续找的。\n干得好，行动官.",
							"moremissions/VoiceOver/Central/distresscall/judge/prisoner_out3",
							"Central" } },
					},
					LOST_OTHER = {
						{ { "又浪费了一个机会。\n你最好加把劲，行动官。\n你该庆幸你抛弃的不是我们自己人.",
							"moremissions/VoiceOver/Central/distresscall/judge/prisoner_fail1",
							"Central" } },
						{ { "我们最终白跑一趟.\n等会在任务汇报时你最好跟我好好解释一下.",
							"moremissions/VoiceOver/Central/distresscall/judge/prisoner_fail2",
							"Central" } },
						{ { "徒劳无功的行动。\n那个行动官本可以以某种方式为我们所用的。\n但现在为时已晚.",
							"moremissions/VoiceOver/Central/distresscall/judge/prisoner_fail3",
							"Central" } },
					},
				},
			},

			WEAPONS_EXPO = {
				FOUND_EXPO = { { { "别急，行动官。\n我们的扫描显示，\n这个房间有先进的安全保险装置.",
					"moremissions/VoiceOver/Central/techexpo/sighted/room_first_1p",
					"Central" } },
					{ { "只要有一个展品被完全破解，\n系统就会自动增加其它展品的防火墙。\n看看能否找到禁用它的方法.",
						"moremissions/VoiceOver/Central/techexpo/sighted/room_first_2p",
						"Central" } } },
				FOUND_EXPO_DISABLED_SEC = { { { "这就是展品。\n他们的安全保险装置现在应该离线了，\n开始工作吧.",
					"moremissions/VoiceOver/Central/techexpo/sighted/room_last",
					"Central" } } },
				SAW_SWITCH = { { { "这个控制器控制着保护展品的失效开关。\n找到另一个控制器，然后同时激活它们.",
					"moremissions/VoiceOver/Central/techexpo/sighted/switch",
					"Central" } } },
				DISABLED_SWITCH = { { { "你已经关闭了防火墙的失效开关，\n但不要放松警惕。\n可能仍然存在我们不知道的安全措施.",
					"moremissions/VoiceOver/Central/techexpo/switched",
					"Central" } } },
				LOOTED_CASE_DROIDS_BOOTING = {
					{ { "行动官，精神点。\n那些仿生人原型机正在启动.",
						"moremissions/VoiceOver/Central/techexpo/droid_1p",
						"Central" } },
					{ { "看来博览会还有自己的安保措施。\n赶紧离开那里.",
						"moremissions/VoiceOver/Central/techexpo/droid_2p",
						"Central" } },
				},
				CENTRAL_JUDGEMENT = {
					NO_LOOT = { { { "这简直是浪费时间，行动官。\n如果你连一个简单的展览会劫案都做不好，\n那你还有什么用？",
						"moremissions/VoiceOver/Central/techexpo/judge/none1",
						"Central" } },
						{ { "我本期待你会做的更好，行动官。\n我们失去了以前的火力，\n这样的机会不是每天都有的.",
							"moremissions/VoiceOver/Central/techexpo/judge/none2",
							"Central" } },
						{ { "干得真是好一手呀，行动官。\n我相信，下次当我们的特工\n带着牙签和玩具枪执行任务时，\n你一定会记住这一刻的.",
							"moremissions/VoiceOver/Central/techexpo/judge/none3",
							"Central" } } },
					GOT_PARTIAL = { { { "我相信你做了正确的决定，行动官。\n虽然有点遗憾我们没能全部拿走它们，\n但回报并不总是值得冒险.",
						"moremissions/VoiceOver/Central/techexpo/judge/some1",
						"Central" } },
						{ { "还算可以接受。\n虽然你没有瓜分掉整个武器库，\n但这应该也足够让我们暂时渡过难关.",
							"moremissions/VoiceOver/Central/techexpo/judge/some2",
							"Central" } },
						{ { "这应该能让我们的人在接下来的任务中占得先机。\n但愿敌人不会用你们留下的原型机武装起来.",
							"moremissions/VoiceOver/Central/techexpo/judge/some3",
							"Central" } } },
					GOT_FULL = { { { "我希望你走的时候没忘了把架子上的灰尘擦干净。\n我们可不想让他们的清洁工以为我们漏了任何\n一个地方。\n出色的工作.",
						"moremissions/VoiceOver/Central/techexpo/judge/all1",
						"Central" } },
						{ { "这个任务做的相当成功。\n虽然这不能让我们直接与公司相提并论，\n但至少我们不会再像以前那样惨遭淘汰了.",
							"moremissions/VoiceOver/Central/techexpo/judge/all2",
							"Central" } },
						{ { "干得好，行动官。\n我们不仅扩大了我们的武器库，\n同时也削弱了他们的研究实力.",
							"moremissions/VoiceOver/Central/techexpo/judge/all3",
							"Central" } } },
				},
			},

			MOLE_INSERTION = {
				MOLE_ESCAPED_NOWITNESSES = {
					{ { "线人离开了，\n而她的伪装身份也安全了。\n行动官，把剩下的人撤出来。\n我们已经搞定了。",
						"moremissions/VoiceOver/Central/informant/escape_unseen",
						"Central" } },
				},
				MOLE_ESCAPED_WITNESSES = {
					{ { "线人离开了，\n但她的身份过不了多久就会被发现，\n除非我们保护好他们的伪装。\n记住你的目标，行动官： “没有目击者”.",
						"moremissions/VoiceOver/Central/informant/escape_seen",
						"Central" } },
				},
				MOLE_ESCAPED_TO_JET = {
					{
						{ "你应该把线人带进敌营，\n而不是飞机上。\n但我相信，\n你放弃这次任务是有充分理由的.",
							"moremissions/VoiceOver/Central/informant/escape_abort",
							"Central" },
						{ "我们应该能在附近为她找到个新的目标，\n所以这也不算完全是失败。\n重要的是：没有人受伤.", "moremissions/VoiceOver/Monster/informant/escape_abort_2p", "Monster" },
					},
				},
				MOLE_DIED = {
					{
						{ "宝贵的生命资产就这样浪费了。\n恐怕以后我们只有运气爆棚的时候，\n才能再有这样的机会了.",
							"moremissions/VoiceOver/Central/informant/died1",
							"Central" },
						{ "是的，确实只有“运气爆棚”的时候。\n我想我应该重新考虑要不要向你们\n投入任何\"生命资产\"的立场了.", "moremissions/VoiceOver/Monster/informant/died1_2p", "Monster" },
					},
					{
						{ "任务就这么泡汤了。\n确保小队安全撤离， \n之后让我们会在汇报时详细讨论一下.",
							"moremissions/VoiceOver/Central/informant/died2",
							"Central" },
						{ "泡汤的还有我最喜欢的联络人之一。\n这个所谓的\"讨论\"真的还有必要吗?", "moremissions/VoiceOver/Monster/informant/died2_2p", "Monster" },
					},
					{
						{ "该死，行动官！\n你知道如果有那个线人在，\n我们会有多大优势吗？",
							"moremissions/VoiceOver/Central/informant/died3",
							"Central" },
						{ "我想她的死是我害的。\n毕竟是我让他们联系上你的.", "moremissions/VoiceOver/Monster/informant/died3_2p", "Monster" },
					},
				},
				MOLE_SEEN_INTERJECTION = { --should play dynamically after the first time mole is spotted, no matter who spots them
					{ { "请记住：如果失败了，放弃这项任务并不丢人。\n把我的线人安全送回你的飞机上，\n我们还可以在其他的地方重来一次.", nil, "Monster" } },
				},
				MOLE_SEEN_GENERIC = { -- TODO: 这些 "seen_generic" 行是用于重复发现情况的吗？
					{
						{ "那是更多不需要的眼睛盯着线人。你熟悉隐形的概念，对吗？",
							"moremissions/VoiceOver/Monster/informant/seen_generic1",
							"Monster" },
					},
					{
						{ "请小心，操作员。我们的线人在没有目击者的情况下工作效果最好。",
							"moremissions/VoiceOver/Monster/informant/seen_generic3",
							"Monster" },
					},
				},

				MOLE_SEEN_BY_GUARD = { {
					{ "行动官！除非我们保护好线人的伪装，\n否则她跟死了几乎没有什么区别。\n如果有人在我们离开前看到她，\n那么一定要把这些尾巴清理干净.",
						"moremissions/VoiceOver/Central/informant/seen_1p",
						"Central" },
					{ "And by \"clean up\", she means...",                                                                                          "moremissions/VoiceOver/Monster/informant/seen_2p", "Monster" },
					{ "Not necessarily. If you can find a non-lethal solution, use it. The informant should have some equipment on them for that.", "moremissions/VoiceOver/Central/informant/seen_2p", "Central" },
				},
				},
				MOLE_SEEN_BY_DEVICE = {
					{
						{ "你需要处理线人被发现的任何主机设备。它们的视觉数据流同步到最近的摄像头数据库。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen1_1p",
							"Monster" },
						{ "清理数据库或破坏设备——一颗子弹或一个EMP就能解决问题。我担心他们的技术真的不是最坚固的。现在，如果他们能有一个更可靠的供应商——",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen1_2p",
							"Monster" }, -- TODO: 长行被截断。缺少“可靠的供应商——”
						{ "德里克，现在不是时候。",
							"moremissions/VoiceOver/Central/informant/shush_derek",
							"Central" },
						{ "对，对，当然。继续。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen1_4p",
							"Monster" },
					},

					{
						{
							"记得让线人避开摄像头或无人机的视线。",
							"moremissions/VoiceOver/Monster/informant/seen_generic2",
							"Monster" },
						{ "你需要用EMP干扰设备的视觉芯片，或者彻底摧毁它。我相信你能胜任这项任务。",
							"moremissions/VoiceOver/Monster/informant/seen_drone_2p",
							"Monster" },
						{ "另一种选择是找到一个摄像头数据库并远程清除记录，但这需要时间。请尽量隐秘一些，好吗？毕竟这应该是一次隐秘行动。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen5_2p",
							"Monster" }, -- 重用 seen5 的这行，因为这个序列没有提到数据库选项。 -- TODO: 长行被截断。缺少“隐秘行动，毕竟”
					},
					{
						{ "这层楼上所有无人机和摄像头的视觉数据流都同步到一个摄像头数据库。让你的人靠近它，你应该可以逐一清除它们的记忆芯片。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen2_1p",
							"Monster" }, -- TODO: 长行被截断。缺少“逐一”
						{ "或者……如果你喜欢的话，可以通过更物理的手段来干扰它们。与格莱斯顿不同，我对我的盟友没有那么严加管控。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen2_2p",
							"Monster" },
					},
					{
						{ "小心点。那个主框架设备刚刚暴露了我们可爱的线人的身份。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen3_1p",
							"Monster" },
						{ "附近应该有一个摄像头数据库。找到它，你的问题会比用蛮力解决得更有效。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen3_2p",
							"Monster" },
						{ "或者……如果你喜欢的话，可以通过更物理的手段来干扰它们。与格莱斯顿不同，我对我的盟友没有那么严加管控。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen2_2p",
							"Monster" }, -- 重用 seen2 的这行，因为 seen3 没有提到直接选项。而且有更多机会嘲讽格莱斯顿。
					},
					{
						{ "请尽量不要让线人被任何带摄像头的东西发现，好吗？这些数据流相当难以清除，你需要实际访问附近的摄像头数据库。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen4_1p",
							"Monster" },
						{ "否则，你可以用EMP干扰主框架设备，或者彻底摧毁它。我相信你能胜任这项任务。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen4_2p",
							"Monster" },
					},
					{
						{ "既然你让线人被发现了，有两种方法可以处理。摧毁或EMP干扰相关设备，它将足够干扰视觉芯片以清除面部识别记录。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen5_1p",
							"Monster" }, -- TODO: 长行被截断。缺少“识别记录”
						{ "另一种选择是找到一个摄像头数据库并远程清除记录，但这需要时间。请尽量隐秘一些，好吗？毕竟这应该是一次隐秘行动。",
							"moremissions/VoiceOver/Monster/informant/witness_mainframe/seen5_2p",
							"Monster" }, -- TODO: 长行被截断。缺少“隐秘行动，毕竟”
					},
				},
				SEE_CAMERADB = { {
					{ "那里有一个摄像头数据库。现在要小心了——你可以用它来逐一清除任何摄像头和无人机的目击记录，但这是一个非常侵入的过程。我毫不怀疑他们会有应对措施。",
						"moremissions/VoiceOver/Monster/informant/sighted/camera_database1",
						"Monster" }, -- TODO: 长行被截断。缺少“应对措施”
				},
					{
						{ "一个摄像头数据库。记住这一点，如果我们的线人被任何讨厌的摄像头或无人机发现，这可能会派上用场。",
							"moremissions/VoiceOver/Monster/informant/sighted/camera_database2",
							"Monster" },
					},
				},
				CAMERADB_PROGRESS = {
					{
						{ "啊，搞定了。你每清除一个设备，它就会重启一个随机设备。这就是为什么谨慎是勇气的一部分，你知道的。",
							"moremissions/VoiceOver/Monster/informant/rebooting1",
							"Monster" },
					},
					{
						{ "你触发了一个主框架协议，只要你连接到摄像头数据流，它就会重启网络的一部分。<叹气> 我知道会发生这种情况。让我们尽量缩短这次入侵时间，好吗？",
							"moremissions/VoiceOver/Monster/informant/rebooting2",
							"Monster" }, -- TODO: 长行被截断。缺少“好吗”
					},
				},
				SEE_OBJECTIVE_DOOR = {
					{ { "注意，行动官。\n我们找对地方了。\n人事数据库应该就在那扇门后面.",
						"moremissions/VoiceOver/Central/informant/sighted/room",
						"Central" } },
				},
				SEE_OBJECTIVE_DB = {
					{ { "这就是人事数据库。\n线人可以用它来伪造身份，\n然后再潜入设施深处。\n确保它顺利进行.",
						"moremissions/VoiceOver/Central/informant/sighted/console",
						"Central" } },
				},
				FINISHED_DB_HACK = {
					{ { "骇入已经完成，\n但线人在断开连接时被标记了。\n他们的位置会在每一级警报等级提升时，\n吸引附近的安保人员调查.",
						"moremissions/VoiceOver/Central/informant/hacked_1p",
						"Central" } },
					{ { "把她带到警卫电梯，\n让她从警卫电梯离开这层楼，别让人看见。\n我们的工作已经接近尾声了.",
						"moremissions/VoiceOver/Central/informant/hacked_2p",
						"Central" } },
				},
				CAMERA_BOOTING = {
					{ { "他们启动了备用摄像头来调查我们的入侵行为。\n别让线人被它看到，\n否则我们会有更多不必要的麻烦要处理.",
						"moremissions/VoiceOver/Central/informant/camera",
						"Central" } },
				},
				SEE_GUARD_EXIT = {
					{ { "这就是警卫出口了。\n小心点，行动官 -- \n确保线人不会撞到电梯中任何增援部队的枪口上.",
						"moremissions/VoiceOver/Central/informant/sighted/exit",
						"Central" } },
				},
				WITNESS_FLED_LEVEL = {
					{ { "马的！线人的一个目击者刚刚从这层楼逃走了！\n我们现在无法处理掉他们了，\n而我们线人的脸也被记住了.", nil, "Central" } },
					{ { "如果你还留下了其他目击证人，\n那就不用再费心处理了。\n现在赶紧集中精力逃出去 -- \n希望我们的线人在引火上身前至少能给我们点线索.", nil, "Central" } },
				},
				WITNESS_FLED_LEVEL_RETRY = {
					{ { "马的！线人的一个目击者刚刚从这层楼逃走了！\n我们现在无法处理掉他们了.", nil, "Central" } },
					{ { "我们可以放弃这次任务，正常撤离线人，然后\n去其他地方再来一次。\n或者在已经知道卧底的身份很快就会暴露的情况下，\n强行把线人送进去。\n看你怎么选了，行动官.", nil, "Central", } },
				},
				CENTRAL_JUDGEMENT = {
					MOLE_JET_ESCAPE = {
						-- {{"We cannot afford to keep wasting our time like this, Operator. Luckily, we may just have a second shot at this. Make it count.", nil,"Central"}},
						{ { "我们的情况并不比开始时好多少。\n这附近应该还有一个类似的渗透目标， \n但是别逼我给你第三次机会，行动官.",
							"moremissions/VoiceOver/Central/informant/judge/abort2",
							"Central" } },
					},
					MOLE_DIED = {
						{ { "真是浪费机会。 \n我们本来就已经没什么朋友了，行动官。\n这本可以是脱离困境所迈出的一大步的.",
							"moremissions/VoiceOver/Central/informant/judge/fail1",
							"Central" } },
						{ { "你的任务是把线人带进去， \n而不是害死他们！ \n看到一个优秀的人员就这样倒下，\n真是太（脏话）的可惜了.",
							"moremissions/VoiceOver/Central/informant/judge/fail2",
							"Central" } },
						{ { "真是完全令我失望。 \n我们需要公司内部的人，行动官。 \n这些公司的情报对我们生存下去非常宝贵.",
							"moremissions/VoiceOver/Central/informant/judge/fail3",
							"Central" } },
						{ { "不要让这样的失败成为一种常态，行动官。\n这绝不对你有利.",
							"moremissions/VoiceOver/Central/informant/judge/fail4",
							"Central" } },
					},
					WIN_WITH_WITNESSES = {
						{ { "你不应该留下目击者的。 \n恐怕在她在向我们提供情报后没多久，\n线人的身份就要彻底暴露了。 \n不过，有总比没有强.",
							"moremissions/VoiceOver/Central/informant/judge/seen1",
							"Central" } },
						-- {{"Next time, make sure the informant is unseen. They'll be useful to us for that much longer if their cover is secure.",nil,"Central"}},
						{ { "任务只能说完成了一半。 \n她的情报我们用不了多久，\n因为你留下的那些目击者很快就会注意到她。 \n下次小心点.",
							"moremissions/VoiceOver/Central/informant/judge/seen2",
							"Central" } },
					},
					WIN_NO_WITNESSES = {
						{ { "在正确的地方，线人的价值不亚于等重的黄金。\n而你确保了他们没有被发现。\n干得好，行动官.",
							"moremissions/VoiceOver/Central/informant/judge/good1",
							"Central" } },
						{ { "我们现在就能提前得到下几次渗透目标的情报了。 \n虽然这只是我们以前工作的一个缩影， \n但任何情报在这危急时刻都非常宝贵。\n干得漂亮.",
							"moremissions/VoiceOver/Central/informant/judge/good2",
							"Central" } },
						{ { "\"观之非易...行且克难。\"\n这真是项艰巨的任务，而你完成得很好 -- \n线人撤离了，你也确保了没有任何目击者。\n干得好.",
							"moremissions/VoiceOver/Central/informant/judge/good3",
							"Central" } },
					},

				},
			},

			AI_TERMINAL = {
				CENTRAL_DOOR_SPOTTED = {
					{ { "扫描显示,那扇门的安保措施异常严密。 \n这一定是我们一直在寻找的 AI 终端了.",
						"moremissions/VoiceOver/Central/aiterminal/sighted/door_1p",
						"Central" } },
					{ { "你需要激活这四扇门，\n才能解锁后面的那个终端。\n你应该能在附近找到解锁措施。\n四处看看。",
						"moremissions/VoiceOver/Central/aiterminal/sighted/door_2p",
						"Central" } },
				},
				CENTRAL_UNLOCKED_SUBDOOR =
				{
					{ { "那个控制台刚刚向设施的另一部分\n发送了信号。\n其中一扇之前上锁的门现在\n应该已经打开了.",
						"moremissions/VoiceOver/Central/aiterminal/console",
						"Central" } },
				},

				CENTRAL_UNLOCKED_MAINDOOR_OMNI_UNSEEN =
				{
					{
						{ "那是主要的AI开发终端。终于。让我们访问数据，看看有没有对Incognita有价值的东西。",
							"moremissions/VoiceOver/Central/aiterminal/sighted/main_1p",
							"Central" },
						{ "这里有些奇怪的事情发生。这研究站点的设备和我以前见过的任何设备都不同。绝对不是这家公司的。",
							"moremissions/VoiceOver/Monster/aiterminal/sighted/main_2p_preomni",
							"Monster" },
						{ "这是以后需要解开的谜团。现在，我们需要完成任务并离开这里。",
							"moremissions/VoiceOver/Central/aiterminal/sighted/main_2p_preomni",
							"Central" },
					},
				},

				CENTRAL_UNLOCKED_MAINDOOR_OMNI_SEEN =
				{
					{
						{ "那是主要的AI开发终端。终于。让我们访问数据，看看有没有对Incognita有价值的东西。",
							"moremissions/VoiceOver/Central/aiterminal/sighted/main_1p",
							"Central" },
						{ "这一定是Omni公司的一个秘密研究站点——只有他们有如此先进的技术。装饰也是一个明显的线索。",
							"moremissions/VoiceOver/Monster/aiterminal/sighted/main_2p_postomni",
							"Monster" },
						{ "全球一定有数百个这样的设施。我们以前怎么从未遇到过一个呢？",
							"moremissions/VoiceOver/Central/aiterminal/sighted/main_2p_postomni",
							"Central" },
						{ "我承认我有我的怀疑，尽管你可能不愿意听到这些......",
							"moremissions/VoiceOver/Monster/aiterminal/sighted/main_4p_postomni",
							"Monster" },
					},
				},

				INCOGNITA_DATA_ACQUIRED = {
					{ { "新数据已获取。\n极有可能提高例行程序的执行效率。\n处理中... 预计所需时间\n为 1 小时 21 分 48 秒.", nil, "Incognita" } },
					{ { "整合新输入矩阵中...\n预计处理时间为 78 分钟。\n在我完成前最好别死在这里.", nil, "Incognita" } },
					{ { "解锁额外的计算处理单元。\n机构存活的可能性提高了 2%。\n在数据完全整合请耐心等待.\n(但别真\"耐心等待\"了，完成任务了就赶紧撤)", nil, "Incognita" } },
					-- {{"Excelent job, Operator. Incognita will be able to install one additional program after we're finished here.",nil,"Central"}},
				},

				INCOGNITA_PROG_UPGRADED = {
					{ { "获得计算升级。\n为升级后的程序线程分配更多处理能力。\n处理中... \n整合完成.", nil, "Incognita" } },
					{ { "多线程协议已解锁，\n可执行参数成功增强。\n您的成功将使我们双方都受益匪浅，行动官.", nil, "Incognita" } },
				},
				INCOGNITA_HOSTILE_AI_WEAKENED = {
					{ { "启动破坏程序。\n但在达到有效的干扰阈值之前，\n预计会需要不少的时间.", nil, "Incognita" } },
					{ { "运行反情报数据矩阵分析。\n插入自我维持的数据破坏蠕虫。\n等待阶段激活。\n种子已经开始生长.", nil, "Incognita" } },
				},

				INCOGNITA_TECH_ACQUIRED = { --unused?
					{ { "Excelent job, Operator. Monst3r will certainly be interested in selling this data. Get it back to the jet.", nil, "Central" } },
					{ { "Quite so, I already have half a dozen buyers in mind for something like this. We should do this more often.", nil, "Monster" } },
				},

				SMOKE_WARNING = { {
					{ "我们触发了一个保险装置。房间正在迅速充满昏迷气体。立刻让你的特工离开那里。",
						"moremissions/VoiceOver/Central/aiterminal/gas",
						"Central" },
					{ "情况可能更糟。至少他们没有用致命的神经毒剂淹没研究中心。",
						"moremissions/VoiceOver/Monster/aiterminal/gas",
						"Monster" },
				}, },


				CENTRAL_JUDGEMENT = {
					GOT_SUCCESS = {
						{ { "干得好，行动官。\nIncognita升级得越强大，\n我们生存下去的机会也就越大.",
							"moremissions/VoiceOver/Central/aiterminal/judge/upgrade1",
							"Central" } },
						{ { "这是一次胜利，行动官。\nIncognita是我们在这场混乱中活下来的王牌和底牌。\n我们为她升级的东西越多，\n我们的处境就会越好.",
							"moremissions/VoiceOver/Central/aiterminal/judge/upgrade2",
							"Central" } }, -- obligatory portal ref
						{ { "干得好，行动官。\nIncognita升级得越强大，\n我们生存下去的机会也就越大.",
							"moremissions/VoiceOver/Central/aiterminal/judge/upgrade1",
							"Central" } },
						{ { "这是一次胜利，行动官。\nIncognita是我们在这场混乱中活下来的王牌和底牌。\n我们为她升级的东西越多，\n我们的处境就会越好.",
							"moremissions/VoiceOver/Central/aiterminal/judge/upgrade2",
							"Central" } }, -- obligatory portal ref
						-- again, lazy copy-pasting to keep cookie line rare
						{ { "Incognita似乎对她的新升级非常满意。\n吃块曲奇吧，行动官。\n这是你应得的.",
							"moremissions/VoiceOver/Central/aiterminal/judge/upgrade3",
							"Central" } },
					},
					GOT_NOTHING = {
						{ { "我应该把你留在孤儿院的.",
							"moremissions/VoiceOver/Central/aiterminal/judge/fail3",
							"Central" } },
						{ { "我们曾有一个难得的机会在这里升级\nIncognita，而你却浪费了它。\n多么令人失望.",
							"moremissions/VoiceOver/Central/aiterminal/judge/fail1",
							"Central" } },
						{ { "行动官，\nIncognita 是我们对集团仍有的一个优势。\n我们不能再浪费这样的机会了。\n下次要牢记这一点.",
							"moremissions/VoiceOver/Central/aiterminal/judge/fail2",
							"Central" } },
						--copypasting: lazy way of making the orphanage line a rarer easter egg
						{ { "我们曾有一个难得的机会在这里升级\nIncognita，而你却浪费了它。\n多么令人失望.",
							"moremissions/VoiceOver/Central/aiterminal/judge/fail1",
							"Central" } },
						{ { "行动官，\nIncognita 是我们对集团仍有的一个优势。\n我们不能再浪费这样的机会了。\n下次要牢记这一点.",
							"moremissions/VoiceOver/Central/aiterminal/judge/fail2",
							"Central" } },
					},
					WEAKENED_COUNTER_AI = {
						{ { "俗话说，进攻是最好的防守。\n搞破坏也许是一种肮脏的游戏，\n但阻碍他们的人工智能研究\n一定能帮助我们保持竞争力。\n干得漂亮.",
							"moremissions/VoiceOver/Central/aiterminal/judge/sabotage",
							"Central" } },
					},
				},
			},

			MM_SIDEMISSIONS = {
				STEAL_STORAGE = {
					STORAGE_SPOTTED_1 = {
						{ "操作员，我们的遥测数据表明在设施内还有两个类似的房间。如果我们有时间，不顺便拜访一下这些贵重物品就太可惜了。",
							nil,
							"Central" }, -- TODO: 长行被截断。缺少“拜访一下”
						{ "尽量不要弄坏它们。我的客户对他们的货物有非常严格的要求。",
							"moremissions/VoiceOver/Monster/briefcases/sighted1_p2",
							"Monster" },
					},
					STORAGE_SPOTTED_2 = {
						{ "你找到了第二个储藏室。开始工作吧。",
							nil,
							"Central" },
						{ "记住：你偷得越多，我就越会让你觉得值得。",
							"moremissions/VoiceOver/Monster/briefcases/sighted2_p2",
							"Monster" },
						{ "我们不是你的送货服务。操作员，只带我们团队能安全带出的东西。",
							nil,
							"Central" }
					},
					STORAGE_SPOTTED_3 = {
						{ "在那里！最后一个房间。把所有东西带回来，我保证你会赚大钱。也许你可以做两次旅行——",
							"moremissions/VoiceOver/Monster/briefcases/sighted3_p1",
							"Monster" },
						{ "这已经够了。选择权在你手中，操作员。确保我们不会后悔这个决定。",
							nil,
							"Central" },
					},
					CENTRAL_LOCKER_ROBBED = {
						{ "小心，操作员。你拿走那些装备时，储物柜的内部传感器触发了一个守护程序。也许他们的安全措施不像我们想的那么差劲。",
							nil,
							"Central" },
					},
				},

				PERSONNEL_HIJACK = {
					SPOTTED_BOSS = {
						{ "有趣。那个守卫的面部识别……Monst3r，你认得他吗？",
							nil,
							"Central" },
						{ "天哪。这真是提醒了我那些糟糕的旧时光，不是吗？",
							"moremissions/VoiceOver/Monster/personnel/sighted_p2",
							"Monster" },
						{ "确实有一段时间了。操作员，我非常想在飞机上和他聊聊。确保做到。",
							nil,
							"Central" },
					},
					KO_BOSS = {
						{ "很好。现在把他带回飞机上。记住：我们审问他时要活着。",
							nil,
							"Central" },
					},
					BOSS_KILLED = {
						{ "你没听到我说我们需要他活着吗？不过，至少他终于得到了应有的报应。继续任务吧。",
							nil,
							"Central" },
					},
					BOSS_TAKEN = {
						{ "干得好，操作员。我会看看能不能从他那里得到一些情报，问问他老公司最近怎么样。",
							nil,
							"Central" },
					},
				},

				LUXURY_NANOFAB = {
					LOOTED_KEY = {
						{ "操作员，你的特工刚刚获取了一种特殊的访问钥匙。留意匹配的纳米制造设备——我们可能有机会了。",
							nil,
							"Central" },
					},
					LOOTED_KEY_SAWNANOFAB = {
						{ "你刚刚偷的那张卡一定是我们一直在找的那张。回到那个纳米制造设备那里看看有什么可买的。",
							nil,
							"Central" },
					},
					SAW_NANOFAB = {
						{ "啊，现在这有趣了。这款纳米制造设备专门用于一种特定类型的装备，但每次使用后都需要进行长时间的重新校准。你最好仔细选择。",
							"moremissions/VoiceOver/Monster/luxury_nanofab/sighted_1p",
							"Monster" }, -- TODO: 长行被截断。缺少“仔细选择”
						{ "看看后面的房间——那里应该有一个召唤技术支持的控制台，他们肯定有访问权限。",
							"moremissions/VoiceOver/Monster/luxury_nanofab/sighted_2p",
							"Monster" },
					},
					SAW_NANOFAB_HAVE_KEY = {
						{ "啊，现在这有趣了。这款纳米制造设备专门用于一种特定类型的装备，但每次使用后都需要进行长时间的重新校准。你最好仔细选择。",
							"moremissions/VoiceOver/Monster/luxury_nanofab/sighted_1p",
							"Monster" }, -- TODO: 长行被截断。缺少“仔细选择”
						{ "现在，我相信你已经有钥匙了？不是吗？",
							"moremissions/VoiceOver/Monster/luxury_nanofab/haskey",
							"Monster" },
					},
					SAW_CONSOLE = {
						{ "操作员，看看：那个控制台是指定的纳米制造设备技术支持。这应该能召唤持有钥匙的人，只要他们还清醒。我们给IT部门打个电话，好吗？",
							nil,
							"Central" },
					},
					SAW_CONSOLE_HAVE_KEY = {
						{ "操作员，看看：那个控制台是指定的纳米制造设备技术支持。我们已经有钥匙了，但在紧急情况下，这仍然可能是一个有用的分散注意力的方法。",
							nil,
							"Central" },
					},
					SUMMONED_GUARD = {
						{ "搞定了。注意任何直奔这个房间的守卫，我们很快就会有钥匙了。",
							nil,
							"Central" },
					},
					SUMMONED_GUARD_KO = {
						{ "IT部门没有回应。我们知道他们今天在值班——也许你应该再检查一下你已经放倒的守卫的口袋。",
							nil,
							"Central" },
					},
					UNLOCKED_NANOFAB = {
						{ "干得好，你已经解锁了纳米制造设备。这款设备在打印一件物品后会关闭以进行重新校准，所以要慎重选择，操作员。",
							nil,
							"Central" },
						{ "啊，时间压力下的购物。幸好不是我。",
							"moremissions/VoiceOver/Monster/luxury_nanofab/unlocked_2p",
							"Monster" },
					},
					BOUGHT_ITEM = {
						{ "精准购物能起到很大的作用。希望这个小插曲能证明自己值得麻烦。",
							nil,
							"Central" },
					},
					TODO_1 = { -- TODO: 关联/移动这些台词
					}
				},

				WORKSHOP =
				{
					SEE_CONSOLE =
					{
						{ "啊，现在这有趣了。小道消息告诉我这里可能有一个装备增强工作台……看看那个控制台，通过重型电路连接起来。这层楼的某个地方一定有一个非常耗电的设备。",
							"moremissions/VoiceOver/Monster/workshop/console_1p",
							"Monster" }, -- 长行被截断。最后一个词“非常”
						{ "如果你有多余的电力，试着把它从这些控制台重新路由到工作台。一个最先进的升级工作台？天哪，我愿意立刻和你换位置。",
							"moremissions/VoiceOver/Monster/workshop/console_2p",
							"Monster" },
					},

					SEE_WORKSHOP =
					{
						{ "那里是工作台！真是美丽，不是吗？现在，升级所需的电量与你的技术复杂性成正比，所以如果你对那些控制台吝啬，就不要指望奇迹。哼，我想我应该退后一步，让你慢慢熟悉。享受吧……",
							"moremissions/VoiceOver/Monster/workshop/workshop",
							"Monster" }, -- 长行被截断。最后一个词“吝啬”
					},
					SEE_WORKSHOP_NO_PWR = -- TODO: 使用这行
					{
						{ "那里是工作台！你知道它使用最先进的激光烧蚀和3D打印技术吗？想象一下可能性！当然是假设的——你没有重新路由任何电力，所以最多只能启动它，欣赏一下启动屏幕。哦，好吧，也许下次吧……",
							"moremissions/VoiceOver/Monster/workshop/workshop_unpowered",
							"Monster" }, -- 长行被截断。最后一个词“没有重新路由”
					},

					ITEM_MODIFIED =
					{
						{ "工作台3的占位符文本", nil, "Central" },
					},
				},
			},
		},
	},


	LOGS = {
		-- Informant datalog: doubles as acknowledgemt for VA contributors
		log_informant_filename = "INFORMANT INTEL", --author: Hek
		log_informant_title = "UNDERCOVER AGENT REPORT",
		log_informant = [[INFORMANT COMMUNIQUÉ - NATALIE FORMAUNT
			标题：《来自线人的报告》
			[解密完成]
			
			<c:9d7faa>行动官，我记得你很喜欢先谈生意后谈情，所以我就开门见山了。我已经确定了
			MesMerize 项目的主要资金来源（见附件）。有些是名字，有些是别名。
			一旦我们弄清了这些人之间的联系，我们就会有更多关于这个项目的数据。

			我有一种直觉，你是对的。这些联系人来自全球各地，在每个公司都有很深的根
			基。我目前所做的调查似乎与你的集团理论相符合，但全部细节要等到我的下一
			份报告。如果查证属实，这将改变我们对集团运作的认知。

			在我引火上身之前，我应该还能从这个身份中挤出至少两天的时间。按照惯例：
			如果你没有再收到我的来信，很高兴与你合作。

			xoxo(爱你的),
			
			"Natalie"</>

			[附件]
			
			--------------------
			<c:62B3B3>Cyberboy2000
			jlaub
			TornadoFive
			Zorlock Darksoul
			Dwarlen
			amalloy
			Datsdabeat
			Mobbstar
			Waldenburger
			alpacalypse
			magnificentophat
			Zaman
			Alexander S.
			Datapuncher
			Jeysie
			Linenpixel
			WMGreywind
			Puppetsquid
			qoala
			kalec.gos
			Erpy
			Andrew Kay
			woaini7755888(汉化)
			ralf(汉化)</>
			--------------------

			(衷心感谢所有为 "More Missions" MOD 配音工作捐款的人，
			同样衷心感谢Veena Sood 和 Benjamin Hawkins 为台词配音!
			
			- The More Missions 开发团队)
		]],
		log_techexpo_filename = "LETTER OF INVITATION", --author: jlaub
		log_techexpo_title = "MWC LETTER OF INVITATION",
		log_techexpo =
		[[INVITATION, 2074 MEGACORP WARE CONGRESS (MWC)
		标题：《2074年集团科技展览大会的邀请函》
		<c:62B3B3>尊敬的 Richardson 先生,

		恭喜！根据您的申请以及与FTM和K&O集团的长期合作关系，您已被选为我们在
 		2074 年科技展览大会（MWC）上的嘉宾。这独一无二的年度盛会将展示我们
 		的合作伙伴及其子公司所能提供的最先进技术--或者说，我们常说的"集团皇冠上
 		的明珠"。有关活动的具体信息请查看详情。在博览会临近时，我们将与您联系，以
 		提供更多详细信息。</>

		<c:db65ba>关于 MWC</> - <c:eca35b>“明年的技术，就在今天！”</>

		<c:62B3B3>在 9 月下旬的两天时间里，来自全球各地的开拓型科学家、高级管理人员、重要
		股东、顶级开发人员、下游供应商和值得信赖的市场顾问（如您本人）将汇聚一堂，
		一睹未来的风采。 在R&D集团研发设施旁的展厅里，集团的精英们将分享他们在
		致命和非致命武器、网络接口系统以及人体增强和强化技术方面的最新成果。根据
		现行条约，各种原型均可供近距离观察、进行功能演示和特定地区的预购。

		2061 年，由 FTM 时任首席产品官、现任首席执行官索菲-伍德布里奇
		（Sophie Woodbridge）牵头，在旧金山举办了第一届集团科技展览
		大会，会上展示了勉强但不仅仅是勉强能正常工作的实验性加速芯片、首款无火药随
		身武器、和一种可应用在植入体上，但可行性未知的低摩擦凝胶。毫无疑问，大家都
		知道，当 2065 年第一台功能扫描放大器惊艳亮相时，该博览会很快在公司的
		上层社会声名鹊起。从那之后，它很快扩展到了 FTM 的产品线以外，并涵盖了
		所有巨型企业及其子公司的突破性应用科学和工业设计，以及思想领导力和独家网络
		活动。如今，MWC已成为*无与伦比*的年度全球技术博览会。</>


		<c:db65ba>地点与会场</>

		<c:62B3B3>按照传统，博览会的主办方在各集团之间轮换。但由于 2073 年的安全漏洞，
		2074 年MWC的地点是受严格保护的机密，只有受邀贵宾才能知道。我们仅会
		在展厅即将开放时短暂提供光束坐标。我们最后提醒您，在申请成为嘉宾时，您已经
		接受了有关企业设施位置的标准保密协议。</>



		<c:db65ba>日程安排</>

		<c:eca35b>星期六, 8:00 AM:</> 展厅开放
		<c:eca35b>星期六, 9:00 AM:</> 主题演讲：《扩展防火墙：量子网络安全的未来》
		<c:eca35b>星期六, 12:00 PM:</> 位于 Koi Pond（锦鲤池畔）的午餐招待会
		<c:eca35b>星期六, 1:00 PM 至 5:30 PM:</> 产品功能演示
		<c:eca35b>星期六, 5:30 PM:</> 展厅关闭，交流招待会开始
		<c:eca35b>星期六, 7:00 PM:</> Holovid（全息电影）放映，《伊斯坦布尔四人组（删节版）》（*注）
		<c:eca35b>星期六, 9:00 PM:</> 极速约会环节，"Vali-Dates：限时挑战版"
		<c:eca35b>星期日, 9:00 AM:</> 问答环节, “与 Sophie Woodbridge 的一场面对面交流”
		<c:eca35b>星期日, 12:00 PM:</> "拉面数据库"设施餐厅午餐招待会
		<c:eca35b>星期日, 3:00 PM:</> 小组讨论，题目为《为何如此安全：如何应对反公司威胁》
		<c:eca35b>星期日, 5:30 PM:</> 闭幕式


		真诚的,
		Victor Doubleday
		Director, Marketing Events Operations
		Megacorp Ware Congress

		P.S.: 您在博览会闭幕后的出现将触发警报。我们提前感谢您与安全人员的合作。</>

		(译者注：《伊斯坦布尔四人组》该电影于2070年上映，内容大致为：2057年
		的伊斯坦布尔事件成为资源战争的关键转折点，集团成功对残余的国家形成了压倒性
		优势。然而旧秩序的残党仍然阴魂不散，尤其以泛欧信息安全局（隐形公司的前身）
		为代表，不惜一切手段阻止和平会谈。其试图派出特工在和平会谈上刺杀集团董事
		会，但最终失败被俘，所有特工被直播处决。)
		]],

		log_assassination_filename = "CORPORATE CHATLOG", --author: jlaub
		log_assassination_title = "DECRYPTED CHATLOG",
		log_assassination = [[标题：《VIP与保镖的聊天记录》
		>>> 聊天系统初始化成功
		
		>>> 已确认加密协议
		
		>>> 与会者参加了聊天： Steve Hall，特别项目首席行动官；Sayid Madani，地区安全负责人
		
		>>> 您友好的可互户动聊天机器人将为您提供帮助. 只需输入 <c:6bf7ff>"嘿, Weebo..."</c> 和您的请求。例如， <c:6bf7ff>"嘿 Weebo, 2073 年第二季度部门的季度收益是多少？"</c> 祝您今天愉快！

		<c:63ffca>VIP:</c> <c:62B3B3>你就是Sayid吗?</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>是的Steve我的伙计，你的行政生活怎么样？</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>感觉好多了。你收到我的请求了吗？</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>这很重要。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>你是说那个安保升级请求吗？</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>怎么了？</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>...</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>通过了吗？</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>...好吧，你知道事情没那么简单。“你还没有确凿证据证明你的人身安全会受到威
		胁，以及风险来自谁。”标准的拒绝理由。</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>我手里有*你*的团队在子网中的聊天记录。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>聊天就是聊天，它可能什么都不是。恐怖分子在玩心理游戏，想让我们把自己搞
		得身烦瘦神烦。比如说，根据子网的谣言，花一大笔钱购买安全设备。</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>我不知道。你听说了最近的高楼行政终端被袭击的事吗？Gavin（另一个执行官）
		的所有联络地点的数据都被盗了。肯定有什么大事要发生。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>我当然听说了。</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>然后呢？</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>呃，然后怎么了</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>真的要我一个字一个字说出来吗？？？现在随时可能就有一颗正在瞄着我的子弹
		射出来！</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>我们当然无法确定这一点。</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>"当然"？
		我的天呐。这几乎就像是在说你现在*非常想*害死我一样。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>当然不是！我只是在做我的工作。这不是针对你个人。</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>是的没错，自从我升职而你没升职后，你就一直对我很不爽，现在终于打算把我
		晾在一边了是吧？？？我要举报你。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>你真是太多疑了 -- 我绝不会那么做。这不仅仅是因为保护你的安全是我TM的工作，还有一个原因是，
		我和你一样也必须对*每一笔*开支负责。如果我们安装了那么多额外的安保技术，
		却什么都没发生，财务部门绝对会把我叼吊飞的。</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>“什么都没发生”不就是重点吗？？？</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>你明白我的意思。</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>我不明白。我在这里没有任何安全感。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>其实大家都没有。但是相信我，在每个房间的角落里都安装了炮塔的情况下，你
		需要的"安全感"比你想象的要少得多。</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>我们能执行那个请求吗？？？</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>不行。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>我们甚至还没有完成安网评估。它可能什么都不是。可能是安保排班不满，也可
		能是某个白痴吃临时工忘记锁屏幕。你想因为这个把你的套间变成诺克斯堡（注：著
		注名美国军事基地）吗？</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>几项安全升级并不算是'诺克斯堡'，而且大部分都是我们已经在使用的标准安全
		措施。我只是想要更多。在我的办公室里。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>你到底看过自己的需求清单没？"两架装有追踪弹药的'豪鬼'无人机"？带激光网
		格防护的安全屋？压力板？绊半线？这些有一半都是实验性技术，对你和你的同事造成
		的危害甚至比子网的那些所谓"聊天记录"更严重。更不用说把你的真皮沙发弄得凹
		凸凸不平了。</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>哈哈。太有趣了。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>看，我知道你很担心。但你得承认，这可能只是新工作带来的压力。你不是第一
		个发现自己有恐高症的主管。也许你应该用一用你的带薪休假，在游艇挺上度过一
		天，试着放松一下。顺便别再看间谍小说了，好吗？</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>我没有恐高症。我每年都参加翼E装飞行比赛。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>我只是在比喻。 </c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>Sayid，伙计。我们是老相识了，对吧？只要你帮我这个忙，我就会还你一个大
		人情。这对你来说可是个大好机会。你知道的，像你这样的人，不可能对这样的
		机会挑三拣减四。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>唉...</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>嗯，我有必要提醒你一下，我对我的工作非常认真，我绝不会参与任何涉及滥用
		公司资金的人情交易计划，尤其是在公司的聊天系统上。</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>我会让你觉得值得的。我们可以稍后再担心向管理层解释的问题，如果我还活着
		的话。</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>我真的不能 -- </c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>唉，听着...如果你真的那么担心的话，我看看能不能给你弄把防身武器，好吗？
		不过再多的话，你就得自己掏逃腰包了。你可以把它作为设施升级向上级申伸请，也
		许他们会给你报销部分费用。我相信你会想出办法的 -- 以你的身份和地位。</c>
		
		<c:63ffca>VIP:</c> <c:62B3B3>我不是那个意思 --</c>
		
		<c:ff9677>保镖:</c> <c:62B3B3>我要离开了，好吗？Ttyl，下次见，记得替我向Katie问好。</c>

		>>> Sayid Madani 已离开聊天室。
		
		<c:63ffca>VIP:</c> <c:62B3B3>去你**的朋友。S.B东西</c>
		
		<c:63ffca>VIP:</c> <c:6bf7ff>嘿，Weebo</c>, <c:62B3B3>请订购所附文件"安全升级.doc"中列出的项目，但不包括三角重工的进口产品，
		并将其作为加急订单，费用从我的个人账户里扣。</c>

		<c:6bf7ff>WEEBO:</c> <c:62B3B3>下单中...</c>
		
		<c:6bf7ff>WEEBO:</c> <c:62B3B3>已完成。安装详情已发送至您的钱包和日历。感谢您使用 Weebo 购物！</c>
		
		>>> Steve Hall 已离开聊天室.
		
		>>> 聊天结束并成功存档

		（译者注：最后VIP订购了一整套安全屋、至少两个激光网格、压力板、绊半线，以
		及最先进的特种型仿生人诱饵？破费了啊，可惜遇上了隐形公司这个怪物，233）
		
		]],
	},
}
