#!/usr/bin/env bash
# Downscale the covers copied by copy-covers.sh to web resolution.
# The site never renders a cover above 480 CSS px, so 1000px on the long edge
# covers 2x retina with headroom. The client's full-resolution originals stay
# untouched in the source folders at the repo root — re-run copy-covers.sh
# followed by this script to regenerate.
set -euo pipefail
cd "$(dirname "$0")/.."

MAX=1000
DEST="site/src/assets/covers"

before=$(du -sk "$DEST" | cut -f1)
for f in "$DEST"/*; do
  # sips --resampleHeightWidthMax only shrinks when the image exceeds MAX
  sips --resampleHeightWidthMax "$MAX" "$f" >/dev/null
done
after=$(du -sk "$DEST" | cut -f1)

# The OG card image wants ~1200px on the long edge, not 1000
sips --resampleHeightWidthMax 1200 site/public/images/mary-ann-portrait.png >/dev/null

echo "covers: $((before / 1024))MB -> $((after / 1024))MB across $(ls "$DEST" | wc -l | tr -d ' ') files"
