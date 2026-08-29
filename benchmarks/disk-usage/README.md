# Peak disk usage of `docker pull`

How much disk does pulling one of these images actually need? The compressed
download size and the space it occupies on disk are two very different numbers,
and running out of room halfway through a pull is a common failure.

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
| storage | containerd image store (Docker 29 default) | 26.816 GiB | 26.816 GiB | kept, 8.748 GiB |
| overlay2 graphdriver (Docker ≤28 default) | 20.176 GiB | 18.086 GiB | deleted after extract |

With `overlay2` the pull has a real transient spike — 2.090 GiB above its own
final size — because downloads run concurrently while extraction is serial, so
compressed layers pile up in `/var/lib/docker/tmp` waiting their turn.

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
| `raw/*.csv` | Raw samples: `t_seconds, consumed_bytes, compressed_blob_bytes` |
| `raw/*.json` | Per-run summary: peak, final, timing, driver |

Reproduce with:

```bash
sudo ./run_all.sh default 2026.1 2025.1 2024.1 2023.1 2022.1 2021.1 2020.1
```

Needs roughly 30 GB of free space and takes about 5 minutes per tag.
