# 第 13 步完成记录（清理旧字段 + 整理文件）

> 日期：2026-10-21
> 前一步：`docs/step-12-report.md`（角色状态面板）

## 清理了什么

**1. 删掉 `GameState` 的旧扁平字段**

`GameState` 现在只剩：

```gdscript
@export var 角色簿: CharacterBook = CharacterBook.new()
```

`名字/年龄` → `Character.display_name / age`；`体力/精力/好感/天赋` → 各自组件。
所有内容、演示、校验都改成从角色组件读写：

- `new_game`：不再写 `Era.state.名字/年龄`，改为装配角色后写女儿角色；
- `character_create`：页面回填从女儿角色读；
- `talent_select`：只写女儿 `TalentListComponent`（不再写 `Era.state.天赋`）；
- `day_start` / `character_panel`：只读组件；
- `check_*` 里的“状态标记”改为测试角色 + 组件（生命/天赋），不再借用 GameState 字段；
- `_demo_mixed_grid_event`：用本地 `LifeComponent/EnergyComponent` 当示例数据。

**2. 删除/归档旧文件**

| 操作 | 文件 |
|---|---|
| 删除（引用了已删脚本的坏场景） | `scenes/event_tscn/main.tscn` |
| 删除（旧角色创建场景，已被新流程取代） | `scenes/event_tscn/first_game.tscn`、`scripts/first_game.gd` |
| 删除（旧 demo 部件） | `scenes/demo_tscn/` 整个目录 |
| 删除（未使用的旧 Node 组件） | `scripts/component/talent_component.gd`（它和新的 `TalentListComponent` 重名，之前报过冲突） |
| 归档（纯视觉参考，无脚本引用） | `scenes/event_tscn/start.tscn` → `experiment/legacy/start.tscn` |

现在 `scripts/` 只剩被使用的 `base_resource/talent_data.gd`；`scenes/` 目录已清空删除。

**3. 文档整理**

- 新增 `docs/README.md`：运行方式、目录说明、文档索引。
- `docs/character-system-design.md` §5/§7 同步“旧字段已清理”。

## 验收结果

- 15 个校验场景全部 `CHECK OK`。
- 主场景 headless 无报错。
- 演示场景全部能加载：`demo_character` / `demo_relations` / `demo_kojo` / `demo_mixed_grid` / `demo_grid_b`。
- 归档的 `experiment/legacy/start.tscn` 可正常加载（纯视觉，无脚本）。

## 注意

- 旧的 `first_game.tscn`/`main.tscn` 已删除；项目里只保留新流程。
- 如果 Godot 编辑器还开着旧场景标签，重新打开项目或忽略“文件不存在”的提示即可。
- 以后再要旧场景参考，可从 `experiment/legacy/start.tscn` 看标题屏；`first_game` 的内容已经变成新的角色创建 + 天赋选择。

## 文件清单

- 修改：`engine/game_state.gd`、`engine/era.gd`（文档示例）、`content/events/new_game.gd`、`content/screens/character_create.gd`、`content/events/talent_select.gd`、`tests/check_day_start.gd`、`tests/check_talent_select.gd`、`tests/check_era_commands.gd`、`tests/_drive_commands.gd`、`tests/check_grid.gd`、`tests/_drive_grid.gd`、`tests/check_mixed_grid.gd`、`tests/_drive_mixed_grid.gd`、`tests/_drive_kojo_buttons.gd`、`tests/check_kojo_buttons.gd`、`tests/_demo_mixed_grid_event.gd`、`docs/character-system-design.md`
- 新增：`docs/README.md`、`docs/step-13-report.md`
- 删除/归档：见上表
