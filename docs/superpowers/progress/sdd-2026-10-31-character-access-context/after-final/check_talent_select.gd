extends Node
## CheckTalentSelect, 校验真实天赋选择场景（5 个 TalentData + 多列格子 + 互斥）
##
## 覆盖：格子生成、选中青色、互斥项变灰、灰色项点击无效、反选后恢复、
## 确认后写女儿的天赋组件并进入第 1 天。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const TALENT_SELECT := preload("res://content/events/talent_select.gd")


func _ready() -> void:
	var failures: Array[String] = []

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

		# 穿过 type_a_new_game 剧情（等键 + 双按钮）→ 第 1 天（13 行：多了“对玩家好感”一行 + 5 个按钮）
		await _walk_until_day_start()
		if Era.row_count() != 13:
			failures.append("进入第 1 天应有 13 行，实际 %d" % Era.row_count())

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


## 穿过 type_a_new_game 剧情（print_wait 的等键 + 双按钮 input），直到第 1 天的 13 行出现。
## 不能只看 row_count() >= 13：剧情选“亲生女儿”后行数也会经过 13（还在剧情中段）。
## 必须等行数先冲过 13（剧情尾部）、再被第 1 天清屏回到 13，才算真正到站。
func _walk_until_day_start() -> void:
	var guard := 0
	var peak := 0
	while guard < 120:
		var count := Era.row_count()
		peak = maxi(peak, count)
		if count == 13 and peak > 13:
			return
		Era._choose(0)      # 过 type_a_new_game 的双按钮 input（非 input 期会被引擎忽略，无害）
		Era._resolve_key()  # 过 print_wait 的等键
		await get_tree().process_frame
		guard += 1
