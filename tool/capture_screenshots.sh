#!/usr/bin/env bash
# Captures README screenshots + short clips from a running Android emulator.
# Usage (with the example app open on the emulator):  bash tool/capture_screenshots.sh
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=doc/images
mkdir -p "$OUT"

ADB="${ADB:-adb}"
if ! command -v "$ADB" >/dev/null 2>&1; then
  for p in "$HOME/Library/Android/sdk/platform-tools/adb" "${ANDROID_HOME:-}/platform-tools/adb"; do
    [ -x "$p" ] && ADB="$p" && break
  done
fi
"$ADB" get-state >/dev/null || { echo "No emulator/device found by adb."; exit 1; }
echo "Using device: $("$ADB" shell getprop ro.product.model | tr -d '\r')"

shoot() { # name, prompt
  printf '\n\033[1;36m%s\033[0m\n' "$2"
  read -r -p "  Press Enter when ready… " _
  "$ADB" exec-out screencap -p > "$OUT/$1.png"
  echo "  ✔ saved $OUT/$1.png"
}

clip() { # name, seconds, prompt
  printf '\n\033[1;35m%s\033[0m\n' "$3"
  read -r -p "  Press Enter to start a ${2}s recording… " _
  "$ADB" shell screenrecord --time-limit "$2" --bit-rate 6000000 /sdcard/eg_clip.mp4
  "$ADB" pull -q /sdcard/eg_clip.mp4 "$OUT/$1.mp4" >/dev/null
  "$ADB" shell rm /sdcard/eg_clip.mp4
  echo "  ✔ saved $OUT/$1.mp4"
}

shoot contour  "1/4  Open the CONTOUR tab (Animate ON, any color)."
shoot ambient  "2/4  Open the AMBIENT tab."
shoot border   "3/4  Open the BORDER tab."
shoot ripple   "4/4  Open the RIPPLE tab."

read -r -p $'\nAlso record short animated clips for GIFs? [Y/n] ' yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  clip contour_clip 4 "CONTOUR tab — let it breathe/flicker."
  clip border_clip  4 "BORDER tab — rotating borders."
  clip ripple_clip  4 "RIPPLE tab — ripples."
  clip playground_clip 8 "Any tab — drag the sliders and tap color chips while recording."
fi

printf '\n\033[1;32mDone.\033[0m Files are in %s — tell Claude to finish the README.\n' "$OUT"
ls -1 "$OUT"
