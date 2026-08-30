#!/usr/bin/env python3
"""Collect every measurement run into one JSON blob for the report page."""
import json, os, glob, sys

SP = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(SP, "results")
TAGS = ["2026.1","2025.1","2024.1","2023.1","2022.1","2021.1","2020.1"]
G = 2**30

def decimate(rows, target=320):
    """Bucket-decimate but KEEP the max of every bucket, so the peak survives."""
    if len(rows) <= target:
        return rows
    step = len(rows) / target
    out, i = [], 0
    while i < len(rows):
        j = min(len(rows), int(round((len(out) + 1) * step)))
        if j <= i:
            j = i + 1
        bucket = rows[i:j]
        keep = max(bucket, key=lambda r: r[1])          # peak-preserving
        out.append(bucket[0])
        if keep is not bucket[0]:
            out.append(keep)
        i = j
    if out[-1] is not rows[-1]:
        out.append(rows[-1])
    return out

def load_series(path):
    rows = []
    with open(path) as f:
        next(f)
        for line in f:
            t, c, b = line.split(",")
            rows.append([float(t), int(c), int(b)])
    return rows

def collect(mode, subdir=""):
    out = {}
    for tag in TAGS:
        base = os.path.join(RES, subdir, f"{tag}-{mode}")
        if not os.path.exists(base + ".json"):
            continue
        meta = json.load(open(base + ".json"))
        rows = load_series(base + ".csv")
        d = decimate(rows)
        meta["series"] = [[round(r[0], 1), r[1], r[2]] for r in d]
        meta["n_raw"] = len(rows)
        out[tag] = meta
    return out

manifests = {}
for tag in TAGS:
    p = os.path.join(SP, f"man-{tag}.json")
    if os.path.exists(p):
        m = json.load(open(p))
        layers = [l["size"] for l in m["layers"]]
        manifests[tag] = {"n_layers": len(layers), "compressed_total": sum(layers),
                          "largest_layer": max(layers), "layers": layers}

data = {
    "default": collect("default"),
    "graphdriver": collect("graphdriver"),
    "graphdriver_mcd1": collect("graphdriver-mcd1"),
    "manifests": manifests,
    "quota_bytes": int(29.995 * G),
    "measured_on": "2026-08-29",
}
json.dump(data, open(os.path.join(SP, "report-data.json"), "w"), separators=(",", ":"))

print("tags measured (default):", sorted(data["default"]))
print("tags measured (graphdriver):", sorted(data["graphdriver"]))
for tag in TAGS:
    d = data["default"].get(tag)
    if d:
        print(f"  {tag}  peak={d['peak_bytes']/G:7.3f} GiB  final={d['final_bytes']/G:7.3f} GiB"
              f"  blobs={d['final_blob_bytes']/G:6.3f} GiB  pull={d['pull_seconds']:6.1f}s"
              f"  pts={len(d['series'])}/{d['n_raw']}")
size = os.path.getsize(os.path.join(SP, "report-data.json"))
print("report-data.json:", round(size/1024, 1), "KiB")
