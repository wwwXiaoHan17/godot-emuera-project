extends EraEvent
## 角色系统第 1 步演示：生命组件 + 关系组件 + 称呼。
##
## 跑法：F6 打开 tests/demo_character.tscn


func run(context: EventContext) -> GDScript:
	_ensure_characters()
	var daughter := Era.character(&"daughter")
	var player := Era.character(&"player")
	if daughter == null or player == null:
		Era.print("角色创建失败。")
		await Era.wait_key()
		return null

	var life := daughter.get_component(LifeComponent) as LifeComponent
	var daughter_relations := daughter.get_component(RelationComponent) as RelationComponent
	var player_relations := player.get_component(RelationComponent) as RelationComponent

	while true:
		Era.clear()
		Era.print_rule()
		Era.print("角色系统（第 1 步）", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_rule()
		Era.print("女儿：%s（默认称呼：%s）" % [daughter.display_name, daughter.callname])
		Era.print("生命：%d / %d" % [life.value, life.max_value])
		Era.print("女儿对玩家好感：%d" % (
			daughter_relations.relation_to(&"player") if daughter_relations != null else 0
		))
		Era.print("玩家对女儿好感：%d" % (
			player_relations.relation_to(&"daughter") if player_relations != null else 0
		))
		Era.print("女儿称呼玩家：%s" % daughter.name_for(player))
		Era.print_rule()
		Era.print("要做什么？")
		Era.print_button("伤害女儿（生命 -10）", 0)
		Era.print_button("治疗女儿（生命 +10）", 1)
		Era.print_button("好感 +10", 2)
		Era.print_button("退出", 3)

		var picked: int = await Era.input()
		if picked == 3:
			break
		if picked == 0:
			life.hurt(10)
		elif picked == 1:
			life.heal(10)
		elif picked == 2 and daughter_relations != null:
			daughter_relations.add_relation(&"player", 10)

		Era.print(
			"现在：生命 %d　好感 %d" % [
				life.value,
				daughter_relations.relation_to(&"player") if daughter_relations != null else 0,
			],
			Era.Style.ACCENT
		)
		await Era.wait_key()
	return null


## 第一次跑时建两个角色（以后换成 .tres 原型 + spawn）。
func _ensure_characters() -> void:
	var book := Era.state.character_book
	if book == null:
		book = CharacterBook.new()
		Era.state.character_book = book
	if book.find(&"player") != null:
		return

	var player := Character.new()
	player.id = &"player"
	player.display_name = "你"
	player.callname = "你"
	player.add_component(LifeComponent.new())
	var player_relations := RelationComponent.new()
	player.add_component(player_relations)
	player_relations.set_relation_to(&"daughter", 50)
	book.add(player)

	var daughter := Character.new()
	daughter.id = &"daughter"
	daughter.display_name = "阿丽丝"
	daughter.callname = "女儿"
	daughter.add_component(LifeComponent.new())
	var daughter_relations := RelationComponent.new()
	daughter.add_component(daughter_relations)
	daughter_relations.set_relation_to(&"player", 20)
	book.add(daughter)

	book.protagonist_id = &"player"
