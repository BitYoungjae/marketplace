# Obsidian Mermaid Support Reference

Obsidian 1.8.0+ uses **Mermaid 11.3.0**.

## Supported Diagram Types

### Currently in mermaid-diagramming skill (8)

| Diagram | Keyword |
|---------|---------|
| Flowchart | `flowchart` |
| Sequence | `sequenceDiagram` |
| Class | `classDiagram` |
| Gantt | `gantt` |
| State | `stateDiagram-v2` |
| Gitgraph | `gitGraph` |
| Mindmap | `mindmap` |
| Pie | `pie` |

### Available to Add (12)

| Diagram | Keyword | Since | Priority |
|---------|---------|-------|----------|
| Entity Relationship | `erDiagram` | v9.0 | High |
| User Journey | `journey` | v9.0 | High |
| Timeline | `timeline` | v10.1 | High |
| Quadrant Chart | `quadrantChart` | v10.2 | Medium |
| Sankey | `sankey-beta` | v10.3 | Medium |
| XY Chart | `xychart-beta` | v10.6 | Medium |
| Block | `block-beta` | v10.9 | Medium |
| Architecture | `architecture-beta` | v11.1 | Medium |
| C4 Diagram | `C4Context` | v10.0 | Medium |
| Packet | `packet-beta` | v11.0 | Low |
| Requirement | `requirementDiagram` | v8.11 | Low |
| ZenUML | `zenuml` | v9.4 | Low |

### Not Supported (version > 11.3.0)

| Diagram | Keyword | Requires |
|---------|---------|----------|
| Kanban | `kanban` | v11.4+ |
| Radar | `radar-beta` | v11.6+ |
| Treemap | `treemap-beta` | v11.x late |

## Sources

- [Obsidian 1.8.0 Changelog](https://obsidian.md/changelog/2024-12-18-desktop-v1.8.0/)
- [Mermaid.js Official](https://mermaid.js.org/intro/)
