class_name KojoContext
extends EventContext
## KojoContext, 口上固定上下文
##
## 方向语义（治"speaker 是谁"的痛点）：[member speaker] 是说话人，[member player]
## 是听者（主角）。引擎保证口上执行期间 [code]speaker == Era.target == context.target[/code]，
## 结束后 [member Era.target] 恢复原值。
## [br][br]
## [method speaker_name] 是"说话人怎么称呼听者"，[method listener_name] 反向。
## 调用者的临时数据放 [member extras]（同名键不会覆盖固定字段）；
## player / state / character() / target 等由 [EventContext] 继承。

var speaker: Character
var extras: Dictionary = {}


## 说话人对听者（player）的称呼；speaker 或 player 为 null 返回 "-"。
## [codeblock]
## Era.print("%s：「早上好。」" % context.speaker_name())
## [/codeblock]
func speaker_name() -> String:
	if speaker == null or player == null:
		return "-"
	return speaker.name_for(player)


## 听者（player）对说话人的称呼（[method speaker_name] 的反向）；任一为 null 返回 "-"。
## [codeblock]
## Era.print("（%s 喊了一声。）" % context.listener_name())
## [/codeblock]
func listener_name() -> String:
	if speaker == null or player == null:
		return "-"
	return player.name_for(speaker)
