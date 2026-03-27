# Agent Skills Repository Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap `~/Agent/Skills/` as a universal, cross-agent skills repository following the agentskills.io open standard, with install/uninstall scripts that copy skills into each agent's native directory, and a git post-commit hook that auto-syncs on every commit.

**Architecture:** Skills live in `~/Agent/Skills/<category>/<skill-name>/SKILL.md`. `install.sh` scans all skill directories, then copies each skill's entire directory into each detected agent's user-level skills path (`~/.claude/skills/` for Claude Code, `~/.gemini/skills/` for Gemini CLI, `~/.openclaw/skills/` for OpenClaw). A git `post-commit` hook runs `install.sh` automatically after every commit. `uninstall.sh` removes only skill directories whose names match skills found in this repo.

**Tech Stack:** Bash (install/uninstall scripts), Git hooks, agentskills.io SKILL.md format (YAML frontmatter + Markdown body)

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `~/Agent/Skills/.git/` | Create | Git repository |
| `~/Agent/Skills/.git/hooks/post-commit` | Create | Auto-run install.sh after every commit |
| `~/Agent/Skills/.gitignore` | Create | Exclude OS/editor junk |
| `~/Agent/Skills/README.md` | Create | Repo overview + add-skill guide |
| `~/Agent/Skills/install.sh` | Create | Copy skills into agent config dirs |
| `~/Agent/Skills/uninstall.sh` | Create | Remove copied skills from agent dirs |
| `~/Agent/Skills/coding/` | Create | Coding-domain skill category |
| `~/Agent/Skills/writing/` | Create | Writing-domain skill category |
| `~/Agent/Skills/devops/` | Create | DevOps-domain skill category |
| `~/Agent/Skills/productivity/` | Create | Productivity-domain skill category |
| `~/Agent/Skills/coding/hello-skill/SKILL.md` | Create | Minimal example skill to validate setup |

---

## Task 1: Git init + directory structure + .gitignore

**Files:**
- Create: `~/Agent/Skills/.gitignore`
- Create dirs: `coding/`, `writing/`, `devops/`, `productivity/`

- [ ] **Step 1: Initialize git repository**

```bash
cd ~/Agent/Skills
git init
```

Expected output:
```
Initialized empty Git repository in /Users/leonardo/Agent/Skills/.git/
```

- [ ] **Step 2: Create category directories with .gitkeep**

```bash
mkdir -p ~/Agent/Skills/{coding,writing,devops,productivity}
touch ~/Agent/Skills/coding/.gitkeep
touch ~/Agent/Skills/writing/.gitkeep
touch ~/Agent/Skills/devops/.gitkeep
touch ~/Agent/Skills/productivity/.gitkeep
```

- [ ] **Step 3: Write .gitignore**

Create `~/Agent/Skills/.gitignore`:

```gitignore
# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# Linux
*~

# Editors
.idea/
.vscode/
*.swp
*.swo
*.sublime-workspace

# Python (for skills that bundle scripts)
__pycache__/
*.pyc
*.pyo
.venv/
venv/

# Node (for skills that bundle scripts)
node_modules/

# OS-generated
.Spotlight-V100
.Trashes
```

- [ ] **Step 4: Verify structure**

```bash
ls ~/Agent/Skills/
```

Expected output (order may vary): `coding/`, `devops/`, `docs/`, `productivity/`, `writing/`, `.gitignore`

Note: `docs/` already exists from design docs. That's expected.

- [ ] **Step 5: Commit**

```bash
cd ~/Agent/Skills
git -c include.path=/Users/leonardo/.gitconfig.claude add .gitignore coding/.gitkeep writing/.gitkeep devops/.gitkeep productivity/.gitkeep
git -c include.path=/Users/leonardo/.gitconfig.claude commit -m "$(cat <<'EOF'
chore: initialize repository structure

Co-authored-by: Claude Code <271226941+leonardo-github-assist[bot]@users.noreply.github.com>
EOF
)"
```

---

## Task 2: README.md

**Files:**
- Create: `~/Agent/Skills/README.md`

- [ ] **Step 1: Write README.md**

Create `~/Agent/Skills/README.md`:

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
cd ~/Agent/Skills
git -c include.path=/Users/leonardo/.gitconfig.claude add README.md
git -c include.path=/Users/leonardo/.gitconfig.claude commit -m "$(cat <<'EOF'
docs: add README with structure and skill creation guide

Co-authored-by: Claude Code <271226941+leonardo-github-assist[bot]@users.noreply.github.com>
EOF
)"
```

---

## Task 3: install.sh

**Files:**
- Create: `~/Agent/Skills/install.sh`

**How it works:**
- Scans `~/Agent/Skills/` for any directory containing `SKILL.md` (excluding `docs/`)
- For each skill found, copies the entire skill directory into each detected agent's skills directory using `rsync`
- Idempotent: `rsync --delete` ensures the copy exactly mirrors the source
- Detects Claude Code by checking if `~/.claude/` exists
- Detects Gemini CLI by checking if `~/.gemini/` exists or `gemini` is in PATH
- Cleans up: removes skill dirs from agent targets that no longer exist in the source repo

- [ ] **Step 1: Write install.sh**

Create `~/Agent/Skills/install.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLED=0

green()  { printf '\033[0;32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$1"; }
bold()   { printf '\033[1m%s\033[0m\n' "$1"; }

# Collect all skill names from this repo
collect_skill_names() {
  find "$SKILLS_DIR" -name "SKILL.md" \
    -not -path "*/docs/*" \
    -not -path "*/.git/*" \
    | while IFS= read -r f; do basename "$(dirname "$f")"; done \
    | sort
}

# Copy a single skill dir into an agent's skills directory
copy_skill() {
  local skill_dir="$1"
  local target_base="$2"
  local agent_name="$3"
  local skill_name
  skill_name="$(basename "$skill_dir")"

  mkdir -p "$target_base/$skill_name"
  rsync -a --delete "$skill_dir/" "$target_base/$skill_name/"
  green "  ✓ $agent_name: $skill_name"
  INSTALLED=$((INSTALLED + 1))
}

# Remove skills from agent dir that no longer exist in the repo
cleanup_stale() {
  local target_base="$1"
  local agent_name="$2"

  if [ ! -d "$target_base" ]; then
    return
  fi

  # Get current skill names from repo
  local repo_skills
  repo_skills="$(collect_skill_names)"

  for dir in "$target_base"/*/; do
    [ -d "$dir" ] || continue
    local name
    name="$(basename "$dir")"
    # Only remove if this skill has a marker showing it came from us
    if [ -f "$dir/.agent-skills-source" ] && ! echo "$repo_skills" | grep -qx "$name"; then
      rm -rf "$dir"
      yellow "  ✗ $agent_name: removed stale $name"
    fi
  done
}

# Copy skill and write a source marker
copy_skill_with_marker() {
  local skill_dir="$1"
  local target_base="$2"
  local agent_name="$3"
  local skill_name
  skill_name="$(basename "$skill_dir")"

  mkdir -p "$target_base/$skill_name"
  rsync -a --delete "$skill_dir/" "$target_base/$skill_name/"
  # Write marker so uninstall/cleanup knows this came from our repo
  echo "$SKILLS_DIR" > "$target_base/$skill_name/.agent-skills-source"
  green "  ✓ $agent_name: $skill_name"
  INSTALLED=$((INSTALLED + 1))
}

bold "Agent Skills — install"
echo "Source: $SKILLS_DIR"
echo ""

# Find all skill directories
SKILL_COUNT=0
while IFS= read -r _sd; do
  SKILL_COUNT=$((SKILL_COUNT + 1))
done < <(
  find "$SKILLS_DIR" -name "SKILL.md" \
    -not -path "*/docs/*" \
    -not -path "*/.git/*" \
    | xargs -I{} dirname {} \
    | sort
)

if [ "$SKILL_COUNT" -eq 0 ]; then
  yellow "No skills found in $SKILLS_DIR"
  yellow "Add skills under coding/, writing/, devops/, or productivity/"
  exit 0
fi

echo "Found $SKILL_COUNT skill(s)"
echo ""

# Determine which agents are present
AGENTS=()
if [ -d "$HOME/.claude" ]; then
  AGENTS+=("claude:$HOME/.claude/skills:Claude Code")
fi
if [ -d "$HOME/.gemini" ] || command -v gemini &>/dev/null; then
  AGENTS+=("gemini:$HOME/.gemini/skills:Gemini CLI")
fi
if [ -d "$HOME/.openclaw" ] || command -v openclaw &>/dev/null; then
  AGENTS+=("openclaw:$HOME/.openclaw/skills:OpenClaw")
fi

if [ "${#AGENTS[@]}" -eq 0 ]; then
  yellow "No supported agents detected."
  exit 0
fi

# Clean up stale skills first
for agent_entry in "${AGENTS[@]}"; do
  IFS=: read -r _id target_dir agent_name <<< "$agent_entry"
  cleanup_stale "$target_dir" "$agent_name"
done

# Copy each skill to each agent
while IFS= read -r skill_dir; do
  skill_name="$(basename "$skill_dir")"
  echo "→ $skill_name"

  for agent_entry in "${AGENTS[@]}"; do
    IFS=: read -r _id target_dir agent_name <<< "$agent_entry"
    copy_skill_with_marker "$skill_dir" "$target_dir" "$agent_name"
  done
done < <(
  find "$SKILLS_DIR" -name "SKILL.md" \
    -not -path "*/docs/*" \
    -not -path "*/.git/*" \
    | xargs -I{} dirname {} \
    | sort
)

echo ""
bold "Done. Installed $INSTALLED skill(s)."
```

- [ ] **Step 2: Make executable**

```bash
chmod +x ~/Agent/Skills/install.sh
```

- [ ] **Step 3: Commit**

```bash
cd ~/Agent/Skills
git -c include.path=/Users/leonardo/.gitconfig.claude add install.sh
git -c include.path=/Users/leonardo/.gitconfig.claude commit -m "$(cat <<'EOF'
feat: add install.sh — copies skills into Claude Code and Gemini CLI

Co-authored-by: Claude Code <271226941+leonardo-github-assist[bot]@users.noreply.github.com>
EOF
)"
```

---

## Task 4: uninstall.sh

**Files:**
- Create: `~/Agent/Skills/uninstall.sh`

**How it works:**
- Scans `~/.claude/skills/` and `~/.gemini/skills/` for directories containing `.agent-skills-source` marker
- Only removes directories whose marker points to this repo (`~/Agent/Skills/`)
- Does not touch skills installed by other means

- [ ] **Step 1: Write uninstall.sh**

Create `~/Agent/Skills/uninstall.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOVED=0

green()  { printf '\033[0;32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$1"; }
bold()   { printf '\033[1m%s\033[0m\n' "$1"; }

remove_from() {
  local agent_skills_dir="$1"
  local agent_name="$2"

  if [ ! -d "$agent_skills_dir" ]; then
    return
  fi

  for dir in "$agent_skills_dir"/*/; do
    [ -d "$dir" ] || continue
    local marker="$dir/.agent-skills-source"
    if [ -f "$marker" ] && [ "$(cat "$marker")" = "$SKILLS_DIR" ]; then
      rm -rf "$dir"
      green "  ✓ $agent_name: removed $(basename "$dir")"
      REMOVED=$((REMOVED + 1))
    fi
  done
}

bold "Agent Skills — uninstall"
echo "Source: $SKILLS_DIR"
echo ""

remove_from "$HOME/.claude/skills" "Claude Code"
remove_from "$HOME/.gemini/skills" "Gemini CLI"
remove_from "$HOME/.openclaw/skills" "OpenClaw"

if [ "$REMOVED" -eq 0 ]; then
  yellow "No installed skills found — nothing to remove."
else
  echo ""
  bold "Done. Removed $REMOVED skill(s)."
fi
```

- [ ] **Step 2: Make executable**

```bash
chmod +x ~/Agent/Skills/uninstall.sh
```

- [ ] **Step 3: Commit**

```bash
cd ~/Agent/Skills
git -c include.path=/Users/leonardo/.gitconfig.claude add uninstall.sh
git -c include.path=/Users/leonardo/.gitconfig.claude commit -m "$(cat <<'EOF'
feat: add uninstall.sh — removes skills installed from this repo

Co-authored-by: Claude Code <271226941+leonardo-github-assist[bot]@users.noreply.github.com>
EOF
)"
```

---

## Task 5: Git post-commit hook

**Files:**
- Create: `~/Agent/Skills/.git/hooks/post-commit`

**How it works:**
- Runs `install.sh` automatically after every `git commit`
- Suppresses output unless there's an error (quiet by default in commit flow)
- Non-blocking: hook failure does not prevent the commit from completing (post-commit, not pre-commit)

- [ ] **Step 1: Write post-commit hook**

Create `~/Agent/Skills/.git/hooks/post-commit`:

```bash
#!/usr/bin/env bash
# Auto-sync skills to all agents after each commit
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
"$REPO_DIR/install.sh" > /dev/null 2>&1 || true
```

- [ ] **Step 2: Make executable**

```bash
chmod +x ~/Agent/Skills/.git/hooks/post-commit
```

- [ ] **Step 3: Verify the hook exists**

```bash
cat ~/Agent/Skills/.git/hooks/post-commit
```

Expected: prints the script from Step 1.

Note: This hook is inside `.git/` so it is NOT tracked by git. This is intentional — git hooks are local to the clone. The README documents that users should run `install.sh` once after cloning, which will set up initial copies. For re-creating the hook on a fresh clone, a `setup.sh` could be added later if needed.

---

## Task 6: Example skill + end-to-end validation

**Files:**
- Create: `~/Agent/Skills/coding/hello-skill/SKILL.md`

This task creates a minimal real skill and runs the full install→verify→uninstall cycle to confirm everything works. The post-commit hook will be tested as part of this flow.

- [ ] **Step 1: Create the example skill directory**

```bash
mkdir -p ~/Agent/Skills/coding/hello-skill
```

- [ ] **Step 2: Write hello-skill/SKILL.md**

Create `~/Agent/Skills/coding/hello-skill/SKILL.md`:

```markdown
---
name: hello-skill
description: Example skill to verify the Agent Skills repository is working correctly. Responds with a greeting and lists the current date.
license: MIT
metadata:
  author: leonardo
  version: "1.0"
---

# Hello Skill

This is an example skill that verifies the Agent Skills repository is installed and working.

When invoked, respond with:
1. A friendly greeting
2. Confirm that the skill was loaded successfully
3. State today's date
```

- [ ] **Step 3: Commit (triggers post-commit hook → install.sh)**

```bash
cd ~/Agent/Skills
git -c include.path=/Users/leonardo/.gitconfig.claude add coding/hello-skill/
git -c include.path=/Users/leonardo/.gitconfig.claude commit -m "$(cat <<'EOF'
feat: add hello-skill example to validate repository setup

Co-authored-by: Claude Code <271226941+leonardo-github-assist[bot]@users.noreply.github.com>
EOF
)"
```

The post-commit hook should silently run `install.sh` and copy the skill.

- [ ] **Step 4: Verify copies were created**

```bash
ls ~/.claude/skills/hello-skill/
ls ~/.gemini/skills/hello-skill/
ls ~/.openclaw/skills/hello-skill/
```

Expected — both directories should contain:
```
SKILL.md
.agent-skills-source
```

- [ ] **Step 5: Verify SKILL.md content matches source**

```bash
diff ~/Agent/Skills/coding/hello-skill/SKILL.md ~/.claude/skills/hello-skill/SKILL.md
```

Expected: no output (files are identical).

- [ ] **Step 6: Verify the source marker**

```bash
cat ~/.claude/skills/hello-skill/.agent-skills-source
```

Expected output:
```
/Users/leonardo/Agent/Skills
```

- [ ] **Step 7: Run uninstall.sh and verify cleanup**

```bash
~/Agent/Skills/uninstall.sh
```

Expected output:
```
Agent Skills — uninstall
Source: /Users/leonardo/Agent/Skills

  ✓ Claude Code: removed hello-skill
  ✓ Gemini CLI: removed hello-skill

Done. Removed 2 skill(s).
```

- [ ] **Step 8: Verify directories are removed**

```bash
ls ~/.claude/skills/hello-skill 2>/dev/null && echo "STILL EXISTS" || echo "REMOVED"
ls ~/.gemini/skills/hello-skill 2>/dev/null && echo "STILL EXISTS" || echo "REMOVED"
ls ~/.openclaw/skills/hello-skill 2>/dev/null && echo "STILL EXISTS" || echo "REMOVED"
```

Expected: all print `REMOVED`.

- [ ] **Step 9: Re-run install.sh to restore**

```bash
~/Agent/Skills/install.sh
```

Expected output:
```
Agent Skills — install
Source: /Users/leonardo/Agent/Skills

Found 1 skill(s)

→ hello-skill
  ✓ Claude Code: hello-skill
  ✓ Gemini CLI: hello-skill

Done. Installed 2 skill(s).
```

---

## Task 7: Commit design docs

**Files:**
- Modify: `~/Agent/Skills/docs/` (already exists)

The `docs/` directory was created before git init, so it needs to be added to the repo.

- [ ] **Step 1: Add docs to git**

```bash
cd ~/Agent/Skills
git -c include.path=/Users/leonardo/.gitconfig.claude add docs/
```

- [ ] **Step 2: Verify what will be committed**

```bash
git status
```

Expected: shows `docs/superpowers/specs/2026-03-28-agent-skills-repo-design.md` and `docs/superpowers/plans/2026-03-28-agent-skills-repo.md` as new files.

- [ ] **Step 3: Commit**

```bash
git -c include.path=/Users/leonardo/.gitconfig.claude commit -m "$(cat <<'EOF'
docs: add design spec and implementation plan

Co-authored-by: Claude Code <271226941+leonardo-github-assist[bot]@users.noreply.github.com>
EOF
)"
```

---

## Spec Coverage Check

| Spec requirement | Covered by |
|---|---|
| `~/Agent/Skills/` directory structure with category subdirs | Task 1 |
| `.gitignore` excludes OS files | Task 1 |
| `SKILL.md` format per agentskills.io | Task 6 (example), README |
| `install.sh` — idempotent, Claude Code, Gemini CLI | Task 3 |
| `uninstall.sh` — removes registrations only | Task 4 |
| `README.md` with all 4 required sections | Task 2 |
| Git repo initialized | Task 1 |
| Auto-sync on commit (post-commit hook) | Task 5 |
| End-to-end validation | Task 6 |
| Design docs committed | Task 7 |
