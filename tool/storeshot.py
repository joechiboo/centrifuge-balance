"""Turn a raw 1080x2340 phone capture into a Play store screenshot.

Same geometry as the v1.0.0 set: drop the status bar and gesture bar so the
image is 2180 tall, then pad the sides with the app background to 1226 wide
(9:16). The app is edge-to-edge, so the bars are dropped by fixed height rather
than detected by colour.

usage: python storeshot.py raw.png out.png
"""
import sys
from PIL import Image

BG = (0xE9, 0xED, 0xF1)
OUT_W, OUT_H = 1226, 2180
TOL = 12


def is_bg_row(im, y, w):
    px = im.load()
    hits = 0
    for x in range(0, w, 8):
        r, g, b = px[x, y][:3]
        if abs(r - BG[0]) <= TOL and abs(g - BG[1]) <= TOL and abs(b - BG[2]) <= TOL:
            hits += 1
    return hits >= (w // 8) * 0.8


def main(src, dst):
    # The app paints edge-to-edge, so the bars sit on its own background and
    # cannot be found by colour. SM-S9110: status bar 100 px, gesture bar
    # 60 px, which is exactly the 160 px the v1.0.0 set dropped.
    im = Image.open(src).convert("RGB")
    w, h = im.size
    y0 = 100
    band = im.crop((0, y0, w, y0 + OUT_H))
    out = Image.new("RGB", (OUT_W, OUT_H), BG)
    out.paste(band, ((OUT_W - w) // 2, 0))
    out.save(dst)
    print(f"{dst}: crop y {y0}-{y0 + OUT_H} of {h}, out {out.size}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
