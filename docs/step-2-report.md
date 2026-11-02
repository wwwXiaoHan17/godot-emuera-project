# 第 2 步完成记录（事件接力 + 状态跨事件）

> 日期：2026-10-20
> 对应设计：`docs/engine-v1-design.md`（v2）
> 前一步：`docs/step-1-report.md`

## 这一步做完了什么

**新增事件**

- `content/events/day_start.gd`：第 1 天的开头。
  - 顶部一条分割线、强调色的“第 1 天”、名字/年龄/体力/精力、再一条分割线；
  - 三个选项：出去走走（体力 -10、精力 -5）、在家休息（体力 +5、精力 +10）、返回标题；
  - 改完数值后用 `await Era.wait_key()` 停一下，再 `return null` 结束流程。

**标题屏接线（`content/events/title.gd`）**

- `[1] 开始游戏` → `return DayStart`（事件接力）。
- `[2] 继续游戏` → 打印“还没有存档。” → 等任意键 → 回到标题。
- `[3] 关于游戏` → 打印一句说明 → 等任意键 → 回到标题。
- 自己加载自己用运行时 `load()`，避免 title ↔ day_start 互相 `preload` 的循环引用。

**校验**

- 新增 `tests/check_day_start.tscn/.gd`：标题 → 开始游戏 → day_start（9 行）→ 出去走走 → 体力 90 / 精力 95、多 1 行 → 按任意键 → `flow_finished`。
- 更新 `tests/check_title.tscn/.gd`：覆盖“继续游戏 / 关于游戏”两条回标题的路径（15 行 → 等键 → 重新 14 行）。

## 验收结果

7 个校验场景全部 `CHECK OK`：

```
check_foundations  check_text_row  check_button_rule  check_era_screen
check_era_commands check_title     check_day_start
```

实际画面：`experiment/shots/day_start.png`。

## 实际跑的时候发现并修掉的一个问题

**症状**：点“继续游戏”出现“还没有存档。”之后，在窗口里点鼠标没反应，看起来像卡死、无法重复。

**原因**：`wait_key()` 原来只监听键盘（`_unhandled_key_input`），鼠标点击唤不醒它；
而且背景 `ColorRect` 会把点击吃掉，`_unhandled_input` 也收不到。

**修法**：引擎用 `_input` 接管鼠标左键（GUI 处理之前），`wait_key` 期间左键点击也唤醒；
`check_title` 里“关于游戏”路径改成用真实 `InputEventMouseButton` 测试。

修复后实测：标题 ↔ 第 1 天来回 2 轮、继续游戏 + 按键 2 轮、继续游戏 + 鼠标点击 1 轮，都正常。

## 已知限制（第 2 步范围内）

- 名字还没地方创建（显示“（未创建）”），要等第 3 步的角色创建页。
- 天数固定“第 1 天”，`GameState` 还没有天数/日期字段；做多天循环时再加。
- 没有存档：改完的数值只在这一次运行里有效。

## 下一步（第 3 步）

- 挂载式特殊页面：`Era.show_screen()` + 页面基类 `EraScreenPage`。
- 把旧 `first_game.tscn`（角色创建）改造成挂载页面，天赋用 `TalentData` Resource。
- 验收：页面挂载/拿掉时历史文字和流程都不丢；页面能 F6 单独跑。
