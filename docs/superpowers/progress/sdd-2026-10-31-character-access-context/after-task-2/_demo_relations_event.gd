extends EraEvent
## 角色系统第 2 步演示：.tres 角色原型 + 多角色关系矩阵。
##
## 跑法：F6 打开 tests/demo_relations.tscn


func run(context: EventContext) -> GDScript:
	_ensure_characters()
	var player := Era.character(&"player")
	var daughter := Era.character(&"daughter")
	var maid := Era.character(&"maid")
	if player == null or daughter == null or maid == null:
		Era.print("角色创建失败。")
		await Era.wait_key()
		return null

	var player_relations := player.get_component(RelationComponent) as RelationComponent
	var daughter_relations := daughter.get_component(RelationComponent) as RelationComponent
	var characters: Array[Character] = [player, daughter, maid]

	while true:
		Era.clear()
		Era.print_rule()
		Era.print("多角色关系矩阵（第 2 步）", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_rule()

		# 矩阵：行 = 谁，列 = 对谁（空格子用纯文字格）
		Era.begin_grid(4)
		Era.print_cell("关系", Era.Style.DIM)
		for character in characters:
			Era.print_cell(character.display_name, Era.Style.DIM, HORIZONTAL_ALIGNMENT_CENTER)
		for row in characters:
			Era.print_cell(row.display_name, Era.Style.DIM)
			var row_relations := row.get_component(RelationComponent) as RelationComponent
			for column_character in characters:
				var value: int = row_relations.relation_to(column_character.id) if row_relations != null else 0
				var style := Era.Style.NORMAL if value > 0 else Era.Style.DIM
				Era.print_cell(str(value), style, HORIZONTAL_ALIGNMENT_CENTER)
		Era.end_grid()

		Era.print("女儿称呼玩家：%s" % daughter.name_for(player))
		Era.print("女仆称呼女儿：%s" % maid.name_for(daughter))
		Era.print_rule()
		Era.print("要做什么？")
		Era.print_button("女儿对玩家好感 +10", 0)
		Era.print_button("玩家对女儿好感 +10", 1)
		Era.print_button("让女儿叫玩家“爸爸”", 2)
		Era.print_button("退出", 3)

		var picked: int = await Era.input()
		if picked == 3:
			break
		if picked == 0 and daughter_relations != null:
			daughter_relations.add_relation(&"player", 10)
		elif picked == 1 and player_relations != null:
			player_relations.add_relation(&"daughter", 10)
		elif picked == 2 and daughter_relations != null:
			daughter_relations.set_callname_for(&"player", "爸爸")

		Era.print("现在：女儿→玩家 %d　玩家→女儿 %d　女儿称呼玩家：%s" % [
			daughter_relations.relation_to(&"player") if daughter_relations != null else 0,
			player_relations.relation_to(&"daughter") if player_relations != null else 0,
			daughter.name_for(player),
		], Era.Style.ACCENT)
		await Era.wait_key()
	return null


## 用 .tres 原型 spawn 出运行时实例（以后读档也走这里）。
func _ensure_characters() -> void:
	var book := Era.state.character_book
	if book == null:
		book = CharacterBook.new()
		Era.state.character_book = book
	if book.find(&"player") != null:
		return

	book.add((preload("res://content/characters/prototypes/玩家.tres") as Character).spawn(&"player"))
	book.add((preload("res://content/characters/prototypes/女儿.tres") as Character).spawn(&"daughter"))
	book.add((preload("res://content/characters/prototypes/女仆.tres") as Character).spawn(&"maid"))
	book.protagonist_id = &"player"
