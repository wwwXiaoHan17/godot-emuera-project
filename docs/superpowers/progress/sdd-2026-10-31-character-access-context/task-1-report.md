# Task 1 Report: EventContext 基类与 KojoContext 继承

## 结论

**DONE**。`EventContext` 基类已创建，`KojoContext` 改为继承它并白捡 `character(id)`；`check_kojo` GREEN，全量 17/17 `CHECK OK`。

## 实现内容

### 新建 `engine/event_context.gd`（按 brief 精确接口，逐字一致）

```gdscript
class_name EventContext
extends RefCounted
## EventContext, 事件的随身工具包
##
## 拿数据用 context（人、主角、状态），做事用 Era.*。
## player 是 CharacterBook.protagonist_id 的绑定（可为 null），不是按 id 查找。

var player: Character
var state: GameState


func character(id: StringName) -> Character:
	if state == null or state.character_book == null:
		return null
	return state.character_book.find(id)
```

### 修改 `engine/kojo/kojo_context.gd`

- `extends RefCounted` → `extends EventContext`
- 删除自身 `var player: Character` 与 `var state: GameState`（改由继承获得）
- 保留 `var speaker: Character`、`var extras: Dictionary = {}`
- docstring 按要求改写：固定字段描述改为 speaker/extras + 继承 player/state/character()，恶意 extras 不覆盖固定字段的说明保留

### 修改 `tests/check_kojo.gd`（第 9 段 probe 断言块末尾追加三条，126–131 行）

- `probe_context is EventContext`
- `probe_context.character(&"player") == player`
- `probe_context.character(&"missing") == null`

## TDD 证据

### Step 2 — RED（先写测试，确认按预期失败）

命令：

```powershell
$GODOT = 'C:\Users\30873\Desktop\Godot\Stable\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64_console.exe'
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_kojo.tscn --quit-after 300
```

失败输出（正是 brief 预言的解析错误）：

```
SCRIPT ERROR: Parse Error: Could not find type "EventContext" in the current scope.
   at: GDScript::reload (res://tests/check_kojo.gd:126)
ERROR: Failed to load script "res://tests/check_kojo.gd" with error "Parse error".
```

### Step 4 — GREEN（实现后通过）

同一命令，输出：

```
Godot Engine v4.8.dev7.official.c971f93e7 - https://godotengine.org

CHECK OK
```

（stderr 中另有两条 `Era.kojo` push_warning，来自本测试第 5 段"缺少事件"与第 8 段"无口上组件角色"的既有故意负例，与本次改动无关，改动前亦存在。）

### Step 5 — 全量回归

对 `tests/check_*.tscn` 全部 17 个场景逐一运行，结果：

```
PASS  res://tests/check_button_rule.tscn
PASS  res://tests/check_character.tscn
PASS  res://tests/check_character_create.tscn
PASS  res://tests/check_day_start.tscn
PASS  res://tests/check_era_commands.tscn
PASS  res://tests/check_era_screen.tscn
PASS  res://tests/check_event_flow.tscn
PASS  res://tests/check_foundations.tscn
PASS  res://tests/check_grid.tscn
PASS  res://tests/check_kojo.tscn
PASS  res://tests/check_kojo_buttons.tscn
PASS  res://tests/check_mixed_grid.tscn
PASS  res://tests/check_print_wait.tscn
PASS  res://tests/check_relations.tscn
PASS  res://tests/check_talent_select.tscn
PASS  res://tests/check_text_row.tscn
PASS  res://tests/check_title.tscn
TOTAL: 17/17 CHECK OK
```

## 过程备注（重要）

实现后首次运行 check_kojo 曾报 `Could not parse global class "KojoContext"` 连锁错误——根因是 `.godot/global_script_class_cache.cfg` 里没有新的 `EventContext` 条目（headless 运行不会重建该缓存，新增 `class_name` 必须先过一次编辑器扫描）。执行一次：

```powershell
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' --import
```

后缓存更新（`EventContext` 入册，`KojoContext` 的 base 变为 `EventContext`），check_kojo 随即 GREEN。该操作只重建 `.godot/` 构建产物，不触碰任何源码。

## 文件变更

- 新建 `engine/event_context.gd`
- 修改 `engine/kojo/kojo_context.gd`
- 修改 `tests/check_kojo.gd`
- （构建产物）`.godot/global_script_class_cache.cfg` 由 `--import` 重新生成

未触碰：`engine/era.gd`、任何 `content/` 文件、任何事件 `run()` 签名。

## 自查

- **KojoContext 对外能力不变？** 是。`speaker`/`extras` 仍为自身字段；`player`/`state` 改由继承获得，类型不变（`Character`/`GameState`）。`era.gd:347-351` 的 `context.speaker/player/state/extras` 赋值无需改动即工作，check_kojo 第 9 段的 speaker/player/state 断言全绿可证。
- **恶意 extras 回归底线？** 全绿。extras 里同名 `speaker`/`player`/`state` 恶意键仍原样保留在 `extras`、不覆盖固定字段（断言 122–123 行通过），`other: 42` 可读（124–125 行通过）。
- **全量 17/17？** 是。
- **约定？** TAB 缩进、中文 doc 注释、显式类型，无新增警告。

## 顾虑

- 无阻塞项。唯一提示：后续任务若再新增 `class_name`（Task 2 只改签名、不新增类名，不受影响），headless 校验前需先跑一次 `--import` 刷新类缓存，否则会以"类未声明"的解析错误假失败。
