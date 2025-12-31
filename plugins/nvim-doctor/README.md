# nvim-doctor

**Diagnose and fix your Neovim configuration issues with AI-powered analysis.**

Like `brew doctor` for your Neovim setup - nvim-doctor helps you troubleshoot plugin conflicts, keybinding problems, performance bottlenecks, LSP issues, and configuration errors.

[한국어 문서](./README.ko.md)

## Features

- **Error Diagnosis**: Analyze Lua error messages, stack traces, and identify root causes
- **Configuration Audit**: Grade your config A-F based on structure, performance, security, and compatibility
- **Plugin Investigation**: Research plugin version compatibility and breaking changes via GitHub
- **Keymap Debugging**: Diagnose leader/localleader issues, mode conflicts, and which-key problems
- **LSP Troubleshooting**: Debug server attachment, capabilities, and language-specific setup
- **Performance Analysis**: Profile startup time, identify bottlenecks, optimize lazy loading
- **Security Checking**: Detect exposed credentials, insecure commands, and modeline/exrc risks
- **Deprecated API Detection**: Track Neovim 0.9-0.12 API changes and migrations

## Installation

```bash
# Add marketplace
/plugin marketplace add bityoungjae/marketplace

# Install plugin
/plugin install nvim-doctor@bityoungjae-marketplace
```

## Usage

### `/nvim-doctor:diagnose <error-message-or-symptom>`

Main entry point for Neovim problem diagnosis.

```
/nvim-doctor:diagnose "E5108: Error executing lua: attempt to index nil value"
```

```
/nvim-doctor:diagnose "keymaps not working after update"
```

```
/nvim-doctor:diagnose "slow startup time"
```

```
/nvim-doctor:diagnose "LSP not attaching to Python files"
```

The command automatically:
1. Gathers system information (Neovim version, config path, plugin count, startup time)
2. Classifies your problem type
3. Routes to the appropriate specialized agent

## Architecture

nvim-doctor uses a multi-agent architecture where each agent specializes in a specific type of diagnosis:

```
User Problem
    │
    ▼
┌───────────────────────────┐
│  /nvim-doctor:diagnose    │  ← Entry point
│     (main command)        │
└───────────────────────────┘
    │
    ├─── Complex diagnosis ──→ nvim-diagnostician (sonnet)
    │                          Uses: neovim-debugging skill
    │
    ├─── Config review ──────→ config-auditor (haiku)
    │                          Uses: config-auditing skill
    │
    └─── Plugin issues ──────→ plugin-investigator (haiku)
                               Uses: WebSearch for GitHub research
```

### Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| `nvim-diagnostician` | Sonnet | Deep root cause analysis with hypothesis testing |
| `config-auditor` | Haiku | Fast configuration scanning and A-F grading |
| `plugin-investigator` | Haiku | Plugin version compatibility and GitHub research |

### Skills (Knowledge Bases)

**neovim-debugging**
- Diagnostic flowcharts for common issues
- Error pattern database with solutions
- Plugin-specific debugging guides (lazy.nvim, which-key, LSP, Treesitter, Telescope, nvim-cmp, Snacks.nvim, LazyVim)

**config-auditing**
- 5-category audit checklist (Structure, Performance, Security, Compatibility, Redundancy)
- Best practices for lazy.nvim, vim.opt, keymaps
- Deprecated API reference for Neovim 0.9-0.12

## Audit Grading System

When auditing your configuration, nvim-doctor assigns a grade:

| Grade | Criteria | Meaning |
|-------|----------|---------|
| **A** | 0 Critical, 0-2 Warnings | Excellent - Production ready |
| **B** | 0 Critical, 3-5 Warnings | Good - Minor improvements possible |
| **C** | 0 Critical, 6+ Warnings OR 1 Critical | Acceptable - Should address issues |
| **D** | 2-3 Critical issues | Poor - Needs attention |
| **F** | 4+ Critical issues | Failing - Immediate fixes required |

## Diagnosis Output Format

nvim-doctor provides structured, evidence-based diagnoses:

```xml
<diagnosis>
  Root Cause: [identified cause with evidence]
  Evidence: [commands/files that confirmed it]
  Solution: [specific steps to fix]
  Prevention: [how to avoid in future]
</diagnosis>
```

## Supported Neovim Distributions

- Vanilla Neovim configurations
- LazyVim
- NvChad
- AstroNvim
- LunarVim
- Custom configurations

## Requirements

- Claude Code CLI
- Neovim 0.9+ (for full compatibility checking)
- Access to your Neovim configuration directory

## License

MIT

## Author

**BitYoungjae** - [bityoungjae@gmail.com](mailto:bityoungjae@gmail.com)
