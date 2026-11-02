extends Node
## CheckCharacter, 校验角色组件系统
##
## 覆盖：组件字段/信号、to_fields/apply_fields 往返、组件类型身份与显示名、
## Character 组件检索/替换/删除、关系与称呼回退、spawn 深拷贝独立、
## CharacterBook 增查替换。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

class SlimeLifeComponent extends LifeComponent:
	pass


class FakeLifeComponent extends CharacterComponent:
	func _init() -> void:
		display_name = "生命"


class BowlComponent extends CharacterComponent:
	## 测试用容器组件：混合容器成员（含 Object 元素的字段应被 to_fields 整字段跳过）。
	@export var plain: int = 0
	@export var pure: Array = []
	@export var holding: Array = []
	@export var nested: Dictionary = {}
	@export var names: Array[StringName] = []
	@export var flags: Dictionary[StringName, bool] = {}

	func _init() -> void:
		display_name = "碗"


class NotAComponent extends RefCounted:
	## 测试用非组件类：get_or_add 应拒绝并警告。
	pass


var _changed: Array[StringName] = []
var _died_count := 0


func _ready() -> void:
	var failures: Array[String] = []

	# 1) 生命组件：增减、夹取、信号
	var life := LifeComponent.new()
	life.component_changed.connect(_on_changed)
	if life.get_display_name() != "生命":
		failures.append("生命组件显示名应为“生命”，实际 %s" % life.get_display_name())
	life.hurt(30)
	if life.value != 70:
		failures.append("hurt(30) 后生命应为 70，实际 %d" % life.value)
	life.hurt(1000)
	if life.value != 0:
		failures.append("hurt(1000) 应夹到 0，实际 %d" % life.value)
	life.heal(20)
	if life.value != 20:
		failures.append("heal(20) 后生命应为 20，实际 %d" % life.value)
	if _changed.size() != 3:
		failures.append("component_changed 应发 3 次，实际 %d" % _changed.size())

	# 2) AgeComponent 是可选组件；Character 自身没有年龄
	var age_component := AgeComponent.new()
	if age_component.display_name != "年龄":
		failures.append("年龄组件显示名应为“年龄”，实际 %s" % age_component.display_name)
	if age_component.value != 18:
		failures.append("年龄组件默认值应为 18，实际 %d" % age_component.value)
	var bare_character := Character.new()
	if bare_character.get_component(AgeComponent) != null:
		failures.append("新 Character 不应默认带 AgeComponent")
	for prop in bare_character.get_script().get_script_property_list():
		if String(prop.get("name")) == "age":
			failures.append("Character 脚本属性中不应再有 age")
	var aged := Character.new()
	var aged_component := AgeComponent.new()
	aged_component.value = 21
	aged.add_component(aged_component)
	if aged.get_component(AgeComponent) != aged_component:
		failures.append("装有 AgeComponent 的角色应能按类型找到它")

	# died 信号：正好到达或跳过 died_age 都只发一次
	_died_count = 0
	var aging := AgeComponent.new()
	aging.value = 79
	aging.died_age = 80
	aging.died.connect(_on_died)
	aging.increase(1)
	if _died_count != 1:
		failures.append("正好到达 died_age 应发一次 died，实际 %d" % _died_count)
	aging.increase(1)
	if _died_count != 1:
		failures.append("死后继续成长不应重复发 died，实际 %d" % _died_count)
	aging.decrease(5)
	aging.increase(10)
	if _died_count != 1:
		failures.append("年龄回落再越过也不应重复发 died，实际 %d" % _died_count)

	var jumping := AgeComponent.new()
	jumping.value = 78
	jumping.died_age = 80
	jumping.died.connect(_on_died)
	jumping.increase(5)
	if jumping.value != 83:
		failures.append("increase(5) 后年龄应为 83，实际 %d" % jumping.value)
	if _died_count != 2:
		failures.append("一次加龄跳过 died_age 也应发 died，实际 %d" % _died_count)

	# 3) 空显示名回退到脚本类名
	var unnamed := LifeComponent.new()
	unnamed.display_name = ""
	if unnamed.get_display_name() != "LifeComponent":
		failures.append("空显示名应回退 LifeComponent，实际 %s" % unnamed.get_display_name())

	# 3) 类型身份：LifeComponent 的身份是 LifeComponent，子类继承该身份
	if LifeComponent.new().component_type() != LifeComponent:
		failures.append("LifeComponent.component_type() 应返回 LifeComponent")
	var slime := SlimeLifeComponent.new()
	if slime.component_type() != LifeComponent:
		failures.append("SlimeLifeComponent 应继承 LifeComponent 的类型身份")

	var base_host := Character.new()
	base_host.add_component(slime)
	if base_host.get_component(LifeComponent) != slime:
		failures.append("component(LifeComponent) 应能找到子类组件")
	if base_host.get_component(SlimeLifeComponent) != slime:
		failures.append("component(SlimeLifeComponent) 应能找到自己")

	# 同一身份：子类替换普通生命组件，不并存
	var normal_life := LifeComponent.new()
	base_host.add_component(normal_life)
	if base_host.components.size() != 1:
		failures.append("同生命身份的组件应替换，实际数量 %d" % base_host.components.size())
	if base_host.get_component(LifeComponent) != normal_life:
		failures.append("替换后 component(LifeComponent) 应返回新组件")

	# 按类型删除
	base_host.remove_component(LifeComponent)
	if base_host.get_component(LifeComponent) != null or base_host.components.size() != 0:
		failures.append("按类型删除后应查不到组件且数组为空")

	# 4) 同显示名的无关组件不能替换生命组件
	var display_host := Character.new()
	var real_life := LifeComponent.new()
	display_host.add_component(real_life)
	display_host.add_component(FakeLifeComponent.new())
	if display_host.components.size() != 2:
		failures.append("同显示名的无关组件应并存，实际数量 %d" % display_host.components.size())
	if display_host.get_component(LifeComponent) != real_life:
		failures.append("同显示名的无关组件不应替换 LifeComponent")

	# 5) 连续增删后索引仍正确
	var index_host := Character.new()
	for i in 5:
		index_host.add_component(LifeComponent.new())
	if index_host.components.size() != 1:
		failures.append("同身份连续添加后应只剩 1 个组件")
	index_host.remove_component(LifeComponent)
	index_host.add_component(SlimeLifeComponent.new())
	if index_host.get_component(LifeComponent) == null:
		failures.append("删除后重新添加，索引应恢复")

	# 6) to_fields / apply_fields 往返；未知字段/类型静默跳过
	var fields := life.to_fields()
	var restored := LifeComponent.new()
	restored.apply_fields(fields)
	if restored.value != 20 or restored.max_value != 100:
		failures.append("字段往返失败：值=%d 上限=%d" % [restored.value, restored.max_value])
	restored.apply_fields({"不存在的字段": 123})
	if restored.value != 20:
		failures.append("未知字段不应改变数据")

	# 7) Character：组件检索
	var daughter := Character.new()
	daughter.id = &"daughter"
	daughter.display_name = "阿丽丝"
	daughter.callname = "女儿"
	daughter.add_component(life)
	var relations_component := RelationComponent.new()
	daughter.add_component(relations_component)
	if daughter.get_component(LifeComponent) != life:
		failures.append("get_component(LifeComponent) 没找到组件")
	if daughter.get_component(RelationComponent) == null:
		failures.append("get_component(RelationComponent) 没找到组件")

	# 8) 关系与称呼回退
	var player := Character.new()
	player.id = &"player"
	player.display_name = "你"
	player.callname = "你"
	relations_component.set_relation_to(&"player", 20)
	if relations_component.relation_to(&"player") != 20:
		failures.append("relation_to 应为 20，实际 %d" % relations_component.relation_to(&"player"))
	if relations_component.add_relation(&"player", 5) != 25:
		failures.append("add_relation 应返回 25")
	relations_component.max_value = 30
	if relations_component.add_relation(&"player", 10) != 30:
		failures.append("关系组件应把关系夹到上限 30")
	if relations_component.callname_for(&"player") != "":
		failures.append("没设自定义称呼时应返回空串")
	if daughter.name_for(player) != "你":
		failures.append("称呼回退应取对方默认称呼“你”，实际 %s" % daughter.name_for(player))
	relations_component.set_callname_for(&"player", "主人")
	if daughter.name_for(player) != "主人":
		failures.append("自定义称呼应优先，实际 %s" % daughter.name_for(player))
	if daughter.name_for(null) != "-":
		failures.append("name_for(null) 应返回“-”")

	# 9) spawn：组件和关系都是独立副本
	var proto := Character.new()
	proto.id = &"prototype"
	proto.display_name = "原型"
	proto.add_component(LifeComponent.new())
	var proto_relations := RelationComponent.new()
	proto.add_component(proto_relations)
	proto_relations.set_relation_to(&"player", 50)
	var instance := proto.spawn(&"daughter_copy")
	if instance.id != &"daughter_copy":
		failures.append("spawn 的 id 不对")
	if instance.get_component(LifeComponent) == proto.get_component(LifeComponent):
		failures.append("spawn 后组件不能和原型共享实例")
	(instance.get_component(LifeComponent) as LifeComponent).hurt(10)
	if (proto.get_component(LifeComponent) as LifeComponent).value != 100:
		failures.append("改实例组件不应影响原型")
	var instance_relations := instance.get_component(RelationComponent) as RelationComponent
	if instance_relations == null or instance_relations == proto_relations:
		failures.append("spawn 后关系组件应是独立实例")
	elif instance_relations.relation_to(&"player") != 50:
		failures.append("spawn 应复制关系，实际 %d" % instance_relations.relation_to(&"player"))
	instance_relations.add_relation(&"player", 10)
	if proto_relations.relation_to(&"player") != 50:
		failures.append("改实例关系不应影响原型")

	# 10) 同类型组件覆写
	var new_life := LifeComponent.new()
	daughter.add_component(new_life)
	if daughter.get_component(LifeComponent) != new_life:
		failures.append("同生命类型的组件应覆写旧组件")
	if daughter.components.size() != 2:
		failures.append("同类型覆写后组件数应保持 2，实际 %d" % daughter.components.size())

	# 11) CharacterBook：增、查、替换
	var book := CharacterBook.new()
	book.add(player)
	book.add(daughter)
	if book.find(&"daughter") != daughter:
		failures.append("book.find(&\"女儿\") 没找到")
	if book.all().size() != 2:
		failures.append("book.all() 应有 2 个角色，实际 %d" % book.all().size())
	if not book.ids().has(&"player"):
		failures.append("book.ids() 应包含“玩家”")
	var replaced := Character.new()
	replaced.id = &"daughter"
	book.add(replaced)
	if book.find(&"daughter") != replaced or book.all().size() != 2:
		failures.append("同 id 加角色应替换，不应重复")

	# 12) 直装同 identity 组件：索引统一“后者胜”（identity 槽与基类槽一致，对齐 add_component 替换语义）
	var dup_host := Character.new()
	var slime_a := SlimeLifeComponent.new()
	var slime_b := SlimeLifeComponent.new()
	dup_host.components = [slime_a, slime_b]
	if dup_host.get_component(LifeComponent) != slime_b:
		failures.append("直装两个同子类生命组件时 LifeComponent 槽应后者胜，实际 %s" % _component_name(dup_host.get_component(LifeComponent)))
	if dup_host.get_component(SlimeLifeComponent) != slime_b:
		failures.append("实际脚本槽（SlimeLifeComponent）也应后者胜，实际 %s" % _component_name(dup_host.get_component(SlimeLifeComponent)))
	var dup2_host := Character.new()
	var plain_a := LifeComponent.new()
	var plain_b := LifeComponent.new()
	dup2_host.components = [plain_a, plain_b]
	if dup2_host.get_component(LifeComponent) != plain_b:
		failures.append("直装两个普通生命组件时 LifeComponent 槽应后者胜，实际 %s" % _component_name(dup2_host.get_component(LifeComponent)))
	var dup2_spawn := dup2_host.spawn(&"dup2_spawn")
	if dup2_spawn.get_component(LifeComponent) == null:
		failures.append("直装重复 identity 的原型 spawn 后应仍能按类型拿到组件（后者胜投影）")
	elif dup2_spawn.get_component(LifeComponent) == plain_b:
		failures.append("spawn 实例不能与原型共享组件")
	if dup2_spawn.components.size() != 1:
		failures.append("同 identity 直装两个的 spawn 投影应是 1 个（后者胜），实际 %d" % dup2_spawn.components.size())

	# 13) to_fields：含 Object 元素的 Array/Dictionary 整字段跳过（防共享引用）；纯容器仍深拷贝
	var bowl := BowlComponent.new()
	bowl.plain = 7
	bowl.pure = [1, 2, 3]
	bowl.holding = [1, RefCounted.new()]
	bowl.nested = {"list": [RefCounted.new()]}
	var bowl_fields := bowl.to_fields()
	if bowl_fields.has("holding"):
		failures.append("含 Object 元素的 Array 字段应整字段跳过")
	if bowl_fields.has("nested"):
		failures.append("嵌套容器里的 Object 也应让整字段跳过")
	if not bowl_fields.has("pure") or not bowl_fields.has("plain"):
		failures.append("纯容器与标量字段应保留在 fields 里")
	bowl.pure.append(4)
	if (bowl_fields["pure"] as Array).size() != 3:
		failures.append("纯容器字段应是深拷贝，不受原组件后续修改影响")

	# 14) apply_fields：未知/类型不符字段跳过后数据不变；typed 容器元素预检拦坏元素
	var apply_bowl := BowlComponent.new()
	apply_bowl.names = [&"a"]
	apply_bowl.apply_fields({"plain": 1, "不存在的字段": 123})
	if apply_bowl.plain != 1:
		failures.append("apply_fields 应写入已知同类型字段")
	apply_bowl.apply_fields({"plain": "不是数字"})
	if apply_bowl.plain != 1:
		failures.append("类型不符的字段应跳过，实际 %s" % str(apply_bowl.plain))
	apply_bowl.apply_fields({"names": [&"b", 123]})
	if apply_bowl.names.size() != 1:
		failures.append("typed 容器混入坏元素应整字段跳过，实际 %d 个" % apply_bowl.names.size())
	apply_bowl.apply_fields({"names": [&"b", &"c"]})
	if apply_bowl.names.size() != 2 or apply_bowl.names[1] != &"c":
		failures.append("typed 容器合法数据应整字段写入")
	apply_bowl.apply_fields({"flags": {&"on": true}})
	if not apply_bowl.flags.get(&"on", false):
		failures.append("typed Dictionary 合法数据应写入")
	apply_bowl.apply_fields({"flags": {&"on": "yes"}})
	if apply_bowl.flags.get(&"on", true) != true:
		failures.append("typed Dictionary 混入坏值应整字段跳过")

	# 15) get_or_add：有则取现有，无则新建并装上；非 CharacterComponent 子类警告并返回 null
	var ga_host := Character.new()
	var got_life := ga_host.get_or_add(LifeComponent)
	if got_life == null or not (got_life is LifeComponent):
		failures.append("get_or_add(LifeComponent) 应返回新组件")
	elif ga_host.components.size() != 1 or ga_host.get_component(LifeComponent) != got_life:
		failures.append("get_or_add 新建的组件应已装上角色")
	elif ga_host.get_or_add(LifeComponent) != got_life:
		failures.append("get_or_add 第二次应返回同一个组件")
	ga_host.remove_component(LifeComponent)
	var regot := ga_host.get_or_add(LifeComponent)
	if regot == null or regot == got_life or ga_host.components.size() != 1:
		failures.append("删除后 get_or_add 应再新建一个")
	var got_bowl := ga_host.get_or_add(BowlComponent)
	if got_bowl == null or ga_host.get_component(BowlComponent) != got_bowl:
		failures.append("get_or_add 应支持装自定义子类组件")
	if ga_host.get_or_add(NotAComponent) != null:
		failures.append("非 CharacterComponent 子类应返回 null")
	if ga_host.components.size() != 2:
		failures.append("非法类型不应在角色上留下组件，实际数量 %d" % ga_host.components.size())
	if ga_host.get_or_add(null) != null:
		failures.append("get_or_add(null) 应返回 null")

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


func _on_changed(what: StringName) -> void:
	_changed.append(what)


func _on_died() -> void:
	_died_count += 1



func _component_name(component: CharacterComponent) -> String:
	if component == null:
		return "<null>"
	var script: Script = component.get_script()
	if script == null:
		return "<无脚本>"
	if script.get_global_name() != "":
		return script.get_global_name()
	return script.resource_path if script.resource_path != "" else "<匿名脚本>"
