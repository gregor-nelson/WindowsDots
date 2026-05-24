#!/usr/bin/env bash
# Composes the python statusline with the kotlin-loc segment.

set -u

input=$(cat)

main_out=$(printf '%s' "$input" | python3 ~/.claude/statusline.py 2>/dev/null)
kt_out=$(bash ~/.claude/kotlin-loc.sh 2>/dev/null)

if [[ -z "$main_out" && -z "$kt_out" ]]; then
  echo '? no data'
  exit 0
fi

main_out=${main_out%$'\n'}
printf '%s  %s\n' "$main_out" "$kt_out"
