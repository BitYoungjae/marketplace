# Mermaid Extension Session Prompts

## Session 1: High Priority Diagrams

```
@contexts/obsidian/plan.md @contexts/obsidian/task.md
@contexts/cc/skills.md @contexts/cc/prompt-engineering/use-xml-tags.md

Session 1 실행: mermaid-diagramming 스킬에 High priority 다이어그램 3개 추가

대상:
- erDiagram (Entity Relationship)
- journey (User Journey)
- timeline (Timeline)

작업:
1. 각 다이어그램의 공식 Mermaid 문서 조사
2. 기존 flowchart.md 형식 참고하여 각 다이어그램 파일 생성
3. SKILL.md 업데이트 (selection guide, quick start, references)
4. task.md의 Session 1 체크박스 업데이트

기존 파일 형식 참조: plugins/obsidian-blocks/skills/mermaid-diagramming/flowchart.md
```

---

## Session 2: Chart Diagrams

```
@contexts/obsidian/plan.md @contexts/obsidian/task.md
@contexts/cc/skills.md @contexts/cc/prompt-engineering/multishot-prompting.md

Session 2 실행: mermaid-diagramming 스킬에 Chart 다이어그램 3개 추가

대상:
- quadrantChart (Quadrant Chart)
- sankey-beta (Sankey Diagram)
- xychart-beta (XY Chart)

작업:
1. 각 다이어그램의 공식 Mermaid 문서 조사
2. 기존 파일 형식 참고하여 각 다이어그램 파일 생성
3. SKILL.md 업데이트
4. task.md의 Session 2 체크박스 업데이트

기존 파일 형식 참조: plugins/obsidian-blocks/skills/mermaid-diagramming/flowchart.md
```

---

## Session 3: Architecture Diagrams

```
@contexts/obsidian/plan.md @contexts/obsidian/task.md
@contexts/cc/sub-agents.md @contexts/cc/prompt-engineering/chain-prompts.md

Session 3 실행: mermaid-diagramming 스킬에 Architecture 다이어그램 3개 추가

대상:
- block-beta (Block Diagram)
- architecture-beta (Architecture Diagram)
- C4Context (C4 Diagram)

작업:
1. 각 다이어그램의 공식 Mermaid 문서 조사
2. 기존 파일 형식 참고하여 각 다이어그램 파일 생성
3. SKILL.md 업데이트
4. task.md의 Session 3 체크박스 업데이트

기존 파일 형식 참조: plugins/obsidian-blocks/skills/mermaid-diagramming/flowchart.md
```

---

## Session 4: Low Priority + Finalize

```
@contexts/obsidian/plan.md @contexts/obsidian/task.md
@contexts/cc/plugins-reference.md @contexts/cc/prompt-engineering/be-clear-and-direct.md

Session 4 실행: mermaid-diagramming 스킬에 Low priority 다이어그램 3개 추가 및 마무리

대상:
- packet-beta (Network Packet)
- requirementDiagram (Requirement Diagram)
- zenuml (ZenUML)

작업:
1. 각 다이어그램의 공식 Mermaid 문서 조사
2. 기존 파일 형식 참고하여 각 다이어그램 파일 생성
3. SKILL.md 업데이트
4. task.md의 Session 4 체크박스 업데이트
5. 버전 업데이트:
   - plugins/obsidian-blocks/.claude-plugin/plugin.json
   - .claude-plugin/marketplace.json
6. task.md Progress Summary 최종 업데이트

기존 파일 형식 참조: plugins/obsidian-blocks/skills/mermaid-diagramming/flowchart.md
```

---

## Context References

| Reference | Purpose |
|-----------|---------|
| `contexts/cc/skills.md` | Skill file structure and conventions |
| `contexts/cc/sub-agents.md` | Agent usage patterns |
| `contexts/cc/plugins-reference.md` | Plugin JSON format |
| `contexts/cc/prompt-engineering/use-xml-tags.md` | Structured output |
| `contexts/cc/prompt-engineering/multishot-prompting.md` | Example-based learning |
| `contexts/cc/prompt-engineering/chain-prompts.md` | Multi-step workflows |
| `contexts/cc/prompt-engineering/be-clear-and-direct.md` | Clear instructions |
