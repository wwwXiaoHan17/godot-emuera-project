=== Task 3 diff（before → after，git diff --no-index；含 .uid）===
 .../_demo_character_event.gd"                                       | 4 ++--
 .../_demo_kojo_event.gd"                                            | 4 ++--
 .../_demo_relations_event.gd"                                       | 6 +++---
 .../character_panel.gd"                                             | 2 +-
 .../check_event_flow.gd"                                            | 2 +-
 .../day_start.gd"                                                   | 2 +-
 .../new_game.gd"                                                    | 2 +-
 .../show_component.gd"                                              | 2 +-
 .../talent_select.gd"                                               | 2 +-
 9 files changed, 13 insertions(+), 13 deletions(-)

=== Full diff (U10) ===
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/_demo_character_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/_demo_character_event.gd"
index b27ab70..fe5d43c 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/_demo_character_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/_demo_character_event.gd"
@@ -1,20 +1,20 @@
 extends EraEvent
 ## 角色系统第 1 步演示：生命组件 + 关系组件 + 称呼。
 ##
 ## 跑法：F6 打开 tests/demo_character.tscn
 
 
 func run(context: EventContext) -> GDScript:
 	_ensure_characters()
-	var daughter := Era.character(&"daughter")
-	var player := Era.character(&"player")
+	var daughter := context.character(&"daughter")
+	var player := context.character(&"player")
 	if daughter == null or player == null:
 		Era.print("角色创建失败。")
 		await Era.wait_key()
 		return null
 
 	var life := daughter.get_component(LifeComponent) as LifeComponent
 	var daughter_relations := daughter.get_component(RelationComponent) as RelationComponent
 	var player_relations := player.get_component(RelationComponent) as RelationComponent
 
 	while true:
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/_demo_kojo_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/_demo_kojo_event.gd"
index 570718f..827573b 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/_demo_kojo_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/_demo_kojo_event.gd"
@@ -2,22 +2,22 @@ extends EraEvent
 ## 演示：带按钮的口上 + sync 口上 + 口上开关/计数。
 ##
 ## 跑法：F6 打开 tests/demo_kojo.tscn
 
 const PLAYER_PROTO := preload("res://content/characters/prototypes/玩家.tres")
 const DAUGHTER_PROTO := preload("res://content/characters/prototypes/女儿.tres")
 
 
 func run(context: EventContext) -> GDScript:
 	_ensure_characters()
-	var daughter := Era.character(&"daughter")
-	var player := Era.character(&"player")
+	var daughter := context.character(&"daughter")
+	var player := context.character(&"player")
 	if daughter == null or player == null:
 		Era.print("角色创建失败。")
 		await Era.wait_key()
 		return null
 
 	var kojo := daughter.get_component(KojoComponent) as KojoComponent
 	var daughter_relations := daughter.get_component(RelationComponent) as RelationComponent
 	var daily_enabled := true
 
 	while true:
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/_demo_relations_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/_demo_relations_event.gd"
index 804b85c..4743df8 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/_demo_relations_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/_demo_relations_event.gd"
@@ -1,21 +1,21 @@
 extends EraEvent
 ## 角色系统第 2 步演示：.tres 角色原型 + 多角色关系矩阵。
 ##
 ## 跑法：F6 打开 tests/demo_relations.tscn
 
 
 func run(context: EventContext) -> GDScript:
 	_ensure_characters()
-	var player := Era.character(&"player")
-	var daughter := Era.character(&"daughter")
-	var maid := Era.character(&"maid")
+	var player := context.character(&"player")
+	var daughter := context.character(&"daughter")
+	var maid := context.character(&"maid")
 	if player == null or daughter == null or maid == null:
 		Era.print("角色创建失败。")
 		await Era.wait_key()
 		return null
 
 	var player_relations := player.get_component(RelationComponent) as RelationComponent
 	var daughter_relations := daughter.get_component(RelationComponent) as RelationComponent
 	var characters: Array[Character] = [player, daughter, maid]
 
 	while true:
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/character_panel.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/character_panel.gd"
index ced863c..2a3d7c2 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/character_panel.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/character_panel.gd"
@@ -3,21 +3,21 @@ extends EraEvent
 ##
 ## 用混合格子把女儿的组件值摆出来（生命/体力/精力/好感/天赋）；
 ## 按钮直接调用组件方法，打印“现在”后按键重画，能直观看到组件数据变化。
 ## 面板内部用 while 保留局部变量循环；离开面板时才返回 DayStart。
 
 const DayStartPath := "res://content/events/day_start.gd"
 
 
 func run(context: EventContext) -> GDScript:
 	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
-	var daughter := Era.state.character_book.find(&"daughter")
+	var daughter := context.character(&"daughter")
 	if daughter == null:
 		Era.clear()
 		Era.print("找不到女儿角色。", Era.Style.DANGER)
 		await Era.wait_key()
 		return null
 
 	var life := daughter.get_component(LifeComponent) as LifeComponent
 	var stamina := daughter.get_component(StaminaComponent) as StaminaComponent
 	var energy := daughter.get_component(EnergyComponent) as EnergyComponent
 	var relations := daughter.get_component(RelationComponent) as RelationComponent
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/check_event_flow.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/check_event_flow.gd"
index d50bef0..5a7ac06 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/check_event_flow.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/check_event_flow.gd"
@@ -6,21 +6,21 @@ extends Node
 ## 用真实 Era.input() 驱动，不直接调用 run()。
 ## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。
 
 class RestartEvent extends EraEvent:
 	func run(context: EventContext) -> GDScript:
 		var local_count := 0
 		local_count += 1
 		Era.clear()
 		Era.print("restart_local=%d" % local_count)
 		Era.print("ctx_player=%s" % context.player.id)
-		var daughter := Era.character(&"daughter")
+		var daughter := context.character(&"daughter")
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/day_start.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/day_start.gd"
index da0e7f2..0c5ac08 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/day_start.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/day_start.gd"
@@ -9,21 +9,21 @@ extends EraEvent
 ##
 ## 动作改组件 → 打印“现在” → 按键后重画本屏（面板显示更新后的数值）。
 
 const Title := preload("res://content/events/type_a_title.gd")
 const CharacterPanel := preload("res://content/events/character_panel.gd")
 const ShowComponent = preload("uid://cjiyuvnnqpklg")
 
 
 func run(context: EventContext) -> GDScript:
 	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
-	var daughter := Era.state.character_book.find(&"daughter")
+	var daughter := context.character(&"daughter")
 	if daughter == null:
 		Era.clear()
 		Era.print("找不到女儿角色。", Era.Style.DANGER)
 		await Era.wait_key()
 		return null
 
 	var stamina := daughter.get_component(StaminaComponent) as StaminaComponent
 	var energy := daughter.get_component(EnergyComponent) as EnergyComponent
 	var age_component := daughter.get_component(AgeComponent) as AgeComponent
 	var relations := daughter.get_component(RelationComponent) as RelationComponent
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/new_game.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/new_game.gd"
index 59337f3..9cab224 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/new_game.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/new_game.gd"
@@ -7,21 +7,21 @@ const CHARACTER_CREATE := preload("res://content/screens/character_create.tscn")
 const TalentSelect := preload("res://content/events/talent_select.gd")
 
 
 func run(context: EventContext) -> GDScript:
 	# 先装配角色：页面输入需要女儿已有的名字/年龄。
 	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
 	Era.clear()
 	Era.print("先创建你的角色。")
 	Era.print_gap()
 
-	var daughter := Era.state.character_book.find(&"daughter")
+	var daughter := context.character(&"daughter")
 	var age_component := daughter.get_component(AgeComponent) as AgeComponent if daughter != null else null
 	var result: Variant = await Era.show_screen(CHARACTER_CREATE, {
 		"display_name": daughter.display_name if daughter != null else "",
 		"age": age_component.value if age_component != null else 18,
 	})
 	var data: Dictionary = result as Dictionary
 	var display_name := str(data.get("display_name", ""))
 	var age := int(data.get("age", 18))
 
 	if daughter != null:
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/show_component.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/show_component.gd"
index 5c83eae..070f9b6 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/show_component.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/show_component.gd"
@@ -3,21 +3,21 @@ extends EraEvent
 ##
 ## 遍历 [code]daughter.components[/code]；每个组件用 [method CharacterComponent.to_fields]
 ## 收字段（白名单类型），用混合格子按「组件 / 字段 / 值」三列显示。
 ## 枚举值会尽量显示成英文名（如 DISGUST / NORMAL / BUDDING / AROUSED）。
 
 
 const DayStart = preload("uid://c0iwltmcqj80g")
 
 func run(context: EventContext) -> GDScript:
 	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
-	var daughter := Era.state.character_book.find(&"daughter")
+	var daughter := context.character(&"daughter")
 	
 	Era.clear()
 	if daughter == null:
 		Era.print("找不到女儿角色。", Era.Style.DANGER)
 		await Era.wait_key()
 		return null
 
 	Era.print_rule()
 	Era.print("组件一览：%s" % daughter.display_name, Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
 	Era.print("共 %d 个组件" % daughter.components.size(), Era.Style.DIM)
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/talent_select.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/talent_select.gd"
index 87f3089..549c997 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-3/talent_select.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-3/talent_select.gd"
@@ -49,21 +49,21 @@ func run(context: EventContext) -> GDScript:
 	match await Era.input():
 		9998:
 			# 把格子里的选中项（编号 = 序号 + 1）还原成天赋名，写进女儿的天赋组件。
 			var talents: Array[StringName] = []
 			var names: Array[String] = []
 			for id in _grid.get_selected():
 				var talent: TalentData = TALENTS[int(id) - 1]
 				talents.append(talent.talent_name)
 				names.append(str(talent.display_name))
 
-			var daughter := Era.state.character_book.find(&"daughter")
+			var daughter := context.character(&"daughter")
 			if daughter != null:
 				var talent_component := daughter.get_component(TalentListComponent) as TalentListComponent
 				if talent_component != null:
 					talent_component.set_talents(talents)
 
 			Era.print(
 				"已选天赋：%s" % ("、".join(names) if not names.is_empty() else "（无）"),
 				Era.Style.ACCENT
 			)
 			Era.print("按任意键或点击进入第 1 天。", Era.Style.DIM)
