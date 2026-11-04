extends Node
## CheckTalentSelect, 校验真实天赋选择场景（5 个 TalentData + 多列格子 + 互斥）
##
## 覆盖：格子生成、选中青色、互斥项变灰、灰色项点击无效、反选后恢复、
## 确认后写女儿的天赋组件并进入第 1 天。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const TALENT_SELECT := preload("res://content/events/talent_select.gd")


func _ready() -> void:
	var failures: Array[String] = []

	# Phase B 起事件自身不再 ensure 装配（收敛到 new_game 一处），测试自带装配。
	Era.set_character_book(CharacterSetup.ensure(Era.state.character_book))
	Era.start(TALENT_SELECT)
	var guard := 0
	while Era.row_count() < 5 and guard < 120:
		await get_tree().process_frame
		guard += 1
	if Era.row_count() != 5:
		failures.append("天赋屏应有 5 行，实际 %d" % Era.row_count())

	var rows := get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Scroll/Rows")
	var grid: Variant = null
	if rows != null and rows.get_child_count() >= 1:
		grid = rows.get_child(rows.get_child_count() - 1)

	if grid == null or not (grid is GridContainer):
		failures.append("天赋屏最后一行不是格子块")
	else:
		# 5 个天赋 + 1 个占位格 + 确认 + 返回 + 1 个说明文字格 = 9
		if grid.get_child_count() != 9:
			failures.append("格子应有 9 格，实际 %d" % grid.get_child_count())

		# 选中“幼稚”（编号 2），互斥的“早熟”（编号 3）应变灰
		(grid.get_button(2) as Button).pressed.emit()
		if not bool(grid.is_selected(2)):
			failures.append("点“幼稚”后应选中")
		if not bool(grid.is_disabled(3)):
			failures.append("幼稚选中后，早熟应变为灰色")

		# 点灰色项无效
		(grid.get_button(3) as Button).pressed.emit()
		if bool(grid.is_selected(3)):
			failures.append("灰色项不该被选中")

		# 反选“幼稚” → “早熟”恢复可点
		(grid.get_button(2) as Button).pressed.emit()
		if bool(grid.is_selected(2)):
			failures.append("再点“幼稚”应取消选中")
		if bool(grid.is_disabled(3)):
			failures.append("幼稚取消后，早熟应恢复")

		# 重新选中幼稚，点确认
		(grid.get_button(2) as Button).pressed.emit()
		(grid.get_button(9998) as Button).pressed.emit()

		var daughter := Era.state.character_book.find(&"daughter") if Era.state.character_book != null else null
		if daughter == null:
			failures.append("确认后应已装配女儿角色")
		else:
			var talent_component := daughter.get_component(TalentListComponent) as TalentListComponent
			if talent_component == null:
				failures.append("女儿缺少天赋组件")
			elif talent_component.selected.size() != 1 or talent_component.selected[0] != &"childish":
				failures.append("天赋组件应为 [childish]，实际 %s" % str(talent_component.selected))
			elif talent_component.text() != "幼稚":
				failures.append("天赋显示名应为“幼稚”，实际 %s" % talent_component.text())
		if Era.row_count() != 7:
			failures.append("确认后应再打印 2 行，实际 %d" % Era.row_count())

		# 穿过 type_a_new_game 剧情（等键 + 双按钮）→ 第 1 天（面板块：3 行）
		await _walk_until_day_start()
		if Era.row_count() != 3:
			failures.append("进入第 1 天应有 3 行（面板块版），实际 %d" % Era.row_count())

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


## 穿过 type_a_new_game 剧情（等键 + 双按钮 input），直到第 1 天出现。
## 第 1 天用面板块（3 行），靠“有没有带按钮 5 的面板块”判断到站，不能只看行数。
func _walk_until_day_start() -> void:
	var guard := 0
	while guard < 240:
		if _is_day_start_visible():
			return
		Era._choose(0)      # 过 type_a_new_game 的双按钮 input（非 input 期会被引擎忽略，无害）
		Era._resolve_key()  # 过 print_wait 的等键
		await get_tree().process_frame
		guard += 1


func _is_day_start_visible() -> bool:
	if Era.row_count() != 3:
		return false
	var rows := get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Scroll/Rows")
	if rows == null:
		return false
	for child in rows.get_children():
		if child.has_method("button_ids"):
			return child.button_ids().has(5)
	return false
