extends Node
## Era, 引擎入口
##
## 此类是自动加载单例。
## [br][br]
## 常驻壳 + 命令 API + 输入等待 + 事件循环。
## [br][br]
## 内容脚本的写法：
## [codeblock]
## extends EraEvent
##
## func run(context: EventContext) -> GDScript:
##     Era.print("你醒了过来。")
##     Era.print_button("起床", 0)
##     var picked: int = await Era.input()
##     var 女儿 := context.character(&"daughter")
##     var 生命 := 女儿.get_component(LifeComponent) as LifeComponent
##     生命.hurt(10)
##     return null
## [/codeblock]
## 事件返回下一个事件脚本就继续跑，返回 [code]null[/code] 就结束。
## 没有 goto，也不换场景。

## 文字样式；具体颜色取自 [code]res://engine/era_palette.tres[/code]。
enum Style { NORMAL, DIM, ACCENT, DANGER }

const PALETTE_PATH := "res://engine/era_palette.tres"
const SCREEN_SCENE := preload("res://engine/era_screen.tscn")
const TEXT_ROW_SCENE := preload("res://engine/rows/text_row.tscn")
const BUTTON_ROW_SCENE := preload("res://engine/rows/button_row.tscn")
const RULE_ROW_SCENE := preload("res://engine/rows/rule_row.tscn")
const GRID_ROW_SCENE := preload("res://engine/rows/grid_row.tscn")
const GAME_STATE_SCRIPT := preload("res://engine/game_state.gd")

## 壳所在的画布层。
## [br][br]
## 比普通场景高，保证内容始终在游戏之上。
const LAYER_INDEX := 100

## 整个事件流程跑完时发出（校验场景、将来“回到标题”会用到）。
signal flow_finished

signal _choice_made(id: int)
signal _key_pressed

## 游戏状态：只装 [code]character_book[/code]；角色数据在组件里。
## [br][br]
## 事件里拿角色用入参 context（拿数据用 context，做事用 Era.*）：
## [codeblock]
## context.character(&"daughter")
## context.player
## [/codeblock]
var state: GameState

var _palette: EraPalette
var _screen
var _layer: CanvasLayer
var _pending_buttons: Array[Dictionary] = []
var _active_buttons: Dictionary = {}
var _input_active := false
var _waiting_key := false
var _grid_mode := false
var _grid_columns := 3
var _grid_items: Array = []
var _pending_grids: Array = []
var _active_grids: Array = []


func _ready() -> void:
	_palette = load(PALETTE_PATH) as EraPalette
	state = GAME_STATE_SCRIPT.new() as GameState
	set_process_unhandled_key_input(true)
	set_process_input(true)  # 鼠标点击也要能唤醒 wait_key

	_layer = CanvasLayer.new()
	_layer.name = "EraLayer"
	_layer.layer = LAYER_INDEX
	add_child(_layer)  # 挂在 Era 自己下面：自动加载的 _ready 里不能直接往 root 加子节点
	_screen = SCREEN_SCENE.instantiate()
	_layer.add_child(_screen)


# ---------- 命令：往壳里印东西 ----------

## 追加一行文字。
## [br][br]
## [param text] 支持使用BBCode，使用BBCode时，将生成一份RichTextLabel，否则生成Label
## [br][br]
## [param style] 整行文字颜色，取自调色板。
## [br][br]
## [param align] 直接用 Godot 的 [enum HorizontalAlignment]。
func print(
	text: String,
	style: Era.Style = Style.NORMAL,
	align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> void:
	_print_text(text, style, align)


## 打印一行，然后等任意键或者鼠标左键。其实就是[method print] 与 [method wait_key] 的语法糖。
## [br][br]
## 调用时必须 [code]await[/code]。忘了 await 会打印并开始等待，但后面的代码会立刻继续。
func print_wait(
	text: String,
	style: Era.Style = Style.NORMAL,
	align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> void:
	_print_text(text, style, align)
	await wait_key()

	
## 追加一个按钮行。
## [br][br]
## 实际显示为 [code][编号] 文字[/code]，点了返回编号。
func print_button(
	text: String,
	id: int,
	align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> void:
	# 格子收集模式下，先放进当前块，end_grid() 时一次画出（动作项）
	if _grid_mode:
		_grid_items.append({"id": id, "text": text, "kind": "action"})
		return
	var row: Variant = BUTTON_ROW_SCENE.instantiate()
	_screen.append_row(row)
	row.setup(text, id, align)
	row.picked.connect(_on_button_picked)
	_pending_buttons.append({"id": id, "row": row})


## 在格子模式下追加一个“选择项”。
## [br][br]
## 选中＝青色、未选＝白色、[param disabled] = true 时灰色且点击无效。
## 点击只切换自己，不会让 [method input] 返回；内容可接格子句柄的 [code]toggled[/code]
## 信号处理互斥/上限。
func print_toggle(
	text: String,
	id: int,
	selected: bool = false,
	disabled: bool = false
) -> void:
	if _grid_mode:
		_grid_items.append({
			"id": id,
			"text": text,
			"kind": "toggle",
			"selected": selected,
			"disabled": disabled,
		})
		return
	push_warning("Error! Era：print_toggle 只能在 begin_grid / end_grid 之间使用")


## 在格子模式下追加一个“纯文字格”（不可点、不带编号）。
## [br][br]
## 用来做状态面板、表头、以及“一行里文字 + 按钮”的混排。
## 颜色取自 [param style]，对齐用 [enum HorizontalAlignment]。
func print_cell(
	text: String,
	style: Style = Style.NORMAL,
	align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> void:
	if _grid_mode:
		_grid_items.append({
			"id": -1,
			"text": text,
			"kind": "text",
			"color": _style_color(style),
			"align": align,
		})
		return
	push_warning("Error! Era：print_cell 只能在 begin_grid / end_grid 之间使用")


## 开始收集一块多列格子；之后用 [method print_toggle] / [method print_button] / [method print_cell] 往里加项，
## [method end_grid] 一次构建并挂上。适合“一行一行写选项，最后排成多列”的写法。
func begin_grid(columns: int = 3) -> void:
	_grid_mode = true
	_grid_columns = maxi(1, columns)
	_grid_items.clear()


## 结束收集，构建并挂上格子块；返回格子句柄（用它 get_selected / set_disabled / 接 toggled）。
## [br][br]
## 只有格子里的动作项（[method print_button]）会让 [method input] 返回编号；
## 选择项（[method print_toggle]）点击只改自己；文字格（[method print_cell]）不可点。
func end_grid() -> Variant:
	_grid_mode = false
	var items := _grid_items.duplicate()
	_grid_items.clear()
	if items.is_empty():
		return null

	var row: Variant = GRID_ROW_SCENE.instantiate()
	_screen.append_row(row)
	row.setup(items, _grid_columns, _screen.text_width())
	row.picked.connect(_on_button_picked)
	_pending_grids.append(row)
	for item in items:
		if item is Dictionary and item["kind"] == "action":
			_pending_buttons.append({"id": int(item["id"]), "row": row})
	return row


## 追加一条占满整行的分割线。
## [br][br]
## [param char] 用来重复的符号；重复次数按当前文字区宽度算。
func print_rule(char: String = "╍") -> void:
	var row: Variant = RULE_ROW_SCENE.instantiate()
	_screen.append_row(row)
	row.setup(char, _screen.text_char_count(char))


## 追加 [param count] 个空行
## [br][br]
## 用空格占高度，和 Emuera 的空行一致。
func print_gap(count: int = 1) -> void:
	for i in count:
		_print_text(" ", Style.NORMAL, HORIZONTAL_ALIGNMENT_LEFT)


## 清空屏幕，并丢弃所有还没用上的按钮。
func clear() -> void:
	_screen.clear_rows()
	_pending_buttons.clear()
	_active_buttons.clear()
	_pending_grids.clear()
	_grid_mode = false
	_grid_items.clear()


# -------------------- 等待玩家 --------------------

## 等玩家点动作按钮（或按数字键），返回选中编号。
## [br][br]
## 格子里的选择项（toggle）点击不会让它返回，只切换自己。
func input() -> int:
	_active_buttons.clear()
	for entry in _pending_buttons:
		_active_buttons[entry["id"]] = entry["row"]
	_pending_buttons.clear()

	_active_grids.clear()
	for grid in _pending_grids:
		_active_grids.append(grid)
	_pending_grids.clear()

	_input_active = true
	var picked: Variant = await _choice_made
	_input_active = false

	for row in _active_buttons.values():
		row.make_inert()
	_active_buttons.clear()
	for grid in _active_grids:
		grid.make_inert()
	_active_grids.clear()
	return int(picked)


## 等任意键、或鼠标左键点击。
func wait_key() -> void:
	_waiting_key = true
	await _key_pressed
	_waiting_key = false


# -------------------- 事件循环 --------------------

## 启动第一个事件
## [br][br]
## 之后由每个事件 [code]run()[/code] 函数的返回值接力。如果[code]return null[/code]，则停止接力。
## [br][br]
## 会先等壳完成一次排版：第一行要按真实宽度算分割线字数。
func start(event_script: GDScript) -> void:
	var guard := 0
	while _screen == null or _screen.text_width() <= 0.0:
		await get_tree().process_frame
		guard += 1
		if guard > 30:
			push_warning("Era：等壳排版超过 30 帧，按当前值继续")
			break
	_run_flow(event_script)


## 挂载一个特殊页面（[code].tscn[/code]，根脚本继承 [code]EraScreenPage[/code]）。
## [br][br]
## [param data] 在页面进入场景树之前交给页面的 [code]configure()[/code]；
## 页面不读取全局状态，只使用这里传入的数据。页面发 [code]finished(result)[/code]
## 后拿掉并把 result 返回。全程不换场景；页面拿掉后文字流和历史都还在。
func show_screen(scene: PackedScene, data: Dictionary = {}) -> Variant:
	var page: Variant = scene.instantiate()
	if page.has_method("configure"):
		page.configure(data)
	_screen.show_page(page)
	var result: Variant = await page.finished
	_screen.hide_page(page)
	return result


## 按 id 取角色。引擎内部/测试用；内容脚本在事件里用
## [code]context.character(&"daughter")[/code]（拿数据用 context，做事用 Era.*）。
func character(id: StringName) -> Character:
	if state == null or state.character_book == null:
		return null
	return state.character_book.find(id)


## 运行[method Era.kojo]方法会调用一段口上，也就是[i]kojo[/i]。
## [br][br]
## [b]原理:[/b]找角色的 [KojoComponent]，调用[param KojoComponent.book]里注册的事件函数。
## [br][br]
## [param character]: 传入一个属于[Character]类的变量。然后判断该[Character]是否装配[KojoComponent]，如果没有则返回[code]null[/code]。
## [br][br]
## [param event_name]: 传入一个[StringName]类型的变量，然后在[Character]的[param KojoComponent.book]中，根据[param event_name]
## 寻找对应的[code]Callable[/code][i](也就是使用事件函数)[/i]
## [br][br]
## [b]注意[/b]:事件函数就是一个普通 GDScript。它在[KojoBook]类中完成注册。[i](详细你可以去看看[KojoBook]类的注释)[/i]
## 你可以在事件函数里面写入所有的Era命令。
## [codeblock]
## func _morning(context: KojoContext) -> Variant:
##     Era.print("Hello, %s" % context.speaker.name_for(context.player))
##     return null
## [/codeblock]
## [param extras]: 调用者临时数据；放进 [member KojoContext.extras]，不会覆盖固定字段。
## 固定字段是 [code]speaker / player / state[/code]；口上组件可从
## [code]context.speaker.get_component(KojoComponent)[/code] 取得。
## [br][br]
## 引擎每次新建 [KojoContext] 并等事件函数执行完。
func kojo(character: Character, event_name: StringName, extras: Dictionary = {}) -> Variant:
	if character == null:
		push_warning("Era.kojo：角色为空")
		return null
	var kojo_component := character.get_component(KojoComponent) as KojoComponent
	if kojo_component == null or kojo_component.book == null:
		push_warning("Era.kojo：角色「%s」没有口上组件或口上书" % character.id)
		return null
	var callable := kojo_component.book.get_event(event_name)
	if not callable.is_valid():
		push_warning("Era.kojo：角色「%s」的口上里没有事件「%s」" % [character.id, event_name])
		return null
	if not kojo_component.is_event_enabled(event_name):
		push_warning("Era.kojo：角色「%s」的口上事件「%s」已被关掉" % [character.id, event_name])
		return null

	kojo_component.bump_counter(event_name)
	var context := KojoContext.new()
	context.speaker = character
	context.player = _protagonist()
	context.state = state
	context.extras = extras.duplicate(true)
	var result: Variant = await callable.call(context)
	return result


## 当前屏幕行数（校验场景用）。
func row_count() -> int:
	return _screen.row_count()


func _protagonist() -> Character:
	if state == null or state.character_book == null:
		return null
	return state.character_book.find(state.character_book.protagonist_id)


# ---------- 内部 ----------

func _run_flow(first_script: GDScript) -> void:
	var next_script: GDScript = first_script
	while next_script != null:
		var event: Variant = next_script.new()
		# 每事件一包：主角中途换绑后，下一个事件拿到新值。
		var context := EventContext.new()
		context.state = state
		context.player = _protagonist()
		var result: Variant = await event.run(context)
		next_script = result as GDScript
	flow_finished.emit()


func _print_text(text: String, style: Style, align: HorizontalAlignment) -> void:
	var row: Variant = TEXT_ROW_SCENE.instantiate()
	_screen.append_row(row)
	row.setup(text, _style_color(style), align)


func _on_button_picked(id: int) -> void:
	_choose(id)


## 只接受“这一轮”的按钮；旧按钮和旧编号会被忽略。
func _choose(id: int) -> void:
	if not _input_active:
		return
	if not _active_buttons.has(id):
		return
	_choice_made.emit(id)


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key_event := event as InputEventKey
	var key := key_event.keycode

	if _input_active:
		var digit := -1
		if key >= KEY_0 and key <= KEY_9:
			digit = key - KEY_0
		elif key >= KEY_KP_0 and key <= KEY_KP_9:
			digit = key - KEY_KP_0
		if digit >= 0:
			_choose(digit)
			get_viewport().set_input_as_handled()
		return

	if _waiting_key:
		_resolve_key()
		get_viewport().set_input_as_handled()


## 鼠标左键点击也算“任意键”。
## [br][br]
## 用 [code]_input[/code] 而不是 [code]_unhandled_input[/code]：
## 背景 ColorRect 会把点击吃掉，等不到 unhandled。
func _input(event: InputEvent) -> void:
	if not _waiting_key:
		return
	if not (event is InputEventMouseButton):
		return
	var mouse := event as InputEventMouseButton
	if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
		_resolve_key()


## 模拟“按了一个键 / 点了一下”（校验场景也直接调它）。
func _resolve_key() -> void:
	if not _waiting_key:
		return
	_waiting_key = false
	_key_pressed.emit()


func _style_color(style: Style) -> Color:
	match style:
		Style.DIM:
			return _palette.dim
		Style.ACCENT:
			return _palette.accent
		Style.DANGER:
			return _palette.danger
		_:
			return _palette.normal
