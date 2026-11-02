#!/usr/bin/env python3
"""重建 GEMono SC（godot-emuera-project 定制字体）。

基底：EraMono SC（等距时代黑体 SC，SIL OFL 1.1，源自 Sarasa Gothic 血统）。
只做四件事，不改字形轮廓：
  1. 逐字符 advance 对齐 MS Gothic 语义（全角 1em / 半角 0.5em），使 ERB 字符画
     （┏━━┓ / ▰▱█░ / ①★☆ 等）与 Emuera 的列对齐口径一致；
  2. .notdef 改为全角 advance，缺字时占满一格不发散；
  3. 子集化到固定字符集（ASCII + GB2312 + 标点/假名/符号区 + 常用游戏符号）；
  4. 改名 GE Mono SC / GEMonoSC-Regular，保留 OFL 版权与许可声明。
垂直度量保持 EraMono 原生（asc 880 / desc -400 @upem 1000 → 16px 字号行高 22px），
本字体不承诺 17px 行高。

依赖：pip install fonttools
用法：
  python rebuild_font.py --src "EraMono SC.ttf" --ms "MS Gothic.ttf" --out "GEMono-SC.ttf"
"""

import argparse
import json
import os
import sys

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")   # 缺字清单含 bidi 控制符，避免 GBK 控制台报错

FAMILY = "GE Mono SC"
PS_NAME = "GEMonoSC-Regular"
VERSION = "Version 1.000; GEMono custom build"

REPLACE_NAME_IDS = (1, 2, 3, 4, 5, 6, 16, 17, 18, 21, 22)


def build_charset() -> str:
    """子集字符集：ASCII + GB2312 全集 + 符号区 + 假名 + 常用游戏符号。"""
    chars = set()
    chars.update(chr(c) for c in range(0x20, 0x7F))
    for hi in range(0xA1, 0xF8):                      # GB2312 全集
        for lo in range(0xA1, 0xFF):
            try:
                chars.add(bytes([hi, lo]).decode("gb2312"))
            except Exception:
                pass
    for a, b in [(0x2000, 0x206F), (0x2190, 0x21FF), (0x2460, 0x24FF), (0x2500, 0x257F),
                 (0x2580, 0x259F), (0x25A0, 0x25FF), (0x2600, 0x26FF), (0x2700, 0x27BF),
                 (0x3000, 0x303F), (0x3040, 0x309F), (0x30A0, 0x30FF), (0x31F0, 0x31FF),
                 (0xFE30, 0xFE4F), (0xFF00, 0xFFEF)]:
        chars.update(chr(c) for c in range(a, b + 1))
    chars.update("♥★☆♪♫→←↑↓■□▲△▼▽◆◇○●◎✓✗")
    return "".join(sorted(chars))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True, help="EraMono SC.ttf（原始基底，upem 1000）")
    ap.add_argument("--ms", required=True, help="MS Gothic.ttf（advance 语义基准）")
    ap.add_argument("--out", required=True, help="输出 .ttf")
    ap.add_argument("--report", default=None, help="校验报告 JSON 输出路径")
    args = ap.parse_args()

    from fontTools import subset
    from fontTools.ttLib import TTFont

    font = TTFont(args.src)
    ms = TTFont(args.ms)
    upem = font["head"].unitsPerEm
    ms_upem = ms["head"].unitsPerEm
    half, full = upem // 2, upem

    charset = build_charset()
    cmap = font.getBestCmap()
    ms_cmap = ms.getBestCmap()
    hmtx = font["hmtx"]
    ms_hmtx = ms["hmtx"]

    # 1) 逐字符对齐 MS Gothic 语义
    fixed_full = fixed_half = skipped = kept = 0
    for ch in charset:
        cp = ord(ch)
        gname = cmap.get(cp)
        if gname is None:
            continue
        mg = ms_cmap.get(cp)
        if mg is None:
            kept += 1                          # 基准字体没有 → 保留 EraMono 原生 advance
            continue
        ratio = ms_hmtx[mg][0] / ms_upem
        if abs(ratio - 1.0) < 0.02:
            target = full
        elif abs(ratio - 0.5) < 0.02:
            target = half
        else:
            skipped += 1                       # 非 1/2 比例的字符不强行改
            continue
        adv, lsb = hmtx[gname]
        if adv != target:
            if target == full:
                fixed_full += 1
            else:
                fixed_half += 1
            hmtx[gname] = (target, lsb)

    # 2) .notdef 全角
    if ".notdef" in font.getGlyphOrder():
        adv, lsb = hmtx[".notdef"]
        hmtx[".notdef"] = (full, lsb)
        notdef_fixed = adv != full
    else:
        notdef_fixed = False

    # 3) 子集化（丢弃全部 layout 特性 → 无 kerning，advance 严格等宽）
    opts = subset.Options()
    opts.layout_features = []
    opts.name_IDs = ["*"]
    opts.name_legacy = True
    opts.name_languages = ["*"]
    opts.notdef_glyph = True
    opts.notdef_outline = True
    opts.recommended_glyphs = True
    opts.symbol_cmap = True
    opts.drop_tables += ["BASE", "GDEF", "GPOS", "GSUB", "DSIG"]
    sub = subset.Subsetter(options=opts)
    sub.populate(text=charset)
    sub.subset(font)
    for tag in ("BASE", "GDEF", "GPOS", "GSUB"):
        if tag in font:
            del font[tag]

    # 4) 改名（OFL：修改版改名，版权/许可声明保留）
    name_table = font["name"]
    new_names = {
        1: FAMILY, 16: FAMILY,
        2: "Regular", 17: "Regular",
        4: FAMILY,
        6: PS_NAME,
        3: "1.000;GEMONO;" + PS_NAME,
        5: VERSION,
    }
    for rec in list(name_table.names):
        if rec.nameID in REPLACE_NAME_IDS:
            name_table.removeNames(nameID=rec.nameID)
    for name_id, value in new_names.items():
        name_table.setName(value, name_id, 3, 1, 0x409)     # Windows Unicode BMP
        name_table.setName(value, name_id, 1, 0, 0)         # Mac Roman

    os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
    font.save(args.out)

    # 5) 自检
    check = TTFont(args.out)
    c2, h2 = check.getBestCmap(), check["hmtx"]
    hhea = check["hhea"]
    missing = [c for c in charset if ord(c) not in c2]
    import unicodedata
    bad = []
    for ch in charset:
        g = c2.get(ord(ch))
        if g is None:
            continue
        adv = h2[g][0]
        if adv in (half, full):
            continue
        # 零宽字符合法：Cf（格式控制符/不可见运算符）与 Mn（组合记号，如 CJK 声调符）
        if adv == 0 and unicodedata.category(ch) in ("Cf", "Mn", "Me"):
            continue
        bad.append(f"U+{ord(ch):04X}={adv}")
    report = {
        "out": os.path.abspath(args.out),
        "bytes": os.path.getsize(args.out),
        "upem": check["head"].unitsPerEm,
        "hhea_asc": hhea.ascent,
        "hhea_desc": hhea.descent,
        "lineGap": hhea.lineGap,
        "charset": len(charset),
        "cmap": len(c2),
        "missing": len(missing),
        "missing_chars": "".join(missing),
        "advance_fixed_full": fixed_full,
        "advance_fixed_half": fixed_half,
        "advance_skipped_nonbinary": skipped,
        "advance_native_kept": kept,
        "notdef_full_width": notdef_fixed,
        "bad_advances": bad[:20],
        "bad_advance_count": len(bad),
        "tables": sorted(check.keys()),
        "name": {str(r.nameID): r.toUnicode()[:60] for r in check["name"].names if r.nameID in (1, 4, 6, 13)},
    }
    charset_txt = os.path.join(os.path.dirname(os.path.abspath(args.out)), "charset.txt") if args.report else None
    if args.report:
        charset_txt = os.path.join(os.path.dirname(os.path.abspath(args.report)), "charset.txt")
        with open(charset_txt, "w", encoding="utf-8", newline="") as fh:
            fh.write(charset)
        report["charset_txt"] = charset_txt
    print(json.dumps(report, ensure_ascii=False, indent=1))
    if args.report:
        with open(args.report, "w", encoding="utf-8") as fh:
            json.dump(report, fh, ensure_ascii=False, indent=1)
    return 0 if not bad else 1


if __name__ == "__main__":
    sys.exit(main())
