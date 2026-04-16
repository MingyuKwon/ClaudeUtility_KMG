# ClaudeUtility

Claude Code를 더 편리하게 사용하기 위한 유틸리티 모음입니다.

## 설치

```bash
git clone https://github.com/your-id/ClaudeUtility.git
cd ClaudeUtility
bash install.sh
```

이후 Claude Code를 재시작하면 적용됩니다.

## 유틸리티 목록

| 폴더 | 설명 |
|---|---|
| `ShowTokenCost_Pro` | Claude Code 하단 상태줄에 rate limit / 리셋 시간 표시 |

## 구조

각 서브폴더는 독립적인 유틸리티이며, 루트 `install.sh`가 각 폴더의 `install.sh`를 자동으로 실행합니다.

새 유틸리티를 추가하려면 서브폴더를 만들고 `install.sh`를 작성하면 됩니다.
