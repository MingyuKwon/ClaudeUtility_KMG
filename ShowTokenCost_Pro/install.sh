#!/usr/bin/env bash
# ShowTokenCost_Pro 설치 스크립트
# ~/.claude/settings.json 의 statusLine 항목을 등록/업데이트합니다

UTIL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$UTIL_DIR/statusline.sh"
SETTINGS="$HOME/.claude/settings.json"

# settings.json 없으면 빈 파일 생성
if [ ! -f "$SETTINGS" ]; then
  mkdir -p "$(dirname "$SETTINGS")"
  echo "{}" > "$SETTINGS"
fi

# python으로 JSON 수정 (bash만으로 JSON 편집은 불안정)
PYTHON=""
if command -v python3 &>/dev/null && python3 -c "" 2>/dev/null; then
  PYTHON="python3"
elif command -v python &>/dev/null && python -c "" 2>/dev/null; then
  PYTHON="python"
fi

if [ -z "$PYTHON" ]; then
  echo "  ERROR: Python을 찾을 수 없습니다"
  exit 1
fi

$PYTHON - "$SETTINGS" "$SCRIPT_PATH" <<'EOF'
import sys, json

settings_path = sys.argv[1]
script_path   = sys.argv[2]

with open(settings_path, 'r', encoding='utf-8') as f:
  data = json.load(f)

data['statusLine'] = {
  'type': 'command',
  'command': f"bash '{script_path}'"
}

with open(settings_path, 'w', encoding='utf-8') as f:
  json.dump(data, f, indent=2, ensure_ascii=False)

print(f"  statusLine 등록 완료: {script_path}")
EOF
