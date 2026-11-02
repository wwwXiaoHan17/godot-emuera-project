# 引擎 v1 第 1 步实现计划（壳 + 命令 + 标题屏）

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让 `Era` 引擎跑起来：常驻壳 + 命令 API + 点击/数字键输入 + 用命令写成的标题屏，画面和现有 `start.tscn` 一致。

**Architecture:** `Era` 是自动加载脚本，`_ready` 时把 `era_screen.tscn` 放进 `CanvasLayer`；屏幕里有背景 + 滚动区 + 行容器（第 3 步再加页面槽）。内容脚本通过 `Era.print*` 追加行部件，`await Era.input()` 等待玩家；事件用 `run() -> GDScript` 的 `return` 切换，不用 goto / change_scene。

**Tech Stack:** Godot 4.8-dev7（GDScript）、现有 `assets/themes/normal_theme.tres`、无测试框架（用 headless 校验场景）。

**Spec:** `docs/engine-v1-design.md`（v2，已审阅通过）

## Global Constraints

- 引擎代码英文命名；游戏内容/状态字段可以用中文（`Era.state.体力`）。
- 每个文件中文注释，目标 ≤ 150 行；一次只加一个小模块，写之前先讲、写完用户 Code Review 通过再继续。
- 不引入测试框架：每个任务配一个 headless 校验场景，成功打印 `CHECK OK` 并 `quit(0)`，失败打印 `CHECK FAIL` 并 `quit(1)`。
- 本目录不是 git 仓库：不做 commit，每个任务用“校验场景通过 + 用户审阅”作为完成标志。
- 事件流不用 goto、不用 `change_scene`；数据用 Resource，不读 CSV。
- 分割线按 ERB 习惯占满整行：默认符号 `╍`，按当前文字区宽度自动算重复次数（MS Gothic 16px 下 `╍`=8px/字 → 144 个；`■`=16px/字 → 72 个），不写死数量。
- 引擎内部禁止直接调用全局 `print()`（`Era.print` 同名），需要输出时用 `push_warning` 或校验场景。

## Review Focus

- 按钮获得焦点后按空格/回车：应该触发 `wait_key`/数字选择，而不是重复触发按钮（按钮行要 `focus_mode = FOCUS_NONE`）。
- 同一行在 Label 与 RichTextLabel 之间切换：颜色、对齐、换行观感要一致（行内颜色只在 RichTextLabel 分支）。
- 内容变短（清屏 / 行数上限裁剪）后滚动条和滚动位置不能残留（A 版踩过）。
- 快速双击 / 连续按键：`input()` 只能被满足一次，旧按钮编号不能串到下一次等待。
- `Era.print` 与全局 `print` 同名：引擎内部不能误调全局 print 造成递归；校验场景要覆盖。
- 窗口缩放后已打印的分割线不会自动重排（v1 接受这个限制；重新打印即可）。

## File Structure

```
engine/
  era.gd                 # 自动加载：枚举、命令 API、输入等待、事件循环
  era_screen.tscn/.gd    # 常驻壳：背景 + ScrollContainer + 行容器（一个节点、一份职责）
  era_palette.gd/.tres   # 文字颜色 Resource（4 色）
  game_state.gd          # 游戏状态 Resource
  era_event.gd           # 事件基类：run() -> GDScript
  rows/text_row.tscn/.gd # 一行文字（Label / RichTextLabel 二选一）
  rows/button_row.tscn/.gd # 一行按钮
  rows/rule_row.tscn/.gd # 一行分割线
content/events/title.gd  # 标题屏（改写 start.tscn）
main.tscn/main.gd        # 入口：启动 title 事件
tests/check_*.tscn/.gd   # 每个任务一个校验场景
```

---

### Task 1: 调色板 + 状态 + 事件基类

**Files:**
- Create: `engine/era_palette.gd`, `engine/era_palette.tres`
- Create: `engine/game_state.gd`
- Create: `engine/era_event.gd`
- Create: `tests/check_foundations.tscn`, `tests/check_foundations.gd`

**Interfaces:**
- Produces: `class_name EraPalette extends Resource { @export var normal/dim/accent/danger: Color }`；`class_name GameState extends Resource`（字段 `名字: String = ""`、`年龄: int = 18`、`体力: int = 100`、`精力: int = 100`）；`class_name EraEvent extends RefCounted { func run() -> GDScript }`（基类返回 `null`）。

- [ ] **Step 1: 写校验场景（先失败）**

`tests/check_foundations.gd` 断言：`EraPalette` 资源 4 个颜色都不是默认黑；`GameState.new().体力 == 100`；`EraEvent.new().run() == null`。成功打印 `CHECK OK` 并 `get_tree().quit(0)`，失败打印 `CHECK FAIL: <原因>` 并 `quit(1)`。

- [ ] **Step 2: 跑一次，确认失败**

Run: `Godot_v4.8-dev7_win64_console.exe --headless --path . res://tests/check_foundations.tscn`
Expected: 报找不到脚本/场景（或 `CHECK FAIL`），退出码非 0。

- [ ] **Step 3: 实现三个文件**

`era_palette.gd`：4 个 `@export var ...: Color`。`era_palette.tres` 填值：normal 白、dim 灰（0.55 白）、accent 青（0.45, 0.95, 1.0）、danger 红（0.95, 0.35, 0.35）。`game_state.gd` 按上面字段。`era_event.gd`：`func run() -> GDScript: return null`。

- [ ] **Step 4: 跑校验场景，确认通过**

Run: 同 Step 2
Expected: 输出 `CHECK OK`，退出码 0。

- [ ] **Step 5: 交给用户审阅这三个文件**

- [ ] **Step 6: 用户通过后继续 Task 2**

---

### Task 2: 文字行部件

**Files:**
- Create: `engine/rows/text_row.tscn`, `engine/rows/text_row.gd`
- Create: `tests/check_text_row.tscn`, `tests/check_text_row.gd`

**Interfaces:**
- Produces: `text_row.tscn` 根节点 `MarginContainer`，内含 `Label`（默认显示）与 `RichTextLabel`（默认隐藏）；脚本 `func setup(text: String, color: Color, align: HorizontalAlignment) -> void`。无 `[` 用 Label；含 `[` 用 RichTextLabel（`bbcode_enabled = true`，center/right 用 `[center]`/`[right]` 包一层）。

- [ ] **Step 1: 写校验场景（先失败）**

`tests/check_text_row.gd` 断言三组：
1. `setup("普通文字", Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT)` → Label 可见、RichTextLabel 隐藏、Label.text 正确；
2. `setup("[color=#ff8888]红[/color]", ...)` → RichTextLabel 可见、Label 隐藏、RichTextLabel.text 含 `[color`;
3. `setup("居中", ..., HORIZONTAL_ALIGNMENT_CENTER)` → Label.horizontal_alignment == CENTER；`setup("[center]居中的 BBCode[/center]", ...)` → RichTextLabel.text 含 `[center]`。
成功 `CHECK OK` / 失败 `CHECK FAIL`。

- [ ] **Step 2: 跑一次，确认失败**

Run: `... --headless --path . res://tests/check_text_row.tscn`
Expected: 失败（场景/脚本不存在）。

- [ ] **Step 3: 实现 text_row.tscn 与 text_row.gd**

节点：`MarginContainer` → `Label`（`horizontal_alignment` 由 setup 设定）、`RichTextLabel`（`bbcode_enabled=true`、`fit_content=true`、`scroll_active=false`、`visible=false`）。颜色用 `add_theme_color_override("font_color"/"default_color", color)`。判断规则：`text.contains("[")`。

- [ ] **Step 4: 跑校验场景，确认通过**

Expected: `CHECK OK`，退出码 0。

- [ ] **Step 5: 交给用户审阅**

---

### Task 3: 按钮行 + 分割线行

**Files:**
- Create: `engine/rows/button_row.tscn/.gd`
- Create: `engine/rows/rule_row.tscn/.gd`
- Create: `tests/check_button_rule.tscn/.gd`

**Interfaces:**
- Produces: `button_row.tscn` 根节点 `Button`（`flat=true`、`focus_mode=FOCUS_NONE`）；`signal picked(id: int)`；`func setup(text: String, id: int, align: HorizontalAlignment) -> void`（text 自动变成 `"[%d] %s" % [id, text]`）；`func make_inert() -> void`（`disabled=true`、`modulate.a=0.45`）。`rule_row.tscn` 根节点 `Label`；`func setup(char: String, count: int) -> void`：只做 `char.repeat(count)`，`count` 由引擎按文字区宽度算好；带标题/花哨样式由内容自己拼字符串用 `Era.print()`，本部件不管。

- [ ] **Step 1: 写校验场景（先失败）**

断言：button `setup("开始游戏", 0, LEFT)` 后 text 以 `"[0] 开始游戏"` 开头、`flat`、`focus_mode == FOCUS_NONE`；`picked.emit`/`pressed.emit()` 能收到 id 0；`make_inert()` 后 `disabled == true`。rule：`setup("", "╍", 10)` 正好 10 个 ╍；`setup("标题", "╍", 10)` 总长仍是 10（含标题）。

- [ ] **Step 2: 跑一次，确认失败**

- [ ] **Step 3: 实现两个行部件**

- [ ] **Step 4: 跑校验场景，确认通过**

- [ ] **Step 5: 交给用户审阅**

---

### Task 4: 常驻壳 era_screen

**Files:**
- Create: `engine/era_screen.tscn`, `engine/era_screen.gd`
- Create: `tests/check_era_screen.tscn/.gd`

**Interfaces:**
- Produces: `era_screen.tscn` 根 `Control`（全屏），内含 `Background: ColorRect`、`Margin: MarginContainer`、`Scroll: ScrollContainer`（`%Scroll`）、`Rows: VBoxContainer`（`%Rows`）。脚本 `func append_row(row: Control) -> void`、`func clear_rows() -> void`、`func row_count() -> int`、`func scroll_to_bottom() -> void`、`func text_char_count(char: String) -> int`。行数上限常量 `MAX_ROWS := 500`。

`text_char_count`：用 `%Rows.get_theme_default_font()` 和 `get_theme_default_font_size()` 量 `char` 宽度，`floor(%Rows.size.x / 字符宽)`；宽度 <= 0 时返回 144。

- [ ] **Step 1: 写校验场景（先失败）**

断言：追加 3 行后 `row_count() == 3`；追加到 600 行后仍为 500（丢最旧）；`clear_rows()` 后为 0 且 `%Scroll.scroll_vertical == 0`。

- [ ] **Step 2: 跑一次，确认失败**

- [ ] **Step 3: 实现壳场景与脚本**

`append_row`：`%Rows.add_child(row)`；超过上限时移除最旧 `remove_child` + `queue_free`；调用 `scroll_to_bottom()`。`clear_rows`：遍历 `%Rows` 先 `remove_child` 再 `queue_free`，`scroll_vertical = 0`，`get_combined_minimum_size()` + `queue_sort()` 强制重算。`scroll_to_bottom`：等两帧（`await get_tree().process_frame` ×2），`scroll_vertical = maxi(0, int(_rows.size.y - _scroll.size.y))`。

- [ ] **Step 4: 跑校验场景，确认通过**

- [ ] **Step 5: 交给用户审阅**

---

### Task 5: 引擎 era.gd（命令 + 输入 + 事件循环）

**Files:**
- Create: `engine/era.gd`
- Modify: `project.godot`（加自动加载 `Era="*res://engine/era.gd"`，先不改主场景）
- Create: `tests/check_era_commands.tscn/.gd`

**Interfaces:**
- Produces（自动加载单例 `Era`）：
  - `enum Style { NORMAL, DIM, ACCENT, DANGER }`（对齐直接用 Godot 的 `HorizontalAlignment`，不另造枚举）
  - `var state: GameState`
  - `func print(text: String, style: Style = Style.NORMAL, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void`
  - `func print_button(text: String, id: int, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void`
  - `func print_rule(char: String = "╍") -> void`（重复次数 = 壳的 `text_char_count(char)`）、`func print_gap(n: int = 1) -> void`、`func clear() -> void`
  - `func input() -> int`（`await` 用，返回编号）、`func wait_key() -> void`（`await` 用）
  - `func start(event_script: GDScript) -> void`、`signal flow_finished`
  - `func _choose(id: int) -> void`（供输入层/校验场景调用；当前这一轮的按钮才有效）
  - `func row_count() -> int`（转发给壳，供校验用）

- [ ] **Step 1: 写校验场景与测试事件（先失败）**

`tests/check_era_commands.gd`：注册自动加载后，`Era.start(preload("res://tests/_drive_commands.gd"))`；测试事件 `_drive_commands.gd` 依次：`Era.print("第一行")`、`Era.print("红", Era.Style.DANGER)`、`Era.print_button("甲", 0)`、`Era.print_button("乙", 1)`、`var picked := await Era.input()`、`Era.print("选了 %d" % picked)`、`await Era.wait_key()`、`return null`。校验场景 `await Era.flow_finished` 后断言：行数 = 5、`_drive_commands` 里 `picked == 0`（校验场景在启动后调 `Era._choose(0)`；`wait_key` 用 `Era._choose(-1)` 或专门方法）、`CHECK OK`。

- [ ] **Step 2: 跑一次，确认失败**

- [ ] **Step 3: 实现 era.gd**

要点：`_ready` 里创建 `CanvasLayer`（layer = 100）并实例化 `era_screen.tscn` 挂进去；`state = GameState.new()`；行部件用 `preload` 的 3 个场景；`print*` 创建行并 `append_row`；`print_button` 把按钮记入 `_pending_buttons` 列表（`id -> row`），并连接 `picked` 到 `_choose`；`input()` 开始新的一轮：把 pending 变成 active、`_input_active = true`、`return await _choice_submitted`；`_choose(id)` 仅在 `_input_active` 且 id 在 active 中时 emit，并把 active 全部 `make_inert()`、清空、`_input_active = false`；`wait_key()` 等 `_key_submitted`，任意键触发；`_unhandled_key_input` 把数字键转成 `_choose(digit)`，非数字键在等 key 时 emit `_key_submitted`；`start(script)` 启动 `while next_script != null: next_script = await (next_script.new() as EraEvent).run()`，结束后 `flow_finished.emit()`。

- [ ] **Step 4: 跑校验场景，确认通过**

Run: `... --headless --path . res://tests/check_era_commands.tscn`
Expected: `CHECK OK`，退出码 0；控制台无 `SCRIPT ERROR`。

- [ ] **Step 5: 交给用户审阅**

---

### Task 6: 标题屏 + 入口 + 清理旧文件

**Files:**
- Create: `content/events/title.gd`
- Create: `main.tscn`, `main.gd`
- Modify: `project.godot`（主场景改为 `main.tscn`，自动加载保留 `Era`，删除旧 `MainScene` 自动加载）
- Delete: `_tmp_check.gd`、`_tmp_check.gd.uid`、`main.tscn4100520743.tmp`、`scripts/to_dict.gd`、`scripts/to_dict.gd.uid`、`scenes/event_tscn/main.gd`、`scenes/event_tscn/main.gd.uid`、`scenes/event_tscn/main.tscn`
- Create: `tests/check_title_headless.tscn/.gd`（可选：用命令复刻标题但不在真实窗口）

**Interfaces:**
- `title.gd extends EraEvent`，`func run() -> GDScript`：`Era.clear()`，用 `Era.print(..., Era.Style..., HORIZONTAL_ALIGNMENT_CENTER)` 复刻 `start.tscn` 的 6 行 ASCII 字（深红 `#c02f45`，用 BBCode `[color=#c02f45]`）、空行、居中标题与分割线（`Era.print_rule("■")`，自动 72 个，和 start.tscn 一致）、3 个居中按钮（id 1/2/3：开始游戏/继续游戏/关于游戏），`var picked := await Era.input()`，`Era.print("你选了 %d" % picked)`，`await Era.wait_key()`；第一版对任何选择都返回 `null`（第 2 步再接事件）。

- [ ] **Step 1: 写标题事件和入口**

`main.gd`：`extends Node`，`_ready` 里 `Era.start(preload("res://content/events/title.gd"))`。`main.tscn`：根 `Node` 挂 `main.gd`。

- [ ] **Step 2: 切换 project.godot 并删旧文件**

改 `run/main_scene` 为新 `main.tscn` 的 uid；删除列出的旧文件；确认 `MainScene` 自动加载已移除。

- [ ] **Step 3: headless 跑主场景，确认无报错**

Run: `... --headless --path . --quit-after 120`
Expected: 无 `SCRIPT ERROR`；退出码 0。

- [ ] **Step 4: 有窗口跑一次，和 start.tscn 对照**

Run: `... --path .`（开窗口）；用 Godot 输出面板确认无报错；截图与旧 `start.tscn` 对照（可以临时用 F6 跑旧场景截图）。验收：画面布局/颜色/居中一致；点按钮或按数字 1/2/3 后出现“你选了 …”，再按键退出等待。
（用户亲手跑这一条也在验收里。）

- [ ] **Step 5: 交给用户审阅 title.gd / main.gd，并收集画面意见**

---

### Task 7: 第 1 步收尾

**Files:**
- Modify: `docs/engine-v1-design.md`（只在行为与设计不一致时更新）
- Create: `tests/check_all_headless.gd`（可选：一次跑完 Task 1–6 的校验场景）

- [ ] **Step 1: 重跑全部校验场景**

Run: 每个 `tests/check_*.tscn`；Expected: 全部 `CHECK OK`。

- [ ] **Step 2: 写一小段“第 1 步完成”记录到 `docs/`（做了什么、怎么跑、已知限制）**

- [ ] **Step 3: 交给用户，确认后进入第 2 步（事件流程 + 状态）**

---

## Self-Review

- 覆盖 spec 第 2/3/4/5/8 节（壳、行部件、命令、事件、第一步验收）：Task 1–6 逐项覆盖；`show_screen` 与页面槽属于第 3 步，本计划不做（spec 分步一致）。
- 签名一致：`Era.print(text, style, align)`、`Era.print_button(text, id, align)`、`Era.input() -> int`、`Era.wait_key()`、`Era.start(script)`、`Era.row_count()` 在 Task 4/5/6 中名称一致。
- 每个 Review Focus 都有测试归属：焦点/键盘在 Task 3 + Task 5；Label/RTL 一致在 Task 2；滚动残留/行数上限在 Task 4；双击/串号在 Task 5；`print` 同名在 Task 5 校验场景（headless 运行本身会暴露递归/报错）。
- 风险：`Title` 的 ASCII 字与旧 `start.tscn` 逐字对照时，若行宽/字体不同会偏；Task 6 用截图对照人工验收。
