# Dokhak

> _Burn tokens, earn knowledge._

A Claude Code plugin for creating comprehensive self-learning resources. Just specify a topic and Dokhak will automate the entire workflow from project scaffolding to document generation.

[한국어 README](README.ko.md)

## Features

- **Conversational Interview**: Natural dialogue-based interview creates personalized learning materials
- **Domain-Adaptive Generation**: Automatically adjusts content strategy based on domain (technology, history, science, arts, language)
- **Automated Research**: Web research collection and curriculum design
- **Document Generation**: Write technical documents following consistent structure with persona adoption
- **Progress Tracking**: Monitor completion status and validate project consistency

## Installation

```bash
# Add marketplace
/plugin marketplace add BitYoungjae/marketplace

# Install plugin
/plugin install dokhak@bityoungjae-marketplace
```

## Quick Start

### 1. Initialize a New Project

```bash
/dokhak:init
```

This starts a conversational interview with multi-language greetings:

```
🇰🇷 안녕하세요! 오늘은 어떤 걸 배워보고 싶으세요?
🇺🇸 Hey there! What are you curious to learn about?
🇯🇵 こんにちは！今日は何を学んでみたいですか？
🇨🇳 你好！今天想学点什么呢？
🇪🇸 ¡Hola! ¿Qué te gustaría aprender hoy?
```

The interviewer naturally discovers:

- **Topic**: What do you want to learn?
- **Motivation**: Why are you learning this?
- **Level**: How much do you already know?
- **Preferences**: What kind of document do you want?

After initialization, the following files are created:

| File                 | Description                                      |
| -------------------- | ------------------------------------------------ |
| `persona.md`         | Writer and reader persona definitions            |
| `interview-data.md`  | Raw interview data                               |
| `plan.md`            | Hierarchical structure (Parts/Chapters/Sections) |
| `task.md`            | Checklist with session-based task distribution   |
| `project-context.md` | Research results and environment info            |
| `CLAUDE.md`          | Project-specific guidelines                      |

### 2. Write Documents

```bash
# Write single section
/dokhak:write

# Write specific section
/dokhak:write 2-3

# Write multiple sections continuously (recommended)
/dokhak:continue 5
```

Uses a context-isolated pipeline (researcher → writer) to generate documents while keeping the main session context minimal.

**Batch Writing Progress**:

```
📝 [1/5] Starting section 1.1 Introduction...
✅ [1/5] Completed section 1.1 Introduction
📝 [2/5] Starting section 1.2 Core Concepts...
...
```

### 3. Track Progress

```bash
/dokhak:status
```

Shows:

- Completion percentage
- Completed/Total sections per Part
- Next pending tasks

## Domain-Adaptive Content Generation

Dokhak automatically adjusts generation strategy based on the learning domain:

### Technology

- Code examples with version info
- GitHub repositories and official docs
- Environment setup guides
- API references

### History

- Primary source collection
- Chronological organization
- Historical perspectives
- Academic citations

### Science

- Equations and formulas
- Experimental procedures
- Mathematical prerequisites
- Peer-reviewed papers

### Arts

- Visual examples and references
- Step-by-step technique guides
- Materials and tools lists
- Practice exercises

### Language / General

- Structured explanations
- Linguistic analysis and examples
- Practice problems
- Interactive elements

## Commands

| Command     | Description                                                       |
| ----------- | ----------------------------------------------------------------- |
| `/init`     | Initialize project with interview-based persona creation          |
| `/write`    | Write the next document using researcher→writer→reviewer pipeline |
| `/continue` | Write multiple sections continuously (default: 3)                 |
| `/status`   | Show project progress and statistics                              |
| `/doctor`   | Diagnose project structure health and interactively fix issues    |

### Command Details

#### `/init`

```bash
/dokhak:init
```

Starts the interactive interview process.

#### `/write`

```bash
/dokhak:write [section-id] [--skip-review]
```

- `section-id`: Optional. Specific section to write (e.g., `2-3` for Chapter 2, Section 3)
- `--skip-review`: Skip the reviewer step and proceed directly to completion

#### `/continue`

```bash
/dokhak:continue [count] [--skip-review]
```

- `count`: Number of sections to write continuously (default: 3)
- `--skip-review`: Skip the reviewer step for all sections
- Respects session boundaries in `task.md`

#### `/doctor`

```bash
/dokhak:doctor
```

- Checks required files (plan.md, task.md, persona.md, etc.)
- Validates cross-file consistency (plan.md ↔ task.md ↔ CLAUDE.md)
- Checks completion status matches actual files
- Offers interactive fixes for each issue found

## Session-Based Task Distribution

`task.md` is automatically divided into sessions for efficient batch processing:

```markdown
<!-- Session 1: Part 1 Foundations -->

- [ ] 1.1 Introduction (8p)
- [ ] 1.2 Core Concepts (7p)
- [ ] 1.3 Basic Syntax (10p)

<!-- Session 2: Part 1 Architecture -->

- [ ] 1.4 System Design (12p)
- [ ] 1.5 Best Practices (8p)
```

- 1 session = 3-5 sections or 20-40 pages
- `/continue` respects these boundaries
- Sessions group related content for coherent writing

## Workflow

```
┌──────────────────────────────────────────────────────────────┐
│                    1. Project Initialization                  │
│  /dokhak:init                                        │
│                                                              │
│  → project-interviewer conducts conversational interview     │
│  → research-collector gathers domain-specific information    │
│  → structure-designer creates plan.md and task.md            │
│  → Generates persona.md, project-context.md, CLAUDE.md       │
└──────────────────────┬───────────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────────┐
│                    2. Document Writing (Loop)                 │
│  /dokhak:write or /dokhak:continue 3             │
│                                                              │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     │
│  │ researcher  │────▶│   writer    │────▶│  reviewer   │     │
│  │  (Haiku)    │     │   (Opus)    │     │   (Haiku)   │     │
│  └─────────────┘     └─────────────┘     └──────┬──────┘     │
│                                                  │            │
│                            ┌─────────────────────┼────────┐   │
│                            │                     │        │   │
│                            ▼                     ▼        │   │
│                      NEEDS_REVISION           PASS        │   │
│                            │                     │        │   │
│                            ▼                     │        │   │
│                      ┌─────────────┐             │        │   │
│                      │   writer    │             │        │   │
│                      │ (revision)  │─────────────┘        │   │
│                      └─────────────┘                      │   │
│                                                           │   │
│                     docs/XX-X-title.md saved              │   │
│                     task.md status updated                │   │
│                     (use --skip-review to bypass)         │   │
└──────────────────────┬────────────────────────────────────┘   │
                       ▼
┌──────────────────────────────────────────────────────────────┐
│                    3. Progress Tracking                       │
│  /dokhak:status                                              │
│                                                              │
│  → Completion rate, remaining sections, next task            │
└──────────────────────┬───────────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────────┐
│                    4. Health Check (Optional)                 │
│  /dokhak:doctor                                              │
│                                                              │
│  → plan.md ↔ task.md ↔ actual files consistency              │
│  → Interactive fixes for structural issues                   │
└──────────────────────────────────────────────────────────────┘
```

## Agents

| Agent                 | Model | Purpose                                                 |
| --------------------- | ----- | ------------------------------------------------------- |
| `project-interviewer` | Opus  | Conduct conversational interview for persona creation   |
| `researcher`          | Haiku | Gather and synthesize information for document writing  |
| `writer`              | Opus  | Write technical documents based on research and context |
| `reviewer`            | Haiku | Review written documents for quality and consistency    |
| `research-collector`  | Haiku | Collect and structure web research (init)               |
| `structure-designer`  | Opus  | Design curriculum hierarchy (init)                      |

## Generated Project Structure

After running `/init`, your project will have:

```
your-project/
├── persona.md           # Writer/reader personas with empathy data
├── interview-data.md    # Raw interview responses
├── plan.md              # Detailed structure with page allocations
├── task.md              # Checklist with session markers
├── project-context.md   # Research and environment info
├── CLAUDE.md            # Project guidelines for Claude
├── .research/           # Research cache (auto-generated)
│   ├── init/            # Initial research from /init
│   │   ├── summary.md   # Structured research summary
│   │   └── sources.md   # Source registry with reliability
│   └── sections/        # Section-specific research
│       └── {XX-Y-slug}/ # Research per section
└── docs/                # Generated documents
    ├── 01-1-introduction.md
    ├── 01-2-getting-started.md
    └── ...
```

## Plugin Structure

```
dokhak/
├── .claude-plugin/
│   └── plugin.json           # Plugin metadata
├── commands/
│   ├── init.md       # Project initialization with interview
│   ├── write.md          # Single section writing (researcher→writer→reviewer)
│   ├── continue.md   # Multiple section writing
│   ├── status.md             # Progress tracking
│   └── doctor.md             # Structure diagnosis and fix
├── skills/
│   ├── project-scaffolder/   # Project setup templates
│   ├── project-interview/    # Interview flow and questions
│   ├── domain-profiles/      # Domain-specific strategies
│   └── research-storage/     # Research file storage conventions
└── agents/
    ├── project-interviewer.md  # Interview agent (opus)
    ├── researcher.md           # Research gathering (haiku)
    ├── writer.md               # Document writing (opus)
    ├── reviewer.md             # Document review (haiku)
    ├── research-collector.md   # Research collection (haiku)
    └── structure-designer.md   # Structure design (opus)
```

## Tips

### Efficient Usage

- **Batch Writing**: Use `/dokhak:continue 5` to write multiple sections at once
- **Check Progress**: Run `/dokhak:status` regularly to monitor completion
- **Customize Persona**: Edit `persona.md` to adjust document tone and style

### Customizing persona.md

Key sections you can modify:

- **Reader Profile**: Adjust target audience level and background
- **Empathy Data**: Add specific learner concerns (Says, Thinks, Does, Feels)
- **Domain Guidelines**: Fine-tune domain-specific requirements
- **Terminology Policy**: Define how technical terms should be explained

### Notes

- Initialize projects in **empty directories**
- Avoid directly editing `task.md` to prevent tracking issues
- **Internet connection** required for web research

## FAQ

### Q: Can I speed up the interview?

Yes! Provide more context upfront. Instead of "React", say "I want to learn React for job preparation. I know HTML/CSS but am new to JavaScript." The interviewer will adapt and ask fewer follow-up questions.

### Q: I want to modify the curriculum structure

Edit `plan.md` and `task.md` directly, then run `/dokhak:doctor` to check consistency.

### Q: The generated document quality isn't satisfactory

1. Edit `persona.md` to provide more detailed writer persona
2. Add additional context to `project-context.md`
3. Delete the document, reset status in `task.md` to `[ ]`, and regenerate

### Q: How do I generate English documents?

During the interview (Round 6), select English as the language. Or for quick start, the language option will be presented.

## Requirements

- Claude Code CLI
- Web access for research (WebSearch, WebFetch tools)

## License

MIT
