# Era 现有设计边界调整

> 日期：2026-10-25
> 状态：已获用户确认（2026-10-25）
> 范围：只调整已经讨论并确认的现有设计，不评价或添加缺失功能。

## 0. 目标与原则

保留当前已经成立的架构：常驻壳、命令式内容、挂载页面、Resource 角色组件、直接 GDScript 口上、事件返回下一个脚本。

本轮解决的是现有职责和写法中的含糊之处：

- `Character` 不应预先拥有所有游戏概念。
- 组件需要有唯一、明确的身份规则。
- 页面需要显式的数据输入，不应自行查找全局状态。
- 事件重启与局部循环需要有不同的语义。
- 口上固定上下文需要类型，临时数据仍保持灵活。
- 代码标识符与程序 ID 统一使用英文，玩家可见文本不受影响。

## 1. Era 暂时保持为一个实现文件

`Era` 继续提供现有的简单作者接口：

```gdscript
Era.print(...)
await Era.input()
await Era.kojo(...)
```

本轮不拆分 `engine/era.gd`。当前职责集中尚不构成必须立即重构的问题，文件行数本身也不作为拆分依据。

以后出现以下实际问题时再评审拆分：

- 修改输入时反复影响输出或事件流程。
- 无法独立理解或验证某一块行为。
- 多类功能的实现持续互相牵扯。

拆分必须保持内容作者使用的 `Era` 接口不变。

## 2. Character 只保留基础身份与组件宿主职责

`Character` 保留：

- `id`：运行时实例身份，供 `CharacterBook` 查找。
- `display_name`：真名；Era 角色需要有名字。
- `callname`：默认称呼，与名字回退规则有关。
- `components`：可选组件集合。
- 原型标记与复制规则。

`age` 移出 `Character`，由需要成长、年龄概念的游戏自行定义 `AgeComponent`。没有年龄概念的角色不安装该组件，也不携带无意义的默认年龄。

`relations` 移出 `Character`，由可选的 `RelationComponent` 保存。没有关系概念的角色不安装该组件。

组件宿主不因为“完全组件化”而无限拆分。名字是本项目确认的基础角色概念，因此留在 `Character`。

## 3. 关系数据与规则合并进 RelationComponent

`RelationComponent` 同时持有：

- 当前角色指向其他角色的 `RelationEntry` 数组。
- 定向称呼。
- 关系值范围 `min_value / max_value`。
- 关系读取、设置、增减与称呼读写方法。

当前只有一个关系数值，因此不再让 `Character.relations` 与 `AffectionComponent` 分别保存数据和规则。原 `AffectionComponent.change()` 的职责合并到 `RelationComponent.add_relation()`。

关系修改统一经过 `RelationComponent`，不再提供一条绕过范围和变更通知的 `Character.set_relation_to()`。关系数据变化由 `RelationComponent` 发出通知；通知需要能指出发生变化的目标角色。

定向称呼仍保存在关系条目中，`RelationComponent.callname_for(other_id)` 只负责读取这条定向称呼。`Character.name_for(other)` 继续负责完整回退：可选关系组件中的定向称呼 → 对方默认称呼 → 对方真名 → `"-"`。名字回退属于 `Character` 保留的名字职责；没有 `RelationComponent` 时跳过定向称呼即可，不要求角色必须安装关系组件。

## 4. 组件身份采用脚本类型

正式选择：脚本类型决定组件是什么，显示名只负责显示。

### 4.1 查找

内容代码使用：

```gdscript
var life := daughter.get_component(LifeComponent) as LifeComponent
if life != null:
    life.hurt(10)
```

查找必须支持继承。`SlimeLifeComponent extends LifeComponent` 时，`component(LifeComponent)` 应能找到它，并执行子类规则。

### 4.2 显示名

原 `context_key` 改名为 `display_name`，原 `get_context_key()` 改为 `get_display_name()`：

```gdscript
@export var display_name: String = ""

func get_display_name() -> String:
    if not display_name.is_empty():
        return display_name
    var script := get_script()
    if script != null and not script.get_global_name().is_empty():
        return script.get_global_name()
    return "CharacterComponent"
```

这里不用过于宽泛的 `name`，因为该字段只是界面显示名，不是组件实例 ID 或脚本类名；`display_name` 也与 `Character.display_name` 的命名一致。显示名可以是中文，不参与查找、替换或程序 ID。

显示名为空时回退到脚本类名。原 `component_key()` 不再保留，避免继续暗示存在第二套身份。组件展示页使用 `get_display_name()`；修改显示名不影响任何查找。

### 4.3 同类替换

每类组件需要明确的身份脚本。组件提供 `component_type() -> Script`：

- 独立组件默认返回自己的脚本。
- 可作为基础类型的组件返回自身，例如 `LifeComponent` 返回 `LifeComponent`。
- 子类继承该身份，不另造类别。

`add_component()` 按 `component_type()` 替换同类组件，不再按显示名替换。这样，同显示名的无关组件不能互相覆盖，同一角色也不会同时保留多个同身份组件。

### 4.4 索引

运行时索引与 `component_type()` 身份一致，只在组件增删或身份变化时重建，不在每次查询时无条件重建。不提供按显示名查找组件的内容 API。

## 5. 挂载页面只接收输入并返回结果

挂载页面不读取或修改 `Era.state`。

调用事件负责准备初始数据：

```gdscript
var age := daughter.get_component(AgeComponent) as AgeComponent
var result: Variant = await Era.show_screen(CHARACTER_CREATE, {
    "display_name": daughter.display_name,
    "age": age.value if age != null else 18,
})
```

`EraScreenPage` 提供 `configure(data: Dictionary)`。`Era.show_screen()` 在页面进入场景树之前调用它；页面在 `configure()` 中保存输入，在 `_ready()` 中更新控件。

页面完成后仍通过 `finished(result)` 返回结果。调用事件负责把结果写回角色或组件。

因此，页面不知道数据来自女儿、玩家还是其他角色；它只负责编辑调用者提供的数据。

## 6. 事件重启与局部循环同时保留

两种写法有不同语义，不互相替代，也不新增 `refresh()` 命令。

### 6.1 重启当前事件

```gdscript
return get_script() as GDScript
```

含义：结束当前事件，创建同类的新事件并重新执行 `run()`。

用途：丢弃事件局部变量、重新执行初始化。它不会自动重置 `Era.state`、角色组件、静态 Resource 或屏幕历史；清屏仍由事件显式调用 `Era.clear()`。

重启自己不再通过 `load(SelfPath)`。

### 6.2 当前事件内循环

```gdscript
while true:
    # 显示、等待输入、修改局部状态
    if should_leave:
        return DayStart
```

含义：保留当前事件对象及其局部变量，重复一段交互。

用途：角色面板修改数值后继续显示、连续选择、只重复事件的一部分。

`return OtherEvent` 仍表示离开当前事件并进入另一个事件。

## 7. 口上使用明确上下文与额外数据

新增 `KojoContext extends RefCounted`，固定字段为：

```gdscript
var speaker: Character
var player: Character
var state: GameState
var extras: Dictionary = {}
```

`Era.kojo(character, event_name, extras)` 为每次调用创建上下文。固定数据放入明确字段，调用者提供的临时数据放入 `extras`，不能覆盖固定字段。

口上写法：

```gdscript
func _morning(context: KojoContext) -> Variant:
    Era.print("早上好，%s。" % context.speaker.name_for(context.player))
    return null
```

保留现有直接 GDScript 口上、`KojoBook` 注册表、条件、随机、按钮与等待方式，不引入字符串条件或另一套内容语法。

## 8. 英文命名范围

代码标识符统一使用英文，包括：

- 变量、方法、导出字段、信号与上下文固定字段。
- 组件字段，例如 `值 / 上限` 改为 `value / max_value`。
- 状态字段，例如 `角色簿` 改为 `character_book`。
- 口上方法名，例如 `_爱抚` 改为 `_caress`。

程序用于查找的字符串 ID 也统一使用英文：

- 角色：`player / daughter / maid / father`。
- 口上事件：`morning / after_training / act_cute / daily / caress`。
- 额外上下文键：例如 `partner`。

玩家可见的名字、台词、按钮与状态文本仍可使用中文。中文文档和既有资源文件名不因本条规则被要求翻译。

## 9. 错误处理与兼容性原则

- 未安装可选组件表示角色没有该概念；调用方按现有方式检查 `null`，不伪造默认组件。
- 同类组件替换必须明确，不因显示名冲突静默替换。
- 页面输入缺少必填数据时，由页面拒绝完成并给出提示；不能暗中读取全局状态补齐。
- 英文 ID 是程序契约，修改时必须同步原型、口上注册、内容和校验；显示文本不需要同步改名。
- 本轮不引入新的存档系统，也不借英文化额外设计存档迁移。

## 10. 验证原则

沿用项目现有校验场景与 `CHECK OK` 方式，不引入新测试框架。

调整完成后至少验证：

- 普通组件与继承组件都能按基础类型找到，同类替换不受显示名影响。
- 无年龄、无关系组件的角色可以成立；有关系时范围、通知与称呼回退正确。
- 页面只凭 `configure()` 输入显示初始值，并通过 `finished` 返回结果。
- 事件重启会重置局部变量且保留游戏状态；局部循环会保留局部变量。
- `KojoContext` 固定字段与 `extras` 正确传递，口上按钮流程不回归。
- 全部既有校验场景、主场景和相关演示场景继续通过。
