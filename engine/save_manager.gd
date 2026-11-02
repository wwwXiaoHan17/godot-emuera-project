class_name SaveManager
extends RefCounted
## SaveManager, JSON 存档读写（静态工具）
##
## 存档落在 [code]user://save_slot<N>.json[/code]，内容：
## [codeblock]
## { "save_version": 1, "min_supported": 1, "day": 5,
##   "flags": {"gold": 3}, "protagonist_id": "player",
##   "book": CharacterBook.to_save_dict() }
## [/codeblock]
## 读档带版本门禁（过旧拒载并返回错误文案）与宽容读取（缺失补默认、未知键
## push_warning 汇总）；组件可实现可选钩子 [code]on_load_fixup(old_version)[/code]
## 完成存档迁移（未实现则不调用）。

## 当前存档版本。
const SAVE_VERSION := 1
## 引擎最低支持载入的存档版本（[code]save_version[/code] 低于它拒载）。
const MIN_SUPPORTED := 1
## 存档顶层已知键；之外的键汇总进宽容警告。
const KNOWN_KEYS := ["save_version", "min_supported", "day", "flags", "protagonist_id", "book"]


## 存档槽位文件路径。
static func slot_path(slot: int) -> String:
	return "user://save_slot%d.json" % slot


## 写存档；返回 [code]{ok: bool, path: String, error: String}[/code]。
## [codeblock]
## SaveManager.save_to(1, Era.state)
## [/codeblock]
static func save_to(slot: int, state: GameState) -> Dictionary:
	var path := slot_path(slot)
	var book_dict := {"characters": []}
	var protagonist_id := &"player"
	if state != null and state.character_book != null:
		book_dict = state.character_book.to_save_dict()
		protagonist_id = state.character_book.protagonist_id
	var payload := {
		"save_version": SAVE_VERSION,
		"min_supported": MIN_SUPPORTED,
		"day": 1 if state == null else state.day,
		"flags": _flags_to_json({} if state == null else state.flags),
		"protagonist_id": String(protagonist_id),
		"book": book_dict,
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "path": path, "error": "无法写存档文件：%s" % path}
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return {"ok": true, "path": path, "error": ""}


## 读存档；返回 [code]{ok: bool, state: GameState, error: String, warnings: Array[String]}[/code]。
## 失败时 [code]ok=false[/code] 且 [param error] 带中文文案；成功时 [param warnings]
## 汇总宽容读取警告（也已 push_warning）。返回的 [code]state[/code] 是全新实例。
## [codeblock]
## var result := SaveManager.load_from(1)
## if result.ok: Era.set_character_book(result.state.character_book)
## [/codeblock]
static func load_from(slot: int) -> Dictionary:
	var path := slot_path(slot)
	if not FileAccess.file_exists(path):
		return _fail("存档不存在：%s" % path)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return _fail("存档损坏（不是合法 JSON）：%s" % path)
	var save_dict: Dictionary = parsed

	# 版本门禁：过旧拒载；缺 save_version 视为 0。
	var save_version := int(save_dict.get("save_version", 0))
	if save_version < MIN_SUPPORTED:
		return _fail("存档版本过旧（v%d < 最低支持 v%d），拒绝载入：%s" % [save_version, MIN_SUPPORTED, path])

	var warnings: Array[String] = []
	if save_version > SAVE_VERSION:
		warnings.append("存档版本 v%d 比当前 v%d 新，按宽容模式继续读取" % [save_version, SAVE_VERSION])
	for key in save_dict:
		if not KNOWN_KEYS.has(String(key)):
			warnings.append("未知存档键「%s」，已忽略" % key)

	var state := GameState.new()
	state.day = int(save_dict.get("day", 1))
	var flags_value: Variant = save_dict.get("flags", {})
	if flags_value is Dictionary:
		state.flags = _flags_from_json(flags_value)
	else:
		warnings.append("存档 flags 不是字典，已重置为空")

	var book := CharacterBook.new()
	if save_dict.has("book"):
		if save_dict["book"] is Dictionary:
			warnings.append_array(book.apply_save_dict(save_dict["book"]))
		else:
			warnings.append("存档 book 不是字典，使用空角色表")
	else:
		warnings.append("存档缺少 book，使用空角色表")
	if save_dict.has("protagonist_id"):
		var saved_protagonist := StringName(String(save_dict["protagonist_id"]))
		if book.find(saved_protagonist) != null:
			book.protagonist_id = saved_protagonist
		else:
			warnings.append("存档主角「%s」不在角色表中，保持「%s」" % [saved_protagonist, book.protagonist_id])
	state.character_book = book
	_call_fixups(book, save_version)

	if not warnings.is_empty():
		push_warning("SaveManager.load_from（槽位 %d）宽容读取 %d 条：\n- %s" % [slot, warnings.size(), "\n- ".join(warnings)])
	return {"ok": true, "state": state, "error": "", "warnings": warnings}


# 组件可选迁移钩子：实现了 on_load_fixup(old_version) 就调用（未实现零开销）。
static func _call_fixups(book: CharacterBook, old_version: int) -> void:
	for character in book.characters:
		if character == null:
			continue
		for component in character.components:
			if component != null and component.has_method("on_load_fixup"):
				component.call("on_load_fixup", old_version)


static func _fail(message: String) -> Dictionary:
	var no_warnings: Array[String] = []
	return {"ok": false, "state": null, "error": message, "warnings": no_warnings}


static func _flags_to_json(flags: Dictionary) -> Dictionary:
	var out := {}
	for key in flags:
		out[String(key)] = int(flags[key])
	return out


static func _flags_from_json(flags: Dictionary) -> Dictionary[StringName, int]:
	var out: Dictionary[StringName, int] = {}
	for key in flags:
		out[StringName(String(key))] = int(flags[key])
	return out
