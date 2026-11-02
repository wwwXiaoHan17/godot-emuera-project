# Character Access Context Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 事件与口上统一从 context 拿角色/数据（`EventContext` + `KojoContext` 继承），内容层退役 `Era.character` / `character_book.find`。

**Architecture:** 新增 `EventContext`（player/state/character()），`KojoContext` 改为它的子类（+speaker/extras）；`Era._run_flow` 每次执行事件前打包一个 context 塞给 `run(context)`。分两刀迁移：先切签名（全量机械改），再改函数体（旧入口退役，grep 可证）。

**Tech Stack:** Godot 4.8-dev7、GDScript、现有 `.tscn` 校验场景；不新增库或测试框架。

**Spec:** `docs/superpowers/specs/2026-10-31-character-access-context-design.md`（已获用户确认）

## Global Constraints

- 保留 `Era.kojo(character, event_name, extras)` 签名、`get_component()` 取组件、`show_screen(scene, data)`、事件接力语义——全部不动。
- 无双写、无兼容别名：`run()` 签名一次切换；旧入口从内容层一次退役。
- 代码标识符/程序 ID 英文；玩家可见文本中文；显式类型（项目警告即错误）。
- `player` 是 `protagonist_id` 绑定（可为 null），不是 `character(&"player")` 查找。
- 当前目录不是 Git 仓库：不执行 `git init`/commit；每个任务以校验通过和 review 为完成标志。
- `$GODOT = 'C:\Users\30873\Desktop\Godot\Stable\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64_console.exe'`；校验命令：`& $GODOT --headless --path $PWD res://tests/<场景> --quit-after 300`，看 `CHECK OK`。
- 2026-10-31 基线实测：17 个 check 中 14 绿。用户已把主流程改为 type_a 线（`title.gd` 删除、talent 后先进 `type_a_new_game` 剧情再进 day_start），3 个 check 滞后——先由 Task 0 恢复 17/17，再进入本改造。

## Review Focus

- 主角中途换绑后，后续 `run()` 拿到旧 player → 每次执行事件前新建 context；Task 2 的 check_event_flow 改绑断言固定。
- 漏迁的旧 `run()` 签名是运行期才爆（动态调用）→ Task 2 用 `func run()` 全库 grep = 0 兜底 + 全量 17 check 覆盖每条流程。
- `content/` 残留 `Era.character(` / `character_book.find(` → Task 3 grep = 0 兜底。
- `character(id)` 查无此人必须返回 null、不伪造 → Task 1 在 check_kojo probe 断言 `character(&"missing") == null`。
- KojoContext 同名 extras 覆盖固定字段的既有回归 → Task 1 改继承时 check_kojo 既有恶意 extras 断言必须保持全绿。

---

### Task 0: 基线修复（用户 type_a 流程后的测试同步）

**Files:**
- Modify: `tests/check_title.gd`、`tests/check_day_start.gd`、`tests/check_talent_select.gd`
- Test: 上述三个校验场景本身

**Interfaces:**
- Consumes: 用户已落地的流程改动（不改任何 `content/` 文件）。
- Produces: 17/17 基线恢复，供 Task 1–4 使用。

- [x] **Step 1: check_title 指向新标题屏**

preload 改为 `res://content/events/type_a_title.gd`；行数断言 14→19、15→20（新布局：gap5 + rule + gap2 + 6 行点阵 + gap + 3 按钮 + rule）。继续/关于两条路径断言保持。

- [x] **Step 2: check_day_start / check_talent_select 穿过 type_a_new_game**

两处的 TITLE preload 改为 `type_a_title.gd`；talent 确认后的“单次 `_resolve_key()` 直达 day_start”改为走路循环：`Era._choose(0)` + `Era._resolve_key()` + 帧等待，直到第 1 天 13 行出现（guard 120）——因为 `type_a_new_game` 混用 `print_wait`（等键）和一个双按钮 `input`。到达后原有断言不变。

- [x] **Step 3: 验证三场景 + 全量**

Run: `check_title`、`check_day_start`、`check_talent_select` → 全 `CHECK OK`；全量 17 个 → 17/17。

---

### Task 1: EventContext 基类与 KojoContext 继承

**Files:**
- Create: `engine/event_context.gd`
- Modify: `engine/kojo/kojo_context.gd`
- Test: `tests/check_kojo.gd`（probe 段，约 96–130 行）

**Interfaces:**
- Produces: `class_name EventContext extends RefCounted`，`var player: Character`、`var state: GameState`、`func character(id: StringName) -> Character`。
- Produces: `KojoContext extends EventContext`，仅保留 `var speaker: Character`、`var extras: Dictionary`（player/state 由继承获得，删除自身重复声明）。

- [x] **Step 1: 在 check_kojo 的 probe 段写失败断言**

在既有 `probe_context` 断言块内追加三条：`probe_context is EventContext`；`probe_context.character(&"player") == player`；`probe_context.character(&"missing") == null`。

- [x] **Step 2: 运行确认 RED**

Run: `& $GODOT --headless --path $PWD res://tests/check_kojo.tscn --quit-after 300`
Expected: 解析错误，`EventContext` 未声明。

- [x] **Step 3: 实现 EventContext；KojoContext 改继承**

`event_context.gd`：三个成员 + 中文 docstring；`character()` 实现 = `state == null or state.character_book == null` 时返回 null，否则 `state.character_book.find(id)`。`kojo_context.gd`：`extends EventContext`，删除自身的 `player`/`state` 声明，保留 speaker/extras。

- [x] **Step 4: 运行确认 GREEN**

Run: `check_kojo` → `CHECK OK`（含既有恶意 extras 断言不回归）。

- [x] **Step 5: 全量回归**

Run: 17 个 check → 17/17 `CHECK OK`。

---

### Task 2: 事件签名切换 run(context)

**Files:**
- Modify: `engine/era.gd`（`_run_flow`）、`engine/era_event.gd`（基类签名）
- Modify: `content/events/` 全部 7 个事件：`type_a_title.gd`、`type_a_new_game.gd`、`new_game.gd`、`talent_select.gd`、`day_start.gd`、`character_panel.gd`、`show_component.gd`
- Modify: tests 事件脚本 10 个：`_drive_commands.gd`、`_drive_grid.gd`、`_drive_mixed_grid.gd`、`_drive_kojo_buttons.gd`、`_drive_print_wait.gd`、`_demo_character_event.gd`、`_demo_relations_event.gd`、`_demo_kojo_event.gd`、`_demo_mixed_grid_event.gd`、`_demo_grid_b_event.gd`
- Modify: `tests/check_event_flow.gd`（内嵌 RestartEvent/LoopEvent + 新断言）、`tests/check_foundations.gd`（基类 `run()` 调用点）
- Test: `tests/check_event_flow.gd`

**Interfaces:**
- Consumes: Task 1 的 `EventContext`。
- Produces: `EraEvent.run(context: EventContext) -> GDScript`；`Era._run_flow` 每次循环 `EventContext.new()` + `state`/`player=_protagonist()` 后 `await event.run(context)`。

- [x] **Step 1: 扩展 check_event_flow 写失败断言**

设置段给 book 增加第二个角色 `&"player"`（主角仍绑 `&"daughter"`）。RestartEvent 打印 `ctx_player=%s`（取 `context.player.id`），断言两次重启都是 `daughter`。之后把 `protagonist_id` 改绑 `&"player"` 再跑 LoopEvent，断言其 `context.player.id == "player"`（证明改绑后新事件拿到新主角）。

- [x] **Step 2: 运行确认 RED**

Run: `check_event_flow` → 运行期错误，`run()` 参数数量不符（旧签名不收 context）。

- [x] **Step 3: 切换引擎与全部事件签名**

`era_event.gd` 基类改 `run(_context: EventContext) -> GDScript: return null`。`era.gd` `_run_flow` 每次事件前打包 context。上述 19 个脚本文件的 `func run()` 全部改 `func run(context: EventContext)`（未用到参数的事件暂不使用它，函数体留到 Task 3 迁移）。`check_foundations` 的基类调用点改 `event.run(null)`。

- [x] **Step 4: 运行 GREEN + 旧签名兜底**

Run: `check_event_flow` → `CHECK OK`。全库 grep `func run()`（无参形式）在 `engine/content/tests` 命中 0（基类已是带参形式）。

- [x] **Step 5: 全量回归**

Run: 17 个 check → 17/17 `CHECK OK`。

---

### Task 3: 内容层退役 Era.character / character_book.find

**Files:**
- Modify: `content/events/` 5 个取人事件：`new_game.gd`、`talent_select.gd`、`day_start.gd`、`character_panel.gd`、`show_component.gd`（`title.gd` 无取人）
- Modify: tests 事件脚本中的取人调用：`check_event_flow.gd` 内嵌事件（`Era.character` → `context.character`）、`_demo_character_event.gd`、`_demo_kojo_event.gd`、`_demo_relations_event.gd`
- Test: 全量回归 + grep 兜底

**Interfaces:**
- Consumes: Task 2 的 `context.character(id)` / `context.player`。
- 说明：`Era.state.character_book = CharacterSetup.ensure(...)` 的装配赋值保留（那是建簿，不是取人）；check 脚本（非事件）直接操作 book 做断言允许保留。

- [x] **Step 1: 迁移事件函数体**

规则：`Era.character(&"x")` → `context.character(&"x")`；事件内 `Era.state.character_book.find(&"x")` → `context.character(&"x")`；需要主角处可直接用 `context.player`（本任务只做同义替换，不改变行为）。

- [x] **Step 2: 运行受影响校验**

Run: `check_day_start`、`check_talent_select`、`check_event_flow`、`check_kojo_buttons` → 全 `CHECK OK`。

- [x] **Step 3: grep 兜底**

`content/` 目录 grep `Era\.character\(` 与 `character_book\.find\(` → 0 命中。

- [x] **Step 4: 全量回归**

Run: 17 个 check → 17/17 `CHECK OK`；主场景 headless 无报错。

---

### Task 4: 文档同步与最终验收

**Files:**
- Modify: `docs/engine-v1-design.md`（run 签名、context 规则、命令表说明）、`docs/character-system-design.md`（§7 事件段落补 context）、`docs/README.md`（当前接口一句话）
- Verify: 17 check + main + 全部 demo

**Interfaces:**
- Consumes: Tasks 1–3 的最终接口；不引入代码变化。

- [x] **Step 1: 更新当前设计文档**

把“拿数据用 context，做事用 Era.*”写进两份设计文档的对应段落；示例代码统一为 `run(context: EventContext)` 形态。

- [x] **Step 2: 旧接口扫描**

在 `engine/`、`content/`、`tests/` 与两份当前设计文档中 grep：`func run\(\)`（无参）、content 层 `Era\.character\(`、`character_book\.find\(`（引擎与测试装配处允许）→ 按 spec §7 口径核对命中。

- [x] **Step 3: 全量自动验收**

Run: 17 个 check 全 `CHECK OK`；`res://main.tscn` 与全部 `tests/demo_*.tscn` headless 无脚本错误。

- [x] **Step 4: 用户手动验收**（2026-10-31 用户 F5 通过）

用户 F5 走主链路（标题→创建→天赋→第 1 天→面板→口上），确认行为不变；本步留给用户，不以“代码已改”代替。
