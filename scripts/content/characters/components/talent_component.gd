class_name TalentListComponent
extends CharacterComponent
## TalentComponent, 天赋组件（示例模板）
##
## 类名 TalentListComponent 与文件名 talent_component.gd 的不一致是历史遗留；
## 为免 .uid 与既有引用断裂，不改文件名。
##
## 存这个角色选中的天赋程序 ID（如 &"childish"）；显示时映射回中文名。

## 全部天赋数据的唯一清单（TalentData .tres）。天赋选择事件生成格子也从这里取，
## 不再各自维护一份 preload 列表；ID 用于存档/程序，显示名用于界面。
const TALENT_RESOURCES := [
	preload("res://resources/talent_resource/无知.tres"),
	preload("res://resources/talent_resource/幼稚.tres"),
	preload("res://resources/talent_resource/早熟.tres"),
	preload("res://resources/talent_resource/性压抑.tres"),
	preload("res://resources/talent_resource/易漏尿.tres"),
]

@export var selected: Array[StringName] = []


func _init() -> void:
	display_name = "天赋"


func set_talents(talents: Array[StringName]) -> void:
	selected = talents.duplicate()
	_mark_changed(&"selected")


func text() -> String:
	if selected.is_empty():
		return "无"
	var names: Array[String] = []
	for talent in selected:
		var label := str(talent)
		for resource in TALENT_RESOURCES:
			var data: TalentData = resource
			if data.talent_name == talent:
				label = data.display_name
				break
		names.append(label)
	return "、".join(names)
