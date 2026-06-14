# bityoungjae-marketplace

A Claude Code plugin marketplace by BitYoungjae.

## Installation

```bash
/plugin marketplace add bityoungjae/marketplace
```

## Plugins

### [dokhak](./plugins/dokhak/)

> *Burn tokens, earn knowledge.*

Self-learning resource creation plugin. Specify a topic and Dokhak automates the entire workflow from project scaffolding to document generation.

```bash
/plugin install dokhak@bityoungjae-marketplace
```

**Features:**
- Conversational interview for personalized learning materials
- Domain-adaptive generation (technology, history, science, arts, language)
- Automated web research and curriculum design
- Document generation with consistent structure

### [nvim-doctor](./plugins/nvim-doctor/)

> *Like `brew doctor` for your Neovim setup.*

Diagnose and fix your Neovim configuration issues with AI-powered analysis. Troubleshoots plugin conflicts, keybinding problems, performance bottlenecks, LSP issues, and configuration errors.

```bash
/plugin install nvim-doctor@bityoungjae-marketplace
```

**Features:**
- Error diagnosis with root cause analysis
- Configuration audit with A-F grading
- Plugin version compatibility investigation
- Deprecated API detection (Neovim 0.9-0.12)
- Support for LazyVim, NvChad, AstroNvim, and custom configs

### [obsidian-blocks](./plugins/obsidian-blocks/)

> *Visual content through code blocks.*

Skills for writing visual content in Obsidian using code blocks. Formulas, graphs, diagrams, and more beyond plain text.

```bash
/plugin install obsidian-blocks@bityoungjae-marketplace
```

**Commands:**
- `/enhance <file-path>`: Analyze and enhance documents with visual elements

**Skills:**
- `mathjax-rendering`: LaTeX formula syntax and MathJax rendering
- `desmos-graphing`: Interactive graphs with Desmos
- `mermaid-diagramming`: 16 types of Mermaid diagrams
- `tikzjax-diagramming`: TikZ diagrams (geometry, circuits, chemistry, 3D plots)

### [gitkkal](./plugins/gitkkal/)

> *Commit smarter, not harder.*
>
> Named after Korean "기깔나다" (giggal-nada), meaning stylish or impressive.

Automate Git workflows—smart branch naming, flexible commit styles, and PR generation.

```bash
/plugin install gitkkal@bityoungjae-marketplace
```

**Commands:**
- `/gitkkal:init`: Configure commit style and preferences
- `/gitkkal:branch`: Create a branch based on your changes
- `/gitkkal:commit`: Generate commits in your preferred style
- `/gitkkal:pr`: Create or update a pull request

### [hermes-tweet](./plugins/hermes-tweet/)

> *Read first, act with approval.*

Native Hermes Agent X/Twitter plugin for Xquik automation with read-first workflows and approval-gated actions.

```bash
/plugin install hermes-tweet@bityoungjae-marketplace
```

**Skills:**
- `hermes-tweet`: Guide Hermes Agent X/Twitter workflows with safe endpoint discovery, runtime credential setup, and action gating

### [omarchy](./plugins/omarchy/)

> *Theme once, apply everywhere.*

Skills for creating and managing themes in Omarchy, a Hyprland-based Linux desktop environment. Define colors once in a TOML file, automatically generate configs for 13+ applications.

```bash
/plugin install omarchy@bityoungjae-marketplace
```

**Features:**
- 22 color variables with automatic config generation
- Support for terminals (Alacritty, Kitty, Ghostty)
- Hyprland, Waybar, Walker, Mako integration
- Dark and light theme support

**Skills:**
- `omarchy-theming`: Template-based theme creation with colors.toml

## License

MIT
