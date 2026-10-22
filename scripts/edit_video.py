#!/usr/bin/env python3
"""Turn the raw simulator recording into a short, compressed demo video.

1. Trim to the in-app tour: from the app launch to the app exit, found by comparing
   frames with the home screen the recording starts on (the wall-clock marks written by
   AppTourUITests are only a fallback, since the recorder's clock runs a few seconds off).
2. Shorten every static stretch (UI test waiting for the app to idle, etc.) so the
   video only shows the app being operated.
3. Re-encode to H.264 at 1280 px height.

The simulator recording has a variable frame rate with long gaps, so the video is
never seeked: it is decoded once onto a constant 30 fps timeline, all cuts are
computed on that timeline, and the encode selects frames on the same timeline.

Usage: scripts/edit_video.py <recording-dir> <output.mp4>
Requires ffmpeg and numpy.
"""

import json
import subprocess
import sys

import numpy as np

FPS = 30
MAX_STILL = 1.8  # seconds a frozen frame may stay on screen
THUMB_W, THUMB_H = 66, 144


def thumbnails(raw):
    data = subprocess.run(
        ["ffmpeg", "-loglevel", "error", "-i", raw,
         "-vf", f"fps={FPS},scale={THUMB_W}:{THUMB_H},format=gray", "-f", "rawvideo", "-"],
        capture_output=True, check=True,
    ).stdout
    return np.frombuffer(data, np.uint8).reshape(-1, THUMB_H, THUMB_W).astype(np.float32)


def app_bounds(frames, start, end):
    """Frame range from the app launch to the app exit.

    The recording starts on the home screen and ends on it, so the app is on screen
    between the first frame that leaves the home screen and the first frame back on it.
    The marks are only a fallback: the recorder's timestamps run several seconds off.
    """
    to_home = np.abs(frames - frames[0]).mean(axis=(1, 2))
    app_level = np.median(to_home[start:end])
    in_app = np.nonzero(to_home > 0.35 * app_level)[0]
    if not len(in_app):
        return start, end
    launch = in_app[0]
    back_home = np.nonzero(to_home[launch:] < 0.1 * app_level)[0]
    # Stop before the exit animation, which starts before the screen is pure home.
    exit_ = launch + back_home[0] - int(0.6 * FPS) if len(back_home) else end
    return launch + int(0.2 * FPS), exit_


def keep_ranges(frames, start, end):
    """Frame ranges to keep, cutting each still stretch down to MAX_STILL."""
    moving = np.abs(np.diff(frames[start:end], axis=0)).mean(axis=(1, 2)) > 0.4
    keep, run_start, cursor = [], None, start
    max_still = int(MAX_STILL * FPS)
    for i, is_moving in enumerate(np.append(moving, True)):
        frame = start + i
        if not is_moving and run_start is None:
            run_start = frame
        elif is_moving and run_start is not None:
            if frame - run_start > max_still:
                keep.append((cursor, run_start + max_still))
                cursor = frame
            run_start = None
    keep.append((cursor, end))
    return keep


def main():
    rec_dir, output = sys.argv[1], sys.argv[2]
    raw = f"{rec_dir}/raw.mp4"
    t0 = float(open(f"{rec_dir}/record_start.txt").read())
    marks = json.load(open(f"{rec_dir}/marks.json"))

    frames = thumbnails(raw)
    start = int((marks["start"] - t0) * FPS)
    end = min(int((marks["end"] - t0) * FPS), len(frames))
    start, end = app_bounds(frames, start, end)
    keep = keep_ranges(frames, start, end)

    kept = sum(b - a for a, b in keep)
    print(f"app on screen {start / FPS:.1f}s-{end / FPS:.1f}s, "
          f"keeping {kept / FPS:.1f}s after shortening {len(keep) - 1} still stretches")

    select = "+".join(f"between(n,{a},{b - 1})" for a, b in keep)
    vf = f"fps={FPS},select='{select}',setpts=N/{FPS}/TB,scale=-2:1280:flags=lanczos"
    subprocess.run(
        ["ffmpeg", "-y", "-loglevel", "error", "-i", raw, "-vf", vf,
         "-c:v", "libx264", "-preset", "slow", "-crf", "26", "-pix_fmt", "yuv420p",
         "-movflags", "+faststart", "-an", output],
        check=True,
    )
    subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration,size",
                    "-of", "default=nw=1", output], check=True)


if __name__ == "__main__":
    main()
