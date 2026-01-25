---
name: pr
description: "Creates or updates a PR. No arguments creates new PR, PR number updates existing PR."
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion
argument-hint: "[pr-number]"
---

# gitkkal PR Skill

Creates or updates a Pull Request.

## Usage

<usage>
- `/gitkkal:pr` - Create new PR
- `/gitkkal:pr 123` - Update PR #123
</usage>

## Prerequisites

### Load Configuration

Read `{project_root}/.gitkkal/config.json` to load settings.

The project root is the top-level directory of the Git repository (use `git rev-parse --show-toplevel` to find it).

- **If exists**: Load settings from the file.
- **If not exists**: Use default settings.

<default_config>

```json
{
  "language": "en",
  "commitPattern": "conventional",
  "branchPattern": "type/description",
  "splitCommits": true,
  "askOnAmbiguity": true,
  "createPrTemplate": false
}
```

</default_config>

When no config file exists, display once: "Using default settings. Run `/gitkkal:init` to customize."

### Check GitHub CLI

Verify that `gh` CLI is installed and authenticated:

```bash
gh auth status
```

## Determine Execution Mode

Check `$ARGUMENTS` to determine mode:

<mode_decision>
- **No arguments or empty string**: PR creation mode
- **Number present**: PR update mode (update that PR number)
</mode_decision>

---

## PR Creation Mode

### Step 1: Check Branch Status

<branch_check>
```bash
# Check current branch
git branch --show-current

# Check main branch (main or master)
git remote show origin | grep 'HEAD branch'

# Check remote tracking status
git status -sb

# Check if push needed
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null || echo "no-remote"
```
</branch_check>

### Step 2: Analyze Commits

Analyze all commits from the base branch:

<commit_analysis>
```bash
# List commits compared to base branch
git log main..HEAD --oneline

# Check full diff
git diff main...HEAD --stat

# Detailed diff (if needed)
git diff main...HEAD
```
</commit_analysis>

### Step 3: Write PR Content

Write PR title and body according to the `language` setting.

<pr_content_guidelines>
**Title**:
- Concisely summarize the core changes
- Recommended under 50 characters
- Write in Korean/English based on language setting

**Body** structure:
```markdown
## Summary
<!-- 1-3 bullet points summarizing changes -->

## Test plan
<!-- Testing method checklist -->
```
</pr_content_guidelines>

### Step 4: Push and Create PR

<pr_creation>
```bash
# Push to remote (if needed)
git push -u origin $(git branch --show-current)

# Create PR (pass body via HEREDOC)
gh pr create --title "PR title" --body "$(cat <<'EOF'
## Summary
- Change summary 1
- Change summary 2

## Test plan
- [ ] Test item 1
- [ ] Test item 2
EOF
)"
```
</pr_creation>

---

## PR Update Mode

When PR number is passed via `$ARGUMENTS`.

### Step 1: Check Existing PR

<pr_check>
```bash
# Check PR existence and status
gh pr view $ARGUMENTS --json number,title,body,state,headRefName

# Verify current branch matches PR branch
```
</pr_check>

### Step 2: Re-analyze Changes

Analyze commits added since PR creation:

<update_analysis>
```bash
# Check all commits in PR
gh pr view $ARGUMENTS --json commits

# Check current diff
git diff main...HEAD --stat
```
</update_analysis>

### Step 3: Update PR Content

**Completely replace** existing PR content with new content.

<important>
**Note**: When updating, do NOT append to existing content. **Completely replace** it.
Analyze all commits and write new Summary and Test plan.
</important>

### Step 4: Execute PR Update

<pr_update>
```bash
# Update PR title and body
gh pr edit $ARGUMENTS --title "New PR title" --body "$(cat <<'EOF'
## Summary
- Updated change summary

## Test plan
- [ ] Updated test item
EOF
)"
```
</pr_update>

---

## PR Template Usage

If `{project_root}/.github/PULL_REQUEST_TEMPLATE.md` exists, follow that template's structure.

<template_usage>
1. Read template file
2. Understand section structure
3. Fill in appropriate content for each section
4. Keep empty sections but remove guide text
</template_usage>

---

## Error Handling

<error_handling>
**gh CLI not installed**:
- Display "GitHub CLI is required. Install from https://cli.github.com"

**Not authenticated**:
- Display "Run `gh auth login` to authenticate."

**Invalid PR number**:
- Display "PR #N not found."

**Cannot push to remote**:
- Inform about permission issues or potential conflicts

**Attempting to create PR from main branch**:
- Display "Cannot create PR from main branch. Please create a new branch."
</error_handling>

---

## Output Example

<output_example>
**On PR creation completion**:
- Display PR URL
- Display PR number
- Summary info (title, base branch, commit count)

**On PR update completion**:
- Display PR URL
- Display "PR #N has been updated."
- Summary of changes
</output_example>

---

## Prohibited Actions

<prohibited>
- Never include `Co-Authored-By` lines in PR body
- Never force push (`git push --force`)
- Never attempt to modify already merged PRs
</prohibited>
