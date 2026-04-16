#!/usr/bin/env bash
input=$(cat)
echo "$input" > /tmp/statusline_debug.json

PYTHON=""
if command -v python3 &>/dev/null && python3 -c "" 2>/dev/null; then
  PYTHON="python3"
elif command -v python &>/dev/null && python -c "" 2>/dev/null; then
  PYTHON="python"
fi

if [ -z "$PYTHON" ]; then
  echo "no python"
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR_WIN="$(cygpath -w "$SCRIPT_DIR" 2>/dev/null || echo "$SCRIPT_DIR")"

echo "$input" | $PYTHON -c "
import sys, json, os
sys.stdout.reconfigure(encoding='utf-8')

CACHE_FILE = r'$SCRIPT_DIR_WIN\rate_cache.json'

RESET  = '\033[0m'
GRAY   = '\033[90m'
GREEN  = '\033[32m'
YELLOW = '\033[33m'
RED    = '\033[91m'
WHITE  = '\033[97m'
DIM    = '\033[2m'

def color(pct, cached=False):
    if pct == '?' or pct is None:
        return GRAY
    p = int(pct)
    if cached:
        return DIM + (RED if p >= 80 else YELLOW if p >= 50 else GREEN)
    if p >= 80: return RED
    if p >= 50: return YELLOW
    return GREEN

def bar(pct):
    if pct == '?' or pct is None:
        return '-----'
    filled = round(int(pct) / 100 * 5)
    return '#' * filled + '-' * (5 - filled)

from datetime import datetime, timezone

data = json.load(sys.stdin)
rl        = data.get('rate_limits', {})
five_hour_raw = rl.get('five_hour', {}).get('used_percentage')
seven_day_raw = rl.get('seven_day', {}).get('used_percentage')
five_hour = int(five_hour_raw) if five_hour_raw is not None else None
seven_day = int(seven_day_raw) if seven_day_raw is not None else None
fh_reset  = rl.get('five_hour', {}).get('resets_at')
sd_reset  = rl.get('seven_day', {}).get('resets_at')

cached = False

# 유효한 값이 있으면 캐시에 저장
if five_hour is not None and seven_day is not None:
    try:
        with open(CACHE_FILE, 'w') as f:
            json.dump({
                'five_hour': five_hour, 'seven_day': seven_day,
                'fh_reset': fh_reset, 'sd_reset': sd_reset
            }, f)
    except Exception:
        pass
else:
    # 캐시에서 읽기
    try:
        with open(CACHE_FILE) as f:
            cache = json.load(f)
        fh_raw = cache.get('five_hour')
        sd_raw = cache.get('seven_day')
        five_hour = int(fh_raw) if fh_raw is not None else '?'
        seven_day = int(sd_raw) if sd_raw is not None else '?'
        fh_reset  = cache.get('fh_reset')
        sd_reset  = cache.get('sd_reset')
        cached = True
    except Exception:
        five_hour = '?'
        seven_day = '?'

def reset_time(ts):
    if not ts:
        return ''
    return datetime.fromtimestamp(ts, tz=timezone.utc).astimezone().strftime('%H:%M')

def reset_date(ts):
    if not ts:
        return ''
    return datetime.fromtimestamp(ts, tz=timezone.utc).astimezone().strftime('%m/%d')

def block(title, pct, reset_label, reset_str, cached=False):
    c = color(pct, cached)
    reset_part = f'{GRAY} {reset_label} {reset_str}{RESET}' if reset_str else ''
    cached_mark = f'{GRAY}~{RESET}' if cached else ''
    return (
        f'{GRAY}[{RESET} '
        f'{WHITE}{title}{RESET} '
        f'{c}{bar(pct)} {pct}%{RESET}{cached_mark}'
        f'{reset_part}'
        f' {GRAY}]{RESET}'
    )

parts = [
    block('5h Rate', five_hour, 'reset', reset_time(fh_reset), cached),
    block('7d Rate', seven_day, 'expire', reset_date(sd_reset), cached),
]
print('  '.join(parts))
"
