# Task 2 报告：事件签名切换 run(context)

日期：2026-10-31
状态：DONE（17/17 全绿 + main.tscn 干净 + grep 兜底 0 命中）

## 实现内容

按 brief 完成 `EraEvent.run()` → `run(context: EventContext)` 的签名切换，引擎在每次执行事件前打包一个全新的 EventContext：

- `engine/era_event.gd`：基类签名改为 `func run(_context: EventContext) -> GDScript:`，doc 注释补一句「context 由引擎在执行前打包。」
- `engine/era.gd` `_run_flow`：每次 while 循环新建 `EventContext`，`context.state = state`、`context.player = _protagonist()`，然后 `await event.run(context)`。附中文注释「每事件一包：主角中途换绑后，下一个事件拿到新值。」
- 17 个事件脚本（content/events 7 个 + tests 10 个）：仅 `func run()` 声明行改为 `func run(context: EventContext) -> GDScript:`，函数体一行未动。
- `tests/check_foundations.gd`：基类调用点 `event.run()` → `event.run(null)`。
- 事件体内旧的 `Era.character(...)` / `character_book.find(...)` 全部原样保留（Task 3 迁移）。

## TDD 证据

### Step 1（先改测试）

`tests/check_event_flow.gd` 按 brief 四组改动：

- A 设置段：追加第二个角色 `you`（id=`player`，display_name/callname=「你」），`book.add(you)`。
- B RestartEvent：签名改 `run(context: EventContext)`；`restart_local` 打印后追加 `Era.print("ctx_player=%s" % context.player.id)`；两次重启断言 `size() != 2` → `size() != 3`，并各追加 `first.has("ctx_player=daughter")` / `second.has("ctx_player=daughter")` 断言。
- C LoopEvent：签名同上；`loop_local` 打印后追加 `loop_player=%s`（context.player.id）与 `ctx_char=%s`（context.character(&"daughter").id）两行；`loop_first.size()` 1→3，`loop_second` 由 `is_empty()` 检查改为 `size() != 3`；两次都断言含 `loop_player=player` 与 `ctx_char=daughter`。
- D 改绑：`Era.start(LoopEvent)` 之前加 `book.protagonist_id = &"player"`（若引擎不每事件重新打包，LoopEvent 会读到旧主角 daughter，测试露馅）。

另外把四处 `_wait_rows` 目标行数同步 2→3 / 2→3 / 2→3 / 1→3（与断言行数一致，避免提前读到半截行；brief 的「row-count changes」精神之内）。

### Step 2 RED（引用实际输出）

```
Godot Engine v4.8.dev7.official.c971f93e7 - https://godotengine.org

SCRIPT ERROR: Parse Error: The function signature doesn't match the parent. Parent signature is "run() -> GDScript".
   at: GDScript::reload (res://tests/check_event_flow.gd:10)
SCRIPT ERROR: Parse Error: The function signature doesn't match the parent. Parent signature is "run() -> GDScript".
   at: GDScript::reload (res://tests/check_event_flow.gd:30)
ERROR: Failed to load script "res://tests/check_event_flow.gd" with error "Parse error".
   at: load (modules/gdscript/gdscript_resource_format.cpp:50)

[exit code: 1]
```

说明：brief 预期的 RED 是「运行期参数数量错误或 ctx 行缺失」，实际失败出现得更早——Godot 在解析期就拒绝子类签名覆盖不匹配（父类还是旧 `run()`）。根因相同（引擎/基类尚未切换），属正确的「因功能缺失而失败」，符合 TDD 要求。

### Step 4 GREEN（引用实际输出）

```
Godot Engine v4.8.dev7.official.c971f93e7 - https://godotengine.org

CHECK OK
```

（exit code 0，无任何 SCRIPT ERROR / 警告。）

### Step 4 grep 兜底

命令：

```powershell
Select-String -Path 'engine\*.gd','engine\*\*.gd','content\events\*.gd','tests\*.gd' -Pattern '^\s*func run\(\)'
```

输出：`GREP BACKSTOP: 0 hits`（无参 `func run()` 在 engine / content/events / tests 全部清零）。

## Step 5 全量回归

17 个 `tests/check_*.tscn` 全部 `CHECK OK`、exit 0：

```
PASS  check_button_rule.tscn  (exit 0)
PASS  check_character.tscn  (exit 0)
PASS  check_character_create.tscn  (exit 0)
PASS  check_day_start.tscn  (exit 0)
PASS  check_era_commands.tscn  (exit 0)
PASS  check_era_screen.tscn  (exit 0)
PASS  check_event_flow.tscn  (exit 0)
PASS  check_foundations.tscn  (exit 0)
PASS  check_grid.tscn  (exit 0)
PASS  check_kojo.tscn  (exit 0)
PASS  check_kojo_buttons.tscn  (exit 0)
PASS  check_mixed_grid.tscn  (exit 0)
PASS  check_print_wait.tscn  (exit 0)
PASS  check_relations.tscn  (exit 0)
PASS  check_talent_select.tscn  (exit 0)
PASS  check_text_row.tscn  (exit 0)
PASS  check_title.tscn  (exit 0)
TOTAL: 17/17 CHECK OK
```

`res://main.tscn` headless（--quit-after 300）：exit 0，无 SCRIPT ERROR / Parse Error / Invalid call，输出仅引擎横幅（游戏停在标题等输入，属预期）。

## 改动文件（21 个，全清单）

引擎（2）：
1. `engine/era_event.gd` — 基类签名 + doc 注释
2. `engine/era.gd` — `_run_flow` 打包 context + 头部 doc 示例签名行

content/events（7）：
3. `content/events/type_a_title.gd`
4. `content/events/type_a_new_game.gd` — 仅第 3 行签名，正文零改动（用户剧情文件）
5. `content/events/new_game.gd`
6. `content/events/talent_select.gd`
7. `content/events/day_start.gd`
8. `content/events/character_panel.gd`
9. `content/events/show_component.gd`

tests 事件脚本（10）：
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

tests 校验脚本（2）：
20. `tests/check_event_flow.gd` — Step 1 断言 + 内嵌两事件签名
21. `tests/check_foundations.gd` — `event.run(null)`

## 自审

- **21 个文件全部覆盖**：grep 兜底 0 命中；现存 `func run(` 声明共 20 处（17 事件 + check_event_flow 内嵌 2 处 + 基类 `_context`），全部带参；调用点仅 `era.gd:377 run(context)` 与 `check_foundations.gd:41 run(null)`。
- **行数断言与 brief 一致**：重启两次 `size() != 3`（原 2）；`loop_first.size() != 3`（原 1）；`loop_second.size() != 3`（原 `is_empty()`）；ctx 断言齐全。
- **事件体零误改**：与 `docs/superpowers/progress/sdd-2026-10-31-character-access-context/before-task-2/` 备份逐一 Compare-Object 比对——17 个事件脚本全部是 -1/+1（仅签名行）；`type_a_new_game.gd` 仅第 3 行；`check_foundations.gd` 仅调用点一行；`era.gd` 为 `_run_flow` 五行 + doc 示例一行；其余无差异。备份目录本身未动（仍是旧签名，grep 兜底路径不含它）。
- **17/17 + main.tscn 干净**，无警告无错误（警告即错误的项目设定下全部 exit 0）。

## 顾虑（供 controller 裁量）

1. **RED 形态**：解析期签名不匹配错误，而非 brief 预期的运行期参数数量错误。根因一致（切换未实施），失败原因明确；如 controller 只认运行期形态，可说明。
2. **doc 示例签名行**（超出 brief 字面）：`era_event.gd:7` 与 `era.gd:12` 的 codeblock 示例原展示 `func run() -> GDScript:`，切换后若不改会教旧写法。已各改一行对齐新签名（era_event.gd 原注释其余部分保留 + 按要求补一句）。如需严格回退可只还原这两行 doc。
3. **`_wait_rows` 目标行数**（2→3 等）：brief 只字未提但断言行数变了，等待目标同步改才不会读到半截行；属 row-count changes 的配套。
4. **17 个事件体的 `context` 形参暂未使用**（Task 3 迁移前正常现象）；Godot 4.8-dev7 对未用形参无警告，全部运行 exit 0。
