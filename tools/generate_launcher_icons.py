#!/usr/bin/env python3
"""Generate Android launcher icons from assets/icon/app_icon_114.png.

Pure-stdlib (zlib/struct) so it runs anywhere, no Pillow needed:
  python3 tools/generate_launcher_icons.py

Outputs
  android/app/src/main/res/mipmap-{mdpi..xxxhdpi}/ic_launcher.png        (full icon)
  android/app/src/main/res/mipmap-{mdpi..xxxhdpi}/ic_launcher_round.png  (circle mask)
  android/app/src/main/res/drawable-{mdpi..xxxhdpi}/ic_launcher_foreground.png
      (adaptive-icon foreground: icon at 80% on transparent 108dp canvas)
Adaptive XML + background colour live in
  res/mipmap-anydpi-v26/ic_launcher(.xml/_round.xml), res/values/ic_launcher_background.xml
"""
import math
import struct
import sys
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "assets/icon/app_icon_114.png"
RES = ROOT / "android/app/src/main/res"

# density name -> legacy icon px (48dp), adaptive foreground canvas px (108dp)
DENSITIES = {
    "mdpi": (48, 108),
    "hdpi": (72, 162),
    "xhdpi": (96, 216),
    "xxhdpi": (144, 324),
    "xxxhdpi": (192, 432),
}


# ---------------------------------------------------------------- PNG decode
def decode_png_rgba(path: Path):
    data = path.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", "not a PNG"
    pos, idat, plte, trns = 8, bytearray(), None, None
    width = height = bitdepth = colortype = None
    while pos < len(data):
        (length,) = struct.unpack(">I", data[pos:pos + 4])
        ctype = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + length]
        if ctype == b"IHDR":
            width, height, bitdepth, colortype = struct.unpack(">IIBB", chunk[:10])
        elif ctype == b"IDAT":
            idat += chunk
        elif ctype == b"PLTE":
            plte = chunk
        elif ctype == b"tRNS":
            trns = chunk
        pos += 12 + length
    assert bitdepth == 8, f"only 8-bit PNGs supported, got {bitdepth}"
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[colortype]
    raw = zlib.decompress(bytes(idat))
    stride = width * channels
    px = bytearray(width * height * 4)
    prev = bytearray(stride)
    p = 0
    for y in range(height):
        filt = raw[p]; p += 1
        line = bytearray(raw[p:p + stride]); p += stride
        if filt == 1:
            for i in range(channels, stride):
                line[i] = (line[i] + line[i - channels]) & 0xFF
        elif filt == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif filt == 3:
            for i in range(stride):
                a = line[i - channels] if i >= channels else 0
                line[i] = (line[i] + ((a + prev[i]) >> 1)) & 0xFF
        elif filt == 4:
            for i in range(stride):
                a = line[i - channels] if i >= channels else 0
                b = prev[i]
                c = prev[i - channels] if i >= channels else 0
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pr) & 0xFF
        for x in range(width):
            s, d = x * channels, (y * width + x) * 4
            if colortype == 6:
                px[d:d + 4] = line[s:s + 4]
            elif colortype == 2:
                px[d:d + 3] = line[s:s + 3]; px[d + 3] = 255
            elif colortype == 0:
                px[d] = px[d + 1] = px[d + 2] = line[s]; px[d + 3] = 255
            elif colortype == 4:
                px[d] = px[d + 1] = px[d + 2] = line[s]; px[d + 3] = line[s + 1]
            elif colortype == 3:
                idx = line[s] * 3
                px[d:d + 3] = plte[idx:idx + 3]
                px[d + 3] = trns[line[s]] if trns and line[s] < len(trns) else 255
        prev = line
    return width, height, px


def encode_png(path: Path, width: int, height: int, px: bytearray):
    raw = bytearray()
    stride = width * 4
    for y in range(height):
        raw.append(0)
        raw += px[y * stride:(y + 1) * stride]

    def chunk(ctype: bytes, body: bytes) -> bytes:
        c = ctype + body
        return struct.pack(">I", len(body)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)

    png = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
           + chunk(b"IEND", b""))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)


# ----------------------------------------------------------------- transform
def resize_bilinear(sw, sh, src, dw, dh):
    dst = bytearray(dw * dh * 4)
    for dy in range(dh):
        sy = (dy + 0.5) * sh / dh - 0.5
        y0 = max(0, math.floor(sy)); y1 = min(sh - 1, y0 + 1)
        fy = min(1.0, max(0.0, sy - y0))
        for dx in range(dw):
            sx = (dx + 0.5) * sw / dw - 0.5
            x0 = max(0, math.floor(sx)); x1 = min(sw - 1, x0 + 1)
            fx = min(1.0, max(0.0, sx - x0))
            d = (dy * dw + dx) * 4
            for ch in range(4):
                top = src[(y0 * sw + x0) * 4 + ch] * (1 - fx) + src[(y0 * sw + x1) * 4 + ch] * fx
                bot = src[(y1 * sw + x0) * 4 + ch] * (1 - fx) + src[(y1 * sw + x1) * 4 + ch] * fx
                dst[d + ch] = round(top * (1 - fy) + bot * fy)
    return dst


def circle_mask(size, px, supersample=4):
    """Zero the alpha outside the inscribed circle (anti-aliased)."""
    r = size / 2.0
    for y in range(size):
        for x in range(size):
            inside = 0
            for sy in range(supersample):
                for sx in range(supersample):
                    cx = x + (sx + 0.5) / supersample - r
                    cy = y + (sy + 0.5) / supersample - r
                    if cx * cx + cy * cy <= r * r:
                        inside += 1
            i = (y * size + x) * 4 + 3
            px[i] = round(px[i] * inside / (supersample * supersample))
    return px


def paste_centered(canvas_size, icon_px, icon_size, scale=0.80):
    target = round(canvas_size * scale)
    resized = resize_bilinear(icon_size, icon_size, icon_px, target, target)
    canvas = bytearray(canvas_size * canvas_size * 4)  # transparent
    off = (canvas_size - target) // 2
    for y in range(target):
        for x in range(target):
            s = (y * target + x) * 4
            a = resized[s + 3] / 255.0
            if a == 0:
                continue
            d = ((y + off) * canvas_size + (x + off)) * 4
            for ch in range(3):
                canvas[d + ch] = round(resized[s + ch] * a + canvas[d + ch] * (1 - a))
            canvas[d + 3] = max(canvas[d + 3], resized[s + 3])
    return canvas


def main():
    sw, sh, src = decode_png_rgba(SOURCE)
    assert sw == sh, "launcher icon source must be square"
    # Corner average = the icon's dark navy background (for adaptive icons).
    corners = []
    for (x, y) in [(sw // 2, 3), (sw // 2, sh - 4), (3, sh // 2), (sw - 4, sh // 2)]:  # edge midpoints: corners are transparent (rounded icon)
        i = (y * sw + x) * 4
        corners.append(tuple(src[i:i + 3]))
    avg = tuple(round(sum(c[k] for c in corners) / len(corners)) for k in range(3))
    print(f"source {sw}x{sh}, background colour = #{avg[0]:02X}{avg[1]:02X}{avg[2]:02X}")

    for density, (legacy, adaptive) in DENSITIES.items():
        icon = resize_bilinear(sw, sh, src, legacy, legacy)
        encode_png(RES / f"mipmap-{density}" / "ic_launcher.png", legacy, legacy, icon)
        encode_png(RES / f"mipmap-{density}" / "ic_launcher_round.png",
                   legacy, legacy, circle_mask(legacy, bytearray(icon)))
        fg = paste_centered(adaptive, src, sw, scale=0.80)
        encode_png(RES / f"drawable-{density}" / "ic_launcher_foreground.png",
                   adaptive, adaptive, fg)
        print(f"{density}: legacy {legacy}px, adaptive foreground {adaptive}px")
    print("done")


if __name__ == "__main__":
    sys.exit(main())
