class_name EraPalette
extends Resource
## EraPalette, 文字颜色表
## 
## 引擎里所有“整行文字颜色”都从这里取。
## [br][br]
## 改颜色只改 engine/era_palette.tres 这一个文件。

@export var normal: Color = Color(1, 1, 1, 1)        ## 正文的颜色, 默认[code](1,1,1,1)[/code]
@export var dim: Color = Color(1, 1, 1, 0.55)        ## 变暗的字/提示的颜色，默认[code](1, 1, 1, 0.55)[/code]
@export var accent: Color = Color(0.45, 0.95, 1.0)   ## 强调的颜色，默认[code](0.45, 0.95, 1.0)[/code]
@export var danger: Color = Color(0.95, 0.35, 0.35)  ## 危险/警告的颜色，默认[code](0.95, 0.35, 0.35)[/code]
