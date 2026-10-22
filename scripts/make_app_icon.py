#!/usr/bin/env python3
"""Draw the app icon: aurora curtains over a Kirkjufell-like peak at night.

Writes a 1024x1024 opaque PNG (App Store icons must not have transparency).
Usage: scripts/make_app_icon.py [output.png]
Requires Pillow and numpy.
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
DEFAULT_OUT = (Path(__file__).resolve().parent.parent
               / "IcelandApp/Assets.xcassets/AppIcon.appiconset/AppIcon.png")


def sky():
    y = np.linspace(0, 1, SIZE)[:, None]
    top, bottom = np.array([5, 12, 38]), np.array([12, 58, 92])
    rgb = top + (bottom - top) * y[..., None] ** 1.3
    return np.broadcast_to(rgb, (SIZE, SIZE, 3)).astype(np.float32)


def stars(rng):
    layer = Image.new("L", (SIZE, SIZE), 0)
    draw = ImageDraw.Draw(layer)
    for _ in range(90):
        x, y = rng.uniform(0, SIZE), rng.uniform(0, SIZE * 0.55)
        r = rng.choice([1.2, 1.6, 2.2], p=[0.6, 0.3, 0.1])
        draw.ellipse((x - r, y - r, x + r, y + r), fill=int(rng.uniform(110, 230)))
    return np.asarray(layer.filter(ImageFilter.GaussianBlur(0.6)), np.float32)[..., None] / 255


def aurora(base_y, amplitude, phase, height, color_low, color_high, strength):
    """Curtain of light hanging above a wavy baseline, brightest at its lower edge."""
    xs = np.arange(SIZE)
    t = xs / SIZE
    baseline = base_y + amplitude * np.sin(2 * np.pi * (0.9 * t + phase)) + 28 * np.sin(2 * np.pi * (2.3 * t + phase * 1.7))
    rays = 0.65 + 0.35 * np.sin(xs * 0.09 + phase * 10) * np.sin(xs * 0.031 + phase * 4)

    ys = np.arange(SIZE)[:, None]
    d = baseline[None, :] - ys  # distance above the baseline
    above = np.clip(d / height, 0, None)
    intensity = np.where(d > 0, np.exp(-above * 2.6), np.exp(d / 10.0)) * rays[None, :]
    intensity *= np.clip(1 - above, 0, 1) ** 0.6

    mix = np.clip(above * 1.4, 0, 1)[..., None]
    color = np.array(color_low) * (1 - mix) + np.array(color_high) * mix
    glow = Image.fromarray(np.uint8(np.clip(intensity * 255, 0, 255)))
    soft = np.asarray(glow.filter(ImageFilter.GaussianBlur(6)), np.float32)[..., None] / 255
    return color * soft * strength


def mountains(img):
    draw = ImageDraw.Draw(img)
    # Kirkjufell: steep, slightly asymmetric cone
    peak = (560, 452)
    draw.polygon([(150, SIZE), (330, 700), (440, 560), peak, (640, 540), (760, 660), (930, 800), (1024, 860), (1024, SIZE)],
                 fill=(10, 24, 42))
    # Face lit by the aurora, then the snow cap
    draw.polygon([peak, (440, 560), (330, 700), (150, SIZE), (500, SIZE), (520, 760), (545, 600)], fill=(22, 52, 74))
    draw.polygon([peak, (500, 520), (520, 532), (540, 518), (566, 540), (596, 522), (640, 540)], fill=(205, 238, 240))
    draw.polygon([peak, (500, 520), (520, 532), (540, 518), (545, 470)], fill=(235, 252, 250))
    # Foreground hills and shoreline
    draw.polygon([(0, 840), (180, 780), (360, 830), (520, 800), (700, 850), (880, 820), (1024, 850), (1024, SIZE), (0, SIZE)],
                 fill=(6, 15, 28))
    draw.rectangle((0, 930, SIZE, SIZE), fill=(4, 10, 20))
    draw.line([(0, 930), (SIZE, 930)], fill=(40, 120, 120), width=3)


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_OUT
    rng = np.random.default_rng(7)

    canvas = sky()
    canvas += stars(rng) * 255 * 0.9
    canvas += aurora(470, 70, 0.15, 380, (70, 255, 170), (120, 90, 220), 1.0)
    canvas += aurora(360, 55, 0.55, 260, (40, 220, 200), (150, 80, 210), 0.55)
    image = Image.fromarray(np.uint8(np.clip(canvas, 0, 255)), "RGB")

    # Reflection of the aurora in the water before the land is drawn over it
    reflection = image.crop((0, 260, SIZE, 520)).transpose(Image.FLIP_TOP_BOTTOM).resize((SIZE, 94))
    reflection = Image.blend(Image.new("RGB", reflection.size, (4, 10, 20)), reflection, 0.35)
    mountains(image)
    image.paste(reflection.filter(ImageFilter.GaussianBlur(2)), (0, 930))

    out.parent.mkdir(parents=True, exist_ok=True)
    image.save(out, optimize=True)
    print(f"wrote {out} {image.size} {image.mode}")


if __name__ == "__main__":
    main()
