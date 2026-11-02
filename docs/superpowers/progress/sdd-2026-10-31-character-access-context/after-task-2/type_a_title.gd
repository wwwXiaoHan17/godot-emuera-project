extends EraEvent
## Title, 标题屏
##
## 由旧的 [code]scenes/event_tscn/start.tscn[/code] 改写成命令流：
## 分割线、点阵字、三个居中按钮，全部通过 [code]Era.print*[/code] 输出。
## [br][br]
## 第一版只验证“命令能搭出旧画面 + 点/按数字能返回编号”，
## 具体跳到哪个事件留到第 2 步再接。

## 点阵字的颜色（旧 start.tscn 里的深红）。
const ART_COLOR := "#c02f45"

## 下一个事件：点“开始游戏”后进入“创建角色”。
const NewGame := preload("res://content/events/new_game.gd")

## 旧的 start.tscn 里的 6 行点阵字，原样保留。
const ART_LINES := [
	"███████╗██████╗  █████╗        ██████╗  █████╗ ██╗   ██╗ ██████╗ ██╗  ██╗████████╗███████╗██████╗",
	" ██╔════╝██╔══██╗██╔══██╗       ██╔══██╗██╔══██╗██║   ██║██╔════╝ ██║  ██║╚══██╔══╝██╔════╝██╔══██╗",
	" █████╗  ██████╔╝███████║       ██║  ██║███████║██║   ██║██║  ███╗███████║   ██║   █████╗  ██████╔╝",
	" ██╔══╝  ██╔══██╗██╔══██║       ██║  ██║██╔══██║██║   ██║██║   ██║██╔══██║   ██║   ██╔══╝  ██╔══██╗",
	" ███████╗██║  ██║██║  ██║       ██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║  ██║   ██║   ███████╗██║  ██║",
	" ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝",
]

## 分割线用的符号（旧 start.tscn 用的是 ■）。
const RULE_CHAR := "■"


func run(context: EventContext) -> GDScript:
	Era.clear()
	Era.print_gap(5)
	Era.print_rule(RULE_CHAR)
	Era.print_gap(2)
	for line in ART_LINES:
		Era.print("[color=%s]%s[/color]" % [ART_COLOR, line], Era.Style.NORMAL, HORIZONTAL_ALIGNMENT_CENTER)
	Era.print_gap()
	Era.print_button("开始游戏", 1, HORIZONTAL_ALIGNMENT_CENTER)
	Era.print_button("继续游戏", 2, HORIZONTAL_ALIGNMENT_CENTER)
	Era.print_button("关于游戏", 3, HORIZONTAL_ALIGNMENT_CENTER)
	Era.print_rule(RULE_CHAR)

	match await Era.input():
		1:
			return NewGame
		2:
			Era.print("还没有存档。", Era.Style.DIM)
			await Era.wait_key()
			return get_script() as GDScript
		3:
			Era.print("这是用 Godot 做的 Era 风格实验。", Era.Style.DIM)
			await Era.wait_key()
			return get_script() as GDScript
		_:
			return
