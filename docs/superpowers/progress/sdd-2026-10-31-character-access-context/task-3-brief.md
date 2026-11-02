# Task 3 Brief: 内容层退役 Era.character / character_book.find

## 背景

前置 Task 2 已完成：所有事件签名是 `run(context: EventContext)`，`context.character(id)` / `context.player` 可用。本任务把事件函数体里的旧取人写法迁到 context——**同义替换，不改变任何行为**。统一规则：**拿数据用 context（人、主角、状态），做事用 Era.\***。

## 迁移规则

**要改**（事件函数体里的"取人"）：

| 旧写法 | 新写法 |
|---|---|
| `Era.character(&"xxx")` | `context.character(&"xxx")` |
| `Era.state.character_book.find(&"xxx")` | `context.character(&"xxx")` |

**不要改**：

- `Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)` —— 这是建簿装配，不是取人；
- **本任务不引入 `context.player` 的新读取**（Task 2 审查者警告：引擎在 `CharacterSetup.ensure` 之前打包的 context，其 player 为 null——title 等早期事件不能假设非空；`context.character(id)` 查无此人返回 null，与旧 `Era.character(id)` 语义完全一致，同义替换最安全）；
- check 脚本（非事件）里为断言/装配直接操作 book 的代码（如 `check_kojo_buttons.gd` 里的 `Era.character`）——spec 允许保留；
- 事件脚本里 `_ensure_characters()` 之类的建簿代码（`book.add(...)`、`book.find(&"player") != null` 判重）——装配代码，保持原样；
- 任何组件/引擎接口。

## 文件与已知命中

**content/events（5 个，grep 必须清零）：**
1. `content/events/new_game.gd`（约 17 行 find）
2. `content/events/talent_select.gd`（约 59 行 find）
3. `content/events/day_start.gd`（约 19 行 find）
4. `content/events/character_panel.gd`（约 13 行 find）
5. `content/events/show_component.gd`（约 13 行 find）

**tests 事件脚本（run 流程里的取人，迁到 context）：**
6. `tests/check_event_flow.gd` —— RestartEvent 内 `Era.character(&"daughter")` → `context.character(&"daughter")`
7. `tests/_demo_character_event.gd` —— run 里 2 处 `Era.character`
8. `tests/_demo_kojo_event.gd` —— run 里 2 处 `Era.character`
9. `tests/_demo_relations_event.gd` —— run 里 3 处 `Era.character`

第一步先自己 grep 全量命中，确认没有漏网：
`Select-String -Path 'content\events\*.gd' -Pattern 'Era\.character\(|character_book\.find\('`

## 步骤

1. 逐文件按规则迁移（同义替换；不动其他任何行）。
2. 跑受影响校验：`check_day_start`、`check_talent_select`、`check_event_flow`、`check_kojo_buttons` → 全 `CHECK OK`。
3. grep 兜底：`content\` 目录 `Era\.character\(` 与 `character_book\.find\(` → **0 命中**。
4. 全量 17 个 check → 17/17；`main.tscn` headless 无脚本错误。

## Godot 命令

```powershell
$GODOT = 'C:\Users\30873\Desktop\Godot\Stable\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64_console.exe'
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_day_start.tscn --quit-after 300
```

## 项目约定

- Tab 缩进；中文注释；显式类型。非 git 仓库：**不要 commit**。
- 只碰上面列的 9 个文件（若 grep 发现其他 content/events 命中，一并迁移并在报告注明）。
- 已知陷阱：不要用"行数到达 N"当穿过 `type_a_new_game` 的到达判定（Task 0 教训）；本任务不穿剧情，别引入。
