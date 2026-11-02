# Task 3 报告：内容层退役 Era.character / character_book.find

日期：2026-10-31
状态：**DONE**（17/17 全绿，main.tscn headless 干净，content 层 grep 清零）

## 1. 初始 grep 命中（改前全量）

命令（brief 第 40 行）：`Select-String -Path 'content\events\*.gd' -Pattern 'Era\.character\(|character_book\.find\('`（实际用等价 ripgrep 全量扫 `content\` 与 `tests\`）。

**content\ 共 5 处命中**（与 brief 预告的 5 文件一一对应，无漏网）：

| 文件 | 行 | 命中 |
|---|---|---|
| content/events/new_game.gd | 17 | `Era.state.character_book.find(&"daughter")` |
| content/events/talent_select.gd | 59 | `Era.state.character_book.find(&"daughter")` |
| content/events/day_start.gd | 19 | `Era.state.character_book.find(&"daughter")` |
| content/events/character_panel.gd | 13 | `Era.state.character_book.find(&"daughter")` |
| content/events/show_component.gd | 13 | `Era.state.character_book.find(&"daughter")` |

**tests\ 共 15 处命中**，其中：

- **应迁（4 文件 8 处）**：check_event_flow.gd:16（RestartEvent 内 1 处）、_demo_character_event.gd:9-10（2 处）、_demo_kojo_event.gd:12-13（2 处）、_demo_relations_event.gd:9-11（3 处）。
- **保留（6 文件 7 处）**：check_day_start.gd:40、check_talent_select.gd:57、check_era_commands.gd:31、check_grid.gd:68、check_mixed_grid.gd:62、check_kojo_buttons.gd:25+44 —— 均为 check 脚本（非事件）的断言/装配代码，brief 明确允许保留（check_kojo_buttons 里的 `Era.character` 被点名为允许项）。

## 2. 逐文件改动（共 9 文件 12 处，全部同义替换）

统一规则：`Era.character(&"x")` / `Era.state.character_book.find(&"x")` → `context.character(&"x")`。除此之外未动任何其他行。

1. **content/events/new_game.gd:17** — `Era.state.character_book.find(&"daughter")` → `context.character(&"daughter")`。上一行的 `Era.state.character_book = CharacterSetup.ensure(...)` 建簿装配保持原样。
2. **content/events/talent_select.gd:59** — 同上替换（match 9998 分支内）。:29 的 `CharacterSetup.ensure` 保持原样。
3. **content/events/day_start.gd:19** — 同上替换。:18 的 `CharacterSetup.ensure` 保持原样。
4. **content/events/character_panel.gd:13** — 同上替换。:12 的 `CharacterSetup.ensure` 保持原样。
5. **content/events/show_component.gd:13** — 同上替换。:12 的 `CharacterSetup.ensure` 保持原样。
6. **tests/check_event_flow.gd:16**（RestartEvent.run 内）— `Era.character(&"daughter")` → `context.character(&"daughter")`。:15/:36 的 `context.player.id` 是 Task 2 既有断言，未动。
7. **tests/_demo_character_event.gd:9-10** — `Era.character(&"daughter")` / `Era.character(&"player")` → `context.character(...)`×2。`_ensure_characters()`（book.find 判重、book.add）未动。
8. **tests/_demo_kojo_event.gd:12-13** — 同上 2 处。`_ensure_characters()` 未动。
9. **tests/_demo_relations_event.gd:9-11** — `Era.character(&"player"/"daughter"/"maid")` → `context.character(...)`×3。`_ensure_characters()` 未动。

**要点**：`_demo_*.gd` 里的 `var player := context.character(&"player")` 是对旧 `Era.character(&"player")` 的同义替换（按 id 查找、查无返回 null），**不是** `context.player` 属性读取——未引入任何新的 `context.player` 读取（Task 2 审查警告遵守）。

**同义性核验**（读实现而非自洽断言）：`engine/event_context.gd:12` 的 `character()` 与 `engine/era.gd:303` 的 `character()` 逐行相同（state/character_book 为 null 时返回 null，否则 `character_book.find(id)`）；且 `engine/era.gd:375` 打包 context 时 `context.state = state` 是同一引用，故事件体内先执行 `Era.state.character_book = CharacterSetup.ensure(...)` 后再 `context.character(...)` 可见新书，与旧直接 `Era.state.character_book.find` 完全一致。

## 3. 验证输出

### 3.1 受影响校验（4/4 CHECK OK，exit 0）

```
===== check_day_start =====      CHECK OK  exit=0
===== check_talent_select =====  CHECK OK  exit=0
===== check_event_flow =====     CHECK OK  exit=0
===== check_kojo_buttons =====   WARNING: Era.kojo：角色「daughter」的口上事件「act_cute」已被关掉 (check 自身的关开关断言，既有行为)  CHECK OK  exit=0
```

### 3.2 grep 兜底（改后）

`content\` 目录 `Era\.character\(|character_book\.find\(` → **0 命中**（ripgrep: No matches found）。
`tests\` 剩余 7 处均为上述 check 脚本断言/装配代码（brief 允许保留项），事件脚本 0 命中。

### 3.3 全量 17/17

```
check_text_row OK  check_button_rule OK  check_era_commands OK  check_title OK
check_day_start OK  check_character_create OK  check_era_screen OK  check_grid OK
check_mixed_grid OK  check_talent_select OK  check_character OK  check_relations OK
check_kojo OK  check_kojo_buttons OK  check_print_wait OK  check_event_flow OK
check_foundations OK
===== SUMMARY: 17 OK / 0 FAIL (total 17) =====
```

### 3.4 main.tscn headless

`--quit-after 300` 过滤 ERROR/WARNING/null → **零输出，exit=0**（干净）。

## 4. 自查

- [x] 先 grep 全量再动手：初始命中见 §1，content 无漏网文件（无超出 brief 9 文件之外的 content/events 命中）。
- [x] 每处改动均为取人查找的同义替换：无行为编辑、无新 `context.player` 读取、`CharacterSetup.ensure` / `_ensure_characters()` / `book.add` / check 断言代码全部未动。
- [x] 17/17 全绿 + main.tscn headless 干净。
- [x] 未用“行数到达 N”当到达判定；本任务未穿剧情。
- [x] 非 git 仓库，未执行任何 git 操作。

## 5. 顾虑

- 无阻塞项。两点备忘（不影响验收）：
  1. `Era.character()`（engine/era.gd:303）本体保留——本次只退役内容层调用；引擎侧 API 是否最终删除属后续任务范畴。
  2. check 脚本里的 7 处 `Era.character` / `character_book.find` 按 spec 保留；若后续任务要求 check 断言也走 context，需单独迁移（check_kojo_buttons.gd:44 的 `Era.kojo(daughter, ...)` 参数处不在本次规则内）。
