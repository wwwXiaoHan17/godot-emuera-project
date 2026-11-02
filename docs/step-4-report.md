# 第 4 步完成记录（多列选择格子）

> 日期：2026-10-21
> 对应设计：`docs/engine-v1-design.md`（v2，已补第 4 步/格子块说明）
> 前一步：`docs/step-3-report.md`

## 需求与决定

需求：像参考图那样，一屏里用多列（3 列）排几十个**选择项**；选中青色、未选白色、无法选择/互斥灰色；底部有 `[9999] 返回`。

讨论后定下来的三件事：

1. **写法**：逐条写（`begin_grid` → `print_toggle` / `print_button` → `end_grid`）。
2. **优化**：块常驻 + 局部更新——整块只建一次，点击只改颜色/禁用，不重建。
3. **交互**：选择项点击不返回（不打断内容流程）；只有动作项（返回/确认）才让 `await Era.input()` 返回。
4. **互斥**：内容自己算（接 `grid.toggled`，用 `set_disabled` 灰显），引擎只负责三态与禁用。

## 实现

**引擎**

- `engine/rows/grid_row.tscn/.gd`：常驻多列格子块（GridContainer）。
  - 三态：选中青色 / 未选白色 / 禁用灰色（灰色点击无效）。
  - 公开句柄方法：`get_selected()`、`is_selected(id)`、`is_disabled(id)`、`set_selected(id, bool)`、`set_disabled(id, bool)`；信号 `toggled(id, selected)`、`picked(id)`；校验用 `get_button(id)`。
- `engine/era.gd`：
  - 新增 `begin_grid(columns)`、`print_toggle(text, id, selected, disabled)`、`end_grid() -> grid 句柄`。
  - 格子模式下 `print_button` 变成动作项（只有它让 `input()` 返回）。
  - `input()` 结束后会把本轮格子块整块失效（旧格子不能再点）。

**内容 / 演示**

- `tests/demo_grid_b.tscn`（F6 可跑）+ `tests/_demo_grid_b_event.gd`：
  - 54 个属性项 + 2 个互斥演示项（幼稚/早熟）+ 返回；
  - 初始选中/禁用状态；互斥项选中一个就灰掉另一个；返回后显示结果页（一行两个动作按钮）。
- `tests/_demo_grid_options.gd`：演示数据。

**校验**

- `tests/check_grid.tscn/.gd` + `tests/_drive_grid.gd`：
  - 初始选中、点击选择项切换、禁用项点击无效、`set_disabled` 生效、动作项让 `input()` 返回、结束后整块失效。

## 性能实测（50 个按钮）

| 操作 | 耗时 |
|---|---|
| 旧方案：每次点击清屏重建（含挂树） | **21–25 ms/次** |
| 新方案：整块常驻，点击只改状态 | **0.046 ms/次**（20 次平均） |
| 新方案：首次进屏构建整块 | 约 18–25 ms（一次性） |

50 项 3 列约 17 行，648 高放得下；100+ 项再考虑分页/虚拟化。

## 验收结果

- 9 个校验场景全部 `CHECK OK`（原 8 个 + 新增 `check_grid`）。
- `tests/demo_grid_b.tscn` headless 加载无报错；F6 可跑。
- 截图：
  - `experiment/shots/grid2_exclusive.png`：整块外观（选中青/未选白/禁用灰 + 互斥灰显）
  - `experiment/shots/grid2_result.png`：返回后的结果页（一行两个动作按钮）

## 已知限制

- 键盘仍然只支持单个数字 0–9；格子里的 `9999`、`900` 这类编号先用鼠标点，多位数输入以后单独做。
- 首次进屏建 50 个按钮会掉一帧（以后可以分帧构建；现在先接受）。
- 没有 hover 样式；禁用/选中只改文字颜色。
- 互斥/选择上限由内容自己管；引擎不内置业务规则。

## 文件清单

- 新增：`engine/rows/grid_row.tscn`、`engine/rows/grid_row.gd`、`tests/check_grid.tscn`、`tests/check_grid.gd`、`tests/_drive_grid.gd`、`tests/demo_grid_b.tscn`、`tests/demo_grid_b.gd`、`tests/_demo_grid_b_event.gd`、`tests/_demo_grid_options.gd`、`docs/step-4-report.md`
- 修改：`engine/era.gd`、`docs/engine-v1-design.md`
