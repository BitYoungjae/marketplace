# Claude Code Lesson Learned

실험과 경험을 통해 배운 것들을 기록합니다.

---

## Subagent 제한사항

### Nested Subagent 호출 불가

**결론**: Subagent 내부에서 다른 subagent를 호출할 수 없다.

**공식 문서**:
> "Subagents cannot spawn other subagents. If your workflow requires nested delegation, use Skills or chain subagents from the main conversation."

**동작 방식**:
- 에이전트 정의에서 `tools: Task`를 명시해도 런타임에서 자동 제거됨
- 무한 재귀와 컨텍스트 폭발 방지를 위한 의도된 설계

**대안**:
| 방식 | 설명 |
|------|------|
| 체이닝 | 메인 세션에서 순차적으로 여러 subagent 호출 |
| 병렬 실행 | 메인 세션에서 독립적인 subagent 동시 실행 |
| Skills | subagent 내에서도 Skill 호출 가능 |

**예시** (dokhak `/write` 파이프라인):
```
메인 명령 → researcher → writer → reviewer (순차 호출)
```

---
