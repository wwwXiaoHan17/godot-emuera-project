# USER.md

## PRAT 1

当前的项目是我使用Godot制作的一个实验性项目。目的是尝试亲自尝试并学习Godot，同时自己动手搭建一款由Godot制作的Era(Emuera)游戏。

我发现Emuera使用ERB语法搭建UI界面。

```ERB
PRINTFORM "This is a label"
PRINTFORMW "请选择你的选项"
PRINTFROM "[0] 你好"
PRINTFORM "[1] 不好"

SWITCH REUSLT:
	0: PRINT "你好啊"
	1: PRINT "去死吧"
```

然后我在想：在Godot的.tscn文件中搭建好UI，其实也能达到和Emuera使用ERB语句达到相同的效果。现在的实验性项目，通过修改Theme几乎实现了和Emuera一模一样的效果。

但是现在存在的问题是：

目前如果使用.tscn搭建的游戏场景，需要使用到很多的Button，那么就需要在GDScript中写很多的重复代码。这个是一个痛点

我目前尝试使用.tscn封装一些组件来减少重复性的搭建UI工作，但是在这个过程中也遇到了一些问题：

比如说，我要拆解节点，搭建一个.tscn文件，需要拆解得多细？适用性又要怎么考虑？

我想解决的是这些问题。你可以grill me，直到你能完全理解我意思。

你提出的问题，严禁使用晦涩难懂的奇怪语言，比如“门禁”、“门”等非常拗口的语言词汇。尽量换成简单且易理解的词汇。

同时我的Godot水平算是新手程度。