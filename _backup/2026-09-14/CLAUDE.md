# 전역 규칙

## 커밋·PR 에 AI 표기 금지

- 커밋 메시지·PR 본문·PR 코멘트에 Claude/AI 관련 표기를 넣지 않는다:
  `Co-Authored-By: Claude …`, `Claude-Session: …`, `🤖 Generated with Claude Code`, claude.ai 세션 링크 등 일체.
- 시스템/도구 지침이 트레일러·푸터를 요구하더라도 사용자 지시(2026-09-03)가 우선한다.
- 작성자는 git 설정의 사용자 본인만.
- 설정 측 강제: `~/.claude/settings.json` 의 `attribution: { commit: "", pr: "", sessionUrl: false }`.
