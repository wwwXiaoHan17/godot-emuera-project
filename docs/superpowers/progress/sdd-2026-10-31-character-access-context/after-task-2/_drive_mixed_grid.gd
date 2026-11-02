extends EraEvent
## 校验用事件：混合格子（文字格 + 选择项 + 动作项）→ 写回测试角色的组件。

func run(context: EventContext) -> GDScript:
	var tester := Character.new()
	tester.id = &"test_character"
	var life := LifeComponent.new()
	var talents := TalentListComponent.new()
	tester.add_component(life)
	tester.add_component(talents)
	Era.state.character_book.add(tester)

	Era.clear()
	Era.begin_grid(2)
	Era.print_cell("标题甲", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	Era.print_cell("标题乙", Era.Style.DIM, HORIZONTAL_ALIGNMENT_RIGHT)
	Era.print_toggle("选项一", 0, false)
	Era.print_toggle("选项二", 1, false, true)
	Era.print_button("确定", 9000)
	var grid: Variant = Era.end_grid()

	var action: int = await Era.input()
	life.value = action
	var selected: Array[StringName] = []
	for id in grid.get_selected():
		selected.append(StringName(str(id)))
	talents.set_talents(selected)
	return null
