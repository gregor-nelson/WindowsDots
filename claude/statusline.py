import sys, json

sys.stdout.reconfigure(encoding="utf-8")

try:
    d = json.load(sys.stdin)
except Exception:
    print("? no data")
    sys.exit(0)

# context window data (piped directly by Claude Code)
ctx = d.get("context_window") or {}
usage = ctx.get("current_usage") or {}
pct = min(max(int(ctx.get("used_percentage") or 0), 0), 100)
window = ctx.get("context_window_size") or 200000

# input tokens only — this is what fills the context window and what
# used_percentage is derived from.  output tokens are NOT counted.
inp = usage.get("input_tokens", 0)
cr = usage.get("cache_read_input_tokens", 0)
cc = usage.get("cache_creation_input_tokens", 0)
used = inp + cr + cc

# model & workspace
model = (d.get("model") or {}).get("display_name", "?")
cwd = (d.get("workspace") or {}).get("current_dir", d.get("cwd", ""))
parts = cwd.replace("\\", "/").split("/")
folder = parts[-1] if parts else cwd

# cost
cost = (d.get("cost") or {}).get("total_cost_usd") or 0

# colors
R, G, Y, DIM, B, RST = "\033[31m", "\033[32m", "\033[33m", "\033[2m", "\033[1m", "\033[0m"
color = G if pct < 50 else Y if pct < 80 else R

# visual bar: 15 segments, clamped
filled = min(pct * 15 // 100, 15)
bar = f"{color}{B}{'█' * filled}{DIM}{'░' * (15 - filled)}{RST}"

fmt = lambda n: f"{n/1000:.1f}k" if n >= 1000 else str(n)
wfmt = lambda n: f"{n // 1_000_000}M" if n >= 1_000_000 else f"{n // 1000}k"

print(
    f"\uf07b  {folder}"
    f"  {DIM}|{RST}  {model}"
    f"  {DIM}|{RST}  {bar}  {color}{B}{fmt(used)}{RST} {DIM}/{RST} {wfmt(window)}  {color}({pct}%){RST}"
    f"  {DIM}|{RST}  ${cost:.4f}"
)
