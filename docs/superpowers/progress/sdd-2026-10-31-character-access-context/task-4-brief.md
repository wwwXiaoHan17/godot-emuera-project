# Task 4 Brief: 文档同步与最终验收

## 背景

前置 Task 1–3 已完成：`EventContext` 存在且 `KojoContext extends EventContext`；所有事件签名是 `run(context: EventContext)`；内容层取人已统一走 `context.character(id)` / `context.player`。本任务只同步文档与注释、做全量验收，**不改任何代码行为**。

## 统一口径（写进文档的一句话）

> **拿数据用 `context`（人、主角、状态），做事用 `Era.*`（print / input / kojo / show_screen）。**

## 文件与改动

### 1. `docs/engine-v1-design.md`

- §5 事件与流程：`run()` 描述改为 `run(context: EventContext)`；补一条"引擎每次执行事件前打包 EventContext（state + player=protagonist 绑定），每事件一包"；
- §5 的示例代码块：`func run() -> GDScript:` → `func run(context: EventContext) -> GDScript:`；示例里 `Era.state.character_book.find(...)` 取人 → `context.character(...)`；
- §4 命令表/说明处：`Era.state` 行的描述改为"只装 `character_book`；事件里拿角色用 `context.character(id)` / `context.player`"；
- §9 代码约定：把"拿数据用 context，做事用 Era.*"写进命名约定附近。

### 2. `docs/character-system-design.md`

- §7 页面与事件：事件签名改 `run(context: EventContext)`；示例用 `context.character(&"daughter")`；
- §8 KOJO：`KojoContext` 描述改为"extends EventContext（继承 player/state/character()），口上特有 speaker/extras"；
- §11 验证：仍写 17 个 check（数量不变）。

### 3. `docs/README.md`

- "说明"区补一行统一口径（拿数据 context / 做事 Era.*），并把"现有 17 个 check 全绿是基线"保留。

### 4. 仍描述旧行为的 GDScript 注释/docstring（只改注释，不改代码）

已知位置（先 grep 确认再改）：
- `engine/era.gd` 顶部示例注释里的 `Era.state.character_book.find(...)` → `context.character(...)`；`Era.character()` 的 doc 注明"引擎内部/测试用；内容脚本用 context.character()"；
- `engine/game_state.gd` 顶部示例注释同上；
- 其他 grep 出的旧写法注释一并同步。

## 步骤

1. 按上面清单改三份文档 + 旧注释。
2. 旧接口扫描（PowerShell）：
   - `Select-String -Path 'engine\*.gd','engine\*\*.gd','content\**\*.gd','tests\*.gd' -Pattern '^\s*func run\(\)'` → **0 命中**；
   - content 层：`Select-String -Path 'content\**\*.gd' -Pattern 'Era\.character\(|character_book\.find\('` → **0 命中**（引擎内部与 tests 的装配/断言处允许存在，逐条核对属于装配而非内容取人）；
   - 两份当前设计文档中不应再出现"事件自己 find 角色"的示例。
3. 全量验收：17 个 `check_*.tscn` 全 `CHECK OK`；`res://main.tscn` 与全部 `tests/demo_*.tscn` headless 无 `SCRIPT ERROR` / `Parse Error`。

## Godot 命令

```powershell
$GODOT = 'C:\Users\30873\Desktop\Godot\Stable\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64_console.exe'
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_character.tscn --quit-after 300
```

## 项目约定

- 文档中文；代码注释中文；Tab 缩进。非 git 仓库：**不要 commit**。
- 只改文档与注释；**不改任何可执行代码行**。
