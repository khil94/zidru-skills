# ~/.agents — Claude Code · Codex 공용 원본

스킬과 전역 지침의 원본은 여기 한 곳에만 둔다. 두 도구는 링크와 import 로 이 파일들을 읽는다.

## 구조

```
~/.agents/
  AGENTS.md                ← 전역 지침 원본
  link-skills.ps1          ← 스킬 junction 동기화 스크립트
  skills/<name>/SKILL.md   ← 스킬 원본
  _backup/                 ← 통합 이전 상태 백업

~/.claude/CLAUDE.md        실제 파일. 첫 줄 @~/.agents/AGENTS.md + Claude 전용 내용
~/.claude/skills/<name>    junction → ~/.agents/skills/<name>   (learned 는 Claude 전용 실제 폴더)
~/.codex/AGENTS.md         symlink  → ~/.agents/AGENTS.md
~/.codex/skills/<name>     junction → ~/.agents/skills/<name>   (.system 은 Codex 번들, 건드리지 않음)
```

## 스킬

- **직접 만들 때**: `~/.agents/skills/<name>/SKILL.md` 를 작성하고 스크립트를 실행한다. 여러 번 실행해도 안전하다.
  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File ~\.agents\link-skills.ps1
  ```
- **외부 스킬 설치**: `npx skills add <owner/repo> -g -a claude-code -a codex`
- **외부 스킬 업데이트**: `npx skills update -g`
- **링크 삭제**: junction 은 `cmd /c rmdir <경로>` 로만 지운다. PowerShell 5.1 의 `Remove-Item -Recurse` 는 원본 내용까지 지울 수 있다.
- **호환 주의**: 스킬 본문이 Claude 전용 도구명(Agent, AskUserQuestion 등)이나 `allowed-tools` 에 기대면 Codex 에서는 그대로 동작하지 않는다. Codex 표시 이름은 스킬 폴더의 `agents/openai.yaml` 로 준다.

## 전역 지침

- 두 도구 공통 규칙은 `~/.agents/AGENTS.md` 에 직접 쓴다.
- Claude 의 `/memory` 나 `#` 은 얇은 `~/.claude/CLAUDE.md` 에 쓰므로 공통 규칙용으로 쓰지 않는다.
- Claude 는 전역 `CLAUDE.md` 자체가 링크면 일부 세션에서 건너뛴다. 그래서 링크 대신 import 를 쓴다.
- Codex 링크를 다시 만들어야 하면 `mklink` 를 쓴다. PowerShell 5.1 의 `New-Item -ItemType SymbolicLink` 는 개발자 모드여도 관리자 권한을 요구한다.
  ```powershell
  cmd /c mklink "%USERPROFILE%\.codex\AGENTS.md" "%USERPROFILE%\.agents\AGENTS.md"
  ```
- Orca 로 띄운 Codex 는 홈이 `%APPDATA%\orca\codex-runtime-home\home` 으로 바뀐다. 그 폴더가 `skills` 와 `AGENTS.md` 를 `~/.codex` 로 링크하므로 따로 할 일은 없다. 다만 `~/.codex/AGENTS.md` 를 새로 만들면 Orca 쪽 링크는 조금 늦게 생긴다.
- Codex 가 실제로 무엇을 읽는지는 모델 호출 없이 확인할 수 있다.
  ```powershell
  codex debug prompt-input "hi"
  ```

## 프로젝트(레포) 규약

레포에서도 같은 방식으로 원본을 하나로 둔다. 링크를 쓰지 않으니 다른 PC와 팀원에게도 그대로 동작한다.

```
repo/
  AGENTS.md    ← 원본. Codex 가 읽는다.
  CLAUDE.md    ← 첫 줄 @AGENTS.md, 아래에 Claude 전용 내용만
```
