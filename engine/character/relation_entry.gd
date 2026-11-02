class_name RelationEntry
extends Resource
## RelationEntry, 一个角色对另一个角色的关系（出边）
##
## 关系是“我 → 别人”的一条出边：好感值 + 我对别人的称呼。
## 称呼留空时回退：对方默认称呼 → 对方真名 → "-"（由 [method Character.name_for] 处理）。

## 目标角色 id（如 &"player"）。
@export var target: StringName
## 好感/信赖值。
@export var relation: int = 0
## 我对目标的称呼；空串 = 用对方默认称呼。
@export var callname: String = ""


## 复制一条独立关系条目（spawn 用，避免 Resource 共享）。
func duplicate_entry() -> RelationEntry:
	var copy := RelationEntry.new()
	copy.target = target
	copy.relation = relation
	copy.callname = callname
	return copy
