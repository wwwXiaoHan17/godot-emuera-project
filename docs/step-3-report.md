# 第 3 步完成记录（挂载式页面 + 角色创建 + 天赋 Resource）

> 日期：2026-10-20
> 对应设计：`docs/engine-v1-design.md`（v2）
> 前一步：`docs/step-2-report.md`

## 这一步做完了什么

**引擎侧：挂载式页面**

- `engine/era_screen_page.gd`：页面基类 `EraScreenPage`，页面做好后发 `finished(result)`。
- `engine/era_screen.gd`：页面槽的开关——`show_page()` 把页面插进 `Slot` 并暂藏文字流；`hide_page()` 拿掉页面、恢复文字流（历史还在）；`page_count()` 给校验用。
- `engine/era.gd`：`await Era.show_screen(scene)`——实例化页面、插进槽、等 `finished`、拿掉、返回数据。全程没有 `change_scene`。

**内容侧**

- `content/screens/character_create.tscn/.gd`：角色创建页，由旧 `first_game.tscn` 改写。
  - 名字 LineEdit、年龄 +/-、天赋勾选框；
  - 天赋**来自 TalentData Resource**：`talent_table` 在 `.tscn` 里挂了 `resources/talent_resource/幼稚.tres`、`早熟.tres`，页面按表动态生成勾选框；
  - 页面能 F6 单独运行、单独调布局。
- `content/events/new_game.gd`：开始新游戏的流程——清屏 → 打印提示 → `await Era.show_screen(角色创建)` → 把数据写进 `Era.state` → 等键 → `return DayStart`。
- `content/events/title.gd`：`[1] 开始游戏` 改成接力到 `new_game`。
- `content/events/day_start.gd`：多打印一行“天赋：…”。
- `engine/game_state.gd`：新增 `@export var 天赋: Array[StringName] = []`。

**校验**

- 新增 `tests/check_character_create.tscn/.gd`：页面单独实例化、天赋来自 Resource、改名字/年龄/勾天赋后 `finished` 数据正确。
- 更新 `tests/check_day_start.tscn/.gd`：标题 → new_game → 页面挂载 → 模拟页面完成 → 状态写入 → 第 1 天 → 数值变化 → 结束。

## 验收结果

8 个校验场景全部 `CHECK OK`：

```
check_foundations  check_text_row  check_button_rule  check_era_screen
check_era_commands check_title     check_character_create  check_day_start
```

- `character_create.tscn` 单独 headless 加载无报错（F6 可跑）。
- headless 跑主场景无报错。
- 实际画面：
  - 挂载中的角色创建页：`experiment/shots/char_page.png`
  - 页面拿掉后的文字流（历史保留 + 创建结果）：`experiment/shots/char_after.png`

## 已知限制

- 页面是全屏覆盖（文字流暂藏）；页面拿掉后历史还在，但页面期间看不到下面的文字。
- 角色创建页暂时只有“开始游戏”，没有“取消/返回标题”。
- 天赋只有两个示例 Resource；`TalentData` 的互斥逻辑（`conflicts_with`）还没接到页面上。
- 没有存档/读档；重启游戏就是重新开始。

## 验收时修掉的一个问题：数值改了但画面不刷新

**症状**：在第 1 天选“出去走走 / 在家休息”，体力/精力其实变了，但屏幕上的
“体力：100　精力：100”那行还是旧值，看起来像没加减。

**原因**：数值确实加减了（校验断言过 90/95），但 `day_start` 只在选项里打印一句结果，
没有把新数值显示出来，也没有重画面板。

**修法**：

- 选项后多打印一行“现在：体力 X　精力 Y”（强调色）；
- 按任意键后 `return` 回 `day_start` 自己（运行时 load，避免自引用），**重画第 1 天**，
  面板显示更新后的数值。
- 校验新增：出去走走 → 12 行（结果 + 现在）、90/95；按键后重画回 10 行；
  在家休息 → 95/105，再次重画回 10 行。

实际画面：`experiment/shots/day_action.png`、`experiment/shots/day_redraw.png`。

## 下一步候选（第 1 步设计里的 v1 三步已走完）

1. 角色创建页加“取消”并处理页面返回值；天赋互斥（用 TalentData.conflicts_with）。
2. 输入行：文字输入 / 数字输入（对应 ERB 的 INPUT）。
3. 存档/读档（`GameState` 已经是 Resource，可以直接存）。
4. 多天循环：`GameState` 加天数，`day_start` 每天 +1，数值结算。
