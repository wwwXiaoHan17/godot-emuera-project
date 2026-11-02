extends Node
## CheckKojo, 校验直接 GDScript 口上：文本 / 条件 / 随机 / 分支 / 缺事件。
##
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const PLAYER_PROTO := preload("res://content/characters/prototypes/玩家.tres")
const DAUGHTER_PROTO := preload("res://content/characters/prototypes/女儿.tres")


func _ready() -> void:
	var failures: Array[String] = []
	await get_tree().process_frame
	await get_tree().process_frame

	var player := PLAYER_PROTO.spawn(&"player")
	var daughter := DAUGHTER_PROTO.spawn(&"daughter")
	var book := CharacterBook.new()
	book.add(player)
	book.add(daughter)
	book.protagonist_id = &"player"
	Era.state.character_book = book

	var kojo_component := daughter.get_component(KojoComponent) as KojoComponent
	var daughter_relations := daughter.get_component(RelationComponent) as RelationComponent
	if kojo_component == null or kojo_component.book == null:
		failures.append("女儿没有口上组件/口上书")
	elif daughter_relations == null:
		failures.append("女儿没有关系组件")
	else:
		# 1) 好感 20 的morning：问候 + 随机，无条件台词
		Era.clear()
		await Era.kojo(daughter, &"morning", {"partner": player})
		var morning := _row_texts()
		if morning.size() != 2:
			failures.append("好感 20 的morning应有 2 行，实际 %s" % str(morning))
		else:
			if morning[0] != "早上好，你。":
				failures.append("问候不对：%s" % morning[0])
			if morning[1] != "天气真好。" and morning[1] != "要一起出门吗？":
				failures.append("随机行不对：%s" % morning[1])

		# 2) 好感 50：多一行条件台词
		daughter_relations.set_relation_to(&"player", 50)
		Era.clear()
		await Era.kojo(daughter, &"morning")
		var morning_high := _row_texts()
		if morning_high.size() != 3:
			failures.append("好感 50 的morning应有 3 行，实际 %s" % str(morning_high))
		elif morning_high[1] != "今天也要一起加油哦。":
			failures.append("条件台词不对：%s" % str(morning_high))

		# 3) “调教后”好感 50：走真分支
		Era.clear()
		await Era.kojo(daughter, &"after_training")
		var after_high := _row_texts()
		if after_high.size() != 2 or after_high[1] != "……嗯，最喜欢你了。":
			failures.append("“调教后”真分支不对：%s" % str(after_high))

		# 4) “调教后”好感 20：走假分支
		daughter_relations.set_relation_to(&"player", 20)
		Era.clear()
		await Era.kojo(daughter, &"after_training")
		var after_low := _row_texts()
		if after_low.size() != 2 or after_low[1] != "……别碰我。":
			failures.append("“调教后”假分支不对：%s" % str(after_low))

		# 5) 缺少事件：返回 null，且不打印
		Era.clear()
		var missing: Variant = await Era.kojo(daughter, &"missing")
		if missing != null or Era.row_count() != 0:
			failures.append("缺少事件时应返回 null 且不打印，实际 result=%s rows=%d" % [
				str(missing), Era.row_count()
			])

		# 6) sync 口上：只打印、不等待
		Era.clear()
		var daily: Variant = await Era.kojo(daughter, &"daily", {"partner": player})
		var daily_texts := _row_texts()
		if daily != null or daily_texts.size() != 1 or daily_texts[0] != "（你 今天也很有精神。）":
			failures.append("sync 口上不对：result=%s lines=%s" % [str(daily), str(daily_texts)])

		# 7) 口上组件计数：morning调用了两次
		if kojo_component.counter(&"morning") != 2:
			failures.append("morning调用次数应为 2，实际 %d" % kojo_component.counter(&"morning"))
		if kojo_component.counter(&"daily") != 1:
			failures.append("daily调用次数应为 1，实际 %d" % kojo_component.counter(&"daily"))

	# 8) 没有口上组件的角色：不应输出
	var bare := Character.new()
	bare.id = &"stranger"
	Era.clear()
	var bare_result: Variant = await Era.kojo(bare, &"morning")
	if bare_result != null or Era.row_count() != 0:
		failures.append("没有口上组件的角色不应输出")

	# 9) KojoContext 固定字段与 extras：同名 extras 不能覆盖固定字段
	var probe_book: Variant = preload("res://tests/_kojo_context_probe.gd").new()
	var probe_character := DAUGHTER_PROTO.spawn(&"probe_daughter")
	var probe_component := KojoComponent.new()
	probe_component.book = probe_book
	probe_character.add_component(probe_component)
	var extras := {
		"partner": player,
		"speaker": "恶意 speaker",
		"player": "恶意 player",
		"state": "恶意 state",
		"other": 42,
	}
	var probe_result: Variant = await Era.kojo(probe_character, &"probe", extras)
	var probe_context: KojoContext = probe_book.last_context
	if probe_context == null:
		failures.append("probe 没有收到 KojoContext")
	else:
		if probe_context.speaker != probe_character:
			failures.append("KojoContext.speaker 应为 probe 角色")
		if probe_context.player != player:
			failures.append("KojoContext.player 应为主角")
		if probe_context.state != Era.state:
			failures.append("KojoContext.state 应为 Era.state")
		if probe_result != player:
			failures.append("probe 应返回 extras[partner]，实际 %s" % str(probe_result))
		if probe_context.extras.get("speaker") != "恶意 speaker":
			failures.append("extras 里的同名键应原样保留")
		if probe_context.extras.get("other") != 42:
			failures.append("extras 额外键应可读取")
		if not (probe_context is EventContext):
			failures.append("KojoContext 应继承 EventContext")
		if probe_context.character(&"player") != player:
			failures.append("context.character 应能查到主角")
		if probe_context.character(&"missing") != null:
			failures.append("查无此人时 character() 应返回 null")

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


## 把文字行（Label / RichTextLabel）收成字符串；按钮/格子行跳过。
func _row_texts() -> Array[String]:
	var texts: Array[String] = []
	var rows := get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Scroll/Rows")
	if rows == null:
		return texts
	for row in rows.get_children():
		var label := row.get_node_or_null("Label") as Label
		if label != null and label.visible:
			texts.append(label.text)
			continue
		var rich := row.get_node_or_null("RichTextLabel") as RichTextLabel
		if rich != null and rich.visible:
			texts.append(rich.text)
	return texts
