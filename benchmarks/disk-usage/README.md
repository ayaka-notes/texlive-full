# Peak disk usage of `docker pull`

How much disk does pulling one of these images actually need? The compressed
download size and the space it takes on disk are two very different numbers, and
running out of room halfway through a pull is a common failure.

These are measured values, not estimates.

## Test environment

Identical to a stock install from Docker's own APT repository:

| | |
|---|---|
| OS | Ubuntu 24.04.4 LTS (noble) |
| APT source | `https://download.docker.com/linux/ubuntu noble stable` |
| docker-ce | `5:29.3.1-1~ubuntu.24.04~noble` |
| containerd.io | `2.2.2-1~ubuntu.24.04~noble` |
| daemon config | **none** — no `/etc/docker/daemon.json`, defaults only |
| storage | containerd image store + `overlayfs` snapshotter (the Docker 29 default) |
| platform | `linux/amd64` |

## Results — stock defaults

Peak = the largest amount of disk the pull ever occupies. Under the containerd
image store the peak equals the final size, because the compressed layers are kept
in the content store and never deleted.

| Tag | Download | Peak (GiB) | Peak (GB) | Peak (bytes) | Extracted | Kept compressed | Ratio |
|:---|---:|---:|---:|---:|---:|---:|---:|
| 2026.1 | 8.748 GiB | **26.816** | 28.79 | 28,793,057,280 | 18.067 GiB | 8.748 GiB | 3.07× |
| 2025.1 | 8.276 GiB | **25.509** | 27.39 | 27,390,554,112 | 17.233 GiB | 8.276 GiB | 3.08× |
| 2024.1 | 8.341 GiB | **25.617** | 27.51 | 27,505,983,488 | 17.276 GiB | 8.341 GiB | 3.07× |
| 2023.1 | 7.479 GiB | **22.984** | 24.68 | 24,678,830,080 | 15.505 GiB | 7.479 GiB | 3.07× |
| 2022.1 | 7.342 GiB | **22.620** | 24.29 | 24,288,182,272 | 15.278 GiB | 7.342 GiB | 3.08× |
| 2021.1 | 6.346 GiB | **19.431** | 20.86 | 20,863,787,008 | 13.084 GiB | 6.346 GiB | 3.06× |
| 2020.1 | 6.378 GiB | **19.695** | 21.15 | 21,147,086,848 | 13.316 GiB | 6.378 GiB | 3.09× |

**A 20 GB disk cannot hold any of these tags** — not even 2020.1, which needs
21.15 GB. For 2026.1 you need at least 28.8 GB free just for the image; plan on
40 GB so there is room for the OS and for compile scratch files.

The tags share almost no layers with each other, so pulling several years costs
close to the sum of their sizes — about 175 GB for all seven.

## Storage driver matters

Docker 28 and earlier defaulted to the `overlay2` graphdriver, which deletes each
compressed layer as soon as it is extracted. Docker 29 defaults to the containerd
image store, which keeps them. Switching back saves a whole copy of the download:

| Tag | containerd peak | overlay2 peak | overlay2 final | overlay2 spike | Saved |
|:---|---:|---:|---:|---:|---:|
| 2026.1 | 26.816 GiB | **20.176 GiB** | 18.086 GiB | +2.090 GiB | 6.639 GiB |
| 2025.1 | 25.509 GiB | **19.251 GiB** | 17.320 GiB | +1.931 GiB | 6.258 GiB |
| 2024.1 | 25.617 GiB | **19.290 GiB** | 17.294 GiB | +1.996 GiB | 6.327 GiB |
| 2023.1 | 22.984 GiB | **17.312 GiB** | 15.521 GiB | +1.791 GiB | 5.672 GiB |
| 2022.1 | 22.620 GiB | **16.947 GiB** | 15.294 GiB | +1.653 GiB | 5.673 GiB |
| 2021.1 | 19.431 GiB | **14.752 GiB** | 13.099 GiB | +1.653 GiB | 4.679 GiB |
| 2020.1 | 19.695 GiB | **15.018 GiB** | 13.331 GiB | +1.688 GiB | 4.676 GiB |

To switch, put this in `/etc/docker/daemon.json` and restart the daemon:

```json
{
  "features": { "containerd-snapshotter": false }
}
```

`docker info --format '{{.Driver}}'` then reports `overlay2` rather than
`overlayfs`. The two stores are independent: images pulled under one are invisible
to the other (not deleted — they reappear if you switch back), so remove images
before switching or they keep occupying disk unseen.

Size the disk against the **peak**, not the final figure.

### Where the overlay2 spike comes from

Not from downloads outrunning extraction, which is the intuitive guess. Compressed
layers do pile up in `/var/lib/docker/tmp` early on — 2026.1 reaches 8.716 GiB of
them at t=75 s — but only 10.0 GiB of disk is in use at that moment, nowhere near
the maximum.

The real peak lands at the very *end* of the pull: the image is essentially fully
extracted (18.04 GiB) while **the last large compressed layer is still on disk,
because a layer's compressed copy is deleted only once its own extraction
finishes**. For 2026.1 that layer is L16 at 2.130 GiB; the sample at the peak
measured 2,292,486,144 bytes in `tmp`, which is L16 plus L19 to within 21 KB. All
seven tags follow the same pattern — each spike sits 35–40 MiB below its own last
large layer.

Which is why `max-concurrent-downloads` does not help. Measured on 2026.1:

| `max-concurrent-downloads` | Peak | Pull time |
|:---|---:|---:|
| 3 (default) | 20.176 GiB | 438.3 s |
| 1 | 20.181 GiB | 408.3 s |

A 4.6 MB difference — noise. The storage driver is the only lever that
moves this number.

## Deleting is clean

`docker rmi` reclaimed 26.815 GiB of the 26.816 GiB used, leaving 1.1 MiB of
daemon metadata. No separate prune is needed — removing the image also garbage
collects the compressed layers from the content store.

## Method

- Each run stops the daemon, wipes `/var/lib/docker`, restarts, and re-baselines,
  so no layer is ever reused between tags.
- Disk use is sampled with `statvfs()` every 0.2 s: consumed = baseline available
  space − current available space. This measures bytes actually on disk, not the
  logical size reported by `docker images`.
- `vm.dirty_bytes` is set to 512 MiB during sampling so writeback keeps up and the
  curve does not lag behind the data; the final figure is taken after `sync`.
- Cross-checked against `docker system df -v` (2026.1: 28,793,057,280 B measured,
  28.8 GB reported).

## Files

| Path | What it is |
|---|---|
| `measure.py` | Measures one tag: wipes state, pulls, samples, writes CSV + JSON |
| `run_all.sh` | Runs `measure.py` over a list of tags sequentially |
| `build_data.py` | Merges every run into a single JSON for charting |
| `raw/*-default.*` | Stock Docker defaults (containerd image store) |
| `raw/*-graphdriver.*` | `overlay2` graphdriver |
| `raw/*-graphdriver-mcd1.*` | `overlay2` with `max-concurrent-downloads: 1` |

CSV columns are `t_seconds, consumed_bytes, compressed_blob_bytes`; the JSON
alongside each one carries the peak, the final figure, timing and the driver.

Reproduce with:

```bash
sudo ./run_all.sh default 2026.1 2025.1 2024.1 2023.1 2022.1 2021.1 2020.1
```

Needs roughly 30 GB of free space and takes about 5 minutes per tag.
