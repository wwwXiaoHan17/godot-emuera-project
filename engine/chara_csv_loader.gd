class_name CharaCsvLoader
extends RefCounted
## CharaCsvLoader, 角色 CSV 导入（静态工具）
##
## 对标 eraTW 的 ADDCHARA + EXISTCSV：从目录（含子目录）批量导入 [code]*.csv[/code]
## 角色定义，产出角色数组，交给 [method CharacterBook.add_all] 入表。
##
## CSV 行格式 v1（一行一个行类型，首列为行类型；[code]#[/code] 开头为注释行）：
## [codeblock]
## id,daughter                                  # 英文程序 id（每文件一个角色，必须有）
## 名字,阿丽丝                                   # display_name
## 称呼,小丽丝                                   # callname
## 组件,LifeComponent,value=80,max_value=120    # 类名走全局类表；同组件多行合并
## flag,cute,5                                  # 整数标记，进 FlagTableComponent.values
## [/codeblock]
## 字段值按 int → float → bool → String 解析；未知行类型 push_warning 跳过。

static func load_dir(dir: String) -> Array[Character]:
	var result: Array[Character] = []
	_scan_dir(dir, result)
	return result


static func _scan_dir(dir: String, out: Array[Character]) -> void:
	var access := DirAccess.open(dir)
	if access == null:
		push_warning("CharaCsvLoader：打不开目录「%s」" % dir)
		return
	var files: Array[String] = []
	var subdirs: Array[String] = []
	access.list_dir_begin()
	var entry := access.get_next()
	while not entry.is_empty():
		if access.current_is_dir():
			if not entry.begins_with("."):
				subdirs.append(entry)
		elif entry.to_lower().ends_with(".csv"):
			files.append(entry)
		entry = access.get_next()
	access.list_dir_end()
	files.sort()
	subdirs.sort()
	for file_name in files:
		var character := _load_file(dir.path_join(file_name))
		if character != null:
			out.append(character)
	for subdir in subdirs:
		_scan_dir(dir.path_join(subdir), out)


static func _load_file(path: String) -> Character:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("CharaCsvLoader：读不了文件「%s」" % path)
		return null
	var text := file.get_as_text()
	file.close()
	var character: Character = null
	var line_number := 0
	for raw_line in text.split("\n"):
		line_number += 1
		var line := String(raw_line).strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		var cells := _split_cells(line)
		match cells[0]:
			"id":
				if character != null:
					push_warning("CharaCsvLoader：%s:%d 一个文件只支持一个角色，忽略后续 id 行" % [path, line_number])
				else:
					var id_text := _cell(cells, 1, path, line_number)
					if id_text.is_empty():
						push_warning("CharaCsvLoader：%s:%d id 为空，忽略该文件" % [path, line_number])
					else:
						character = Character.new()
						character.id = StringName(id_text)
			"名字":
				if character == null:
					push_warning("CharaCsvLoader：%s:%d 名字行出现在 id 之前，跳过" % [path, line_number])
				else:
					character.display_name = _cell(cells, 1, path, line_number)
			"称呼":
				if character == null:
					push_warning("CharaCsvLoader：%s:%d 称呼行出现在 id 之前，跳过" % [path, line_number])
				else:
					character.callname = _cell(cells, 1, path, line_number)
			"组件":
				_apply_component_row(character, cells, path, line_number)
			"flag":
				_apply_flag_row(character, cells, path, line_number)
			_:
				push_warning("CharaCsvLoader：%s:%d 未知行类型「%s」，跳过" % [path, line_number, cells[0]])
	if character == null:
		push_warning("CharaCsvLoader：「%s」缺少有效的 id 行，忽略该文件" % path)
	return character


static func _apply_component_row(character: Character, cells: Array[String], path: String, line_number: int) -> void:
	if character == null:
		push_warning("CharaCsvLoader：%s:%d 组件行出现在 id 之前，跳过" % [path, line_number])
		return
	if cells.size() < 2:
		push_warning("CharaCsvLoader：%s:%d 组件行缺少类名，跳过" % [path, line_number])
		return
	var script := CharacterBook.script_for_class_name(cells[1])
	if script == null:
		push_warning("CharaCsvLoader：%s:%d 未知组件类「%s」，跳过" % [path, line_number, cells[1]])
		return
	var component := character.get_component(script) as CharacterComponent
	if component == null:
		component = script.new() as CharacterComponent
		if component == null:
			push_warning("CharaCsvLoader：%s:%d「%s」不是角色组件，跳过" % [path, line_number, cells[1]])
			return
		character.add_component(component)
	var fields := {}
	for index in range(2, cells.size()):
		var cell := cells[index]
		if not cell.contains("="):
			push_warning("CharaCsvLoader：%s:%d 字段「%s」缺少 =，跳过" % [path, line_number, cell])
			continue
		fields[cell.get_slice("=", 0).strip_edges()] = _parse_value(cell.get_slice("=", 1).strip_edges())
	component.apply_fields(fields)


static func _apply_flag_row(character: Character, cells: Array[String], path: String, line_number: int) -> void:
	if character == null:
		push_warning("CharaCsvLoader：%s:%d flag 行出现在 id 之前，跳过" % [path, line_number])
		return
	if cells.size() < 3 or not cells[2].is_valid_int():
		push_warning("CharaCsvLoader：%s:%d flag 行格式应为 flag,键,整数，跳过" % [path, line_number])
		return
	var flag_component := character.get_component(FlagTableComponent) as FlagTableComponent
	if flag_component == null:
		flag_component = FlagTableComponent.new()
		character.add_component(flag_component)
	flag_component.set_flag(StringName(cells[1]), int(cells[2]))


# 字段值解析：int → float → bool → String。
static func _parse_value(text: String) -> Variant:
	if text.is_valid_int():
		return int(text)
	if text.is_valid_float():
		return float(text)
	if text == "true":
		return true
	if text == "false":
		return false
	return text


static func _split_cells(line: String) -> Array[String]:
	var cells: Array[String] = []
	for cell in line.split(","):
		cells.append(String(cell).strip_edges())
	return cells


static func _cell(cells: Array[String], index: int, path: String, line_number: int) -> String:
	if index < cells.size():
		return cells[index]
	push_warning("CharaCsvLoader：%s:%d 第 %d 列缺失" % [path, line_number, index + 1])
	return ""
