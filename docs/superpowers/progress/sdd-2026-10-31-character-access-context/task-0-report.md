# Task 0 报告：基线修复（用户 type_a 流程后的测试同步）

## 结论

- 3/3 目标校验转绿：`check_title` / `check_day_start` / `check_talent_select` 均输出 `CHECK OK`。
- 全量 `tests/check_*.tscn` 17 个场景 **17/17 CHECK OK**（0 失败）。
- 只修改了 `tests/` 下 3 个文件；`content/`、`engine/` 未做任何改动。

## 每个文件的改动

### 1. `tests/check_title.gd`

- 第 7 行 preload：`res://content/events/title.gd` → `res://content/events/type_a_title.gd`。
- 行数断言全部按新标题屏布局（gap5 + rule + gap2 + 6 行点阵 + gap + 3 按钮 + rule = 19 行）更新：
  - `_wait_rows(14, 120)` → `_wait_rows(19, 120)`；
  - 标题屏断言 `!= 14` → `!= 19`（含失败文案里的 14 → 19，共 3 处：初始、两条路径回到标题后）；
  - 点"继续游戏 / 关于游戏"后追加 1 行的断言 `!= 15` → `!= 20`（2 处）。
- 两条路径（继续游戏 → 等键 → 回标题；关于游戏 → 鼠标左键 → 回标题）的测试逻辑未动。

### 2. `tests/check_day_start.gd`

- 第 8 行 `const TITLE := preload(...)`：`title.gd` → `type_a_title.gd`。
- 标题屏等待/断言：`_wait_rows(14, 120)` → `_wait_rows(19, 120)`，`!= 14` → `!= 19`，文案 14 → 19。
- "等键 → 第 1 天"一步：原来的单次 `Era._resolve_key()` 改为 `await _walk_until_day_start()`，13 行断言保留；随后（第 1 天出现后）的一切断言原样保留。
- 顶部文档注释的流程描述补上 `type_a 开场剧情` 一段（使注释与新流程一致）。
- 新增 `_walk_until_day_start()` 辅助函数（见下文"与 brief 的偏差"）。

### 3. `tests/check_talent_select.gd`

- 结尾"等键 → 第 1 天"同样改为 `await _walk_until_day_start()` + 13 行断言；其余断言（格子 9 格、互斥灰显、灰色点击无效、反选恢复、天赋组件写入、确认后 7 行）全部未动。
- 新增同一个 `_walk_until_day_start()` 辅助函数。

## 与 brief 的偏差（重要）：walk 辅助函数的循环条件

Brief 给的现成辅助函数是：

```gdscript
func _walk_until_day_start() -> void:
	var guard := 0
	while Era.row_count() < 13 and guard < 120:
		Era._choose(0)
		Era._resolve_key()
		await get_tree().process_frame
		guard += 1
```

**这个条件有 bug，实测无法通过**：`type_a_new_game` 选"亲生女儿"后，行数会**路过恰好 13 行**
（rule 1 + 剧情前段 5 行 + 双按钮 2 行 + 选择后前 5 行 = 13，之后还要涨到 21 行才清屏进第 1 天）。
所以 `row_count() < 13` 会在剧情**中段**提前退出：

- `check_day_start` 首次转绿尝试（用 brief 原样辅助函数）失败，10 条断言全因"停在中段、第 1 天的 input 未激活、`_choose` 全被忽略"：
  - `角色面板应有 11 行，实际 13`、`面板"生命 -10"后生命应为 90，实际 100`、`重画第 1 天后应回到 13 行，实际 15` 等（完整 10 条见下文中间态证据）。
- `check_talent_select` 用原样辅助函数虽然显示 `CHECK OK`，但那是**假绿**：它停在了剧情中段，
  恰好中段也是 13 行，而它后续只断言 13 行这一个条件，被巧合满足。

修复（两个文件同款）：到达判定改为"**行数先冲过 13（剧情尾部 ≥ 21），再被第 1 天清屏回到 13**"，
并且**先判定后动作**，保证 `_choose(0)` 永远不会打在第 1 天自己的 0 号按钮（出去走走）上：

```gdscript
## 穿过 type_a_new_game 剧情（print_wait 的等键 + 双按钮 input），直到第 1 天的 13 行出现。
## 不能只看 row_count() >= 13：剧情选"亲生女儿"后行数也会经过 13（还在剧情中段）。
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
```

安全性依据（读 `engine/era.gd` 确认过）：`_choose` 在 `_input_active == false` 时直接 return（389-394 行），
`_resolve_key` 在 `_waiting_key == false` 时直接 return（434-438 行），非激活期调用无害——与 brief 注释一致。

## 执行的命令（PowerShell，项目根）

```powershell
$GODOT = 'C:\Users\30873\Desktop\Godot\Stable\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64_console.exe'
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_title.tscn --quit-after 300
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_day_start.tscn --quit-after 300
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_talent_select.tscn --quit-after 300
# 全量（循环跑 tests/check_*.tscn 全部 17 个，同参数）
```

## RED 证据（改动前的首轮运行，原样引用）

- `check_title.tscn`（解析失败，preload 已删除文件）：
  ```
  SCRIPT ERROR: Parse Error: Preload file "res://content/events/title.gd" does not exist.
     at: GDScript::reload (res://tests/check_title.gd:7)
  SCRIPT ERROR: Parse Error: Cannot infer the type of "TITLE" constant because the value doesn't have a set type.
     at: GDScript::reload (res://tests/check_title.gd:7)
  ERROR: Failed to load script "res://tests/check_title.gd" with error "Parse error".
  ```
- `check_day_start.tscn`（同因，第 8 行）：
  ```
  SCRIPT ERROR: Parse Error: Preload file "res://content/events/title.gd" does not exist.
     at: GDScript::reload (res://tests/check_day_start.gd:8)
  SCRIPT ERROR: Parse Error: Cannot infer the type of "TITLE" constant because the value doesn't have a set type.
     at: GDScript::reload (res://tests/check_day_start.gd:8)
  ERROR: Failed to load script "res://tests/check_day_start.gd" with error "Parse error".
  ```
- `check_talent_select.tscn`（exit=1）：
  ```
  CHECK FAIL
    - 进入第 1 天应有 13 行，实际 2
  ```

### 中间态证据（用 brief 原样 walk 辅助函数时的 `check_day_start`，证明该辅助函数有 bug）

```
CHECK FAIL
  - 角色面板应有 11 行，实际 13
  - 面板"生命 -10"后生命应为 90，实际 100
  - 面板动作后应多 1 行"现在"，实际 13
  - 重画角色面板后应回到 11 行，实际 14
  - 从面板返回第 1 天应有 13 行，实际 14
  - 选择后应追加 2 行（结果 + 现在），实际 14
  - 体力/精力应为 90/95，实际 100/100
  - 重画第 1 天后应回到 13 行，实际 15
  - 休息后体力/精力应为 95/100（精力夹到上限），实际 100/100
  - 再次重画后应回到 13 行，实际 16
```

## GREEN 证据

三个目标校验（修正 walk 条件后）：

```
check_title => CHECK OK (exit=0)
check_day_start => CHECK OK (exit=0)
check_talent_select => CHECK OK (exit=0)
```

全量 17 个场景（同一命令逐一运行）：

```
check_button_rule => CHECK OK
check_character => CHECK OK
check_character_create => CHECK OK
check_day_start => CHECK OK
check_era_commands => CHECK OK
check_era_screen => CHECK OK
check_event_flow => CHECK OK
check_foundations => CHECK OK
check_grid => CHECK OK
check_kojo => CHECK OK
check_kojo_buttons => CHECK OK
check_mixed_grid => CHECK OK
check_print_wait => CHECK OK
check_relations => CHECK OK
check_talent_select => CHECK OK
check_text_row => CHECK OK
check_title => CHECK OK

TOTAL: 17 OK / 17 scenes (0 failed)
```

## 改动的文件（仅这 3 个）

- `tests/check_title.gd`
- `tests/check_day_start.gd`
- `tests/check_talent_select.gd`

## 自查

- brief 列的计数是否全部改到位（14→19、15→20，含 `_wait_rows` 目标）？
  是。`check_title`：`_wait_rows(19)`、3 处 `!= 19`（含文案）、2 处 `!= 20`；`check_day_start`：`_wait_rows(19, 120)`、`!= 19`（含文案）。已通读改后全文核对。
- walk 辅助函数是否防死循环？
  是。`guard < 120` 硬上限；到达即 `return`；先判定后动作，不会误触第 1 天的按钮。
- 是否碰了 `content/` 或 `engine/`？
  没有。只读了它们用于理解流程与确认 `_choose`/`_resolve_key` 的空转语义，未做任何修改。
- 全量是否 17/17 绿？
  是，`TOTAL: 17 OK / 17 scenes (0 failed)`。
- 缩进/注释/类型约定？
  全部 Tab 缩进、中文注释、显式类型（`var peak := 0`、`var count := Era.row_count()`），Godot 无任何 SCRIPT ERROR / 警告输出，全部场景退出码 0。

## 顾虑

1. **brief 附带的 walk 辅助函数本身有 bug**（详见"与 brief 的偏差"）：`row_count() < 13` 会在
   type_a_new_game 剧情中段（恰好 13 行处）提前退出。我按 brief 的意图（"穿过剧情、直到第 1 天的
   13 行出现"）把到达条件改成了 `count == 13 and peak > 13`（先冲过 13 再清屏回到 13）。
   这是唯一偏离 brief 原样代码的地方，但它是从"红"到"绿"的必要修复。
2. **下游任务提醒**：以后任何"穿过 type_a_new_game"的测试都不能用"行数到达 N"做到达判定
   （剧情行数会路过 13，将来内容再变还可能路过别的数）；要么用本报告的 peak 清屏判定，
   要么给引擎加一个"当前事件/等待状态"的只读查询。`check_talent_select` 曾用 buggy 条件假绿过，
   评审时不要被"恰好 13 行"迷惑。
3. 本项目无 git，无法附 diff；改动明细已在"每个文件的改动"里逐条列出，可对照 brief 复核。
