class_name SexyComponent
extends CharacterComponent
## SexyComponent, 性欲组件
##
## [member sexy_value] 是唯一数据源；[member sexy_level] 是按阈值表推导的派生字段，
## 勿手写。数值入口（[method increased] / [method decreased] / [method set_value]）
## 都会刷新等级。


enum SexyLevel {
	DISGUST,    # 厌恶
	NORMAL,     # 正常
	BUDDING,    # 性欲萌芽
	AROUSED,    # 性欲高涨
}

## 等级阈值表（降序，取首个 sexy_value >= min 的档位；负值走 DISGUST 特判）。
const LEVEL_THRESHOLDS := [
	{"min": 5000, "level": SexyLevel.AROUSED},
	{"min": 1000, "level": SexyLevel.BUDDING},
	{"min": 0, "level": SexyLevel.NORMAL},
]

## 性欲值（唯一数据源）。
@export var sexy_value: int = 0
## 派生字段：由 [method _refresh_sexy_level] 按 [constant LEVEL_THRESHOLDS] 推导，勿手写。
@export var sexy_level: SexyLevel = SexyLevel.NORMAL


func _init() -> void:
	display_name = "性欲"
	_refresh_sexy_level()


## 增性欲值；等级随之刷新。
func increased(value: int) -> void:
	sexy_value += value
	_mark_changed(&"sexy_value")
	_refresh_sexy_level()


## 减性欲值；等级随之刷新。
func decreased(value: int) -> void:
	sexy_value -= value
	_mark_changed(&"sexy_value")
	_refresh_sexy_level()


## 直接设定性欲值；等级随之刷新。
func set_value(v: int) -> void:
	sexy_value = v
	_mark_changed(&"sexy_value")
	_refresh_sexy_level()


## 按阈值表重算等级；等级实际变化才 _mark_changed（sexy_value 的标记由入口发）。
func _refresh_sexy_level() -> void:
	var level: int = SexyLevel.DISGUST if sexy_value < 0 else _level_for(sexy_value)
	if level == sexy_level:
		return
	sexy_level = level
	_mark_changed(&"sexy_level")


func _level_for(v: int) -> int:
	for row in LEVEL_THRESHOLDS:
		if v >= int(row["min"]):
			return int(row["level"])
	return SexyLevel.NORMAL
