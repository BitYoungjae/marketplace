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

```bash
git status --short
git diff --stat
git diff --cached --stat
```

- No changes → Ask user for branch description directly
- Changes exist → Analyze and determine type

### 3. Determine Branch Type

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

When ambiguous: Choose the most significant change. Default to `feat` if truly uncertain.

### 4. Generate Branch Name

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

### 5. Confirm with User

Use AskUserQuestion:
- header: "Branch"
- question: "Create this branch?"
- options: Generated name (recommended) / Custom

### 6. Create Branch

```bash
git checkout -b {branch_name}
```

### 7. Output

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
| Name too long              | Auto-truncate to 50 characters                   |
