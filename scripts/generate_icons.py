#!/usr/bin/env python3
"""Generate app icon PNGs for HanziWidget."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
APP_ICON = ROOT / "HanziWidget" / "Assets.xcassets" / "AppIcon.appiconset"
EXT_ICON = ROOT / "HanziWidgetExtension" / "Assets.xcassets" / "AppIcon.appiconset"
SIZE = 1024


def find_font() -> str:
    paths = [
        "/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc",
        "/usr/share/fonts/noto-cjk/NotoSansCJK-Bold.ttc",
        "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/noto-cjk/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ]
    for p in paths:
        if Path(p).exists():
            return p
    raise SystemExit("no font found")


def rounded_rect(draw: ImageDraw.ImageDraw, box, radius, fill):
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def make_icon(text: str, bg: tuple, fg: tuple, out: Path, mono: bool = False) -> None:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    rounded_rect(draw, (0, 0, SIZE, SIZE), 220, bg)

    font_path = find_font()
    font_size = 560
    font = ImageFont.truetype(font_path, font_size)

    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    x = (SIZE - tw) / 2 - bbox[0]
    y = (SIZE - th) / 2 - bbox[1] - 20
    draw.text((x, y), text, font=font, fill=fg)

    if mono:
        # Tinted icons: grayscale luminance, alpha preserved
        gray = img.convert("LA")
        out_img = gray
    else:
        # App icons must be fully opaque RGB
        out_img = Image.new("RGB", (SIZE, SIZE), bg[:3])
        out_img.paste(img, mask=img.split()[3])

    out.parent.mkdir(parents=True, exist_ok=True)
    out_img.save(out, format="PNG")


def main() -> None:
    light = ((196, 48, 43, 255), (255, 255, 255, 255))
    dark = ((28, 28, 30, 255), (255, 99, 71, 255))
    # Tinted: white glyph on transparent-ish rounded shape via alpha
    tinted_bg = (255, 255, 255, 230)
    tinted_fg = (40, 40, 40, 255)

    for dest in (APP_ICON, EXT_ICON):
        make_icon("汉", light[0], light[1], dest / "AppIcon.png")
        make_icon("汉", dark[0], dark[1], dest / "AppIcon-Dark.png")
        make_icon("汉", tinted_bg, tinted_fg, dest / "AppIcon-Tinted.png", mono=True)
        print(f"wrote icons to {dest}")


if __name__ == "__main__":
    main()
