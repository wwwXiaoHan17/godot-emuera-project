# 第 14 步完成记录（Era.print_wait）

> 日期：2026-10-25
> 前一步：`docs/step-13-report.md`（清理旧字段 + 整理文件）

## 做了什么

新增 `Era.print_wait(text, style, align)`：打印一行后等任意键/鼠标左键，等价于：

```gdscript
Era.print("按任意键返回。", Era.Style.DIM)
await Era.wait_key()
```

改成：

```gdscript
await Era.print_wait("按任意键返回。", Era.Style.DIM)
```

- 参数和 `Era.print()` 完全一致（text / style / align，支持 BBCode）；
- 不自动补“按任意键继续”，也不清屏；
- **调用时必须 `await`**；忘了 await 会打印并开始等待，但后面的代码会立刻继续。

## 改动文件

- `engine/era.gd`：新增 `print_wait`；
- `tests/check_print_wait.gd/.tscn` + `tests/_drive_print_wait.gd`：
  - 打印后流程停住；
  - 颜色/对齐沿用 print 参数；
  - 按键后打印第二行，再按键结束；
- `content/events/show_component.gd`：把“按任意键返回”改成 `await Era.print_wait(...)` 做示范。

## 验证

- 新校验 `check_print_wait` 通过；
- 全量 16 个校验场景全部 `CHECK OK`；
- 主场景、`demo_mixed_grid`、`demo_show_component` headless 无报错。

## 顺手修掉的测试滞后

跑全量时发现 3 个旧校验没跟上你改的组件字段：

- `EnergyComponent` 的 `值/上限` → `value/max_value`；
- `AffectionComponent.上限` → `max_value`；
- 第 1 天菜单多了“查看女儿携带的组件”，行数 12 → 13。

已更新 `check_character`、`check_day_start`、`check_talent_select` 和 `_demo_mixed_grid_event`；组件本身没动。
