# Inter-Agent Communication Schemas

This document defines standardized XML formats for communication between nvim-doctor components (command → agents, agent → agent).

## Diagnosis Request (Command → Agent)

When the `/diagnose` command delegates to an agent:

```xml
<diagnosis_request>
  <classification>{STARTUP_ERROR|PLUGIN_CONFLICT|KEYMAP_ISSUE|LSP_ISSUE|PERFORMANCE|CONFIG_AUDIT|PLUGIN_VERSION|GENERAL}</classification>
  <confidence>{HIGH|MEDIUM|LOW}</confidence>
  <user_problem>
    {verbatim user input}
  </user_problem>
  <system_info>
    <neovim_version>{version}</neovim_version>
    <config_path>{path}</config_path>
    <plugin_manager>{lazy.nvim|packer.nvim|other}</plugin_manager>
    <plugin_count>{count}</plugin_count>
    <startup_time>{ms}</startup_time>
  </system_info>
</diagnosis_request>
```

### Classification Values

| Value | Description | Primary Agent |
|-------|-------------|---------------|
| `STARTUP_ERROR` | Crashes or errors during initialization | nvim-diagnostician |
| `PLUGIN_CONFLICT` | Incompatible or conflicting plugins | plugin-investigator |
| `KEYMAP_ISSUE` | Key bindings not working or conflicting | nvim-diagnostician |
| `LSP_ISSUE` | Language server problems | nvim-diagnostician |
| `PERFORMANCE` | Slow startup, high memory, lag | config-auditor |
| `CONFIG_AUDIT` | General review, deprecated APIs | config-auditor |
| `PLUGIN_VERSION` | Version updates, breaking changes | plugin-investigator |
| `GENERAL` | Unclear or multiple issues | nvim-diagnostician |

---

## Diagnosis Result Schemas

### nvim-diagnostician Output

```xml
<diagnosis_result status="{RESOLVED|NEEDS_INVESTIGATION|HANDOFF}">
  <thinking>
    <symptoms>
      - {observed symptom 1}
      - {observed symptom 2}
    </symptoms>
    <hypotheses>
      - H1: {hypothesis} - Likelihood: {HIGH|MEDIUM|LOW}
      - H2: {hypothesis} - Likelihood: {HIGH|MEDIUM|LOW}
    </hypotheses>
    <testing>
      - Test for H1: {command} → Result: {outcome}
      - Test for H2: {command} → Result: {outcome}
    </testing>
    <conclusion>
      Root cause: {identified cause}
      Evidence: {what confirmed this}
    </conclusion>
  </thinking>

  <diagnosis>
    <root_cause>{clear statement of what's wrong}</root_cause>
    <evidence>{specific data/output that proves this}</evidence>
    <solution>
      {step-by-step fix with code/commands}
    </solution>
    <prevention>{how to avoid this in future}</prevention>
  </diagnosis>

  <!-- Optional: if status="HANDOFF" -->
  <handoff target="{agent-name}">
    <reason>{why handoff needed}</reason>
    <context>{findings so far}</context>
    <specific_question>{what target should investigate}</specific_question>
  </handoff>
</diagnosis_result>
```

### config-auditor Output

```xml
<audit_report status="COMPLETE" grade="{A|B|C|D|F}">
  <summary>
    <neovim_version>{version}</neovim_version>
    <config_location>{path}</config_location>
    <plugin_manager>{manager}</plugin_manager>
    <plugin_count>{count}</plugin_count>
  </summary>

  <critical_issues count="{N}">
    <issue file="{path}" line="{N}">
      <title>{issue title}</title>
      <problem>{description}</problem>
      <fix>
        {specific code or command}
      </fix>
    </issue>
  </critical_issues>

  <warnings count="{N}">
    <warning file="{path}" line="{N}">
      <title>{warning title}</title>
      <problem>{description}</problem>
      <recommendation>{suggestion}</recommendation>
    </warning>
  </warnings>

  <suggestions count="{N}">
    <suggestion>
      <current>{what they're doing}</current>
      <better>{what they could do}</better>
    </suggestion>
  </suggestions>

  <statistics>
    | Metric | Value |
    |--------|-------|
    | Lua files | {N} |
    | Total lines | {N} |
    | Plugins | {N} |
    | Startup time | {N}ms |
    | Deprecated API calls | {N} |
    | Critical issues | {N} |
    | Warnings | {N} |
  </statistics>
</audit_report>
```

### plugin-investigator Output

```xml
<investigation_report status="{OK|OUTDATED|BREAKING_CHANGES|ERROR}">
  <plugin>
    <name>{plugin-name}</name>
    <installed_version>{commit hash or tag}</installed_version>
    <latest_version>{from GitHub}</latest_version>
    <status>{Up to date|Outdated by X versions|Breaking changes}</status>
  </plugin>

  <version_comparison>
    | Aspect | Installed | Latest |
    |--------|-----------|--------|
    | Commit | {hash} | {hash} |
    | Tag | {tag} | {tag} |
    | Neovim Req | {version} | {version} |
  </version_comparison>

  <recent_changes>
    <breaking_changes>
      - {breaking change 1}
      - {breaking change 2}
    </breaking_changes>
    <new_features>
      - {feature 1}
    </new_features>
    <bug_fixes>
      - {fix 1}
    </bug_fixes>
  </recent_changes>

  <known_issues>
    - [#{number}]({url}): {title} - {status}
  </known_issues>

  <compatibility>
    <neovim_required>{version}</neovim_required>
    <dependencies>
      - {dep1}: {status}
    </dependencies>
    <conflicts>
      - {conflicting plugin}
    </conflicts>
  </compatibility>

  <recommendations>
    1. {primary recommendation}
    2. {alternative approach}
  </recommendations>

  <config_updates>
```lua
-- Recommended configuration changes
{code}
```
  </config_updates>
</investigation_report>
```

---

## Handoff Protocol

When one agent needs to delegate to another:

```xml
<handoff_request target="{nvim-diagnostician|config-auditor|plugin-investigator}">
  <from_agent>{originating agent name}</from_agent>
  <reason>{why handoff is needed}</reason>
  <partial_findings>
    {what has been discovered so far}
  </partial_findings>
  <specific_question>
    {what the target agent should focus on}
  </specific_question>
</handoff_request>
```

### Handoff Scenarios

| From | To | When |
|------|----|------|
| nvim-diagnostician | plugin-investigator | Root cause is outdated plugin or version mismatch |
| nvim-diagnostician | config-auditor | Problem requires full config review |
| config-auditor | nvim-diagnostician | Found error that needs deeper diagnosis |
| config-auditor | plugin-investigator | Found deprecated plugin usage |
| plugin-investigator | nvim-diagnostician | Plugin is fine, issue is in config |

---

## Status Values

### diagnosis_result.status

| Value | Meaning | Next Action |
|-------|---------|-------------|
| `RESOLVED` | Problem diagnosed and solution provided | Present to user |
| `NEEDS_INVESTIGATION` | More info needed from user | AskUserQuestion |
| `HANDOFF` | Different agent should continue | Invoke target agent |

### investigation_report.status

| Value | Meaning |
|-------|---------|
| `OK` | Plugin is up to date, no issues found |
| `OUTDATED` | Newer version available, no breaking changes |
| `BREAKING_CHANGES` | Update available but has breaking changes |
| `ERROR` | Could not complete investigation |

### audit_report.grade

| Grade | Critical | Warnings | Meaning |
|-------|----------|----------|---------|
| A | 0 | 0-2 | Excellent - Production ready |
| B | 0 | 3-5 | Good - Minor improvements possible |
| C | 0-1 | 6+ | Acceptable - Needs attention |
| D | 2-3 | any | Poor - Significant problems |
| F | 4+ | any | Failing - Immediate fixes required |
