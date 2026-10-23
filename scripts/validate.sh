#!/usr/bin/env bash
# Check each skill's SKILL.md frontmatter.
# Usage: ./scripts/validate.sh
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
errors=0
warnings=0

for dir in "$ROOT"/skills/*/; do
  [[ -d "$dir" ]] || continue
  skill="$(basename "$dir")"
  file="$dir/SKILL.md"

  if [[ ! -f "$file" ]]; then
    echo "✗ $skill: missing SKILL.md"; ((errors++)); continue
  fi
  if [[ "$(head -n1 "$file")" != "---" ]]; then
    echo "✗ $skill: SKILL.md must start with '---' frontmatter"; ((errors++)); continue
  fi

  front="$(awk 'NR==1{next} /^---$/{exit} {print}' "$file")"
  name="$(echo "$front" | sed -n 's/^name:[[:space:]]*//p' | head -n1)"
  desc="$(echo "$front" | sed -n 's/^description:[[:space:]]*//p' | head -n1)"

  if [[ -z "$name" ]]; then
    echo "✗ $skill: missing 'name'"; ((errors++))
  elif [[ "$name" != "$skill" ]]; then
    echo "✗ $skill: name '$name' doesn't match folder name"; ((errors++))
  elif [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || (( ${#name} > 64 )); then
    echo "✗ $skill: name must be lowercase/numbers/hyphens, max 64 chars"; ((errors++))
  fi

  if [[ -z "$desc" ]]; then
    echo "✗ $skill: missing 'description'"; ((errors++))
  elif (( ${#desc} > 1024 )); then
    echo "✗ $skill: description is ${#desc} chars (max 1024)"; ((errors++))
  elif [[ "$desc" == TODO* ]]; then
    echo "! $skill: description is still a TODO"; ((warnings++))
  else
    echo "✓ $skill"
  fi
done

echo
echo "$errors error(s), $warnings warning(s)"
(( errors == 0 ))
