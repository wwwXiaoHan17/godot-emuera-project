class_name CharacterBook
extends Resource
## CharacterBook, 角色表（id → 角色）
##
## 多角色游戏的运行时角色集合。角色实例直接挂在 [member characters] 里，
## 运行时按 id 线性查找（角色数量是几十级，不需要哈希表）。
## 增删/换主角通过 [signal character_added] / [signal character_removed] /
## [signal protagonist_changed] 通知外界；JSON 存档口径走
## [method to_save_dict] / [method apply_save_dict]（[SaveManager] 使用）。

## 角色加入后发出（[param character] 是新加入的实例；同 id 替换时先发被替换者的 character_removed）。
signal character_added(character: Character)
## 角色被移除后发出（[method remove]、同 id 替换）。
signal character_removed(character: Character)
## 主角改绑后发出（[param old_id] → [param new_id]；见 [method set_protagonist]）。
signal protagonist_changed(old_id: StringName, new_id: StringName)

## to_save_dict 里存放组件静态资源引用的保留键。
const STATIC_REFS_KEY := "__static_refs__"
## to_save_dict 里内联子资源（如 [RelationEntry]）的标记键。
const RESOURCE_KEY := "__resource__"

@export var characters: Array[Character] = []
## 玩家主角的 id。[b].tres 原型兼容保留[/b]；运行时改绑请走 [method set_protagonist]（存在性校验 + 信号）。
@export var protagonist_id: StringName = &"player"

# 全局类名表缓存（类名 → 脚本路径）与已解析 Script 缓存（进程内共享）。
static var _class_path_cache: Dictionary = {}
static var _script_cache: Dictionary = {}


## 加角色；同 id 已存在则替换（返回新加入的实例）。
func add(character: Character) -> Character:
	if character == null:
		return null
	var existing := find(character.id)
	if existing != null:
		characters.erase(existing)
		character_removed.emit(existing)
	characters.append(character)
	character_added.emit(character)
	return character


## 移除并返回角色；不存在返回 null（不发信号）。
func remove(id: StringName) -> Character:
	var existing := find(id)
	if existing == null:
		return null
	characters.erase(existing)
	character_removed.emit(existing)
	return existing


## 寻找角色
func find(id: StringName) -> Character:
	for character in characters:
		if character != null and character.id == id:
			return character
	return null


## 按真名/称呼线性查找角色（先匹配 display_name，再匹配 callname，取第一个命中）；查无返回 null。
## [codeblock]
## book.find_by_name("阿丽丝")
## [/codeblock]
func find_by_name(name: String) -> Character:
	for character in characters:
		if character != null and character.display_name == name:
			return character
	for character in characters:
		if character != null and character.callname == name:
			return character
	return null


## 批量加角色（等价于逐个 [method add]，逐个发 [signal character_added]）。
func add_all(chara_list: Array[Character]) -> void:
	for character in chara_list:
		add(character)


## 改绑主角：角色存在才修改并发 [signal protagonist_changed]；不存在则 push_warning 并保持原值。
## [codeblock]
## book.set_protagonist(&"daughter")
## [/codeblock]
func set_protagonist(id: StringName) -> void:
	if find(id) == null:
		push_warning("CharacterBook.set_protagonist：角色「%s」不存在，主角保持「%s」" % [id, protagonist_id])
		return
	if id == protagonist_id:
		return
	var old_id := protagonist_id
	protagonist_id = id
	protagonist_changed.emit(old_id, id)


func all() -> Array[Character]:
	return characters.duplicate()


func ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for character in characters:
		if character != null:
			result.append(character.id)
	return result


## 全局类名 → [Script] 的映射工具（[method ProjectSettings.get_global_class_list]，进程内缓存）。
## CSV 导入、存档重建按类名装配组件都走这里；未知类名返回 null。
static func script_for_class_name(global_name: String) -> Script:
	if _script_cache.has(global_name):
		return _script_cache[global_name]
	if _class_path_cache.is_empty():
		for entry in ProjectSettings.get_global_class_list():
			var entry_name := String(entry.get("class", ""))
			if entry_name != "":
				_class_path_cache[entry_name] = String(entry.get("path", ""))
	if not _class_path_cache.has(global_name):
		return null
	var script: Script = load(String(_class_path_cache[global_name]))
	if script != null:
		_script_cache[global_name] = script
	return script


## 收成 JSON 纯数据字典（[SaveManager] 写档用）：
## [codeblock]
## {
##   "characters": [{
##     "id": "daughter", "display_name": "阿丽丝", "callname": "女儿",
##     "components": {"LifeComponent": {字段字典…}, "__static_refs__": {"KojoComponent": {…}}}
##   }],
##   "protagonist_id": "player"
## }
## [/codeblock]
## 组件按"脚本全局类名"做键；字段来自 [method CharacterComponent.to_fields]；
## 静态资源引用（如口上书）与内联子资源（如关系条目）转成路径/类名规格，保证可 JSON 序列化。
func to_save_dict() -> Dictionary:
	var out_characters: Array = []
	for character in characters:
		if character == null:
			continue
		var components_dict := {}
		var static_refs := {}
		for component in character.components:
			if component == null:
				continue
			var key := _component_key(component)
			if key.is_empty():
				continue
			components_dict[key] = _to_json_value(component.to_fields())
			var refs := component.to_static_refs()
			if not refs.is_empty():
				static_refs[key] = _to_json_value(refs)
		if not static_refs.is_empty():
			components_dict[STATIC_REFS_KEY] = static_refs
		out_characters.append({
			"id": String(character.id),
			"display_name": character.display_name,
			"callname": character.callname,
			"components": components_dict,
		})
	return {"characters": out_characters, "protagonist_id": String(protagonist_id)}


## 从 [method to_save_dict] 产出的字典整本重建（[SaveManager] 读档用）。
## 重建流程：类名解析 → 实例化组件 → 修正常量类型 → [method CharacterComponent.apply_fields]
## → [method CharacterComponent.apply_static_refs]。
## 宽容读取：缺失部分补默认，坏条目跳过；返回本次跳过的警告清单
## （[SaveManager] 会并入读档警告汇总）。批量重建不发增删信号。
func apply_save_dict(save_dict: Dictionary) -> Array[String]:
	var warnings: Array[String] = []
	characters.clear()
	var list_value: Variant = save_dict.get("characters", [])
	var list: Array = list_value if list_value is Array else []
	for entry in list:
		if not (entry is Dictionary):
			warnings.append("角色条目不是字典，跳过")
			continue
		var entry_dict: Dictionary = entry
		var character := Character.new()
		character.id = StringName(String(entry_dict.get("id", "")))
		character.display_name = String(entry_dict.get("display_name", ""))
		character.callname = String(entry_dict.get("callname", ""))
		var components_value: Variant = entry_dict.get("components", {})
		var components_dict: Dictionary = components_value if components_value is Dictionary else {}
		var refs_value: Variant = components_dict.get(STATIC_REFS_KEY, {})
		var refs_dict: Dictionary = refs_value if refs_value is Dictionary else {}
		for component_key in components_dict:
			if String(component_key) == STATIC_REFS_KEY:
				continue
			var script := script_for_class_name(String(component_key))
			if script == null:
				warnings.append("未知组件类「%s」，跳过" % component_key)
				continue
			var component := script.new() as CharacterComponent
			if component == null:
				warnings.append("「%s」不是角色组件，跳过" % component_key)
				continue
			var fields_value: Variant = components_dict[component_key]
			var fields: Dictionary = fields_value if fields_value is Dictionary else {}
			_apply_component_fields(component, fields)
			if refs_dict.has(component_key) and refs_dict[component_key] is Dictionary:
				var restored_refs: Variant = _from_json_value(refs_dict[component_key])
				if restored_refs is Dictionary:
					component.apply_static_refs(restored_refs)
			character.add_component(component)
		characters.append(character)
	if save_dict.has("protagonist_id"):
		set_protagonist(StringName(String(save_dict["protagonist_id"])))
	return warnings


# ---------- 存档字典内部工具（静态，供 CSV/存档共用口径） ----------

# 组件在存档字典里的键：脚本全局类名；没有全局类名的组件（如内部类）无法进存档。
static func _component_key(component: CharacterComponent) -> String:
	var script: Script = component.get_script()
	if script == null:
		return ""
	var key := script.get_global_name()
	if not key.is_empty():
		return key
	push_warning("CharacterBook.to_save_dict：组件「%s」没有全局类名，无法进存档，跳过" % component.get_display_name())
	return ""


# 把 JSON 读回的组件字段写进实例：只做 JSON 数值类型修正（整数被解析成 float、
# typed 容器的标量元素对齐声明类型），随后统一交给组件自己的 apply_fields
# （含子类覆写，如 RelationComponent 的 relations 重建）落值。
# 不在这里直接填成员——基类 apply_fields 已用 assign/merge 正确处理 typed 容器，
# 子类覆写则完全负责自己的复杂字段。
static func _apply_component_fields(component: CharacterComponent, fields: Dictionary) -> void:
	var plain_fields := {}
	for field_name in fields:
		var value: Variant = _from_json_value(fields[field_name])
		var prop := _find_script_property(component, String(field_name))
		if prop.is_empty():
			plain_fields[field_name] = value  # 未知字段交给 apply_fields 警告跳过
			continue
		var declared := int(prop.get("type", TYPE_NIL))
		var hint := String(prop.get("hint_string", ""))
		if declared == TYPE_DICTIONARY and value is Dictionary:
			plain_fields[field_name] = _coerce_json_entries(value, hint)
		elif declared == TYPE_ARRAY and value is Array:
			plain_fields[field_name] = _coerce_json_elements(value, hint)
		else:
			plain_fields[field_name] = _coerce_scalar(value, declared)
	if not plain_fields.is_empty():
		component.apply_fields(plain_fields)


# typed 数组的元素类型修正（仅 builtin 标量）；脚本类元素描述符（如
# "24/17:RelationEntry"）原样放行，由组件的 apply_fields（可能覆写）自行处理。
static func _coerce_json_elements(value: Array, hint: String) -> Array:
	var descriptor := hint.split(";")[0]
	if _descriptor_is_script_class(descriptor):
		return value
	var out: Array = []
	for element in value:
		out.append(_coerce_by_spec(element, descriptor))
	return out


# typed 字典的键/值类型修正（仅 builtin 标量）；无 ";" 描述符或脚本类原样放行。
static func _coerce_json_entries(value: Dictionary, hint: String) -> Dictionary:
	var segments := hint.split(";")
	if segments.size() != 2:
		return value
	var out := {}
	for key in value:
		var coerced_key: Variant = key
		if not _descriptor_is_script_class(segments[0]):
			coerced_key = _coerce_by_spec(key, segments[0])
		var coerced_value: Variant = value[key]
		if not _descriptor_is_script_class(segments[1]):
			coerced_value = _coerce_by_spec(value[key], segments[1])
		out[coerced_key] = coerced_value
	return out


# 描述符（如 "24/17:RelationEntry"）是否指脚本类元素：冒号后带类名即脚本类。
static func _descriptor_is_script_class(descriptor: String) -> bool:
	var parts := descriptor.split(":")
	return parts.size() > 1 and String(parts[1]) != ""


# spec 形如 "类型id:类名"（"21:"）；把 JSON 读回的值修成声明类型。
static func _coerce_by_spec(value: Variant, type_spec: String) -> Variant:
	match int(type_spec.get_slice(":", 0)):
		TYPE_STRING_NAME:
			return StringName(value) if value is String else value
		TYPE_STRING:
			return String(value) if value is StringName else value
		TYPE_INT:
			return int(value) if value is float else value
		TYPE_FLOAT:
			return float(value) if value is int else value
		_:
			return value


# 普通标量字段：JSON 的整数会解析成 float，这里按声明类型修回。
static func _coerce_scalar(value: Variant, type_id: int) -> Variant:
	match type_id:
		TYPE_INT:
			return int(value) if value is float else value
		TYPE_FLOAT:
			return float(value) if value is int else value
		_:
			return value


# 把任意值转成 JSON 可序列化的纯数据：StringName→String、Resource→路径/内联规格、容器递归。
static func _to_json_value(value: Variant) -> Variant:
	match typeof(value):
		TYPE_STRING_NAME:
			return String(value)
		TYPE_OBJECT:
			var resource := value as Resource
			if resource == null:
				return null
			if not resource.resource_path.is_empty():
				return {RESOURCE_KEY: {"path": resource.resource_path}}
			var script: Script = resource.get_script()
			var global_name := ""
			if script != null:
				global_name = script.get_global_name()
			if global_name.is_empty():
				push_warning("CharacterBook：子资源「%s」既无资源路径也无全局类名，存档时丢弃" % resource.get_class())
				return null
			var fields := {}
			for prop in script.get_script_property_list():
				if (int(prop.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
					continue
				var member_value: Variant = resource.get(String(prop.get("name")))
				if _is_basic_scalar(member_value):
					fields[String(prop.get("name"))] = _to_json_value(member_value)
			return {RESOURCE_KEY: {"class": global_name, "fields": fields}}
		TYPE_ARRAY:
			var out_array: Array = []
			for element in value:
				out_array.append(_to_json_value(element))
			return out_array
		TYPE_DICTIONARY:
			var out_dict := {}
			for key in value:
				out_dict[String(key)] = _to_json_value(value[key])
			return out_dict
		_:
			return value


# 反向还原：__resource__ 规格重建实例（路径 load / 全局类名 new），容器递归；其余原样返回。
static func _from_json_value(value: Variant) -> Variant:
	if value is Dictionary:
		var value_dict: Dictionary = value
		if value_dict.has(RESOURCE_KEY) and value_dict[RESOURCE_KEY] is Dictionary:
			var spec: Dictionary = value_dict[RESOURCE_KEY]
			if spec.has("path"):
				var loaded: Variant = load(String(spec["path"]))
				if loaded == null:
					push_warning("CharacterBook：静态资源「%s」加载失败" % String(spec["path"]))
				return loaded
			var script := script_for_class_name(String(spec.get("class", "")))
			if script == null:
				push_warning("CharacterBook：未知子资源类「%s」，跳过" % String(spec.get("class", "")))
				return null
			var instance: Variant = script.new()
			if spec.has("fields") and spec["fields"] is Dictionary and instance is Object:
				for member in spec["fields"]:
					_set_member(instance, String(member), _from_json_value(spec["fields"][member]))
			return instance
		var out := {}
		for key in value_dict:
			out[key] = _from_json_value(value_dict[key])
		return out
	if value is Array:
		var out_array: Array = []
		for element in value:
			out_array.append(_from_json_value(element))
		return out_array
	return value


static func _set_member(target: Object, member: String, value: Variant) -> void:
	var prop := _find_script_property(target, member)
	if prop.is_empty():
		return
	match int(prop.get("type", TYPE_NIL)):
		TYPE_STRING_NAME:
			target.set(member, StringName(value) if value is String else value)
		TYPE_INT:
			target.set(member, int(value) if value is float else value)
		TYPE_FLOAT:
			target.set(member, float(value) if value is int else value)
		_:
			target.set(member, value)


# 在脚本属性表里找成员声明（与 CharacterComponent._find_member 同口径）。
static func _find_script_property(target: Object, member: String) -> Dictionary:
	var script: Script = target.get_script()
	if script == null:
		return {}
	for prop in script.get_script_property_list():
		if String(prop.get("name")) == member \
				and (int(prop.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
			return prop
	return {}


static func _is_basic_scalar(value: Variant) -> bool:
	return [TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_STRING_NAME].has(typeof(value))
