extends Node
## CheckTitle, 校验标题屏事件
##
## 覆盖：标题屏行数、“继续游戏 / 关于游戏”两条会回到标题的路径。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const TITLE := preload("res://content/events/title.gd")


func _ready() -> void:
	var failures: Array[String] = []

	Era.start(TITLE)
	await _wait_rows(14, 120)
	if Era.row_count() != 14:
		failures.append("标题屏应有 14 行，实际 %d" % Era.row_count())

	# 继续游戏（没有存档）→ 打印一行 → 等键 → 回到标题
	Era._choose(2)
	if Era.row_count() != 15:
		failures.append("“继续游戏”后应追加 1 行，实际 %d" % Era.row_count())
	Era._resolve_key()
	if Era.row_count() != 14:
		failures.append("回到标题后应重新是 14 行，实际 %d" % Era.row_count())

	# 关于游戏 → 打印一行 → 鼠标左键点击 → 回到标题（覆盖鼠标唤醒 wait_key）
	Era._choose(3)
	if Era.row_count() != 15:
		failures.append("“关于游戏”后应追加 1 行，实际 %d" % Era.row_count())
	await _click_left()
	if Era.row_count() != 14:
		failures.append("点击回到标题后应重新是 14 行，实际 %d" % Era.row_count())

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


## 等行数至少到 target（标题事件在引擎等壳排版后才开始跑）。
func _wait_rows(target: int, max_frames: int) -> void:
	var guard := 0
	while Era.row_count() < target and guard < max_frames:
		await get_tree().process_frame
		guard += 1


## 模拟鼠标左键点击（走引擎的 _input）。
func _click_left() -> void:
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	mouse.position = Vector2(16, 16)
	get_viewport().push_input(mouse)
	await get_tree().process_frame
