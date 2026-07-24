#!/usr/bin/env python3
"""Generate the TeXLive Full disc emblem icon (mono). One theme via --fg/--bg."""
import argparse, math

OVERLEAF_O = ("M37.205 39.652C14.822 53.982 0 77.339 0 102.326 0 132.522 24.48 157 54.681 157c30.198 0 "
    "54.674-24.478 54.674-54.674 0-23.34-14.626-43.276-35.204-51.111-3.958-1.505-12.556-4.213-19.421-3.635-9.806 "
    "6.234-21.751 19.044-27.411 31.809 8.416-10.093 21.537-14.488 33.17-12.619 17.126 2.777 30.208 17.638 30.208 "
    "35.551 0 19.896-16.126 36.021-36.016 36.021-10.962 0-20.785-4.896-27.388-12.619C17.516 114.299 15 101.91 "
    "16.975 89.809c6.927-42.375 57.233-66.53 94.636-75.799-12.207 6.458-34.227 17.074-49.626 28.63 44.924 17.341 "
    "52.184-20.517 73.217-37.459C114.038-3.07 37.33-6.117 37.205 39.652z")
OW, OH = 136, 157

def arc_text(text, radius, fg, font_size, center_deg=0.0, step_deg=None,
             bottom=False, cx=128, cy=128, font="Georgia,'Times New Roman',serif",
             weight="700", spacing_scale=1.0):
    if step_deg is None:
        step_deg = font_size * 0.62 / radius * (180/math.pi) * spacing_scale
    n = len(text)
    glyphs = []
    for i, ch in enumerate(text):
        offset = (i - (n-1)/2) * step_deg
        a = center_deg + (offset if not bottom else -offset)
        rad = math.radians(a)
        x = cx + radius * math.sin(rad)
        y = cy - radius * math.cos(rad)
        rot = a if not bottom else a + 180
        glyphs.append(
            f'<text x="{x:.2f}" y="{y:.2f}" font-size="{font_size}" '
            f'transform="rotate({rot:.2f} {x:.2f} {y:.2f})" '
            f'text-anchor="middle" dominant-baseline="central">{ch}</text>')
    return (f'<g font-family="{font}" font-weight="{weight}" fill="{fg}" '
            f'letter-spacing="0">' + "".join(glyphs) + "</g>")

def build(fg, bg):
    C = 128
    rings = "".join(
        f'<circle cx="128" cy="128" r="{r}"/>' for r in (116,111,106,101,96,91))
    # Overleaf O centered, scaled to fill the inner ring (r=49)
    target_h = 72
    s = target_h / OH
    ox = C - (OW*s)/2
    oy = C - (OH*s)/2
    o_mark = (f'<g transform="translate({ox:.2f} {oy:.2f}) scale({s:.4f})">'
              f'<path d="{OVERLEAF_O}" fill="{fg}" fill-rule="evenodd"/></g>')
    top = arc_text("TEX · LIVE", 67, fg, 18, center_deg=0, bottom=False)
    bot = arc_text("FULL", 67, fg, 18, center_deg=180, bottom=True, spacing_scale=1.4)
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs><clipPath id="face"><circle cx="128" cy="128" r="120"/></clipPath></defs>
  <circle cx="128" cy="128" r="122" fill="{fg}"/>
  <circle cx="128" cy="128" r="120" fill="{bg}"/>
  <g clip-path="url(#face)" fill="none" stroke="{fg}" stroke-width="1.3" opacity="0.8">{rings}</g>
  <g clip-path="url(#face)" opacity="0.08"><path d="M128 128 L246 52 L253 142 Z" fill="{fg}"/></g>
  <circle cx="128" cy="128" r="84" fill="{bg}" stroke="{fg}" stroke-width="1.8"/>
  <circle cx="128" cy="128" r="49" fill="none" stroke="{fg}" stroke-width="1.4" opacity="0.55"/>
  <g fill="{fg}"><path d="M60 128 l5.5 -5.5 5.5 5.5 -5.5 5.5 z"/><path d="M185 128 l5.5 -5.5 5.5 5.5 -5.5 5.5 z"/></g>
  {top}
  {bot}
  {o_mark}
</svg>
'''

def disc_group(fg, bg, cx, cy, scale):
    """The emblem as a <g> placed at (cx,cy) with given scale (1.0 = 256px)."""
    inner = build(fg, bg)
    inner = inner.split(">", 1)[1].rsplit("</svg>", 1)[0]
    t = 256 * scale
    return (f'<g transform="translate({cx-t/2:.2f} {cy-t/2:.2f}) scale({scale:.4f})">'
            f'{inner}</g>')

def build_banner(fg, bg, muted):
    W, H = 960, 260
    cy = H/2
    disc = disc_group(fg, bg, cx=150, cy=cy, scale=0.80)
    fam = "Georgia,'Times New Roman',serif"
    # Wordmark: real TeX lockup  ->  T \kern-.1667em \lower.5ex E \kern-.125em X
    wx = 320
    wy = 120
    fs = 78
    k1 = round(-0.1667 * fs, 1)   # kern before E
    k2 = round(-0.125 * fs, 1)    # kern before X
    low = round(0.22 * fs, 1)     # lower E by ~0.5ex
    word = (
        f'<g font-family="{fam}" fill="{fg}" font-weight="700">'
        f'<text x="{wx}" y="{wy}" font-size="{fs}" letter-spacing="0">'
        f'<tspan>T</tspan>'
        f'<tspan dx="{k1}" dy="{low}">E</tspan>'
        f'<tspan dx="{k2}" dy="{-low}">X</tspan>'
        f'<tspan dx="6">Live</tspan>'
        f'<tspan dx="20">Full</tspan>'
        f'</text></g>')
    tagline = (
        f'<text x="{wx+3}" y="{wy+52}" font-family="{fam}" font-size="27" '
        f'fill="{muted}" font-style="italic">'
        f'Best TeX Live Full image for Overleaf Sandbox.</text>')
    rule = f'<rect x="{wx+3}" y="{wy+72}" width="580" height="3" fill="{fg}" opacity="0.85"/>'
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">
  {disc}
  {word}
  {tagline}
  {rule}
</svg>
'''

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--fg", default="#111111")
    ap.add_argument("--bg", default="#ffffff")
    ap.add_argument("--muted", default="#555555")
    ap.add_argument("--kind", choices=["icon", "banner"], default="icon")
    ap.add_argument("-o", "--out", required=True)
    a = ap.parse_args()
    out = build(a.fg, a.bg) if a.kind == "icon" else build_banner(a.fg, a.bg, a.muted)
    with open(a.out, "w") as f:
        f.write(out)
    print("wrote", a.out)
