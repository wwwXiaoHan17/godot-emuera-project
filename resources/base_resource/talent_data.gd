class_name TalentData
extends Resource

@export var talent_name: StringName
@export var display_name: String
## 填上互斥天赋的 id，两边都填（幼稚填早熟，早熟填幼稚）
@export var conflicts_with: Array[StringName] = []
