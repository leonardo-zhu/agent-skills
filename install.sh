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
if [ -d "$HOME/.gemini/antigravity" ] || [ -d "$HOME/.antigravity" ]; then
  AGENTS+=("antigravity:$HOME/.gemini/antigravity/skills:Antigravity")
fi
if [ -d "$HOME/.codex" ]; then
  AGENTS+=("codex:$HOME/.codex/skills:Codex CLI")
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
