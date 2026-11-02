# Task 0 Brief: 基线修复（用户 type_a 流程后的测试同步）

## 背景

用户改了主流程（这是有意的，**不许改任何 `content/` 文件**）：

1. `content/events/title.gd` 已删除；`main.gd` 现在启动 `content/events/type_a_title.gd`（新标题屏，布局多了空行）。
2. `talent_select.gd` 确认天赋后现在 `return TypeANewGame`——先进入 `type_a_new_game.gd`（一段 `print_wait` 剧情，中间有一个双按钮 `Era.input`：0=亲生女儿 / 1=继女），结束后才 `return day_start.gd`。

结果是 3 个校验红了（当前基线 14/17）：

- `tests/check_title.tscn` → 解析错误：preload 了已删除的 `title.gd`
- `tests/check_day_start.tscn` → 同上
- `tests/check_talent_select.tscn` → "进入第 1 天应有 13 行，实际 2"（被 type_a_new_game 挡住了）

你的任务：**只改这 3 个测试文件**，让它们跟上新流程，恢复 17/17。

## 具体改动

### 1. `tests/check_title.gd`

- 第 7 行 preload：`title.gd` → `type_a_title.gd`
- 行数断言：标题屏 `14` → `19`（新布局 = gap5 + rule + gap2 + 6 行点阵 + gap + 3 按钮 + rule）；点"继续/关于"后追加 1 行的断言 `15` → `20`
- 两条路径（继续游戏 / 关于游戏 → 追加一行 → 等键/点击 → 重启回标题）的测试逻辑保持不变

### 2. `tests/check_day_start.gd`

- 顶部 `const TITLE := preload(...)`：`title.gd` → `type_a_title.gd`
- 标题屏等待/断言行数：`14` → `19`（`_wait_rows(14, 120)` 和 `!= 14` 都要改）
- 天赋确认后（"等键 → 第 1 天"那步）：现在是单次 `Era._resolve_key()` 后直接断言 13 行。改为**走路循环穿过 type_a_new_game**：

```gdscript
func _walk_until_day_start() -> void:
	var guard := 0
	while Era.row_count() < 13 and guard < 120:
		Era._choose(0)      # 过 type_a_new_game 的双按钮 input（非 input 期会被引擎忽略，无害）
		Era._resolve_key()  # 过 print_wait 的等键
		await get_tree().process_frame
		guard += 1
```

- 调用处：原来的 `Era._resolve_key()` + 13 行断言 → `await _walk_until_day_start()` + 13 行断言
- 循环结束后（第 1 天 13 行出现）的一切断言**原样保留**

### 3. `tests/check_talent_select.gd`

- 结尾"等键 → 第 1 天"同样改为 `_walk_until_day_start()`（加同一个辅助函数）+ 13 行断言；其余不动

## 验收

```powershell
$GODOT = 'C:\Users\30873\Desktop\Godot\Stable\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64_console.exe'
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_title.tscn --quit-after 300
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_day_start.tscn --quit-after 300
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_talent_select.tscn --quit-after 300
```

三个都输出 `CHECK OK`；然后全量跑 `tests/check_*.tscn` 17 个 → 17/17 `CHECK OK`。

## 项目约定

- GDScript 用 **Tab 缩进**；注释中文；显式类型（项目警告即错误）
- 项目不是 git 仓库：**不要 commit**，校验绿即完成
- 只允许修改上述 3 个 `tests/` 文件；`content/`、`engine/` 一律不碰
