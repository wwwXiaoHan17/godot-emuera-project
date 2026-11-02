extends EraEvent
## 演示：混合格子（文字格 + 动作按钮 + 选择项混排）
##
## 跑法：F6 打开 tests/demo_mixed_grid.tscn
## 演示内容：
## - 多列状态面板（纯文字格，DIM 表头 + ACCENT 数值）；
## - 一行三个动作按钮（休息 / 训练 / 离开）；
## - 一行“文字 + 两个按钮”（心情）；
## - 一行“两个选择项 + 说明文字”（选择项点击只切自己，不打断流程）。
## 数值用两个示例组件（生命/精力），不再依赖 GameState 的扁平字段。

var _name := "小灯"
var _age := 18
var _life := LifeComponent.new()
var _energy := EnergyComponent.new()
var _mood := "平静"
var _early_sleep := false
var _exercise := false


func run() -> GDScript:
	while true:
		Era.clear()
		Era.print("混合格子：文字 + 按钮 + 选择项", Era.Style.DIM)
		Era.print_gap()

		Era.begin_grid(3)
		# 表头（纯文字格）
		Era.print_cell("名字", Era.Style.DIM, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_cell("年龄", Era.Style.DIM, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_cell("生命 / 精力", Era.Style.DIM, HORIZONTAL_ALIGNMENT_CENTER)
		# 数值（纯文字格）
		Era.print_cell(_name, Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_cell(str(_age), Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
		Era.print_cell(
			"%d / %d" % [_life.value, _energy.value],
			Era.Style.ACCENT,
			HORIZONTAL_ALIGNMENT_CENTER
		)
		# 一行三个动作按钮
		Era.print_button("休息", 0)
		Era.print_button("训练", 1)
		Era.print_button("离开", 9999)
		# 一行：文字 + 两个按钮
		Era.print_cell("心情：" + _mood)
		Era.print_button("开朗", 2)
		Era.print_button("阴郁", 3)
		# 一行：两个选择项 + 说明文字
		Era.print_toggle("早睡", 10, _early_sleep)
		Era.print_toggle("运动", 11, _exercise)
		Era.print_cell("↑ 选择项：点了只切自己", Era.Style.DIM)

		var grid: Variant = Era.end_grid()
		grid.toggled.connect(_on_toggled)

		var action: int = await Era.input()
		if action == 9999:
			break
		elif action == 0:
			_life.heal(5)
			_energy.rest(10)
		elif action == 1:
			_life.hurt(10)
			_energy.spend(5)
		elif action == 2:
			_mood = "开朗"
		elif action == 3:
			_mood = "阴郁"

	# 离开：打印总结
	Era.clear()
	Era.print("离开时：", Era.Style.ACCENT)
	Era.print("名字：%s　年龄：%d" % [_name, _age])
	Era.print("生命：%d　精力：%d" % [_life.value, _energy.value])
	Era.print("心情：%s　早睡：%s　运动：%s" % [_mood, _yes_no(_early_sleep), _yes_no(_exercise)])
	Era.print_gap()
	Era.print("按任意键或点击结束。", Era.Style.DIM)
	await Era.wait_key()
	return null


func _on_toggled(id: int, selected: bool) -> void:
	if id == 10:
		_early_sleep = selected
	elif id == 11:
		_exercise = selected


func _yes_no(value: bool) -> String:
	return "是" if value else "否"
