---
description: "Analyzes changes and creates an appropriate branch."
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
argument-hint: "[description]"
---

# gitkkal branch

Analyzes changes and generates an appropriate branch name, then creates the branch.

## Critical Rules

- NEVER create branches with non-English names
- NEVER use special characters except hyphens
- Branch names MUST be lowercase kebab-case
- Maximum 50 characters for branch name

## Workflow

### 1. Load Configuration

```bash
git rev-parse --show-toplevel  # Find project root
```

Read `{project_root}/.gitkkal/config.json`. If not exists, use defaults and display once:
"Using default settings. Run `/gitkkal:init` to customize."

<defaults>
```json
{
  "language": "en",
  "branchPattern": "type/description"
}
```
</defaults>

### 2. Analyze Current State

Run in parallel:

```bash
git status --short
git diff              # Actual content changes (unstaged)
git diff --cached     # Actual content changes (staged)
```

- No changes → Ask user for branch description directly
- Changes exist → Proceed to semantic analysis

### 3. Understand Semantic Intent

Focus on the **"why"** rather than the **"what"**:

- Read actual diff content, not just file statistics
- Identify the semantic meaning of changes (e.g., "renaming SKU to Bundle ID", "adding retry logic")
- Look for patterns: variable renames, API changes, new abstractions, bug fixes

<examples>
| Diff observation | Semantic intent | Branch |
|------------------|-----------------|--------|
| New `validateEmail()` function + test file | Adding email validation | `feat/add-email-validation` |
| `catch` block added, null checks inserted | Fixing unhandled error crash | `fix/handle-null-user-error` |
| `userId` → `oderId` typo fixed | Fixing variable typo | `fix/order-id-typo` |
| Loop replaced with `.map()`, no behavior change | Refactoring to functional style | `refactor/use-map-for-transform` |
| `setTimeout` → `requestIdleCallback` | Improving render performance | `perf/defer-non-critical-updates` |
</examples>

<bad-analysis>
Diff shows: 5 files changed, 47 insertions, 32 deletions
Result: `feat/update-files` ← Too vague, based on file stats only
</bad-analysis>

**When intent is unclear from code alone:**
- Use AskUserQuestion to clarify: "I see changes to product naming. What's the purpose of this change?"
- Do NOT guess or default to generic names

### 4. Determine Branch Type

| Type       | When to use                                            |
| ---------- | ------------------------------------------------------ |
| `feat`     | New feature, new files, new functions                  |
| `fix`      | Bug fix, error handling                                |
| `refactor` | Structural improvements without functional changes     |
| `docs`     | Documentation (*.md, README, CHANGELOG)                |
| `test`     | Test code (*.test.*, *.spec.*, __tests__/)             |
| `style`    | Formatting, code style (no logic changes)              |
| `chore`    | Build/config (package.json, tsconfig)                  |
| `perf`     | Performance improvements                               |
| `ci`       | CI/CD config (.github/workflows/)                      |

When type is ambiguous: Use AskUserQuestion to clarify the primary purpose of the changes.

### 5. Generate Branch Name

**Slug rules:**
1. English kebab-case only
2. Max 50 characters
3. Alphanumeric and hyphens only
4. Lowercase

<good-example>
Input: "Add user authentication"
Output: `feat/add-user-authentication`
</good-example>

<bad-example>
Input: "사용자 인증 추가"
Action: Use AskUserQuestion to request English description
</bad-example>

**Pattern formats:**

| branchPattern      | Format          | Example               |
| ------------------ | --------------- | --------------------- |
| `type/description` | `{type}/{slug}` | `feat/add-user-login` |
| `description-only` | `{slug}`        | `add-user-login`      |

### 6. Confirm with User

Use AskUserQuestion:
- header: "Branch"
- question: "Create this branch?"
- options: Generated name (recommended) / Custom

### 7. Create Branch

```bash
git checkout -b {branch_name}
```

### 8. Output

```
Created branch: `{branch_name}`
Next: Run `/gitkkal:commit` to commit changes
```

## Argument Handling

If user provides argument (e.g., `/gitkkal:branch add user authentication`):
1. Use argument as branch description
2. Skip change analysis
3. Determine type from argument content

## Error Handling

| Situation                  | Action                                           |
| -------------------------- | ------------------------------------------------ |
| Not a Git repository       | "This is not a Git repository"                   |
| Branch already exists      | Suggest different name or numeric suffix         |
| Non-English description    | Request English description via AskUserQuestion  |
| Intent unclear from code   | Ask user to clarify the purpose of changes       |
| Name too long              | Auto-truncate to 50 characters                   |
