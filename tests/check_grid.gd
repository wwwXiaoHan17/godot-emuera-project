extends Node
## CheckGrid, 校验常驻多列格子的交互
##
## 覆盖：初始选中、点击选择项切换、禁用项点击无效、代码 set_disabled、
## 动作项让 input 返回、input 结束后整块失效。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const DRIVER := preload("res://tests/_drive_grid.gd")

var _toggled_count := 0


func _ready() -> void:
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
		else:
			grid.toggled.connect(_on_toggled)

			var fresh: Array = grid.get_selected()
			if fresh != [0]:
				failures.append("初始选中应为 [0]，实际 %s" % str(fresh))

			# 点选择项 1：应选中
			(grid.get_button(1) as Button).pressed.emit()
			if not bool(grid.is_selected(1)):
				failures.append("点击后 id 1 应该是选中")
			if _toggled_count != 1:
				failures.append("toggled 应发 1 次，实际 %d" % _toggled_count)

			# 点禁用项 2：不应切换
			(grid.get_button(2) as Button).pressed.emit()
			if bool(grid.is_selected(2)):
				failures.append("禁用项不该被选中")
			if _toggled_count != 1:
				failures.append("禁用项不该发 toggled")

			# 代码禁用 1，再点：状态不应变
			grid.set_disabled(1, true)
			(grid.get_button(1) as Button).pressed.emit()
			if not bool(grid.is_selected(1)):
				failures.append("被禁用后再点不应取消选中")
			if _toggled_count != 1:
				failures.append("被禁用后点击不该发 toggled")

			# 恢复 1，再点：应取消选中
			grid.set_disabled(1, false)
			(grid.get_button(1) as Button).pressed.emit()
			if bool(grid.is_selected(1)):
				failures.append("再次点击后 id 1 应该取消选中")
			if _toggled_count != 2:
				failures.append("第二次切换后 toggled 应累计 2 次，实际 %d" % _toggled_count)

			# 点动作项：input 返回 9000，事件结束
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
