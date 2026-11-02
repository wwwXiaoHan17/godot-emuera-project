extends EraEvent
## TalentSelect, 天赋选择
##
## 从 [code]TalentData[/code] Resource 生成多列选择格子：
## - 选择项点击只切自己：选中青色、未选白色、互斥项灰色；
## - 点“确认”把选中的天赋名写进女儿角色的天赋组件，然后进入第 1 天；
## - 点“返回”重新创建角色（回到 [code]new_game[/code]）。
##
## 互斥规则来自每个天赋自己的 [code]conflicts_with[/code]，由本事件负责灰显；
## 引擎只负责“灰色的不能点”。

## 天赋列表：显式列出，导出后不依赖目录扫描。
const TALENTS := [
	preload("res://resources/talent_resource/无知.tres"),
	preload("res://resources/talent_resource/幼稚.tres"),
	preload("res://resources/talent_resource/早熟.tres"),
	preload("res://resources/talent_resource/性压抑.tres"),
	preload("res://resources/talent_resource/易漏尿.tres"),
	
]
const NewGame := preload("res://content/events/new_game.gd")
const DayStart := preload("res://content/events/day_start.gd")
const TypeANewGame = preload("uid://ccidr3i8rgbkb")

var _grid: Variant = null


func run(context: EventContext) -> GDScript:
	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
	Era.clear()
	Era.print_rule()
	Era.print("天 赋", Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	Era.print("可多选；互斥的天赋会变灰。", Era.Style.DIM)
	Era.print_rule()

	# 格子里的编号 = 列表序号 + 1（1~N），跟旧 first_game.tscn 的 [ 1] [ 2] ... 对齐。
	Era.begin_grid(3)
	for i in TALENTS.size():
		var talent: TalentData = TALENTS[i]
		Era.print_toggle(str(talent.display_name), i + 1, false, false)
	# 占位格：让“确认/返回”另起一行，不和天赋挤在同一行
	Era.print_cell("")
	Era.print_button("确认", 9998)
	Era.print_button("返回", 9999)
	Era.print_cell("选中：青色　　互斥：灰色", Era.Style.DIM)
	_grid = Era.end_grid()
	_grid.toggled.connect(_on_toggled)

	match await Era.input():
		9998:
			# 把格子里的选中项（编号 = 序号 + 1）还原成天赋名，写进女儿的天赋组件。
			var talents: Array[StringName] = []
			var names: Array[String] = []
			for id in _grid.get_selected():
				var talent: TalentData = TALENTS[int(id) - 1]
				talents.append(talent.talent_name)
				names.append(str(talent.display_name))

			var daughter := Era.state.character_book.find(&"daughter")
			if daughter != null:
				var talent_component := daughter.get_component(TalentListComponent) as TalentListComponent
				if talent_component != null:
					talent_component.set_talents(talents)

			Era.print(
				"已选天赋：%s" % ("、".join(names) if not names.is_empty() else "（无）"),
				Era.Style.ACCENT
			)
			Era.print("按任意键或点击进入第 1 天。", Era.Style.DIM)
			await Era.wait_key()
			#return DayStart
			return TypeANewGame
		9999:
			return NewGame
		# 这个_的作用时：当前match语法没有_时，可能会出现一个分支都不匹配的情况。这个时候走到结尾没有return解析器会报 “Not all code paths return a value.”。
		# 所以这个 _: return 的作用就是兜底，防止编译器报错，无实际作用
		_:
			return

	


## 选择项点击：互斥的天赋要“选中一个、另一个灰掉”。
## 这版只演示一对互斥（幼稚/早熟）；更复杂的规则（分组、上限）以后在这里扩展。
func _on_toggled(id: int, selected: bool) -> void:
	var talent: TalentData = TALENTS[id - 1]
	for conflict_name in talent.conflicts_with:
		var other_id := _id_of(conflict_name)
		if other_id == 0:
			continue
		if selected:
			_grid.set_selected(other_id, false)
			_grid.set_disabled(other_id, true)
		else:
			_grid.set_disabled(other_id, false)


## 天赋名 → 格子编号（1 起）。
func _id_of(talent_name: StringName) -> int:
	for i in TALENTS.size():
		if (TALENTS[i] as TalentData).talent_name == talent_name:
			return i + 1
	return 0
