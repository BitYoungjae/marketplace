# Task Tool (서브에이전트) 컨텍스트 동작 메커니즘

> Claude Code의 Task tool을 사용한 서브에이전트의 컨텍스트 격리 및 절약 전략

## 핵심 원리

**서브에이전트는 메인 세션과 별도의 컨텍스트 윈도우에서 동작하며, 최종 응답만 메인 세션에 반환됩니다.**

---

## 1. 파일 쓰기(Write) 후 메인 세션 컨텍스트 포함 여부

**결론: 파일 내용은 메인 세션 컨텍스트에 자동 포함되지 않음**

```
서브에이전트
    ├─ Write tool로 파일 저장 (예: .research/summary.md)
    └─ "Research saved to .research/ (10 sources)" 요약 반환
         ↓
메인 세션 컨텍스트
    └─ 요약 메시지만 포함 (파일 내용 없음!)
```

- 서브에이전트가 파일을 Write tool로 저장하면, **파일의 전체 내용이 메인 세션 컨텍스트에 자동 포함되지 않음**
- 서브에이전트는 **"concise resulting context"(간결한 결과 컨텍스트)만 반환**
- 메인 세션에서 파일 내용을 사용하려면 **명시적으로 Read tool로 읽어야 함**

---

## 2. 서브에이전트 내부의 파일 읽기(Read) 내용

**결론: 서브에이전트의 Read 내용은 서브에이전트 컨텍스트에만 존재**

```
서브에이전트 컨텍스트 (격리됨)
    ├─ Read: file1.md (5,000 토큰)
    ├─ Read: file2.md (3,000 토큰)
    ├─ WebFetch: url1 (10,000 토큰)
    └─ 총 18,000 토큰 처리
         ↓
         요약 생성 (500 토큰)
         ↓
메인 세션 컨텍스트
    └─ 500 토큰만 추가됨 (17,500 토큰 절약!)
```

- 서브에이전트가 파일을 Read하면, 그 내용은 **서브에이전트의 격리된 컨텍스트 윈도우 내에만 유지**
- 읽은 파일이 메인 세션으로 자동 반환되지 않음
- 서브에이전트가 **의도적으로 요약/추출하여 반환하는 것만** 메인 세션에 포함

---

## 3. Task Tool 결과 반환 메커니즘

### 정확한 흐름

```
1. Task tool 호출
   Task(subagent_type="researcher", prompt="...")
         ↓
2. 서브에이전트 실행 (독립적 컨텍스트 윈도우)
   ├─ Read/Grep/Write/Bash/WebSearch/WebFetch 실행
   ├─ 모든 중간 결과는 서브에이전트 컨텍스트에만 존재
   └─ 서브에이전트가 최종 요약 생성
         ↓
3. Task tool result 반환
   ├─ 서브에이전트가 생성한 텍스트 응답만 포함
   ├─ 명시적으로 제공한 요약/결과만
   └─ 읽은 파일 전체나 중간 작업 내역은 포함 안 됨
         ↓
4. 메인 세션 컨텍스트에 추가
   └─ Task tool의 최종 결과만 포함
```

### 중요한 세부사항

- 서브에이전트 내 tool_use 블록들은 `parent_tool_use_id` 필드로 추적됨
- 서브에이전트의 전체 대화는 메인 세션에서 **기본적으로 숨김** (Ctrl+O로 확인 가능)
- Task tool 결과만 메인 대화에 직접 나타남

---

## 4. 컨텍스트 절약 전략의 실제 효과

**결론: 효과가 있음 - 시스템 차원에서 검증된 기능**

### 컨텍스트 절약 메커니즘

| 메커니즘          | 설명                                                 |
| ----------------- | ---------------------------------------------------- |
| **컨텍스트 격리** | 서브에이전트는 별도의 컨텍스트 윈도우 사용           |
| **도구 격리**     | 비싼 작업(웹 fetch, API 호출)이 서브에이전트에 격리  |
| **결과 압축**     | 중간 도구 호출, 실패, 재시도 과정은 메인에 영향 없음 |

### 정량적 효과 예시

```
리서치 서브에이전트 없이:
├─ 10개 URL fetch → 각 5,000 토큰 = 50,000 토큰
└─ 메인 컨텍스트에 전부 포함

리서치 서브에이전트 사용:
├─ 10개 URL fetch (서브에이전트 컨텍스트)
├─ 500 토큰 요약만 메인으로 반환
└─ 메인 절약: 49,500 토큰
```

### 효과적인 사용 케이스

1. **리서치 헤비한 작업**: 많은 웹/파일 리소스를 읽고 요약
2. **중간 결과가 필요 없는 경우**: 최종 결과만 필요할 때
3. **병렬 처리**: 여러 서브에이전트 동시 실행

---

## 5. 실용적인 활용 패턴

### 패턴 1: 조사 후 파일 저장 + 요약 반환

```markdown
## 서브에이전트 프롬프트 예시

조사를 수행하고 결과를 파일로 저장하세요.

### Output Process

1. WebSearch/WebFetch로 조사 수행
2. Write tool로 .research/summary.md에 저장
3. 메인 세션에는 다음 형식으로만 반환:
   "Research saved to .research/summary.md (X sources, Y concepts)"

IMPORTANT: 조사 내용 전체를 반환하지 마세요.
```

**효과**: 조사 내용(수만 토큰) → 확인 메시지(50 토큰)로 압축

### 패턴 2: 파일 분석 후 요약만 반환

```markdown
## 서브에이전트 프롬프트 예시

다음 파일들을 분석하고 핵심만 요약하세요:

- src/\*_/_.ts
- docs/\*.md

### Output Format

분석 결과를 300토큰 이내로 요약하세요.
전체 파일 내용을 반환하지 마세요.
```

**효과**: 수십 개 파일(10만 토큰) → 요약(300 토큰)

### 패턴 3: 작업 수행 후 결과 확인만 반환

```markdown
## 서브에이전트 프롬프트 예시

docs/01-1-intro.md 문서를 작성하세요.

### Output Constraints

반환 형식:
"{filename} written ({line_count} lines)"

문서 내용을 반환하지 마세요.
```

**효과**: 문서 내용(수천 토큰) → 확인 메시지(20 토큰)

---

## 6. 주의사항

### 메인 세션에서 파일 사용 시

서브에이전트가 생성한 파일을 메인 세션에서 사용하려면 **명시적으로 Read**해야 합니다:

```
서브에이전트 A: .research/summary.md 생성
         ↓
메인 세션: 파일 존재는 알지만 내용은 모름
         ↓
Read tool로 .research/summary.md 읽기
         ↓
이제 메인 컨텍스트에 포함됨
```

### 컨텍스트 절약을 극대화하려면

1. **서브에이전트 응답 제한**: 명시적으로 토큰 제한 지정
2. **파일에 저장 후 확인만 반환**: 전체 내용 대신 경로만 알려줌
3. **다음 에이전트가 파일 직접 읽기**: 필요할 때만 Read

---

## 7. dokhak 플러그인 적용 예시

```
researcher (haiku 서브에이전트)
    ├─ WebSearch/WebFetch로 10개 URL 조사 (서브에이전트 컨텍스트)
    ├─ .research/sections/01-1/research.md에 Write
    └─ "Research saved (10 sources, 5 concepts)" 반환 (50 토큰)
         ↓
메인 세션 컨텍스트: 50 토큰만 추가
         ↓
writer (opus 서브에이전트)
    ├─ Read .research/sections/01-1/research.md (writer 컨텍스트)
    ├─ Read persona.md (writer 컨텍스트)
    ├─ docs/01-1-intro.md에 Write
    └─ "01-1-intro.md written (450 lines)" 반환 (30 토큰)
         ↓
메인 세션 컨텍스트: 30 토큰만 추가
```

**총 절약**: 조사 내용 + 문서 내용이 메인 컨텍스트에 포함되지 않음

---

## 참고 자료

- [Subagents in the SDK - Claude Docs](https://platform.claude.com/docs/en/agent-sdk/subagents)
- [Subagents in Claude Code - Claude Code Docs](https://code.claude.com/docs/en/sub-agents)
- [Context Management with Subagents](https://www.richsnapp.com/article/2025/10-05-context-management-with-subagents-in-claude-code)
- [Building agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)
