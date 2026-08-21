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

# Derived assets that this script must not touch. Famous Wonders is a
# Real-ESRGAN 4x upscale (1756x1612) of a 439x403 client scan — copy-covers.sh
# deliberately does not regenerate it, and resampling it here would throw away
# work that needs a GPU model to redo. See its note in books.json.
SKIP="learning-about-the-philippines-famous-wonders.png"

before=$(du -sk "$DEST" | cut -f1)
for f in "$DEST"/*; do
  case " $SKIP " in *" $(basename "$f") "*) continue ;; esac
  # sips --resampleHeightWidthMax resamples in BOTH directions — handed a cover
  # whose long edge is under MAX it upscales, inventing pixels and bloating the
  # file. Some client covers ship smaller than MAX (Jesus Raises Lazarus is
  # 796x952), so gate the call on the long edge actually exceeding MAX.
  long=$(sips -g pixelWidth -g pixelHeight "$f" | awk '/pixel/ {print $2}' | sort -rn | head -1)
  if [ "$long" -gt "$MAX" ]; then
    sips --resampleHeightWidthMax "$MAX" "$f" >/dev/null
  fi
done
after=$(du -sk "$DEST" | cut -f1)

# The OG card image wants ~1200px on the long edge, not 1000
sips --resampleHeightWidthMax 1200 site/public/images/mary-ann-portrait.png >/dev/null

echo "covers: $((before / 1024))MB -> $((after / 1024))MB across $(ls "$DEST" | wc -l | tr -d ' ') files"
