#!/bin/sh
# Little Piggy Tracker (LittleGPTracker) for TrimUI Brick / Smart Pro
# NextUI Tools pak.
set -e

PAK_DIR="$(cd "$(dirname "$0")" && pwd)"
PAK_NAME="$(basename "$PAK_DIR" .pak)"
BINARY="lgpt-tg5040.elf"

# User data lives OUTSIDE the pak: the Pak Store wipes and re-unzips the pak
# folder on update, which would otherwise take every song with it. This path
# is also what config.xml sets as ROOTFOLDER, so it is where the tracker
# looks for samplelib/ and lgpt_<Project>/ directories.
DATA_DIR="/mnt/SDCARD/LGPT"
mkdir -p "$DATA_DIR/samplelib" "$DATA_DIR/logs" 2>/dev/null || true

# One truncated log per launch, on the SD card so a crash is retrievable
# without ssh. Falls back to /tmp if the card is not writable.
LOG_FILE="$DATA_DIR/logs/$PAK_NAME.txt"
if : > "$LOG_FILE" 2>/dev/null; then
    exec >> "$LOG_FILE" 2>&1
else
    LOG_FILE="/tmp/$PAK_NAME.txt"
    : > "$LOG_FILE" 2>/dev/null || true
    exec >> "$LOG_FILE" 2>&1
fi
echo "=== $PAK_NAME launch $(date 2>/dev/null) ==="
echo "firmware: $(head -n1 /etc/version 2>/dev/null)"
echo "pak dir : $PAK_DIR"
echo "data dir: $DATA_DIR"

cd "$PAK_DIR"

# The Pak Store does not preserve the executable bit.
chmod +x "./$BINARY" 2>/dev/null || true

# Library resolution, in priority order:
#   1. /usr/trimui/lib - the device's OWN SDL2 (2.30.8). /etc/ld.so.conf is
#      empty and this directory is NOT on the default search path, so without
#      this line SDL2 resolves to whatever another pak happened to leave
#      behind, or nothing. It must be the stock build: it is the only SDL2
#      matching this device's GPU blobs, and other versions are known to die
#      on the Brick's unsupported SDL_GetDisplayDPI query. We deliberately
#      do NOT ship our own SDL2 even though we compile against the SDK's
#      2.26 headers - SDL2 keeps ABI compatibility forward.
#   2. inherited LD_LIBRARY_PATH, last, so it can never override the above.
export LD_LIBRARY_PATH="/usr/trimui/lib:$LD_LIBRARY_PATH"
export LANG=C LC_CTYPE=C

# Keep NextUI from sleeping mid-pattern, and restore the governor on the way
# out however we exit.
ORIG_GOV=""
[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ] && \
    ORIG_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
cleanup() {
    rm -f /tmp/stay_awake 2>/dev/null || true
    if [ -n "$ORIG_GOV" ]; then
        for cpu in 0 1 2 3; do
            echo "$ORIG_GOV" > /sys/devices/system/cpu/cpu${cpu}/cpufreq/scaling_governor 2>/dev/null || true
        done
    fi
}
trap cleanup EXIT INT TERM HUP QUIT

for cpu in 0 1 2 3; do
    echo performance > /sys/devices/system/cpu/cpu${cpu}/cpufreq/scaling_governor 2>/dev/null || true
done
echo "1" > /tmp/stay_awake 2>/dev/null || true

echo "--- starting $BINARY ---"
set +e
nice -n -20 "./$BINARY"
rc=$?
set -e
echo "--- $BINARY exited rc=$rc ---"
exit $rc
