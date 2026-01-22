#!/bin/bash

# Claude Code Status Line - Comprehensive status display
# Features: Model, Context, Cost, Lines Changed, Duration, Project
# Optimized: Single jq call for all data extraction

# ═══════════════════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════════════════
DEBUG=false  # Set to true to log raw JSON to /tmp/claude-status-debug.json

# ═══════════════════════════════════════════════════════════
# Read input once
# ═══════════════════════════════════════════════════════════
INPUT=$(cat)

# Debug: Log raw JSON to diagnose issues
if $DEBUG; then
  echo "$INPUT" > /tmp/claude-status-debug.json
fi

# ═══════════════════════════════════════════════════════════
# Nerd Font Icons
# ═══════════════════════════════════════════════════════════
ICON_MODEL="󰧑"       # Robot face
ICON_CONTEXT="󱔗"      # Memory chip
ICON_COST="󰄬"        # Dollar sign
ICON_LINES_ADD=""   # Plus
ICON_LINES_DEL=""   # Minus
ICON_TIME="󰅐"        # Clock
ICON_DIR=""         # Folder
ICON_SEP="│"         # Separator

# ═══════════════════════════════════════════════════════════
# Colors (ANSI)
# ═══════════════════════════════════════════════════════════
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
MAGENTA="\033[35m"
BLUE="\033[34m"
DIM="\033[2m"
BOLD="\033[1m"
RESET="\033[0m"

# ═══════════════════════════════════════════════════════════
# Extract ALL data in a single jq call (performance)
# ═══════════════════════════════════════════════════════════
IFS=$'\t' read -r MODEL_ID MODEL_DISPLAY INPUT_TOKENS OUTPUT_TOKENS CTX_SIZE \
       COST_USD DURATION_MS LINES_ADD LINES_DEL CWD < <(
  echo "$INPUT" | jq -r '[
    (.model.id // ""),
    (.model.display_name // ""),
    (.context_window.total_input_tokens // 0),
    (.context_window.total_output_tokens // 0),
    (.context_window.context_window_size // 200000),
    (.cost.total_cost_usd // 0),
    (.cost.total_duration_ms // 0),
    (.cost.total_lines_added // 0),
    (.cost.total_lines_removed // 0),
    (.workspace.current_dir // .cwd // "")
  ] | @tsv'
)

# ═══════════════════════════════════════════════════════════
# Process Model Name
# Prefer full ID, fallback to display name
# ═══════════════════════════════════════════════════════════
if [[ -n "$MODEL_ID" && "$MODEL_ID" != "null" ]]; then
  MODEL="$MODEL_ID"
elif [[ -n "$MODEL_DISPLAY" && "$MODEL_DISPLAY" != "null" ]]; then
  MODEL="$MODEL_DISPLAY"
else
  MODEL="unknown"
fi

# ═══════════════════════════════════════════════════════════
# Process Context Window
# ═══════════════════════════════════════════════════════════
INPUT_TOKENS=${INPUT_TOKENS:-0}
OUTPUT_TOKENS=${OUTPUT_TOKENS:-0}
CTX_SIZE=${CTX_SIZE:-200000}

[[ "$INPUT_TOKENS" == "null" ]] && INPUT_TOKENS=0
[[ "$OUTPUT_TOKENS" == "null" ]] && OUTPUT_TOKENS=0
[[ "$CTX_SIZE" == "null" ]] && CTX_SIZE=200000

TOTAL_TOKENS=$((INPUT_TOKENS + OUTPUT_TOKENS))
INPUT_K=$((INPUT_TOKENS / 1000))
OUTPUT_K=$((OUTPUT_TOKENS / 1000))
CTX_MAX_K=$((CTX_SIZE / 1000))

if [[ $CTX_SIZE -gt 0 ]]; then
  PERCENT=$((INPUT_TOKENS * 100 / CTX_SIZE))
else
  PERCENT=0
fi

# Context color based on usage
if [[ $PERCENT -lt 50 ]]; then
  CTX_COLOR="$GREEN"
elif [[ $PERCENT -lt 75 ]]; then
  CTX_COLOR="$YELLOW"
else
  CTX_COLOR="$RED"
fi

# ═══════════════════════════════════════════════════════════
# Process Cost
# ═══════════════════════════════════════════════════════════
COST_USD=${COST_USD:-0}
[[ "$COST_USD" == "null" ]] && COST_USD=0

# Format cost (show cents if < $1, otherwise dollars)
if (( $(echo "$COST_USD < 0.01" | bc -l 2>/dev/null || echo 0) )); then
  COST_FMT="<1¢"
elif (( $(echo "$COST_USD < 1" | bc -l 2>/dev/null || echo 0) )); then
  CENTS=$(echo "$COST_USD * 100" | bc -l 2>/dev/null | cut -d. -f1)
  COST_FMT="${CENTS}¢"
else
  COST_FMT="\$$(printf "%.2f" "$COST_USD" 2>/dev/null || echo "$COST_USD")"
fi

# ═══════════════════════════════════════════════════════════
# Process Duration
# ═══════════════════════════════════════════════════════════
DURATION_MS=${DURATION_MS:-0}
[[ "$DURATION_MS" == "null" ]] && DURATION_MS=0

DURATION_SEC=$((DURATION_MS / 1000))
if [[ $DURATION_SEC -lt 60 ]]; then
  DURATION_FMT="${DURATION_SEC}s"
elif [[ $DURATION_SEC -lt 3600 ]]; then
  MINS=$((DURATION_SEC / 60))
  SECS=$((DURATION_SEC % 60))
  DURATION_FMT="${MINS}m${SECS}s"
else
  HOURS=$((DURATION_SEC / 3600))
  MINS=$(((DURATION_SEC % 3600) / 60))
  DURATION_FMT="${HOURS}h${MINS}m"
fi

# ═══════════════════════════════════════════════════════════
# Process Lines Changed
# ═══════════════════════════════════════════════════════════
LINES_ADD=${LINES_ADD:-0}
LINES_DEL=${LINES_DEL:-0}
[[ "$LINES_ADD" == "null" ]] && LINES_ADD=0
[[ "$LINES_DEL" == "null" ]] && LINES_DEL=0

# ═══════════════════════════════════════════════════════════
# Process Project Directory (show only folder name)
# ═══════════════════════════════════════════════════════════
if [[ -n "$CWD" && "$CWD" != "null" ]]; then
  PROJECT=$(basename "$CWD")
else
  PROJECT=""
fi

# ═══════════════════════════════════════════════════════════
# Build Progress Bar
# ═══════════════════════════════════════════════════════════
BAR_WIDTH=8
FILLED=$((PERCENT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))

BAR=""
for ((i=0; i<FILLED; i++)); do BAR+="█"; done
for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

# ═══════════════════════════════════════════════════════════
# Build Output
# ═══════════════════════════════════════════════════════════
OUTPUT=""

# Model
OUTPUT+="${CYAN}${ICON_MODEL} ${MODEL}${RESET}"

# Context
OUTPUT+=" ${DIM}${ICON_SEP}${RESET} "
OUTPUT+="${CTX_COLOR}${ICON_CONTEXT} ${INPUT_K}k/${CTX_MAX_K}k ${DIM}${BAR}${RESET}"

# Cost (only show if > 0)
if (( $(echo "$COST_USD > 0" | bc -l 2>/dev/null || echo 0) )); then
  OUTPUT+=" ${DIM}${ICON_SEP}${RESET} "
  OUTPUT+="${YELLOW}${ICON_COST} ${COST_FMT}${RESET}"
fi

# Lines changed (only show if any changes)
if [[ $LINES_ADD -gt 0 || $LINES_DEL -gt 0 ]]; then
  OUTPUT+=" ${DIM}${ICON_SEP}${RESET} "
  OUTPUT+="${GREEN}${ICON_LINES_ADD}${LINES_ADD}${RESET}"
  OUTPUT+="${RED}${ICON_LINES_DEL}${LINES_DEL}${RESET}"
fi

# Duration (only show if > 0)
if [[ $DURATION_SEC -gt 0 ]]; then
  OUTPUT+=" ${DIM}${ICON_SEP}${RESET} "
  OUTPUT+="${MAGENTA}${ICON_TIME} ${DURATION_FMT}${RESET}"
fi

# Project (only show if available)
if [[ -n "$PROJECT" ]]; then
  OUTPUT+=" ${DIM}${ICON_SEP}${RESET} "
  OUTPUT+="${BLUE}${ICON_DIR} ${PROJECT}${RESET}"
fi

echo -e "$OUTPUT"
