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

# 슬래시 커맨드 등록 (template → ~/.claude/commands/)
TOGGLE_PATH="$UTIL_DIR/toggle.sh"
COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"

for template in "$UTIL_DIR/commands/"*.md.template; do
  filename="$(basename "${template%.template}")"
  output="$COMMANDS_DIR/$filename"
  sed "s|{{TOGGLE_PATH}}|$TOGGLE_PATH|g" "$template" > "$output"
  echo "  커맨드 등록 완료: /$( basename "${filename%.md}" )"
done
