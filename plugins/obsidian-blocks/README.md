# obsidian-blocks

**Skills for writing visual content in Obsidian using code blocks.**

Formulas (LaTeX), graphs (Desmos), diagrams (Mermaid, TikZ), and more.

## Installation

```bash
/plugin marketplace add bityoungjae/marketplace
/plugin install obsidian-blocks@bityoungjae-marketplace
```

## Commands

### /enhance

Analyze and enhance Obsidian documents with visual elements.

```bash
/enhance path/to/document.md
```

The command delegates to the `doc-enhancer` agent, which:
- Reads and analyzes your document
- Identifies opportunities for visual enhancement
- Adds Mermaid diagrams, Desmos graphs, MathJax formulas, or TikZJax drawings
- Applies restraint: only enhances where it genuinely improves clarity

## Skills

### mathjax-rendering

LaTeX formula syntax for Obsidian's MathJax renderer.

- Inline/display math, fractions, matrices, limits
- Greek letters, operators, spacing
- Aligned equations, cases, multi-line

### desmos-graphing

Interactive graph creation with Desmos plugin.

- Function plotting, parametric curves, polar graphs
- Points, labels, sliders, animations
- Piecewise functions, inequalities, implicit curves

### mermaid-diagramming

Mermaid diagrams for visualizing processes and structures.

- Flowcharts, sequence diagrams, class diagrams
- Gantt charts, state diagrams, gitgraph
- Mindmaps, pie charts, ER diagrams
- User journeys, timelines, quadrant charts
- Sankey diagrams, XY charts
- Block diagrams, architecture diagrams

### tikzjax-diagramming

TikZ diagrams via TikZJax plugin for complex technical drawings.

- Geometric shapes with precise coordinates
- Circuit diagrams (circuitikz)
- Chemical structures (chemfig)
- 3D plots (tikz-3dplot, pgfplots)
- Commutative diagrams (tikz-cd)
- Game scenes, coordinate systems

**Note:** Requires [Obsidian TikZJax plugin](https://github.com/artisticat1/obsidian-tikzjax). English text only (Korean not supported).

## License

MIT
