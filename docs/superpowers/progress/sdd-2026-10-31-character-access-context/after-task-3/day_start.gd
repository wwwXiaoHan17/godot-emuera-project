extends EraEvent
## DayStart, 第一天的开头
##
## 数据来自角色组件，不再直接读写 GameState 的扁平字段：
## - 名字/年龄：女儿角色的 display_name / AgeComponent；
## - 体力/精力：女儿的 StaminaComponent / EnergyComponent；
## - 好感：女儿的 RelationComponent；
## - 天赋：女儿的 TalentListComponent。
##
## 动作改组件 → 打印“现在” → 按键后重画本屏（面板显示更新后的数值）。

const Title := preload("res://content/events/type_a_title.gd")
const CharacterPanel := preload("res://content/events/character_panel.gd")
const ShowComponent = preload("uid://cjiyuvnnqpklg")


func run(context: EventContext) -> GDScript:
	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
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

	Era.clear()
	Era.print_rule()
	Era.print("第 1 天", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	Era.print("名字：%s　年龄：%s" % [display_name, age_text])
	Era.print("体力：%d　精力：%d" % [stamina.value, energy.value])
	Era.print("对玩家好感：%d" % (relations.relation_to(&"player") if relations != null else 0))
	Era.print("天赋：%s" % talent_text)
	Era.print_rule()
	Era.print("要做什么？")
	Era.print_button("出去走走", 0)
	Era.print_button("在家休息", 1)
	Era.print_button("查看角色面板", 2)
	Era.print_button("返回标题", 3)
	Era.print_button("查看女儿携带的组件", 4)

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
		_:
			return
