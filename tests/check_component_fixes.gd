extends Node
## CheckComponentFixes, 校验引擎与组件 bugfix（2026-11-01 批次）
##
## 覆盖：SexyComponent 四档派生等级（阈值表/分支顺序/派生通知）、
## AgeComponent set_value 设定不越死 + increase 跨界死亡、
## 空脚本组件 duplicate_for_spawn/spawn 的警告跳过。
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

var _died_count := 0
var _changes: Array[StringName] = []


func _ready() -> void:
	var failures: Array[String] = []

	# 1) sexy 四档派生：<0 厌恶 / 0..999 正常 / 1000..4999 萌芽 / >=5000 高涨
	var sexy := SexyComponent.new()
	if sexy.sexy_value != 0 or sexy.sexy_level != SexyComponent.SexyLevel.NORMAL:
		failures.append("新建性欲组件应为 0/正常，实际 %d/%d" % [sexy.sexy_value, sexy.sexy_level])
	sexy.component_changed.connect(_on_changed)
	_changes.clear()
	sexy.set_value(0)
	if sexy.sexy_level != SexyComponent.SexyLevel.NORMAL:
		failures.append("0 应为正常档")
	if _changes != [&"sexy_value"]:
		failures.append("等级未变时不应标记 sexy_level，实际 %s" % str(_changes))
	_changes.clear()
	sexy.set_value(-1)
	if sexy.sexy_level != SexyComponent.SexyLevel.DISGUST:
		failures.append("负值应为厌恶档，实际 %d" % sexy.sexy_level)
	sexy.set_value(999)
	if sexy.sexy_level != SexyComponent.SexyLevel.NORMAL:
		failures.append("999 应仍为正常档，实际 %d" % sexy.sexy_level)
	sexy.set_value(1000)
	if sexy.sexy_level != SexyComponent.SexyLevel.BUDDING:
		failures.append("1000 应进萌芽档，实际 %d" % sexy.sexy_level)
	sexy.set_value(4999)
	if sexy.sexy_level != SexyComponent.SexyLevel.BUDDING:
		failures.append("4999 应仍为萌芽档，实际 %d" % sexy.sexy_level)
	_changes.clear()
	sexy.set_value(5000)
	if sexy.sexy_level != SexyComponent.SexyLevel.AROUSED:
		failures.append("5000 应进高涨档（旧代码该分支被 >=1000 挡死），实际 %d" % sexy.sexy_level)
	if _changes != [&"sexy_value", &"sexy_level"]:
		failures.append("跨档时应先标 sexy_value 再标 sexy_level，实际 %s" % str(_changes))
	sexy.increased(1)
	if sexy.sexy_value != 5001 or sexy.sexy_level != SexyComponent.SexyLevel.AROUSED:
		failures.append("高涨档内增长应保持高涨，实际 %d/%d" % [sexy.sexy_value, sexy.sexy_level])
	sexy.decreased(5002)
	if sexy.sexy_value != -1 or sexy.sexy_level != SexyComponent.SexyLevel.DISGUST:
		failures.append("减到负值应为厌恶档，实际 %d/%d" % [sexy.sexy_value, sexy.sexy_level])
	sexy.increased(1)
	if sexy.sexy_value != 0 or sexy.sexy_level != SexyComponent.SexyLevel.NORMAL:
		failures.append("回到 0 应恢复正常档，实际 %d/%d" % [sexy.sexy_value, sexy.sexy_level])

	# 2) age set_value：设定不越死（抬 died_age），increase 才判死
	var age := AgeComponent.new()
	age.died.connect(_on_died)
	_died_count = 0
	if age.value != 18 or age.died_age < 28:
		failures.append("新组件默认 18 岁、died_age 保底 28，实际 %d/%d" % [age.value, age.died_age])
	var died_age_before := age.died_age
	age.component_changed.connect(_on_changed)
	_changes.clear()
	age.set_value(25)
	if age.value != 25 or age.died_age != died_age_before:
		failures.append("设定低于死亡年龄时不应动 died_age，实际 %d/%d" % [age.value, age.died_age])
	if _changes != [&"value"]:
		failures.append("set_value 应标记 value，实际 %s" % str(_changes))
	if _died_count != 0:
		failures.append("set_value 不应触发 died，实际 %d 次" % _died_count)
	age.set_value(200)
	if age.died_age != 201:
		failures.append("设定越过死亡年龄时应抬到 v+1=201，实际 %d" % age.died_age)
	if age.value != 200 or _died_count != 0:
		failures.append("抬完死亡年龄后落值且不发 died，实际 %d/%d 次" % [age.value, _died_count])
	age.increase(1)
	if age.value != 201 or _died_count != 1:
		failures.append("increase 跨过 died_age 才发 died（increase 才是死亡路径），实际 %d/%d 次" % [age.value, _died_count])
	age.increase(5)
	if _died_count != 1:
		failures.append("死后继续成长不应重复发 died，实际 %d 次" % _died_count)

	var aging := AgeComponent.new()
	aging.died_age = 30
	aging.died.connect(_on_died)
	_died_count = 0
	aging.set_value(30)
	if aging.died_age != 31 or _died_count != 0:
		failures.append("正好等于死亡年龄也应抬到 31 且不发 died，实际 %d/%d 次" % [aging.died_age, _died_count])
	aging.increase(1)
	if _died_count != 1 or aging.value != 31:
		failures.append("抬过后 increase 跨 31 应发一次 died，实际 %d 次/%d" % [_died_count, aging.value])
	aging.set_value(50)
	if aging.died_age != 31:
		failures.append("已死后 set_value 不再抬 died_age，实际 %d" % aging.died_age)
	aging.increase(10)
	if _died_count != 1:
		failures.append("已死后继续成长不再发 died，实际 %d 次" % _died_count)

	# 3) 空脚本组件：duplicate_for_spawn 警告并返回 null；spawn 跳过该组件并继续
	var ad_hoc := GDScript.new()
	ad_hoc.source_code = "extends CharacterComponent
"
	ad_hoc.reload()
	var ad_hoc_component := ad_hoc.new() as CharacterComponent
	if ad_hoc_component == null:
		failures.append("运行时脚本能实例化出组件")
	elif ad_hoc_component.duplicate_for_spawn() != null:
		failures.append("脚本缺 resource_path 时 duplicate_for_spawn 应返回 null（并警告）")
	var ad_hoc_host := Character.new()
	ad_hoc_host.components = [ad_hoc_component]
	var ad_hoc_spawn := ad_hoc_host.spawn(&"ad_hoc_spawn")
	if ad_hoc_spawn == null:
		failures.append("spawn 应跳过复制失败的组件并继续")
	elif not ad_hoc_spawn.components.is_empty():
		failures.append("复制失败的组件不应出现在 spawn 实例里，实际 %d 个" % ad_hoc_spawn.components.size())
	var file_host := Character.new()
	file_host.components = [LifeComponent.new()]
	if file_host.spawn(&"file_spawn").components.size() != 1:
		failures.append("正常脚本组件 spawn 后应保留 1 个")

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)


func _on_changed(what: StringName) -> void:
	_changes.append(what)


func _on_died() -> void:
	_died_count += 1
