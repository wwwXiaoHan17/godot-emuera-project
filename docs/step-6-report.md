# 第 6 步完成记录（把格子接进真实天赋场景）

> 日期：2026-10-21
> 对应设计：`docs/engine-v1-design.md`
> 前一步：`docs/step-5-report.md`

## 需求

把多列选择格子接进实际游戏的天赋场景：用 `TalentData` Resource 生成天赋列表，选中青色、未选白色、互斥项灰色，选完确认进入第 1 天。

## 现在的流程

```
标题
 └─[1] 开始游戏 → new_game（挂载式角色创建页：名字 / 年龄）
        └─ 按任意键 → talent_select（文本流多列格子：天赋）
              └─ 确认 → 写 Era.state.天赋 → 第 1 天
              └─ 返回 → 回到角色创建页（名字/年龄会回填）
```

## 实现

**新增事件 `content/events/talent_select.gd`（review/学习重点）**

- 天赋列表显式 preload 5 个 `TalentData` Resource（无知 / 幼稚 / 早熟 / 性压抑 / 易漏尿）；
- `begin_grid(3)` → 每个天赋一行 `print_toggle` → 一个占位 `print_cell("")` → 确认/返回按钮 → 说明文字格；
- 拿 `end_grid()` 的句柄接 `toggled` 信号，用 `TalentData.conflicts_with` 做互斥：
  - 选中一个 → 冲突项 `set_selected(false)` + `set_disabled(true)`（变灰）；
  - 取消选中 → 冲突项 `set_disabled(false)`（恢复）；
- 确认：把 `grid.get_selected()` 的编号（= 列表序号 + 1）还原成 `talent_name`，写入 `Era.state.天赋`；
- 返回：`return NewGame`，回到角色创建页。

**改动**

- `content/events/new_game.gd`：页面只收名字/年龄；等键后 `return TalentSelect`（不再直接进第 1 天）。
- `content/screens/character_create.tscn/.gd`：去掉天赋勾选框，只保留名字/年龄；从 `Era.state` 回填（从天赋页返回时不丢数据）；按钮文字改“[下一步：选天赋]”。
- 新增 3 个天赋 Resource：`resources/talent_resource/无知.tres`、`性压抑.tres`、`易漏尿.tres`（加上原有 幼稚/早熟 共 5 个）。
- `tests/check_character_create.gd`：去掉天赋断言，改为断言只交名字/年龄。
- 新增 `tests/check_talent_select.gd/.tscn`：5 个天赋生成格子、选中/互斥灰显/灰色点击无效/反选恢复/确认写状态/进第 1 天。
- `tests/check_day_start.gd`：整条链路更新为 标题 → 角色页 → 天赋格子 → 第 1 天。

## 验收

- 11 个校验场景全部 `CHECK OK`（原 10 个 + `check_talent_select`）。
- 主场景 headless 无报错；demo 场景 F6 可跑。
- 截图：
  - `experiment/shots/talent_initial.png`：天赋屏初始；
  - `experiment/shots/talent_exclusive.png`：选“幼稚”后“早熟”变灰；
  - `experiment/shots/talent_summary.png`：确认后“已选天赋：幼稚”；
  - `experiment/shots/talent_day.png`：第 1 天显示“天赋：幼稚”。

## 已知限制

- 格子里的选择项暂时只能鼠标点；键盘只认动作按钮的 0–9 编号（多位数/选择项键盘操作以后做）。
- 天赋列表是 `talent_select.gd` 里的显式 `const`；新增天赋要在这里加一行（导出后不依赖目录扫描）。
- 互斥规则目前只处理“一对多”简单情况（选中灰掉冲突项、取消恢复）；同时选多个冲突源的复杂规则以后扩展。
- “返回”会回到角色创建页，但不会清空已填名字/年龄（这是故意的，方便改）。

## 文件清单

- 新增：`content/events/talent_select.gd`、`tests/check_talent_select.gd/.tscn`、`resources/talent_resource/无知.tres`、`性压抑.tres`、`易漏尿.tres`
- 修改：`content/events/new_game.gd`、`content/screens/character_create.tscn/.gd`、`tests/check_character_create.gd`、`tests/check_day_start.gd`、`docs/engine-v1-design.md`
- 新增记录：`docs/step-6-report.md`
