#!/usr/bin/env python3
"""把字体以「内嵌 FontFile」方式写进 Theme 资源（normal_theme.tres）。

做法：解析现有 .tres 的文本块，丢弃旧的 FontFile 与其 glyph 缓存 Image 子资源，
再用新的字体数据重建一个 FontFile 子资源（data = base64 PackedByteArray），
其余 StyleBox / [resource] 段原样保留。字体属性设 allow_system_fallback = false。

用法：
  python embed_theme_font.py --theme normal_theme.tres --font GEMono-SC.ttf \
                             --out normal_theme.new.tres --font-name "GE Mono SC"
"""

import argparse
import base64
import os
import sys

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

FONT_STYLE_FIXED_WIDTH = 4   # TextServer::FONT_FIXED_WIDTH


def parse_blocks(text):
    lines = text.splitlines(keepends=True)
    starts = [i for i, line in enumerate(lines) if line.startswith("[")]
    blocks = []
    for j, start in enumerate(starts):
        end = starts[j + 1] if j + 1 < len(starts) else len(lines)
        header = lines[start].rstrip("\r\n")
        blocks.append((header, lines[start:end]))
    return blocks


def block_type(header):
    if not header.startswith("[sub_resource "):
        return None
    head = header[len("[sub_resource "):].split("]")[0]
    kind = head.split("type=\"")[1].split("\"")[0] if "type=\"" in head else ""
    return kind


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--theme", required=True)
    ap.add_argument("--font", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--font-name", default="GE Mono SC")
    args = ap.parse_args()

    with open(args.theme, encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    font_bytes = open(args.font, "rb").read()
    b64 = base64.b64encode(font_bytes).decode("ascii")

    blocks = parse_blocks(text)
    header_block = None
    resource_block = None
    kept = []
    dropped = []
    font_id = None
    for header, lines in blocks:
        if header.startswith("[gd_resource"):
            header_block = lines
            continue
        if header.startswith("[resource]"):
            resource_block = lines
            continue
        kind = block_type(header)
        if kind == "FontFile":
            font_id = header.split("id=\"")[1].split("\"")[0]
            dropped.append("FontFile:" + font_id)
            continue
        if kind == "Image":          # 只被旧字体 glyph 缓存引用
            dropped.append("Image:" + header.split("id=\"")[1].split("\"")[0])
            continue
        kept.append(lines)

    if header_block is None or resource_block is None:
        print("ERROR: 不是合法的 Theme 文本资源")
        return 1
    if font_id is None:
        font_id = "FontFile_gemono"

    # 校验：被丢弃的子资源没有被其它块引用
    kept_text = "".join("".join(k) for k in kept) + "".join(resource_block)
    for tag in dropped:
        if tag.startswith("FontFile:"):
            continue          # 새 FontFile 复用同一 id，[resource] 里的引用有效
        name = tag.split(":", 1)[1]
        if name in kept_text:
            print(f"ERROR: 子资源 {name} 仍被引用，拒绝丢弃")
            return 1

    new_font_lines = [
        f"[sub_resource type=\"FontFile\" id=\"{font_id}\"]\n",
        f"data = PackedByteArray(\"{b64}\")\n",
        f"font_name = \"{args.font_name}\"\n",
        "style_name = \"Regular\"\n",
        f"font_style = {FONT_STYLE_FIXED_WIDTH}\n",
        "allow_system_fallback = false\n",
        "\n",
    ]

    out_lines = list(header_block)
    for lines in kept:
        out_lines.extend(lines)
    out_lines.extend(new_font_lines)
    out_lines.extend(resource_block)

    os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
    with open(args.out, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("".join(out_lines))

    out_size = os.path.getsize(args.out)
    print(f"[ok] {args.out}  {out_size/1024/1024:.2f} MB  font={len(font_bytes)/1024/1024:.2f} MB  dropped={dropped}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
