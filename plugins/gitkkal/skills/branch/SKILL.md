---
name: branch
description: "변경사항을 분석하여 적절한 브랜치를 생성합니다."
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
disable-model-invocation: true
argument-hint: "[description]"
---

# gitkkal branch 스킬

변경사항을 분석하여 적절한 브랜치명을 생성하고 브랜치를 생성합니다.

## 실행 절차

### 1단계: 설정 확인

`{project_root}/.gitkkal/config.json` 파일을 읽어 설정을 확인합니다.

프로젝트 루트는 Git 저장소의 최상위 디렉터리입니다 (`git rev-parse --show-toplevel`로 확인).

- **존재하면**: 파일에서 설정을 로드합니다.
- **존재하지 않으면**: 기본 설정을 사용합니다.

<default_config>

```json
{
  "language": "en",
  "commitPattern": "conventional",
  "branchPattern": "type/description",
  "splitCommits": true,
  "askOnAmbiguity": true,
  "createPrTemplate": false
}
```

</default_config>

설정 파일이 없을 때는 "기본 설정을 사용합니다. 커스터마이즈하려면 `/gitkkal:init`을 실행하세요." 메시지를 한 번 표시합니다.

### 2단계: 현재 상태 확인

다음 명령을 실행하여 현재 상태를 파악합니다:

```bash
git status --short
git diff --stat
git diff --cached --stat
```

- 변경사항이 없으면: 사용자에게 브랜치 설명을 직접 입력받습니다.
- 변경사항이 있으면: 변경 내용을 분석합니다.

### 3단계: 변경 유형 결정

변경된 파일과 내용을 분석하여 브랜치 타입을 결정합니다:

<branch_type_rules>

| 타입 | 판단 기준 |
|------|-----------|
| `feat` | 새로운 기능 추가 (새 파일 추가, 새 함수/클래스 추가) |
| `fix` | 버그 수정 (기존 로직 수정, 에러 핸들링 추가) |
| `refactor` | 코드 리팩토링 (기능 변경 없이 구조 개선) |
| `docs` | 문서 변경 (*.md, README, CHANGELOG 등) |
| `test` | 테스트 코드 (*.test.*, *.spec.*, __tests__/) |
| `style` | 포맷팅, 세미콜론 등 코드 스타일 변경 |
| `chore` | 빌드, 설정 파일 변경 (package.json, tsconfig 등) |
| `perf` | 성능 개선 |
| `ci` | CI/CD 설정 변경 (.github/workflows/ 등) |

</branch_type_rules>

**판단이 어려운 경우**:
- 여러 타입에 해당하면 가장 주요한 변경 기준으로 결정
- 확실하지 않으면 `feat`으로 기본 설정

### 4단계: 브랜치명 생성

#### slug 생성 규칙

<slug_rules>

1. 영어 kebab-case 사용
2. 최대 50자 제한
3. 특수문자 제거 (영문, 숫자, 하이픈만 허용)
4. 공백은 하이픈으로 변환
5. 연속 하이픈은 단일 하이픈으로
6. 앞뒤 하이픈 제거
7. 소문자로 변환

</slug_rules>

<slug_examples>

| 입력 | 출력 |
|------|------|
| `Add user authentication` | `add-user-authentication` |
| `Fix button click bug` | `fix-button-click-bug` |
| `Update README file` | `update-readme-file` |
| `사용자 로그인 기능` | (AskUserQuestion으로 영문 설명 요청) |

</slug_examples>

#### 패턴별 브랜치명

| branchPattern | 형식 | 예시 |
|---------------|------|------|
| `type/description` | `{type}/{slug}` | `feat/add-user-login` |
| `description-only` | `{slug}` | `add-user-login` |

### 5단계: 사용자 확인

생성할 브랜치명을 사용자에게 보여주고 확인을 받습니다.

AskUserQuestion 도구로 다음을 질문합니다:

<confirmation_question>

header: "Branch"
question: "다음 브랜치를 생성할까요?"
options:
  - label: "{생성된 브랜치명}"
    description: "이 브랜치명으로 생성합니다"
  - label: "직접 입력"
    description: "다른 브랜치명을 직접 지정합니다"

</confirmation_question>

### 6단계: 브랜치 생성

확인된 브랜치명으로 브랜치를 생성하고 체크아웃합니다:

```bash
git checkout -b {branch_name}
```

### 7단계: 완료 메시지

브랜치 생성 결과를 안내합니다:

<completion_message>

- 생성된 브랜치: `{branch_name}`
- 다음 단계: 변경사항을 커밋하려면 `/gitkkal:commit` 실행

</completion_message>

## 인자 처리

사용자가 인자를 제공한 경우 (예: `/gitkkal:branch add user authentication`):

1. 인자를 브랜치 설명으로 사용
2. 변경사항 분석 단계를 건너뛰고 인자 기반으로 타입 결정
3. 나머지 절차 동일하게 진행

## 에러 처리

<error_cases>

| 상황 | 처리 |
|------|------|
| Git 저장소 아님 | "Git 저장소가 아닙니다" 안내 |
| 동일 브랜치명 존재 | 다른 이름을 입력받거나 숫자 접미사 추가 제안 |
| 현재 브랜치에 커밋되지 않은 변경 있음 | 경고 후 계속 진행할지 확인 |

</error_cases>

## 주의사항

- 브랜치 생성 전 현재 브랜치 상태를 확인
- 한글 설명이 입력되면 영문 설명을 요청
- 브랜치명이 너무 길면 자동으로 축약
