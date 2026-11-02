# my-test 文档目录

> 自建的 GDScript Era 风格引擎 + 角色系统。Godot 版本：4.8-dev7。

## 怎么跑

- **F5**：标题 → 开始游戏 → 角色创建（名字/年龄）→ 天赋选择 → 第 1 天 → 查看角色面板 / 口上。
- **F6 单独跑**：
  - `tests/demo_character.tscn`：角色组件（生命/关系）
  - `tests/demo_relations.tscn`：多角色关系矩阵
  - `tests/demo_kojo.tscn`：口上（文本/条件/随机/按钮/sync/开关计数）
  - `tests/demo_mixed_grid.tscn`：混合格子（文字 + 按钮 + 选择项）
  - `tests/demo_grid_b.tscn`：多列选择格子
  - `tests/demo_show_component.tscn`：组件一览（显示名/字段/值）
- **headless 校验**：`tests/check_*.tscn`，每个都应输出 `CHECK OK`。命令示例：
  ```powershell
  $godot = 'C:\Users\30873\Desktop\Godot\Stable\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64_console.exe'
  & $godot --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_character.tscn --quit-after 300
  ```

## 目录

| 目录 | 内容 |
|---|---|
| `engine/` | 引擎：Era 单例、壳、行部件、角色/组件、口上、调色板、GameState |
| `content/` | 游戏内容：事件、挂载页面、角色原型/组件、口上书 |
| `resources/` | 天赋 `TalentData` 等 Resource |
| `scripts/` | 旧项目的 `TalentData` 脚本（仍被使用） |
| `tests/` | 校验场景 + 演示场景 + 校验用 driver |
| `assets/` | 字体、主题 |
| `docs/` | 设计与分步记录 |
| `experiment/` | 早期 A/B/C 实验、截图证据、归档的旧 `start.tscn` |

## 文档索引

- 引擎设计：`docs/engine-v1-design.md`
- 角色系统设计（定稿）：`docs/character-system-design.md`
- 设计边界 spec：`docs/superpowers/specs/2026-10-25-engine-boundaries-design.md`
- 执行计划：`docs/superpowers/plans/2026-10-25-engine-boundaries.md`
- 第 1 步实现计划：`docs/superpowers/plans/2026-10-20-engine-v1-step1.md`
- 分步完成记录：`docs/step-1-report.md` … `docs/step-14-report.md`
- 实验证据：`experiment/README.md`、`experiment/shots/`

## 说明

- `GameState` 现在只装 `character_book`；角色名字/年龄/关系/数值都在 `Character` 及其可选组件里。
- 统一口径：**拿数据用 `context`（人、主角、状态），做事用 `Era.*`（print / input / kojo / show_screen）**；事件与口上函数从入参 context 取人（`context.character(id)` / `context.player`），不直接翻 `Era.state.character_book`。
- 代码标识符和程序 ID 用英文（`player/daughter/maid/father`、`character_book`）；玩家可见文本保持中文。
- 现有 **17** 个 `check_*.tscn` 全部 `CHECK OK` 是当前验收基线。
- 旧参考场景（`start.tscn`）归档在 `experiment/legacy/start.tscn`；旧的 `first_game.tscn`/`main.tscn` 等已删除。
