# 第 1 步完成记录（引擎骨架 + 标题屏）

> 日期：2026-10-20
> 对应设计：`docs/engine-v1-design.md`（v2）
> 对应计划：`docs/superpowers/plans/2026-10-20-engine-v1-step1.md`

## 这一步做完了什么

**引擎（`engine/`）**

| 文件 | 作用 |
|---|---|
| `era.gd` | 自动加载单例：命令 API（print / print_button / print_rule / print_gap / clear / await input / await wait_key）、输入等待、事件循环、`Style` 枚举、`Era.state` |
| `era_screen.tscn` / `.gd` | 常驻壳：背景 + 滚动区 + 行容器 + 页面槽；追加行、500 行上限、清屏、滚到底、按文字区宽度算字数 |
| `era_palette.gd` / `.tres` | 文字颜色 Resource（normal / dim / accent / danger），改颜色只改这里 |
| `game_state.gd` | 游戏状态 Resource（中文属性：名字 / 年龄 / 体力 / 精力） |
| `era_event.gd` | 事件基类：`run() -> GDScript`，返回下一个事件脚本，`null` 结束 |
| `rows/text_row.tscn` / `.gd` | 一行文字：无 BBCode 用 Label，含 `[` 自动切 RichTextLabel |
| `rows/button_row.tscn` / `.gd` | 一行按钮：自动 `[id]` 前缀、不抢键盘焦点、选完可失效 |
| `rows/rule_row.tscn` / `.gd` | 一行分割线：按字符宽度重复填满整行 |

**内容与入口**

- `content/events/title.gd`：把旧 `scenes/event_tscn/start.tscn` 的画面用命令重写（点阵字 / 分割线 / 三个按钮）。
- `main.tscn` / `main.gd`：项目入口，启动 `title.gd`。
- `project.godot`：主场景改为 `res://main.tscn`；自动加载只留 `Era`；旧的 `MainScene` 自动加载已移除。

**清理**

- 删除：`_tmp_check.gd`、`main.tscn*.tmp`、`scripts/to_dict.gd`、`scenes/event_tscn/main.gd`、`scenes/event_tscn/main.tscn`。
- 保留：`scenes/event_tscn/start.tscn`、`first_game.tscn`（第 2/3 步对照用）、`experiment/`（设计与实验证据）。

## 怎么跑

**编辑器里**：打开项目 → F5。
> 如果编辑器一直开着旧状态，执行一次 `Project → Reload Current Project`，避免它把旧的 `project.godot` 写回去。

**headless 校验**（每个都应该输出 `CHECK OK`）：

```powershell
$godot = 'C:\Users\30873\Desktop\Godot\Stable\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64_console.exe'
$scenes = @(
  'res://tests/check_foundations.tscn',
  'res://tests/check_text_row.tscn',
  'res://tests/check_button_rule.tscn',
  'res://tests/check_era_screen.tscn',
  'res://tests/check_era_commands.tscn',
  'res://tests/check_title.tscn'
)
foreach ($scene in $scenes) {
  & $godot --headless --path 'E:\MyCode\GodotCode\my-test' $scene --quit-after 300
}
```

## 验收结果

- 6 个校验场景全部 `CHECK OK`。
- headless 跑主场景：无 `SCRIPT ERROR`。
- 标题屏截图与旧 `start.tscn` 同尺寸对照：点阵字、颜色、按钮、分割线一致；
  连 PNG 大小都只差 1 字节（`experiment/shots/title_new.png` vs `experiment/shots/start_old.png`）。
- 已确认的布局选择：**顶部对齐 + 左右 24px 边距**（Emuera 控制台行为，不跟旧场景的垂直居中）。

## 已知限制（第 1 步范围内，正常）

- 键盘选择只支持数字 0–9；超过 10 个选项以后再扩展。
- 分割线按“打印那一刻”的宽度算；窗口缩放后已打印的分割线不会自动重排（重新打印即可）。
- 行数上限 500，超出丢最旧的。
- 没有存档/读档；特殊页面（挂载式 `.tscn`）还没接（第 3 步）。
- 标题屏的选项目前只打印“你选了 N”，还没接到真正的事件流（第 2 步）。

## 下一步（第 2 步）

- 写 `content/events/day_start.gd`，把标题屏的选择接到下一个事件。
- 验证：`return 下一个事件脚本` 接力、`Era.state` 数值跨事件保留、`wait_key` 正常。
