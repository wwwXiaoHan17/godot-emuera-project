class_name Character
extends Resource
## 角色宿主类。
##
## 角色 [Character] 由基础身份（id/名字/默认称呼）和可选组件 [CharacterComponent] 组成；
## 关系数据放在可选的 [RelationComponent] 里。
## 组件是 Resource，不是 Node：文本 Era 没有每帧需求，Resource 可 Inspector 编辑、
## 可存档、headless 可测。
## [br][br]
## 原型 vs 实例：同一个 .tres 原型可以 [method spawn] 出多个运行时实例；
## spawn 通过 [method CharacterComponent.duplicate_for_spawn] 重建组件，不依赖
## [method Resource.duplicate] 的嵌套复制行为。

@export var id: StringName = &""
@export var display_name: String = ""
## 默认称呼（别人没给你设称呼时用）。
@export var callname: String = ""
## 组件列表；运行时只能经 [method add_component] / [method remove_component] 变更
## （直改数组不会重建类型索引；.tres 原型可在编辑器里预先装配）。
@export var components: Array[CharacterComponent] = []
## 原型标记（只是语义标记；spawn 出来的实例为 false）。
@export var is_prototype := false

## 运行时类型索引：Script 身份 → 组件；懒构建，不导出。
## 同时收录组件实际脚本和它的基类脚本，所以 get_component(LifeComponent) 能找到子类。
var _type_index: Dictionary[Script, CharacterComponent] = {}
var _index_dirty := true


# ---------- 组件 ----------

## 加一个组件。
## [br][br]
## 按 [method CharacterComponent.component_type] 判断同类：同类旧组件会被替换。
func add_component(component: CharacterComponent) -> CharacterComponent:
	if component == null:
		return null
	_ensure_index()
	var identity: Script = component.component_type()
	if identity == null:
		return null
	var old: CharacterComponent = _type_index.get(identity, null)
	if old != null:
		components.erase(old)
	components.append(component)
	_rebuild_index()
	return component


## 按脚本类型找组件，支持继承（如 [code]character.get_component(LifeComponent)[/code]）。
func get_component(type: Script) -> CharacterComponent:
	if type == null:
		return null
	_ensure_index()
	return _type_index.get(type, null)

## 判断[param type]是否在存在，不存在则返回null。
func has_component(type: Script) -> bool:
	return get_component(type) != null


## 取[param type]的现有组件；没有就用 [param type] 新建一个并装上。
## [br][br]
## 供内容层免判空地拿可选组件（如 [code]get_or_add(AgeComponent).set_value(20)[/code]）。
## [param type] 不是 [CharacterComponent] 子类时 push_warning 并返回 null，不会装到角色上。
func get_or_add(type: Script) -> CharacterComponent:
	if type == null:
		return null
	var existing := get_component(type)
	if existing != null:
		return existing
	var component := type.new() as CharacterComponent
	if component == null:
		push_warning("Character.get_or_add：「%s」不是 CharacterComponent 子类，已忽略" % _script_name(type))
		return null
	return add_component(component)


## 按类型身份删除组件。
func remove_component(type: Script) -> void:
	if type == null:
		return
	_ensure_index()
	var component_item: CharacterComponent = _type_index.get(type, null)
	if component_item == null:
		return
	components.erase(component_item)
	_rebuild_index()


# ---------- 名字回退 ----------

## 显示时我对 [param other] 的称呼：可选关系组件的定向称呼 → 对方默认称呼 → 对方真名 → "-"。
func name_for(other: Character) -> String:
	if other == null:
		return "-"
	var relation_component := get_component(RelationComponent) as RelationComponent
	if relation_component != null:
		var custom := relation_component.callname_for(other.id)
		if custom != "":
			return custom
	if other.callname != "":
		return other.callname
	if other.display_name != "":
		return other.display_name
	return "-"


# ---------- 原型 ----------

## 从原型复制一个运行时实例。组件与关系都是独立副本，不共享。
func spawn(new_id: StringName) -> Character:
	var instance := Character.new()
	instance.id = new_id
	instance.display_name = display_name
	instance.callname = callname
	instance.is_prototype = false

	for component_item in components:
		if component_item == null:
			continue
		var copy := component_item.duplicate_for_spawn()
		if copy == null:
			push_warning("spawn：组件「%s」复制失败（脚本缺 resource_path），已跳过" % _script_name(component_item.get_script()))
			continue
		instance.add_component(copy)

	return instance


# ---------- 内部 ----------

func _ensure_index() -> void:
	if not _index_dirty:
		return
	_rebuild_index()


## 重建类型索引：identity 槽与基类槽统一“后者胜”（按数组序后写覆盖）。
## [br][br]
## 与 [method add_component] 的同类替换语义对齐：直装（.tres 编辑器装配）了同
## identity 的多个组件时，索引、替换、spawn 投影都认定数组里靠后的那个生效，
## 不再出现 identity 槽指后者、基类槽指前者的失配。
func _rebuild_index() -> void:
	_type_index.clear()
	for component_item in components:
		if component_item == null:
			continue
		# 收录实际脚本及基类，支持按基础类型查找子类；一律后写覆盖。
		var script: Script = component_item.get_script()
		while script != null:
			_type_index[script] = component_item
			script = script.get_base_script()
		# 类型身份可能与实际脚本不同（如子类继承基类身份），最后写保证后者胜。
		var identity: Script = component_item.component_type()
		if identity != null:
			_type_index[identity] = component_item
	_index_dirty = false


func _script_name(script: Script) -> String:
	if script == null:
		return "<无脚本>"
	if script.get_global_name() != "":
		return script.get_global_name()
	return script.resource_path if script.resource_path != "" else "<匿名脚本>"
