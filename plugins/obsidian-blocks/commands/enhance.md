---
description: Analyze and enhance Obsidian documents with visual elements (Mermaid, Desmos, MathJax)
argument-hint: <file-path>
---

# Document Enhancement

Enhance the document at `$ARGUMENTS` with visual elements.

Use the `doc-enhancer` agent to perform this task. The agent has access to:
- **mermaid-diagramming** skill: 16 diagram types for processes, structures, timelines
- **desmos-graphing** skill: Interactive function graphs
- **mathjax-rendering** skill: LaTeX formula rendering

Delegate the following to the agent:
1. Read and analyze the target document: `$ARGUMENTS`
2. Identify enhancement opportunities (diagrams, graphs, formulas)
3. Apply restrained, contextually appropriate visual elements
4. Preserve the document's original flow and voice
