# Task 1 Brief: EventContext 基类与 KojoContext 继承

## 背景（一段话）

引擎正在统一"事件与口上如何拿角色"：规则是**拿数据用 context（人、主角、状态），做事用 Era.\***。本任务新增事件用的 `EventContext` 工具包，并把已有的 `KojoContext` 改成它的子类——口上从此白捡一个 `character(id)` 查人方法。这是纯增量改造，`Era.kojo` 与所有事件写法在本任务里都不变。

## 文件

- Create: `engine/event_context.gd`
- Modify: `engine/kojo/kojo_context.gd`
- Test: `tests/check_kojo.gd`（"9) KojoContext 固定字段与 extras"那一段，约 96–130 行）

## 精确接口

### 新建 `engine/event_context.gd`

```gdscript
class_name EventContext
extends RefCounted
## EventContext, 事件的随身工具包
##
## 拿数据用 context（人、主角、状态），做事用 Era.*。
## player 是 CharacterBook.protagonist_id 的绑定（可为 null），不是按 id 查找。

var player: Character
var state: GameState


func character(id: StringName) -> Character:
	if state == null or state.character_book == null:
		return null
	return state.character_book.find(id)
```

### 修改 `engine/kojo/kojo_context.gd`

现状：`extends RefCounted`，自带 `speaker / player / state / extras` 四个变量。
改为：`extends EventContext`；**删除自身的 `player` 与 `state` 声明**（由继承获得）；保留 `speaker`、`extras` 和原有中文 docstring（把"固定字段"描述改为 speaker/extras + 继承 player/state/character()）。

## TDD 步骤

### Step 1: 先改 `tests/check_kojo.gd` 的 probe 段（写失败断言）

在既有 `probe_context` 断言块（`if probe_context == null:` 的 else 里）追加：

```gdscript
		if not (probe_context is EventContext):
			failures.append("KojoContext 应继承 EventContext")
		if probe_context.character(&"player") != player:
			failures.append("context.character 应能查到主角")
		if probe_context.character(&"missing") != null:
			failures.append("查无此人时 character() 应返回 null")
```

注意：probe 事件运行时 `Era.state.character_book` 里已有 `player` 和 `daughter`（该 check 开头就装配好了），所以 `character(&"player")` 查得到。

### Step 2: 运行确认 RED

`res://tests/check_kojo.tscn` → 解析错误：`EventContext` 未声明（正因如此，这是期望中的失败）。

### Step 3: 实现（按上面精确接口）

### Step 4: 运行确认 GREEN

`check_kojo` → `CHECK OK`。既有断言（恶意 extras 不覆盖固定字段等）必须保持全绿——这是回归底线。

### Step 5: 全量回归

17 个 `tests/check_*.tscn` 全部 `CHECK OK`。

## Godot 命令

```powershell
$GODOT = 'C:\Users\30873\Desktop\Godot\Stable\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64_console.exe'
& $GODOT --headless --path 'E:\MyCode\GodotCode\my-test' res://tests/check_kojo.tscn --quit-after 300
```

## 项目约定

- Tab 缩进；中文 doc 注释；显式类型（警告即错误）。
- 项目不是 git 仓库：**不要 commit**，校验绿即完成。
- 只碰上面列的 3 个文件。
