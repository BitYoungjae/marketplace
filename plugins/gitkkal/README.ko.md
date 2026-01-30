# gitkkal

> *한국어 "기깔나다"에서 이름을 따왔습니다.*

[English](./README.md)

Git 워크플로우를 자동화하는 Claude Code 플러그인입니다. 브랜치 생성, 커밋 메시지 작성, PR 생성을 지원합니다.

## 설치

먼저 마켓플레이스를 추가합니다 (최초 1회):

```
/plugin marketplace add bityoungjae/marketplace
```

그 다음 플러그인을 설치합니다:

```
/plugin install gitkkal@bityoungjae-marketplace
```

## 빠른 시작

```
/gitkkal:init                      # 환경설정 (처음 한 번)
/gitkkal:branch [설명]             # 새 브랜치 생성
/gitkkal:commit [힌트]             # 변경사항 커밋
/gitkkal:pr [힌트]                 # PR 생성 또는 업데이트
```

## 워크플로우

gitkkal를 사용한 일반적인 개발 워크플로우:

1. **작업 시작**
   ```
   /gitkkal:branch add user authentication
   ```
   변경사항이나 설명을 기반으로 새 브랜치를 생성합니다.

2. **변경사항 커밋**
   ```
   /gitkkal:commit
   ```
   변경사항을 분석하고 설정된 스타일로 커밋을 생성합니다.

3. **PR 생성**
   ```
   /gitkkal:pr
   ```
   자동 생성된 제목과 설명으로 PR을 생성합니다.

4. **PR 업데이트** (추가 커밋 후)
   ```
   /gitkkal:pr emphasize refactoring
   ```
   새 변경사항으로 기존 PR을 업데이트합니다.

## 명령어

| 명령어 | 설명 |
|--------|------|
| `/gitkkal:init` | 커밋 스타일 및 환경설정 구성 |
| `/gitkkal:branch [설명]` | 변경사항이나 설명을 기반으로 브랜치 생성 |
| `/gitkkal:commit [힌트]` | 설정된 스타일로 커밋 생성 |
| `/gitkkal:pr [힌트]` | Pull Request 생성 또는 업데이트 |

## 커밋 스타일

- **conventional** - `feat(auth): add login support`
- **gitmoji** - `✨ Add login support`
- **simple** - `Add login support`

## 설정

`.gitkkal/config.json`에 저장됩니다 (`/gitkkal:init`으로 생성):

```json
{
  "language": "ko",
  "commitPattern": "conventional",
  "branchPattern": "type/description",
  "splitCommits": true,
  "askOnAmbiguity": true,
  "createPrTemplate": false
}
```

| 옵션 | 값 | 설명 |
|------|-----|------|
| `language` | `"en"`, `"ko"` | 커밋 메시지 언어 |
| `commitPattern` | `"conventional"`, `"gitmoji"`, `"simple"` | 커밋 메시지 형식 |
| `branchPattern` | `"type/description"`, `"description-only"` | 브랜치 명명 스타일 |
| `splitCommits` | `true`, `false` | 변경사항을 의미 단위로 분리하여 커밋 |
| `askOnAmbiguity` | `true`, `false` | 커밋 분류가 모호할 때 사용자에게 확인 |
| `createPrTemplate` | `true`, `false` | 초기화 시 `.github/PULL_REQUEST_TEMPLATE.md` 생성 |

설정 파일이 없으면 기본값이 자동으로 사용됩니다.

## 요구사항

- Git 저장소
- GitHub CLI (`gh`) - PR 기능 사용 시 필요
