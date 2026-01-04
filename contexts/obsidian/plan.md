# Mermaid Diagram Support Extension Plan

**Goal**: Add 12 new diagram types to `mermaid-diagramming` skill across 4 sessions.

**Target**: `plugins/obsidian-blocks/skills/mermaid-diagramming/`

---

## Session Structure

| Session | Priority | Diagrams | Files to Create |
|---------|----------|----------|-----------------|
| 1 | High | erDiagram, journey, timeline | 3 |
| 2 | Medium-1 | quadrantChart, sankey-beta, xychart-beta | 3 |
| 3 | Medium-2 | block-beta, architecture-beta, C4Context | 3 |
| 4 | Low | packet-beta, requirementDiagram, zenuml | 3 |

---

## Per-Diagram Deliverables

1. **Dedicated file**: `{diagram-name}.md` with complete reference
2. **SKILL.md update**: Add to selection guide table + quick start example
3. **Consistency**: Match existing file format (reference, direction, syntax tables, practical examples)

---

## File Format Template

Each diagram file follows existing pattern:
- Title + intro
- Syntax reference tables
- Basic examples
- Advanced features
- Practical examples (2-3)
- Obsidian notes
- Quick reference table

---

## Version Update

After Session 4: Bump version in both:
- `plugins/obsidian-blocks/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
