# Dokhak (독학)

> _토큰을 태워, 지식을 얻다._

종합적인 독학 학습 자료를 생성하기 위한 Claude Code 플러그인입니다.

주제만 지정하면, 웹 리서치부터 커리큘럼 설계, 문서 작성까지 전체 과정을 자동화합니다.

[English README](README.md)

## 주요 기능

- **대화형 인터뷰**: 자연스러운 대화를 통해 맞춤형 학습 자료 생성
- **도메인 적응형 생성**: 분야에 따라 콘텐츠 전략 자동 조정 (기술, 역사, 과학, 예술, 언어/일반)
- **자동 리서치**: 각 섹션 작성 전 웹에서 최신 정보를 수집
- **문서 생성**: 정의된 페르소나와 스타일에 맞춰 일관된 톤의 문서 작성
- **진행 추적**: 전체 진행률 확인 및 프로젝트 일관성 검증

## 요구 사항

- **Claude Code CLI** (필수)
- 웹 접근 권한 (WebSearch, WebFetch 도구)

## 설치

Claude Code CLI에서 다음 명령어를 순서대로 실행하세요:

```bash
# 1단계: 마켓플레이스 등록
/plugin marketplace add BitYoungjae/marketplace

# 2단계: 플러그인 설치
/plugin install dokhak@bityoungjae-marketplace
```

설치가 완료되면 `/dokhak:` 로 시작하는 명령어들을 사용할 수 있습니다.

---

## 빠른 시작 가이드

### Step 1. 프로젝트 초기화

먼저 학습 자료를 생성할 **빈 디렉토리를 만들고 해당 디렉토리로 이동**하세요.

```bash
# 예시: Rust 학습 자료 프로젝트 생성
mkdir rust-learning && cd rust-learning
```

그 다음 Claude Code를 실행하고 `init` 명령어로 프로젝트를 초기화합니다:

```bash
/dokhak:init
```

다국어 인사와 함께 대화형 인터뷰가 시작됩니다:

```
🇰🇷 안녕하세요! 오늘은 어떤 걸 배워보고 싶으세요?
🇺🇸 Hey there! What are you curious to learn about?
🇯🇵 こんにちは！今日は何を学んでみたいですか？
🇨🇳 你好！今天想学点什么呢？
🇪🇸 ¡Hola! ¿Qué te gustaría aprender hoy?
```

인터뷰어가 자연스럽게 파악하는 것들:

- **주제**: 무엇을 배우고 싶은지
- **동기**: 왜 배우려고 하는지
- **수준**: 현재 어느 정도 알고 있는지
- **선호**: 어떤 형태의 문서를 원하는지

초기화 후 생성되는 파일:

| 파일                 | 설명                                          |
| -------------------- | --------------------------------------------- |
| `persona.md`         | 작가와 독자의 페르소나 정의                   |
| `interview-data.md`  | 인터뷰 원본 데이터                            |
| `plan.md`            | 전체 커리큘럼 구조 (Part → Chapter → Section) |
| `task.md`            | 작성할 섹션 목록과 진행 상태 체크리스트       |
| `project-context.md` | 수집된 리서치 결과와 프로젝트 환경 정보       |
| `CLAUDE.md`          | Claude가 참조할 프로젝트별 가이드라인         |

### Step 2. 문서 작성

프로젝트 초기화가 완료되면 문서 작성을 시작합니다.

```bash
# task.md에서 다음 대기 중인 섹션 1개를 작성
/dokhak:write

# 특정 섹션을 지정하여 작성
/dokhak:write 2-3

# 여러 섹션을 연속으로 작성 (권장)
/dokhak:continue 5
```

**작동 방식**:

1. `researcher` 에이전트가 해당 섹션에 대한 웹 리서치 수행
2. 수집된 정보를 `writer` 에이전트에게 전달
3. `writer`가 `persona.md`의 스타일에 맞춰 문서 작성
4. 완성된 문서는 `docs/` 디렉토리에 저장
5. `task.md`에서 해당 섹션이 완료 상태로 업데이트

**배치 작성 진행 상황**:

```
📝 [1/5] Starting section 1.1 Introduction...
✅ [1/5] Completed section 1.1 Introduction
📝 [2/5] Starting section 1.2 Core Concepts...
...
```

### Step 3. 진행 상황 확인

언제든지 현재 진행 상황을 확인할 수 있습니다:

```bash
/dokhak:status
```

**출력 예시**:

- 전체 완료율 (예: 43%)
- Part별 완료된 섹션 수 / 전체 섹션 수
- 다음으로 작성할 섹션 정보

---

## 도메인 적응형 콘텐츠 생성

Dokhak은 학습 자료의 분야에 따라 생성 전략을 자동으로 조정합니다:

### 기술 (Technology)

- 코드 예제와 버전 정보
- GitHub 리포지토리 및 공식 문서 참조
- 환경 설정 가이드
- API 레퍼런스

### 역사 (History)

- 1차 사료 수집
- 연대기 구성
- 역사적 관점 포함
- 학술 자료 인용

### 과학 (Science)

- 수식 및 공식 포함
- 실험 절차 상세화
- 수학적 배경 명시
- 논문 참조

### 예술 (Arts)

- 시각적 예시 및 참고 자료
- 기법 단계별 설명
- 재료 및 도구 목록
- 실습 과제

### 언어 / 일반 (Language / General)

- 구조화된 설명
- 언어학적 분석 및 예시
- 연습 문제
- 인터랙티브 요소

---

## 전체 커맨드 레퍼런스

### 핵심 커맨드

| 커맨드             | 설명                                            | 사용 시점             |
| ------------------ | ----------------------------------------------- | --------------------- |
| `/dokhak:init`     | 인터뷰 기반 프로젝트 초기화                     | 처음 시작할 때 1회    |
| `/dokhak:write`    | 다음 섹션 1개 작성 (researcher→writer→reviewer) | 섹션 단위로 작업할 때 |
| `/dokhak:continue` | 여러 섹션 연속 작성                             | 배치 작업할 때 (권장) |
| `/dokhak:status`   | 진행 상황 확인                                  | 언제든지              |

### 유지보수 커맨드

| 커맨드           | 설명                              | 사용 시점                 |
| ---------------- | --------------------------------- | ------------------------- |
| `/dokhak:doctor` | 프로젝트 구조 진단 및 대화형 수정 | 문제 발생 시 또는 완료 전 |

### 상세 사용법

#### `/dokhak:init`

```bash
/dokhak:init
```

대화형 인터뷰 프로세스를 시작합니다.

#### `/dokhak:write`

```bash
/dokhak:write [섹션ID] [--skip-review]
```

- `섹션ID`: 특정 섹션을 지정 (선택, 생략 시 task.md의 다음 대기 섹션 작성)
- `--skip-review`: reviewer 단계를 건너뛰고 바로 완료 처리
- 예: `/dokhak:write 2-3` → Chapter 2의 Section 3 작성

#### `/dokhak:continue`

```bash
/dokhak:continue [개수] [--skip-review]
```

- `개수`: 연속으로 작성할 섹션 수 (선택, 기본값: 3)
- `--skip-review`: 모든 섹션에서 reviewer 단계 건너뛰기
- task.md의 세션 경계를 존중함
- 예: `/dokhak:continue 5` → 5개 섹션 연속 작성

#### `/dokhak:doctor`

```bash
/dokhak:doctor
```

- 필수 파일 존재 여부 확인 (plan.md, task.md, persona.md 등)
- 파일 간 일관성 검증 (plan.md ↔ task.md ↔ CLAUDE.md)
- 완료 상태와 실제 파일 매칭 확인
- 발견된 문제에 대해 대화형 수정 제안

---

## 세션 기반 작업 분배

`task.md`는 효율적인 배치 처리를 위해 세션 단위로 자동 분할됩니다:

```markdown
<!-- Session 1: Part 1 기초 -->

- [ ] 1.1 Introduction (8p)
- [ ] 1.2 Core Concepts (7p)
- [ ] 1.3 Basic Syntax (10p)

<!-- Session 2: Part 1 아키텍처 -->

- [ ] 1.4 System Design (12p)
- [ ] 1.5 Best Practices (8p)
```

- 1 세션 = 3-5개 섹션 또는 20-40 페이지
- `/continue`가 세션 경계를 자동 인식
- 관련 콘텐츠를 그룹화하여 일관된 작성 유지

---

## 전체 워크플로우

```
┌──────────────────────────────────────────────────────────────┐
│                    1. 프로젝트 초기화                          │
│  /dokhak:init                                        │
│                                                              │
│  → project-interviewer가 대화형 인터뷰 진행                    │
│  → research-collector가 도메인별 정보 수집                     │
│  → structure-designer가 plan.md, task.md 설계                │
│  → persona.md, project-context.md, CLAUDE.md 생성            │
└──────────────────────┬───────────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────────┐
│                    2. 문서 작성 (반복)                         │
│  /dokhak:write 또는 /dokhak:continue 3           │
│                                                              │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     │
│  │ researcher  │────▶│   writer    │────▶│  reviewer   │     │
│  │  (Haiku)    │     │   (Opus)    │     │   (Haiku)   │     │
│  └─────────────┘     └─────────────┘     └──────┬──────┘     │
│                                                  │            │
│                            ┌─────────────────────┼────────┐   │
│                            │                     │        │   │
│                            ▼                     ▼        │   │
│                      NEEDS_REVISION           PASS        │   │
│                            │                     │        │   │
│                            ▼                     │        │   │
│                      ┌─────────────┐             │        │   │
│                      │   writer    │             │        │   │
│                      │ (수정 반영) │─────────────┘        │   │
│                      └─────────────┘                      │   │
│                                                           │   │
│                     docs/XX-X-title.md 저장               │   │
│                     task.md 상태 업데이트                  │   │
│                     (--skip-review로 리뷰 단계 생략 가능)  │   │
└──────────────────────┬────────────────────────────────────┘   │
                       ▼
┌──────────────────────────────────────────────────────────────┐
│                    3. 진행 상황 확인                          │
│  /dokhak:status                                              │
│                                                              │
│  → 완료율, 남은 섹션 수, 다음 작업 표시                         │
└──────────────────────┬───────────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────────┐
│                    4. 구조 진단 (선택)                         │
│  /dokhak:doctor                                              │
│                                                              │
│  → plan.md ↔ task.md ↔ 실제 파일 일관성 확인                  │
│  → 발견된 문제에 대해 대화형 수정 제안                          │
└──────────────────────────────────────────────────────────────┘
```

---

## 내부 구성 요소

> 일반 사용자는 이 섹션을 읽지 않아도 됩니다. 플러그인 구조를 이해하고 싶은 분들을 위한 참고 정보입니다.

### 에이전트 (Agents)

플러그인은 내부적으로 여러 AI 에이전트를 사용하여 작업을 분담합니다:

| 에이전트              | 사용 모델 | 역할                                     |
| --------------------- | --------- | ---------------------------------------- |
| `project-interviewer` | Opus      | 대화형 인터뷰로 페르소나 생성            |
| `researcher`          | Haiku     | 섹션 작성 전 웹에서 관련 정보 수집       |
| `writer`              | Opus      | 수집된 정보를 바탕으로 실제 문서 작성    |
| `reviewer`            | Haiku     | 작성된 문서의 품질 및 일관성 검토        |
| `research-collector`  | Haiku     | 프로젝트 초기화 시 주제 관련 리서치 수집 |
| `structure-designer`  | Opus      | 수집된 정보로 커리큘럼 구조 설계         |

### 스킬 (Skills)

#### project-scaffolder

프로젝트 초기화 시 사용되는 템플릿 모음:

- `plan-template.md` - 커리큘럼 구조 템플릿
- `task-template.md` - 작업 체크리스트 템플릿
- `persona-template.md` - 페르소나 정의 템플릿
- `project-context-template.md` - 프로젝트 컨텍스트 템플릿
- `claude-md-template.md` - CLAUDE.md 가이드라인 템플릿

#### project-interview

인터뷰 가이드 및 템플릿:

- `conversation-flow.md` - 대화 예시 및 가이드
- `interview-data-template.md` - 인터뷰 데이터 저장 형식

#### domain-profiles

도메인별 작성 전략:

- `technology.md` - 기술 분야 프로필
- `history.md` - 역사 분야 프로필
- `science.md` - 과학 분야 프로필
- `arts.md` - 예술 분야 프로필
- `language.md` - 일반/언어 분야 프로필

### 플러그인 디렉토리 구조

```
dokhak/
├── .claude-plugin/
│   └── plugin.json           # 플러그인 메타데이터
├── commands/                 # 사용자 명령어 정의
│   ├── init.md
│   ├── write.md          # researcher→writer→reviewer 파이프라인
│   ├── continue.md
│   ├── status.md
│   └── doctor.md             # 구조 진단 및 대화형 수정
├── skills/                   # 재사용 가능한 스킬
│   ├── project-scaffolder/
│   ├── project-interview/
│   └── domain-profiles/
└── agents/                   # AI 에이전트 정의
    ├── project-interviewer.md
    ├── researcher.md
    ├── writer.md
    ├── reviewer.md           # 문서 품질 검토
    ├── research-collector.md
    └── structure-designer.md
```

---

## 생성되는 프로젝트 구조

`/dokhak:init` 실행 후 생성되는 파일들:

```
your-project/
├── persona.md           # 작가/독자 페르소나 (Empathy Data 포함)
├── interview-data.md    # 인터뷰 원본 응답
├── plan.md              # 전체 커리큘럼 구조
├── task.md              # 작업 체크리스트 (세션 마커 포함)
├── project-context.md   # 프로젝트 맥락 및 리서치 결과
├── CLAUDE.md            # Claude용 프로젝트 가이드라인
└── docs/                # 생성된 문서들이 저장되는 디렉토리
    ├── 01-1-introduction.md
    ├── 01-2-getting-started.md
    └── ...
```

---

## 팁

### 효율적인 사용법

- **배치 작업 추천**: `/dokhak:continue 5`처럼 여러 섹션을 한 번에 작성하면 효율적입니다
- **진행 상황 수시 확인**: `/dokhak:status`로 현재 진행률을 확인하며 작업하세요
- **페르소나 커스터마이징**: `persona.md`를 수정하면 문서의 톤과 스타일을 조절할 수 있습니다

### persona.md 커스터마이징

수정할 수 있는 주요 섹션:

- **Reader Profile**: 대상 독자의 수준과 배경 조정
- **Empathy Data**: 학습자의 구체적인 고민 추가 (Says, Thinks, Does, Feels)
- **Domain Guidelines**: 도메인별 세부 요구사항 조정
- **Terminology Policy**: 기술 용어 설명 방식 정의

### 주의사항

- 프로젝트 초기화는 **빈 디렉토리**에서 실행하세요
- `task.md`를 직접 수정하면 진행 상황 추적이 깨질 수 있습니다
- 웹 리서치가 필요하므로 **인터넷 연결**이 필수입니다

---

## 자주 묻는 질문 (FAQ)

### Q: 인터뷰를 빠르게 끝내고 싶어요

처음부터 맥락을 풍부하게 제공하세요. "React요" 대신 "취업 준비 중인데 React를 배우고 싶어요. HTML/CSS는 알지만 JavaScript는 초보예요." 처럼 말하면 인터뷰어가 적응해서 질문을 줄입니다.

### Q: 문서 작성이 중간에 중단되었어요

`/dokhak:status`로 현재 상태를 확인하고, `/dokhak:write`을 다시 실행하면 중단된 지점부터 이어서 작성합니다.

### Q: 커리큘럼 구조를 수정하고 싶어요

`plan.md`와 `task.md`를 직접 편집한 후 `/dokhak:doctor`로 일관성을 확인하세요.

### Q: 생성된 문서의 품질이 마음에 들지 않아요

1. `persona.md`에서 작가 페르소나를 더 상세히 정의해보세요
2. `project-context.md`에 추가 맥락 정보를 기입하세요
3. 해당 섹션의 문서를 삭제하고 `task.md`에서 상태를 `[ ]`로 되돌린 후 다시 작성하세요

### Q: 영어 문서를 생성하고 싶어요

인터뷰 시작 시 영어로 응답하세요. 인터뷰어가 영어로 인사하면 영어로 대화를 이어가며, 최종 문서도 영어로 생성됩니다.

---

## 라이선스

MIT
