# EVENT_CODING_RULE.md

该文件的作用是约束Agent和User要时刻牢记：编写GodotEmueraProject的EraEvent事件时，需要注意给GDScript命名的规则

## 怎么命名？

由于本项目具备较强的自由，没有明确的文件规范。所以最好是自建一套约束命名的规范。那么怎么命名呢？请注意，Godot，如果使用的是GDScript最好使用和Python一样的蛇形命名法。最好是统一规范，然后使用文件夹统一管理。

```GDScript
- events
  - type_system_event
    - type_system_title.gd
    - type_system_new_game.gd
    - type_system_continue_game.gd
  - type_custom_event
    - type_custom_select_talent.gd
    - type_custom_select_start_new_day.gd
    - diy_custom_event.gd  # 错误的命名
```