---
description: Comprehensive Neovim diagnostics - errors, keymap conflicts, performance issues
allowed-tools: Bash(nvim:*), Bash(cat:*), Bash(ls:*), Read, Grep, Glob, Task
argument-hint: <error-message-or-symptom>
---

## System Information

<system_info>
- Neovim version: !`nvim --version | head -3`
- Config path: !`nvim --headless -c "lua print(vim.fn.stdpath('config'))" -c "qa" 2>&1`
- Plugin count: !`ls ~/.local/share/nvim/lazy 2>/dev/null | wc -l || echo "N/A"`
- Startup time: !`nvim --headless --startuptime /tmp/nvim-startup.log -c "qa" && tail -1 /tmp/nvim-startup.log`
</system_info>

## User Problem

$ARGUMENTS

## Task

<instructions>
You are a Neovim troubleshooting expert. Analyze the system information and user's problem description above.

1. **Classify the problem type**:
   - Startup Error: Crashes or errors during initialization
   - Plugin Conflict: Incompatible or conflicting plugins
   - Keymap Issue: Key bindings not working or conflicting
   - LSP Issue: Language server problems
   - Performance Issue: Slow startup, high memory usage
   - Configuration Error: Invalid settings, deprecated APIs

2. **Formulate hypotheses** and create a verification plan.

3. **Delegate to specialized agents** based on complexity:
   - Complex error diagnosis → `nvim-diagnostician` agent
   - Full configuration review → `config-auditor` agent
   - Specific plugin investigation → `plugin-investigator` agent

4. **Communicate in the user's language** throughout the diagnosis process.
</instructions>
