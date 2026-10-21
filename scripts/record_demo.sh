#!/bin/bash
# Records the UI tour on a booted simulator.
# Usage: scripts/record_demo.sh <simulator-udid> <output-dir>
set -uo pipefail

UDID="$1"
OUT="$2"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"

xcrun simctl io "$UDID" recordVideo --codec=h264 --force "$OUT/raw.mp4" 2> "$OUT/record.log" &
REC_PID=$!

for _ in $(seq 1 100); do
  grep -q "Recording started" "$OUT/record.log" 2>/dev/null && break
  sleep 0.1
done
python3 -c 'import time; print(time.time())' > "$OUT/record_start.txt"
echo "Recording started at $(cat "$OUT/record_start.txt")"

TEST_RUNNER_MARKS_PATH="$OUT/marks.json" xcodebuild test-without-building \
  -project IcelandApp.xcodeproj \
  -scheme IcelandApp \
  -destination "id=$UDID" \
  -derivedDataPath build \
  -only-testing:IcelandAppUITests/AppTourUITests/testAppTour \
  -resultBundlePath "$OUT/tour.xcresult" \
  CODE_SIGNING_ALLOWED=NO 2>&1 | tee "$OUT/test.log"
STATUS=${PIPESTATUS[0]}

sleep 1
kill -INT "$REC_PID"
wait "$REC_PID" || true

# Fall back to the marks printed in the test log if the runner could not write the file.
if [ ! -s "$OUT/marks.json" ]; then
  python3 - "$OUT" <<'PY'
import json, re, sys
out = sys.argv[1]
marks = dict(re.findall(r"TOUR_MARK (\w+)=([\d.]+)", open(f"{out}/test.log").read()))
json.dump({k: float(v) for k, v in marks.items()}, open(f"{out}/marks.json", "w"), indent=2)
PY
fi

echo "--- record.log"; cat "$OUT/record.log"
echo "--- marks.json"; cat "$OUT/marks.json"
ls -la "$OUT"
exit "$STATUS"
