# Task 2 Brief: 事件签名切换 run(context)

## 背景

前置 Task 1 已完成：`engine/event_context.gd` 存在（`class_name EventContext`，`player: Character`、`state: GameState`、`character(id: StringName) -> Character`），`KojoContext extends EventContext`。本任务把**所有** `EraEvent.run()` 签名切成 `run(context: EventContext)`，引擎每次执行事件前打包一个 context。本任务**只切签名**：事件函数体里旧的 `Era.character(...)` / `character_book.find(...)` 取人写法暂时保留（Task 3 再迁移）。`Era.kojo` 内部无需改动（KojoContext 已在 Task 1 获得继承能力）。

## 文件清单（权威，逐个改）

**引擎（2 个）：**
1. `engine/era_event.gd` — 基类签名
2. `engine/era.gd` — `_run_flow` 打包 context

**content/events（7 个）：**
3. `content/events/type_a_title.gd`
4. `content/events/type_a_new_game.gd`
5. `content/events/new_game.gd`
6. `content/events/talent_select.gd`
7. `content/events/day_start.gd`
8. `content/events/character_panel.gd`
9. `content/events/show_component.gd`

**tests 事件脚本（10 个）：**
10. `tests/_drive_commands.gd`
11. `tests/_drive_grid.gd`
12. `tests/_drive_mixed_grid.gd`
13. `tests/_drive_kojo_buttons.gd`
14. `tests/_drive_print_wait.gd`
15. `tests/_demo_character_event.gd`
16. `tests/_demo_relations_event.gd`
17. `tests/_demo_kojo_event.gd`
18. `tests/_demo_mixed_grid_event.gd`
19. `tests/_demo_grid_b_event.gd`

**tests 校验脚本（2 个）：**
20. `tests/check_event_flow.gd` — 内嵌两个事件 + 新断言（见下）
21. `tests/check_foundations.gd` — 基类调用点

## 精确改动

### `engine/era_event.gd`

```gdscript
func run(_context: EventContext) -> GDScript:
	return null
```
（保留原中文 doc 注释，补充一句“context 由引擎在执行前打包”。）

### `engine/era.gd` 的 `_run_flow`（当前约 379 行）

现状是 `var result: Variant = await event.run()`。改为**每次循环**新建 context：

```gdscript
func _run_flow(first_script: GDScript) -> void:
	var next_script: GDScript = first_script
	while next_script != null:
		var event: Variant = next_script.new()
		var context := EventContext.new()
		context.state = state
		context.player = _protagonist()
		var result: Variant = await event.run(context)
		next_script = result as GDScript
	flow_finished.emit()
```
（每事件一包：主角中途换绑后，下一个事件拿到新值。）

### 上面清单 3–19 的全部事件脚本

`func run() -> GDScript:` → `func run(context: EventContext) -> GDScript:`。函数体一行都不改。

### `tests/check_foundations.gd`

基类调用点 `event.run()` → `event.run(null)`（第 41 行附近）。

## TDD：先改 `tests/check_event_flow.gd`（Step 1，写失败断言）

对该文件做三组改动：

**A. 设置段**（已有 daughter + book，protagonist 绑 daughter）：追加第二个角色

```gdscript
	var you := Character.new()
	you.id = &"player"
	you.display_name = "你"
	you.callname = "你"
	book.add(you)
```

**B. RestartEvent**（内嵌类）：签名改 `func run(context: EventContext) -> GDScript:`；在 `restart_local` 打印后追加一行

```gdscript
		Era.print("ctx_player=%s" % context.player.id)
```

对应地，测试里两次重启的行数断言 `size() != 2` → `size() != 3`，并各追加 `if not first.has("ctx_player=daughter"):` / `second.has(...)` 断言（两次都是 daughter，因为 protagonist 仍绑 daughter）。

**C. LoopEvent**：签名同上；在 `loop_local` 打印后追加两行

```gdscript
			Era.print("loop_player=%s" % context.player.id)
			Era.print("ctx_char=%s" % context.character(&"daughter").id)
```

测试断言：`loop_first` / `loop_second` 的 `size()` 由 1 → 3；两次都含 `loop_player=player` 与 `ctx_char=daughter`。

**D. 改绑断言**：在"启动 LoopEvent"之前加

```gdscript
	book.protagonist_id = &"player"
```

（RestartEvent 跑完时主角是 daughter；LoopEvent 启动前改绑 player——如果引擎真的每事件重新打包，LoopEvent 读到的就是 player；如果引擎复用旧包或读全局旧值，这里会露馅。）

## Step 2: 运行确认 RED

`res://tests/check_event_flow.tscn` → 运行期错误：`run()` 参数数量不符（旧签名不收 context），或 ctx_player 行缺失导致 CHECK FAIL。两者都是期望中的失败。

## Step 3: 实施全部签名切换（按上面精确改动）

## Step 4: 运行 GREEN + 旧签名兜底

- `check_event_flow` → `CHECK OK`
- 全库 grep 无参形式（PowerShell）：
  `Select-String -Path 'engine\*.gd','engine\*\*.gd','content\events\*.gd','tests\*.gd' -Pattern '^\s*func run\(\)'`
  → **0 命中**（era_event.gd 基类已是 `run(_context: ...)`）

## Step 5: 全量回归

17 个 `tests/check_*.tscn` → 17/17 `CHECK OK`；`res://main.tscn` headless 无脚本错误。

## Godot 命令

```powershell
$GODOT = 'C:\Users\30873\Desktop\Godot\Stable\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64_console.exe'
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_event_flow.tscn --quit-after 300
```

## 项目约定

- Tab 缩进；中文注释；显式类型（警告即错误）。项目非 git 仓库：**不要 commit**。
- 只碰清单里的 21 个文件。注意：`type_a_new_game.gd` 是用户的剧情文件，改它的**唯一**内容是 run() 签名那一行。
- 已知陷阱（Task 0 的教训）：这个项目穿过 `type_a_new_game` 时不能用"行数到达 N"当到达判定——本任务不走路该剧情，但别引入这类断言。
