extends EraEvent
## ShowComponent, 开发用：列出女儿身上的全部组件和字段
##
## 遍历 [code]daughter.components[/code]；每个组件用 [method CharacterComponent.to_fields]
## 收字段（白名单类型），用混合格子按「组件 / 字段 / 值」三列显示。
## 枚举值会尽量显示成英文名（如 DISGUST / NORMAL / BUDDING / AROUSED）。


const DayStart = preload("uid://c0iwltmcqj80g")

func run(context: EventContext) -> GDScript:
	Era.state.character_book = CharacterSetup.ensure(Era.state.character_book)
	var daughter := context.character(&"daughter")
	
	Era.clear()
	if daughter == null:
		Era.print("找不到女儿角色。", Era.Style.DANGER)
		await Era.wait_key()
		return null

	Era.print_rule()
	Era.print("组件一览：%s" % daughter.display_name, Era.Style.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	Era.print("共 %d 个组件" % daughter.components.size(), Era.Style.DIM)
	Era.print_rule()

	Era.begin_grid(3)
	Era.print_cell("组件", Era.Style.DIM)
	Era.print_cell("字段", Era.Style.DIM)
	Era.print_cell("值", Era.Style.DIM)

	var printed_rows := 0
	for component in daughter.components:
		if component == null:
			continue
		var component_name := component.get_display_name()
		var fields := component.to_fields()
		# display_name 是组件配置，不算数据字段
		fields.erase("display_name")
		var field_names: Array = fields.keys()
		field_names.sort()

		if field_names.is_empty():
			Era.print_cell(component_name, Era.Style.ACCENT)
			Era.print_cell("（无字段）", Era.Style.DIM)
			Era.print_cell("—", Era.Style.DIM)
			printed_rows += 1
			continue

		for i in field_names.size():
			var field_name := str(field_names[i])
			Era.print_cell(component_name if i == 0 else "", Era.Style.ACCENT)
			Era.print_cell(field_name)
			Era.print_cell(_format_field(component, field_name, fields[field_name]), Era.Style.ACCENT)
			printed_rows += 1
	Era.end_grid()

	if printed_rows == 0:
		Era.print("（女儿还没有任何组件）", Era.Style.DIM)

	Era.print_rule()
	await Era.print_wait("按任意键返回。", Era.Style.DIM)
	return DayStart


## 把字段值转成可读文字；int 字段如果是 enum，显示枚举名。
func _format_field(component: CharacterComponent, field_name: String, value: Variant) -> String:
	if typeof(value) == TYPE_INT:
		var script: Script = component.get_script()
		if script != null:
			for prop in script.get_script_property_list():
				if str(prop.get("name", "")) != field_name:
					continue
				if int(prop.get("hint", -1)) != PROPERTY_HINT_ENUM:
					continue
				var labels := String(prop.get("hint_string", "")).split(",")
				var index := int(value)
				# Godot 的 enum hint 可能是 "A,B,C"，也可能是 "A:0,B:1,C:2"。
				var has_values := false
				for label in labels:
					if String(label).contains(":"):
						has_values = true
						break
				for i in labels.size():
					var label := String(labels[i])
					if has_values:
						var parts := label.split(":", false, 1)
						if parts.size() != 2:
							continue
						if int(parts[1]) == index:
							return "%s（%d）" % [parts[0], index]
					elif i == index:
						return "%s（%d）" % [label, index]
	return str(value)
