extends Node
## CheckEventFlow, 校验两种事件语义
##
## - 重启：return get_script() 会新建事件实例，局部变量重置，Era.state/角色数据保留；
## - 局部循环：while 保留同一事件实例，局部变量继续累加。
## 用真实 Era.input() 驱动，不直接调用 run()。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

class RestartEvent extends EraEvent:
	func run() -> GDScript:
		var local_count := 0
		local_count += 1
		Era.clear()
		Era.print("restart_local=%d" % local_count)
		var daughter := Era.character(&"daughter")
		var life := daughter.get_component(LifeComponent) as LifeComponent
		var second_visit := life != null and life.value == 90
		if not second_visit and life != null:
			life.hurt(10)
		Era.print("life=%d" % (life.value if life != null else -1))
		if second_visit:
			return null
		Era.print_button("继续", 0)
		await Era.input()
		return get_script() as GDScript


class LoopEvent extends EraEvent:
	func run() -> GDScript:
		var local_count := 0
		while true:
			local_count += 1
			Era.clear()
			Era.print("loop_local=%d" % local_count)
			if local_count >= 2:
				return null
			Era.print_button("继续", 0)
			await Era.input()
		return null


func _ready() -> void:
	var failures: Array[String] = []

	var daughter := Character.new()
	daughter.id = &"daughter"
	daughter.display_name = "阿丽丝"
	daughter.add_component(LifeComponent.new())
	var book := CharacterBook.new()
	book.add(daughter)
	book.protagonist_id = &"daughter"
	Era.state.character_book = book

	# 1) 重启：局部计数两次都是 1，生命值从 100 保留为 90
	Era.start(RestartEvent)
	await _wait_rows(2, 120)
	var first := _row_texts()
	if first.size() != 2 or first[0] != "restart_local=1":
		failures.append("重启第一次应打印 restart_local=1，实际 %s" % str(first))
	Era._choose(0)
	await _wait_rows(2, 120)
	await get_tree().process_frame
	var second := _row_texts()
	if second.size() != 2 or second[0] != "restart_local=1":
		failures.append("重启后局部计数应重置为 1，实际 %s" % str(second))
	if daughter.get_component(LifeComponent) == null or (daughter.get_component(LifeComponent) as LifeComponent).value != 90:
		failures.append("重启应保留生命值 90")
	if not second.has("life=90"):
		failures.append("重启后生命行应为 life=90，实际 %s" % str(second))

	# 2) 局部循环：同一实例，计数从 1 累加到 2
	Era.start(LoopEvent)
	await _wait_rows(2, 120)
	var loop_first := _row_texts()
	if loop_first.size() != 1 or loop_first[0] != "loop_local=1":
		failures.append("循环第一次应打印 loop_local=1，实际 %s" % str(loop_first))
	Era._choose(0)
	await _wait_rows(1, 120)
	await get_tree().process_frame
	var loop_second := _row_texts()
	if loop_second.is_empty() or loop_second[0] != "loop_local=2":
		failures.append("循环应保留局部变量累加到 2，实际 %s" % str(loop_second))

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


func _wait_rows(target: int, max_frames: int) -> void:
	var guard := 0
	while Era.row_count() < target and guard < max_frames:
		await get_tree().process_frame
		guard += 1


func _row_texts() -> Array[String]:
	var texts: Array[String] = []
	var rows := get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Scroll/Rows")
	if rows == null:
		return texts
	for row in rows.get_children():
		var label := row.get_node_or_null("Label") as Label
		if label != null and label.visible:
			texts.append(label.text)
	return texts
