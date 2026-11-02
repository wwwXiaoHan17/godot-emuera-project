extends EraEvent
## NewGame, 开始新游戏
##
## 流程：装配角色 → 挂载角色创建页（名字/年龄）→ 写女儿角色 → 等键 → 选天赋。

const CHARACTER_CREATE := preload("res://content/screens/character_create.tscn")
const TalentSelect := preload("res://content/events/talent_select.gd")


func run(context: EventContext) -> GDScript:
	# 先装配角色：页面输入需要女儿已有的名字/年龄。
	Era.set_character_book(CharacterSetup.ensure(Era.state.character_book))
	Era.clear()
	Era.print("先创建你的角色。")
	Era.print_gap()

	var daughter := context.character(&"daughter")
	var age_component := daughter.get_component(AgeComponent) as AgeComponent if daughter != null else null
	var result: Variant = await Era.show_screen(CHARACTER_CREATE, {
		"display_name": daughter.display_name if daughter != null else "",
		"age": age_component.value if age_component != null else 18,
	})
	var data: Dictionary = result as Dictionary
	var display_name := str(data.get("display_name", ""))
	var age := int(data.get("age", 18))

	if daughter != null:
		daughter.display_name = display_name
		if age_component != null:
			age_component.set_value(age)
		else:
			push_warning("new_game：女儿没有 AgeComponent，年龄没有写回")

	Era.print("角色已经建好：%s（%d 岁）" % [display_name, age])
	Era.print("接下来选天赋。", Era.Style.DIM)
	await Era.wait_key()
	return TalentSelect
