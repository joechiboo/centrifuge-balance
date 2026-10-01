"""App icon generator: top-down centrifuge rotor, three tubes balanced at 120°.

Colours follow lib/palette.dart. Run `python assets/icon/generate.py`, then
`dart run flutter_launcher_icons` to push the PNGs into the platform folders.

Outputs (1024x1024):
  icon.png        full-bleed, opaque — iOS, legacy Android, web
  foreground.png  transparent, rotor inside the adaptive-icon safe zone
  monochrome.png  white silhouette for Android 13 themed icons
  preview.png     launcher-sized previews (not used by the build)
"""
import math
from pathlib import Path

from PIL import Image, ImageDraw

OUT = Path(__file__).parent
SIZE = 1024
SS = 4  # supersample factor

BG_TOP = (0x1E, 0x2B, 0x38)
BG_BOTTOM = (0x10, 0x18, 0x21)
STEEL_HI = (0xE4, 0xEA, 0xEF)
STEEL_LO = (0x9C, 0xA8, 0xB4)
WELL = (0x22, 0x2C, 0x37)
WELL_RING = (0x7E, 0x8A, 0x97)
CAP = (0x8B, 0x63, 0xD6)
CAP_HI = (0xC4, 0xAC, 0xF5)

HOLES = 6
FILLED = {0, 2, 4}


def radial(size, center, radius, inner, outer):
    """Radial gradient image, inner colour at center fading to outer at radius."""
    img = Image.new("RGB", (size, size))
    px = img.load()
    cx, cy = center
    for y in range(size):
        for x in range(size):
            t = min(1.0, math.hypot(x - cx, y - cy) / radius)
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(inner, outer))
    return img


def vertical(size, top, bottom):
    img = Image.new("RGB", (size, size))
    d = ImageDraw.Draw(img)
    for y in range(size):
        t = y / (size - 1)
        d.line([(0, y), (size, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))
    return img


def circle(d, c, r, **kw):
    d.ellipse([c[0] - r, c[1] - r, c[0] + r, c[1] + r], **kw)


def rotor(scale, mono=False):
    """RGBA rotor on a transparent canvas. scale = disc diameter / canvas side."""
    n = SIZE * SS
    c = (n / 2, n / 2)
    R = n * scale / 2
    ring = R * 0.62
    hole = R * 0.25
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    mask = Image.new("L", (n, n), 0)

    if mono:
        # Disc with the wells punched out; filled wells stay solid.
        md = ImageDraw.Draw(mask)
        circle(md, c, R, fill=255)
        for i in range(HOLES):
            a = 2 * math.pi * i / HOLES
            h = (c[0] + ring * math.sin(a), c[1] - ring * math.cos(a))
            circle(md, h, hole, fill=0)
            if i in FILLED:
                circle(md, h, hole * 0.78, fill=255)
        circle(md, c, R * 0.2, fill=0)
        circle(md, c, R * 0.12, fill=255)
        img.paste((255, 255, 255, 255), mask=mask)
        return img

    # Disc: soft steel gradient lit from the upper left.
    disc = radial(n // 8, (n / 8 * 0.4, n / 8 * 0.32), R / 8 * 1.5, STEEL_HI, STEEL_LO)
    disc = disc.resize((n, n), Image.BILINEAR)
    md = ImageDraw.Draw(mask)
    circle(md, c, R, fill=255)
    img.paste(disc, mask=mask)

    d = ImageDraw.Draw(img)
    edge = max(2, round(R * 0.018))
    circle(d, c, R, outline=WELL_RING, width=edge)

    for i in range(HOLES):
        a = 2 * math.pi * i / HOLES
        h = (c[0] + ring * math.sin(a), c[1] - ring * math.cos(a))
        circle(d, h, hole, fill=WELL, outline=WELL_RING, width=edge)
        if i in FILLED:
            circle(d, h, hole * 0.78, fill=CAP)
            hi = (h[0] - hole * 0.24, h[1] - hole * 0.24)
            circle(d, hi, hole * 0.28, fill=CAP_HI)

    # Hub.
    circle(d, c, R * 0.2, fill=STEEL_LO, outline=WELL_RING, width=edge)
    circle(d, c, R * 0.08, fill=WELL)
    return img


def down(img):
    return img.resize((SIZE, SIZE), Image.LANCZOS)


def main():
    # Full-bleed icon: iOS applies its own corner mask, so no rounding here.
    bg = vertical(SIZE * SS, BG_TOP, BG_BOTTOM).convert("RGBA")
    bg.alpha_composite(rotor(0.80))
    icon = down(bg).convert("RGB")
    icon.save(OUT / "icon.png")

    # Adaptive foreground: launcher masks crop to the inner 66/108 circle.
    down(rotor(0.60)).save(OUT / "foreground.png")
    down(rotor(0.60, mono=True)).save(OUT / "monochrome.png")

    # Preview: iOS-style rounded square and Android circle mask, at 192 and 48.
    adaptive = vertical(SIZE, BG_TOP, BG_BOTTOM).convert("RGBA")
    adaptive.alpha_composite(Image.open(OUT / "foreground.png"))
    sheet = Image.new("RGB", (192 * 2 + 48 * 2 + 50, 212), (0xE9, 0xED, 0xF1))
    x = 10
    for src, shape in ((icon.convert("RGBA"), "round"), (adaptive, "circle")):
        for s in (192, 48):
            m = Image.new("L", (s * 4, s * 4), 0)
            md = ImageDraw.Draw(m)
            if shape == "circle":
                md.ellipse([0, 0, s * 4 - 1, s * 4 - 1], fill=255)
            else:
                md.rounded_rectangle([0, 0, s * 4 - 1, s * 4 - 1], radius=s * 4 * 0.22, fill=255)
            sheet.paste(src.resize((s, s), Image.LANCZOS), (x, 10), m.resize((s, s), Image.LANCZOS))
            x += s + 10
    sheet.save(OUT / "preview.png")


if __name__ == "__main__":
    main()
