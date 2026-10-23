#!/usr/bin/env bash
# Zip skills for upload to claude.ai. Each zip contains the skill folder itself.
# Usage: ./scripts/package.sh [skill-name ...]   (no args = all skills)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
mkdir -p "$DIST"

if (( $# )); then
  skills=("$@")
else
  skills=()
  for d in "$ROOT"/skills/*/; do [[ -d "$d" ]] && skills+=("$(basename "$d")"); done
fi

# Git Bash on Windows has no zip, but Windows ships tar.exe (bsdtar), which can write zips.
WIN_TAR="${SYSTEMROOT:-C:\\Windows}\\System32\\tar.exe"
if command -v zip >/dev/null; then
  ZIPPER=zip
elif [[ -x "$(cygpath -u "$WIN_TAR" 2>/dev/null)" ]]; then
  ZIPPER=wintar
else
  echo "Error: no zip tool found. Install zip and try again." >&2; exit 1
fi

cd "$ROOT/skills"
for s in "${skills[@]}"; do
  if [[ ! -f "$s/SKILL.md" ]]; then
    echo "Skipping $s (no SKILL.md)" >&2; continue
  fi
  rm -f "$DIST/$s.zip"
  if [[ "$ZIPPER" == zip ]]; then
    zip -qr "$DIST/$s.zip" "$s" -x "*/.gitkeep" "*/tests.md" "*/.DS_Store"
  else
    "$(cygpath -u "$WIN_TAR")" -a -cf "$(cygpath -w "$DIST/$s.zip")" \
      --exclude .gitkeep --exclude tests.md --exclude .DS_Store "$s"
  fi
  echo "Packaged dist/$s.zip"
done
