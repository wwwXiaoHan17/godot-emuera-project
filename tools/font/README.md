# GEMono SC：项目定制字体（构建与契约）

本目录是 **GEMono SC** 的可复现构建工具链。产物是 `assets/fonts/GEMono-SC.ttf`，
并以「内嵌 FontFile」形式写进 `assets/themes/normal_theme.tres`（项目主题字体）。

## 为什么要有这个字体

主题原来内嵌 **MS Gothic**：`upem 256 / asc 220 / desc -36`，16px 字号下行高 17px。
但它只覆盖 GB2312 的 66.4%（6763 字里缺 2275，连「查」「测」「说」都没有）。
缺字时 Godot 走**系统回退**，而一行的行高 =

    max(该行用到的所有字体的 ascent) + max(所有字体的 descent)

微软雅黑是 17+5，于是任何含缺字的 Label/Button 最小高度从 **17px 跳到 22px**，
在 `VBoxContainer` 里一行变高就把下面所有行整体推下去。

**GEMono SC** 换掉了字形来源：**EraMono SC（等距时代黑体 SC，Ele / era-electron 的默认字体，
SIL OFL 1.1，源自 Sarasa Gothic 血统，50170 字，GB2312 100%）**。
MS Gothic **只作 advance 语义基准**（度量参考），**不复制任何字形轮廓**（微软专有授权）。

## 不变量（度量契约，`tests/check_font_contract.tscn` 守卫）

| 项 | 值 |
|---|---|
| upem | 1000 |
| hhea asc / desc | 880 / -400（保持 EraMono 原生，**不做固定行高**） |
| Godot 实测行高 @16px | **22px**（asc 15 + desc 7） |
| 半角 advance | 500（@16px = **8px**） |
| 全角 advance | 1000（@16px = **16px**） |
| layout 表 | 已丢弃 GPOS/GSUB/BASE/GDEF → **无 kerning**，advance 严格等宽 |
| .notdef | 全角 advance（1000），缺字占满一格不发散 |
| allow_system_fallback | **false**（设置在内嵌主题 FontFile 上，不是 .import 上） |
| 字符集 | ASCII + GB2312 全集 + 标点/假名/符号区 + 常用游戏符号，共 **8733** 字 |
| 实有字形 | 8427；缺 310 个罕符号（见 `charset_missing.txt`，关闭回退后显示 □，行高不变） |
| 文件体积 | 2.04 MB（内嵌后主题 2.85 MB） |

> 行高从 17px 变成 22px 是本次的**有意识决策**：不做固定行高，保留字体原生高度。
> 若将来要 17px：给 `rebuild_font.py` 加一段「hhea/OS2 垂直度量补丁」（asc 875 / desc -187，
> upem 1000），已实测 Godot 会回到 17px；但必须同步复核所有依赖行数的校验场景。

## 与 MS Gothic 的差异（advance 语义修正）

逐字符对比 MS Gothic 的 `hmtx / upem` 比例后修正：

- **156** 个字符由半角改全角；
- **145** 个字符由全角改半角；
- 合计 301 处（主要是箭头 `↗⇧`、希腊/西里尔 `χΡд`、杂项 `▣▭◉№` 等冷门符号）；
- 2026-11-05 追加：`∬`（U+222C）、`卍`（U+534D）改为全角，`·`（U+00B7）保持半角
  （EraMono 有字形、MS Gothic 有度量；eraTW 彩色地图会用到前两个）；
- 框线 `┏━┃`、块元素 `█░▓`、常用箭头 `→←↑↓`、`①★☆♪` 本来就一致，未改动。

## 重建

素材（都不入库）：

1. `EraMono SC.ttf`：era-electron 仓库 `src/assets/fonts/EraMono SC.ttf`
2. `MS Gothic.ttf`：advance 基准，Windows 自带，**本地自备（不入库）**

```bash
pip install fonttools
python tools/font/rebuild_font.py \
  --src "路径/EraMono SC.ttf" \
  --ms  "路径/MS Gothic.ttf" \
  --out "assets/fonts/GEMono-SC.ttf" \
  --report "tools/font/build_report.json"
```

脚本会同时写出 `charset.txt`（完整字符集）与 `build_report.json`（自检报告：
缺字清单、advance 修正计数、行高等）。自检要求：字符集内所有字符 advance ∈ {500, 1000}
（零宽格式字符 `Cf/Mn/Me` 除外）。

## 重新内嵌进主题

主题里存的是字体的内嵌副本（`normal_theme.tres` 的 `FontFile` 子资源），
换字体后必须重新生成主题，否则运行时用的还是旧字体：

```bash
python tools/font/embed_theme_font.py \
  --theme assets/themes/era_theme.tres \
  --font  assets/fonts/GEMono-SC.ttf \
  --out   assets/themes/era_theme.tres \
  --font-name "GE Mono SC"
```

脚本会：丢弃旧 `FontFile` 子资源与其 glyph 缓存 `Image` 子资源、保留其它 StyleBox
与 `[resource]` 段、写入新字体数据、设置 `allow_system_fallback = false`、保留原 uid。

## 校验

```bash
godot --headless --path . res://tests/check_font_contract.tscn
```

断言：字体身份 / 系统回退关闭 / 行高 22px / 逐字 advance ∈ {8, 16} /
ERB 字符画整串宽度（`┏━━━━━━━━━━┓` = 12 格、`▰▰▰▰▱▱▱▱` = 8 个半角格）/
混排串宽 = 逐字宽之和（无 kerning）/ 缺字清单与 `charset_missing.txt` 完全一致。

运行期还有 `scripts/engine/font_guard.gd`：文字进入行部件时检查主题字体缺字，
缺字时 `push_warning("FONT_GLYPH_MISSING U+…") `，同一码点整局只报一次。

## 授权

修改版按 SIL OFL 1.1 分发，**已改名**（GE Mono SC / GEMonoSC-Regular），
不使用任何 Reserved Font Name（`Source` 是 Adobe 的上游 RFN，同样未使用）。
许可全文与上游版权声明见 `assets/fonts/LICENSE-GEMono-SC.txt`。
字体 name 表里的上游版权/许可字段保持原样。
