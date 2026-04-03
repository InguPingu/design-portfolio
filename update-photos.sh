#!/bin/bash
# Run this after adding new photos to AboutMePhotos/
# Updates the photo list in about.html automatically.

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIR="$ROOT/AboutMePhotos"
HTML="$ROOT/about.html"

# Build the JS array lines
ARRAY=""
while IFS= read -r -d '' f; do
  name="$(basename "$f")"
  case "${name,,}" in
    *.png|*.jpg|*.jpeg|*.webp|*.gif) ;;
    *) continue ;;
  esac
  ARRAY="${ARRAY}    \"${name}\",\n"
done < <(find "$DIR" -maxdepth 1 -type f -print0 | sort -z)

# Replace the PHOTOS array in about.html using awk
awk -v arr="$ARRAY" '
  /const PHOTOS = \[/ { print; in_array=1; next }
  in_array && /^\s*\];/ { printf "%s", arr; print; in_array=0; next }
  in_array { next }
  { print }
' "$HTML" > "$HTML.tmp" && mv "$HTML.tmp" "$HTML"

count=$(echo -e "$ARRAY" | grep -c '"')
echo "✓ about.html updated with $count photos"
