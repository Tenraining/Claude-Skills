#!/usr/bin/env bash
# Link every skill into ~/.claude/skills so Claude Code picks up edits immediately.
# Uses symlinks on macOS/Linux and directory junctions on Windows (no admin rights needed).
# Never copies: if a link can't be made, the skill is skipped and reported.
# Usage: ./scripts/link-claude-code.sh [target-dir]   (default: ~/.claude/skills)
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-$HOME/.claude/skills}"
errors=0

# Show paths relative to the repo or home folder, so output never prints the full local path.
show() {
  local p="$1"
  p="${p/#"$ROOT"/.}"
  p="${p/#"$HOME"/\~}"
  echo "$p"
}

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) WINDOWS=1 ;;
  *) WINDOWS=0 ;;
esac

# Git Bash's ln -s copies folders instead of linking them, so Windows uses junctions.
# Paths go through env vars so spaces and special characters need no extra quoting.
make_link() {
  if (( WINDOWS )); then
    SRC="$(cygpath -w "$1")" LINK="$(cygpath -w "$2")" powershell.exe -NoProfile -NonInteractive -Command \
      'New-Item -ItemType Junction -Path $env:LINK -Target $env:SRC -ErrorAction Stop | Out-Null' >/dev/null 2>&1
  else
    ln -s "$1" "$2" 2>/dev/null
  fi
}

# Removes only the link, never the skill folder it points to.
# The non-recursive delete refuses to touch a real, non-empty folder.
remove_link() {
  if (( WINDOWS )); then
    LINK="$(cygpath -w "$1")" powershell.exe -NoProfile -NonInteractive -Command \
      '[System.IO.Directory]::Delete($env:LINK)' >/dev/null 2>&1
  else
    rm "$1"
  fi
}

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

for d in "$ROOT"/skills/*/; do
  [[ -d "$d" ]] || continue
  s="$(basename "$d")"
  src="$ROOT/skills/$s"
  link="$TARGET/$s"

  if [[ -L "$link" ]]; then
    if [[ "$(readlink "$link")" == "$src" ]]; then
      echo "✓ $s: already linked"; continue
    fi
    remove_link "$link"
    action="Updated"
  elif [[ -e "$link" ]]; then
    echo "! $s: skipped, $(show "$link") exists and isn't a link" >&2; continue
  else
    action="Linked"
  fi

  if make_link "$src" "$link" && [[ -L "$link" ]]; then
    echo "✓ $s: $action"
  else
    echo "✗ $s: couldn't create a link at $(show "$link")" >&2; ((errors++))
  fi
done

# Links left behind by skills that were deleted or renamed in this repo.
for link in "$TARGET"/*; do
  [[ -L "$link" && ! -e "$link" ]] || continue
  case "$(readlink "$link")" in
    "$ROOT"/skills/*) echo "! $(basename "$link"): skill no longer exists; remove the link with: rm $(show "$link")" ;;
  esac
done

(( errors == 0 ))
