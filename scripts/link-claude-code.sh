#!/usr/bin/env bash
# Symlink every skill into ~/.claude/skills so Claude Code picks up edits immediately.
# Usage: ./scripts/link-claude-code.sh [target-dir]   (default: ~/.claude/skills)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-$HOME/.claude/skills}"
mkdir -p "$TARGET"

for d in "$ROOT"/skills/*/; do
  [[ -d "$d" ]] || continue
  s="$(basename "$d")"
  link="$TARGET/$s"
  if [[ -L "$link" ]]; then
    ln -sfn "$ROOT/skills/$s" "$link"; echo "Updated $link"
  elif [[ -e "$link" ]]; then
    echo "Skipping $s: $link exists and isn't a symlink" >&2
  else
    ln -s "$ROOT/skills/$s" "$link"; echo "Linked $link"
  fi
done
