#!/usr/bin/env python3
"""Mirror a dated tlnet snapshot from texlive.info into a local directory.

Usage: fetch_tlnet.py <YYYY/MM/DD> <dest-dir>

Downloads the containers needed to run install-tl fully offline with
`-repository /path` (plain path, media local_compressed):
  - every arch-independent runfile container       (<pkg>.tar.xz)
  - binaries for x86_64-linux and aarch64-linux    (<pkg>.<arch>.tar.xz)
  - tlpkg/texlive.tlpdb (+ .sha512/.asc) and install-tl-unx.tar.gz (+ sigs)
doc/source containers are skipped: the images are consumed with
tlpdbopt_install_docfiles/srcfiles = 0.

Every container is verified against the sha512 recorded in texlive.tlpdb,
so re-runs are incremental: files that already verify are skipped.
"""
import concurrent.futures as fut
import hashlib
import os
import subprocess
import sys
import time

JOBS = 6
ARCHES = ("x86_64-linux", "aarch64-linux")


def curl(url, out, retries=5):
    for i in range(retries):
        r = subprocess.run(["curl", "-sf", "--retry", "3", "--retry-all-errors",
                            "-C", "-", "--max-time", "300", "-o", out, url],
                           check=False)
        if r.returncode == 0:
            return True
        time.sleep(2 * (i + 1))
    return False


def sha512(path):
    h = hashlib.sha512()
    with open(path, "rb") as f:
        for c in iter(lambda: f.read(1 << 20), b""):
            h.update(c)
    return h.hexdigest()


def main():
    snapshot, dest = sys.argv[1], sys.argv[2]
    base = f"https://texlive.info/tlnet-archive/{snapshot}/tlnet"
    os.makedirs(f"{dest}/tlpkg", exist_ok=True)
    os.makedirs(f"{dest}/archive", exist_ok=True)

    # installer tarball + signatures (small, always refresh)
    # drop the seeded copies first: .sha512/.asc have a constant byte length, so
    # `curl -C -` reports them complete and silently keeps the stale ones, while
    # the tarball gets a newer tail appended onto an older prefix
    for f in ("install-tl-unx.tar.gz", "install-tl-unx.tar.gz.sha512",
              "install-tl-unx.tar.gz.sha512.asc"):
        if os.path.exists(f"{dest}/{f}"):
            os.remove(f"{dest}/{f}")
        if not curl(f"{base}/{f}", f"{dest}/{f}"):
            sys.exit(f"download failed: {f}")

    # tlpdb, verified against its sha512
    # same trap as above: the seeded .sha512/.asc have a constant byte length,
    # so `curl -C -` reports them complete and keeps the previous snapshot's
    # copy. The seeded tlpdb then verifies against that stale hash and the new
    # snapshot is never fetched. Drop them first.
    tlpdb = f"{dest}/tlpkg/texlive.tlpdb"
    for f in ("tlpkg/texlive.tlpdb.sha512", "tlpkg/texlive.tlpdb.sha512.asc"):
        if os.path.exists(f"{dest}/{f}"):
            os.remove(f"{dest}/{f}")
        if not curl(f"{base}/{f}", f"{dest}/{f}"):
            sys.exit(f"download failed: {f}")
    want = open(f"{tlpdb}.sha512").read().split()[0]
    for attempt in range(6):
        if os.path.exists(tlpdb) and sha512(tlpdb) == want:
            break
        if os.path.exists(tlpdb):
            os.remove(tlpdb)
        curl(f"{base}/tlpkg/texlive.tlpdb", tlpdb)
    else:
        sys.exit("texlive.tlpdb keeps failing sha512 verification")
    print("tlpdb OK", flush=True)

    # container list from the tlpdb
    pkgs, cur, size, csum = [], None, None, None
    for line in open(tlpdb, encoding="utf-8", errors="replace"):
        line = line.rstrip("\n")
        if line.startswith("name "):
            cur, size, csum = line[5:], None, None
        elif line.startswith("containersize "):
            size = int(line[14:])
        elif line.startswith("containerchecksum "):
            csum = line[18:]
        elif line == "" and cur:
            arch = cur.rsplit(".", 1)[-1] if "." in cur else ""
            is_bin = "-" in arch and not arch.startswith("win32")
            if size and csum and (not is_bin or arch in ARCHES):
                pkgs.append((cur, size, csum))
            cur = None
    total = sum(s for _, s, _ in pkgs)
    print(f"containers: {len(pkgs)}, {total / 1073741824:.2f} GB", flush=True)

    # stale files from a previous snapshot (2026 rolls daily): drop anything
    # that is not in the current container list
    keep = {f"{n}.tar.xz" for n, _, _ in pkgs}
    stale = [f for f in os.listdir(f"{dest}/archive") if f not in keep]
    for f in stale:
        os.remove(f"{dest}/archive/{f}")
    if stale:
        print(f"removed {len(stale)} stale containers", flush=True)

    done = fail = skip = 0

    def fetch(item):
        name, sz, cs = item
        fn = f"{dest}/archive/{name}.tar.xz"
        if os.path.exists(fn) and os.path.getsize(fn) == sz and sha512(fn) == cs:
            return "skip", name
        for attempt in range(4):
            curl(f"{base}/archive/{name}.tar.xz", fn)
            if os.path.exists(fn) and os.path.getsize(fn) == sz and sha512(fn) == cs:
                return "ok", name
            if os.path.exists(fn) and os.path.getsize(fn) > sz:
                os.remove(fn)  # broken resume grows past the real size
            # texlive.info is a single box; when a snapshot changes we pull
            # hundreds of containers at once and it starts refusing. Back off
            # instead of retrying straight into the same wall.
            time.sleep(3 * (attempt + 1))
        return "fail", name

    t0 = time.time()
    with fut.ThreadPoolExecutor(JOBS) as ex:
        for i, (st, name) in enumerate(ex.map(fetch, pkgs), 1):
            if st == "ok":
                done += 1
            elif st == "skip":
                skip += 1
            else:
                fail += 1
                print(f"FAIL {name}", flush=True)
            if i % 500 == 0:
                print(f"{i}/{len(pkgs)} new={done} kept={skip} "
                      f"failed={fail} {(time.time() - t0) / 60:.1f}min", flush=True)

    print(f"RESULT new={done} kept={skip} failed={fail} "
          f"{(time.time() - t0) / 60:.1f}min", flush=True)
    sys.exit(1 if fail else 0)


if __name__ == "__main__":
    main()
