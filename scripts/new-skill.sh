#!/usr/bin/env bash
# Create a new skill folder from the template.
# Usage: ./scripts/new-skill.sh <skill-name>
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${1:-}"

if [[ -z "$NAME" ]]; then
  echo "Usage: ./scripts/new-skill.sh <skill-name>   (lowercase letters, numbers, hyphens)" >&2
  exit 1
fi
if [[ ! "$NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || (( ${#NAME} > 64 )); then
  echo "Error: name must be lowercase letters, numbers and hyphens, max 64 chars." >&2
  exit 1
fi

DIR="$ROOT/skills/$NAME"
if [[ -e "$DIR" ]]; then
  echo "Error: skills/$NAME already exists." >&2
  exit 1
fi

# "meeting-notes" -> "Meeting Notes"
TITLE="$(echo "$NAME" | sed -E 's/-/ /g; s/\b(.)/\u\1/g')"

mkdir -p "$DIR"/{references,scripts,assets}
sed -e "s/{{NAME}}/$NAME/g" -e "s/{{TITLE}}/$TITLE/g" \
  "$ROOT/templates/SKILL.template.md" > "$DIR/SKILL.md"
sed -e "s/{{NAME}}/$NAME/g" \
  "$ROOT/templates/tests.template.md" > "$DIR/tests.md"
touch "$DIR/references/.gitkeep" "$DIR/scripts/.gitkeep" "$DIR/assets/.gitkeep"

echo "Created skills/$NAME/"
echo "Next: edit skills/$NAME/SKILL.md (start with the description) and add a row to README.md."
