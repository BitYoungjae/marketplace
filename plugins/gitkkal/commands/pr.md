---
description: "Creates or updates a PR. Automatically detects existing PR for current branch."
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion
disable-model-invocation: true
argument-hint: "[hint]"
---

# gitkkal pr

Creates or updates a Pull Request. Auto-detects existing PR for current branch.

The PR body must be readable by **non-developers** (product managers, designers, business stakeholders). Anyone should be able to grasp the purpose and impact of the change without opening the diff.

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

Use **staged analysis** to avoid reading unnecessarily large diffs.

**Step 1:** Analyze commit messages + `--stat` first. Most PRs have descriptive commit messages that reveal intent; `--stat` shows scope.

**Step 2:** If intent is clear → proceed to write PR content.

**Step 3:** If intent is unclear → selectively read specific diffs:

```bash
git diff main...HEAD -- path/to/unclear/file.ts
```

Only read diffs for files where the change purpose is ambiguous. Focus on key files (main logic, not generated/config files).

Then **translate the engineering work into one of three change categories**, because each maps to a different PR body framing:

<change-categories>
| Category | What the PR does | Audience framing |
|----------|------------------|------------------|
| **User-facing** | Adds/changes/fixes something users or external clients see or experience | "What can users now do / no longer suffer from?" |
| **Internal capability** | Adds a building block other features will use (new API, infra, library) | "What does this unlock for the team / product?" |
| **Pure refactor / maintenance** | No behavior change — restructures, renames, cleans up | "What development pain does this remove?" |
</change-categories>

<examples>
| Commits / changes | Category | Title |
|-------------------|----------|-------|
| 3 commits adding validation functions + tests | User-facing | "Block invalid submissions before they reach support" |
| Bug fix + null checks + error logging | User-facing | "Fix crash when users enter unusual input" |
| New `BillingClient` module, no UI yet | Internal capability | "Add billing client so checkout can charge cards" |
| Rename `SKU` to `BundleID` across 10 files | Pure refactor | "Rename SKU to BundleID to match product terminology" |
| Extract 4 helper modules from one 800-line file | Pure refactor | "Split order module to make future changes safer" |
</examples>

<bad-analysis>
Commits: "fix typo", "add test", "update config", "refactor util"
Result: Title = "Various updates" ← Too vague, lists changes without purpose
</bad-analysis>

**When intent is unclear:**
- Use AskUserQuestion: "These commits include both bug fixes and new features. What's the primary focus of this PR?"
- Do not default to generic titles like "Update code" or "Various improvements"

### 4. User Hint

**$ARGUMENTS** — If provided, use as guidance for title emphasis, which changes to highlight, additional context, or tone.

### 5. Write PR Content

Follow `language` setting (ko/en) for the prose.

#### Title guidelines

- **Under 50 characters**
- **Imperative mood**: "Add", "Fix", "Improve" (not "Added", "Fixes")
- **Lead with the outcome**, not the implementation:
  - Good: "Block invalid submissions before they reach support"
  - Bad: "Add validateEmail() to user form"

#### Body structure

Write the body in this order. The first two sections must be understandable without reading any code.

```markdown
## Background
<1-3 sentences explaining the problem, motivation, or context behind this PR>

## What Changes
- <Concrete user-visible or product-visible change>
- <Another change, grouped conceptually>

## Technical Notes
<Optional. Implementation details for reviewers: architecture choices, library/API picks, migration notes, follow-ups. Omit the section entirely when there is nothing meaningful to say here.>

## Test Plan
- [ ] <Test item 1>
- [ ] <Test item 2>
```

#### The Audience Principle

The reader of `Background` and `What Changes` is **someone who does not read the diff** — a product manager, designer, support engineer, or external stakeholder. Write so they can:

1. Understand **why this PR exists** without prior context.
2. Picture **what changes for users or the product** after merge.
3. Skip `Technical Notes` and still grasp the full point of the PR.

Concrete rules for `Background` + `What Changes`:

- **Lead with the problem or user outcome**, not the file or function. Function and module names belong in `Technical Notes` or the diff.
- **Use plain product/business vocabulary** ("checkout page", "signup form", "support ticket volume"). Translate jargon when first introduced. "JWT token" → "the login token we issue users".
- **Quantify impact when possible** ("removes ~30% of failed signup attempts", "responses now arrive within 200ms").
- **One bullet = one observable change**. Group related code edits into a single bullet about the *effect*.

<good-body audience="non-developer">
## Background
Users keep mistyping their email on signup (e.g. `name@gmial.com`), get a generic "signup failed" message, and bounce. Support has handled ~40 tickets/month about this.

## What Changes
- The signup form now catches common email typos before submission and suggests a correction inline.
- Failed submissions show a specific message ("Did you mean `name@gmail.com`?") instead of a generic error.
- Already-supported flows (Google/Apple sign-in) are untouched.

## Technical Notes
- Validation runs client-side via the new `suggestEmailFix()` helper; no new server calls.
- `validateEmail` is reused by the API layer for defense-in-depth.
</good-body>

<bad-body audience="non-developer">
## Summary
- Modified user.js
- Added validateEmail function
- Updated tests for user.test.js
- Refactored form submission handler

## Test plan
- [ ] Run tests
</bad-body>

#### Pure refactor or maintenance PRs

When there is **no user-visible change**, never write "no user impact" or leave `Background` empty. Translate the work into **developer productivity, reliability, or future-capability value**, which non-developer readers still care about.

<refactor-framings>
| Engineering reality | Audience-friendly framing |
|---------------------|---------------------------|
| Split 1 file into 4 modules | "Future changes to this area are smaller and safer to review" |
| Add typed interfaces | "Catches a class of bugs at build time instead of in production" |
| Rename `SKU` → `BundleID` | "Code now uses the same word ('bundle') we use in product and docs, reducing onboarding confusion" |
| Remove dead code | "Removes ~800 lines that no longer ran, shrinking the area future bugs can hide in" |
| Replace custom impl with library X | "Hands maintenance to a well-supported library; lets the team focus on product work" |
</refactor-framings>

<good-refactor-body>
## Background
The order module has grown to 800 lines and mixes pricing, inventory, and fulfillment logic. Adding even small features here keeps touching unrelated code, which slows reviews and creates merge conflicts across teams.

## What Changes
- Splits the order module into three focused modules (pricing, inventory, fulfillment).
- No behavior change for users or APIs — same inputs produce the same outputs.
- Future order-related features can be reviewed by the relevant team alone.

## Technical Notes
- Public exports unchanged; only internal structure moved.
- Each new module owns its tests; existing tests pass without modification.
</good-refactor-body>

#### Verbosity targets

- `Background`: **1–3 sentences**.
- `What Changes`: **2–6 bullets**, each one observable change.
- `Technical Notes`: **0–6 bullets or 1 short paragraph**. Omit the section if nothing meaningful.
- `Test Plan`: **2–6 checklist items**.

#### When a PR template exists

If `{project_root}/.github/PULL_REQUEST_TEMPLATE.md` exists → follow that template's structure exactly, but apply the Audience Principle and refactor framings inside whatever sections the template provides.

### 6. Push and Create

```bash
# Push if needed
git push -u origin $(git branch --show-current)

# Create PR with HEREDOC
gh pr create --title "PR title" --body "$(cat <<'EOF'
## Background
Brief context.

## What Changes
- User/product-visible change.

## Test Plan
- [ ] Test item
EOF
)"
```

### 7. Output

```
Created PR #123: https://github.com/org/repo/pull/123
Title: Block invalid submissions before they reach support
Base: main ← feat/email-typo-detection
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

IMPORTANT: **Completely replace** existing content. Do not append.

Analyze ALL commits with the staged approach from Creation Mode §3:
- Start with commit messages + `--stat` to understand scope.
- Read specific file diffs only when intent is unclear.
- Classify the change (user-facing / internal capability / pure refactor) and apply the matching framing.
- Write fresh `Background`, `What Changes`, optional `Technical Notes`, and `Test Plan` reflecting the current state of the branch.

**$ARGUMENTS** — If provided, incorporate as guidance.

### 3. Execute Update

```bash
gh pr edit --title "New title" --body "$(cat <<'EOF'
## Background
Updated context.

## What Changes
- Updated user/product-visible change.

## Test Plan
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
