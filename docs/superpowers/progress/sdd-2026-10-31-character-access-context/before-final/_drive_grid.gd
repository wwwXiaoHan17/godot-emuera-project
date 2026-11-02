extends EraEvent
## 校验用事件：建一块格子，等动作项，然后写回测试角色的组件。

func run() -> GDScript:
	var tester := Character.new()
	tester.id = &"test_character"
	var life := LifeComponent.new()
	var talents := TalentListComponent.new()
	tester.add_component(life)
	tester.add_component(talents)
	Era.state.character_book.add(tester)

	Era.clear()
	Era.begin_grid(3)
	Era.print_toggle("可选A", 0, true)
	Era.print_toggle("可选B", 1, false)
	Era.print_toggle("禁用C", 2, false, true)
	Era.print_button("确认", 9000)
	var grid: Variant = Era.end_grid()

	var action: int = await Era.input()
	life.value = action
	var selected: Array[StringName] = []
	for id in grid.get_selected():
		selected.append(StringName(str(id)))
	talents.set_talents(selected)
	return null
