#!/bin/sh
# Re-take the three screenshots from a built out/ directory.
# Needs the headless Chromium at ~/workspace/.local/chromium/chrome-linux/headless_shell
# (Playwright's chromium-headless-shell build, downloaded once with curl; the VM's
# system Chrome refuses to start headless here, and /tmp is a 512M tmpfs that
# fills up — keep the browser and profiles under ~/workspace/.local instead).
# Usage (from the repo root, after building out/ with main.ts):
#   OUT=out ./scripts/screenshots.sh
# Writes 1-board.png, 2-detail.png, 3-filtered.png into screenshots/ (1440x900).
set -e
OUT="${OUT:-out}"
CHROME="${CHROME:-$HOME/workspace/.local/chromium/chrome-linux/headless_shell}"
case "$OUT" in /*) OUTDIR="$OUT" ;; *) OUTDIR="$PWD/$OUT" ;; esac
BASE="file://$OUTDIR/dashboard/index.html"
shot() {
  "$CHROME" --no-sandbox --disable-gpu --disable-dev-shm-usage \
    --user-data-dir="$HOME/workspace/.local/tmp/prof-$1" \
    --screenshot="screenshots/$1.png" --window-size=1440,900 --hide-scrollbars \
    --virtual-time-budget=5000 "$2"
}
shot 1-board "$BASE"
shot 2-detail "$BASE#p=steakhouse-financial"
shot 3-filtered "$BASE#category=Risk%20Curators"
ls -la screenshots/
