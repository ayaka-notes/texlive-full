#!/usr/bin/env python3
"""Measure peak disk usage of `docker pull` for a texlive-full tag.

Samples the filesystem quota consumption at 5 Hz while the pull runs, and
splits it into "compressed blobs on disk" vs "extracted layers on disk".
"""
import os, sys, time, json, shutil, signal, subprocess, threading

TAG   = sys.argv[1]                    # e.g. 2026.1
MODE  = sys.argv[2]                    # graphdriver | containerd
OUT   = sys.argv[3]                    # output dir
REPO  = "ghcr.io/ayaka-notes/texlive-full"
ROOT  = "/var/lib/docker"
INTERVAL = 0.2

os.makedirs(OUT, exist_ok=True)
run = lambda c, **k: subprocess.run(c, shell=True, capture_output=True, text=True, **k)

def avail():
    s = os.statvfs("/")
    return s.f_bavail * s.f_frsize

def dirsize(path):
    """Sum of allocated blocks under path (fast: used on small dirs only)."""
    tot = 0
    stack = [path]
    while stack:
        d = stack.pop()
        try:
            with os.scandir(d) as it:
                for e in it:
                    try:
                        if e.is_dir(follow_symlinks=False):
                            stack.append(e.path)
                        else:
                            tot += e.stat(follow_symlinks=False).st_blocks * 512
                    except OSError:
                        pass
        except OSError:
            pass
    return tot

# where each mode keeps the *compressed* blobs while/after pulling
if MODE == "default":
    # containerd image store: compressed blobs live here, and are KEPT after pull
    BLOBDIRS = [f"{ROOT}/containerd/daemon/io.containerd.content.v1.content"]
else:
    BLOBDIRS = [f"{ROOT}/tmp"]          # overlay2 graphdriver: download scratch

def blobsize():
    return sum(dirsize(p) for p in BLOBDIRS)

# ---------- daemon lifecycle ----------
def stop_docker():
    for name in ("dockerd", "containerd"):
        r = run(f"pgrep -x {name}")
        for pid in r.stdout.split():
            try: os.kill(int(pid), signal.SIGTERM)
            except OSError: pass
    for _ in range(30):
        if not run("pgrep -x dockerd").stdout.strip(): break
        time.sleep(1)
    for name in ("dockerd", "containerd"):
        for pid in run(f"pgrep -x {name}").stdout.split():
            try: os.kill(int(pid), signal.SIGKILL)
            except OSError: pass
    time.sleep(2)

def start_docker():
    # "default" == exactly what `apt-get install docker-ce` from download.docker.com
    # gives you: NO /etc/docker/daemon.json at all, daemon picks its own defaults
    # (Docker 29 -> containerd image store + overlayfs snapshotter).
    if MODE == "default":
        try: os.remove("/etc/docker/daemon.json")
        except FileNotFoundError: pass
    else:
        cfg = {"features": {"containerd-snapshotter": False},
               "storage-driver": "overlay2"}
        os.makedirs("/etc/docker", exist_ok=True)
        json.dump(cfg, open("/etc/docker/daemon.json", "w"))
    subprocess.Popen(f"dockerd --data-root={ROOT} >> {OUT}/dockerd.log 2>&1",
                     shell=True, start_new_session=True)
    for _ in range(60):
        if run("docker info --format '{{.Driver}}'").returncode == 0: break
        time.sleep(1)
    return run("docker info --format '{{.Driver}}'").stdout.strip()

print(f"[{TAG}/{MODE}] stopping docker, wiping {ROOT} ...", flush=True)
stop_docker()
shutil.rmtree(ROOT, ignore_errors=True)
os.makedirs(ROOT, exist_ok=True)
run("sync")
time.sleep(2)
driver = start_docker()
run("sync"); time.sleep(2)

BASE = avail()
print(f"[{TAG}/{MODE}] driver={driver}  baseline avail={BASE/2**30:.3f} GiB", flush=True)

# ---------- sampler ----------
samples = []          # (t, consumed_bytes, blob_bytes)
stop_flag = threading.Event()
def sampler():
    t0 = time.time()
    nxt = t0
    while not stop_flag.is_set():
        t = time.time()
        samples.append((round(t - t0, 3), BASE - avail(), blobsize()))
        nxt += INTERVAL
        time.sleep(max(0.0, nxt - time.time()))
th = threading.Thread(target=sampler, daemon=True); th.start()

# ---------- the pull ----------
t0 = time.time()
events = []
proc = subprocess.Popen(f"docker pull --platform linux/amd64 {REPO}:{TAG}",
                        shell=True, stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT, text=True, bufsize=1)
for line in proc.stdout:
    events.append((round(time.time() - t0, 3), line.rstrip()))
rc = proc.wait()
t_pull = time.time() - t0

# settle: flush dirty pages so the post-pull figure is exact
run("sync"); time.sleep(3)
samples.append((round(time.time() - t0, 3), BASE - avail(), blobsize()))
time.sleep(1)
stop_flag.set(); th.join(timeout=5)

run("sync"); time.sleep(2)
final_consumed = BASE - avail()
final_blob = blobsize()

di = run("docker image inspect --format '{{.Size}}' " + f"{REPO}:{TAG}").stdout.strip()
dsdf = run("docker system df -v").stdout

peak_i = max(range(len(samples)), key=lambda i: samples[i][1])
peak_t, peak_c, peak_b = samples[peak_i]

res = dict(tag=TAG, mode=MODE, driver=driver, rc=rc,
           pull_seconds=round(t_pull, 2),
           peak_bytes=peak_c, peak_at_s=peak_t, peak_blob_bytes=peak_b,
           final_bytes=final_consumed, final_blob_bytes=final_blob,
           image_size=di, samples=len(samples))
json.dump(res, open(f"{OUT}/{TAG}-{MODE}.json", "w"), indent=2)
with open(f"{OUT}/{TAG}-{MODE}.csv", "w") as f:
    f.write("t_seconds,consumed_bytes,compressed_blob_bytes\n")
    for s in samples:
        f.write(f"{s[0]},{s[1]},{s[2]}\n")
with open(f"{OUT}/{TAG}-{MODE}.pull.log", "w") as f:
    for t, l in events: f.write(f"{t:9.3f}  {l}\n")
    f.write("\n=== docker system df -v ===\n" + dsdf)

G = 2**30
print(f"[{TAG}/{MODE}] rc={rc} pull={t_pull:.1f}s")
print(f"  PEAK  consumed = {peak_c/G:.3f} GiB  at t={peak_t}s (blobs on disk then: {peak_b/G:.3f} GiB)")
print(f"  FINAL consumed = {final_consumed/G:.3f} GiB (blobs retained: {final_blob/G:.3f} GiB)")
print(f"  docker image size = {di}")
