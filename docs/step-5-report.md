# 第 5 步完成记录（混合格子：文字 + 按钮 + 选择项）

> 日期：2026-10-21
> 对应设计：`docs/engine-v1-design.md`（v2，§3 / §4 / §8 已补说明）
> 前一步：`docs/step-4-report.md`

## 需求

在格子块里不只放按钮，还要能混排：

- 纯文字格：做状态面板的表头/数值，或一行里“文字 + 按钮”的说明文字；
- 动作按钮：一行放多个（休息/训练/离开）；
- 选择项：点击只切自己、不打断流程。

## 实现

- `engine/rows/grid_row.gd`：格子项新增 `kind = "text"`，用 `Label` 显示（自定义颜色、`horizontal_alignment`、列宽均分），不参与点击/选中；`_states` / `_buttons` 只登记按钮类。
- `engine/era.gd`：新增 `print_cell(text, style = Style.NORMAL, align = HORIZONTAL_ALIGNMENT_LEFT)`，只能在 `begin_grid / end_grid` 之间用，颜色由 `Era.Style` 经调色板换算后传给格子。
- 演示：`tests/demo_mixed_grid.tscn`（F6 可跑）+ `tests/_demo_mixed_grid_event.gd`。
  - 状态面板：3 列文字格（名字/年龄/体力精力，表头 DIM、数值 ACCENT）；
  - 一行三个动作按钮：休息 / 训练 / 离开；
  - 一行“文字 + 两个按钮”：心情 / 开朗 / 阴郁；
  - 一行“两个选择项 + 说明”：早睡 / 运动 / ↑ 点了只切自己。
- 校验：`tests/check_mixed_grid.tscn/.gd` + `tests/_drive_mixed_grid.gd`。

## 验收

- `check_mixed_grid` 通过：文字格是 Label、颜色/对齐正确；选择项可点；禁用项无效；动作项让 `input()` 返回；结束后整块失效。
- `check_grid`（第 4 步）仍通过；9 个旧校验也全部通过（共 10 个）。
- 截图：
  - `experiment/shots/mixed_initial.png`：初始画面（表头/数值 + 一行三按钮 + 心情行 + 选择项行）；
  - `experiment/shots/mixed_after_train.png`：点“训练”后数值 90/95；
  - `experiment/shots/mixed_toggle.png`：点“早睡”后变青色；
  - `experiment/shots/mixed_summary.png`：离开后的总结（早睡：是）。

## 已知限制

- 文字格只支持 `Label`（不支持 BBCode 行内颜色）；需要行内混色时以后再给 text 格加 RichTextLabel 分支。
- 文字格没有 `id`，不参与 `input()`；如果需要“点文字执行动作”，用动作按钮。
- 键盘仍只支持单数字 0–9；`9999` 这类编号用鼠标点。
- 首次进屏构建整块仍有约 18–25ms 的一次性开销（50 个按钮）。

## 文件清单

- 新增：`tests/demo_mixed_grid.tscn`、`tests/demo_mixed_grid.gd`、`tests/_demo_mixed_grid_event.gd`、`tests/check_mixed_grid.tscn`、`tests/check_mixed_grid.gd`、`tests/_drive_mixed_grid.gd`、`docs/step-5-report.md`
- 修改：`engine/era.gd`（`print_cell`）、`engine/rows/grid_row.gd`（文字格）、`docs/engine-v1-design.md`
