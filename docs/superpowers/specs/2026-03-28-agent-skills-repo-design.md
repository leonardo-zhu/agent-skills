# Agent Skills Repository Design

**Date:** 2026-03-28
**Location:** `~/Agent/Skills/`
**Status:** Approved

---

## Overview

A personal, universal agent skills repository stored at `~/Agent/Skills/`. Skills follow the [agentskills.io](https://agentskills.io) open standard — a single `SKILL.md` file per skill that is natively supported by 30+ agent platforms including Claude Code, Gemini CLI, Cursor, OpenAI Codex, GitHub Copilot, VS Code, Roo Code, and others.

The repository is part of a broader `~/Agent/` directory structure that also contains `MCP/` and may grow to include other agent resource types.

---

## Directory Structure

```
~/Agent/Skills/
├── coding/
│   └── <skill-name>/
│       ├── SKILL.md          # Required: frontmatter + instructions
│       ├── references/       # Optional: reference docs
│       └── scripts/          # Optional: executable scripts
├── writing/
├── devops/
├── productivity/
├── docs/
│   └── superpowers/
│       └── specs/            # Design documents
├── install.sh                # Register skills with installed agents
├── uninstall.sh              # Remove agent registrations
└── README.md
```

Categories are lowercase plural English words, added on demand. Each skill directory name must match its `SKILL.md` `name` field.

---

## Skill Format

Strictly follows [agentskills.io specification](https://agentskills.io/specification):

```markdown
---
name: skill-name
description: What this skill does and when to use it. Include specific keywords.
license: MIT
metadata:
  author: leonardo
  version: "1.0"
---

# Skill instructions...
```

**Rules:**
- `name`: lowercase, hyphens only, matches directory name
- `description`: clear trigger conditions + keywords (1–1024 chars)
- Body: `SKILL.md` under 500 lines; detailed content goes in `references/`

---

## install.sh

Registers `~/Agent/Skills/` with each detected agent by writing the path into each agent's configuration file. Idempotent — safe to run multiple times.

**Supported agents (initial):**
- Claude Code → `~/.claude/settings.json`
- Gemini CLI → `~/.gemini/settings.json` (or equivalent)
- Additional agents added as needed

**Does NOT:**
- Copy or symlink skill files
- Modify skill content
- Require internet access

---

## uninstall.sh

Removes only the configuration entries added by `install.sh`. Does not delete any skill files or directories.

---

## Git Setup

- `~/Agent/Skills/` is a git repository (`git init`)
- No required remote; GitHub push is optional for backup/cross-machine sync
- `.gitignore` excludes OS files (`.DS_Store`, `Thumbs.db`, etc.)

---

## Validation

The agentskills.io reference CLI (`skills-ref`) can validate skill format:

```bash
skills-ref validate ./coding/my-skill
```

Optionally called by `install.sh` before registering skills.

---

## README.md Contents

1. What this repo is
2. Directory structure
3. How to add a new skill (one-line summary + template)
4. How to run `install.sh` / `uninstall.sh`
