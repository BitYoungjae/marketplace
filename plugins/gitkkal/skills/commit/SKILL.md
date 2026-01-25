---
name: commit
description: "변경사항을 분석하여 설정에 맞는 커밋을 생성합니다. Git 워크플로우 자동화."
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion
disable-model-invocation: true
---

# gitkkal 커밋 스킬

변경사항을 분석하고 설정된 스타일에 맞는 커밋을 생성합니다.

## 선행 조건 확인

### 설정 파일 확인

`{project_root}/.gitkkal/config.json` 파일이 존재하는지 확인합니다.

프로젝트 루트는 Git 저장소의 최상위 디렉터리입니다 (`git rev-parse --show-toplevel`로 확인).

<if_not_exists>
설정 파일이 없습니다. `/gitkkal:init`을 먼저 실행하여 설정을 완료해주세요.
</if_not_exists>

## 설정 스키마

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

## 커밋 패턴 형식

<commit_patterns>
| 패턴 | 형식 | 예시 |
|------|------|------|
| `conventional` | `<type>[(scope)]: <description>` | `feat(auth): 로그인 기능 추가`, `fix: null 참조 오류 수정` |
| `gitmoji` | `<emoji> [(scope)][:] <message>` | `✨ 로그인 기능 추가`, `🐛 (auth): 로그인 버그 수정` |
| `simple` | `<message>` | `로그인 기능 추가` |
</commit_patterns>

**Conventional Commits**: scope는 선택사항이며, 괄호로 감싸서 표기합니다. [공식 사양](https://www.conventionalcommits.org/en/v1.0.0/)

**Gitmoji**: 이모지는 unicode(`✨`) 또는 shortcode(`:sparkles:`) 형식 모두 가능. scope는 선택사항. [공식 사양](https://gitmoji.dev/specification)

### Conventional Commit Types

<conventional_types>
| Type | 용도 | Gitmoji |
|------|------|---------|
| `feat` | 새로운 기능 | ✨ |
| `fix` | 버그 수정 | 🐛 |
| `docs` | 문서 변경 | 📝 |
| `style` | 코드 포맷팅 (기능 변경 없음) | 🎨 |
| `refactor` | 리팩토링 | ♻️ |
| `perf` | 성능 개선 | ⚡ |
| `test` | 테스트 추가/수정 | ✅ |
| `build` | 빌드 시스템/의존성 | 📦 |
| `ci` | CI 설정 변경 | 👷 |
| `chore` | 기타 변경 | 🔧 |
| `revert` | 커밋 되돌리기 | ⏪ |
</conventional_types>

## 실행 절차

### 1단계: 설정 로드

`{project_root}/.gitkkal/config.json`을 읽어 설정을 로드합니다.

### 2단계: 변경사항 분석

다음 Git 명령을 실행하여 변경사항을 파악합니다:

<git_commands>
```bash
# Staged 변경사항 확인
git diff --cached --stat
git diff --cached

# Unstaged 변경사항 확인
git diff --stat
git diff

# Untracked 파일 확인
git status --porcelain

# 최근 커밋 메시지 스타일 참고
git log --oneline -10
```
</git_commands>

### 3단계: 커밋 분할 결정

`splitCommits`가 `true`인 경우:

<split_criteria>
**분할 원칙**:
1. 각 커밋은 **실행 가능한 단위**여야 함 (빌드/테스트 통과 가능)
2. **의미적으로 응집된 변경**만 하나의 커밋으로 묶음

**분할 예시**:
- 새 기능 + 관련 테스트 → 하나의 커밋
- 버그 수정 + 새 기능 → 별도 커밋
- 포맷팅 변경 + 로직 변경 → 별도 커밋
- 관련 없는 여러 파일 수정 → 의미 단위로 분할
</split_criteria>

`askOnAmbiguity`가 `true`이고 분할이 모호한 경우:
- AskUserQuestion으로 사용자에게 확인

### 4단계: 커밋 메시지 작성

설정된 패턴에 맞게 커밋 메시지를 작성합니다.

<message_guidelines>
**좋은 커밋 메시지 원칙**:
- "what"이 아닌 "why"에 초점
- 명령형 현재 시제 사용 (영어: "Add", 한국어: "추가")
- 첫 줄은 50자 이내 권장
- 필요시 본문에 상세 설명 추가

**언어별 예시**:
- `ko`: `feat(auth): 소셜 로그인 기능 추가`
- `en`: `feat(auth): add social login feature`
</message_guidelines>

### 5단계: 커밋 실행

<commit_execution>
```bash
# 파일 스테이징 (splitCommits인 경우 선별적으로)
git add <files>

# 커밋 생성 (HEREDOC으로 메시지 전달)
git commit -m "$(cat <<'EOF'
커밋 메시지
EOF
)"
```
</commit_execution>

## 금지 사항

<prohibited>
- 커밋 메시지에 `Co-Authored-By` 라인 **절대 포함 금지**
- `git commit --amend` 사용 금지 (새 커밋 생성)
- `git add -A` 또는 `git add .` 대신 개별 파일 지정
- 민감한 파일 (.env, credentials 등) 커밋 금지
</prohibited>

## 오류 처리

<error_handling>
**스테이징할 변경사항이 없는 경우**:
- "커밋할 변경사항이 없습니다." 안내

**pre-commit hook 실패 시**:
- 문제 수정 후 **새 커밋 생성** (amend 금지)
- 실패 원인을 사용자에게 설명

**충돌 상태인 경우**:
- 먼저 충돌 해결 필요함을 안내
</error_handling>

## 출력 예시

<output_example>
커밋이 완료되면 다음 정보를 표시합니다:
- 생성된 커밋 해시
- 커밋 메시지
- 변경된 파일 목록
- (splitCommits인 경우) 생성된 커밋 수
</output_example>
