extends Node
## 校验 Task 1
## 
## 调色板 Resource、游戏状态 Resource、事件基类。
## [br][br]
## 成功打印 CHECK OK 并退出码 0；失败打印 CHECK FAIL 并退出码 1。

const PaletteScript := preload("res://engine/era_palette.gd")
const StateScript := preload("res://engine/game_state.gd")
const EventScript := preload("res://engine/era_event.gd")


func _ready() -> void:
	var failures: Array[String] = []

	# 1) 调色板：能加载、是 EraPalette、四个颜色合理
	var palette: Resource = load("res://engine/era_palette.tres")
	if palette == null:
		failures.append("调色板 era_palette.tres 没加载到")
	elif not (palette is PaletteScript):
		failures.append("调色板脚本不是 era_palette.gd")
	else:
		if palette.normal.v < 0.9:
			failures.append("normal 应该是亮色")
		if palette.dim.a >= palette.normal.a:
			failures.append("dim 应该比 normal 暗/透明")
		if palette.accent == palette.normal:
			failures.append("accent 不能和 normal 一样")
		if palette.danger.r <= palette.danger.b:
			failures.append("danger 应该偏红")

	# 2) 状态：角色表存在且初始为空
	var state: Resource = StateScript.new()
	if state.character_book == null:
		failures.append("GameState.character_book 不应为 null")
	elif state.character_book.characters.size() != 0:
		failures.append("GameState.character_book 初始应为空")

	# 3) 事件基类：run() 返回 null（流程结束）
	var event: RefCounted = EventScript.new()
	var next: Variant = event.run()
	if next != null:
		failures.append("EraEvent 基类 run() 应返回 null")

	if failures.is_empty():
		print("CHECK OK")
		get_tree().quit(0)
	else:
		print("CHECK FAIL")
		for failure in failures:
			print("  - ", failure)
		get_tree().quit(1)
