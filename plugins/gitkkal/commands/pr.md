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
"Using default settings. Run `/gitkkal:init-gitkkal` to customize."

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

### 2. Analyze Commits

```bash
git log main..HEAD --oneline
git diff main...HEAD --stat
git diff main...HEAD  # If detailed analysis needed
```

IMPORTANT: Analyze ALL commits from base branch, not just the latest.

### 3. User Hint

**$ARGUMENTS** — If provided, use as guidance for:
- Title/summary emphasis
- Which changes to highlight
- Additional context
- Tone or detail level

### 4. Write PR Content

Follow `language` setting (ko/en).

**Title**: Under 50 characters, summarizes core changes

**Body structure**:
```markdown
## Summary
- Bullet point 1
- Bullet point 2

## Test plan
- [ ] Test item 1
- [ ] Test item 2
```

If `{project_root}/.github/PULL_REQUEST_TEMPLATE.md` exists → Follow that template structure.

### 5. Push and Create

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

### 6. Output

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
git diff main...HEAD --stat
```

### 2. Rewrite Content

IMPORTANT: **Completely replace** existing content. Do NOT append.

Analyze ALL commits and write fresh Summary and Test plan.

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
