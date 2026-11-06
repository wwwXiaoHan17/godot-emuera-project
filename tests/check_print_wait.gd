extends Node
## CheckPrintWait, 校验 print_wait = print + wait_key
##
## 覆盖：打印一行后流程停住、颜色/对齐沿用 print 参数、按键后继续、
## 再次按键后 flow_finished。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const DRIVER := preload("res://tests/_drive_print_wait.gd")
const PALETTE := preload("res://scripts/engine/era_palette.tres")

var _flow_finished := false


func _ready() -> void:
	var failures: Array[String] = []
	Era.flow_finished.connect(_on_flow_finished, CONNECT_ONE_SHOT)

	Era.start(DRIVER)
	await _wait_rows(1, 120)
	if Era.row_count() != 1:
		failures.append("print_wait 后应先有 1 行，实际 %d" % Era.row_count())

	var row := _row(0)
	if row == null:
		failures.append("找不到第一行")
	else:
		var label := row.get_node_or_null("Label") as Label
		if label == null:
			failures.append("第一行不是普通 Label")
		else:
			if label.text != "等待行":
				failures.append("第一行文字应为“等待行”，实际 %s" % label.text)
			if label.horizontal_alignment != HORIZONTAL_ALIGNMENT_CENTER:
				failures.append("第一行应居中对齐")
			if label.get_theme_color("font_color") != PALETTE.accent:
				failures.append("第一行应使用 ACCENT 颜色")

	# 此时应停在 wait_key；按键后打印第二行并再次等待
	Era._resolve_key()
	await _wait_rows(2, 120)
	if Era.row_count() != 2:
		failures.append("按键后应追加 1 行，实际 %d" % Era.row_count())
	var second := _row(1)
	if second != null:
		var second_label := second.get_node_or_null("Label") as Label
		if second_label == null or second_label.text != "按键后继续。":
			failures.append("第二行文字不对")

	# 第二次按键 → 事件结束
	Era._resolve_key()
	await get_tree().process_frame
	if not _flow_finished:
		failures.append("第二次按键后流程应结束")

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


func _row(index: int) -> Node:
	var rows := get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Scroll/Rows")
	if rows == null or index >= rows.get_child_count():
		return null
	return rows.get_child(index)


func _on_flow_finished() -> void:
	_flow_finished = true
