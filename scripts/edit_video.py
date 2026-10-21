#!/usr/bin/env python3
"""Turn the raw simulator recording into a short, compressed demo video.

1. Trim to the in-app tour using the wall-clock marks written by AppTourUITests.
2. Shorten every static stretch (UI test waiting for the app to idle, etc.) so the
   video only shows the app being operated.
3. Re-encode to H.264 at 1280 px height.

Usage: scripts/edit_video.py <recording-dir> <output.mp4>
"""

import json
import re
import subprocess
import sys

MAX_STILL = 1.8  # seconds a frozen frame may stay on screen
FPS = 30


def main():
    rec_dir, output = sys.argv[1], sys.argv[2]
    raw = f"{rec_dir}/raw.mp4"
    t0 = float(open(f"{rec_dir}/record_start.txt").read())
    marks = json.load(open(f"{rec_dir}/marks.json"))
    start, end = marks["start"] - t0, marks["end"] - t0
    duration = end - start

    probe = subprocess.run(
        ["ffmpeg", "-hide_banner", "-ss", f"{start:.3f}", "-to", f"{end:.3f}", "-i", raw,
         "-vf", "scale=330:-1,freezedetect=n=0.002:d=0.5", "-map", "0:v", "-f", "null", "-"],
        capture_output=True, text=True, check=True,
    ).stderr
    starts = [float(x) for x in re.findall(r"freeze_start: ([\d.]+)", probe)]
    ends = [float(x) for x in re.findall(r"freeze_end: ([\d.]+)", probe)]
    ends += [duration] * (len(starts) - len(ends))

    keep, cursor, removed = [], 0.0, 0.0
    for fs, fe in zip(starts, ends):
        if fe - fs > MAX_STILL:
            cut_from = fs + MAX_STILL
            keep.append((cursor, cut_from))
            removed += fe - cut_from
            cursor = fe
    keep.append((cursor, duration))
    print(f"tour {duration:.1f}s, removing {removed:.1f}s of still frames in {len(keep) - 1} cuts")

    select = "+".join(f"between(t,{a:.3f},{b:.3f})" for a, b in keep)
    vf = (f"fps={FPS},select='{select}',setpts=N/{FPS}/TB,"
          "scale=-2:1280:flags=lanczos")
    subprocess.run(
        ["ffmpeg", "-y", "-loglevel", "error", "-ss", f"{start:.3f}", "-to", f"{end:.3f}", "-i", raw,
         "-vf", vf, "-c:v", "libx264", "-preset", "slow", "-crf", "26", "-pix_fmt", "yuv420p",
         "-movflags", "+faststart", "-an", output],
        check=True,
    )
    subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration,size",
                    "-of", "default=nw=1", output], check=True)


if __name__ == "__main__":
    main()
