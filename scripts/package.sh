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

cd "$ROOT/skills"
for s in "${skills[@]}"; do
  if [[ ! -f "$s/SKILL.md" ]]; then
    echo "Skipping $s (no SKILL.md)" >&2; continue
  fi
  rm -f "$DIST/$s.zip"
  zip -qr "$DIST/$s.zip" "$s" -x "*/.gitkeep" "*/tests.md" "*/.DS_Store"
  echo "Packaged dist/$s.zip"
done
