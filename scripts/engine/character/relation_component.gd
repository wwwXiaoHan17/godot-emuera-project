class_name RelationComponent
extends CharacterComponent
## 关系组件（可选）。
##
## 同时保存“我 → 别人”的关系数据（好感值 + 定向称呼）和规则（范围/夹取/通知）。
## 没有关系概念的角色不安装这个组件。
## [br][br]
## 关系修改统一走这里，不再有绕过范围和通知的 Character 方法。

## 关系值实际变化时发出；[param target] 是目标角色 id。
signal relation_changed(target: StringName, value: int)
## 定向称呼实际变化时发出；[param target] 是目标角色 id，[param value] 是新称呼。
signal callname_changed(target: StringName, value: String)

## 我 → 别人 的出边关系。
@export var relations: Array[RelationEntry] = []
@export var min_value: int = 0
@export var max_value: int = 100


func _init() -> void:
	display_name = "关系"


func _find(other: StringName) -> RelationEntry:
	for entry in relations:
		if entry != null and entry.target == other:
			return entry
	return null


func relation_to(other: StringName) -> int:
	var entry := _find(other)
	return entry.relation if entry != null else 0


func set_relation_to(other: StringName, value: int) -> void:
	var clamped := clampi(value, min_value, max_value)
	var entry := _find(other)
	var old := entry.relation if entry != null else 0
	if entry == null:
		entry = RelationEntry.new()
		entry.target = other
		relations.append(entry)
	entry.relation = clamped
	if old != clamped:
		relation_changed.emit(other, clamped)
		_mark_changed(&"relations")


func add_relation(other: StringName, delta: int) -> int:
	set_relation_to(other, relation_to(other) + delta)
	return relation_to(other)


func callname_for(other: StringName) -> String:
	var entry := _find(other)
	return entry.callname if entry != null else ""


## 设我对 [param other] 的定向称呼。
## [br][br]
## 值实际变化时发 [signal callname_changed] 并 _mark_changed(&"callname")，
## 与 [method set_relation_to] 的双通知对称。
func set_callname_for(other: StringName, value: String) -> void:
	var entry := _find(other)
	var old := entry.callname if entry != null else ""
	if entry == null:
		entry = RelationEntry.new()
		entry.target = other
		relations.append(entry)
	entry.callname = value
	if old != value:
		callname_changed.emit(other, value)
		_mark_changed(&"callname")


## 存档/复制走纯数据轨：[member relations] 是 Array[RelationEntry]，
## Resource 元素会被白名单轨的 Object 拒收，这里降成每条
## {target, relation, callname} 的字典数组（其余成员仍走基类白名单口径）。
func to_fields() -> Dictionary:
	var out := {
		"display_name": display_name,
		"min_value": min_value,
		"max_value": max_value,
	}
	var entries: Array = []
	for entry in relations:
		if entry != null:
			entries.append({
				"target": entry.target,
				"relation": entry.relation,
				"callname": entry.callname,
			})
	out["relations"] = entries
	return out


## 把纯数据字典写回；[member relations] 每条用 [code]new RelationEntry[/code] 重建
## 后整组替换，不复用入参引用（入参可能来自存档或外部数据）；
## 其余成员（display_name/min_value/max_value）交给基类白名单口径。
func apply_fields(fields: Dictionary) -> void:
	var incoming: Variant = fields.get("relations", null)
	if incoming == null:
		pass  # 没带 relations 就保持现状
	elif incoming is Array:
		var rebuilt: Array[RelationEntry] = []
		for item in incoming:
			if not (item is Dictionary):
				push_warning("RelationComponent.apply_fields：关系条目不是字典，已跳过（%s）" % str(item))
				continue
			var data: Dictionary = item
			var entry := RelationEntry.new()
			entry.target = StringName(str(data.get("target", &"")))
			entry.relation = int(data.get("relation", 0))
			entry.callname = str(data.get("callname", ""))
			rebuilt.append(entry)
		relations = rebuilt
	else:
		push_warning("RelationComponent.apply_fields：relations 来值不是 Array，已跳过")
	var rest := fields.duplicate()
	rest.erase("relations")
	super.apply_fields(rest)
