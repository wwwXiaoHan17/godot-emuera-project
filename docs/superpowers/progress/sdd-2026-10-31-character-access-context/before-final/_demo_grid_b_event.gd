extends EraEvent
## 演示：常驻多列选择格子
##
## 跑法：F6 打开 tests/demo_grid_b.tscn
## [br][br]
## 写法（逐条写）：begin_grid → print_toggle / print_button → end_grid 拿句柄。
## 点击选择项只切自己（不打断流程）：选中青色、未选白色、禁用灰色。
## 只有“返回”这类动作项才让 [code]await Era.input()[/code] 返回。
## 互斥逻辑在内容里算（幼稚 / 早熟互相禁用）。

const DATA := preload("res://tests/_demo_grid_options.gd")
const TALENT_A := 900
const TALENT_B := 901

var _selected: Dictionary = {}
var _grid: Variant = null


func run() -> GDScript:
	for index in DATA.SELECTED_INDEXES:
		_selected[int(index)] = true

	while true:
		Era.clear()
		Era.print("多列选择格子（常驻块 + 局部更新）", Era.Style.DIM)
		Era.print_gap()

		Era.begin_grid(3)
		for i in DATA.TEXTS.size():
			var disabled: bool = DATA.DISABLED_INDEXES.has(i)
			Era.print_toggle(DATA.TEXTS[i], i, _selected.has(i), disabled)
		Era.print_toggle("幼稚（互斥演示）", TALENT_A, _selected.has(TALENT_A), _selected.has(TALENT_B))
		Era.print_toggle("早熟（互斥演示）", TALENT_B, _selected.has(TALENT_B), _selected.has(TALENT_A))
		Era.print_button("返回", 9999)
		_grid = Era.end_grid()
		_grid.toggled.connect(_on_toggled)

		var action: int = await Era.input()
		if action == 9999:
			break

	# 结果页：先记下选中项（清屏后格子节点会被释放），再显示 + 一行两个动作按钮
	var selected_ids: Array = _grid.get_selected()
	Era.clear()
	var names: Array[String] = []
	for id in selected_ids:
		names.append(_name_of(int(id)))
	Era.print("你选了 %d 项：" % names.size(), Era.Style.ACCENT)
	Era.print("、".join(names) if not names.is_empty() else "（什么都没选）")
	Era.print_gap()

	Era.begin_grid(2)
	Era.print_button("再试一次", 0)
	Era.print_button("结束", 1)
	Era.end_grid()
	var picked: int = await Era.input()

	if picked == 0:
		_selected.clear()
		for index in DATA.SELECTED_INDEXES:
			_selected[int(index)] = true
		return load("res://tests/_demo_grid_b_event.gd") as GDScript
	return null


## 选择项点击：同步选择集合；幼稚 / 早熟互斥，选中一个就灰掉另一个。
func _on_toggled(id: int, selected: bool) -> void:
	if selected:
		_selected[id] = true
	else:
		_selected.erase(id)

	if id == TALENT_A:
		if selected:
			_selected.erase(TALENT_B)
			_grid.set_selected(TALENT_B, false)
		_grid.set_disabled(TALENT_B, selected)
	elif id == TALENT_B:
		if selected:
			_selected.erase(TALENT_A)
			_grid.set_selected(TALENT_A, false)
		_grid.set_disabled(TALENT_A, selected)


func _name_of(id: int) -> String:
	if id == TALENT_A:
		return "幼稚"
	if id == TALENT_B:
		return "早熟"
	return DATA.TEXTS[id]
