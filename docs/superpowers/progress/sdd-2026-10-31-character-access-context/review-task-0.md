=== Task 0 diff（before → after，git diff --no-index）===
 .../check_day_start.gd"                            | 31 +++++++++++++++++-----
 .../check_talent_select.gd"                        | 21 +++++++++++++--
 .../check_title.gd"                                | 20 +++++++-------
 3 files changed, 53 insertions(+), 19 deletions(-)

=== Full diff (U10) ===
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-0/check_day_start.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-0/check_day_start.gd"
index 072ad87..376e80c 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-0/check_day_start.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-0/check_day_start.gd"
@@ -1,27 +1,27 @@
 extends Node
 ## CheckDayStart, 校验完整流程：挂载页 → 天赋格子 → 第 1 天（角色组件版）
 ##
 ## 流程：标题 → 开始游戏 → 角色创建页（名字/年龄）→ 天赋选择（多列格子）→
-## 第 1 天（数据来自女儿角色的体力/精力/好感/天赋组件）→ 数值变化 → 重画面板。
+## type_a 开场剧情 → 第 1 天（数据来自女儿角色的体力/精力/好感/天赋组件）→ 数值变化 → 重画面板。
 ## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。
 
-const TITLE := preload("res://content/events/title.gd")
+const TITLE := preload("res://content/events/type_a_title.gd")
 
 
 func _ready() -> void:
 	var failures: Array[String] = []
 
 	Era.start(TITLE)
-	await _wait_rows(14, 120)
-	if Era.row_count() != 14:
-		failures.append("标题屏应有 14 行，实际 %d" % Era.row_count())
+	await _wait_rows(19, 120)
+	if Era.row_count() != 19:
+		failures.append("标题屏应有 19 行，实际 %d" % Era.row_count())
 
 	# 开始游戏：new_game 清屏、打印 2 行、然后挂载角色创建页并等待
 	Era._choose(1)
 	if Era.row_count() != 2:
 		failures.append("new_game 应有 2 行，实际 %d" % Era.row_count())
 
 	var slot := get_node_or_null("/root/Era/EraLayer/EraScreen/Margin/Slot")
 	var page: Node = null
 	if slot == null or slot.get_child_count() != 1:
 		failures.append("页面槽里应有 1 个挂载页面")
@@ -68,22 +68,22 @@ func _ready() -> void:
 		var talent_component := daughter.get_component(TalentListComponent) as TalentListComponent
 		if talent_component == null:
 			failures.append("女儿缺少天赋组件")
 		elif talent_component.selected.size() != 1 or talent_component.selected[0] != &"childish":
 			failures.append("天赋组件应为 [childish]，实际 %s" % str(talent_component.selected))
 		elif talent_component.text() != "幼稚":
 			failures.append("天赋显示名应为“幼稚”，实际 %s" % talent_component.text())
 	if Era.row_count() != 7:
 		failures.append("确认后应再打印 2 行，实际 %d" % Era.row_count())
 
-	# 等键 → 第 1 天（13 行：名字/体力/好感/天赋/说明/5 个按钮）
-	Era._resolve_key()
+	# 穿过 type_a_new_game 剧情（等键 + 双按钮）→ 第 1 天（13 行：名字/体力/好感/天赋/说明/5 个按钮）
+	await _walk_until_day_start()
 	if Era.row_count() != 13:
 		failures.append("第 1 天应有 13 行（5 个按钮），实际 %d" % Era.row_count())
 
 	var stamina := daughter.get_component(StaminaComponent) as StaminaComponent if daughter != null else null
 	var energy := daughter.get_component(EnergyComponent) as EnergyComponent if daughter != null else null
 	if stamina == null or energy == null:
 		failures.append("女儿缺少体力/精力组件")
 	elif stamina.value != 100 or energy.value != 100:
 		failures.append("进入第 1 天时体力/精力应为 100/100，实际 %d/%d" % [stamina.value, energy.value])
 
@@ -134,10 +134,27 @@ func _ready() -> void:
 		for failure in failures:
 			print("  - ", failure)
 		get_tree().quit(1)
 
 
 func _wait_rows(target: int, max_frames: int) -> void:
 	var guard := 0
 	while Era.row_count() < target and guard < max_frames:
 		await get_tree().process_frame
 		guard += 1
+
+
+## 穿过 type_a_new_game 剧情（print_wait 的等键 + 双按钮 input），直到第 1 天的 13 行出现。
+## 不能只看 row_count() >= 13：剧情选“亲生女儿”后行数也会经过 13（还在剧情中段）。
+## 必须等行数先冲过 13（剧情尾部）、再被第 1 天清屏回到 13，才算真正到站。
+func _walk_until_day_start() -> void:
+	var guard := 0
+	var peak := 0
+	while guard < 120:
+		var count := Era.row_count()
+		peak = maxi(peak, count)
+		if count == 13 and peak > 13:
+			return
+		Era._choose(0)      # 过 type_a_new_game 的双按钮 input（非 input 期会被引擎忽略，无害）
+		Era._resolve_key()  # 过 print_wait 的等键
+		await get_tree().process_frame
+		guard += 1
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-0/check_talent_select.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-0/check_talent_select.gd"
index 01af6da..a38c478 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-0/check_talent_select.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-0/check_talent_select.gd"
@@ -61,23 +61,40 @@ func _ready() -> void:
 			var talent_component := daughter.get_component(TalentListComponent) as TalentListComponent
 			if talent_component == null:
 				failures.append("女儿缺少天赋组件")
 			elif talent_component.selected.size() != 1 or talent_component.selected[0] != &"childish":
 				failures.append("天赋组件应为 [childish]，实际 %s" % str(talent_component.selected))
 			elif talent_component.text() != "幼稚":
 				failures.append("天赋显示名应为“幼稚”，实际 %s" % talent_component.text())
 		if Era.row_count() != 7:
 			failures.append("确认后应再打印 2 行，实际 %d" % Era.row_count())
 
-		# 等键 → 第 1 天（13 行：多了“对玩家好感”一行 + 5 个按钮）
-		Era._resolve_key()
+		# 穿过 type_a_new_game 剧情（等键 + 双按钮）→ 第 1 天（13 行：多了“对玩家好感”一行 + 5 个按钮）
+		await _walk_until_day_start()
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
+
+
+## 穿过 type_a_new_game 剧情（print_wait 的等键 + 双按钮 input），直到第 1 天的 13 行出现。
+## 不能只看 row_count() >= 13：剧情选“亲生女儿”后行数也会经过 13（还在剧情中段）。
+## 必须等行数先冲过 13（剧情尾部）、再被第 1 天清屏回到 13，才算真正到站。
+func _walk_until_day_start() -> void:
+	var guard := 0
+	var peak := 0
+	while guard < 120:
+		var count := Era.row_count()
+		peak = maxi(peak, count)
+		if count == 13 and peak > 13:
+			return
+		Era._choose(0)      # 过 type_a_new_game 的双按钮 input（非 input 期会被引擎忽略，无害）
+		Era._resolve_key()  # 过 print_wait 的等键
+		await get_tree().process_frame
+		guard += 1
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-0/check_title.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-0/check_title.gd"
index 6742aca..ba2b63b 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-0/check_title.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-0/check_title.gd"
@@ -1,42 +1,42 @@
 extends Node
 ## CheckTitle, 校验标题屏事件
 ##
 ## 覆盖：标题屏行数、“继续游戏 / 关于游戏”两条会回到标题的路径。
 ## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。
 
-const TITLE := preload("res://content/events/title.gd")
+const TITLE := preload("res://content/events/type_a_title.gd")
 
 
 func _ready() -> void:
 	var failures: Array[String] = []
 
 	Era.start(TITLE)
-	await _wait_rows(14, 120)
-	if Era.row_count() != 14:
-		failures.append("标题屏应有 14 行，实际 %d" % Era.row_count())
+	await _wait_rows(19, 120)
+	if Era.row_count() != 19:
+		failures.append("标题屏应有 19 行，实际 %d" % Era.row_count())
 
 	# 继续游戏（没有存档）→ 打印一行 → 等键 → 回到标题
 	Era._choose(2)
-	if Era.row_count() != 15:
+	if Era.row_count() != 20:
 		failures.append("“继续游戏”后应追加 1 行，实际 %d" % Era.row_count())
 	Era._resolve_key()
-	if Era.row_count() != 14:
-		failures.append("回到标题后应重新是 14 行，实际 %d" % Era.row_count())
+	if Era.row_count() != 19:
+		failures.append("回到标题后应重新是 19 行，实际 %d" % Era.row_count())
 
 	# 关于游戏 → 打印一行 → 鼠标左键点击 → 回到标题（覆盖鼠标唤醒 wait_key）
 	Era._choose(3)
-	if Era.row_count() != 15:
+	if Era.row_count() != 20:
 		failures.append("“关于游戏”后应追加 1 行，实际 %d" % Era.row_count())
 	await _click_left()
-	if Era.row_count() != 14:
-		failures.append("点击回到标题后应重新是 14 行，实际 %d" % Era.row_count())
+	if Era.row_count() != 19:
+		failures.append("点击回到标题后应重新是 19 行，实际 %d" % Era.row_count())
 
 	if failures.is_empty():
 		print("CHECK OK")
 		get_tree().quit(0)
 	else:
 		print("CHECK FAIL")
 		for failure in failures:
 			print("  - ", failure)
 		get_tree().quit(1)
 
