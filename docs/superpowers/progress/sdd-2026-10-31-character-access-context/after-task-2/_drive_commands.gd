extends EraEvent
## 校验用事件：打印、分割线、空行、按钮、等待选择、改角色组件、等任意键。

func run(context: EventContext) -> GDScript:
	var tester := Character.new()
	tester.id = &"test_character"
	tester.add_component(LifeComponent.new())
	Era.state.character_book.add(tester)

	Era.print("第一行")
	Era.print("红字", Era.Style.DANGER)
	Era.print_rule()
	Era.print_gap()
	Era.print_button("甲", 0)
	Era.print_button("乙", 1)

	var picked: int = await Era.input()
	Era.print("选了 %d" % picked)
	var life := tester.get_component(LifeComponent) as LifeComponent
	life.value = 7 if picked == 0 else 8

	await Era.wait_key()
	return null
