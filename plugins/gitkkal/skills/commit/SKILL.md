---
name: commit
description: "Analyzes changes and creates commits following configured style. Git workflow automation."
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion
user-invocable: true
disable-model-invocation: true
---

# gitkkal Commit Skill

Analyzes changes and creates commits following the configured style.

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

## Configuration Schema

<config_schema>
```json
{
  "language": "ko" | "en",
  "commitPattern": "conventional" | "gitmoji" | "simple",
  "branchPattern": "type/description" | "description-only",
  "splitCommits": boolean,
  "askOnAmbiguity": boolean,
  "createPrTemplate": boolean
}
```
</config_schema>

## Commit Pattern Formats

<commit_patterns>
| Pattern | Format | Example |
|---------|--------|---------|
| `conventional` | `<type>[(scope)]: <description>` | `feat(auth): add login feature`, `fix: resolve null reference error` |
| `gitmoji` | `<emoji> [(scope)][:] <message>` | `✨ Add login feature`, `🐛 (auth): Fix login bug` |
| `simple` | `<message>` | `Add login feature` |
</commit_patterns>

**Conventional Commits**: Scope is optional and enclosed in parentheses. [Official spec](https://www.conventionalcommits.org/en/v1.0.0/)

**Gitmoji**: Emoji can be unicode (`✨`) or shortcode (`:sparkles:`). Scope is optional. [Official spec](https://gitmoji.dev/specification)

### Conventional Commit Types

<conventional_types>
| Type | Purpose | Gitmoji |
|------|---------|---------|
| `feat` | New feature | ✨ |
| `fix` | Bug fix | 🐛 |
| `docs` | Documentation changes | 📝 |
| `style` | Code formatting (no functional changes) | 🎨 |
| `refactor` | Refactoring | ♻️ |
| `perf` | Performance improvement | ⚡ |
| `test` | Add/modify tests | ✅ |
| `build` | Build system/dependencies | 📦 |
| `ci` | CI configuration changes | 👷 |
| `chore` | Other changes | 🔧 |
| `revert` | Revert commit | ⏪ |
</conventional_types>

## Execution Steps

### Step 1: Load Configuration

Read `{project_root}/.gitkkal/config.json` to load settings.

### Step 2: Analyze Changes

Run the following Git commands to understand changes:

<git_commands>
```bash
# Check staged changes
git diff --cached --stat
git diff --cached

# Check unstaged changes
git diff --stat
git diff

# Check untracked files
git status --porcelain

# Reference recent commit message style
git log --oneline -10
```
</git_commands>

### Step 3: Decide on Commit Splitting

If `splitCommits` is `true`:

<split_criteria>
**Splitting Principles**:
1. Each commit must be an **executable unit** (able to pass build/tests)
2. Only **semantically cohesive changes** should be grouped in one commit

**Splitting Examples**:
- New feature + related tests → One commit
- Bug fix + new feature → Separate commits
- Formatting changes + logic changes → Separate commits
- Unrelated file modifications → Split by semantic units
</split_criteria>

If `askOnAmbiguity` is `true` and splitting is ambiguous:
- Use AskUserQuestion to confirm with user

### Step 4: Write Commit Message

Write commit message according to configured pattern.

<message_guidelines>
**Good Commit Message Principles**:
- Focus on "why" not "what"
- Use imperative present tense (e.g., "Add", "Fix", not "Added", "Fixed")
- First line recommended under 50 characters
- Add detailed explanation in body if needed

**Language Examples**:
- `ko`: `feat(auth): 소셜 로그인 기능 추가`
- `en`: `feat(auth): add social login feature`
</message_guidelines>

### Step 5: Execute Commit

<commit_execution>
```bash
# Stage files (selectively if splitCommits)
git add <files>

# Create commit (pass message via HEREDOC)
git commit -m "$(cat <<'EOF'
Commit message
EOF
)"
```
</commit_execution>

## Prohibited Actions

<prohibited>
- **Never** include `Co-Authored-By` lines in commit messages
- **Never** use `git commit --amend` (always create new commits)
- Use individual file names instead of `git add -A` or `git add .`
- **Never** commit sensitive files (.env, credentials, etc.)
</prohibited>

## Error Handling

<error_handling>
**No changes to stage**:
- Display "No changes to commit."

**Pre-commit hook failure**:
- Fix the issue and create a **new commit** (no amend)
- Explain the failure cause to user

**Conflict state**:
- Inform that conflicts must be resolved first
</error_handling>

## Output Example

<output_example>
Display the following information upon commit completion:
- Created commit hash
- Commit message
- List of changed files
- (If splitCommits) Number of commits created
</output_example>
