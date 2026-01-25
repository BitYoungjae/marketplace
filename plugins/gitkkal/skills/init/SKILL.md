---
name: init
description: "gitkkal 초기 설정을 대화형으로 진행합니다. Git 커밋 스타일, PR 템플릿 등을 설정합니다."
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion, Task
disable-model-invocation: true
---

# gitkkal 초기화 스킬

Git 워크플로우 자동화를 위한 설정 파일을 대화형으로 생성합니다.

## 설정 파일

**위치**: `{project_root}/.gitkkal/config.json`

프로젝트 루트는 Git 저장소의 최상위 디렉터리입니다 (`git rev-parse --show-toplevel`로 확인).

<config_schema>

```json
{
  "language": "ko" | "en",
  "commitPattern": "conventional" | "gitmoji" | "simple",
  "branchPattern": "type/description" | "description-only",
  "splitCommits": boolean,
  "askOnAmbiguity": boolean,
  "createPrTemplate": boolean
}
```

</config_schema>

### branchPattern 옵션

| 패턴 | 형식 | 예시 |
|------|------|------|
| `type/description` | `type/slug` | `feat/add-login`, `fix/button-bug` |
| `description-only` | `slug` | `add-login`, `fix-button-bug` |

## 실행 절차

### 1단계: 기존 설정 확인

`{project_root}/.gitkkal/config.json` 파일이 존재하는지 확인합니다.

- 존재하면: 현재 설정을 보여주고 덮어쓸지 물어봅니다.
- 존재하지 않으면: 새 설정을 생성합니다.

### 2단계: 설정 항목 수집

AskUserQuestion 도구로 다음 항목들을 수집합니다. 한 번에 최대 4개까지 질문할 수 있습니다.

<questions_batch_1>

1. **language**: 커밋 메시지 언어
   - `ko`: 한국어
   - `en`: 영어

2. **commitPattern**: 커밋 메시지 스타일
   - `conventional`: `type(scope): subject` 형식
   - `gitmoji`: 유니코드 이모지로 시작 (예: `✨ Add feature`)
   - `simple`: 단순 메시지 (예: `Add feature`)

3. **branchPattern**: 브랜치 명명 스타일
   - `type/description`: 타입 접두사 포함 (예: `feat/add-login`, `fix/button-bug`)
   - `description-only`: 설명만 사용 (예: `add-login`, `fix-button-bug`)

4. **splitCommits**: 변경사항을 의미 단위로 분할할지 여부
   - `true`: 의미적으로 응집된 변경을 별도 커밋으로 분할
   - `false`: 모든 변경을 하나의 커밋으로

</questions_batch_1>

<questions_batch_2>

5. **askOnAmbiguity**: 커밋 분류가 모호할 때 질문할지 여부
   - `true`: 모호한 경우 사용자에게 확인
   - `false`: Claude가 자동 판단

6. **createPrTemplate**: PR 템플릿 생성 여부
   - `true`: `.github/PULL_REQUEST_TEMPLATE.md` 생성
   - `false`: 생성하지 않음

</questions_batch_2>

### 3단계: 설정 파일 저장

수집한 정보를 `{project_root}/.gitkkal/config.json`에 저장합니다.

<example_config>

```json
{
  "language": "ko",
  "commitPattern": "conventional",
  "branchPattern": "type/description",
  "splitCommits": true,
  "askOnAmbiguity": true,
  "createPrTemplate": true
}
```

</example_config>

### 4단계: PR 템플릿 생성 (선택)

`createPrTemplate`이 `true`인 경우:

1. 프로젝트 구조를 간단히 분석합니다:
   - 사용 언어/프레임워크 파악 (package.json, Cargo.toml, go.mod 등)
   - 테스트 프레임워크 확인
   - CI/CD 설정 확인 (.github/workflows/)

2. 프로젝트에 맞는 `.github/PULL_REQUEST_TEMPLATE.md`를 생성합니다.

<pr_template_example>

```markdown
## Summary

<!-- 변경 사항을 간략히 설명해주세요 -->

## Changes

-

## Test Plan

- [ ] 기존 테스트 통과 확인
- [ ] 새로운 테스트 추가 (해당 시)

## Checklist

- [ ] 코드 스타일 준수
- [ ] 문서 업데이트 (해당 시)
```

</pr_template_example>

### 5단계: 완료 메시지

설정 완료 후 다음을 안내합니다:

- 생성된 설정 파일 경로
- 사용 가능한 명령어: `/gitkkal:branch`, `/gitkkal:commit`, `/gitkkal:pr`
- 설정 변경 방법: `/gitkkal:init` 재실행

## 주의사항

- 기존 `{project_root}/.gitkkal/config.json`이 있으면 덮어쓰기 전 확인
- `.github/PULL_REQUEST_TEMPLATE.md`가 이미 존재하면 덮어쓰기 전 확인
- 모든 설정 항목에 합리적인 기본값 제안 (Recommended 표시)
