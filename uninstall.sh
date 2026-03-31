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
remove_from "$HOME/.gemini/antigravity/skills" "Antigravity"
remove_from "$HOME/.codex/skills" "Codex CLI"

if [ "$REMOVED" -eq 0 ]; then
  yellow "No installed skills found — nothing to remove."
else
  echo ""
  bold "Done. Removed $REMOVED skill(s)."
fi
