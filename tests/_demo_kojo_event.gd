extends EraEvent
## 演示：带按钮的口上 + sync 口上 + 口上开关/计数。
##
## 跑法：F6 打开 tests/demo_kojo.tscn

const PLAYER_PROTO := preload("res://content/characters/prototypes/玩家.tres")
const DAUGHTER_PROTO := preload("res://content/characters/prototypes/女儿.tres")


func run(context: EventContext) -> GDScript:
	_ensure_characters()
	var daughter := context.character(&"daughter")
	var player := context.character(&"player")
	if daughter == null or player == null:
		Era.print("角色创建失败。")
		await Era.wait_key()
		return null

	var kojo := daughter.get_component(KojoComponent) as KojoComponent
	var daughter_relations := daughter.get_component(RelationComponent) as RelationComponent
	var daily_enabled := true

	while true:
		Era.clear()
		Era.print_rule()
		Era.print("口上（KOJO）演示（第 4 步）", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_rule()
		Era.print("女儿对玩家好感：%d" % (
			daughter_relations.relation_to(&"player") if daughter_relations != null else 0
		))
		Era.print("女儿称呼玩家：%s" % daughter.name_for(player))
		Era.print("口上调用次数：早上 %d / 撒娇 %d / 每日开场 %d" % [
			kojo.counter(&"morning"), kojo.counter(&"act_cute"), kojo.counter(&"daily")
		])
		Era.print("每日开场（sync）：%s" % ("开" if daily_enabled else "关"))
		Era.print_rule()
		Era.print("要听哪段口上？")
		Era.print_button("早上", 0)
		Era.print_button("调教后", 1)
		Era.print_button("撒娇（带选项）", 2)
		Era.print_button("每日开场（sync）", 3)
		Era.print_button("开关每日开场", 4)
		Era.print_button("好感 +10", 5)
		Era.print_button("退出", 6)
		Era.print_button("爱抚口上测试", 7)
		
		var event_name: StringName
		match await Era.input():
			0:
				event_name = &"morning"
			1:
				event_name = &"after_training"
			2: # 带按钮的口上：Era.kojo 会一直等到按钮选完
				var result: Variant = await Era.kojo(daughter, &"act_cute", {"partner": player})
				
				Era.clear()
				Era.print("—— 口上：撒娇 ——", Era.Style.DIM)
				Era.print("（Era.kojo 返回：%s）" % str(result), Era.Style.DIM)
				Era.print_gap()
				await Era.print_wait("按任意键返回。", Era.Style.DIM)
				continue
			3:
				event_name = &"daily"
			4:
				daily_enabled = not daily_enabled
				kojo.set_event_enabled(&"daily", daily_enabled)
				await Era.print_wait("每日开场口上已%s。" % ("打开" if daily_enabled else "关掉"), Era.Style.ACCENT)
				continue
			5:
				if daughter_relations != null:
					daughter_relations.add_relation(&"player", 10)
					await Era.print_wait("现在：好感 %d" % daughter_relations.relation_to(&"player"), Era.Style.ACCENT)
				continue
			6:
				break
			7:
				event_name = &"caress"
			_:
				return
		

		#Era.clear()
		Era.print("—— 口上：%s ——" % event_name, Era.Style.DIM)
		await Era.kojo(daughter, event_name, {"partner": player})
		Era.print_gap()
		#await Era.print_wait("按任意键返回。", Era.Style.DIM)
		await Era.wait_key()
	return null


func _ensure_characters() -> void:
	var book := Era.state.character_book
	if book == null:
		book = CharacterBook.new()
		Era.set_character_book(book)
	if book.find(&"player") != null:
		return
	book.add(PLAYER_PROTO.spawn(&"player"))
	book.add(DAUGHTER_PROTO.spawn(&"daughter"))
	book.protagonist_id = &"player"
