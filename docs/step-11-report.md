# 第 11 步完成记录（角色系统第 5 步：day_start 接入角色组件）

> 日期：2026-10-21
> 设计：`docs/character-system-design.md`（v2）
> 前一步：`docs/step-10-report.md`（角色系统第 4 步）

## 这一步做完了什么

**新增示例组件（`content/characters/components/`）**

| 组件 | 字段/方法 | context_key |
|---|---|---|
| `stamina_component.gd` | `值/上限`、`spend()/rest()` | `体力` |
| `energy_component.gd` | `值/上限`、`spend()/rest()` | `精力` |
| `talent_component.gd` | `selected: Array[StringName]`、`set_talents()`、`text()` | `天赋` |

> 注意：`talent_component.gd` 的类名是 **`TalentListComponent`**，不是 `TalentComponent`——
> 项目里旧的 `scripts/component/talent_component.gd` 已经占了 `TalentComponent`（Node 组件），
> 不改旧文件就换个名字避免冲突。

**Character**

- 增加 `@export var age: int = 18`（剧情/显示用），`spawn()` 会一起复制。

**装配 helper**

- `content/characters/character_setup.gd`（`CharacterSetup.ensure(book)`）：
  角色表里没有玩家/女儿/女仆就从 `.tres` 原型 spawn，并设置主角 id；
  主流程每一步都可以直接调它保证角色存在。

**主流程接入**

- `new_game.gd`：页面返回后 `CharacterSetup.ensure` 装配角色，把页面填的名字/年龄同步到女儿角色。
- `talent_select.gd`：确认后除了旧的 `Era.state.天赋`（暂留兼容），还写进女儿的 `TalentListComponent`。
- `day_start.gd`：不再读写 `Era.state.体力/精力/天赋`，改为：
  - 名字/年龄：女儿的 `display_name/age`；
  - 体力/精力：`StaminaComponent/EnergyComponent`（`spend/rest` 自带夹取）；
  - 好感：`daughter.relation_to(&"玩家")`；
  - 天赋：`TalentListComponent.text()`；
  - 动作后打印“现在”，按键后重画（和原来一致）。

**女儿原型**

- 补了 `体力/精力/天赋` 三个组件（用一次性工具改 `.tres`，工具已删）；
  现在女儿 = 生命 + 好感 + 口上 + 体力 + 精力 + 天赋 六个组件。

**校验更新**

- `check_talent_select`：确认后断言天赋组件 `[幼稚]`；第 1 天行数 10→11。
- `check_day_start`：页面返回后断言女儿已装配、名字/年龄同步；第 1 天 11 行；
  出去走走后体力/精力 90/95；在家休息后 95/100（精力 +10 会夹到上限 100）。
- 其余 13 个校验不动。

## 验收结果

- 15 个校验场景全部 `CHECK OK`。
- 主场景 headless 无报错。
- 截图：
  - `experiment/shots/day5_start.png`：第 1 天（小灯/21 岁、体力 100/精力 100、好感 20、天赋幼稚）；
  - `experiment/shots/day5_action.png`：出去走走后“现在：体力 90　精力 95”。

## 已知限制

- `GameState` 的 `名字/年龄/体力/精力/天赋` 字段**先保留**（旧内容/校验还在用）；
  day_start 已经不再依赖它们，但还没删。
- `talent_select` 同时写旧 `Era.state.天赋` 和新的天赋组件（迁移期双写）。
- 旧 `scripts/component/talent_component.gd`（Node 组件）仍在工程里，但当前没有任何地方引用；
  以后要清理可以删。
- 体力/精力/天赋都是示例组件，字段按你的游戏设定自己改。
- 还没有存档。

## 文件清单

- 新增：`content/characters/components/stamina_component.gd`、`energy_component.gd`、`talent_component.gd`、`content/characters/character_setup.gd`、`docs/step-11-report.md`
- 修改：`engine/character/character.gd`（age）、`content/characters/prototypes/女儿.tres`（+3 组件）、`content/events/new_game.gd`、`talent_select.gd`、`day_start.gd`、`tests/check_talent_select.gd`、`tests/check_day_start.gd`
