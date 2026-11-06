extends Node
## CheckRelations, 校验关系组件 + 多角色关系矩阵
##
## 覆盖：原型加载、spawn 独立、方向关系、范围夹取、变更通知、
## 称呼回退/自定义、无 RelationComponent 时的回退、CharacterBook。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const PLAYER_PROTO := preload("res://scripts/content/characters/prototypes/玩家.tres")
const DAUGHTER_PROTO := preload("res://scripts/content/characters/prototypes/女儿.tres")
const MAID_PROTO := preload("res://scripts/content/characters/prototypes/女仆.tres")
const FATHER_PROTO := preload("res://scripts/content/characters/prototypes/父亲.tres")

var _changed_target: StringName = &""
var _changed_value := -1
var _changed_count := 0
var _callname_target: StringName = &""
var _callname_value := ""
var _callname_count := 0
var _component_changes: Array[StringName] = []


func _ready() -> void:
	var failures: Array[String] = []

	# 1) 原型本身：关系数据在 RelationComponent 里，Character 不再持有
	if PLAYER_PROTO.id != &"player" or DAUGHTER_PROTO.id != &"daughter" \
			or MAID_PROTO.id != &"maid" or FATHER_PROTO.id != &"father":
		failures.append("原型程序 ID 应分别是 player/daughter/maid/father")
	var player_proto_relations := PLAYER_PROTO.get_component(RelationComponent) as RelationComponent
	var daughter_proto_relations := DAUGHTER_PROTO.get_component(RelationComponent) as RelationComponent
	var maid_proto_relations := MAID_PROTO.get_component(RelationComponent) as RelationComponent
	if player_proto_relations == null or daughter_proto_relations == null or maid_proto_relations == null:
		failures.append("三个原型都应带 RelationComponent")
	else:
		if player_proto_relations.relation_to(&"daughter") != 50:
			failures.append("玩家原型对女儿好感应为 50，实际 %d" % player_proto_relations.relation_to(&"daughter"))
		if daughter_proto_relations.relation_to(&"player") != 20:
			failures.append("女儿原型对玩家好感应为 20，实际 %d" % daughter_proto_relations.relation_to(&"player"))
		if maid_proto_relations.relation_to(&"daughter") != 30:
			failures.append("女仆原型对女儿好感应为 30，实际 %d" % maid_proto_relations.relation_to(&"daughter"))

	var bare_character := Character.new()
	for prop in bare_character.get_script().get_script_property_list():
		if String(prop.get("name")) == "relations":
			failures.append("Character 脚本属性中不应再有 relations")

	# 2) spawn 出来的实例是独立副本（含关系组件）
	var player := PLAYER_PROTO.spawn(&"player")
	var daughter := DAUGHTER_PROTO.spawn(&"daughter")
	var maid := MAID_PROTO.spawn(&"maid")
	var player_relations := player.get_component(RelationComponent) as RelationComponent
	var daughter_relations := daughter.get_component(RelationComponent) as RelationComponent
	var maid_relations := maid.get_component(RelationComponent) as RelationComponent
	if player.is_prototype:
		failures.append("spawn 出的实例不应是原型")
	if player_relations == null or daughter_relations == null or maid_relations == null:
		failures.append("spawn 后实例应保留 RelationComponent")
	elif player_relations == player_proto_relations or daughter_relations == daughter_proto_relations:
		failures.append("spawn 后关系组件不能和原型共享")
	elif player.get_component(LifeComponent) == PLAYER_PROTO.get_component(LifeComponent):
		failures.append("spawn 后普通组件也不能和原型共享")

	# 3) 关系是有方向的（A→B 与 B→A 可以不同）
	if player_relations != null and daughter_relations != null:
		if player_relations.relation_to(&"daughter") != 50:
			failures.append("玩家对女儿好感应为 50，实际 %d" % player_relations.relation_to(&"daughter"))
		if daughter_relations.relation_to(&"player") != 20:
			failures.append("女儿对玩家好感应为 20，实际 %d" % daughter_relations.relation_to(&"player"))
		if player_relations.relation_to(&"daughter") == daughter_relations.relation_to(&"player"):
			failures.append("关系方向测试失败：两边不应相等")

	# 4) 称呼回退与自定义
	if daughter.name_for(player) != "你":
		failures.append("女儿对玩家的称呼应回退为“你”，实际 %s" % daughter.name_for(player))
	if maid.name_for(daughter) != "女儿":
		failures.append("女仆对女儿的称呼应回退为“女儿”，实际 %s" % maid.name_for(daughter))
	if daughter_relations != null:
		daughter_relations.set_callname_for(&"player", "爸爸")
		if daughter.name_for(player) != "爸爸":
			failures.append("自定义称呼应优先，实际 %s" % daughter.name_for(player))

	# 5) 范围夹取与变更通知（只有实际值变化才通知）
	if daughter_relations != null:
		daughter_relations.relation_changed.connect(_on_relation_changed)
		daughter_relations.set_relation_to(&"player", 999)
		if daughter_relations.relation_to(&"player") != 100:
			failures.append("关系应夹到 max_value=100，实际 %d" % daughter_relations.relation_to(&"player"))
		if _changed_count != 1 or _changed_target != &"player" or _changed_value != 100:
			failures.append("第一次夹取应通知 target=玩家 value=100，实际 count=%d target=%s value=%d" % [
				_changed_count, str(_changed_target), _changed_value
			])
		daughter_relations.add_relation(&"player", -1000)
		if daughter_relations.relation_to(&"player") != 0:
			failures.append("关系应夹到 min_value=0，实际 %d" % daughter_relations.relation_to(&"player"))
		if _changed_count != 2 or _changed_value != 0:
			failures.append("减到 0 应再通知一次，实际 count=%d value=%d" % [_changed_count, _changed_value])
		daughter_relations.set_relation_to(&"player", 0)
		if _changed_count != 2:
			failures.append("值没变时不应重复通知，实际 count=%d" % _changed_count)
		daughter_relations.add_relation(&"player", 10)
		if daughter_relations.relation_to(&"player") != 10:
			failures.append("实例关系加 10 后应为 10，实际 %d" % daughter_relations.relation_to(&"player"))

	# 6) 改实例不影响原型（关系值与定向称呼都不能漏回原型）
	if daughter_relations != null:
		if daughter_proto_relations.relation_to(&"player") != 20:
			failures.append("改实例不应影响原型，原型关系实际 %d" % daughter_proto_relations.relation_to(&"player"))
		var proto_callname := daughter_proto_relations.callname_for(&"player")
		if proto_callname != "":
			failures.append("改实例称呼不应影响原型，原型称呼实际 %s" % proto_callname)

	# 7) 没有 RelationComponent 的角色：name_for 仍按默认称呼/真名回退
	var stranger := Character.new()
	stranger.id = &"stranger"
	stranger.display_name = "路人"
	stranger.callname = "路人"
	var you := Character.new()
	you.id = &"you"
	you.display_name = "你"
	you.callname = "你"
	if stranger.name_for(you) != "你":
		failures.append("无关系组件时应回退对方默认称呼，实际 %s" % stranger.name_for(you))
	if stranger.name_for(null) != "-":
		failures.append("name_for(null) 应返回“-”")

	# 8) CharacterBook 多角色
	var book := CharacterBook.new()
	book.add(player)
	book.add(daughter)
	book.add(maid)
	if book.all().size() != 3:
		failures.append("角色表应有 3 个角色，实际 %d" % book.all().size())
	if book.find(&"maid") != maid:
		failures.append("角色表按 id 找“女仆”失败")
	if not book.ids().has(&"player"):
		failures.append("角色表 ids 应包含“玩家”")

	# 9) callname_changed：值实际变化才发，且与 _mark_changed(&"callname") 双通知（对称 relation_changed）
	if daughter_relations != null:
		daughter_relations.callname_changed.connect(_on_callname_changed)
		daughter_relations.component_changed.connect(_on_component_changed)
		daughter_relations.set_callname_for(&"player", "哥哥")
		if _callname_count != 1 or _callname_target != &"player" or _callname_value != "哥哥":
			failures.append("第一次设称呼应发 callname_changed(target=玩家 value=哥哥)，实际 count=%d target=%s value=%s" % [
				_callname_count, str(_callname_target), _callname_value
			])
		if not _component_changes.has(&"callname"):
			failures.append("称呼变化应同时 _mark_changed(&\"callname\")，实际 %s" % str(_component_changes))
		_component_changes.clear()
		daughter_relations.set_callname_for(&"player", "哥哥")
		if _callname_count != 1 or not _component_changes.is_empty():
			failures.append("称呼没变时不应重复通知，实际 count=%d mark=%s" % [_callname_count, str(_component_changes)])
		daughter_relations.set_callname_for(&"player", "爸爸")
		if _callname_count != 2 or _callname_value != "爸爸":
			failures.append("称呼再变应再通知，实际 count=%d value=%s" % [_callname_count, _callname_value])

	# 10) relations 序列化往返：to_fields 出纯数据，apply_fields 重建新条目（不复用入参引用）
	var save_from := RelationComponent.new()
	save_from.set_relation_to(&"player", 42)
	save_from.set_callname_for(&"player", "主人")
	save_from.set_relation_to(&"maid", 7)
	var saved_fields: Dictionary = save_from.to_fields()
	var saved_relations: Variant = saved_fields.get("relations", null)
	if not (saved_relations is Array):
		failures.append("to_fields 的 relations 应是 Array（白名单纯数据轨）")
	else:
		for item in saved_relations:
			if not (item is Dictionary) or not item.has("target") or not item.has("relation") or not item.has("callname"):
				failures.append("relations 每条应是 {target,relation,callname} 字典，实际 %s" % str(item))
	if int(saved_fields.get("min_value", -1)) != 0 or int(saved_fields.get("max_value", -1)) != 100:
		failures.append("min_value/max_value 应随 fields 序列化")
	var restored := RelationComponent.new()
	restored.apply_fields(saved_fields)
	if restored.relation_to(&"player") != 42 or restored.callname_for(&"player") != "主人":
		failures.append("往返后关系/称呼应还原，实际 %d / %s" % [
			restored.relation_to(&"player"), restored.callname_for(&"player")
		])
	if restored.relation_to(&"maid") != 7:
		failures.append("往返后对女仆的好感应为 7，实际 %d" % restored.relation_to(&"maid"))
	for entry in restored.relations:
		if save_from.relations.has(entry):
			failures.append("apply_fields 重建的条目不能复用入参引用")
	restored.set_relation_to(&"player", 50)
	if save_from.relation_to(&"player") != 42:
		failures.append("改还原件不应影响原件，实际 %d" % save_from.relation_to(&"player"))

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


func _on_relation_changed(target: StringName, value: int) -> void:
	_changed_target = target
	_changed_value = value
	_changed_count += 1


func _on_callname_changed(target: StringName, value: String) -> void:
	_callname_target = target
	_callname_value = value
	_callname_count += 1


func _on_component_changed(what: StringName) -> void:
	_component_changes.append(what)
