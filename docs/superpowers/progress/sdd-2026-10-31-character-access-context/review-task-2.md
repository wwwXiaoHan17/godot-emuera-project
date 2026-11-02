=== Task 2 diff（before → after，git diff --no-index；含 .uid 快照）===
 .../_demo_character_event.gd"                      |  2 +-
 .../_demo_grid_b_event.gd"                         |  2 +-
 .../_demo_kojo_event.gd"                           |  2 +-
 .../_demo_mixed_grid_event.gd"                     |  2 +-
 .../_demo_relations_event.gd"                      |  2 +-
 .../_drive_commands.gd"                            |  2 +-
 .../_drive_grid.gd"                                |  2 +-
 .../_drive_kojo_buttons.gd"                        |  2 +-
 .../_drive_mixed_grid.gd"                          |  2 +-
 .../_drive_print_wait.gd"                          |  2 +-
 .../character_panel.gd"                            |  2 +-
 .../check_event_flow.gd"                           | 43 +++++++++++++++++-----
 .../check_foundations.gd"                          |  2 +-
 .../day_start.gd"                                  |  2 +-
 .../era.gd"                                        |  8 +++-
 .../era_event.gd"                                  |  6 +--
 .../new_game.gd"                                   |  2 +-
 .../show_component.gd"                             |  2 +-
 .../talent_select.gd"                              |  2 +-
 .../type_a_new_game.gd"                            |  2 +-
 .../type_a_title.gd"                               |  2 +-
 21 files changed, 60 insertions(+), 33 deletions(-)

=== Full diff (U10) ===
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_demo_character_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_demo_character_event.gd"
index d7984c1..b27ab70 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_demo_character_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_demo_character_event.gd"
@@ -1,17 +1,17 @@
 extends EraEvent
 ## 角色系统第 1 步演示：生命组件 + 关系组件 + 称呼。
 ##
 ## 跑法：F6 打开 tests/demo_character.tscn
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	_ensure_characters()
 	var daughter := Era.character(&"daughter")
 	var player := Era.character(&"player")
 	if daughter == null or player == null:
 		Era.print("角色创建失败。")
 		await Era.wait_key()
 		return null
 
 	var life := daughter.get_component(LifeComponent) as LifeComponent
 	var daughter_relations := daughter.get_component(RelationComponent) as RelationComponent
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_demo_grid_b_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_demo_grid_b_event.gd"
index 04378a6..1f3b283 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_demo_grid_b_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_demo_grid_b_event.gd"
@@ -9,21 +9,21 @@ extends EraEvent
 ## 互斥逻辑在内容里算（幼稚 / 早熟互相禁用）。
 
 const DATA := preload("res://tests/_demo_grid_options.gd")
 const TALENT_A := 900
 const TALENT_B := 901
 
 var _selected: Dictionary = {}
 var _grid: Variant = null
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	for index in DATA.SELECTED_INDEXES:
 		_selected[int(index)] = true
 
 	while true:
 		Era.clear()
 		Era.print("多列选择格子（常驻块 + 局部更新）", Era.Style.DIM)
 		Era.print_gap()
 
 		Era.begin_grid(3)
 		for i in DATA.TEXTS.size():
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_demo_kojo_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_demo_kojo_event.gd"
index 0d723d4..570718f 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_demo_kojo_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_demo_kojo_event.gd"
@@ -1,20 +1,20 @@
 extends EraEvent
 ## 演示：带按钮的口上 + sync 口上 + 口上开关/计数。
 ##
 ## 跑法：F6 打开 tests/demo_kojo.tscn
 
 const PLAYER_PROTO := preload("res://content/characters/prototypes/玩家.tres")
 const DAUGHTER_PROTO := preload("res://content/characters/prototypes/女儿.tres")
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	_ensure_characters()
 	var daughter := Era.character(&"daughter")
 	var player := Era.character(&"player")
 	if daughter == null or player == null:
 		Era.print("角色创建失败。")
 		await Era.wait_key()
 		return null
 
 	var kojo := daughter.get_component(KojoComponent) as KojoComponent
 	var daughter_relations := daughter.get_component(RelationComponent) as RelationComponent
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_demo_mixed_grid_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_demo_mixed_grid_event.gd"
index cd4399f..14eb832 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_demo_mixed_grid_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_demo_mixed_grid_event.gd"
@@ -11,21 +11,21 @@ extends EraEvent
 
 var _name := "小灯"
 var _age := 18
 var _life := LifeComponent.new()
 var _energy := EnergyComponent.new()
 var _mood := "平静"
 var _early_sleep := false
 var _exercise := false
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	while true:
 		Era.clear()
 		Era.print("混合格子：文字 + 按钮 + 选择项", Era.Style.DIM)
 		Era.print_gap()
 
 		Era.begin_grid(3)
 		# 表头（纯文字格）
 		Era.print_cell("名字", Era.Style.DIM, HORIZONTAL_ALIGNMENT_CENTER)
 		Era.print_cell("年龄", Era.Style.DIM, HORIZONTAL_ALIGNMENT_CENTER)
 		Era.print_cell("生命 / 精力", Era.Style.DIM, HORIZONTAL_ALIGNMENT_CENTER)
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_demo_relations_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_demo_relations_event.gd"
index 53597de..804b85c 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_demo_relations_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_demo_relations_event.gd"
@@ -1,17 +1,17 @@
 extends EraEvent
 ## 角色系统第 2 步演示：.tres 角色原型 + 多角色关系矩阵。
 ##
 ## 跑法：F6 打开 tests/demo_relations.tscn
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	_ensure_characters()
 	var player := Era.character(&"player")
 	var daughter := Era.character(&"daughter")
 	var maid := Era.character(&"maid")
 	if player == null or daughter == null or maid == null:
 		Era.print("角色创建失败。")
 		await Era.wait_key()
 		return null
 
 	var player_relations := player.get_component(RelationComponent) as RelationComponent
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_drive_commands.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_drive_commands.gd"
index de894d6..2271491 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_drive_commands.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_drive_commands.gd"
@@ -1,14 +1,14 @@
 extends EraEvent
 ## 校验用事件：打印、分割线、空行、按钮、等待选择、改角色组件、等任意键。
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	var tester := Character.new()
 	tester.id = &"test_character"
 	tester.add_component(LifeComponent.new())
 	Era.state.character_book.add(tester)
 
 	Era.print("第一行")
 	Era.print("红字", Era.Style.DANGER)
 	Era.print_rule()
 	Era.print_gap()
 	Era.print_button("甲", 0)
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_drive_grid.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_drive_grid.gd"
index 7270b4e..604873b 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_drive_grid.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_drive_grid.gd"
@@ -1,14 +1,14 @@
 extends EraEvent
 ## 校验用事件：建一块格子，等动作项，然后写回测试角色的组件。
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	var tester := Character.new()
 	tester.id = &"test_character"
 	var life := LifeComponent.new()
 	var talents := TalentListComponent.new()
 	tester.add_component(life)
 	tester.add_component(talents)
 	Era.state.character_book.add(tester)
 
 	Era.clear()
 	Era.begin_grid(3)
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_drive_kojo_buttons.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_drive_kojo_buttons.gd"
index a98fe2c..4641dd0 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_drive_kojo_buttons.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_drive_kojo_buttons.gd"
@@ -1,18 +1,18 @@
 extends EraEvent
 ## 校验用事件：跑一次带按钮的口上，把返回值写进状态。
 
 const PLAYER_PROTO := preload("res://content/characters/prototypes/玩家.tres")
 const DAUGHTER_PROTO := preload("res://content/characters/prototypes/女儿.tres")
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	var player := PLAYER_PROTO.spawn(&"player")
 	var daughter := DAUGHTER_PROTO.spawn(&"daughter")
 	var book := CharacterBook.new()
 	book.add(player)
 	book.add(daughter)
 	book.protagonist_id = &"player"
 	Era.state.character_book = book
 
 	Era.clear()
 	var picked: int = await Era.kojo(daughter, &"act_cute", {"partner": player})
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_drive_mixed_grid.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_drive_mixed_grid.gd"
index 2ab482e..7f04e94 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_drive_mixed_grid.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_drive_mixed_grid.gd"
@@ -1,14 +1,14 @@
 extends EraEvent
 ## 校验用事件：混合格子（文字格 + 选择项 + 动作项）→ 写回测试角色的组件。
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	var tester := Character.new()
 	tester.id = &"test_character"
 	var life := LifeComponent.new()
 	var talents := TalentListComponent.new()
 	tester.add_component(life)
 	tester.add_component(talents)
 	Era.state.character_book.add(tester)
 
 	Era.clear()
 	Era.begin_grid(2)
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_drive_print_wait.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_drive_print_wait.gd"
index 5807a89..66eb017 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/_drive_print_wait.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/_drive_print_wait.gd"
@@ -1,8 +1,8 @@
 extends EraEvent
 ## 校验用事件：print_wait = 打印 + 等键。
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	await Era.print_wait("等待行", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
 	Era.print("按键后继续。")
 	await Era.wait_key()
 	return null
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/character_panel.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/character_panel.gd"
index 5cf089e..ced863c 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/character_panel.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/character_panel.gd"
@@ -1,21 +1,21 @@
 extends EraEvent
 ## CharacterPanel, 角色状态面板
 ##
 ## 用混合格子把女儿的组件值摆出来（生命/体力/精力/好感/天赋）；
 ## 按钮直接调用组件方法，打印“现在”后按键重画，能直观看到组件数据变化。
 ## 面板内部用 while 保留局部变量循环；离开面板时才返回 DayStart。
 
 const DayStartPath := "res://content/events/day_start.gd"
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
 	var daughter := Era.state.character_book.find(&"daughter")
 	if daughter == null:
 		Era.clear()
 		Era.print("找不到女儿角色。", Era.Style.DANGER)
 		await Era.wait_key()
 		return null
 
 	var life := daughter.get_component(LifeComponent) as LifeComponent
 	var stamina := daughter.get_component(StaminaComponent) as StaminaComponent
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/check_event_flow.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/check_event_flow.gd"
index 6c6aa9a..d50bef0 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/check_event_flow.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/check_event_flow.gd"
@@ -1,92 +1,115 @@
 extends Node
 ## CheckEventFlow, 校验两种事件语义
 ##
 ## - 重启：return get_script() 会新建事件实例，局部变量重置，Era.state/角色数据保留；
 ## - 局部循环：while 保留同一事件实例，局部变量继续累加。
 ## 用真实 Era.input() 驱动，不直接调用 run()。
 ## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。
 
 class RestartEvent extends EraEvent:
-	func run() -> GDScript:
+	func run(context: EventContext) -> GDScript:
 		var local_count := 0
 		local_count += 1
 		Era.clear()
 		Era.print("restart_local=%d" % local_count)
+		Era.print("ctx_player=%s" % context.player.id)
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
-	func run() -> GDScript:
+	func run(context: EventContext) -> GDScript:
 		var local_count := 0
 		while true:
 			local_count += 1
 			Era.clear()
 			Era.print("loop_local=%d" % local_count)
+			Era.print("loop_player=%s" % context.player.id)
+			Era.print("ctx_char=%s" % context.character(&"daughter").id)
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
+	# 第二个角色：LoopEvent 启动前把主角改绑到它，验证引擎每事件重新打包 context
+	var you := Character.new()
+	you.id = &"player"
+	you.display_name = "你"
+	you.callname = "你"
+	book.add(you)
 	Era.state.character_book = book
 
 	# 1) 重启：局部计数两次都是 1，生命值从 100 保留为 90
 	Era.start(RestartEvent)
-	await _wait_rows(2, 120)
+	await _wait_rows(3, 120)
 	var first := _row_texts()
-	if first.size() != 2 or first[0] != "restart_local=1":
+	if first.size() != 3 or first[0] != "restart_local=1":
 		failures.append("重启第一次应打印 restart_local=1，实际 %s" % str(first))
+	if not first.has("ctx_player=daughter"):
+		failures.append("重启第一次 context 主角应为 daughter，实际 %s" % str(first))
 	Era._choose(0)
-	await _wait_rows(2, 120)
+	await _wait_rows(3, 120)
 	await get_tree().process_frame
 	var second := _row_texts()
-	if second.size() != 2 or second[0] != "restart_local=1":
+	if second.size() != 3 or second[0] != "restart_local=1":
 		failures.append("重启后局部计数应重置为 1，实际 %s" % str(second))
+	if not second.has("ctx_player=daughter"):
+		failures.append("重启后 context 主角仍应为 daughter，实际 %s" % str(second))
 	if daughter.get_component(LifeComponent) == null or (daughter.get_component(LifeComponent) as LifeComponent).value != 90:
 		failures.append("重启应保留生命值 90")
 	if not second.has("life=90"):
 		failures.append("重启后生命行应为 life=90，实际 %s" % str(second))
 
 	# 2) 局部循环：同一实例，计数从 1 累加到 2
+	# 启动前改绑主角：引擎若真的每事件重新打包 context，LoopEvent 读到的应是 player
+	book.protagonist_id = &"player"
 	Era.start(LoopEvent)
-	await _wait_rows(2, 120)
+	await _wait_rows(3, 120)
 	var loop_first := _row_texts()
-	if loop_first.size() != 1 or loop_first[0] != "loop_local=1":
+	if loop_first.size() != 3 or loop_first[0] != "loop_local=1":
 		failures.append("循环第一次应打印 loop_local=1，实际 %s" % str(loop_first))
+	if not loop_first.has("loop_player=player"):
+		failures.append("循环第一次 context 主角应为改绑后的 player，实际 %s" % str(loop_first))
+	if not loop_first.has("ctx_char=daughter"):
+		failures.append("循环第一次 context 应能按 id 查到 daughter，实际 %s" % str(loop_first))
 	Era._choose(0)
-	await _wait_rows(1, 120)
+	await _wait_rows(3, 120)
 	await get_tree().process_frame
 	var loop_second := _row_texts()
-	if loop_second.is_empty() or loop_second[0] != "loop_local=2":
+	if loop_second.size() != 3 or loop_second[0] != "loop_local=2":
 		failures.append("循环应保留局部变量累加到 2，实际 %s" % str(loop_second))
+	if not loop_second.has("loop_player=player"):
+		failures.append("循环第二次 context 主角应为 player，实际 %s" % str(loop_second))
+	if not loop_second.has("ctx_char=daughter"):
+		failures.append("循环第二次 context 应能按 id 查到 daughter，实际 %s" % str(loop_second))
 
 	if failures.is_empty():
 		print("CHECK OK")
 		get_tree().quit(0)
 	else:
 		print("CHECK FAIL")
 		for failure in failures:
 			print("  - ", failure)
 		get_tree().quit(1)
 
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/check_foundations.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/check_foundations.gd"
index bf2544a..46ae042 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/check_foundations.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/check_foundations.gd"
@@ -31,21 +31,21 @@ func _ready() -> void:
 
 	# 2) 状态：角色表存在且初始为空
 	var state: Resource = StateScript.new()
 	if state.character_book == null:
 		failures.append("GameState.character_book 不应为 null")
 	elif state.character_book.characters.size() != 0:
 		failures.append("GameState.character_book 初始应为空")
 
 	# 3) 事件基类：run() 返回 null（流程结束）
 	var event: RefCounted = EventScript.new()
-	var next: Variant = event.run()
+	var next: Variant = event.run(null)
 	if next != null:
 		failures.append("EraEvent 基类 run() 应返回 null")
 
 	if failures.is_empty():
 		print("CHECK OK")
 		get_tree().quit(0)
 	else:
 		print("CHECK FAIL")
 		for failure in failures:
 			print("  - ", failure)
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/day_start.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/day_start.gd"
index 0f343b6..da0e7f2 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/day_start.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/day_start.gd"
@@ -7,21 +7,21 @@ extends EraEvent
 ## - 好感：女儿的 RelationComponent；
 ## - 天赋：女儿的 TalentListComponent。
 ##
 ## 动作改组件 → 打印“现在” → 按键后重画本屏（面板显示更新后的数值）。
 
 const Title := preload("res://content/events/type_a_title.gd")
 const CharacterPanel := preload("res://content/events/character_panel.gd")
 const ShowComponent = preload("uid://cjiyuvnnqpklg")
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
 	var daughter := Era.state.character_book.find(&"daughter")
 	if daughter == null:
 		Era.clear()
 		Era.print("找不到女儿角色。", Era.Style.DANGER)
 		await Era.wait_key()
 		return null
 
 	var stamina := daughter.get_component(StaminaComponent) as StaminaComponent
 	var energy := daughter.get_component(EnergyComponent) as EnergyComponent
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/era.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/era.gd"
index 824081b..9675d15 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/era.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/era.gd"
@@ -2,21 +2,21 @@ extends Node
 ## Era, 引擎入口
 ##
 ## 此类是自动加载单例。
 ## [br][br]
 ## 常驻壳 + 命令 API + 输入等待 + 事件循环。
 ## [br][br]
 ## 内容脚本的写法：
 ## [codeblock]
 ## extends EraEvent
 ##
-## func run() -> GDScript:
+## func run(context: EventContext) -> GDScript:
 ##     Era.print("你醒了过来。")
 ##     Era.print_button("起床", 0)
 ##     var picked: int = await Era.input()
 ##     var 女儿 := Era.state.character_book.find(&"daughter")
 ##     var 生命 := 女儿.get_component(LifeComponent) as LifeComponent
 ##     生命.hurt(10)
 ##     return null
 ## [/codeblock]
 ## 事件返回下一个事件脚本就继续跑，返回 [code]null[/code] 就结束。
 ## 没有 goto，也不换场景。
@@ -363,21 +363,25 @@ func _protagonist() -> Character:
 		return null
 	return state.character_book.find(state.character_book.protagonist_id)
 
 
 # ---------- 内部 ----------
 
 func _run_flow(first_script: GDScript) -> void:
 	var next_script: GDScript = first_script
 	while next_script != null:
 		var event: Variant = next_script.new()
-		var result: Variant = await event.run()
+		# 每事件一包：主角中途换绑后，下一个事件拿到新值。
+		var context := EventContext.new()
+		context.state = state
+		context.player = _protagonist()
+		var result: Variant = await event.run(context)
 		next_script = result as GDScript
 	flow_finished.emit()
 
 
 func _print_text(text: String, style: Style, align: HorizontalAlignment) -> void:
 	var row: Variant = TEXT_ROW_SCENE.instantiate()
 	_screen.append_row(row)
 	row.setup(text, _style_color(style), align)
 
 
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/era_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/era_event.gd"
index cb9e578..83188d0 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/era_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/era_event.gd"
@@ -1,14 +1,14 @@
 class_name EraEvent
 extends RefCounted
 ## EraEvent, 事件内容的基类
 ## 
 ## 每个事件脚本 extends EraEvent，基本写法如下:
 ## [codeblock]
-## func run() -> GDScript：
+## func run(context: EventContext) -> GDScript：
 ##   return 下一个事件的脚本   # 引擎接着跑它
 ##   return null             # 如果返回null，则流程结束
 ## [/codeblock]
-## 这里什么逻辑都不放，只规定形状。
+## 这里什么逻辑都不放，只规定形状。context 由引擎在执行前打包。
 
-func run() -> GDScript:
+func run(_context: EventContext) -> GDScript:
 	return null
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/new_game.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/new_game.gd"
index 8fda02c..59337f3 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/new_game.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/new_game.gd"
@@ -1,20 +1,20 @@
 extends EraEvent
 ## NewGame, 开始新游戏
 ##
 ## 流程：装配角色 → 挂载角色创建页（名字/年龄）→ 写女儿角色 → 等键 → 选天赋。
 
 const CHARACTER_CREATE := preload("res://content/screens/character_create.tscn")
 const TalentSelect := preload("res://content/events/talent_select.gd")
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	# 先装配角色：页面输入需要女儿已有的名字/年龄。
 	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
 	Era.clear()
 	Era.print("先创建你的角色。")
 	Era.print_gap()
 
 	var daughter := Era.state.character_book.find(&"daughter")
 	var age_component := daughter.get_component(AgeComponent) as AgeComponent if daughter != null else null
 	var result: Variant = await Era.show_screen(CHARACTER_CREATE, {
 		"display_name": daughter.display_name if daughter != null else "",
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/show_component.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/show_component.gd"
index a01dfb5..5c83eae 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/show_component.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/show_component.gd"
@@ -1,21 +1,21 @@
 extends EraEvent
 ## ShowComponent, 开发用：列出女儿身上的全部组件和字段
 ##
 ## 遍历 [code]daughter.components[/code]；每个组件用 [method CharacterComponent.to_fields]
 ## 收字段（白名单类型），用混合格子按「组件 / 字段 / 值」三列显示。
 ## 枚举值会尽量显示成英文名（如 DISGUST / NORMAL / BUDDING / AROUSED）。
 
 
 const DayStart = preload("uid://c0iwltmcqj80g")
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
 	var daughter := Era.state.character_book.find(&"daughter")
 	
 	Era.clear()
 	if daughter == null:
 		Era.print("找不到女儿角色。", Era.Style.DANGER)
 		await Era.wait_key()
 		return null
 
 	Era.print_rule()
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/talent_select.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/talent_select.gd"
index 0e9f5b3..87f3089 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/talent_select.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/talent_select.gd"
@@ -18,21 +18,21 @@ const TALENTS := [
 	preload("res://resources/talent_resource/易漏尿.tres"),
 	
 ]
 const NewGame := preload("res://content/events/new_game.gd")
 const DayStart := preload("res://content/events/day_start.gd")
 const TypeANewGame = preload("uid://ccidr3i8rgbkb")
 
 var _grid: Variant = null
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
 	Era.clear()
 	Era.print_rule()
 	Era.print("天 赋", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
 	Era.print("可多选；互斥的天赋会变灰。", Era.Style.DIM)
 	Era.print_rule()
 
 	# 格子里的编号 = 列表序号 + 1（1~N），跟旧 first_game.tscn 的 [ 1] [ 2] ... 对齐。
 	Era.begin_grid(3)
 	for i in TALENTS.size():
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/type_a_new_game.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/type_a_new_game.gd"
index 73b4ae3..615db3d 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/type_a_new_game.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/type_a_new_game.gd"
@@ -1,13 +1,13 @@
 extends EraEvent
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	
 	Era.clear()
 	Era.print_rule()
 	await Era.print_wait("叮咚~你家的门铃忽然间响起")
 	await Era.print_wait("你感到疑惑。因为你不记得这个时间还有谁会来拜访自己")
 	await Era.print_wait("你走向门，通过猫眼观察外面")
 	await Era.print_wait("门外是一个较小的女孩，看上去只有8，9岁的样子")
 	await Era.print_wait("你想起来了，她是你的--")
 	
 	Era.print_button("亲生女儿", 0)
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/type_a_title.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/type_a_title.gd"
index a5215f2..fc40afe 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-2/type_a_title.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-2/type_a_title.gd"
@@ -20,21 +20,21 @@ const ART_LINES := [
 	" █████╗  ██████╔╝███████║       ██║  ██║███████║██║   ██║██║  ███╗███████║   ██║   █████╗  ██████╔╝",
 	" ██╔══╝  ██╔══██╗██╔══██║       ██║  ██║██╔══██║██║   ██║██║   ██║██╔══██║   ██║   ██╔══╝  ██╔══██╗",
 	" ███████╗██║  ██║██║  ██║       ██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║  ██║   ██║   ███████╗██║  ██║",
 	" ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝",
 ]
 
 ## 分割线用的符号（旧 start.tscn 用的是 ■）。
 const RULE_CHAR := "■"
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	Era.clear()
 	Era.print_gap(5)
 	Era.print_rule(RULE_CHAR)
 	Era.print_gap(2)
 	for line in ART_LINES:
 		Era.print("[color=%s]%s[/color]" % [ART_COLOR, line], Era.Style.NORMAL, HORIZONTAL_ALIGNMENT_CENTER)
 	Era.print_gap()
 	Era.print_button("开始游戏", 1, HORIZONTAL_ALIGNMENT_CENTER)
 	Era.print_button("继续游戏", 2, HORIZONTAL_ALIGNMENT_CENTER)
 	Era.print_button("关于游戏", 3, HORIZONTAL_ALIGNMENT_CENTER)
