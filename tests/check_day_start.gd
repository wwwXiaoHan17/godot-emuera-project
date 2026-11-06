extends Node
## CheckDayStart, 校验完整流程：挂载页 → 天赋格子 → 第 1 天（EraFlet 面板版）→ 看地图 → 角色面板
##
## 流程：标题 → 开始游戏 → 角色创建页（名字/年龄）→ 天赋选择（多列格子）→
## type_a 开场剧情 → 第 1 天（状态/菜单用面板块；数据来自女儿组件）→
## 看地图（eraTW 地图，点地点 06）→ 回到第 1 天 → 角色面板 → 数值变化 → 重画。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const TITLE := preload("res://scripts/content/events/type_system_title.gd")
const DAY_START_ROWS := 3      # 分割线 / 面板块 / 分割线
const ACTION_ROWS := 5         # 第 1 天 + 动作结果 2 行


func _ready() -> void:
	var failures: Array[String] = []

	Era.start(TITLE)
	await _wait_rows(19, 120)
	if Era.row_count() != 19:
		failures.append("标题屏应有 19 行，实际 %d" % Era.row_count())

	# 开始游戏：new_game 清屏、打印 2 行、然后挂载角色创建页并等待
	Era._choose(1)
	if Era.row_count() != 2:
		failures.append("new_game 应有 2 行，实际 %d" % Era.row_count())

	var slot := get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Slot")
	var page: Node = null
	if slot == null or slot.get_child_count() != 1:
		failures.append("页面槽里应有 1 个挂载页面")
	else:
		page = slot.get_child(0)

	# 模拟页面“点了下一步”，交出名字/年龄
	if page != null:
		page.finished.emit({"display_name": "小灯", "age": 21})
	if Era.row_count() != 4:
		failures.append("页面返回后应追加 2 行，实际 %d" % Era.row_count())
	if slot != null and slot.get_child_count() != 0:
		failures.append("页面拿掉后槽里应该是空的")

	# 角色装配：页面返回后应该已经有女儿，名字/年龄同步过去
	var daughter := Era.state.character_book.find(&"daughter") if Era.state.character_book != null else null
	var age_component := daughter.get_component(AgeComponent) as AgeComponent if daughter != null else null
	if daughter == null:
		failures.append("页面返回后应装配女儿角色")
	elif daughter.display_name != "小灯":
		failures.append("女儿的名字应同步为小灯，实际 %s" % daughter.display_name)
	elif age_component == null or age_component.value != 21:
		failures.append("女儿的 AgeComponent.value 应同步为 21，实际 %s" % (
			str(age_component.value) if age_component != null else "无 AgeComponent"
		))

	# 等任意键 → 天赋选择（5 行）
	Era._resolve_key()
	if Era.row_count() != 5:
		failures.append("天赋屏应有 5 行，实际 %d" % Era.row_count())

	var grid: Variant = null
	var rows_node := _rows()
	if rows_node != null and rows_node.get_child_count() >= 1:
		grid = rows_node.get_child(rows_node.get_child_count() - 1)
	if grid == null or not (grid is GridContainer):
		failures.append("天赋屏最后一行不是格子块")
	else:
		# 选“幼稚”（2），确认
		(grid.get_button(2) as Button).pressed.emit()
		(grid.get_button(9998) as Button).pressed.emit()

	if daughter != null:
		var talent_component := daughter.get_component(TalentListComponent) as TalentListComponent
		if talent_component == null:
			failures.append("女儿缺少天赋组件")
		elif talent_component.selected.size() != 1 or talent_component.selected[0] != &"childish":
			failures.append("天赋组件应为 [childish]，实际 %s" % str(talent_component.selected))
		elif talent_component.text() != "幼稚":
			failures.append("天赋显示名应为“幼稚”，实际 %s" % talent_component.text())
	if Era.row_count() != 7:
		failures.append("确认后应再打印 2 行，实际 %d" % Era.row_count())

	# 穿过 type_a_new_game 剧情 → 第 1 天（面板版：3 行）
	await _walk_until_day_start()
	if not _is_day_start_visible():
		failures.append("没有进入第 1 天")
	if Era.row_count() != DAY_START_ROWS:
		failures.append("第 1 天应有 %d 行，实际 %d" % [DAY_START_ROWS, Era.row_count()])

	var stamina := daughter.get_component(StaminaComponent) as StaminaComponent if daughter != null else null
	var energy := daughter.get_component(EnergyComponent) as EnergyComponent if daughter != null else null
	if stamina == null or energy == null:
		failures.append("女儿缺少体力/精力组件")
	elif stamina.value != 100 or energy.value != 100:
		failures.append("进入第 1 天时体力/精力应为 100/100，实际 %d/%d" % [stamina.value, energy.value])

	# 面板块：高度 204（8 行），状态面板里有“第 1 天”，下面的分割线对齐到 +234px
	var block: Variant = _find_panel_block()
	if block == null:
		failures.append("第 1 天没有面板块")
	else:
		if absf(block.get_combined_minimum_size().y - 204.0) > 0.5:
			failures.append("第 1 天面板块高度应为 204，实际 %.2f" % block.get_combined_minimum_size().y)
		var texts: Array[String] = []
		_collect_texts(block, texts)
		if not texts.has("第 1 天"):
			failures.append("状态面板里没有“第 1 天”")
		if not texts.has("[0] 出去走走"):
			failures.append("菜单面板里没有“[0] 出去走走”")
		if rows_node != null and rows_node.get_child_count() == DAY_START_ROWS:
			var first_y: float = (rows_node.get_child(0) as Control).position.y
			var last_y: float = (rows_node.get_child(2) as Control).position.y
			if absf(last_y - first_y - 9.0 * 26.0) > 0.5:
				failures.append("面板下面的分割线应对齐到 +234px，实际 +%.2f" % (last_y - first_y))

	# 看地图：第 1 天 → 2 行（标题 + 地图）→ 点地点 06 → 3 行（结果）→ 按键回第 1 天
	Era._choose(5)
	if Era.row_count() != 2:
		failures.append("地图屏应有 2 行（标题 + 地图），实际 %d" % Era.row_count())
	var map_row: Variant = _find_panel_block()
	if map_row == null or not map_row.has_method("get_button"):
		failures.append("地图屏最后一行不是地图块")
	elif not map_row.button_ids().has(6):
		failures.append("地图块里没有地点 06 的按钮")
	else:
		(map_row.get_button(6) as Button).pressed.emit()
		if Era.row_count() != 3:
			failures.append("点地点后应多 1 行结果，实际 %d" % Era.row_count())
		var rows_after := _rows()
		if rows_after != null and rows_after.get_child_count() >= 3:
			var result_text: String = _row_text(rows_after.get_child(2))
			if result_text != "你点了地点 06。":
				failures.append("地点结果文字不对：%s" % result_text)
	Era._resolve_key()
	if not _is_day_start_visible():
		failures.append("地图按键后应回到第 1 天")
	if Era.row_count() != DAY_START_ROWS:
		failures.append("回到第 1 天应有 %d 行，实际 %d" % [DAY_START_ROWS, Era.row_count()])

	# 查看角色面板：第 1 天 → 面板 11 行
	Era._choose(2)
	if Era.row_count() != 11:
		failures.append("角色面板应有 11 行，实际 %d" % Era.row_count())

	# 面板里点“生命 -10” → 组件变化 + “现在”行 → 按键重画面板
	Era._choose(0)
	var life := daughter.get_component(LifeComponent) as LifeComponent if daughter != null else null
	if life == null or life.value != 90:
		failures.append("面板“生命 -10”后生命应为 90，实际 %s" % (str(life.value) if life != null else "无组件"))
	if Era.row_count() != 12:
		failures.append("面板动作后应多 1 行“现在”，实际 %d" % Era.row_count())
	Era._resolve_key()
	if Era.row_count() != 11:
		failures.append("重画角色面板后应回到 11 行，实际 %d" % Era.row_count())

	# 返回第 1 天
	Era._choose(4)
	if Era.row_count() != DAY_START_ROWS:
		failures.append("从面板返回第 1 天应有 %d 行，实际 %d" % [DAY_START_ROWS, Era.row_count()])

	# 出去走走 → 组件数值 -10/-5 → 打印结果 + “现在” → 按键后重画
	Era._choose(0)
	if Era.row_count() != ACTION_ROWS:
		failures.append("选择后应追加 2 行（结果 + 现在），实际 %d" % Era.row_count())
	if stamina != null and energy != null and (stamina.value != 90 or energy.value != 95):
		failures.append("体力/精力应为 90/95，实际 %d/%d" % [stamina.value, energy.value])
	Era._resolve_key()
	if Era.row_count() != DAY_START_ROWS:
		failures.append("重画第 1 天后应回到 %d 行，实际 %d" % [DAY_START_ROWS, Era.row_count()])

	# 在家休息 → 再验证一次加减 + 重画
	Era._choose(1)
	if stamina != null and energy != null and (stamina.value != 95 or energy.value != 100):
		failures.append("休息后体力/精力应为 95/100（精力夹到上限），实际 %d/%d" % [stamina.value, energy.value])
	Era._resolve_key()
	if Era.row_count() != DAY_START_ROWS:
		failures.append("再次重画后应回到 %d 行，实际 %d" % [DAY_START_ROWS, Era.row_count()])

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


func _rows() -> Node:
	return get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Scroll/Rows")


## 屏幕里带 button_ids() 的行（面板块 / 地图块），没有就返回 null。
func _find_panel_block() -> Variant:
	var rows_node := _rows()
	if rows_node == null:
		return null
	for child in rows_node.get_children():
		if child.has_method("button_ids"):
			return child
	return null


## 第 1 天是否已经显示：3 行，且其中有一块带按钮 0 和 5 的面板块。
func _is_day_start_visible() -> bool:
	if Era.row_count() != DAY_START_ROWS:
		return false
	var block: Variant = _find_panel_block()
	return block != null and block.button_ids().has(0) and block.button_ids().has(5)


func _row_text(row: Node) -> String:
	for child in row.get_children():
		if child is Label:
			return (child as Label).text
		if child is RichTextLabel:
			return (child as RichTextLabel).get_parsed_text()
	if row is Label:
		return (row as Label).text
	return ""


func _collect_texts(node: Node, out: Array[String]) -> void:
	if node is Label:
		out.append((node as Label).text)
	elif node is RichTextLabel:
		out.append((node as RichTextLabel).get_parsed_text())
	elif node is Button:
		out.append((node as Button).text)
	for child in node.get_children():
		_collect_texts(child, out)


func _wait_rows(target: int, max_frames: int) -> void:
	var guard := 0
	while Era.row_count() < target and guard < max_frames:
		await get_tree().process_frame
		guard += 1


## 穿过 type_a_new_game 剧情（print_wait 的等键 + 双按钮 input），直到第 1 天的 3 行出现。
## 不能只看 row_count()：剧情中也可能正好是 3 行，所以用“有没有带按钮 0/5 的面板块”判断到站。
func _walk_until_day_start() -> void:
	var guard := 0
	while guard < 240:
		if _is_day_start_visible():
			return
		Era._choose(0)      # 过 type_a_new_game 的双按钮 input（非 input 期会被引擎忽略，无害）
		Era._resolve_key()  # 过 print_wait 的等键
		await get_tree().process_frame
		guard += 1
