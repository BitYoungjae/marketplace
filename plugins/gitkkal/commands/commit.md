---
description: "Analyzes changes and creates commits following configured style."
disable-model-invocation: true
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion
argument-hint: "[hint]"
---

# gitkkal commit

Analyzes changes and creates commits following the configured style.

## Critical Rules

- NEVER include `Co-Authored-By` lines in commit messages
- NEVER use `git commit --amend` — always create NEW commits
- NEVER use `git add -A` or `git add .` — stage files individually
- NEVER commit sensitive files (.env, credentials, API keys)
- ALWAYS use HEREDOC for commit messages to ensure proper formatting

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
  "commitPattern": "conventional",
  "splitCommits": true,
  "askOnAmbiguity": true
}
```
</defaults>

### 2. Gather Change Information

Run in parallel:

```bash
git status --short          # All file states (NEVER use -uall flag)
git diff --cached           # Staged changes (actual content)
git diff                    # Unstaged changes (actual content)
git log --oneline -5        # Recent commit style reference
```

**Commit candidates** (analyze all together):
- Staged changes (index)
- Unstaged changes (modified tracked files)
- Untracked files (new files)

### 3. Understand Semantic Intent

Focus on the **"why"** rather than the **"what"**:

- Read actual diff content, not just file statistics
- Identify the semantic meaning of changes
- Determine if changes represent: new feature, enhancement to existing feature, bug fix, refactoring, etc.
- Ensure verb choice reflects intent: "add" = wholly new, "update" = enhancement, "fix" = bug fix

<examples>
| Diff observation | Semantic intent | Commit message |
|------------------|-----------------|----------------|
| New `validateEmail()` + test file | Adding validation feature | `feat: add email validation` |
| `catch` block added, null checks | Fixing unhandled error | `fix: handle null user error` |
| `userId` → `orderId` typo fixed | Correcting typo | `fix: correct order-id typo` |
| Loop → `.map()`, same behavior | Functional refactoring | `refactor: use map for transform` |
| `setTimeout` → `requestIdleCallback` | Performance optimization | `perf: defer non-critical updates` |
</examples>

<bad-analysis>
Diff shows: 5 files changed, 47 insertions, 32 deletions
Result: `chore: update files` ← Too vague, based on file stats only
</bad-analysis>

**When intent is unclear from code alone:**
- Use AskUserQuestion to clarify: "I see changes to error handling. Is this fixing a bug or adding new validation?"
- Do NOT guess or default to generic messages like "update code"

### 4. User Hint

**$ARGUMENTS** — If provided, use as guidance for:
- Commit message content/style
- How to split/group changes
- Additional context

The hint is advisory — incorporate appropriately.

### 5. Decide Commit Splitting

When `splitCommits: true`:

**Principles:**
1. Each commit must be an executable unit (passes build/tests)
2. Only semantically cohesive changes in one commit

<good-example>
New feature + related tests → One commit
</good-example>

<bad-example>
Bug fix + unrelated new feature → Should be separate commits
Formatting + logic changes → Should be separate commits
</bad-example>

When `askOnAmbiguity: true` and splitting is unclear → Use AskUserQuestion.

### 6. Write Commit Message

**Patterns:**

| Pattern        | Format                           | Example                          |
| -------------- | -------------------------------- | -------------------------------- |
| `conventional` | `<type>[(scope)]: <description>` | `feat(auth): add login feature`  |
| `gitmoji`      | `<emoji> [(scope)] <message>`    | `✨ Add login feature`           |
| `simple`       | `<message>`                      | `Add login feature`              |

**Types:**

| Type       | Purpose                    | Gitmoji |
| ---------- | -------------------------- | ------- |
| `feat`     | New feature                | ✨      |
| `fix`      | Bug fix                    | 🐛      |
| `docs`     | Documentation              | 📝      |
| `style`    | Formatting (no logic)      | 🎨      |
| `refactor` | Refactoring                | ♻️      |
| `perf`     | Performance                | ⚡      |
| `test`     | Tests                      | ✅      |
| `build`    | Build/dependencies         | 📦      |
| `ci`       | CI config                  | 👷      |
| `chore`    | Other                      | 🔧      |

**Message guidelines:**
- Focus on "why" not "what" — explain the purpose, not just the change
- Imperative present tense: "Add", "Fix" (not "Added", "Fixed")
- First line under 50 characters
- Body (optional): use for additional context when the "why" isn't obvious
- Language follows config (`ko` or `en`)

### 7. Execute Commit

```bash
# Stage specific files
git add path/to/file1.ts path/to/file2.ts

# Commit with HEREDOC
git commit -m "$(cat <<'EOF'
feat(auth): add social login feature

- Implement OAuth2 flow
- Add session management
EOF
)"
```

### 8. Output

```
Created: abc1234
Message: feat(auth): add social login feature
Files: src/auth.ts, src/session.ts
```

If multiple commits: show count and summary of each.

## Error Handling

| Situation              | Action                                              |
| ---------------------- | --------------------------------------------------- |
| No changes to commit   | "No changes to commit."                             |
| Pre-commit hook fails  | Fix issue, create NEW commit (never amend)          |
| Merge conflict state   | "Resolve conflicts before committing."              |
| Intent unclear from code | Ask user to clarify the purpose of changes        |
| Sensitive file detected | Warn user and exclude from staging                 |
