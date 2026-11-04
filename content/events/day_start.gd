extends EraEvent
## DayStart，第 N 天的开头
##
## 状态和菜单用 EraFlet 面板块摆（每个面板自己写坐标/大小/占几行）：
## - 左边面板：天数、名字/年龄、体力/精力、好感、天赋（数据来自女儿角色组件）；
## - 右边面板：操作按钮（点完按引擎规则整块变灰）。
##
## 动作改组件 → 打印“现在” → 按键后重画本屏（面板显示更新后的数值）。
## “看地图”切到 WorldMap 事件（大地图上的数字是地点按钮）。

const Title := preload("res://content/events/type_a_title.gd")
const CharacterPanel := preload("res://content/events/character_panel.gd")
const ShowComponent = preload("res://content/events/show_component.gd")
const WorldMap := preload("res://content/events/world_map.gd")

## 面板布局（像素）；整块占 8 行 = 8 × 26 - 4 = 204px。
const PANEL_HEIGHT := 182
const PANEL_ROWS := 8
const STATUS_X := 0
const STATUS_W := 420
const MENU_X := 435
const MENU_W := 400


func run(context: EventContext) -> GDScript:
	# 角色表由 new_game 统一装配（Era.set_character_book）；这里只取人。
	var daughter := context.character(&"daughter")
	if daughter == null:
		Era.clear()
		Era.print("找不到女儿角色。", Era.Style.DANGER)
		await Era.wait_key()
		return null

	var stamina := daughter.get_component(StaminaComponent) as StaminaComponent
	var energy := daughter.get_component(EnergyComponent) as EnergyComponent
	var age_component := daughter.get_component(AgeComponent) as AgeComponent
	var relations := daughter.get_component(RelationComponent) as RelationComponent
	var talents := daughter.get_component(TalentListComponent) as TalentListComponent
	if stamina == null or energy == null:
		Era.clear()
		Era.print("女儿缺少体力/精力组件。", Era.Style.DANGER)
		await Era.wait_key()
		return null

	var display_name: String = daughter.display_name if daughter.display_name != "" else "（未创建）"
	var age_text: String = str(age_component.value) if age_component != null else "—"
	var talent_text: String = talents.text() if talents != null else "无"
	var relation_text: int = relations.relation_to(&"player") if relations != null else 0

	Era.clear()
	Era.print_rule()
	Era.begin_panels()
	Era.begin_panel(STATUS_X, 0, STATUS_W, PANEL_HEIGHT, PANEL_ROWS)
	# TODO: 目前只读 Era.state.day 显示天数；天数推进机制（过天 +1）由后续引擎能力落地。
	Era.print("第 %d 天" % Era.state.day, Era.Style.ACCENT)
	Era.print("名字：%s　年龄：%s" % [display_name, age_text])
	Era.print("体力：%d　精力：%d" % [stamina.value, energy.value])
	Era.print("对玩家好感：%d" % relation_text)
	Era.print("天赋：%s" % talent_text)
	Era.end_panel()
	Era.begin_panel(MENU_X, 0, MENU_W, PANEL_HEIGHT, PANEL_ROWS)
	Era.print("要做什么？", Era.Style.DIM)
	Era.print_button("出去走走", 0)
	Era.print_button("在家休息", 1)
	Era.print_button("查看角色面板", 2)
	Era.print_button("返回标题", 3)
	Era.print_button("查看女儿携带的组件", 4)
	Era.print_button("看地图", 5)
	Era.end_panel()
	Era.end_panels()
	Era.print_rule()

	match await Era.input():
		0:
			stamina.spend(10)
			energy.spend(5)
			Era.print("你出门走了一圈。体力 -10，精力 -5。", Era.Style.DIM)
			Era.print("现在：体力 %d　精力 %d" % [stamina.value, energy.value], Era.Style.ACCENT)
			await Era.wait_key()
			return get_script() as GDScript
		1:
			stamina.rest(5)
			energy.rest(10)
			Era.print("你在家睡了一觉。体力 +5，精力 +10。", Era.Style.DIM)
			Era.print("现在：体力 %d　精力 %d" % [stamina.value, energy.value], Era.Style.ACCENT)
			await Era.wait_key()
			return get_script() as GDScript
		2:
			return CharacterPanel
		3:
			return Title
		4:
			return ShowComponent
		5:
			return WorldMap
		_:
			return
