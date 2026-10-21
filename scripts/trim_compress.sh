#!/bin/bash
# Trims the raw simulator recording to the in-app tour (using marks.json) and compresses it.
# Usage: scripts/trim_compress.sh <recording-dir> <output.mp4> [lead-in-seconds] [tail-seconds]
set -euo pipefail

DIR="$1"
OUT="$2"
LEAD="${3:-0}"
TAIL="${4:-0}"

read -r START END < <(python3 - "$DIR" "$LEAD" "$TAIL" <<'PY'
import json, sys
d, lead, tail = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
t0 = float(open(f"{d}/record_start.txt").read())
marks = json.load(open(f"{d}/marks.json"))
print(f"{max(0, marks['start'] - t0 - lead):.2f} {marks['end'] - t0 + tail:.2f}")
PY
)
echo "Trimming $DIR/raw.mp4 from ${START}s to ${END}s"

ffmpeg -y -loglevel error -ss "$START" -to "$END" -i "$DIR/raw.mp4" \
  -vf "scale=-2:1280:flags=lanczos,fps=30" \
  -c:v libx264 -preset slow -crf 27 -pix_fmt yuv420p -profile:v high \
  -movflags +faststart -an "$OUT"

ffprobe -v error -show_entries format=duration,size -of default=nw=1 "$OUT"
