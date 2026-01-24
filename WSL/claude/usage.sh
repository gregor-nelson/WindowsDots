#!/bin/bash

# Claude Code Monthly Usage Calculator
# Parses transcript files to calculate notional API costs

# Colors
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
MAGENTA="\033[35m"
DIM="\033[2m"
BOLD="\033[1m"
RESET="\033[0m"

# Pricing per 1M tokens (as of 2025)
# Opus: $15 input, $75 output
# Sonnet: $3 input, $15 output
OPUS_INPUT_RATE=15
OPUS_OUTPUT_RATE=75
SONNET_INPUT_RATE=3
SONNET_OUTPUT_RATE=15

CLAUDE_DIR="$HOME/.claude/projects"

# Parse arguments
MONTH_FILTER=$(date +%Y-%m)
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--month)
      MONTH_FILTER="$2"
      shift 2
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -h|--help)
      echo "Usage: claude-usage [-m YYYY-MM] [-v]"
      echo ""
      echo "Options:"
      echo "  -m, --month YYYY-MM   Filter by month (default: current month)"
      echo "  -v, --verbose         Show per-session breakdown"
      echo "  -h, --help            Show this help"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

# Find all JSONL files
TOTAL_INPUT=0
TOTAL_OUTPUT=0
TOTAL_CACHE_READ=0
TOTAL_CACHE_CREATE=0
TOTAL_COST=0
SESSION_COUNT=0

echo -e "${BOLD}Claude Code Usage Report${RESET}"
echo -e "${DIM}Month: ${MONTH_FILTER}${RESET}"
echo ""

if $VERBOSE; then
  echo -e "${DIM}Sessions:${RESET}"
fi

while IFS= read -r -d '' file; do
  # Get file modification date
  FILE_DATE=$(date -r "$file" +%Y-%m 2>/dev/null)

  # Skip if not matching month
  [[ "$FILE_DATE" != "$MONTH_FILTER" ]] && continue

  # Extract session ID from filename
  SESSION_ID=$(basename "$file" .jsonl)

  # Get model and token usage from file
  USAGE=$(jq -s '[.[].message.usage // empty] | {
      input: [.[].input_tokens // 0] | add,
      output: [.[].output_tokens // 0] | add,
      cache_read: [.[].cache_read_input_tokens // 0] | add,
      cache_create: [.[].cache_creation_input_tokens // 0] | add
    }' "$file" 2>/dev/null)

  [[ -z "$USAGE" || "$USAGE" == "null" ]] && continue

  INPUT=$(echo "$USAGE" | jq -r '.input // 0')
  OUTPUT=$(echo "$USAGE" | jq -r '.output // 0')
  CACHE_READ=$(echo "$USAGE" | jq -r '.cache_read // 0')
  CACHE_CREATE=$(echo "$USAGE" | jq -r '.cache_create // 0')

  # Skip empty sessions
  [[ "$INPUT" == "0" && "$OUTPUT" == "0" ]] && continue

  # Detect model from file (default to opus pricing for conservative estimate)
  if grep -q "claude-sonnet\|claude-3-5-sonnet" "$file" 2>/dev/null; then
    INPUT_RATE=$SONNET_INPUT_RATE
    OUTPUT_RATE=$SONNET_OUTPUT_RATE
    MODEL="sonnet"
  else
    INPUT_RATE=$OPUS_INPUT_RATE
    OUTPUT_RATE=$OPUS_OUTPUT_RATE
    MODEL="opus"
  fi

  # Calculate session cost (cache reads are 90% cheaper, cache writes are 25% more)
  # Effective input = regular input + (cache_read * 0.1) + (cache_create * 1.25)
  EFFECTIVE_INPUT=$(awk "BEGIN {print $INPUT + ($CACHE_READ * 0.1) + ($CACHE_CREATE * 1.25)}")
  SESSION_COST=$(awk "BEGIN {printf \"%.4f\", ($EFFECTIVE_INPUT * $INPUT_RATE / 1000000) + ($OUTPUT * $OUTPUT_RATE / 1000000)}")

  ((SESSION_COUNT++))
  TOTAL_INPUT=$((TOTAL_INPUT + INPUT))
  TOTAL_OUTPUT=$((TOTAL_OUTPUT + OUTPUT))
  TOTAL_CACHE_READ=$((TOTAL_CACHE_READ + CACHE_READ))
  TOTAL_CACHE_CREATE=$((TOTAL_CACHE_CREATE + CACHE_CREATE))
  TOTAL_COST=$(awk "BEGIN {print $TOTAL_COST + $SESSION_COST}")

  if $VERBOSE; then
    SHORT_ID="${SESSION_ID:0:8}"
    echo -e "  ${DIM}${SHORT_ID}${RESET} ${MODEL} \$${SESSION_COST}"
  fi

done < <(find "$CLAUDE_DIR" -name "*.jsonl" -print0 2>/dev/null)

# Format totals (show k for thousands, M for millions)
format_tokens() {
  local tokens=$1
  if [[ $tokens -ge 1000000 ]]; then
    awk "BEGIN {printf \"%.1fM\", $tokens/1000000}"
  elif [[ $tokens -ge 1000 ]]; then
    awk "BEGIN {printf \"%.1fk\", $tokens/1000}"
  else
    echo "$tokens"
  fi
}

INPUT_FMT=$(format_tokens $TOTAL_INPUT)
OUTPUT_FMT=$(format_tokens $TOTAL_OUTPUT)
CACHE_READ_FMT=$(format_tokens $TOTAL_CACHE_READ)
CACHE_CREATE_FMT=$(format_tokens $TOTAL_CACHE_CREATE)

echo ""
echo -e "${BOLD}Summary${RESET}"
echo -e "  Sessions:      ${CYAN}${SESSION_COUNT}${RESET}"
echo -e "  Input tokens:  ${GREEN}${INPUT_FMT}${RESET} ${DIM}(+${CACHE_CREATE_FMT} cache write, ${CACHE_READ_FMT} cache read)${RESET}"
echo -e "  Output tokens: ${GREEN}${OUTPUT_FMT}${RESET}"
echo ""
echo -e "  ${BOLD}${YELLOW}Notional cost: \$$(printf "%.2f" "$TOTAL_COST")${RESET}"
echo -e "  ${DIM}(What you'd pay at API rates)${RESET}"

