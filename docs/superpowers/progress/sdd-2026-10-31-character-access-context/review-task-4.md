=== Task 4 diff（before → after，git diff --no-index）===
 .../README.md"                                     |  1 +
 .../character-system-design.md"                    | 12 ++++++-----
 .../engine-v1-design.md"                           | 23 ++++++++++++++--------
 .../era.gd"                                        | 14 ++++++-------
 .../game_state.gd"                                 |  4 ++--
 5 files changed, 32 insertions(+), 22 deletions(-)

=== Full diff (U10) ===
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-4/README.md" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-4/README.md"
index dd171de..86d9ffc 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-4/README.md"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-4/README.md"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-4/character-system-design.md" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-4/character-system-design.md"
index 059a4f9..277afde 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-4/character-system-design.md"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-4/character-system-design.md"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-4/engine-v1-design.md" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-4/engine-v1-design.md"
index f75eec5..3b722da 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-4/engine-v1-design.md"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-4/engine-v1-design.md"
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-4/era.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-4/era.gd"
index 9675d15..c28f412 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-4/era.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-4/era.gd"
@@ -6,21 +6,21 @@ extends Node
 ## 常驻壳 + 命令 API + 输入等待 + 事件循环。
 ## [br][br]
 ## 内容脚本的写法：
 ## [codeblock]
 ## extends EraEvent
 ##
 ## func run(context: EventContext) -> GDScript:
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
diff --git "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-4/game_state.gd" "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-4/game_state.gd"
index a6d23a1..dba52df 100644
--- "a/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\before-task-4/game_state.gd"
+++ "b/docs\\superpowers\\progress\\sdd-2026-10-31-character-access-context\\after-task-4/game_state.gd"
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
