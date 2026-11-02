# 第 8 步完成记录（角色系统第 2 步：.tres 原型 + 多角色关系矩阵）

> 日期：2026-10-21
> 设计：`docs/character-system-design.md`（v2）
> 前一步：`docs/step-7-report.md`（角色系统第 1 步）

## 这一步做完了什么

**角色原型 `.tres`（`content/characters/prototypes/`）**

| 原型 | 内容 |
|---|---|
| `玩家.tres` | id=玩家、显示名=你、默认称呼=你；生命组件；对女儿好感 50 |
| `女儿.tres` | id=女儿、显示名=阿丽丝、默认称呼=女儿；生命 + 好感组件；对玩家好感 20 |
| `女仆.tres` | id=女仆、显示名=小梅、默认称呼=小梅；生命组件；对玩家 10、对女儿 30 |

原型用一次性工具生成（工具已删），之后可以直接在 Godot Inspector 里改：
`Character` 的 `components` 数组里是子 Resource，`relations` 数组里是 `RelationEntry`。

**多角色关系矩阵演示**

- `tests/demo_relations.tscn`（F6 可跑）+ `tests/_demo_relations_event.gd`：
  - 从三个 `.tres` 原型 `spawn()` 出运行时实例，放进 `Era.state.角色簿`；
  - 用混合格子显示 3×3 关系矩阵（行=谁，列=对谁）；
  - 按钮：女儿对玩家好感 +10、玩家对女儿好感 +10、让女儿管玩家叫“爸爸”；
  - 显示称呼回退（默认 → 对方默认称呼 → 真名）和自定义称呼。

**校验**

- `tests/check_relations.tscn/.gd`：
  - `.tres` 原型加载、`is_prototype`、组件类型、初始关系值；
  - `spawn` 出的实例组件不与原型共享；
  - 关系有方向（玩家→女儿 50 ≠ 女儿→玩家 20）；
  - 称呼回退 + 自定义；
  - 改实例不影响原型；
  - `CharacterBook` 三角色增查。

## 验收结果

- 13 个校验场景全部 `CHECK OK`（原 12 个 + `check_relations`）。
- `tests/demo_relations.tscn` headless 加载无报错，F6 可跑。
- 截图：
  - `experiment/shots/relations_initial.png`：关系矩阵初始（50/20/10/30）
  - `experiment/shots/relations_callname.png`：女儿对玩家→30，称呼“爸爸”

## 已知限制

- 关系不自动对称（每条边都是内容/原型里显式写的；要不要“改一边自动改另一边”是游戏规则，没塞进引擎）。
- 称呼只有“我 → 别人”的出边；`name_for()` 需要对方 `Character` 实例（内容里从角色簿取）。
- 原型组件目前都是默认值（生命 100/100、好感上限 100）；字段具体含义等你的游戏设定再定。
- 还没有 KOJO；没有存档；`spawn` 的组件副本用 `to_fields/apply_fields`（已准备好以后接存档）。

## 文件清单

- 新增：`content/characters/prototypes/玩家.tres`、`女儿.tres`、`女仆.tres`、`tests/check_relations.tscn/.gd`、`tests/demo_relations.tscn`、`tests/demo_relations.gd`、`tests/_demo_relations_event.gd`、`docs/step-8-report.md`
- 修改：`tests/_demo_relations_event.gd`（“现在”行显示称呼）
