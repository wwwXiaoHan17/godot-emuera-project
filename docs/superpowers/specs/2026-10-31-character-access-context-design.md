# 角色访问统一（EventContext）设计

> 日期：2026-10-31
> 状态：待用户 review
> 前置：`2026-10-25-engine-boundaries-design.md`（已验收）
> 范围：只统一“事件与口上如何拿到角色/数据”的入口；不改变组件模型、口上语法、页面机制、存档口径。

## 0. 目标与原则

现状：事件用 **pull**（自己 `Era.character(id)` / `character_book.find(id)` 查角色），口上用 **push**（引擎塞 `context.speaker/player`）。两套心智模型，加上口上查第三个角色时的第三种拼写（`context.state.character_book.find`），学习成本高。

目标一句话：**拿数据用 `context`（人、主角、状态），做事用 `Era.*`（print / input / kojo / show_screen）**。事件与口上共享同一条规则。

参考结论（2026-10-31 调研）：

- Emuera / emuera-skia-sharp fork（角色系统同源，fork 只改渲染加载）：角色访问只有一种寻址（`变量:角色番号:编号`）；“当前操作谁”由 `MASTER/TARGET` 等**可赋值绑定**承担，不是“编号 0 的角色”。
- era-electron：所有变量走单一 dispatcher（`getSet(表名, 索引...)`），口上用 Proxy 包装访问。
- 两者“统一”的来源都是**只提供一种入口**，而不是提供多种便捷写法。

## 1. EventContext（新增）

事件的随身工具包，`RefCounted`：

```gdscript
class_name EventContext
extends RefCounted

var player: Character        # 主角绑定
var state: GameState         # 游戏状态

func character(id: StringName) -> Character   # 按名字牌查任意角色
```

- `player` 是**绑定**（Emuera 的 `MASTER`）：等于“按 `protagonist_id` 找出的人”，不等于 `character(&"player")`。`protagonist_id` 改绑后，`player` 跟着变（`check_event_flow` 已存在把主角绑成女儿的用法）。
- `player` 允许为 `null`（无主角概念的游戏/测试），语义是“这局没有主角”，与 `character(id)` 查无此人的 `null` 含义不同。
- `character(id)` 查不到返回 `null`，不伪造角色。
- `state` 保留完整引用，供需要全局状态的场合；内容常规取人不直接翻 `state.character_book`。

## 2. KojoContext（改造为子类）

```gdscript
class_name KojoContext
extends EventContext

var speaker: Character       # 谁在念这段台词（口上特有，事件没有）
var extras: Dictionary       # 本次调用的临时数据（partner 等）
```

- 继承 `player / state / character()`；口上查第三个角色（女仆等）从此走 `context.character(id)`，与事件同一条路。
- 现有固定字段（speaker/player/state/extras）语义不变，只是层级化；同名 `extras` 不能覆盖固定字段的既有规则不变。

## 3. 事件签名与引擎打包

- `EraEvent.run()` 统一改为 `run(context: EventContext) -> GDScript`。
- `Era._run_flow()` 在**每次执行一个事件前**构造新的 `EventContext`（`state` 取当前 `Era.state`，`player` 按当前 `protagonist_id` 解析），事件结束即弃。每事件一包，避免主角中途换绑后读到旧值。
- `Era.kojo(character, event_name, extras)` 签名不变；内部构造 `KojoContext` 时填 `speaker = character`、`player` 按当前绑定解析。
- 口上函数签名维持 `func _xxx(context: KojoContext) -> Variant`。

## 4. 内容层退役（一次性迁移，无双写）

以下两种写法不再出现在 `content/` 的事件、口上、页面脚本中：

- `Era.character(id)`
- `Era.state.character_book.find(id)`（以及任何直接翻 `state.character_book` 取人的写法）

去向：

- 引擎内部（`era.gd` 等）仍可使用 `character_book.find`，它是 `context.character()` 的底层实现。
- `tests/` 中的校验可以直接构造 `EventContext` / 操作 `character_book` 做断言；driver 事件签名随新规则迁移。
- 不保留兼容别名，不做渐进双写；一次迁移，编译错误即漏网点。

## 5. 不变的东西

- `Era.kojo(角色, 事件名, extras)` 的调用方式。
- 组件访问：`get_component(类型) as 类型` + 判空。
- 页面：`show_screen(scene, data)` / `configure(data)`。
- 事件接力语义：`return 下一个脚本 / get_script() / null`，重启与局部循环规则。
- `CharacterBook.protagonist_id` 字段本身。

## 6. 错误处理与兼容性

- `character(id)` 查无此人 → `null`，调用方判空（现有惯例）。
- `player` 为 `null` 合法；口上里 `name_for(null)` 返回 `"-"` 的既有回退不变。
- 事件签名变更是编译期破坏：迁移必须覆盖全部事件/驱动/演示，任何遗漏会在解析期暴露。
- 本轮不引入存档变化、不新增全局可变单例（`Era.player`/`Era.target` 这类方案已否决）。

## 7. 验证原则

沿用校验场景 + `CHECK OK` 口径，不引入新测试框架。至少验证：

- 事件收到的 `context.player` 指向当前 `protagonist_id` 绑定的角色；改绑后新事件拿到新主角。
- 事件与口上都可用 `character(id)` 查到同一角色；查无返回 `null`。
- `KojoContext` 继承 `EventContext` 能力，`speaker/extras` 行为不回归（含同名 extras 不覆盖固定字段）。
- `content/` 中不再出现 `Era.character(` 与 `character_book.find(`。
- 现有全部校验场景迁移后通过；F5 主链路（标题→创建→天赋→第 1 天→面板→口上）行为不变。

## 8. 迁移面预估（供实现计划参考）

- 引擎：新增 `engine/event_context.gd`；`engine/kojo/kojo_context.gd` 改继承并新增 `character()`；`engine/era.gd` 的 `_run_flow`/`kojo` 打包逻辑、`Era.character` 标注内部用途；`era_event.gd` 文档。
- 内容：`content/events/*.gd` 全部 `run()` 签名与取角色写法；`content/kojo/*.gd` 增量极小。
- 测试：全部 driver/内嵌事件的签名，以及用 `Era.character`/`character_book.find` 的断言改写。

## 9. 已决问题（brainstorm 记录）

1. 痛点排序：③“事件/口上两套入口”为最大学习成本（用户选定）。
2. 方向：B 上下文统一（用户在 A/B/C 案例代码对比后选定；C 的全局绑定与已验收的 boundaries 设计冲突，A 不消除两套模型）。
3. `player` 保留为 `MASTER` 式绑定字段，与 `character(id)` 语义区分（用户确认）。
4. `speaker` 仅口上拥有；事件没有“说话人”。
5. `extras` 留在 `KojoContext`；事件暂无临时数据需求，不提前上移。
6. `Era.kojo` 保持为引擎命令（“做事用 Era”），不搬进 context。

## 10. 参考

- 调研对象：`E:\MyCode\eraCode\emuera.em-master`、`emuera_lazyloading_selfmodified_version-develop-skiasharp`（仅渲染差异）、`era-electron-master/src/era/model/apis/era-set.js`。
- 前置设计：`docs/superpowers/specs/2026-10-25-engine-boundaries-design.md`。
