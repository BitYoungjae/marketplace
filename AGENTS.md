# Repository Guidelines

## Project Structure & Module Organization
- `plugins/` contains publishable Claude Code plugins (`dokhak`, `gitkkal`, `nvim-doctor`, `obsidian-blocks`, `omarchy`).
- Each plugin keeps metadata in `.claude-plugin/plugin.json`, plus capability folders such as `commands/`, `skills/`, `agents/`, and optional `contexts/`.
- `contexts/` stores shared reference documents (for example `contexts/cc/` synced Claude Code docs).
- `scripts/` contains maintenance utilities (currently `scripts/cc-docs-sync.sh`).
- `.github/PULL_REQUEST_TEMPLATE.md` defines PR expectations.

## Build, Test, and Development Commands
- No compile/build step is required; this repository is Markdown/JSON-first.
- Add marketplace and install a plugin locally:
  ```bash
  /plugin marketplace add bityoungjae/marketplace
  /plugin install gitkkal@bityoungjae-marketplace
  ```
- Sync Claude Code docs:
  ```bash
  ./scripts/cc-docs-sync.sh --dry-run
  ./scripts/cc-docs-sync.sh --include-prompt-engineering --verbose
  ```
  Use `--dry-run` before writing files.

## Coding Style & Naming Conventions
- Use Markdown for docs and command/skill definitions; keep sections short and task-oriented.
- Use 2-space indentation in JSON files (see `plugins/*/.claude-plugin/plugin.json`).
- Use kebab-case for plugin and skill directories (for example `plugins/obsidian-blocks/skills/mermaid-diagramming/`).
- Command files should map directly to slash commands (for example `commands/diagnose.md` -> `/nvim-doctor:diagnose`).
- If English and Korean READMEs both exist, update both when behavior changes.

## Testing Guidelines
- There is no centralized automated test suite yet.
- For each change, run focused manual validation:
  1. Verify referenced files in updated `plugin.json` exist.
  2. Exercise changed commands/skills in Claude Code.
  3. If docs sync changed, run `./scripts/cc-docs-sync.sh --dry-run` to confirm target diffs.

## Commit & Pull Request Guidelines
- Preferred commit format follows Conventional Commits with optional scope:
  - `feat(dokhak): add model-aware tool selection`
  - `docs(obsidian-blocks): update mermaid note`
- Emoji-style subjects appear in history, but keep messages clear, scoped, and actionable.
- Open PRs using `.github/PULL_REQUEST_TEMPLATE.md`: complete `Summary`, `Changes`, `Test Plan`, and checklist items for style/docs updates.
- Link related issues/PRs in the title or body (for example `(#5)`).
