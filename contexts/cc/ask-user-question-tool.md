# AskUserQuestion Tool

> Claude Code의 대화형 질문 도구 - 실행 중 사용자에게 질문하여 정보를 수집합니다.

## 개요

`AskUserQuestion` 도구는 Claude Code가 작업 실행 중 사용자에게 구조화된 객관식 질문을 통해 입력을 받을 수 있게 해주는 내부 도구입니다. 이 도구는 AI가 실행을 일시 중지하고 사용자에게 일련의 질문을 할 수 있게 합니다.

## 목적

AskUserQuestion 도구를 사용하면 다음을 수행할 수 있습니다:

1. **사용자 선호도 또는 요구사항 수집** - 구현 전에 사용자의 선호를 파악
2. **모호한 지시사항 명확화** - 불확실한 요구사항을 구체화
3. **작업 중 구현 선택에 대한 결정 받기** - 진행하면서 필요한 결정을 사용자에게 위임
4. **사용자에게 방향에 대한 선택지 제공** - 여러 가능한 접근 방식 중 선택 요청

## 주요 기능

### 질문 구조

- 호출당 1-4개의 질문 지원
- 각 질문은 2-4개의 상호 배타적인 옵션 제공
- "Other" 옵션이 자동으로 제공되어 사용자 정의 입력 가능
- `multiSelect: true`를 통한 다중 선택 기능 제공

### 매개변수

```typescript
{
  questions: [
    {
      question: string,      // 완전한 질문 텍스트
      header: string,        // 매우 짧은 레이블 (최대 12자)
      multiSelect: boolean,  // 다중 선택 허용 여부
      options: [             // 2-4개의 선택지
        {
          label: string,       // 표시 텍스트 (1-5단어)
          description: string  // 선택지에 대한 설명
        }
      ]
    }
  ]
}
```

### 매개변수 상세

| 매개변수 | 설명 | 제약 조건 |
|---------|------|----------|
| `question` | 사용자에게 표시할 완전한 질문 텍스트 | 명확하고 구체적이어야 하며 물음표로 끝나야 함 |
| `header` | 칩/태그로 표시되는 짧은 레이블 | 최대 12자 (예: "Auth method", "Library") |
| `multiSelect` | 다중 선택 허용 여부 | boolean, 선택지가 상호 배타적이지 않을 때 true |
| `options` | 선택 가능한 옵션 배열 | 2-4개 필수, "Other"는 자동 추가되므로 포함하지 말 것 |
| `label` | 옵션의 표시 텍스트 | 1-5단어로 간결하게 |
| `description` | 옵션에 대한 설명 | 선택 시 발생할 일이나 트레이드오프 설명 |

## 사용 시나리오

### 적절한 사용 시점

- 구현 경로가 분기될 때
- 요구사항이 명확하지 않을 때
- 사용자의 결정이 진행 중인 작업에 영향을 미칠 때
- Plan 모드에서 접근 방식을 명확히 해야 할 때

### 권장 사항 표시

특정 옵션을 권장할 경우:
- 해당 옵션을 목록의 첫 번째로 배치
- 레이블 끝에 "(Recommended)"를 추가

```typescript
options: [
  {
    label: "JWT Authentication (Recommended)",
    description: "Stateless, scalable, and industry standard"
  },
  {
    label: "Session-based Authentication",
    description: "Traditional approach with server-side state"
  }
]
```

## 사용 예시

### 기본 사용

```typescript
{
  questions: [
    {
      question: "Which authentication method should we use?",
      header: "Auth",
      multiSelect: false,
      options: [
        {
          label: "JWT (Recommended)",
          description: "Stateless tokens, good for APIs"
        },
        {
          label: "OAuth 2.0",
          description: "Third-party authentication support"
        },
        {
          label: "Session-based",
          description: "Traditional server-side sessions"
        }
      ]
    }
  ]
}
```

### 다중 선택 예시

```typescript
{
  questions: [
    {
      question: "Which features do you want to enable?",
      header: "Features",
      multiSelect: true,
      options: [
        {
          label: "Dark mode",
          description: "Theme switching support"
        },
        {
          label: "Notifications",
          description: "Push notification system"
        },
        {
          label: "Analytics",
          description: "Usage tracking and reporting"
        }
      ]
    }
  ]
}
```

### Plan 모드에서의 활용

Plan 모드에서 모호함 처리:

1. `AskUserQuestion` 도구를 사용하여 사용자에게 명확히 질문
2. 특정 구현 선택에 대해 질문 (예: 아키텍처 패턴, 사용할 라이브러리)
3. 구현에 영향을 미칠 수 있는 가정 명확화
4. 사용자 피드백을 반영하여 계획 파일 수정
5. 모호함을 해결하고 계획 파일을 업데이트한 후에만 ExitPlanMode 진행

## 기술적 제약

- 옵션 레이블은 1-5단어로 간결하게 유지
- 헤더는 최대 12자로 제한
- 질문당 2-4개의 옵션 필수
- "Other" 옵션은 스키마에 수동으로 포함하지 말 것 (자동 추가됨)
- 단일 선택 질문이 마지막 질문일 경우 자동 제출됨

## 관련 도구 및 개념

- **EnterPlanMode**: 비사소한 구현 작업 시작 전 계획 모드 진입
- **ExitPlanMode**: 계획 완료 후 사용자 승인을 위해 계획 모드 종료
- **TodoWrite**: 작업 추적 및 계획 관리

## 참고 자료

- [GitHub Issue #10346](https://github.com/anthropics/claude-code/issues/10346) - AskUserQuestion 도구 문서화 요청
- [Claude Code System Prompts](https://github.com/Piebald-AI/claude-code-system-prompts) - 시스템 프롬프트 참조

---

> 이 문서는 Claude Code의 AskUserQuestion 도구에 대한 비공식 문서입니다.
> 공식 문서가 제공되면 업데이트가 필요할 수 있습니다.
