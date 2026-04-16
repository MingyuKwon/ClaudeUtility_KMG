#!/usr/bin/env bash
# ClaudeUtility 루트 설치 스크립트
# 모든 서브폴더의 install.sh를 순서대로 실행합니다

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo " ClaudeUtility installer"
echo " Root: $REPO_DIR"
echo "=========================================="
echo ""

success=0
fail=0

for dir in "$REPO_DIR"/*/; do
  name="$(basename "$dir")"
  installer="$dir/install.sh"

  if [ ! -f "$installer" ]; then
    echo "  [skip] $name  (install.sh 없음)"
    continue
  fi

  echo "  [installing] $name ..."
  if UTIL_DIR="$dir" bash "$installer"; then
    echo "  [ok] $name"
    ((success++))
  else
    echo "  [fail] $name"
    ((fail++))
  fi
  echo ""
done

echo "=========================================="
echo " 완료: ${success}개 성공 / ${fail}개 실패"
echo "=========================================="
