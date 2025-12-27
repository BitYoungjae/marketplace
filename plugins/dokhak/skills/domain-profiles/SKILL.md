---
name: domain-profiles
description: >
  Domain-specific configuration profiles for learning resource creation.
  Defines search strategies, special fields, terminology policies, and content structures
  for different academic domains: technology, history, science, arts, and general.
  Use when researcher or writer agents need domain-adapted behavior.
allowed-tools: Read, WebSearch, WebFetch
---

# Domain Profiles Skill

This skill provides domain-specific configurations for learning resource creation.

## When to Use

- During `/init-project` Phase 2 (Research Collection)
- When researcher agent needs domain-specific search strategies
- When writer agent needs domain-adapted content structure
- When creating persona.md with Domain Guidelines section

## Available Profiles

| Profile    | File                           | Description                                    |
| ---------- | ------------------------------ | ---------------------------------------------- |
| Technology | [technology.md](technology.md) | Programming, frameworks, tools, APIs           |
| History    | [history.md](history.md)       | Historical events, periods, civilizations      |
| Science    | [science.md](science.md)       | Physics, chemistry, biology, mathematics       |
| Arts       | [arts.md](arts.md)             | Visual arts, music, performing arts            |
| Language   | [language.md](language.md)     | General topics, linguistics, language learning |

## Profile Structure

Each profile contains:

### 1. Search Strategy

Authoritative sources and search query patterns for the domain.

### 2. Special Fields

Domain-specific metadata fields to collect and include.

### 3. Terminology Policy

How to handle technical terms, translations, and citations.

### 4. Content Structure

Recommended document organization and pedagogical approach.

## Usage Example

```
# In researcher agent prompt
Use {domain}.md from domain-profiles skill for domain-appropriate search strategy

# In writer agent prompt
Reference Content Structure in {domain}.md from domain-profiles skill for document organization
```

## Domain Detection

Domains are determined by the project-interviewer during the interview:

| Domain           | Typical Topics                         |
| ---------------- | -------------------------------------- |
| technology       | Python, React, Docker, API, 프로그래밍 |
| history          | 조선시대, 르네상스, 세계대전, 문명     |
| science          | 양자역학, 미적분, 세포생물학, 화학     |
| arts             | 유화, 작곡, 조각, 연기, 디자인         |
| language/general | 언어학, 글쓰기, 일반 교양              |

## Fallback Behavior

If domain is unclear or "general", use:

- Broad academic search strategies
- Minimal special fields
- Standard terminology policy
- Flexible content structure
