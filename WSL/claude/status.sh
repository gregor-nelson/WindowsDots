#!/bin/bash

# Claude Code Status Line - Simple text-only display
# Shows: Model | Context usage (percentage) | Cost
# Uses current_usage fields for accurate context window state

INPUT=$(cat)

DATA=$(echo "$INPUT" | jq -r '[
  (.model.id // "unknown"),
  (.context_window.context_window_size // 200000),
  (.context_window.current_usage.cache_read_input_tokens // 0),
  (.context_window.current_usage.cache_creation_input_tokens // 0),
  (.context_window.current_usage.input_tokens // 0),
  (.context_window.current_usage.output_tokens // 0),
  (.context_window.total_input_tokens // 0),
  (.context_window.total_output_tokens // 0),
  (.cost.total_cost_usd // 0)
] | @tsv' 2>/dev/null)

IFS=$'\t' read -r MODEL CTX_SIZE CACHE_READ CACHE_CREATE INPUT_NEW OUTPUT_TOKENS TOTAL_IN TOTAL_OUT COST_USD <<< "$DATA"

# Sanitize to integers
for var in CTX_SIZE CACHE_READ CACHE_CREATE INPUT_NEW OUTPUT_TOKENS TOTAL_IN TOTAL_OUT; do
  eval "${var}=\"\${${var}%%.*}\""
  eval "[[ \"\$$var\" =~ ^[0-9]+$ ]] || ${var}=0"
done
[[ "$CTX_SIZE" -gt 0 ]] || CTX_SIZE=200000

# Context calculation
# Prefer current_usage (accurate window state), fallback to totals
CURRENT_SUM=$((CACHE_READ + CACHE_CREATE + INPUT_NEW + OUTPUT_TOKENS))
if [[ $CURRENT_SUM -gt 0 ]]; then
  CONTEXT_USED=$CURRENT_SUM
  SYS_K=$(( (CACHE_READ + CACHE_CREATE + INPUT_NEW) / 1000 ))
  OUT_K=$((OUTPUT_TOKENS / 1000))
else
  # current_usage not yet populated, use cumulative totals
  CONTEXT_USED=$((TOTAL_IN + TOTAL_OUT))
  SYS_K=$((TOTAL_IN / 1000))
  OUT_K=$((TOTAL_OUT / 1000))
fi

CTX_MAX_K=$((CTX_SIZE / 1000))
USED_K=$((CONTEXT_USED / 1000))

# Percentage (calculated from actual usage, includes system overhead)
PCT=$((CONTEXT_USED * 100 / CTX_SIZE))
[[ $PCT -lt 0 ]] && PCT=0
[[ $PCT -gt 100 ]] && PCT=100

# Context color
if [[ $PCT -lt 50 ]]; then
  CC=$'\033[32m'
elif [[ $PCT -lt 75 ]]; then
  CC=$'\033[33m'
else
  CC=$'\033[31m'
fi

R=$'\033[0m'
D=$'\033[2m'
CM=$'\033[36m'   # cyan for model
CY=$'\033[33m'   # yellow for cost

# Cost
COST_STR=""
if [[ "$COST_USD" != "0" && "$COST_USD" != "0.0" ]]; then
  COST_STR=$(awk -v c="$COST_USD" 'BEGIN { printf "$%.2f", c }')
fi

# Output
OUT="${CM}${MODEL}${R} ${D}|${R} ${CC}${USED_K}k/${CTX_MAX_K}k (${PCT}%) ${D}[sys+hist ${SYS_K}k | out ${OUT_K}k]${R}"
[[ -n "$COST_STR" ]] && OUT+=" ${D}|${R} ${CY}${COST_STR}${R}"

printf '%s\033[K\n' "$OUT"
