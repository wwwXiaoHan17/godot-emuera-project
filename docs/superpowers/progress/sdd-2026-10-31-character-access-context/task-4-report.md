# Task 4 报告：文档同步与最终验收

> 日期：2026-10-31
> 状态：DONE（用户手册 F5 实机跑一步 pending-user，见文末）
> 范围：仅文档（.md）与引擎注释（.gd 的 `##` 行）；**未改任何可执行代码行**（证据见 §5）。

统一口径（三份文档同一句话）：

> **拿数据用 `context`（人、主角、状态），做事用 `Era.*`（print / input / kojo / show_screen）。**

## 1. 逐文档改动

### 1.1 `docs/engine-v1-design.md`（8 处）

| 位置 | 改动 |
|---|---|
| §2 目录结构注释 | `era_event.gd` 行：`func run() -> GDScript` → `func run(context: EventContext) -> GDScript` |
| §4 命令表 `Era.state` 行 | 描述改为「只装 `character_book`；事件里拿角色用 `context.character(id)` / `context.player`」 |
| §4 内容示例代码块 | `func run() -> GDScript:` → `func run(context: EventContext) -> GDScript:`；`Era.state.character_book.find(&"daughter")` → `context.character(&"daughter")` |
| §4 第二个代码块及引导句 | 引导句改为「事件里用 `context` 取人，数据从角色组件取」；示例 `Era.state...find` → `context.character(&"daughter")` |
| §5 事件描述 | `run()` → `run(context: EventContext)` |
| §5 新增 bullet | 「引擎每次执行事件前打包一个 `EventContext`（`state` + `player`＝protagonist 绑定），**每事件一包**：主角中途换绑后，下一个事件拿到新值」 |
| §5 引擎循环示意代码块 | 补 context 打包三行（`EventContext.new()` / `state` / `_protagonist()`），`await event.run()` → `await event.run(context)`（与 `era.gd::_run_flow` 实现逐行对应）；循环后新增统一口径 bullet |
| §9 代码约定 | 命名约定后新增「统一口径」条：内容不直接调 `Era.character()` 或翻 `Era.state.character_book`（那是引擎内部与测试的写法） |

### 1.2 `docs/character-system-design.md`（2 节）

| 位置 | 改动 |
|---|---|
| §7 事件 | 新增前两条：签名统一 `func run(context: EventContext) -> GDScript` + 每事件一包；事件里拿人用 `context.character(&"daughter")` / `context.player`（含统一口径加粗句）。原有重启/循环/进入其他事件三条保留 |
| §8 KOJO | `KojoContext` 描述改为「**extends `EventContext`**（继承 `player` / `state` / `character()`），口上特有的固定字段是 `speaker / extras`」；代码块改为与 `engine/kojo/kojo_context.gd` 一致的 `class_name KojoContext extends EventContext` + `speaker` / `extras` 两字段；固定字段说明改为「player / state / character() 由 EventContext 继承」 |

§11 验证：原文已写「**17** 个」，实测当前 `tests/check_*.tscn` 恰为 17 个，数量不变，未改动。

### 1.3 `docs/README.md`（1 处）

「说明」区在 `GameState` 条目后新增统一口径一行（拿数据 context / 做事 Era.* + 不直接翻 `Era.state.character_book`）；「现有 **17** 个 check 全部 `CHECK OK` 是当前验收基线」原样保留。

## 2. 过时注释 grep 与同步

### 2.1 grep 结果（改动前，活代码树）

模式 `Era\.character\(|character_book\.find\(` 在 `engine/`、`content/`、`tests/` 的命中：

- `content/`：**0 命中**（Task 3 已迁移干净）。
- `engine/`（5 处，其中 3 处可执行行不动，2 处注释需同步）：
  - `engine/era.gd:16` 注释 `## var 女儿 := Era.state.character_book.find(...)` — **过时 → 已同步**；
  - `engine/era.gd:46-54` `state` 的 docstring 教 `Era.state.生命` / `Era.state.health`（这两个字段从不存在，是更早设计的残影）— **过时 → 已同步**；
  - `engine/era.gd:302` `character()` doc「内容脚本里写 `Era.character(...)`」— **过时（教错方向）→ 已同步**；
  - `engine/era.gd:306`、`engine/era.gd:364`、`engine/event_context.gd:15` — 可执行实现行（`character()` 的底层 find），**不动**。
- `tests/`（7 处，全部为装配/断言，非内容取人，按 spec 保留）：
  - `check_era_commands.gd:31`、`check_grid.gd:68`、`check_mixed_grid.gd:62`：断言测试角色组件值；
  - `check_day_start.gd:40`、`check_talent_select.gd:57`：断言页面返回后女儿已装配；
  - `check_kojo_buttons.gd:25`：断言前置取女儿验口上计数；`:44`：测试驱动里给 `Era.kojo` 组 extras。
- `docs/superpowers/progress/**/before-*/after-*` 快照里的命中是历史证据，**一律不动**。

另：`era_event.gd`、`event_context.gd`、`kojo/kojo_context.gd` 的注释在 Task 1–2 已对齐（event_context.gd 首行就是统一口径句），本轮无需改。`era.gd::kojo` docstring 里「固定字段是 speaker / player / state」**仍准确**（player/state 是继承来的固定字段，`character()` 是方法不是字段），按约定保留不动。

### 2.2 已同步的注释（仅 `##` 行）

| 文件 | 行 | 改动 |
|---|---|---|
| `engine/era.gd` | 16 | 顶部示例：`Era.state.character_book.find(&"daughter")` → `context.character(&"daughter")` |
| `engine/era.gd` | 46-53 | `state` docstring：删掉不存在的 `Era.state.生命/health` 示例，改为「只装 character_book；事件里拿角色用 `context.character(&"daughter")` / `context.player`（拿数据用 context，做事用 Era.*）」 |
| `engine/era.gd` | 302-303 | `character()` doc：改为「引擎内部/测试用；内容脚本在事件里用 `context.character(...)`」 |
| `engine/game_state.gd` | 6-11 | 顶部示例：`Era.state.character_book.find(...)` → `context.character(...)`，引导句补「事件里拿人用入参 context」 |

本轮实际触碰的文件全清单：`docs/engine-v1-design.md`、`docs/character-system-design.md`、`docs/README.md`、`engine/era.gd`（仅注释）、`engine/game_state.gd`（仅注释）、本报告文件。

## 3. 扫描输出（brief 的两条命令，逐字运行）

```powershell
# 扫描 1：无参 func run()
Select-String -Path 'engine\*.gd','engine\*\*.gd','content\**\*.gd','tests\*.gd' -Pattern '^\s*func run\(\)'
# 输出：（空）→ 0 命中

# 扫描 2：内容层旧取人
Select-String -Path 'content\**\*.gd' -Pattern 'Era\.character\(|character_book\.find\('
# 输出：（空）→ 0 命中
```

补充（超出 brief 的兜底）：brief 的 `content\**\*.gd` 通配只到一层目录，`content/characters/components/*.gd`（两层）不在字面覆盖内，已用 `Get-ChildItem -Recurse` 补扫，同样 **0 命中**；engine+tests 递归命中即 §2.1 所列 3+7 处（实现行与装配/断言）。

两份当前设计文档复查：`docs/engine-v1-design.md` 与 `docs/character-system-design.md` 中已无「事件自己 find 角色」的示例；仅存的旧拼写出现在规则句里（「不要这样写」），属预期。

## 4. 全量验收输出

命令：`& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_*.tscn --quit-after 300`（Godot 4.8-dev7 console exe，逐场景）。

### 4.1 17 个 check（判定：输出含 `CHECK OK` 且无 `SCRIPT ERROR` / `Parse Error`）

```
[check_text_row]         CHECK_OK=True ERRORS=0
[check_button_rule]      CHECK_OK=True ERRORS=0
[check_era_commands]     CHECK_OK=True ERRORS=0
[check_title]            CHECK_OK=True ERRORS=0
[check_day_start]        CHECK_OK=True ERRORS=0
[check_character_create] CHECK_OK=True ERRORS=0
[check_era_screen]       CHECK_OK=True ERRORS=0
[check_grid]             CHECK_OK=True ERRORS=0
[check_mixed_grid]       CHECK_OK=True ERRORS=0
[check_talent_select]    CHECK_OK=True ERRORS=0
[check_character]        CHECK_OK=True ERRORS=0
[check_relations]        CHECK_OK=True ERRORS=0
[check_kojo]             CHECK_OK=True ERRORS=0
[check_kojo_buttons]     CHECK_OK=True ERRORS=0
[check_print_wait]       CHECK_OK=True ERRORS=0
[check_event_flow]       CHECK_OK=True ERRORS=0
[check_foundations]      CHECK_OK=True ERRORS=0
```

**17/17 `CHECK OK`。**

### 4.2 main + 全部 demo（判定：无 `SCRIPT ERROR` / `Parse Error`）

```
[res://main.tscn]                  ERRORS=0
[res://tests/demo_character.tscn]  ERRORS=0
[res://tests/demo_relations.tscn]  ERRORS=0
[res://tests/demo_kojo.tscn]       ERRORS=0
[res://tests/demo_mixed_grid.tscn] ERRORS=0
[res://tests/demo_grid_b.tscn]     ERRORS=0
[res://tests/demo_show_component.tscn] ERRORS=0
```

**7/7 零脚本/解析错误。** 所有 Godot 运行都在 .gd 注释改动之后执行。

## 5. 自查

1. **三份文档同一口径？** 是。engine-v1-design §5/§9、character-system-design §7、README「说明」均为同一句加粗规则；§4/§7 的示例都从 `context.character(...)` 取人。示例均与现行 API 对得上：§4 示例镜像 `content/events/day_start.gd` 真实写法；§5 循环示意与 `era.gd::_run_flow` 逐行对应（含 `_protagonist()`）；§8 代码块与 `engine/kojo/kojo_context.gd` 逐字一致。
2. **是否误改可执行行？** 否。以 `before-task-4` 快照为基线，把 `engine/era.gd`、`engine/game_state.gd` 双方去掉注释行后 `Compare-Object` 差异 **0 行**（`era_event.gd` 未动，同为 0）。逐行 diff 显示变更全部以 `##` 开头。
3. **验收输出是否齐全？** 是，§3/§4 全量在案。

## 6. 顾虑与备注

- brief 的 `content\**\*.gd` 通配只覆盖一层子目录；`content/characters/components/`（两层）已递归补扫确认 0。后续 brief 建议写 `Get-ChildItem -Recurse`。
- `engine/era.gd` 的 `state` docstring 原示例（`Era.state.生命/health`）不属于本 SDD 的「取人写法」类过时，而是更早设计的残影字段；同属「教不存在的 API」，已按同步精神一并修正并在此注明（超出 brief 字面清单的一处）。
- `era.gd::kojo` docstring「固定字段是 speaker / player / state」经核对仍为真（继承字段也是固定字段），按约定保留。
- tests 里 7 处旧写法命中已逐条核对为装配/断言（§2.1），符合 spec 的保留条款；若后续任务要求 check 断言也走 context，需单独迁移。
- 非 git 仓库，未做任何 commit。

## 7. Pending-user

**用户手册 F5**（编辑器里实际跑一遍标题 → 新游戏 → 角色创建 → 天赋 → 第 1 天 → 面板/口上）属于人类用户的最终验收步骤，本轮代理无法替代，**待用户执行**。
