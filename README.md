# Agent Skills

A personal repository of reusable [Agent Skills](https://agentskills.io) — cross-agent instructions and workflows that extend AI coding assistants.

Skills follow the [agentskills.io](https://agentskills.io) open standard and work across Claude Code, Gemini CLI, Cursor, OpenAI Codex, and 30+ other agent platforms.

## Directory Structure

```
Skills/
├── coding/          # Code review, refactoring, documentation
├── writing/         # Drafting, editing, summarization
├── devops/          # CI/CD, infrastructure, deployment
├── productivity/    # Workflows, planning, automation
├── install.sh       # Copy skills into agent config dirs
├── uninstall.sh     # Remove copied skills from agent dirs
└── README.md
```

## Adding a New Skill

1. Create the skill directory under the appropriate category:

```bash
mkdir -p ~/Agent/Skills/<category>/<skill-name>
```

2. Create `SKILL.md` with required frontmatter:

```markdown
---
name: skill-name
description: What this skill does and when to use it. Include keywords that match user intent.
license: MIT
metadata:
  author: leonardo
  version: "1.0"
---

# Instructions

Write your instructions here. Keep this file under 500 lines.
Move detailed reference material to `references/` and link to it from here.
```

3. Commit — skills are automatically synced to all agents via the post-commit hook:

```bash
git add .
git commit -m "feat: add <skill-name>"
```

Or run `install.sh` manually without committing:

```bash
~/Agent/Skills/install.sh
```

### Skill Directory Layout

```
<skill-name>/
├── SKILL.md           # Required: frontmatter + instructions
├── references/        # Optional: detailed reference docs
└── scripts/           # Optional: executable scripts
```

## Install / Uninstall

```bash
# Copy all skills into detected agents (also runs automatically on git commit)
~/Agent/Skills/install.sh

# Remove all copied skills from agent dirs (does not delete source skills)
~/Agent/Skills/uninstall.sh
```

Supported agents:
- **Claude Code** → copies into `~/.claude/skills/`
- **Gemini CLI** → copies into `~/.gemini/skills/`
- **OpenClaw** → copies into `~/.openclaw/skills/`

## Validation

Validate a skill's `SKILL.md` format using the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) CLI:

```bash
# Install (requires Node.js)
npm install -g skills-ref

# Validate a skill
skills-ref validate ~/Agent/Skills/coding/my-skill
```
