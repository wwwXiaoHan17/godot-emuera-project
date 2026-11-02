=== FINAL whole-branch diff（最早快照 → 当前；event_context.gd 为新增）===
 .../README.md"                                     |  1 +
 .../_demo_character_event.gd"                      |  6 +--
 .../_demo_grid_b_event.gd"                         |  2 +-
 .../_demo_kojo_event.gd"                           |  6 +--
 .../_demo_mixed_grid_event.gd"                     |  2 +-
 .../_demo_relations_event.gd"                      |  8 ++--
 .../_drive_commands.gd"                            |  2 +-
 .../_drive_grid.gd"                                |  2 +-
 .../_drive_kojo_buttons.gd"                        |  2 +-
 .../_drive_mixed_grid.gd"                          |  2 +-
 .../_drive_print_wait.gd"                          |  2 +-
 .../character-system-design.md"                    | 12 +++---
 .../character_panel.gd"                            |  4 +-
 .../check_day_start.gd"                            | 31 +++++++++++----
 .../check_event_flow.gd"                           | 45 ++++++++++++++++------
 .../check_foundations.gd"                          |  2 +-
 .../check_kojo.gd"                                 |  6 +++
 .../check_talent_select.gd"                        | 21 +++++++++-
 .../check_title.gd"                                | 20 +++++-----
 .../day_start.gd"                                  |  4 +-
 .../engine-v1-design.md"                           | 23 +++++++----
 .../era.gd"                                        | 22 ++++++-----
 .../era_event.gd"                                  |  6 +--
 .../event_context.gd"                              | 15 ++++++++
 .../game_state.gd"                                 |  4 +-
 .../kojo_context.gd"                               |  9 ++---
 .../new_game.gd"                                   |  4 +-
 .../show_component.gd"                             |  4 +-
 .../talent_select.gd"                              |  4 +-
 .../type_a_new_game.gd"                            |  2 +-
 .../type_a_title.gd"                               |  2 +-
 31 files changed, 183 insertions(+), 92 deletions(-)

=== Full diff (U10) ===
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/README.md" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/README.md"
index dd171de..86d9ffc 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/README.md"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/README.md"
@@ -37,13 +37,14 @@
 - 角色系统设计（定稿）：`docs/character-system-design.md`
 - 设计边界 spec：`docs/superpowers/specs/2026-10-25-engine-boundaries-design.md`
 - 执行计划：`docs/superpowers/plans/2026-10-25-engine-boundaries.md`
 - 第 1 步实现计划：`docs/superpowers/plans/2026-10-20-engine-v1-step1.md`
 - 分步完成记录：`docs/step-1-report.md` … `docs/step-14-report.md`
 - 实验证据：`experiment/README.md`、`experiment/shots/`
 
 ## 说明
 
 - `GameState` 现在只装 `character_book`；角色名字/年龄/关系/数值都在 `Character` 及其可选组件里。
+- 统一口径：**拿数据用 `context`（人、主角、状态），做事用 `Era.*`（print / input / kojo / show_screen）**；事件与口上函数从入参 context 取人（`context.character(id)` / `context.player`），不直接翻 `Era.state.character_book`。
 - 代码标识符和程序 ID 用英文（`player/daughter/maid/father`、`character_book`）；玩家可见文本保持中文。
 - 现有 **17** 个 `check_*.tscn` 全部 `CHECK OK` 是当前验收基线。
 - 旧参考场景（`start.tscn`）归档在 `experiment/legacy/start.tscn`；旧的 `first_game.tscn`/`main.tscn` 等已删除。
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_demo_character_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_demo_character_event.gd"
index d7984c1..fe5d43c 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_demo_character_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_demo_character_event.gd"
@@ -1,20 +1,20 @@
 extends EraEvent
 ## 角色系统第 1 步演示：生命组件 + 关系组件 + 称呼。
 ##
 ## 跑法：F6 打开 tests/demo_character.tscn
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_demo_grid_b_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_demo_grid_b_event.gd"
index 04378a6..1f3b283 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_demo_grid_b_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_demo_grid_b_event.gd"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_demo_kojo_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_demo_kojo_event.gd"
index 0d723d4..827573b 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_demo_kojo_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_demo_kojo_event.gd"
@@ -1,23 +1,23 @@
 extends EraEvent
 ## 演示：带按钮的口上 + sync 口上 + 口上开关/计数。
 ##
 ## 跑法：F6 打开 tests/demo_kojo.tscn
 
 const PLAYER_PROTO := preload("res://content/characters/prototypes/玩家.tres")
 const DAUGHTER_PROTO := preload("res://content/characters/prototypes/女儿.tres")
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_demo_mixed_grid_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_demo_mixed_grid_event.gd"
index cd4399f..14eb832 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_demo_mixed_grid_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_demo_mixed_grid_event.gd"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_demo_relations_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_demo_relations_event.gd"
index 53597de..4743df8 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_demo_relations_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_demo_relations_event.gd"
@@ -1,21 +1,21 @@
 extends EraEvent
 ## 角色系统第 2 步演示：.tres 角色原型 + 多角色关系矩阵。
 ##
 ## 跑法：F6 打开 tests/demo_relations.tscn
 
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_drive_commands.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_drive_commands.gd"
index de894d6..2271491 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_drive_commands.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_drive_commands.gd"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_drive_grid.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_drive_grid.gd"
index 7270b4e..604873b 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_drive_grid.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_drive_grid.gd"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_drive_kojo_buttons.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_drive_kojo_buttons.gd"
index a98fe2c..4641dd0 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_drive_kojo_buttons.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_drive_kojo_buttons.gd"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_drive_mixed_grid.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_drive_mixed_grid.gd"
index 2ab482e..7f04e94 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_drive_mixed_grid.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_drive_mixed_grid.gd"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_drive_print_wait.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_drive_print_wait.gd"
index 5807a89..66eb017 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/_drive_print_wait.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/_drive_print_wait.gd"
@@ -1,8 +1,8 @@
 extends EraEvent
 ## 校验用事件：print_wait = 打印 + 等键。
 
-func run() -> GDScript:
+func run(context: EventContext) -> GDScript:
 	await Era.print_wait("等待行", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
 	Era.print("按键后继续。")
 	await Era.wait_key()
 	return null
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/character-system-design.md" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/character-system-design.md"
index 059a4f9..277afde 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/character-system-design.md"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/character-system-design.md"
@@ -92,37 +92,39 @@ var result: Variant = await Era.show_screen(CHARACTER_CREATE, {
 })
 ```
 
 - `EraScreenPage.configure(data)` 在页面入树前调用；
 - 页面只使用 `configure()` 输入，不读取或修改 `Era.state`；
 - 完成后发 `finished(result)`，由事件写回角色/组件；
 - 角色创建页结果键：`display_name`、`age`。
 
 ### 事件
 
+- 事件签名统一：`func run(context: EventContext) -> GDScript`；引擎每执行一个事件前打包一个 `EventContext`（`state` + `player`＝protagonist 绑定），每事件一包；
+- 事件里拿人用 `context.character(&"daughter")` / `context.player`（**拿数据用 `context`，做事用 `Era.*`**）；
 - 重启当前事件：`return get_script() as GDScript`（局部变量重置，游戏状态保留）；
 - 当前事件内循环：`while true:`（保留实例和局部变量）；
 - 进入其他事件：`return OtherEvent`。
 
 ## 8. KOJO
 
 - `KojoBook` 只注册 `register(event_name, Callable)`，口上函数是普通 GDScript；
-- `Era.kojo(character, event_name, extras = {})` 每次新建 `KojoContext`：
+- `Era.kojo(character, event_name, extras = {})` 每次新建 `KojoContext`；`KojoContext` **extends `EventContext`**（继承 `player` / `state` / `character()`），口上特有的固定字段是 `speaker / extras`：
 
 ```gdscript
+class_name KojoContext extends EventContext
+
 var speaker: Character
-var player: Character
-var state: GameState
-var extras: Dictionary
+var extras: Dictionary = {}
 ```
 
-- 固定字段是 `speaker / player / state`；调用者的临时数据放 `extras`，同名键不会覆盖固定字段；
+- `player / state / character()` 由 `EventContext` 继承；调用者的临时数据放 `extras`，同名键不会覆盖固定字段；
 - 事件函数：`func _morning(context: KojoContext) -> Variant`；
 - 事件 ID：`morning / after_training / act_cute / daily / caress`；
 - 按钮：`Era.print_button(...)` + `await Era.input()`；sync：函数里不写 await；
 - 口上开关/计数在 `KojoComponent`；计数键用英文事件 ID。
 
 ## 9. 命名边界
 
 - 英文：变量、方法、导出字段、信号、上下文固定字段、组件字段、状态字段、程序字符串 ID。
 - 中文：玩家可见名字/台词/按钮/状态文本、中文注释/文档、既有资源文件名。
 - 角色 ID：`player / daughter / maid / father`；天赋 ID：`ignorant / childish / precocious / sexually_repressed / weak_bladder`。
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/character_panel.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/character_panel.gd"
index 5cf089e..2a3d7c2 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/character_panel.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/character_panel.gd"
@@ -1,23 +1,23 @@
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_day_start.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_day_start.gd"
index 072ad87..376e80c 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_day_start.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_day_start.gd"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_event_flow.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_event_flow.gd"
index 6c6aa9a..5a7ac06 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_event_flow.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_event_flow.gd"
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
-		var daughter := Era.character(&"daughter")
+		Era.print("ctx_player=%s" % context.player.id)
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
 
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_foundations.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_foundations.gd"
index bf2544a..46ae042 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_foundations.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_foundations.gd"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_kojo.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_kojo.gd"
index bf81818..d6e0bf7 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_kojo.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_kojo.gd"
@@ -116,20 +116,26 @@ func _ready() -> void:
 		if probe_context.player != player:
 			failures.append("KojoContext.player 应为主角")
 		if probe_context.state != Era.state:
 			failures.append("KojoContext.state 应为 Era.state")
 		if probe_result != player:
 			failures.append("probe 应返回 extras[partner]，实际 %s" % str(probe_result))
 		if probe_context.extras.get("speaker") != "恶意 speaker":
 			failures.append("extras 里的同名键应原样保留")
 		if probe_context.extras.get("other") != 42:
 			failures.append("extras 额外键应可读取")
+		if not (probe_context is EventContext):
+			failures.append("KojoContext 应继承 EventContext")
+		if probe_context.character(&"player") != player:
+			failures.append("context.character 应能查到主角")
+		if probe_context.character(&"missing") != null:
+			failures.append("查无此人时 character() 应返回 null")
 
 	if failures.is_empty():
 		print("CHECK OK")
 		get_tree().quit(0)
 	else:
 		print("CHECK FAIL")
 		for failure in failures:
 			print("  - ", failure)
 		get_tree().quit(1)
 
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_talent_select.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_talent_select.gd"
index 01af6da..a38c478 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_talent_select.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_talent_select.gd"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_title.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_title.gd"
index 6742aca..ba2b63b 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/check_title.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/check_title.gd"
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
 
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/day_start.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/day_start.gd"
index 0f343b6..0c5ac08 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/day_start.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/day_start.gd"
@@ -7,23 +7,23 @@ extends EraEvent
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/engine-v1-design.md" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/engine-v1-design.md"
index f75eec5..3b722da 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/engine-v1-design.md"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/engine-v1-design.md"
@@ -36,21 +36,21 @@
 
 `change_scene` 只保留给极低频的整页边界（例如将来有独立的启动器/游戏分区），不参与事件跳转。
 
 ## 2. 目录结构
 
 ```
 engine/
   era.gd                 # 自动加载（Era）：命令 API + 事件循环 + 枚举 + 屏幕管理
   era_screen.tscn        # 主屏：背景 + 滚动区 + 行容器 + 页面槽
   era_screen.gd          # 主屏脚本（少量：把行加进容器、滚动、清屏）
-  era_event.gd           # 内容事件基类：func run() -> GDScript（返回下一个事件，null = 结束）
+  era_event.gd           # 内容事件基类：func run(context: EventContext) -> GDScript（返回下一个事件，null = 结束）
   era_screen_page.gd     # 挂载页面基类：signal finished(result)
   era_palette.tres       # 文字颜色（Resource：normal / dim / accent / danger，改一处）
   game_state.gd          # 游戏状态 Resource
   rows/text_row.tscn     # 文字行（内含 Label + RichTextLabel 两个节点，按需切换）
   rows/text_row.gd
   rows/button_row.tscn   # 按钮行（Button，自动带 [数字]）
   rows/button_row.gd
   rows/rule_row.tscn     # 分割线行
   rows/rule_row.gd
   rows/grid_row.tscn     # 多列选择格子（常驻块 + 局部更新）
@@ -122,80 +122,86 @@ enum Style { NORMAL, DIM, ACCENT, DANGER }
 | `Era.print_toggle(text: String, id: int, selected: bool = false, disabled: bool = false)` | 格子里加一个选择项（点击只切自己，不打断流程） |
 | `Era.print_cell(text: String, style: Style = Style.NORMAL, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT)` | 格子里加一个纯文字格（不可点；做状态面板/表头/“文字+按钮”混排） |
 | `var grid := Era.end_grid()` | 结束收集、构建并挂上格子块；返回格子句柄 |
 | `Era.print_rule(char: String = "╍")` | 追加一条占满整行的分割线；带标题/花哨样式由内容自己拼字符串用 `Era.print()` 输出 |
 | `Era.print_gap(n: int = 1)` | 追加 n 个空行 |
 | `Era.clear()` | 清空当前屏幕（文字流 + 旧按钮） |
 | `await Era.input() -> int` | 等玩家点按钮或按数字键，返回选中的 id |
 | `await Era.wait_key()` | 等任意键/点击 |
 | `await Era.print_wait(text: String, style: Style = Style.NORMAL, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT)` | `print` + `wait_key` 的语法糖；调用时必须 `await` |
 | `await Era.show_screen(scene: PackedScene, data: Dictionary = {}) -> Variant` | 挂载特殊页面；入树前用 `configure(data)` 传输入，返回页面交出的结果 |
-| `Era.state` | 游戏状态 Resource（只装 `character_book`；角色数据在组件里） |
+| `Era.state` | 游戏状态 Resource（只装 `character_book`；事件里拿角色用 `context.character(id)` / `context.player`） |
 
 说明：
 - **没有 `goto`**。事件跳转用普通 GDScript 的 `return`：`return 下一个事件脚本`，返回 `null` 表示流程结束。引擎循环执行，事件之间不会嵌套 `await` 成一条长链。
 - `print` 与 GDScript 全局函数同名。引擎内部禁止直接调用全局 `print`（用 `push_warning` 或引擎日志方法），内容脚本不受影响。若后面发现编辑器警告太吵，再统一改名。
 - `input()` 只认“这一轮”的按钮：上一次 `input()` 结束后，旧按钮会被禁用并从“可接受编号”列表里移除；键盘数字只匹配当前这一轮的按钮。
 - 格子句柄（`end_grid()` 的返回值）方法/信号：`get_selected() -> Array[int]`、`is_selected(id)`、`is_disabled(id)`、`set_selected(id, bool)`、`set_disabled(id, bool)`、`toggled(id, selected)` 信号；`get_button(id)` 只给校验场景用。
 - 格子里的**选择项点击不会让 `input()` 返回**；只有动作项会。互斥/选择上限这类业务规则由内容接 `grid.toggled` 自己算，引擎只负责“灰色不能点”。
 - 格子里的**纯文字格**没有编号、不可点；样式用 `Era.Style`，对齐用 `HorizontalAlignment`。
 - 按钮编号第一版支持 0–9 的键盘选择；格子里超过 9 的编号先用鼠标点，多位数输入以后再单独做。
 - 内容示例：
 
 ```gdscript
 extends EraEvent
 
 const DayStart: GDScript = preload("res://content/events/day_start.gd")
 
-func run() -> GDScript:
-    var daughter := Era.state.character_book.find(&"daughter")
+func run(context: EventContext) -> GDScript:
+    var daughter := context.character(&"daughter")
     var life := daughter.get_component(LifeComponent) as LifeComponent
     Era.clear()
     Era.print("你醒了过来。")
     Era.print("窗外还没天亮。", Era.Style.DIM)
     Era.print("有些[color=#ff8888]不对劲[/color]。")
     Era.print("标题居中一下", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
     Era.print_rule()
     Era.print_button("起床", 0)
     Era.print_button("继续睡", 1)
     match await Era.input():
         0:
             life.hurt(10)
             return DayStart          # 下一个事件；不是 goto，是普通的 return
         _:
             Era.print("你又睡了过去。")
     await Era.wait_key()
     return null                      # 流程结束
 ```
 
-数据不再写在 `GameState` 的扁平字段里，而是从角色组件取：
+数据不再写在 `GameState` 的扁平字段里：事件里用 `context` 取人，数据从角色组件取：
 
 ```gdscript
-var daughter := Era.state.character_book.find(&"daughter")
+var daughter := context.character(&"daughter")
 var life := daughter.get_component(LifeComponent) as LifeComponent
 life.hurt(10)
 ```
 
 ## 5. 事件与流程
 
-- 事件 = 一个 `.gd` 脚本，`extends EraEvent`，写 `func run() -> GDScript`：
+- 事件 = 一个 `.gd` 脚本，`extends EraEvent`，写 `func run(context: EventContext) -> GDScript`：
   - 返回一个脚本 → 引擎接着执行它；
   - 返回 `null` → 流程结束。
+- 引擎每次执行事件前打包一个 `EventContext`（`state` + `player`＝protagonist 绑定），**每事件一包**：主角中途换绑后，下一个事件拿到新值。
 - 引擎循环（示意）：
 
 ```gdscript
 var next_script: GDScript = start_script
 while next_script != null:
     var event := next_script.new() as EraEvent
-    next_script = await event.run()
+    var context := EventContext.new()
+    context.state = state
+    context.player = _protagonist()
+    next_script = await event.run(context)
 ```
 
+- 事件里的统一口径：**拿数据用 `context`（人、主角、状态），做事用 `Era.*`（print / input / kojo / show_screen）**。取人写 `context.character(id)` / `context.player`，不要在内容里翻 `Era.state.character_book`。
+
 - 事件之间不嵌套 `await`：A 事件 `return B` 之后，A 的协程就结束了，B 由引擎循环启动。长流程不会把调用栈越叠越深。
 - 事件有两种写法，语义不同：
   - **重启当前事件**：`return get_script() as GDScript`。会创建同类新事件，局部变量重置；`Era.state`、角色组件、资源不自动重置。
   - **当前事件内循环**：`while true:`。保留同一个事件实例和局部变量，适合面板反复交互；离开时再 `return 另一个事件脚本`。
 - 特殊页面 = 一个 `.tscn`，根脚本 `extends EraScreenPage`，实现 `configure(data)`；`Era.show_screen(scene, data)` 在页面入树前调用它，页面只使用这里传入的数据，完成后发 `finished(result)`。页面不读取或修改 `Era.state`。
 - 第一版不做存档/读档，但 `Era.state` 已经是 Resource，后面加存档不需要改内容写法。
 
 ## 6. 数据（Resource，不用 CSV）
 
 - `GameState`：一个 Resource，只装整局游戏的容器；角色自己的数据在 `Character` 的组件里：
@@ -246,20 +252,21 @@ class_name GameState extends Resource
 - `talent_select.gd`：5 个 `TalentData` → 3 列格子；互斥用 `conflicts_with` 灰显。
 - 流程改成：标题 → 角色创建页（名字/年龄）→ 天赋选择 → 第 1 天。
 - 验收：`check_talent_select` + 全链路 `check_day_start`；截图见 `docs/step-6-report.md`。
 
 每一步都用 Godot 实际跑 + 截图对照；每步旁边放一个小校验场景（headless 也能跑，检查行数/文字/返回编号）。
 
 ## 9. 代码约定（你要参与编写与 Code Review）
 
 - 每个文件中文注释，目标每个 ≤ 150 行；一次只加一个小模块。
 - 命名：代码标识符与程序字符串 ID 用英文（`Era.print`、`character_book`、`player/daughter`）；玩家可见文本、中文文档和既有资源文件名保持中文。组件字段也用英文（`value/max_value`）。
+- 统一口径：**拿数据用 `context`（人、主角、状态），做事用 `Era.*`（print / input / kojo / show_screen）**。事件与口上函数一律从入参 `context` 取人（`context.character(id)` / `context.player`），不在内容里直接调 `Era.character()` 或翻 `Era.state.character_book`（那是引擎内部与测试的写法）。
 - 每个文件写完我先用两三句话讲清楚它做什么、怎么用，你 Code Review 通过后再继续。
 - 第 1 步开始前清理旧实验文件：`_tmp_check.gd`、`main.tscn*.tmp`、空的 `to_dict.gd`、旧 `main.gd`、旧 `MainScene` 自动加载。
 - 不引入测试框架；用“校验场景 + 截图”代替。实验目录 `experiment/` 保留作证据，引擎稳定后可以删。
 
 ## 10. 已知风险
 
 - RichTextLabel 行数多时性能下降：先按“没 BBCode 就用 Label”的规则把大部分行降成 Label；仍有压力再换“单 RichTextLabel 分段追加”或自绘。
 - 文字行里含 `[` 会被当成 BBCode：正文要写 `[` 时用 `[lb]`；以后需要再加开关。
 - `ScrollContainer` 的滚动条/最大尺寸有缓存问题（C 版已遇到并绕过）；封装在引擎里，不扩散到内容。
 - 按钮获得焦点时空格/回车会被它吃掉：键盘输入用 `_unhandled_key_input`，必要时先释放焦点。
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/era.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/era.gd"
index 824081b..c28f412 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/era.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/era.gd"
@@ -2,25 +2,25 @@ extends Node
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
-##     var 女儿 := Era.state.character_book.find(&"daughter")
+##     var 女儿 := context.character(&"daughter")
 ##     var 生命 := 女儿.get_component(LifeComponent) as LifeComponent
 ##     生命.hurt(10)
 ##     return null
 ## [/codeblock]
 ## 事件返回下一个事件脚本就继续跑，返回 [code]null[/code] 就结束。
 ## 没有 goto，也不换场景。
 
 ## 文字样式；具体颜色取自 [code]res://engine/era_palette.tres[/code]。
 enum Style { NORMAL, DIM, ACCENT, DANGER }
 
@@ -36,27 +36,26 @@ const GAME_STATE_SCRIPT := preload("res://engine/game_state.gd")
 ## [br][br]
 ## 比普通场景高，保证内容始终在游戏之上。
 const LAYER_INDEX := 100
 
 ## 整个事件流程跑完时发出（校验场景、将来“回到标题”会用到）。
 signal flow_finished
 
 signal _choice_made(id: int)
 signal _key_pressed
 
-## 游戏状态
+## 游戏状态：只装 [code]character_book[/code]；角色数据在组件里。
 ## [br][br]
-## 使用的时候请在内容脚本里写
+## 事件里拿角色用入参 context（拿数据用 context，做事用 Era.*）：
 ## [codeblock]
-## Era.state.生命 
-## 
-## Era.state.health
+## context.character(&"daughter")
+## context.player
 ## [/codeblock]
 var state: GameState
 
 var _palette: EraPalette
 var _screen
 var _layer: CanvasLayer
 var _pending_buttons: Array[Dictionary] = []
 var _active_buttons: Dictionary = {}
 var _input_active := false
 var _waiting_key := false
@@ -292,21 +291,22 @@ func start(event_script: GDScript) -> void:
 func show_screen(scene: PackedScene, data: Dictionary = {}) -> Variant:
 	var page: Variant = scene.instantiate()
 	if page.has_method("configure"):
 		page.configure(data)
 	_screen.show_page(page)
 	var result: Variant = await page.finished
 	_screen.hide_page(page)
 	return result
 
 
-## 按 id 取角色（内容脚本里写 [code]Era.character(&"daughter")[/code]）。
+## 按 id 取角色。引擎内部/测试用；内容脚本在事件里用
+## [code]context.character(&"daughter")[/code]（拿数据用 context，做事用 Era.*）。
 func character(id: StringName) -> Character:
 	if state == null or state.character_book == null:
 		return null
 	return state.character_book.find(id)
 
 
 ## 运行[method Era.kojo]方法会调用一段口上，也就是[i]kojo[/i]。
 ## [br][br]
 ## [b]原理:[/b]找角色的 [KojoComponent]，调用[param KojoComponent.book]里注册的事件函数。
 ## [br][br]
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
 
 
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/era_event.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/era_event.gd"
index cb9e578..83188d0 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/era_event.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/era_event.gd"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/event_context.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/event_context.gd"
new file mode 100644
index 0000000..878ef8f
--- /dev/null
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/event_context.gd"
@@ -0,0 +1,15 @@
+class_name EventContext
+extends RefCounted
+## EventContext, 事件的随身工具包
+##
+## 拿数据用 context（人、主角、状态），做事用 Era.*。
+## player 是 CharacterBook.protagonist_id 的绑定（可为 null），不是按 id 查找。
+
+var player: Character
+var state: GameState
+
+
+func character(id: StringName) -> Character:
+	if state == null or state.character_book == null:
+		return null
+	return state.character_book.find(id)
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/game_state.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/game_state.gd"
index a6d23a1..dba52df 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/game_state.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/game_state.gd"
@@ -1,14 +1,14 @@
 class_name GameState
 extends Resource
 ## GameState, 游戏状态
 ##
 ## 现在只装“整局游戏的容器”：角色表（[CharacterBook]）。
-## 角色自己的数据在 [Character] 的组件里：
+## 角色自己的数据在 [Character] 的组件里；事件里拿人用入参 context：
 ## [codeblock]
-## var 女儿 := Era.state.character_book.find(&"daughter")
+## var 女儿 := context.character(&"daughter")
 ## var 生命 := 女儿.get_component(LifeComponent) as LifeComponent
 ## 生命.hurt(10)
 ## [/codeblock]
 
 ## 多角色：角色表（id → Character）；所有角色数据都从这里取。
 @export var character_book: CharacterBook = CharacterBook.new()
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/kojo_context.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/kojo_context.gd"
index eea98d1..5237775 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/kojo_context.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/kojo_context.gd"
@@ -1,11 +1,10 @@
 class_name KojoContext
-extends RefCounted
+extends EventContext
 ## KojoContext, 口上固定上下文
 ##
-## 固定字段单独存放，调用者临时数据放在 [member extras]；extras 里的同名键
-## 不会覆盖固定字段。口上函数统一接收这个类型。
+## 自身固定字段是 speaker 与 extras（调用者临时数据放在 [member extras]，extras
+## 里的同名键不会覆盖固定字段）；player / state / character() 由 [EventContext]
+## 继承获得。口上函数统一接收这个类型。
 
 var speaker: Character
-var player: Character
-var state: GameState
 var extras: Dictionary = {}
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/new_game.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/new_game.gd"
index 8fda02c..9cab224 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/new_game.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/new_game.gd"
@@ -1,27 +1,27 @@
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/show_component.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/show_component.gd"
index a01dfb5..070f9b6 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/show_component.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/show_component.gd"
@@ -1,23 +1,23 @@
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/talent_select.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/talent_select.gd"
index 0e9f5b3..549c997 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/talent_select.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/talent_select.gd"
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
@@ -49,21 +49,21 @@ func run() -> GDScript:
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/type_a_new_game.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/type_a_new_game.gd"
index 73b4ae3..615db3d 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/type_a_new_game.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/type_a_new_game.gd"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/type_a_title.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/type_a_title.gd"
index a5215f2..fc40afe 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-final/type_a_title.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-final/type_a_title.gd"
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
