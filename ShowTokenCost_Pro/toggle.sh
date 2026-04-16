#!/usr/bin/env bash
# statusLine 켜고 끄기
# 사용법: bash toggle.sh on | off

UTIL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$UTIL_DIR/statusline.sh"
SETTINGS="$HOME/.claude/settings.json"
ACTION="${1:-}"

if [ -z "$ACTION" ]; then
  echo "사용법: bash toggle.sh on | off"
  exit 1
fi

PYTHON=""
if command -v python3 &>/dev/null && python3 -c "" 2>/dev/null; then
  PYTHON="python3"
elif command -v python &>/dev/null && python -c "" 2>/dev/null; then
  PYTHON="python"
else
  echo "ERROR: Python을 찾을 수 없습니다"
  exit 1
fi

$PYTHON - "$SETTINGS" "$SCRIPT_PATH" "$ACTION" <<'EOF'
import sys, json

settings_path = sys.argv[1]
script_path   = sys.argv[2]
action        = sys.argv[3]

with open(settings_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

if action == 'on':
    data['statusLine'] = {
        'type': 'command',
        'command': f"bash '{script_path}'"
    }
    print("statusLine 활성화")
elif action == 'off':
    data.pop('statusLine', None)
    print("statusLine 비활성화")

with open(settings_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
EOF
