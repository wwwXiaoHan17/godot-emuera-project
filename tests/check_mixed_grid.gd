extends Node
## CheckMixedGrid, 校验混合格子（文字格 + 选择项 + 动作项）
##
## 覆盖：文字格是 Label、颜色/对齐正确、选择项可点、禁用项无效、
## 动作项让 input 返回、结束后整块失效。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const DRIVER := preload("res://tests/_drive_mixed_grid.gd")

var _palette: EraPalette
var _toggled_count := 0


func _ready() -> void:
	_palette = load("res://scripts/engine/era_palette.tres") as EraPalette
	var failures: Array[String] = []

	Era.start(DRIVER)
	var guard := 0
	while Era.row_count() < 1 and guard < 120:
		await get_tree().process_frame
		guard += 1

	var rows := get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Scroll/Rows")
	if rows == null or rows.get_child_count() < 1:
		failures.append("屏幕里没有格子块")
	else:
		var grid: Variant = rows.get_child(rows.get_child_count() - 1)
		if not (grid is GridContainer):
			failures.append("最后一行不是 GridContainer")
		elif grid.get_child_count() != 5:
			failures.append(
				"混合格子应有 5 格（2 文字 + 2 选择 + 1 动作），实际 %d" % grid.get_child_count()
			)
		else:
			grid.toggled.connect(_on_toggled)
			var cell0: Label = grid.get_child(0) as Label
			var cell1: Label = grid.get_child(1) as Label
			if cell0 == null or cell1 == null:
				failures.append("前两格应该是 Label（文字格）")
			else:
				if cell0.horizontal_alignment != HORIZONTAL_ALIGNMENT_CENTER:
					failures.append("文字格 1 应对齐居中")
				if cell1.horizontal_alignment != HORIZONTAL_ALIGNMENT_RIGHT:
					failures.append("文字格 2 应对齐右")
				if cell0.get_theme_color("font_color") != _palette.accent:
					failures.append("文字格 1 应是强调色")
				if cell1.get_theme_color("font_color") != _palette.dim:
					failures.append("文字格 2 应是暗淡色")

			(grid.get_button(0) as Button).pressed.emit()
			if not bool(grid.is_selected(0)):
				failures.append("点击后 id 0 应该选中")
			if _toggled_count != 1:
				failures.append("toggled 应发 1 次，实际 %d" % _toggled_count)

			(grid.get_button(1) as Button).pressed.emit()
			if bool(grid.is_selected(1)):
				failures.append("禁用项不该被选中")

			(grid.get_button(9000) as Button).pressed.emit()
			var tester := Era.state.character_book.find(&"test_character")
			var life := tester.get_component(LifeComponent) as LifeComponent if tester != null else null
			var talents := tester.get_component(TalentListComponent) as TalentListComponent if tester != null else null
			if life == null or life.value != 9000:
				failures.append("动作项应让 input 返回 9000，实际 %s" % (str(life.value) if life != null else "无组件"))
			if talents == null or talents.selected != [&"0"]:
				failures.append("结束时选中应为 [0]，实际 %s" % (
					str(talents.selected) if talents != null else "无组件"
				))
			if not (grid.get_button(0) as Button).disabled:
				failures.append("input 结束后整块应变灰失效")

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


func _on_toggled(_id: int, _selected: bool) -> void:
	_toggled_count += 1
