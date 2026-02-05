---
description: "Creates or updates a PR. Automatically detects existing PR for current branch."
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion
disable-model-invocation: true
argument-hint: "[hint]"
---

# gitkkal pr

Creates or updates a Pull Request. Auto-detects existing PR for current branch.

## Critical Rules

- NEVER include `Co-Authored-By` lines in PR body
- NEVER use `git push --force`
- NEVER modify already merged PRs
- NEVER create PR from main/master branch
- ALWAYS use HEREDOC for PR body

## Usage

```
/gitkkal:pr                              # Create or update (auto-detected)
/gitkkal:pr emphasize refactoring        # With hint
```

## Prerequisites

### 1. Load Configuration

```bash
git rev-parse --show-toplevel  # Find project root
```

Read `{project_root}/.gitkkal/config.json`. If not exists, use defaults and display once:
"Using default settings. Run `/gitkkal:init` to customize."

### 2. Verify GitHub CLI

```bash
gh auth status
```

If not installed: "GitHub CLI is required. Install from https://cli.github.com"
If not authenticated: "Run `gh auth login` to authenticate."

## Mode Detection

```bash
gh pr view --json number,state 2>/dev/null
```

- Succeeds + state is `OPEN` → **Update Mode**
- Fails or state is `CLOSED`/`MERGED` → **Creation Mode**

---

## PR Creation Mode

### 1. Check Branch Status

```bash
git branch --show-current
git remote show origin | grep 'HEAD branch'
git status -sb
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null || echo "no-remote"
```

If on main/master → Error: "Cannot create PR from main branch. Create a new branch first."

### 2. Gather Change Information

Run in parallel:

```bash
git log main..HEAD --oneline      # Commit history with messages
git diff main...HEAD --stat       # File-level change summary
```

IMPORTANT: Analyze ALL commits from base branch, not just the latest.

### 3. Understand Semantic Intent

Use **staged analysis** to avoid reading unnecessarily large diffs:

**Step 1: Analyze commit messages + stat**
- Most PRs have descriptive commit messages that reveal intent
- `--stat` shows which files changed and rough scope

**Step 2: If intent is clear → proceed to write PR content**

**Step 3: If intent is unclear → selectively read specific diffs**
```bash
git diff main...HEAD -- path/to/unclear/file.ts
```
- Only read diffs for files where the change purpose is ambiguous
- Focus on key files (main logic, not generated/config files)

**Focus on the "why"** rather than the **"what"**:
- Identify the overarching purpose across all commits
- Determine the user-facing impact: What problem does this solve? What capability does it add?
- Group related changes conceptually (e.g., "improves error handling" vs listing each file changed)

<examples>
| Commits/Changes | Semantic intent | PR Title |
|-----------------|-----------------|----------|
| 3 commits adding validation functions + tests | Adding input validation feature | "Add comprehensive input validation" |
| Bug fix + null checks + error logging | Improving error resilience | "Fix crash on invalid user input" |
| Rename across 10 files + update imports | Clarifying domain terminology | "Rename SKU to BundleID for clarity" |
| Performance tweaks in 3 modules | Optimizing response time | "Improve API response performance" |
</examples>

<bad-analysis>
Commits: "fix typo", "add test", "update config", "refactor util"
Result: Title = "Various updates" ← Too vague, lists changes without purpose
</bad-analysis>

**When intent is unclear:**
- Use AskUserQuestion: "These commits include both bug fixes and new features. What's the primary focus of this PR?"
- Do NOT default to generic titles like "Update code" or "Various improvements"

### 4. User Hint

**$ARGUMENTS** — If provided, use as guidance for:
- Title/summary emphasis
- Which changes to highlight
- Additional context
- Tone or detail level

### 5. Write PR Content

Follow `language` setting (ko/en).

**Title guidelines:**
- Under 50 characters
- Focus on the "why" — the purpose or impact, not just what changed
- Use imperative mood: "Add", "Fix", "Improve" (not "Added", "Fixes")

**Body structure:**
```markdown
## Summary
- Focus on purpose and impact, not file-by-file changes
- Group related changes conceptually
- Explain the "why" when not obvious from title

## Test plan
- [ ] Test item 1
- [ ] Test item 2
```

<good-summary>
## Summary
- Add email validation to prevent invalid submissions
- Include user-friendly error messages for common mistakes
</good-summary>

<bad-summary>
## Summary
- Modified user.js
- Added validateEmail function
- Updated tests
</bad-summary>

If `{project_root}/.github/PULL_REQUEST_TEMPLATE.md` exists → Follow that template structure.

### 6. Push and Create

```bash
# Push if needed
git push -u origin $(git branch --show-current)

# Create PR with HEREDOC
gh pr create --title "PR title" --body "$(cat <<'EOF'
## Summary
- Change summary

## Test plan
- [ ] Test item
EOF
)"
```

### 7. Output

```
Created PR #123: https://github.com/org/repo/pull/123
Title: Add user authentication
Base: main ← feat/add-auth
Commits: 3
```

---

## PR Update Mode

### 1. Get Existing PR

```bash
gh pr view --json number,title,body,state,headRefName
gh pr view --json commits
git diff main...HEAD --stat       # File-level change summary
```

### 2. Rewrite Content

IMPORTANT: **Completely replace** existing content. Do NOT append.

Analyze ALL commits with staged approach:
- Start with commit messages + `--stat` to understand scope
- Only read specific file diffs if intent is unclear
- Identify the overarching purpose across all commits
- Write fresh Summary and Test plan reflecting the "why"

**$ARGUMENTS** — If provided, incorporate as guidance.

### 3. Execute Update

```bash
gh pr edit --title "New title" --body "$(cat <<'EOF'
## Summary
- Updated summary

## Test plan
- [ ] Updated test
EOF
)"
```

### 4. Output

```
Updated PR #123: https://github.com/org/repo/pull/123
```

---

## Error Handling

| Situation                | Action                                              |
| ------------------------ | --------------------------------------------------- |
| gh CLI not installed     | "Install from https://cli.github.com"               |
| Not authenticated        | "Run `gh auth login`"                               |
| On main/master branch    | "Create a new branch first"                         |
| Cannot push              | Explain permission/conflict issue                   |
| PR already merged        | "Cannot modify merged PR"                           |
| Intent unclear from code | Ask user to clarify the primary purpose             |
