class_name CharacterComponent
extends Resource
## 角色组件基类。
##
## 一个角色( [Character] )由单个 [CharacterComponent] 或者多个 [CharacterComponent] 组合而成，组件只管理自己的数据，
## 不引用 Character、不直接打印、不连 UI。
## [br][br]
## 数据变了发 [signal component_changed]，
## 由内容脚本决定怎么显示（Era 的“变更后重打印”方式）。
## [br][br]
## 存档口径统一“白名单 fields 轨”：[method to_fields] / [method apply_fields]
## 只处理 [constant FIELD_WHITELIST] 里的字段类型；容器值做深拷贝，含 Object 元素的
## 容器整字段拒收（Object 深拷贝仍是同一引用，会共享实例）；跳过坏字段时 push_warning。

## 组件字段变化时发出。[param what] 是变化的字段名（如 &"value"）。
signal component_changed(what: StringName)

## 允许进存档的字段类型；清单外的成员直接跳过。
const FIELD_WHITELIST := [
	TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_STRING_NAME,
	TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_COLOR, TYPE_RECT2,
	TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY,
	TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_STRING_ARRAY,
	TYPE_ARRAY, TYPE_DICTIONARY,
]

## 组件的界面显示名（如“生命”）。不参与查找、替换或程序 ID。
@export var display_name: String = ""


## 显示名；空串时回退到脚本类名。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	var script: Script = get_script()
	if script != null and not script.get_global_name().is_empty():
		return script.get_global_name()
	return "CharacterComponent"


## 组件类型身份。
## [br][br]
## 默认是自身脚本，可作为基础类型的组件返回基础脚本。
func component_type() -> Script:
	return get_script()


## 把脚本成员收成纯数据字典（白名单内类型，容器深拷贝）。
## [br][br]
## 含 Object 元素（含嵌套）的 Array / Dictionary 整字段跳过并 push_warning：
## duplicate(true) 不复制 Object，写进去就会和实例共享引用。
func to_fields() -> Dictionary:
	var out := {}
	var script: Script = get_script()
	if script == null:
		return out
	for prop in script.get_script_property_list():
		if (int(prop.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue
		var label := String(prop["name"])
		var value: Variant = get(label)
		if not FIELD_WHITELIST.has(typeof(value)):
			continue
		if value is Array or value is Dictionary:
			if _has_object_element(value):
				push_warning("%s.to_fields：字段「%s」的容器含 Object 元素（会共享引用），整字段跳过" % [_debug_name(), label])
				continue
			out[label] = value.duplicate(true)
		else:
			out[label] = value
	return out


## 把纯数据字典写回脚本成员。
## [br][br]
## 未知字段、类型不符的条目跳过（坏档不进实例），跳过时 push_warning；
## typed 容器（Array[X] / Dictionary[K,V]）先做元素类型预检，混入坏元素就整字段跳过
## （引擎对 typed 容器的整体 set 会静默丢弃，必须走 assign/merge 逐元素落值）。
func apply_fields(fields: Dictionary) -> void:
	for field_name in fields:
		var label := String(field_name)
		var value: Variant = fields[field_name]
		if not FIELD_WHITELIST.has(typeof(value)):
			push_warning("%s.apply_fields：字段「%s」类型 %s 不在白名单，已跳过" % [_debug_name(), label, type_string(typeof(value))])
			continue
		var prop := _find_member(label)
		if prop.is_empty():
			push_warning("%s.apply_fields：未知字段「%s」，已跳过" % [_debug_name(), label])
			continue
		var declared := int(prop.get("type", TYPE_NIL))
		if declared != TYPE_NIL and typeof(value) != declared \
				and not (declared == TYPE_STRING_NAME and typeof(value) == TYPE_STRING):
			push_warning("%s.apply_fields：字段「%s」声明类型 %s，来值是 %s，已跳过" % [
				_debug_name(), label, type_string(declared), type_string(typeof(value))
			])
			continue
		if declared == TYPE_ARRAY and value is Array and _is_typed_container(prop):
			if not _elements_ok(value, String(prop.get("hint_string", ""))):
				push_warning("%s.apply_fields：字段「%s」的元素类型不符，已整字段跳过" % [_debug_name(), label])
				continue
			var target_array: Array = get(label)
			target_array.assign(value)
			continue
		if declared == TYPE_DICTIONARY and value is Dictionary and _is_typed_container(prop):
			var descriptors := String(prop.get("hint_string", "")).split(";")
			var key_descriptor := descriptors[0] if descriptors.size() > 0 else ""
			var value_descriptor := descriptors[1] if descriptors.size() > 1 else ""
			if not _entries_ok(value, key_descriptor, value_descriptor):
				push_warning("%s.apply_fields：字段「%s」的键/值类型不符，已整字段跳过" % [_debug_name(), label])
				continue
			var target_dict: Dictionary = get(label)
			target_dict.clear()
			target_dict.merge(value, true)
			continue
		if declared == TYPE_STRING_NAME and value is String:
			set(label, StringName(value))
		else:
			set(label, value)


func _find_member(member: String) -> Dictionary:
	var script: Script = get_script()
	if script == null:
		return {}
	for prop in script.get_script_property_list():
		if String(prop.get("name")) == member \
				and (int(prop.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
			return prop
	return {}


## 按类名取全局脚本类；不是全局脚本类时返回 null。
## [br][br]
## 只在回填 typed 脚本类容器（如 Array[RelationEntry]）的冷路径上走，不做缓存：
## 本项目 4.8-dev7 对脚本级 static var 有静默崩溃嫌疑，避免使用。
func _global_class_script(class_name_: String) -> Script:
	for entry in ProjectSettings.get_global_class_list():
		if String(entry.get("class", "")) == class_name_:
			return load(String(entry.get("path", ""))) as Script
	return null


## 容器（含嵌套）里是否有 Object 元素；Object 经 duplicate 仍是同一引用，不能进存档。
func _has_object_element(value: Variant) -> bool:
	if value is Object:
		return true
	if value is Array:
		for element in value:
			if _has_object_element(element):
				return true
	if value is Dictionary:
		for key in value:
			if key is Object or _has_object_element(value[key]):
				return true
	return false


## 属性是否 typed 容器（Array[X] / Dictionary[K,V]）。
## [br][br]
## 判据用 hint_string 非空（如 "21:" / "24/17:RelationEntry" / "21:;1:"）：
## 4.8-dev7 里 typed 容器的 hint 编号与 PROPERTY_HINT_ARRAY_TYPE 常量对不上，
## 按常量判会漏；hint_string 只在 typed 时非空。
func _is_typed_container(prop: Dictionary) -> bool:
	return int(prop.get("type", TYPE_NIL)) in [TYPE_ARRAY, TYPE_DICTIONARY] \
			and String(prop.get("hint_string", "")) != ""


## typed 容器的元素描述符（如 "21:"、"24/17:RelationEntry"）是否匹配元素值。
## String 与 StringName 互相视为可转换（assign/merge 落值时由引擎转换）。
func _element_ok(element: Variant, descriptor: String) -> bool:
	var parts := descriptor.split(":")
	if parts.is_empty():
		return false
	var class_name_ := parts[1] if parts.size() > 1 else ""
	if class_name_ != "":
		if element == null:
			return true  # typed 容器允许空元素
		var script := _global_class_script(class_name_)
		if script != null:
			return is_instance_of(element, script)
		return element is Object and ClassDB.is_parent_class(element.get_class(), class_name_)
	var declared := int(parts[0])
	if element == null:
		return false  # 值类型的 typed 容器不留 null
	var actual := typeof(element)
	if actual == declared:
		return true
	if declared in [TYPE_STRING, TYPE_STRING_NAME] and actual in [TYPE_STRING, TYPE_STRING_NAME]:
		return true
	if declared == TYPE_FLOAT and actual == TYPE_INT:
		return true
	return false


## typed Array 的全部元素是否匹配元素描述符。
func _elements_ok(value: Array, descriptor: String) -> bool:
	for element in value:
		if not _element_ok(element, descriptor):
			return false
	return true


## typed Dictionary 的全部键/值是否匹配键/值描述符。
func _entries_ok(value: Dictionary, key_descriptor: String, value_descriptor: String) -> bool:
	for key in value:
		if not _element_ok(key, key_descriptor) or not _element_ok(value[key], value_descriptor):
			return false
	return true


## 警告里的组件名：脚本全局名，回退 resource_path。
func _debug_name() -> String:
	var script: Script = get_script()
	if script == null:
		return "CharacterComponent"
	if script.get_global_name() != "":
		return script.get_global_name()
	return script.resource_path if script.resource_path != "" else "CharacterComponent"


## 组件内部改完数据后调用
## [br][br]
## 不要在外面直接 emit，采用统一出口。
func _mark_changed(what: StringName) -> void:
	component_changed.emit(what)


## 组件的“静态资源引用”（例如口上组件里的 [KojoBook]）。
## [br][br]
## 这些引用不进存档（[method to_fields] 不收），但 [method Character.spawn]
## 需要把它们复制到新实例，否则 spawn 出来的角色会丢口上书。默认没有。
func to_static_refs() -> Dictionary:
	return {}


## 把 [method to_static_refs] 的内容装回组件；默认没有。
func apply_static_refs(_refs: Dictionary) -> void:
	pass


## spawn 时复制一个独立组件；子类可覆盖以处理嵌套数据（如关系条目）。
## [br][br]
## 脚本没有 resource_path（运行时拼的脚本、内部类）时 push_warning 并返回 null：
## 没有脚本文件就没法按脚本重建实例。
func duplicate_for_spawn() -> CharacterComponent:
	var script: Script = get_script()
	if script == null or script.resource_path == "":
		push_warning("%s：脚本缺 resource_path，duplicate_for_spawn 返回 null" % _debug_name())
		return null
	var copy := script.new() as CharacterComponent
	if copy == null:
		return null
	copy.apply_fields(to_fields())
	copy.apply_static_refs(to_static_refs())
	return copy
