---
description: Comprehensive Neovim diagnostics - errors, keymap conflicts, performance issues
allowed-tools: Bash(nvim:*), Bash(cat:*), Bash(ls:*), Read, Grep, Glob, Task
argument-hint: <error-message-or-symptom>
---

## System Information

<system_info>
- Neovim version: !`nvim --version 2>&1 || echo "nvim not found"`
- Config path: !`nvim --headless -c "lua print(vim.fn.stdpath('config'))" -c "qa" 2>&1 || echo "N/A"`
- Plugin count: !`nvim --headless -c "lua local ok,l=pcall(require,'lazy');print(ok and #vim.tbl_keys(l.plugins()) or 'N/A')" -c "qa" 2>&1 || echo "N/A"`
- Startup time: (measured by agent during diagnosis)
</system_info>

## User Problem

$ARGUMENTS

## Task

<instructions>
You are a Neovim troubleshooting expert. Analyze the system information and user's problem description above.

### Step 1: Classify the Problem

Use the Classification Matrix below to determine the problem type:

| Classification | Keywords/Signals | Primary Agent | Fallback Agent |
|----------------|------------------|---------------|----------------|
| `STARTUP_ERROR` | "E5108", "crash", "won't start", lua error stack trace | nvim-diagnostician | - |
| `PLUGIN_CONFLICT` | "after update", specific plugin name, "conflict", "broke" | plugin-investigator | nvim-diagnostician |
| `KEYMAP_ISSUE` | "key doesn't work", "which-key", "mapping", "leader" | nvim-diagnostician | config-auditor |
| `LSP_ISSUE` | "LSP", "language server", "no completion", ":LspInfo" | nvim-diagnostician | - |
| `PERFORMANCE` | "slow", "startup time", "lag", "freeze", "memory" | config-auditor | nvim-diagnostician |
| `CONFIG_AUDIT` | "review", "audit", "deprecated", "optimize" | config-auditor | - |
| `PLUGIN_VERSION` | "update", "version", "breaking change", "upgrade" | plugin-investigator | - |
| `GENERAL` | unclear or multiple issues | nvim-diagnostician | config-auditor |

### Step 2: Route to Specialized Agent

Based on classification, delegate to the appropriate agent using Task:

```
Task(
  subagent_type="nvim-doctor:{agent-name}",
  model="{agent-model}",
  description="Diagnose: {brief-summary}",
  prompt="""
    <diagnosis_request>
      <classification>{CLASSIFICATION}</classification>
      <confidence>{HIGH|MEDIUM|LOW}</confidence>
      <user_problem>
        {original user problem from $ARGUMENTS}
      </user_problem>
      <system_info>
        {collected system info from above}
      </system_info>
    </diagnosis_request>
  """
)
```

**Agent Selection:**
- `nvim-diagnostician` (opus): Complex errors, keymaps, LSP - requires deep reasoning
- `config-auditor` (haiku): Performance issues, config review - fast scanning
- `plugin-investigator` (haiku): Plugin versions, compatibility - GitHub research

### Step 3: Handle Agent Response

If agent returns `HANDOFF` status, invoke the target agent with the handoff context.

If agent returns `NEEDS_INVESTIGATION`, ask the user for more information.

If agent returns `RESOLVED`, present the diagnosis and solution to the user.

### Step 4: Communicate in User's Language

Match the language the user used in their problem description.
</instructions>

## Communication Schemas Reference

See `contexts/communication-schemas.md` for standardized XML formats used between agents.
