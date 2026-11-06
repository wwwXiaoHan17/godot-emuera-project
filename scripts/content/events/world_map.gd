extends EraEvent
## WorldMap，看大地图：点地图上的数字选择地点。
##
## 地图数据来自 content/maps/era_tw_field_map.gd（eraTW COLOREDFIELD 的 32 行字符画 + 逐格颜色）。
## 数字是地点按钮：点一下，Era.input() 返回地点编号。

const MAP_DATA := preload("res://scripts/content/maps/era_tw_field_map.gd")
const DayStart := preload("res://scripts/content/events/day_start.gd")
const MAP_DEFAULT_COLOR := Color(0.78, 0.78, 0.78)


func run(context: EventContext) -> GDScript:
	Era.clear()
	Era.print("看地图：点地图上的数字选地点（00~11）。", Era.Style.ACCENT)
	var map: Variant = Era.print_map(MAP_DATA.ROWS, MAP_DATA.COLORS, MAP_DEFAULT_COLOR)
	var picked: int = await Era.input()
	Era.print("你点了地点 %02d。" % picked)
	await Era.wait_key()
	return DayStart
