#!/usr/bin/env python3
"""Compose App Store marketing images (6.9" iPhone, 1320x2868) from raw screenshots.

Each raw screenshot is placed in a device frame under a headline and subtitle.

Usage: scripts/make_store_images.py <raw-screenshots-dir> <output-dir>
Requires Pillow. The Noto Sans TC font is downloaded on first use.
"""

import sys
import urllib.request
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

WIDTH, HEIGHT = 1320, 2868
FONT_URL = "https://raw.githubusercontent.com/google/fonts/main/ofl/notosanstc/NotoSansTC%5Bwght%5D.ttf"
FONT_PATH = Path.home() / ".cache" / "iceland-app" / "NotoSansTC.ttf"

CAPTIONS = {
    "01-explore": ("探索冰與火之國", "冰川、瀑布、極光，12 個必訪絕景"),
    "02-detail": ("深入認識每個景點", "亮點、最佳季節與位置一目了然"),
    "03-waterfalls": ("依類型輕鬆篩選", "瀑布、冰川、海岸、地熱一次看"),
    "04-map": ("3D 地圖飛越冰島", "點選景點，立即飛到現場"),
    "05-favorites": ("收藏你的夢想清單", "規劃專屬的冰島旅程"),
    "06-info": ("出發前的旅遊指南", "季節、交通與實用小提示"),
}

TOP = (8, 32, 61)
BOTTOM = (18, 120, 160)


def font(size, weight):
    if not FONT_PATH.exists():
        FONT_PATH.parent.mkdir(parents=True, exist_ok=True)
        urllib.request.urlretrieve(FONT_URL, FONT_PATH)
    f = ImageFont.truetype(str(FONT_PATH), size)
    f.set_variation_by_axes([weight])
    return f


def background():
    gradient = Image.new("RGB", (1, HEIGHT))
    for y in range(HEIGHT):
        t = y / (HEIGHT - 1)
        gradient.putpixel((0, y), tuple(round(a + (b - a) * t) for a, b in zip(TOP, BOTTOM)))
    image = gradient.resize((WIDTH, HEIGHT)).convert("RGBA")

    # Soft aurora-like glow behind the headline
    glow = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse((-200, -350, WIDTH + 200, 900), fill=(60, 220, 170, 70))
    return Image.alpha_composite(image, glow.filter(ImageFilter.GaussianBlur(160)))


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius, fill=255)
    return mask


def compose(shot_path, title, subtitle):
    canvas = background()
    draw = ImageDraw.Draw(canvas)

    title_font, subtitle_font = font(112, 800), font(58, 500)
    draw.text((WIDTH / 2, 250), title, font=title_font, fill="white", anchor="mm")
    draw.text((WIDTH / 2, 390), subtitle, font=subtitle_font, fill=(255, 255, 255, 215), anchor="mm")

    shot = Image.open(shot_path).convert("RGBA")
    screen_w = 1000
    screen_h = round(shot.height * screen_w / shot.width)
    shot = shot.resize((screen_w, screen_h), Image.LANCZOS)

    bezel = 26
    device_w, device_h = screen_w + 2 * bezel, screen_h + 2 * bezel
    x, y = (WIDTH - device_w) // 2, 540

    shadow = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (x, y + 30, x + device_w, y + device_h + 30), 150, fill=(0, 0, 0, 120)
    )
    canvas = Image.alpha_composite(canvas, shadow.filter(ImageFilter.GaussianBlur(45)))

    device = Image.new("RGBA", (device_w, device_h), (0, 0, 0, 0))
    ImageDraw.Draw(device).rounded_rectangle(
        (0, 0, device_w - 1, device_h - 1), 150, fill=(22, 24, 28, 255), outline=(90, 96, 104, 255), width=4
    )
    device.paste(shot, (bezel, bezel), rounded_mask(shot.size, 124))
    canvas.paste(device, (x, y), device)

    return canvas.convert("RGB")


def main():
    src, out = Path(sys.argv[1]), Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    for name, (title, subtitle) in CAPTIONS.items():
        shot = src / f"{name}.png"
        if not shot.exists():
            print(f"skip {name}: no screenshot")
            continue
        compose(shot, title, subtitle).save(out / f"{name}.png", optimize=True)
        print(f"wrote {out / name}.png")


if __name__ == "__main__":
    main()
