# 第 12 步完成记录（可见的角色状态面板）

> 日期：2026-10-21
> 前一步：`docs/step-11-report.md`（角色系统第 5 步）

## 这一步做完了什么

**角色状态面板 `content/events/character_panel.gd`**

- 从第 1 天点“查看角色面板”进入（day_start 菜单第 3 项）；
- 用混合格子显示女儿的组件值：生命 / 体力 / 精力 / 对玩家好感 / 天赋；
- 按钮直接调组件方法：
  - `生命 -10` → `LifeComponent.hurt(10)`
  - `体力 -10` → `StaminaComponent.spend(10)`
  - `精力 -10` → `EnergyComponent.spend(10)`
  - `好感 +10` → `AffectionComponent.change(...)`
  - `返回第 1 天`
- 动作后打印“现在：生命/体力/精力/好感”，按键后重画面板（运行时 `load` 自己，避免循环 preload）。

**day_start 菜单**

- 第 3 项从“返回标题”改为“查看角色面板”，返回标题移到第 4 项；
- 行数变化：第 1 天 12 行、动作后 14 行。

**校验**

- `check_day_start` 增加面板链路：
  - 第 1 天 → 面板 11 行；
  - 面板点“生命 -10” → 生命组件 90、多 1 行“现在”；
  - 按键重画面板回到 11 行；
  - 返回第 1 天 12 行；
  - 再继续原来的出去走走/在家休息测试。
- `check_talent_select` 第 1 天行数 11→12。

## 验收结果

- 15 个校验场景全部 `CHECK OK`。
- 主场景 headless 无报错。
- 截图：
  - `experiment/shots/panel_initial.png`：面板初始（生命 100 / 体力 100 / 精力 100 / 好感 20 / 天赋幼稚）；
  - `experiment/shots/panel_after.png`：点“生命 -10”并按任意键后，面板显示生命 90。

## 已知限制

- 面板只显示女儿一个角色（玩家/女仆也有角色对象，但组件还不全；以后可以做多角色状态页）。
- 生命/体力/精力都是示例组件，字段按你的游戏设定自己改。
- 旧 `GameState` 字段仍在（兼容），面板已经完全不读它们。

## 文件清单

- 新增：`content/events/character_panel.gd`、`docs/step-12-report.md`
- 修改：`content/events/day_start.gd`（菜单加“查看角色面板”）、`tests/check_day_start.gd`、`tests/check_talent_select.gd`
