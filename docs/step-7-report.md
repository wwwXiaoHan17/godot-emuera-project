# 第 7 步完成记录（角色系统第 1 步：组件骨架 + 两个示例组件）

> 日期：2026-10-21
> 设计：`docs/character-system-design.md`（v2）
> 前一步：`docs/step-6-report.md`（天赋场景）

## 这一步做完了什么

**引擎（`engine/character/`）**

| 文件 | 作用 |
|---|---|
| `character_component.gd` | 组件基类：`component_changed` 信号、`context_key`（口上条件里的名字）、`component_key`、`to_fields/apply_fields`（字段白名单 + 容器深拷贝） |
| `relation_entry.gd` | 一条“我 → 别人”的关系边：`target/relation/callname` |
| `character.gd` | 角色宿主：组件增删/按类型或 key 查找；关系读写、称呼回退（自定义 → 对方默认 → 对方真名 → "-"）；`spawn()` 深拷贝原型 |
| `character_book.gd` | 角色表：加/按 id 查/全部/ids；同 id 覆写 |

**示例组件（`content/characters/components/`，只是模板，你可自己改）**

- `life_component.gd`：生命值/上限、`hurt()/heal()`、夹取、`ratio()`；`context_key = &"生命"`。
- `affection_component.gd`：好感组件的“规则门面”——关系数据在 `Character.relations` 上，组件只负责上限/夹取/变更通知（`change(角色, 目标, 增减)`）。

**接入**

- `engine/game_state.gd`：新增 `角色簿: CharacterBook`（多角色统一从这里取）。
- `engine/era.gd`：新增 `Era.character(id)` 便捷方法。

**演示 / 校验**

- `tests/demo_character.tscn`（F6 可跑）：玩家 + 女儿两个角色，生命/好感组件；按钮可伤害/治疗/加好感，显示关系和称呼回退。
- `tests/check_character.tscn/.gd`：组件增减夹取、`to_fields/apply_fields` 往返、组件检索、同键覆写、关系/称呼回退、`spawn` 深拷贝独立、`CharacterBook` 增查替换。

## 验收结果

- 12 个校验场景全部 `CHECK OK`（原 11 个 + `check_character`）。
- `tests/demo_character.tscn` headless 加载无报错，F5 可跑。
- 截图：
  - `experiment/shots/character_initial.png`：初始（生命 100/100、关系 20/50、称呼回退“你”）
  - `experiment/shots/character_damage.png`：点“伤害女儿”后“现在：生命 90 好感 20”

## 踩到的一个小坑（项目约定）

项目把「从 Variant 值推断变量类型」这个警告当作错误（`The variable type is being inferred from a Variant value`）。
所以 `var script := get_script()` 编译不过，要写成 `var script: Script = get_script()`。以后新代码注意。

## 已知限制（本步）

- 还没有 `.tres` 角色原型（现在 demo 是在代码里造角色）；第 2 步再上原型 + `spawn`。
- 关系不自动对称（内容决定要不要两边都写）；称呼只有“我 → 别人”的出边。
- KOJO 还没做；`context_key` 已预留（口上条件里将能用 `生命.值`）。
- 没有存档；`to_fields/apply_fields` 已按 GDEmuera 口径准备好。
- 健康/性欲组件还没写（等你自己设计字段；我可以按你的要求再给模板）。

## 文件清单

- 新增：`engine/character/character_component.gd`、`relation_entry.gd`、`character.gd`、`character_book.gd`、`content/characters/components/life_component.gd`、`affection_component.gd`、`tests/check_character.tscn/.gd`、`tests/demo_character.tscn`、`tests/demo_character.gd`、`tests/_demo_character_event.gd`、`docs/step-7-report.md`
- 修改：`engine/game_state.gd`、`engine/era.gd`
