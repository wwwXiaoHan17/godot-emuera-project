extends EraEvent
## CharacterPanel, 角色状态面板
##
## 用混合格子把女儿的组件值摆出来（生命/体力/精力/好感/天赋）；
## 按钮直接调用组件方法，打印“现在”后按键重画，能直观看到组件数据变化。
## 面板内部用 while 保留局部变量循环；离开面板时才返回 DayStart。

const DayStartPath := "res://content/events/day_start.gd"


func run(context: EventContext) -> GDScript:
	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
	var daughter := context.character(&"daughter")
	if daughter == null:
		Era.clear()
		Era.print("找不到女儿角色。", Era.Style.DANGER)
		await Era.wait_key()
		return null

	var life := daughter.get_component(LifeComponent) as LifeComponent
	var stamina := daughter.get_component(StaminaComponent) as StaminaComponent
	var energy := daughter.get_component(EnergyComponent) as EnergyComponent
	var relations := daughter.get_component(RelationComponent) as RelationComponent
	var talents := daughter.get_component(TalentListComponent) as TalentListComponent

	while true:
		Era.clear()
		Era.print_rule()
		Era.print("角色状态：%s" % daughter.display_name, Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_rule()

		Era.begin_grid(2)
		Era.print_cell("属性", Era.Style.DIM)
		Era.print_cell("数值", Era.Style.DIM, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_cell("生命")
		Era.print_cell(str(life.value) if life != null else "—", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_cell("体力")
		Era.print_cell(str(stamina.value) if stamina != null else "—", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_cell("精力")
		Era.print_cell(str(energy.value) if energy != null else "—", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_cell("对玩家好感")
		Era.print_cell(str(relations.relation_to(&"player") if relations != null else 0), Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_cell("天赋")
		Era.print_cell(talents.text() if talents != null else "无", Era.Style.NORMAL, HORIZONTAL_ALIGNMENT_CENTER)
		Era.end_grid()

		Era.print_rule()
		Era.print("要改哪个？")
		Era.print_button("生命 -10", 0)
		Era.print_button("体力 -10", 1)
		Era.print_button("精力 -10", 2)
		Era.print_button("好感 +10", 3)
		Era.print_button("返回第 1 天", 4)

		var picked: int = await Era.input()
		if picked == 4:
			return load(DayStartPath) as GDScript
		if picked == 0 and life != null:
			life.hurt(10)
		elif picked == 1 and stamina != null:
			stamina.spend(10)
		elif picked == 2 and energy != null:
			energy.spend(10)
		elif picked == 3 and relations != null:
			relations.add_relation(&"player", 10)

		Era.print("现在：生命 %s　体力 %s　精力 %s　好感 %d" % [
			str(life.value) if life != null else "—",
			str(stamina.value) if stamina != null else "—",
			str(energy.value) if energy != null else "—",
			relations.relation_to(&"player") if relations != null else 0,
		], Era.Style.ACCENT)
		await Era.wait_key()
		# 按键后回到 while 顶部，保留本次事件的局部变量继续显示


	return null
