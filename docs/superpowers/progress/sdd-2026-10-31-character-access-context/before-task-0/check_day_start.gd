extends Node
## CheckDayStart, 校验完整流程：挂载页 → 天赋格子 → 第 1 天（角色组件版）
##
## 流程：标题 → 开始游戏 → 角色创建页（名字/年龄）→ 天赋选择（多列格子）→
## 第 1 天（数据来自女儿角色的体力/精力/好感/天赋组件）→ 数值变化 → 重画面板。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const TITLE := preload("res://content/events/title.gd")


func _ready() -> void:
	var failures: Array[String] = []

	Era.start(TITLE)
	await _wait_rows(14, 120)
	if Era.row_count() != 14:
		failures.append("标题屏应有 14 行，实际 %d" % Era.row_count())

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

	var rows := get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Scroll/Rows")
	var grid: Variant = null
	if rows != null and rows.get_child_count() >= 1:
		grid = rows.get_child(rows.get_child_count() - 1)
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

	# 等键 → 第 1 天（13 行：名字/体力/好感/天赋/说明/5 个按钮）
	Era._resolve_key()
	if Era.row_count() != 13:
		failures.append("第 1 天应有 13 行（5 个按钮），实际 %d" % Era.row_count())

	var stamina := daughter.get_component(StaminaComponent) as StaminaComponent if daughter != null else null
	var energy := daughter.get_component(EnergyComponent) as EnergyComponent if daughter != null else null
	if stamina == null or energy == null:
		failures.append("女儿缺少体力/精力组件")
	elif stamina.value != 100 or energy.value != 100:
		failures.append("进入第 1 天时体力/精力应为 100/100，实际 %d/%d" % [stamina.value, energy.value])

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
	if Era.row_count() != 13:
		failures.append("从面板返回第 1 天应有 13 行，实际 %d" % Era.row_count())

	# 出去走走 → 组件数值 -10/-5 → 打印结果 + “现在” → 按键后重画
	Era._choose(0)
	if Era.row_count() != 15:
		failures.append("选择后应追加 2 行（结果 + 现在），实际 %d" % Era.row_count())
	if stamina != null and energy != null and (stamina.value != 90 or energy.value != 95):
		failures.append("体力/精力应为 90/95，实际 %d/%d" % [stamina.value, energy.value])
	Era._resolve_key()
	if Era.row_count() != 13:
		failures.append("重画第 1 天后应回到 13 行，实际 %d" % Era.row_count())

	# 在家休息 → 再验证一次加减 + 重画
	Era._choose(1)
	if stamina != null and energy != null and (stamina.value != 95 or energy.value != 100):
		failures.append("休息后体力/精力应为 95/100（精力夹到上限），实际 %d/%d" % [stamina.value, energy.value])
	Era._resolve_key()
	if Era.row_count() != 13:
		failures.append("再次重画后应回到 13 行，实际 %d" % Era.row_count())

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
