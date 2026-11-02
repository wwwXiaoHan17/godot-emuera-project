# my-test 引擎 v1 设计（v2）

> 状态：待审阅。审阅通过后才开始写引擎代码。
> 日期：2026-10-20
> v2 修改：去掉 `Era.goto`（改成“事件 return 下一个事件”）；style/align 改用枚举；文字行按是否含 BBCode 自动选 Label / RichTextLabel。

## 0. 一句话

**常驻壳 + 命令式内容 + 挂载式页面 + Resource 数据 + 没有 goto。**

- 壳（背景、滚动区、历史文字、主题、输入等待）全局只做一份，永远不换。
- 内容脚本用命令一行一行“印”东西，流程用 `await` 停住等玩家。
- 需要整块特殊画面的地方，用 `.tscn` 做页面，**插进壳里**，用完拿掉。
- 事件之间不用 goto、不用 `change_scene`：**事件的 `run()` 直接 `return` 下一个事件脚本**。

## 1. 背景与结论（为什么是这个形态）

目标：做一个 GDScript 的 Era 风格引擎，画面要有 Emuera 味道，写内容要顺手，数据用 Godot Resource。做得好就替代 GDEmuera。

三个实验（都在 `experiment/`，可 F6 跑，截图在 `experiment/shots/`）：

| | A：常驻壳 | B：change_scene | C：混合 |
|---|---|---|---|
| 换页时换掉什么 | 什么也不换 | 整棵场景树 | 壳里的一块内容 |
| 历史文字 | 一直在 | 换页就没 | 一直在 |
| 跨页流程 | 不断 | 当场断 | 不断 |
| 特殊页面能在编辑器里摆 | 不能 | 能 | 能 |
| 每页重复背景/滚动区 | 不用 | 要 | 不用 |

结论：选 **C**。依据：

- Godot 源码：`change_scene_to_file` 同步读盘 + 同步 `instantiate`；调用瞬间 `root->remove_child(current_scene)`，帧末才 `memdelete`。旧场景里的 await 流程会随节点一起死（B 版实测报错 `Invalid access ... 'process_frame' ... null instance`）。
- Emuera 源码：`@EVENT` 是状态机调用的函数，`GOTO` 只跳本函数内 `$` 标签；控制台是全局一份（`GlobalStatic.Console`），事件切换不清屏。所以“事件 ≠ 场景”。
- era-electron：没有 goto、没有场景概念，内容就是一个 async 入口函数 + 一个全局行列表；`era.print` / `await era.input()` 这种命令式写法就是“不别扭”的来源。
- GDEmuera：只吸收“数据用 Resource 而不是 CSV”和事件/存档骨架；画面与写法不沿用。

`change_scene` 只保留给极低频的整页边界（例如将来有独立的启动器/游戏分区），不参与事件跳转。

## 2. 目录结构

```
engine/
  era.gd                 # 自动加载（Era）：命令 API + 事件循环 + 枚举 + 屏幕管理
  era_screen.tscn        # 主屏：背景 + 滚动区 + 行容器 + 页面槽
  era_screen.gd          # 主屏脚本（少量：把行加进容器、滚动、清屏）
  era_event.gd           # 内容事件基类：func run(context: EventContext) -> GDScript（返回下一个事件，null = 结束）
  era_screen_page.gd     # 挂载页面基类：signal finished(result)
  era_palette.tres       # 文字颜色（Resource：normal / dim / accent / danger，改一处）
  game_state.gd          # 游戏状态 Resource
  rows/text_row.tscn     # 文字行（内含 Label + RichTextLabel 两个节点，按需切换）
  rows/text_row.gd
  rows/button_row.tscn   # 按钮行（Button，自动带 [数字]）
  rows/button_row.gd
  rows/rule_row.tscn     # 分割线行
  rows/rule_row.gd
  rows/grid_row.tscn     # 多列选择格子（常驻块 + 局部更新）
  rows/grid_row.gd
content/
  events/title.gd        # 标题事件（把 start.tscn 的内容改写成命令）
  events/new_game.gd     # 开始新游戏：挂载角色创建页（名字/年龄）
  events/talent_select.gd # 天赋选择：文本流多列格子（TalentData + 互斥灰显）
  events/day_start.gd    # 下一屏示例事件
  screens/character_create.tscn / .gd   # 特殊页面（名字 + 年龄；天赋在 talent_select）
resources/talent_resource/
  无知.tres / 幼稚.tres / 早熟.tres / 性压抑.tres / 易漏尿.tres   # TalentData（天赋）
assets/themes/normal_theme.tres          # 继续用（字体/字号/按钮/输入框）
main.tscn / main.gd      # 项目主场景：只负责启动第一个事件
```

运行方式：`Era` 自动加载在 `_ready` 里把 `era_screen.tscn` 放进一个 `CanvasLayer`（保证在所有内容之上）；`main.gd` 调 `Era.start(preload("res://content/events/title.gd"))` 启动。

## 3. 渲染层：壳与行部件

**壳（唯一一份，永不换）**
- 背景 ColorRect、ScrollContainer、VBox 行容器、页面槽 Slot、Theme。
- 负责：追加行、滚动、清屏、旧按钮失效、行数上限。

**行部件（一行 = 一个 .tscn）**
- 只做两件事：显示自己这一行；把交互（被点、按键对应的编号）用信号发给引擎。不认识游戏状态。
- **文字行（简单优化）**：同一个 `text_row.tscn` 里放两个节点——`Label` 和 `RichTextLabel`，默认显示 Label。
  - 文字里**没有** `[` → 用 Label（轻）。
  - 文字里**有** `[` → 启用 RichTextLabel（`bbcode_enabled = true`）来做行内颜色。
  - 判断规则简单粗暴；如果正文里真要写 `[`，用 BBCode 的 `[lb]`，或者以后加一个“强制纯文本”开关。
- 按钮行用 Button（`flat = true`，文字自动加 `[编号] `）；分割线行用 Label。
- **格子块（多列选择）**用 `GridContainer`：整块是一个行部件，一次建好 N 个 Button；之后切换选中/禁用只改颜色和 `disabled`，**不重建节点**。
  - 三态：选中＝青色、未选＝白色、禁用＝灰色（灰色点击无效）；列宽按文字区宽度均分。
  - 选择项（`print_toggle`）点击只切自己，不让 `await Era.input()` 返回；动作项（`print_button`）才返回编号。
  - 还能混入**纯文字格**（`print_cell`，不可点）：用来做状态面板（表头 + 数值）、一行“文字 + 按钮”等。
  - 实测（50 个按钮）：首次构建约 18–25ms（进屏掉一帧，可接受）；之后点击约 0.05ms。50 项 3 列约 17 行，648 高放得下，不需要分页；100+ 项再考虑分页/虚拟化。
- **分割线按 ERB 习惯占满整行**：默认符号 `╍`，按当前文字区宽度自动算重复次数（MS Gothic 16px 下：`╍` 是 8px/字 → 144 个；`■` 是 16px/字 → 72 个），调用方可以换符号（标题屏就用 `■`）。不写死数量，永远填满这一行。分割线部件只做最简单的重复；**带标题/花哨的分割线由内容自己拼字符串用 `Era.print()` 输出，需要复用就自己写辅助函数**，不塞进部件里。
- 空行先用“空文字行”表示，不单独做部件。

**颜色与样式**
- 字体、字号、按钮、输入框外观：继续放在 `normal_theme.tres`。
- 文字颜色：放在 `engine/era_palette.tres`（Resource，四个字段：`normal / dim / accent / danger`）。行部件按 `style` 取色并覆盖到当前显示的节点上（Label 用 `font_color`，RichTextLabel 用 `default_color`）。改颜色只改这个 Resource。
- 对齐：`align` 应用到 Label 的 `horizontal_alignment`；RichTextLabel 没有这个属性，就用 `[center]` / `[right]` BBCode 包一层。

**引擎统一处理的坑（A 版实测出来的，内容脚本不用管）**
1. 清屏不能用 `free()` 正在发信号的按钮：先 `remove_child`，再 `queue_free`。
2. 每次 `input()` 结束后，旧按钮 `disabled = true` 并变灰；否则旧编号会串到下一次等待。
3. 追加行后滚到底要等两帧，再按内容高度算目标位置；只等一帧滚不动。
4. 清屏后滚动位置归零，并强制重算一次最小尺寸；否则画面空白、滚动条不消失。
5. 行数上限（默认 500 行）：超过就丢掉最旧的，避免节点只增不减。

## 4. 写作层：命令 API

样式用枚举（定义在 `era.gd`，内容里写 `Era.Style.DIM`，编辑器有补全和类型提示）：

```gdscript
enum Style { NORMAL, DIM, ACCENT, DANGER }
```

对齐不另造枚举，直接用 Godot 的 `HorizontalAlignment`：`HORIZONTAL_ALIGNMENT_LEFT / CENTER / RIGHT`。

第一版命令表（内容脚本里只出现这些）：

| 命令 | 作用 |
|---|---|
| `Era.print(text: String, style: Style = Style.NORMAL, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT)` | 追加一行文字；支持 BBCode 行内颜色 |
| `Era.print_button(text: String, id: int, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT)` | 追加一个按钮行，自动显示 `[id]`；在格子模式下变成“动作项” |
| `Era.begin_grid(columns: int = 3)` | 开始收集一块多列格子 |
| `Era.print_toggle(text: String, id: int, selected: bool = false, disabled: bool = false)` | 格子里加一个选择项（点击只切自己，不打断流程） |
| `Era.print_cell(text: String, style: Style = Style.NORMAL, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT)` | 格子里加一个纯文字格（不可点；做状态面板/表头/“文字+按钮”混排） |
| `var grid := Era.end_grid()` | 结束收集、构建并挂上格子块；返回格子句柄 |
| `Era.print_rule(char: String = "╍")` | 追加一条占满整行的分割线；带标题/花哨样式由内容自己拼字符串用 `Era.print()` 输出 |
| `Era.print_gap(n: int = 1)` | 追加 n 个空行 |
| `Era.clear()` | 清空当前屏幕（文字流 + 旧按钮） |
| `await Era.input() -> int` | 等玩家点按钮或按数字键，返回选中的 id |
| `await Era.wait_key()` | 等任意键/点击 |
| `await Era.print_wait(text: String, style: Style = Style.NORMAL, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT)` | `print` + `wait_key` 的语法糖；调用时必须 `await` |
| `await Era.show_screen(scene: PackedScene, data: Dictionary = {}) -> Variant` | 挂载特殊页面；入树前用 `configure(data)` 传输入，返回页面交出的结果 |
| `Era.state` | 游戏状态 Resource（只装 `character_book`；事件里拿角色用 `context.character(id)` / `context.player`） |

说明：
- **没有 `goto`**。事件跳转用普通 GDScript 的 `return`：`return 下一个事件脚本`，返回 `null` 表示流程结束。引擎循环执行，事件之间不会嵌套 `await` 成一条长链。
- `print` 与 GDScript 全局函数同名。引擎内部禁止直接调用全局 `print`（用 `push_warning` 或引擎日志方法），内容脚本不受影响。若后面发现编辑器警告太吵，再统一改名。
- `input()` 只认“这一轮”的按钮：上一次 `input()` 结束后，旧按钮会被禁用并从“可接受编号”列表里移除；键盘数字只匹配当前这一轮的按钮。
- 格子句柄（`end_grid()` 的返回值）方法/信号：`get_selected() -> Array[int]`、`is_selected(id)`、`is_disabled(id)`、`set_selected(id, bool)`、`set_disabled(id, bool)`、`toggled(id, selected)` 信号；`get_button(id)` 只给校验场景用。
- 格子里的**选择项点击不会让 `input()` 返回**；只有动作项会。互斥/选择上限这类业务规则由内容接 `grid.toggled` 自己算，引擎只负责“灰色不能点”。
- 格子里的**纯文字格**没有编号、不可点；样式用 `Era.Style`，对齐用 `HorizontalAlignment`。
- 按钮编号第一版支持 0–9 的键盘选择；格子里超过 9 的编号先用鼠标点，多位数输入以后再单独做。
- 内容示例：

```gdscript
extends EraEvent

const DayStart: GDScript = preload("res://content/events/day_start.gd")

func run(context: EventContext) -> GDScript:
    var daughter := context.character(&"daughter")
    var life := daughter.get_component(LifeComponent) as LifeComponent
    Era.clear()
    Era.print("你醒了过来。")
    Era.print("窗外还没天亮。", Era.Style.DIM)
    Era.print("有些[color=#ff8888]不对劲[/color]。")
    Era.print("标题居中一下", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
    Era.print_rule()
    Era.print_button("起床", 0)
    Era.print_button("继续睡", 1)
    match await Era.input():
        0:
            life.hurt(10)
            return DayStart          # 下一个事件；不是 goto，是普通的 return
        _:
            Era.print("你又睡了过去。")
    await Era.wait_key()
    return null                      # 流程结束
```

数据不再写在 `GameState` 的扁平字段里：事件里用 `context` 取人，数据从角色组件取：

```gdscript
var daughter := context.character(&"daughter")
var life := daughter.get_component(LifeComponent) as LifeComponent
life.hurt(10)
```

## 5. 事件与流程

- 事件 = 一个 `.gd` 脚本，`extends EraEvent`，写 `func run(context: EventContext) -> GDScript`：
  - 返回一个脚本 → 引擎接着执行它；
  - 返回 `null` → 流程结束。
- 引擎每次执行事件前打包一个 `EventContext`（`state` + `player`＝protagonist 绑定），**每事件一包**：主角中途换绑后，下一个事件拿到新值。
- 引擎循环（示意）：

```gdscript
var next_script: GDScript = start_script
while next_script != null:
    var event := next_script.new() as EraEvent
    var context := EventContext.new()
    context.state = state
    context.player = _protagonist()
    next_script = await event.run(context)
```

- 事件里的统一口径：**拿数据用 `context`（人、主角、状态），做事用 `Era.*`（print / input / kojo / show_screen）**。取人写 `context.character(id)` / `context.player`，不要在内容里翻 `Era.state.character_book`。

- 事件之间不嵌套 `await`：A 事件 `return B` 之后，A 的协程就结束了，B 由引擎循环启动。长流程不会把调用栈越叠越深。
- 事件有两种写法，语义不同：
  - **重启当前事件**：`return get_script() as GDScript`。会创建同类新事件，局部变量重置；`Era.state`、角色组件、资源不自动重置。
  - **当前事件内循环**：`while true:`。保留同一个事件实例和局部变量，适合面板反复交互；离开时再 `return 另一个事件脚本`。
- 特殊页面 = 一个 `.tscn`，根脚本 `extends EraScreenPage`，实现 `configure(data)`；`Era.show_screen(scene, data)` 在页面入树前调用它，页面只使用这里传入的数据，完成后发 `finished(result)`。页面不读取或修改 `Era.state`。
- 第一版不做存档/读档，但 `Era.state` 已经是 Resource，后面加存档不需要改内容写法。

## 6. 数据（Resource，不用 CSV）

- `GameState`：一个 Resource，只装整局游戏的容器；角色自己的数据在 `Character` 的组件里：

```gdscript
class_name GameState extends Resource

@export var character_book: CharacterBook = CharacterBook.new()
```

- 角色、天赋、配置都用 Resource（`TalentData` 已经是对的样子）。素材数据放 `data/`，现有 `resources/talent_resource/*.tres` 直接搬或引用。
- 数值一律用 int/float 的 Resource 字段，不拼字符串、不读 CSV。
- 新游戏时由引擎创建一个新的 `GameState`；读档以后再覆盖它（第一版不做读档）。

## 7. 组件拆分规则（回答最初的问题）

- **一行 = 一个行部件**；一种“行类型” = 一个 `.tscn`（文字行、按钮行、分割线行……）。
- **整块出现、整块消失的画面** = 一个页面 `.tscn`（挂载式），比如角色创建。
- **一整块多列选项** = 一个格子块行部件（`grid_row`），里面所有格子参与同一次输入等待。
- 判断标准一句话：**逐行往上长的 → 行部件；整块进出的 → 页面场景；一格一格的选项 → 格子块。**
- 不为“半行”“行内小碎片”单独做组件；跨行共享的颜色放 `era_palette.tres`，字体/按钮外观放 Theme，不靠拆组件。
- 清屏、旧按钮失效、滚动、行数上限，全部是引擎的事，内容脚本不写这些代码。

## 8. 实现步骤（按顺序）

**第 1 步：壳 + 命令 + 标题屏**
- 做 `Era`、`era_screen.tscn`、三种行部件、命令 API、点击/数字键输入。
- 把 `start.tscn` 的内容改写成 `content/events/title.gd`。
- 验收：F6 跑起来，画面和现在的标题屏一致；点按钮/按数字能返回编号；无报错。

**第 2 步：事件流程 + 状态**
- `EraEvent`（run 返回下一个事件）、`Era.start`、`Era.state`、`wait_key`。
- `title.gd` 能 `return DayStart`，`day_start.gd` 跑通：文字 → 选项 → 改数值 → 下一屏。
- 验收：连续走完两屏，状态数值正确变化。

**第 3 步：挂载页面 + Resource 数据**
- `EraScreenPage` + `Era.show_screen`；把 `first_game.tscn` 改造成 `character_create.tscn`。
- 验收：换页面时历史还在、流程不断；页面能 F6 单独跑。

**第 4 步：多列选择格子（布局扩展）**
- `GridContainer` 格子块：`begin_grid` / `print_toggle` / `print_button` / `end_grid`。
- 常驻块 + 局部更新：点击只改颜色/禁用，不重建；三态（选中青/未选白/禁用灰）。
- 选择项点击不返回，动作项才返回；互斥逻辑放内容（接 `toggled` 信号）。
- 验收：`check_grid` 校验场景 + demo 场景 F6 可跑；实测点击耗时 &lt; 1ms。
- 追加：混合格子 `print_cell`（纯文字格），状态面板 / “文字+按钮”混排；`check_mixed_grid` 校验。

**第 5 步：天赋场景接入（真实内容）**
- `talent_select.gd`：5 个 `TalentData` → 3 列格子；互斥用 `conflicts_with` 灰显。
- 流程改成：标题 → 角色创建页（名字/年龄）→ 天赋选择 → 第 1 天。
- 验收：`check_talent_select` + 全链路 `check_day_start`；截图见 `docs/step-6-report.md`。

每一步都用 Godot 实际跑 + 截图对照；每步旁边放一个小校验场景（headless 也能跑，检查行数/文字/返回编号）。

## 9. 代码约定（你要参与编写与 Code Review）

- 每个文件中文注释，目标每个 ≤ 150 行；一次只加一个小模块。
- 命名：代码标识符与程序字符串 ID 用英文（`Era.print`、`character_book`、`player/daughter`）；玩家可见文本、中文文档和既有资源文件名保持中文。组件字段也用英文（`value/max_value`）。
- 统一口径：**拿数据用 `context`（人、主角、状态），做事用 `Era.*`（print / input / kojo / show_screen）**。事件与口上函数一律从入参 `context` 取人（`context.character(id)` / `context.player`），不在内容里直接调 `Era.character()` 或翻 `Era.state.character_book`（那是引擎内部与测试的写法）。
- 每个文件写完我先用两三句话讲清楚它做什么、怎么用，你 Code Review 通过后再继续。
- 第 1 步开始前清理旧实验文件：`_tmp_check.gd`、`main.tscn*.tmp`、空的 `to_dict.gd`、旧 `main.gd`、旧 `MainScene` 自动加载。
- 不引入测试框架；用“校验场景 + 截图”代替。实验目录 `experiment/` 保留作证据，引擎稳定后可以删。

## 10. 已知风险

- RichTextLabel 行数多时性能下降：先按“没 BBCode 就用 Label”的规则把大部分行降成 Label；仍有压力再换“单 RichTextLabel 分段追加”或自绘。
- 文字行里含 `[` 会被当成 BBCode：正文要写 `[` 时用 `[lb]`；以后需要再加开关。
- `ScrollContainer` 的滚动条/最大尺寸有缓存问题（C 版已遇到并绕过）；封装在引擎里，不扩散到内容。
- 按钮获得焦点时空格/回车会被它吃掉：键盘输入用 `_unhandled_key_input`，必要时先释放焦点。
- 格子块首次进屏要建 50 个 Button，约 18–25ms，会掉一帧；以后可以分帧构建（现在接受一次性代价）。
- 格子超过 100 项时：优先内容分页；真需要长列表再上虚拟化/单个 RichTextLabel 渲染（实测 50 行 BBCode 仅 ~0.6ms）。
- 多位数键盘输入（`9999` 这类编号）还没做；目前格子里的编号用鼠标点。
- 格子里的选择项还不能用键盘切换（鼠标点）；以后做“选择项键盘操作”时再加。
- 天赋列表在 `talent_select.gd` 里显式 `const` preload；新增天赋要加一行（导出后不依赖目录扫描）。
- Godot 4.8-dev7 是开发版：项目锁这个版本；升级前重跑三个实验与校验场景。
- 主题与调色板先手写 `.tres`，引擎跑起来后再进编辑器调；改动集中在两个资源里。

## 11. 参考与证据

- 实验：`experiment/README.md`；A/B/C 三个场景；`experiment/shots/` 截图（含 A 修复前 bug 现场、C 挂载页与返回画面）。
- Godot 源码结论：`scene/main/scene_tree.cpp` 的 `change_scene_to_file/packed/node` 与 `_flush_scene_change`；`main/main.cpp` 里 `process()` 之后才 draw。
- Emuera 源码：`Process.SystemProc.cs` 事件调用；`Process.State.cs` 的 `JumpTo`；`GlobalStatic.cs` / `EmueraConsole.cs` 的全局控制台。
- era-electron：`sdk/era-electron.js`（命令 API）、`src/era/model/era-start.js`（单一 async 入口）、`era-class.js`（`clear().then(game)`）。
- GDEmuera：只取 `TalentData` / Resource 数据与事件/存档思路。
