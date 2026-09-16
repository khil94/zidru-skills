---
name: test-this
description: Use when a feature, bug fix, behavior change, or current branch needs verification before completion or PR, especially for requests like "뭘 확인해야 해?", "QA 항목 뽑아줘", "이 기능 검증해줘", or "회귀 테스트 뭐 해야 해?"
---

---

# Test this

## Overview

현재 코드 변경이 어떤 동작을 바꾸는지 파악하고, 그 동작이 올바르다고 판단하기 위해 필요한 검증 항목을 만든다.

**Core principle: 구현을 보고 안심하지 말고, 관찰 가능한 증거를 기준으로 검증한다.**

이 스킬의 기본 동작은 **read-only 분석 + verification plan 작성**이다.

사용자가 명시적으로 실행을 요청하지 않았다면 코드를 수정하거나 테스트를 실행하지 않는다.

---

## The Rule

```
검증하지 않은 동작을 "정상 동작한다"고 표현하지 않는다.
```

코드를 읽어서 그럴 것 같다는 판단과 실제 검증 결과를 구분한다.

다음을 동일시하지 않는다.

- 구현되어 있음 ≠ 정상 동작이 확인됨
- 테스트 코드가 있음 ≠ 테스트가 통과함
- lint 통과 ≠ build 성공
- unit test 통과 ≠ 실제 사용자 흐름 정상
- happy path 통과 ≠ feature 전체 검증 완료

검증 전에는 다음과 같이 표현한다.

- "확인해야 한다"
- "이 동작을 기대한다"
- "코드상 이 경로로 보인다"
- "아직 실행 검증되지 않았다"

실제 증거가 있을 때만 다음과 같이 표현한다.

- "테스트가 통과했다"
- "빌드가 성공했다"
- "해당 동작을 확인했다"

---

# Workflow

## 1. Define the Change Scope

먼저 **무엇을 검증할 것인지 정확한 변경 범위**를 결정한다.

사용자가 범위를 지정했다면 그것을 우선한다.

예:

- 특정 기능
- 파일
- commit range
- branch
- PR
- bug fix

범위를 지정하지 않았다면 현재 Git 상태를 조사한다.

확인할 수 있는 항목:

```bash
git status --short
git branch --show-current
git log --oneline --decorate -10
git diff
git diff --cached
```

branch 전체 변경을 확인해야 한다면 upstream 또는 base branch와의 merge-base를 조사한다.

예:

```bash
git merge-base HEAD origin/main
git diff <merge-base>..HEAD
```

저장소에 `main`이 없다는 이유로 임의로 가정하지 않는다.

다음 순서로 가장 타당한 base를 찾는다.

1. 사용자가 지정한 base
2. 현재 branch의 upstream
3. 저장소의 default branch
4. `main`, `master`, `develop` 등 실제 존재하는 후보

**단순히 `HEAD~1`을 feature 전체의 시작점이라고 가정하지 않는다.**

커밋된 변경과 working tree 변경이 모두 있다면 둘을 함께 확인하되 구분해서 이해한다.

---

## 2. Establish Requirements

변경이 무엇을 해야 하는지 파악한다.

우선순위:

1. 사용자가 설명한 요구사항
2. 현재 작업과 연결된 plan/spec 문서
3. 테스트에 표현된 기존 계약
4. 기존 코드의 observable behavior
5. diff에서 추론할 수 있는 의도

명시적인 요구사항이 없는 경우 추론한 내용을 사실처럼 다루지 않는다.

예:

```
명시된 요구사항:
- 저장 후 목록에 즉시 반영되어야 함

코드에서 추론한 동작:
- 중복 클릭을 막으려는 것으로 보임
```

둘을 구분한다.

---

## 3. Inspect the Actual Change

파일 목록이나 commit message만 보고 verification plan을 만들지 않는다.

실제 diff를 읽는다.

필요한 범위에서 관련 코드를 따라간다.

특히 변경된 코드의:

- caller
- callee
- API contract
- UI state
- validation
- persistence
- error handling
- authorization
- asynchronous flow
- shared state
- feature flag
- cache
- migration
- existing tests

를 확인한다.

모든 항목을 기계적으로 조사하지 않는다.

**현재 변경 때문에 observable behavior가 달라질 가능성이 있는 경로만 추적한다.**

---

# 4. Convert Changes Into Behavioral Claims

diff를 파일 단위가 아니라 **검증 가능한 동작 단위**로 변환한다.

예를 들어 다음 변경이 있다고 하자.

```text
SubmitButton.tsx
useCreateOrder.ts
orders.ts
order.test.ts
```

다음을 검증 대상으로 만들지 않는다.

```text
- SubmitButton 확인
- hook 확인
- API 확인
```

대신 observable behavior로 표현한다.

```text
Claim A:
주문 생성 중에는 다시 제출할 수 없다.

Claim B:
주문 생성에 성공하면 상세 화면으로 이동한다.

Claim C:
주문 생성이 실패하면 현재 입력값을 유지하고 오류를 보여준다.
```

좋은 claim은 사용자의 행동이나 시스템의 외부 동작으로 관찰 가능해야 한다.

---

# 5. Find the Risk Surface

모든 변경을 같은 중요도로 취급하지 않는다.

먼저 다음 질문을 한다.

```text
이 변경 때문에 이전에는 가능했던 어떤 일이 깨질 수 있는가?

새로운 분기나 상태가 생겼는가?

입력 또는 출력 계약이 바뀌었는가?

성공 경로 외에 실패 경로가 바뀌었는가?

상태가 저장되거나 다시 읽힐 때 달라지는가?

권한 또는 사용자 종류에 따라 결과가 다른가?

같은 동작을 빠르게 반복하면 문제가 생길 수 있는가?

페이지를 새로고침하거나 다시 진입하면 상태가 유지되는가?
```

특히 다음 변경은 높은 위험도로 본다.

- 새로운 conditional branch
- validation 변경
- API request/response 변경
- DB schema 또는 migration
- authorization 변경
- shared state 변경
- cache invalidation
- async/concurrency
- retry
- optimistic update
- nullable/optional 값 추가
- 기존 public interface 변경
- error handling 변경

실제 diff와 관련 없는 위험을 억지로 추가하지 않는다.

---

# 6. Map Every Important Claim to Evidence

중요한 behavioral claim에는 이를 증명할 방법이 있어야 한다.

가능한 evidence:

### Automated evidence

- unit test
- integration test
- API test
- type check
- build
- lint
- repository-specific validation command

### Manual evidence

- UI interaction
- browser behavior
- 실제 API 요청
- CLI 실행
- database 상태 확인
- refresh / navigation
- 권한이 다른 사용자로 실행

### Inspection evidence

실행 결과가 아니라 구조적 확인이 목적일 때만 사용한다.

예:

- route registration
- migration 존재 여부
- feature flag 연결
- caller coverage

단순 코드 inspection만으로 runtime behavior가 정상이라고 주장하지 않는다.

---

# 7. Reuse the Repository's Existing Verification

새로운 명령을 추측하기 전에 프로젝트가 이미 사용하는 검증 방식을 조사한다.

필요에 따라 확인한다.

```text
package.json
Makefile
justfile
Taskfile
pyproject.toml
Cargo.toml
go.mod
build.gradle
pom.xml
CI configuration
existing test files
README / CONTRIBUTING
```

기존 테스트에서 변경 코드와 가까운 테스트를 찾는다.

가능하면 기존 convention을 그대로 사용한다.

나쁜 예:

```text
npm test를 실행하세요.
```

프로젝트가 실제로 어떤 명령을 쓰는지 확인하지 않은 상태에서는 이 명령을 만들지 않는다.

좋은 예:

```text
package.json의 `test:unit` script가 해당 테스트 suite를 실행하므로:

npm run test:unit -- OrderForm
```

---

# 8. Create Concrete Manual Checks

수동 확인 항목은 반드시 다음 구조를 갖는다.

```text
[행동] → [관찰해야 하는 결과]
```

예:

```text
- [ ] 저장 버튼을 한 번 누른다
      → 저장 성공 후 상세 화면으로 이동하고 저장된 값이 표시된다.

- [ ] 저장 버튼을 빠르게 두 번 누른다
      → 요청이 한 번만 생성되고 처리 중에는 추가 제출할 수 없다.

- [ ] 서버가 500을 반환하게 한 뒤 저장한다
      → 화면에 오류가 표시되고 사용자가 입력한 값은 유지된다.
```

피해야 할 항목:

```text
- [ ] UI 확인
- [ ] API 정상 확인
- [ ] 에러 케이스 확인
- [ ] 데이터 확인
- [ ] 정상 동작 확인
```

사용자가 그대로 따라 할 수 없다면 충분히 구체적이지 않은 것이다.

---

# 9. Prioritize

검증 항목을 무작정 많이 만들지 않는다.

다음 세 단계로 나눈다.

## P0 — Must Verify

이 기능을 완료했다고 말하기 전에 반드시 확인해야 하는 것.

일반적으로:

- 핵심 happy path
- 주요 상태 변화
- 데이터 저장/반영
- 변경된 API contract
- 중요한 failure path
- 변경으로 직접 영향받는 기존 동작

## P1 — Edge / Regression

실제 구현상 위험도가 있는 경우 확인한다.

예:

- empty state
- boundary input
- duplicate action
- refresh
- back navigation
- slow request
- API failure
- stale state
- authorization
- concurrency

## P2 — Nice to Verify

위험도가 낮지만 시간 여유가 있으면 확인할 항목.

P2가 많아지면 생략하는 편을 선호한다.

---

# 10. Recommend Automated Coverage

현재 테스트 구조와 비교해서 중요한 behavioral claim에 자동화된 증거가 없는지 확인한다.

테스트를 추천할 때는:

```text
무엇을 테스트할지
왜 필요한지
어디에 추가하는 것이 자연스러운지
어떤 결과를 assert해야 하는지
```

를 설명한다.

예:

```text
OrderForm 기존 integration test에 추가 추천:

조건:
createOrder가 pending 상태

행동:
submit 버튼 연속 클릭

기대:
createOrder가 한 번만 호출됨
```

"unit test를 추가하세요" 같은 일반론은 쓰지 않는다.

---

# 11. Verification Execution

기본적으로 이 스킬은 **verification plan을 만드는 것**까지 수행한다.

사용자가 다음과 같이 실행까지 요청하면 실제 검증을 수행한다.

```text
검증해줘
실제로 돌려봐
테스트까지 확인해줘
verify it
run the checks
```

이 경우 각 claim에 대해 적절한 명령 또는 동작을 실행한다.

검증 결과를 판단할 때는 반드시:

```text
1. 어떤 claim을 검증하는지 정한다.
2. 그 claim을 증명하는 명령/행동을 정한다.
3. 실제로 실행한다.
4. 전체 결과와 exit status를 확인한다.
5. 결과가 claim을 실제로 증명하는지 판단한다.
6. 그 다음에만 verified로 표시한다.
```

일부 명령만 성공했다고 feature 전체를 verified로 표시하지 않는다.

---

# Output Format

기본 출력은 다음 형식을 사용한다.

```markdown
## 기능 범위

현재 변경이 무엇을 하는지 2~4문장으로 설명한다.

명시적 요구사항과 코드에서 추론한 동작이 다르면 구분한다.

## P0 · 반드시 확인

- [ ] 행동
      → 기대 결과

- [ ] 행동
      → 기대 결과

## P1 · 엣지 / 회귀

- [ ] 행동
      → 기대 결과

## 자동 검증

### 이미 존재

- `command`
  - 검증하는 동작

### 추가 추천

- 대상 테스트
  - 조건
  - 기대 결과

## 특히 위험한 부분

- `path/to/file:line`
  - 왜 이 변경이 위험한지
  - 어떤 검증으로 확인할지

## 아직 확인할 수 없는 것

- 요구사항 또는 환경 부족 때문에 증명할 수 없는 항목
```

관련 항목이 없으면 빈 section을 출력하지 않는다.

---

# When Verification Was Executed

사용자가 실행까지 요청해서 실제 검증한 경우 출력 형식을 변경한다.

```markdown
## 검증 결과

### ✅ 확인됨

- 동작
  - Evidence: `실행한 명령 또는 실제 확인 내용`

### ❌ 실패

- 동작
  - Expected:
  - Actual:
  - Evidence:

### ⚠️ 미확인

- 동작
  - 확인하지 못한 이유
  - 필요한 다음 검증
```

**미실행 항목을 ✅로 표시하지 않는다.**

---

# Review Heuristics

diff를 읽으면서 다음 패턴이 보이면 체크리스트에 반영할지 고려한다.

| Change          | Verification question                   |
| --------------- | --------------------------------------- |
| 새로운 분기     | 각 branch를 실제로 탈 수 있는가?        |
| API 변경        | 기존 caller가 새 contract와 호환되는가? |
| validation 변경 | boundary 전후 값의 결과가 올바른가?     |
| async 변경      | pending/error/retry 상태가 올바른가?    |
| shared state    | 다른 화면이나 caller에 회귀가 없는가?   |
| persistence     | 저장 후 reload해도 동일한가?            |
| cache           | mutation 후 stale data가 남지 않는가?   |
| auth            | 권한이 다른 사용자에서 결과가 올바른가? |
| migration       | 기존 데이터에서도 동작하는가?           |
| optional/null   | 값이 없을 때 안전한가?                  |
| retry/submit    | 중복 실행이 발생하지 않는가?            |

이 표 전체를 매번 체크리스트로 복사하지 않는다.

**diff에 실제로 관련된 항목만 선택한다.**

---

# Anti-Patterns

## Generic QA Dump

나쁨:

```text
로그인 확인
에러 확인
성능 확인
보안 확인
모바일 확인
```

현재 변경과 연결되지 않은 항목은 노이즈다.

---

## Diff Summary Instead of Verification

나쁨:

```text
- UserForm 수정
- API hook 수정
- test 수정
```

이는 변경 요약이지 verification plan이 아니다.

항상 observable behavior로 변환한다.

---

## Confidence as Evidence

나쁨:

```text
코드를 보니 잘 처리되어 있습니다.
```

좋음:

```text
코드상 error branch는 존재하지만 실제 실패 응답에서의 동작은 아직 실행 검증되지 않았다.
```

---

## Tests Equal Complete

테스트가 모두 통과했더라도 요구사항에 있는 동작이 테스트되지 않았다면 verification은 끝난 것이 아니다.

requirements → claim → evidence 순서로 판단한다.

---

## Inventing Requirements

diff만 보고 제품 요구사항을 만들어내지 않는다.

확실하지 않은 것은 다음처럼 표시한다.

```text
추론:
이 변경은 중복 제출을 방지하려는 것으로 보인다.
```

---

## Over-Verification

가능한 모든 경우의 수를 나열하는 것이 목적이 아니다.

**현재 변경으로 깨질 가능성이 크고, 실패했을 때 영향이 큰 동작을 먼저 찾는 것이 목적이다.**

보통 다음 정도면 충분하다.

```text
P0: 3~8개
P1: 2~6개
자동 테스트 추천: 0~4개
```

작고 단순한 변경이라면 이보다 훨씬 적어도 된다.

---

# Final Principle

검증의 목적은 체크박스를 많이 만드는 것이 아니다.

다음 질문에 답할 수 있어야 한다.

```text
이 기능이 제대로 동작한다고 말하려면
무엇을 관찰해야 하고,
어떤 증거가 있어야 하는가?
```

그 증거가 없다면 완료됐다고 가정하지 않는다.
