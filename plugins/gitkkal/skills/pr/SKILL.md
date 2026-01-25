---
name: pr
description: "PR을 생성하거나 업데이트합니다. 인자 없으면 새 PR 생성, PR 번호가 있으면 기존 PR 업데이트."
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion
disable-model-invocation: true
argument-hint: "[pr-number]"
---

# gitkkal PR 스킬

Pull Request를 생성하거나 업데이트합니다.

## 사용법

<usage>
- `/gitkkal:pr` - 새 PR 생성
- `/gitkkal:pr 123` - PR #123 업데이트
</usage>

## 선행 조건 확인

### 설정 파일 확인

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

### GitHub CLI 확인

`gh` CLI가 설치되어 있고 인증되어 있는지 확인합니다:

```bash
gh auth status
```

## 실행 모드 결정

`$ARGUMENTS`를 확인하여 모드를 결정합니다:

<mode_decision>
- **인자가 없거나 빈 문자열**: PR 생성 모드
- **숫자가 있음**: PR 업데이트 모드 (해당 PR 번호 업데이트)
</mode_decision>

---

## PR 생성 모드

### 1단계: 브랜치 상태 확인

<branch_check>
```bash
# 현재 브랜치 확인
git branch --show-current

# 메인 브랜치 확인 (main 또는 master)
git remote show origin | grep 'HEAD branch'

# 리모트 트래킹 상태 확인
git status -sb

# 푸시 필요 여부 확인
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null || echo "no-remote"
```
</branch_check>

### 2단계: 커밋 분석

베이스 브랜치로부터의 모든 커밋을 분석합니다:

<commit_analysis>
```bash
# 베이스 브랜치 대비 커밋 목록
git log main..HEAD --oneline

# 전체 diff 확인
git diff main...HEAD --stat

# 상세 diff (필요시)
git diff main...HEAD
```
</commit_analysis>

### 3단계: PR 내용 작성

설정의 `language`에 맞게 PR 제목과 본문을 작성합니다.

<pr_content_guidelines>
**제목 (Title)**:
- 변경사항의 핵심을 간결하게 요약
- 50자 이내 권장
- 언어 설정에 따라 한국어/영어로 작성

**본문 (Body)** 구조:
```markdown
## Summary
<!-- 1-3개의 불릿 포인트로 변경 요약 -->

## Test plan
<!-- 테스트 방법 체크리스트 -->
```
</pr_content_guidelines>

### 4단계: 푸시 및 PR 생성

<pr_creation>
```bash
# 리모트에 푸시 (필요시)
git push -u origin $(git branch --show-current)

# PR 생성 (HEREDOC으로 본문 전달)
gh pr create --title "PR 제목" --body "$(cat <<'EOF'
## Summary
- 변경 요약 1
- 변경 요약 2

## Test plan
- [ ] 테스트 항목 1
- [ ] 테스트 항목 2
EOF
)"
```
</pr_creation>

---

## PR 업데이트 모드

PR 번호가 `$ARGUMENTS`로 전달된 경우.

### 1단계: 기존 PR 확인

<pr_check>
```bash
# PR 존재 여부 및 상태 확인
gh pr view $ARGUMENTS --json number,title,body,state,headRefName

# 현재 브랜치가 PR의 브랜치와 일치하는지 확인
```
</pr_check>

### 2단계: 변경사항 재분석

PR 생성 이후 추가된 커밋들을 분석합니다:

<update_analysis>
```bash
# PR의 모든 커밋 확인
gh pr view $ARGUMENTS --json commits

# 현재 diff 확인
git diff main...HEAD --stat
```
</update_analysis>

### 3단계: PR 내용 업데이트

기존 PR 내용을 **완전히 새로운 내용으로 교체**합니다.

<important>
**주의**: 업데이트 시 기존 내용에 append하지 않고 **완전 교체**합니다.
모든 커밋을 분석하여 새로운 Summary와 Test plan을 작성합니다.
</important>

### 4단계: PR 업데이트 실행

<pr_update>
```bash
# PR 제목과 본문 업데이트
gh pr edit $ARGUMENTS --title "새 PR 제목" --body "$(cat <<'EOF'
## Summary
- 업데이트된 변경 요약

## Test plan
- [ ] 업데이트된 테스트 항목
EOF
)"
```
</pr_update>

---

## PR 템플릿 활용

`{project_root}/.github/PULL_REQUEST_TEMPLATE.md`가 존재하면 해당 템플릿의 구조를 따릅니다.

<template_usage>
1. 템플릿 파일 읽기
2. 섹션 구조 파악
3. 각 섹션에 맞는 내용 채우기
4. 빈 섹션은 유지하되 가이드 텍스트 제거
</template_usage>

---

## 오류 처리

<error_handling>
**gh CLI가 없는 경우**:
- "GitHub CLI가 필요합니다. https://cli.github.com 에서 설치해주세요." 안내

**인증되지 않은 경우**:
- "`gh auth login`을 실행하여 인증해주세요." 안내

**PR 번호가 유효하지 않은 경우**:
- "PR #N을 찾을 수 없습니다." 안내

**리모트에 푸시할 수 없는 경우**:
- 권한 문제 또는 충돌 가능성 안내

**메인 브랜치에서 PR 생성 시도**:
- "메인 브랜치에서는 PR을 생성할 수 없습니다. 새 브랜치를 만들어주세요." 안내
</error_handling>

---

## 출력 예시

<output_example>
**PR 생성 완료 시**:
- PR URL 표시
- PR 번호 표시
- 요약 정보 (제목, 베이스 브랜치, 커밋 수)

**PR 업데이트 완료 시**:
- PR URL 표시
- "PR #N이 업데이트되었습니다." 메시지
- 변경된 내용 요약
</output_example>

---

## 금지 사항

<prohibited>
- PR 본문에 `Co-Authored-By` 라인 포함 금지
- Force push (`git push --force`) 금지
- 이미 머지된 PR 수정 시도 금지
</prohibited>
